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
| `arch`       | `x86_64`             | `x86_64`   |
| `bootloader` | `tartarus`, `limine` | `tartarus` |
| `buildtype`  | `debug`, `release`   | `debug`    |

## Running

```sh
python3 scripts/qemu.py [options]
```

| Flag            | Description                                                                                                                  |
| --------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| `--kvm`         | Enable KVM acceleration                                                                                                      |
| `--uefi`        | Boot with UEFI firmware (OVMF)                                                                                               |
| `--gfx`         | Enable graphical display                                                                                                     |
| `--pause`       | Pause CPU at startup                                                                                                         |
| `--limine`      | Use Limine for boot                                                                                                          |
| `--x2apic-only` | Disable xAPIC (TCG + x86_64 only + [custom patched qemu](https://gist.github.com/Mintsuki/25129025509e7f8e30521c1f7940aad4)) |

OVMF firmware is downloaded automatically on first run.
