#!/usr/bin/env python3
import os
import platform
import subprocess
import sys
from dataclasses import dataclass

import chariot_utils


def download_ovmf():
    # check if ovmf firmware exists
    if not os.path.exists("edk2-ovmf"):
        r = subprocess.run(
            "curl -L https://github.com/osdev0/edk2-ovmf-nightly/releases/latest/download/edk2-ovmf.tar.gz | gunzip | tar -xf -",
            shell=True,
        )
        if r.returncode != 0:
            print("Failed to download OVMF firmware")
            exit(1)


@dataclass(frozen=True)
class Config:
    arch: str = "x86_64"
    accel: str = "tcg"
    pause: bool = False
    uefi: bool = False
    x2apic_only: bool = False
    graphics: bool = False
    bootloader: str = "tartarus"


def parse_args(argv):
    cfg = Config()

    for arg in argv:
        if arg == "--uefi":
            cfg = cfg.__class__(**{**cfg.__dict__, "uefi": True})
        elif arg in ("--graphics", "--gfx"):
            cfg = cfg.__class__(**{**cfg.__dict__, "graphics": True})
        elif arg == "--tcg":
            cfg = cfg.__class__(**{**cfg.__dict__, "accel": "tcg"})
        elif arg == "--kvm":
            cfg = cfg.__class__(**{**cfg.__dict__, "accel": "kvm"})
        elif arg == "--pause":
            cfg = cfg.__class__(**{**cfg.__dict__, "pause": True})
        elif arg == "--x2apic-only":
            cfg = cfg.__class__(**{**cfg.__dict__, "x2apic_only": True})
        elif arg == "--limine":
            cfg = cfg.__class__(**{**cfg.__dict__, "bootloader": "limine"})
    if cfg.arch != "x86_64":
        cfg = cfg.__class__(**{**cfg.__dict__, "uefi": True})

    return cfg


def validate(cfg: Config):
    if cfg.x2apic_only and (cfg.accel == "kvm" or cfg.arch != "x86_64"):
        raise ValueError("xAPIC can only be disabled with tcg on x86_64")

    architecture = platform.machine()
    if cfg.accel == "kvm" and architecture != cfg.arch:
        raise ValueError("KVM can only be used with the host architecture")


download_ovmf()

cfg = parse_args(sys.argv[1:])
validate(cfg)

chariot_options = [
    ("arch", cfg.arch),
    ("bootloader", cfg.bootloader),
]

if (
    chariot_utils.build(
        ["source/kernel", "custom/image"], options=chariot_options
    ).returncode
    != 0
):
    print("Build failed")
    exit(1)


qemu_cmd = [
    "qemu-system-" + cfg.arch,
    "-m",
    "512m",
    "--no-reboot",
    "--no-shutdown",
    "-s",
    "-smp",
    "cpus=2",
    "-drive",
    f"format=raw,file={chariot_utils.path('custom/image', options=chariot_options).strip()}/kernel_{cfg.bootloader}_{'efi' if cfg.uefi else 'bios'}.img",
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

if cfg.x2apic_only and cfg.arch == "x86_64" and cfg.accel == "tcg":
    qemu_cmd[0] = "../qemu/build/qemu-system-" + cfg.arch
    qemu_cmd += ["-global", "apic.x2apic-locked=on", "-global", "apic.x2apic-mce=on"]

if cfg.uefi:
    qemu_cmd += [
        "-drive",
        f"if=pflash,unit=0,format=raw,file=edk2-ovmf/ovmf-code-{cfg.arch}.fd,readonly=on",
    ]

if cfg.arch == "x86_64":
    qemu_cmd += ["-debugcon", "stdio"]
    if cfg.accel == "kvm":
        qemu_cmd += [
            "-M",
            "q35,accel=kvm",
            "-cpu",
            "host,lkgs=on,fred=on,invtsc=on,x2apic=on,xsave=on,xsaveopt=on,xsavec=on,xsaves=on,avx=on,avx2=on,fma=on",
        ]
    else:
        qemu_cmd += [
            "-M",
            "q35,accel=tcg,smm=off",
            "-cpu",
            # "qemu64,lkgs=on,fred=on,invtsc=on,x2apic=on,xsave=on,xsaveopt=on,xsavec=on,xsaves=on,avx=on,avx2=on,fma=on",
            "Skylake-Client,lkgs=on,fred=on,invtsc=on,x2apic=on,xsave=on,xsaveopt=on,xsavec=on,xsaves=on,avx=on,avx2=on,fma=on",
            # "Penryn",
        ]

if cfg.pause:
    qemu_cmd += ["-S"]

print(qemu_cmd)
subprocess.run(qemu_cmd)
