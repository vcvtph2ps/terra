#!/bin/bash

for suite in posix ansi; do
    for binary in /opt/mlibc-tests/"$suite"/*; do
        [[ -f "$binary" && -x "$binary" ]] || continue

        echo "Running: $binary"
        "$binary"
        status=$?

        if (( status != 0 )); then
            echo "FAILED ($status): $binary"
        fi
    done
done
