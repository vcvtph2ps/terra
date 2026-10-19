return {
    crossFiles = {
        x86_64 = "lunar-x86_64.cross",
        riscv64 = "lunar-riscv64.cross",
    },
    targetTriple = {
        x86_64 = "x86_64-unknown-lunar",
        riscv64 = "riscv64-unknown-lunar",
    },
    cflags = {
        x86_64 = "-march=x86-64 -mabi=sysv",
        riscv64 = "-march=rv64gc_zbb_zba_zihintpause",
    }
}
