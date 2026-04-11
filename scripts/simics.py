#!/usr/bin/env python3
import os
import subprocess
import sys

import chariot_utils

if (
    chariot_utils.build(
        ["source/kernel", "source/test_app", "source/init_system", "custom/image"],
        options=["-o", f"arch=x86_64"],
    ).returncode
    != 0
):
    print("Build failed")
    exit(1)

simics_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "../..", "simics"))
try:
    os.chdir(simics_dir)
except OSError as e:
    print(f"Cannot change directory to {simics_dir}: {e}", file=sys.stderr)
    sys.exit(1)

image_dir = chariot_utils.path("custom/image", options=["-o", "arch=x86_64"]).strip()
iso = os.path.join(image_dir, "output.iso")

stdin_payload = "\n".join(
    [
        '$cpu_comp_class = "x86-experimental-fred"',
        f'run-script ./targets/qsp-x86/qsp-dvd-boot.simics iso_image="{iso}"',
        "r",
        "",
    ]
)
proc = subprocess.Popen(
    ["simics"],
    stdin=subprocess.PIPE,
    stdout=subprocess.PIPE,
    stderr=subprocess.STDOUT,
    text=True,
    bufsize=1,
)

try:
    proc.stdin.write(stdin_payload)
    proc.stdin.close()
    for line in proc.stdout:
        print(line, end="", flush=True)
    retcode = proc.wait()
finally:
    try:
        proc.stdout.close()
    except Exception:
        pass

# Make any later subprocess.run(...) calls return the same result so the script
# uses the live-run's status.
result = subprocess.CompletedProcess(args=["simics"], returncode=retcode)
subprocess.run = lambda *a, **k: result
result = subprocess.run(["simics"], input=stdin_payload, text=True)
if result.returncode != 0:
    print("Simics execution failed", file=sys.stderr)
    sys.exit(result.returncode)
