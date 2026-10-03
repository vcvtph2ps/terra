import os
import subprocess
import sys


def project_path() -> str:
    """Get an absolute path pointing at the project root"""
    return os.path.dirname(os.path.dirname(os.path.realpath(__file__)))


def base_config_path() -> str:
    """Get an absolute path pointing at the base chariot configuration"""
    return os.path.join(project_path(), "chariot_config.toml")


def local_config_path() -> str:
    """Get an absolute path pointing at the local chariot configuration"""
    return os.path.join(project_path(), ".chariot.toml")


def cache_path() -> str:
    """Get an absolute path pointing at the chariot cache"""
    return os.path.join(project_path(), ".chariot-cache")


def rootfs_path() -> str:
    """Get an absolute path pointing at the chariot rootfs"""
    return os.path.join(project_path(), ".chariot-rootfs")


def dest_path() -> str:
    """Get an absolute path pointing at the package install destination"""
    return os.path.join(project_path(), "dest")


def fmt_options(options: list[tuple[str, str]] | None = None) -> list[str]:
    """Format chariot options into args"""
    if options is None:
        return []

    formatted_options: list[str] = []
    for k, v in options:
        formatted_options.append("--option")
        formatted_options.append(f"{k}={v}")

    return formatted_options


def split_arch(
    options: list[tuple[str, str]] | None, arch: str | None
) -> tuple[str, list[tuple[str, str]]]:
    """Split the target architecture out of the chariot options"""
    options = list(options or [])

    if arch is None:
        arch = "x86_64"
        for k, v in options:
            if k == "arch":
                arch = v
                break

    return arch, [(k, v) for k, v in options if k != "arch"]


def install(
    packages: list[str],
    options: list[tuple[str, str]] | None = None,
    arch: str | None = None,
    dest: str | None = None,
    force: bool = False,
) -> subprocess.CompletedProcess:
    """Build and install the given packages into a destination directory"""

    arch, options = split_arch(options, arch)

    if dest is None:
        dest = dest_path()

    command = [
        "chariot",
        "--local-config",
        local_config_path(),
        "install",
        "--cache",
        cache_path(),
        "--rootfs",
        rootfs_path(),
        "--base-config",
        base_config_path(),
        "--arch",
        arch,
        "--worker-count",
        "8",
        "-j",
        "16",
        *fmt_options(options),
    ]

    if force:
        command.append("--force")

    command.extend(packages)
    command.append(dest)
    print(command)
    return subprocess.run(command, cwd=project_path())


def path(
    recipe: str,
    options: list[tuple[str, str]] | None = None,
    arch: str | None = None,
    dest: str | None = None,
    force: bool = False,
) -> str:
    """Install the given recipe and resolve the destination path"""

    if dest is None:
        dest = dest_path()

    result = install([recipe], options=options, arch=arch, dest=dest, force=force)

    if result.returncode != 0:
        sys.exit(f"chariot install failed for recipe {recipe}")

    return dest
