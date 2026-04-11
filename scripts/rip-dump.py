#!/usr/bin/env -S python3 -B

import os
import subprocess
import sys

import chariot_utils

if len(sys.argv) < 2:
    print("Usage: dump.py <address>", file=sys.stderr)
    sys.exit(1)

start_address = int(sys.argv[1], 16)
end_address = start_address + 8

subprocess.run(
    [
        "objdump",
        os.path.join(chariot_utils.path("custom/kernel"), "kernel.elf"),
        "-d",
        "-wrC",
        "--visualize-jumps=color",
        "--disassembler-color=on",
        f"--start-address={hex(start_address)}",
        f"--stop-address={hex(end_address)}",
    ]
)

subprocess.run(
    [
        "addr2line",
        "-fai",
        "-e",
        os.path.join(chariot_utils.path("custom/kernel"), "kernel.elf"),
        hex(start_address),
    ]
)