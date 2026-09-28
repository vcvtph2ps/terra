#!/usr/bin/env python3

# Python script to run clangd inside of the chariot runtime.
# This allows clangd to run in the same exact environment as the build.
# This is designed for NixOS but should work fine on any other distro given the shebang is changed.

import argparse
import os
import subprocess
from os.path import abspath, dirname
from pathlib import Path
from typing import cast

project_path = Path(dirname(dirname(abspath(__file__))))
source_path = Path(os.getcwd())
os.chdir(project_path)


# Parse arguments
def parse_kv(s: str) -> tuple[str, str]:
    if "=" not in s:
        raise argparse.ArgumentTypeError("expected KEY=VALUE")
    k, v = s.split("=", 1)
    if not k:
        raise argparse.ArgumentTypeError("key must be non-empty")
    return k, v


parser = argparse.ArgumentParser(prog="chariot_clangd.py")

_ = parser.add_argument("package", type=str)
_ = parser.add_argument("--arch", type=str)
_ = parser.add_argument(
    "-m",
    "--source-mapping",
    action="append",
    type=parse_kv,
    default=[],
    metavar="KEY=VALUE",
)
_ = parser.add_argument(
    "-o", "--option", action="append", type=parse_kv, default=[], metavar="KEY=VALUE"
)

args = parser.parse_args()

package = cast(str, args.package)
source_mappings = cast(list[tuple[str, str]], args.source_mapping)
options = cast(list[tuple[str, str]], args.option)
arch = args.arch
source_mappings = [(source_path / Path(k), v) for k, v in source_mappings]

# Chariot command
args = [
    "chariot",
    "exec",
    "--cache",
    project_path / ".chariot-cache",
    "--rootfs",
    project_path / ".chariot-rootfs",
    "--base-config",
    project_path / "chariot_config.toml",
    "--stdin",
]

# Prepare context
args.extend(["--build-env", package])
args.extend(["--cwd", "/chariot/build"])
args.extend(["-b", f"/chariot/build={package}"])

args.extend(["-p", "clangd"])

args.extend(["-m", f"{project_path}=/.chariot-clangd-cache:/chariot/clangd"])
args.extend(["-e", "HOME=/chariot/clangd"])
args.extend(["-e", "XDG_CACHE_HOME=/chariot/clangd/cache"])

for k, v in source_mappings:
    args.extend(["-m", f"{k}=/chariot/sources/{v}:ro"])

for k, v in options:
    args.extend(["--options", f"{k}={v}"])

if arch:
    args.extend(["--arch", arch])

# Clangd command
clangd_cmd = "clangd --background-index --clang-tidy"
if len(source_mappings) > 0:
    clangd_cmd += f" --path-mappings {','.join([f'{k}=$SOURCES_DIR/{v}' for k, v in source_mappings])}"

print(args)

args.append(clangd_cmd)

# Run Clangd
_ = subprocess.run(
    args,
)
