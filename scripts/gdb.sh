#!/bin/zsh
# make this use the first one if PREKERNEL=true is set
if [[ "$PREKERNEL" == "true" ]]; then
    KERNEL=$(chariot path custom/prekernel -o arch=x86_64 -o bootloader=$BOOTLOADER --raw)/lunar.elf
else
    KERNEL=$(chariot path custom/kernel -o arch=x86_64 --raw)/kernel.elf
fi

gdb --ex "file $KERNEL" --ex "set substitute-path ../sources ../"
