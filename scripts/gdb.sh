#!/usr/bin/env bash

# : "${ARCH:=x86_64}"

# if [[ "$PREKERNEL" == "true" ]]; then
#     KERNEL=$(chariot path custom/prekernel \
#         -o arch="$ARCH" \
#         -o bootloader="$BOOTLOADER")/lunar.elf
# else
#     KERNEL=$(chariot path custom/kernel \
#         -o arch="$ARCH")/kernel.elf
# fi

# KERNEL="dest/kernel.elf"
KERNEL="dest/lunar.elf"
# KERNEL="dest/usr/share/tartarus/riscv64-opensbi.elf"
# KERNEL="dest/usr/share/tartarus/tartarus.elf"
# set substitute-path ../source/kernel ../kernel/kernel
# set substitute-path ../source/pre_kernel ../prekernel/pre_kernel

gdb --ex "file $KERNEL" --ex "set substitute-path ../sources ../"
