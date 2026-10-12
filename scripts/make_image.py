#!/usr/bin/env python3

import argparse
import os
import shutil
import sys
from pathlib import Path
from typing import Iterable, Sequence

import chariot_utils
from make_initramfs import make_initramfs

IMAGE_CHOICES = [
    "tartarus-x86_64-bios",
    "tartarus-x86_64-efi",
    "tartarus-riscv64-opensbi",
    "tartarus-riscv64-efi",
    "limine-x86_64-bios",
    "limine-x86_64-efi",
    "limine-riscv64-efi",
]

ROOT_FILES: list[tuple[str, str | None]] = [
    ("lunar.elf", "/boot/lunar.elf"),
    ("initramfs.rdk", "/boot/initramfs.rdk"),
    ("kernel.ksym", "/boot/kernel.ksym"),
]


def format_file_list(files: Sequence[tuple[str, str | None]]) -> str:
    return "#".join(
        f"{source}@{target}" if target is not None else source
        for source, target in files
    )


def make_image(image: str, root: Path, dest: Path, build_type: str = "debug") -> None:
    bootloader, arch, firmware = image.split("-")
    root = Path(root)
    root.mkdir(parents=True, exist_ok=True)

    options = [("build_type", build_type), ("bootloader", bootloader)]

    packages = ["kernel_symbols", "prekernel"]
    if bootloader == "tartarus":
        packages.append(f"tartarus_{firmware}")
    elif bootloader == "limine":
        packages.append("limine")

    if (
        chariot_utils.install(
            packages,
            options=options,
            arch=arch,
            dest=str(root),
            force=True,
        ).returncode
        != 0
    ):
        sys.exit("Failed to install image packages")

    image_files: list[tuple[str, str | None]] = list(ROOT_FILES)

    if bootloader == "tartarus":
        image_files.append(("tartarus.cfg", None))
    elif bootloader == "limine":
        image_files.append(("limine.conf", None))

    if firmware == "efi":
        if bootloader == "tartarus":
            efi_name = "BOOTX64.EFI" if arch == "x86_64" else "BOOTRISCV64.EFI"
            image_files.append(
                ("usr/share/tartarus/tartarus.efi", f"/EFI/BOOT/{efi_name}")
            )
        elif bootloader == "limine":
            image_files.append(("BOOTX64.EFI", "/EFI/BOOT/BOOTX64.EFI"))
            image_files.append(("BOOTRISCV64.EFI", "/EFI/BOOT/BOOTRISCV64.EFI"))

        create_image = (
            "mkimg --protective-mbr --dest output.img "
            "--partition type=fs:name=ESP:gpt-type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B"
            f":fs-type=fat32:fs-size=256:fs-files={format_file_list(image_files)}"
        )
    elif firmware == "bios":
        if bootloader == "tartarus":
            create_image = (
                "mkimg --protective-mbr --dest output.img "
                "--bootsector usr/share/tartarus/x86_64-bios.bin "
                "--partition type=file:name=Tartarus:gpt-type=54524154-5241-5355-424F-4F5450415254"
                ":file=usr/share/tartarus/tartarus.sys "
                "--partition type=fs:gpt-type=454C5953-4955-4D52-4F4F-545041525458"
                f":fs-type=fat32:fs-size=256:fs-files={format_file_list(image_files)}"
            )
        elif bootloader == "limine":
            image_files.append(("limine-bios.sys", None))
            create_image = (
                "mkimg --protective-mbr --dest output.img "
                "--partition type=fs:gpt-type=21686148-6449-6e6f-744e-656564454649:fs-type=fat32:fs-size=1 "
                "--partition type=fs:gpt-type=5af96cdc-fcb0-44f8-84ae-42ee9dc9b829"
                f":fs-type=fat32:fs-size=256:fs-files={format_file_list(image_files)}"
                " && limine bios-install output.img 1 --force"
            )
    elif firmware == "opensbi":
        create_image = (
            "mkimg --protective-mbr --dest output.img "
            "--partition type=fs:name=ESP:gpt-type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B"
            f":fs-type=fat32:fs-size=256:fs-files={format_file_list(image_files)}"
        )
    else:
        sys.exit(f"Unknown firmware type: {firmware}")

    exec_packages = ["mkimg"]
    if arch == "x86_64" and bootloader == "limine" and firmware == "bios":
        exec_packages.append("limine")

    mount = os.path.relpath(root, chariot_utils.project_path())

    if (
        chariot_utils.exec_tool(
            exec_packages,
            create_image,
            cwd="/imagetemp",
            mounts=[f"{mount}=/imagetemp"],
            options=options,
            arch=arch,
        ).returncode
        != 0
    ):
        sys.exit("Failed to invoke mkimg")

    shutil.move(str(root / "output.img"), str(dest))


def build_image(
    image: str, packages: Iterable[str], dest: Path, build_type: str = "debug"
) -> None:
    arch = image.split("-")[1]
    dest = Path(dest)

    root = Path(chariot_utils.dest_path())
    root.mkdir(parents=True, exist_ok=True)

    initramfs = root.joinpath("initramfs.rdk")
    make_initramfs(packages, arch, initramfs, build_type)
    make_image(image, root, dest.joinpath(f"{image}.img"), build_type)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Build bootable disk images.")

    parser.add_argument(
        "-d",
        "--dest",
        type=Path,
        default=Path("./"),
        help="Where to save the images (default: ./)",
    )

    parser.add_argument(
        "-i",
        "--initramfs",
        type=Path,
        default=Path("./initramfs.rdk"),
        help="What initramfs to include in the image (default: ./initramfs.rdk)",
    )

    parser.add_argument(
        "--buildtype",
        choices=["debug", "release"],
        default="debug",
        help="Build type used when installing packages (default: debug)",
    )

    parser.add_argument(
        "images",
        nargs="+",
        choices=IMAGE_CHOICES,
        help="Images to build",
    )

    args = parser.parse_args()

    root = Path(chariot_utils.project_path(), "image_temp")
    if root.is_dir():
        shutil.rmtree(root)
    root.mkdir()

    shutil.copy(str(args.initramfs), str(root.joinpath("initramfs.rdk")))

    try:
        for image in args.images:
            make_image(image, root, args.dest.joinpath(f"{image}.img"), args.buildtype)
    finally:
        shutil.rmtree(root, ignore_errors=True)
