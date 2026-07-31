# Terra

Distribution for [Lunar](https://github.com/vcvtph2ps/lunar). Uses [chariot](https://github.com/elysium-os/chariot) to manage packages and produce bootable images.

## Requirements

- `chariot`
- `python3`
- `qemu` (for running)
- `curl` (for fetching OVMF firmware)

## Building

```sh
chariot build custom/image -o bootloader=limine -o buildtype=release
```

Options:

| Option       | Values               | Default    |
| ------------ | -------------------- | ---------- |
| `arch`       | `x86_64`, `riscv64`  | `x86_64`   |
| `bootloader` | `tartarus`, `limine` | `tartarus` |
| `buildtype`  | `debug`, `release`   | `debug`    |

## Running

```sh
python3 scripts/qemu.py [options]
```

| Flag            | Description                                                                                                                  |
| --------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| `--arch`        | Architecture to build and run (`x86_64`, `riscv64`); non-x86_64 targets use UEFI + Limine                                    |
| `--riscv64`     | Shorthand for `--arch riscv64`                                                                                               |
| `--accel`       | Acceleration mode (`tcg`, `kvm`); KVM requires the host architecture to match                                                |
| `--kvm`         | Use KVM acceleration                                                                                                         |
| `--tcg`         | Use TCG emulation (default)                                                                                                  |
| `--bootloader`  | Bootloader to use (`tartarus`, `limine`); Tartarus is only supported on x86_64                                               |
| `--limine`      | Shorthand for `--bootloader limine`                                                                                          |
| `--uefi`        | Boot with UEFI firmware (OVMF); implied on non-x86_64 targets                                                                |
| `--gfx`         | Enable graphical display                                                                                                     |
| `--pause`       | Pause CPU at startup                                                                                                         |
| `--cores`       | Number of CPU cores (default 2)                                                                                              |
| `--up`          | Use a single core                                                                                                            |
| `--acpi`        | Toggle ACPI; required and forced on x86_64                                                                                   |
| `--no-x2apic`   | Disable x2APIC                                                                                                               |
| `--x2apic-only` | Disable xAPIC (TCG + x86_64 only + [custom patched qemu](https://gist.github.com/Mintsuki/25129025509e7f8e30521c1f7940aad4)) |
| `--release`     | Build in release mode                                                                                                        |

OVMF firmware is downloaded automatically on first run.
