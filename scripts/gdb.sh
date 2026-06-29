#!/bin/bash

: "${ARCH:=x86_64}"

if [[ "$PREKERNEL" == "true" ]]; then
    KERNEL=$(chariot path custom/prekernel \
        -o arch="$ARCH" \
        -o bootloader="$BOOTLOADER" \
        --raw)/lunar.elf
else
    KERNEL=$(chariot path custom/kernel \
        -o arch="$ARCH" \
        --raw)/kernel.elf
fi

gdb --ex "file $KERNEL" --ex "set substitute-path ../sources ../"
