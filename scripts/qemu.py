#!/usr/bin/env python3

import argparse
import os
import platform
import subprocess
import sys
from dataclasses import dataclass, replace

import chariot_utils


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


@dataclass(frozen=True)
class Config:
    arch: str = "x86_64"
    accel: str = "tcg"
    pause: bool = False
    uefi: bool = False
    x2apic_only: bool = False
    graphics: bool = False
    bootloader: str = "tartarus"
    smp: int = 2
    acpi: bool = False


def normalize(cfg: Config) -> Config:
    if cfg.arch != "x86_64":
        cfg = replace(
            cfg,
            uefi=True,
            bootloader="limine",
        )

    if cfg.arch == "x86_64":
        cfg = replace(cfg, acpi=True)

    return cfg


def parse_args() -> Config:
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "--arch",
        choices=["x86_64", "riscv64"],
        default="x86_64",
    )

    parser.add_argument(
        "--accel",
        choices=["tcg", "kvm"],
        default="tcg",
    )

    parser.add_argument(
        "--bootloader",
        choices=["tartarus", "limine"],
        default="tartarus",
    )

    parser.add_argument(
        "--cores",
        type=int,
        default=2,
    )

    parser.add_argument(
        "--pause",
        action="store_true",
    )

    parser.add_argument(
        "--uefi",
        action="store_true",
    )

    parser.add_argument(
        "--graphics",
        "--gfx",
        dest="graphics",
        action="store_true",
    )

    parser.add_argument(
        "--x2apic-only",
        action="store_true",
    )

    parser.add_argument(
        "--acpi",
        action="store_true",
    )

    accel = parser.add_mutually_exclusive_group()

    accel.add_argument(
        "--kvm",
        dest="accel",
        action="store_const",
        const="kvm",
    )

    accel.add_argument(
        "--tcg",
        dest="accel",
        action="store_const",
        const="tcg",
    )

    parser.add_argument(
        "--limine",
        dest="bootloader",
        action="store_const",
        const="limine",
    )

    parser.add_argument(
        "--up",
        dest="cores",
        action="store_const",
        const=1,
    )

    parser.add_argument(
        "--riscv64",
        action="store_true",
    )

    args = parser.parse_args()

    cfg = Config(
        arch=args.arch,
        accel=args.accel,
        pause=args.pause,
        uefi=args.uefi,
        x2apic_only=args.x2apic_only,
        graphics=args.graphics,
        bootloader=args.bootloader,
        smp=args.cores,
        acpi=args.acpi,
    )

    if args.riscv64:
        cfg = replace(cfg, arch="riscv64")

    return normalize(cfg)


def validate(cfg: Config):
    if cfg.x2apic_only:
        if cfg.arch != "x86_64":
            raise ValueError("x2APIC-only mode is only supported on x86_64")
        if cfg.accel != "tcg":
            raise ValueError("x2APIC-only mode requires TCG")

    if cfg.accel == "kvm" and platform.machine() != cfg.arch:
        raise ValueError("KVM can only be used with the host architecture")

    if cfg.bootloader == "tartarus" and cfg.arch == "riscv64":
        raise ValueError("Tartarus is not supported on riscv64")

    if cfg.arch == "x86_64" and not cfg.acpi:
        raise ValueError("ACPI is required on x86_64")


download_ovmf()

cfg = parse_args()
validate(cfg)

chariot_options = [
    ("arch", cfg.arch),
    ("bootloader", cfg.bootloader),
]

if (
    chariot_utils.build(
        [
            "source/kernel",
            "source/prekernel",
            "custom/image",
        ],
        options=chariot_options,
    ).returncode
    != 0
):
    print("Build failed")
    sys.exit(1)

drive_path = chariot_utils.path(
    "custom/image",
    options=chariot_options,
).strip()

drive_file = f"{drive_path}/kernel_{cfg.bootloader}_{'efi' if cfg.uefi else 'bios'}.img"

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
    qemu_cmd += [
        "-drive",
        f"format=raw,if=virtio,file={drive_file}",
    ]
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

if cfg.x2apic_only:
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
        "-debugcon",
        "stdio",
    ]

    if cfg.accel == "kvm":
        qemu_cmd += [
            "-M",
            "q35,accel=kvm",
            "-cpu",
            "host,lkgs=on,fred=on,invtsc=on,x2apic=on,xsave=on,xsaveopt=on,xsavec=on,xsaves=on,avx=on,avx2=on,fma=on,umip=on",
        ]
    else:
        qemu_cmd += [
            "-M",
            "q35,accel=tcg,smm=off",
            "-cpu",
            "Skylake-Client,lkgs=on,fred=on,invtsc=on,x2apic=on,xsave=on,xsaveopt=on,xsavec=on,xsaves=on,avx=on,avx2=on,fma=on,la57=on,umip=on,tsc-frequency=2500000000",
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

if cfg.pause:
    qemu_cmd.append("-S")

print(" ".join(qemu_cmd))
subprocess.run(qemu_cmd)
