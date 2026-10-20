#!/usr/bin/env python3

import argparse
import enum
import os
import platform
import subprocess
import sys
from dataclasses import dataclass, replace
from pathlib import Path

import chariot_utils
import tomllib
from make_image import build_image


def download_ovmf():
    if os.path.exists("edk2-ovmf"):
        return

    r = subprocess.run(
        "curl -L https://github.com/osdev0/edk2-ovmf-nightly/releases/latest/download/edk2-ovmf.tar.gz | gunzip | tar -xf -",
        shell=True,
    )

    if r.returncode != 0:
        print("Failed to download OVMF firmware")
        sys.exit(1)


def load_packages(arch: str, path: Path | None = None) -> list[str]:
    if path is None:
        path = Path(chariot_utils.project_path(), "packages.toml")

    with path.open("rb") as f:
        packages = tomllib.load(f)["packages"]

    if arch not in packages:
        sys.exit(f"No packages configured for architecture '{arch}' in {path}")

    return packages[arch]


class xApicState(enum.Enum):
    NO_X2APIC = 1
    X2APIC = 2
    X2APIC_ONLY = 3


@dataclass(frozen=True)
class Config:
    arch: str = "x86_64"
    accel: str = "tcg"
    pause: bool = False
    uefi: bool = False
    apicState: xApicState = xApicState.X2APIC
    graphics: bool = False
    bootloader: str = "tartarus"
    smp: int = 2
    acpi: bool = False
    release: bool = False


def normalize(cfg: Config) -> Config:
    if cfg.arch != "x86_64":
        if cfg.bootloader == "limine":
            cfg = replace(cfg, uefi=True)

    if cfg.arch == "x86_64":
        cfg = replace(cfg, acpi=True)

    return cfg


def parse_args() -> Config:
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "--arch",
        choices=["x86_64", "riscv64"],
        default="x86_64",
        help="(default: x86_64)",
    )

    parser.add_argument(
        "--accel", choices=["tcg", "kvm"], default="tcg", help="(default: tcg)"
    )

    parser.add_argument(
        "--bootloader",
        choices=["tartarus", "limine"],
        default="tartarus",
        help="(default: tartarus)",
    )

    parser.add_argument(
        "--cores",
        type=int,
        default=2,
        help="The amount of cores to pass to the vm (default: 2)",
    )

    parser.add_argument(
        "--pause", action="store_true", help="Pause the vm for debugging"
    )

    parser.add_argument(
        "--uefi",
        action="store_true",
        help="Boot with UEFI firmware",
    )

    parser.add_argument(
        "--graphics",
        "--gfx",
        dest="graphics",
        action="store_true",
        help="Provide a display to qemu",
    )

    parser.add_argument(
        "--no-x2apic",
        dest="apicState",
        action="store_const",
        const=xApicState.NO_X2APIC,
        help="Disable x2APIC",
    )

    parser.add_argument(
        "--x2apic-only",
        dest="apicState",
        action="store_const",
        const=xApicState.X2APIC_ONLY,
        help="Disable xAPIC (TCG-only with [custom patched qemu](https://gist.github.com/Mintsuki/25129025509e7f8e30521c1f7940aad4))",
    )

    parser.add_argument(
        "--acpi",
        action="store_true",
        help="Enable ACPI support for platforms that use device trees",
    )

    accel = parser.add_mutually_exclusive_group()

    accel.add_argument(
        "--kvm",
        dest="accel",
        action="store_const",
        const="kvm",
        help="Alias of --accel kvm",
    )
    parser.add_argument(
        "--limine",
        dest="bootloader",
        action="store_const",
        const="limine",
        help="Alias of --bootloader limine",
    )

    parser.add_argument(
        "--riscv64",
        action="store_true",
        help="Alias of --arch riscv64",
    )

    parser.add_argument(
        "--release",
        action="store_true",
        help="Use release builds of the kernel instead of debug",
    )

    args = parser.parse_args()

    cfg = Config(
        arch=args.arch,
        accel=args.accel,
        pause=args.pause,
        uefi=args.uefi,
        apicState=args.apicState,
        graphics=args.graphics,
        bootloader=args.bootloader,
        smp=args.cores,
        acpi=args.acpi,
        release=args.release,
    )

    if args.riscv64:
        cfg = replace(cfg, arch="riscv64")

    return normalize(cfg)


def validate(cfg: Config):
    if cfg.apicState == xApicState.X2APIC_ONLY:
        if cfg.accel != "tcg":
            raise ValueError("x2APIC-only mode requires TCG")

    if cfg.accel == "kvm" and platform.machine() != cfg.arch:
        raise ValueError("KVM can only be used with the host architecture")

    if cfg.arch == "x86_64" and not cfg.acpi:
        raise ValueError("ACPI is required on x86_64")

    if cfg.arch == "riscv64" and not cfg.uefi and cfg.acpi:
        raise ValueError("ACPI is not supported on riscv-opensbi")


def qemu_command(cfg: Config, drive_file: str) -> list[str]:
    qemu_cmd = [
        f"qemu-system-{cfg.arch}",
        "-m",
        "512m",
        "--no-reboot",
        "--no-shutdown",
        "-s",
        "-smp",
        f"cpus={cfg.smp}",
    ]

    if cfg.arch == "riscv64":
        if cfg.uefi:
            qemu_cmd += [
                "-drive",
                f"format=raw,if=virtio,file={drive_file}",
            ]
        else:
            qemu_cmd += ["-kernel", "dest/usr/share/tartarus/riscv64-opensbi.bin"]
            qemu_cmd += ["-global", "virtio-mmio.force-legacy=false"]
            qemu_cmd += ["-drive", f"file={drive_file},if=none,format=raw,id=x0"]
            qemu_cmd += ["-device", "virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0"]
    else:
        qemu_cmd += [
            "-drive",
            f"format=raw,file={drive_file}",
        ]

    qemu_cmd += [
        "-d",
        "int,cpu_reset",
        "-D",
        "qemu_err.log",
    ]

    if not cfg.graphics:
        qemu_cmd += [
            "-vga",
            "none",
            "-display",
            "none",
        ]
    elif cfg.arch == "x86_64":
        qemu_cmd += [
            "-vga",
            "std",
        ]
    else:
        qemu_cmd += [
            "-device",
            "ramfb",
        ]

    if cfg.apicState == xApicState.X2APIC_ONLY:
        qemu_cmd[0] = f"../qemu/build/qemu-system-{cfg.arch}"
        qemu_cmd += [
            "-global",
            "apic.x2apic-locked=on",
            "-global",
            "apic.x2apic-mce=on",
        ]

    if cfg.uefi:
        qemu_cmd += [
            "-drive",
            f"if=pflash,unit=0,format=raw,file=edk2-ovmf/ovmf-code-{cfg.arch}.fd,readonly=on",
        ]

    if cfg.arch == "x86_64":
        qemu_cmd += [
            "-serial",
            "stdio",
        ]
        xapic_option = "on" if cfg.apicState != xApicState.NO_X2APIC else "off"
        if cfg.accel == "kvm":
            qemu_cmd += [
                "-M",
                "q35,accel=kvm",
                "-cpu",
                f"host,lkgs=on,fred=on,invtsc=on,x2apic={xapic_option},xsave=on,xsaveopt=on,xsavec=on,xsaves=on,avx=on,avx2=on,fma=on,umip=on",
            ]
        else:
            qemu_cmd += [
                "-M",
                "q35,accel=tcg,smm=off",  # i8042=off
                "-cpu",
                f"max,lkgs=on,fred=on,invtsc=on,x2apic={xapic_option},la57=on",
            ]
    else:
        qemu_cmd += [
            "-serial",
            "stdio",
            "-M",
            f"virt,acpi={'on' if cfg.acpi else 'off'}",
            "-cpu",
            "rv64",
        ]

    if cfg.arch == "x86_64":
        qemu_cmd += [
            "-device",
            "pxb-pcie,bus=pcie.0,id=pcie.1,bus_nr=128",
            "-device",
            "pcie-root-port,bus=pcie.1,id=rp0",
            "-device",
            "qemu-xhci,bus=rp0",
        ]

    if cfg.pause:
        qemu_cmd.append("-S")

    return qemu_cmd


def main() -> None:
    download_ovmf()

    cfg = parse_args()
    validate(cfg)

    firmware = "efi" if cfg.uefi else "bios" if cfg.arch != "riscv64" else "opensbi"
    image_name = f"{cfg.bootloader}-{cfg.arch}-{firmware}"
    build_image(
        image_name,
        load_packages(cfg.arch),
        Path("."),
        "release" if cfg.release else "debug",
    )

    qemu_cmd = qemu_command(cfg, f"{image_name}.img")
    print(" ".join(qemu_cmd))
    subprocess.run(qemu_cmd)


if __name__ == "__main__":
    main()
