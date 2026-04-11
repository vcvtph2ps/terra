import os
import subprocess
import sys


def config_path():
    """Get an absolute path pointing at the configuration"""
    return os.path.join(
        os.path.dirname(os.path.dirname(os.path.realpath(__file__))), "config.chariot"
    )


def fmt_options(options: list[tuple[str, str]] | None = None) -> list[str]:
    """Format chariot options into args"""
    if options is None:
        return []

    formatted_options: list[str] = []
    for k, v in options:
        formatted_options.append("-o")
        formatted_options.append(f"{k}={v}")

    return formatted_options


def path(recipe: str, options: list[tuple[str, str]] | None = None):
    """Resolve an absolute path to the installation of the given recipe"""

    result = subprocess.run(
        [
            "chariot",
            "--config",
            config_path(),
            *fmt_options(options),
            "path",
            "-r",
            recipe,
        ],
        capture_output=True,
        text=True,
    )

    if result.returncode != 0:
        sys.exit(f"chariot path failed: {result.stderr}")

    return result.stdout


def build(recipes: list[str], options: list[tuple[str, str]] | None = None):
    """Build the given recipe"""

    return subprocess.run(
        ["chariot", "--config", config_path(), *fmt_options(options), "build", *recipes]
    )
