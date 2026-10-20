# Terra

Distribution for [Lunar](https://github.com/vcvtph2ps/lunar). Uses [chariot](https://github.com/chariot-build/chariot) to manage packages and produce bootable images.

## Requirements

- `chariot`
- `python3`
- `qemu` (for running)
- `curl` (for fetching OVMF firmware)

## Running

```sh
python3 scripts/qemu.py --help
```

OVMF firmware is downloaded automatically on first run.
