local fabricate = require("recipes.system_tools.fabricate")
local clang_tidy_plugin = require("recipes.system_tools.clang-tidy-plugin")
local ksym = require("recipes.system_tools.ksym")

local kernel_source = Source { name = "kernel", Git("https://github.com/vcvtph2ps/lunar.git", "b7858f3dc58944d2f8186f10a3596953ef03147e") }

local kernel = Package {
    name = "kernel",
    version = "1.0",
    revision = 1,
    source = kernel_source,
    dependencies = {
        fabricate,
        clang_tidy_plugin,

        "nasm", "clang", "clang-tidy", "lld", "llvm", "ninja-build"
    },
    configure = ([[
        fabricate --build-dir=$BUILD_DIR setup \
            --config=$SOURCE_DIR/fab.lua \
            --prefix=/ \
            -o arch="{arch}" \
            -o buildtype="{build_type}" \
    ]]):gsub("{arch}", chariot.target_arch):gsub("{build_type}", chariot.options["build_type"]),
    build = [[
        run-clang-tidy \
            -quiet \
            -load /usr/local/lib/clang-tidy-plugins/libelysium-tidy.so \
            -source-filter "^.*/kernel/.*\\.c\$" \
            -header-filter "^.*/kernel/.*\\.h\$" \
            -config-file $SOURCE_DIR/.clang-tidy \
            -use-color

        ninja -j$PARALLELISM
        gzip -9 -c "$BUILD_DIR/output/kernel.elf" > "$BUILD_DIR/output/kernel.elf.gz"
    ]],
    install = [[
        fabricate --build-dir=$BUILD_DIR install --dest-dir=$INSTALL_DIR

        case $ARCH in
            x86_64)
                OBJCOPY_OUTPUT="elf64-x86-64"
                OBJCOPY_ARCH="i386:x86-64"
                ;;
            riscv64)
                OBJCOPY_OUTPUT="elf64-littleriscv"
                OBJCOPY_ARCH="riscv"
                ;;
            *)
                echo "Unknown architecture: $ARCH"
                exit 1
                ;;
        esac

        llvm-objcopy \
            --input-target binary \
            --redefine-sym _binary__chariot_build_output_kernel_elf_gz_start=_binary_kernel_elf_start \
            --redefine-sym _binary__chariot_build_output_kernel_elf_gz_end=_binary_kernel_elf_end \
            --redefine-sym _binary__chariot_build_output_kernel_elf_gz_size=_binary_kernel_elf_size \
            --output-target $OBJCOPY_OUTPUT \
            --binary-architecture $OBJCOPY_ARCH \
            $BUILD_DIR/output/kernel.elf.gz $INSTALL_DIR/kernel.o
    ]]
}

local kernel_symbols = Package {
    name = "kernel_symbols",
    version = "1.0",
    revision = 1,
    dependencies = { kernel, ksym, "llvm" },
    build = [[
        llvm-nm -S $SYSROOT_DIR/kernel.elf -n > ./kernel_symbols.txt
        ksym ./kernel_symbols.txt ./kernel.ksym
    ]],
    install = [[
        install kernel.ksym $INSTALL_DIR
    ]]
}

return { kernel = kernel, symbols = kernel_symbols }
