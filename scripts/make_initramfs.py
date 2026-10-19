#!/usr/bin/env python3

import argparse
import shutil
import subprocess
import sys
from pathlib import Path
from typing import Iterable

import chariot_utils


def make_initramfs(
    packages: Iterable[str],
    arch: str,
    dest: Path,
    build_type: str = "debug",
    cleanup: bool = True,
    compress: bool = True,
) -> None:
    work_dir = Path(chariot_utils.project_path(), "initramfs_temp")

    if work_dir.is_dir():
        shutil.rmtree(work_dir)

    root_dir = work_dir / "root"
    root_dir.mkdir(parents=True)

    options = [("build_type", build_type)]

    try:
        if len(list(packages)) > 0 and (
            chariot_utils.install(
                list(packages),
                options=options,
                arch=arch,
                dest=str(root_dir),
                force=True,
            ).returncode
            != 0
        ):
            sys.exit("Failed to install initramfs packages")

        (root_dir / "dev").mkdir(exist_ok=True)

        if (
            chariot_utils.exec_tool(
                ["rdsk"],
                "rdsk -c ./root -o initramfs.rdk",
                cwd="/initramfs",
                mounts=[f"{work_dir.name}=/initramfs"],
                options=options,
                arch=arch,
            ).returncode
            != 0
        ):
            sys.exit("Failed to invoke rdsk")

        shutil.move(str(work_dir / "initramfs.rdk"), str(dest))

        if compress:
            compressed = dest.with_name(dest.name + ".tmp")
            with open(compressed, "wb") as out:
                if (
                    subprocess.run(
                        ["gzip", "-6", "-c", str(dest)], stdout=out
                    ).returncode
                    != 0
                ):
                    compressed.unlink(missing_ok=True)
                    sys.exit("Failed to compress initramfs")
            compressed.replace(dest)
    finally:
        if cleanup:
            shutil.rmtree(work_dir, ignore_errors=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Build an initramfs from packages.")

    parser.add_argument(
        "--noclean",
        action="store_true",
        help="Doesn't remove the initramfs temp dir after creation",
    )

    parser.add_argument(
        "--no-compress",
        action="store_true",
        help="Don't compress the initramfs with gzip -9",
    )

    parser.add_argument(
        "--arch",
        choices=["x86_64", "riscv64"],
        default="x86_64",
    )

    parser.add_argument(
        "--buildtype",
        choices=["debug", "release"],
        default="debug",
        help="Build type used when installing packages (default: debug)",
    )

    parser.add_argument(
        "-d",
        "--dest",
        type=Path,
        default=Path("./initramfs.rdk"),
        help="Where to save the initramfs (default: ./initramfs.rdk)",
    )

    parser.add_argument(
        "packages",
        nargs="+",
        help="One or more packages to install",
    )

    args = parser.parse_args()

    make_initramfs(
        args.packages,
        args.arch,
        args.dest,
        args.buildtype,
        cleanup=not args.noclean,
        compress=not args.no_compress,
    )
