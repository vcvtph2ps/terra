#!/usr/bin/env bash

if [[ "$PREKERNEL" == "true" ]]; then
    KERNEL="dest/lunar.elf"
else
    KERNEL="dest/kernel.elf"
fi

gdb --ex "file $KERNEL" --ex "set substitute-path ../source/kernel ../kernel/kernel" --ex "set substitute-path ../source/pre_kernel ../prekernel/pre_kernel"
