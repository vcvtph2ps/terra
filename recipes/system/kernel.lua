local fabricate = require("recipes.system_tools.fabricate")
local clang_tidy_plugin = require("recipes.system_tools.clang-tidy-plugin")

local kernel_source = Source { Git("https://github.com/vcvtph2ps/lunar.git", "615937f2265699cde081523fe768539b8cafddd2") }

local kernel = Package {
    name = "kernel",
    version = "1.0",
    revision = 1,
    dependencies = {
        kernel = kernel_source,
        fabricate,
        clang_tidy_plugin,

        "nasm", "clang", "clang-tidy", "lld", "llvm", "ninja-build"
    },
    -- options: [ "arch", "buildtype" ]
    configure = ([[
        fabricate --build-dir=$BUILD_DIR setup \
            --config=$SOURCES_DIR/kernel/fab.lua \
            --prefix=/ \
            -o arch="{arch}" \
            -o buildtype="{build_type}" \
    ]]):gsub("{arch}", chariot.target_arch):gsub("{build_type}", chariot.options["build_type"]),
    build = [[
        run-clang-tidy \
            -load /usr/local/lib/clang-tidy-plugins/libelysium-tidy.so \
            -source-filter "^.*/kernel/.*\\.c\$" \
            -header-filter "^.*/kernel/.*\\.h\$" \
            -config-file $SOURCES_DIR/kernel/.clang-tidy \
            -use-color

        ninja -j$PARALLELISM
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
            --redefine-sym _binary__chariot_build_output_kernel_elf_start=_binary_kernel_elf_start \
            --redefine-sym _binary__chariot_build_output_kernel_elf_end=_binary_kernel_elf_end \
            --redefine-sym _binary__chariot_build_output_kernel_elf_size=_binary_kernel_elf_size \
            --output-target $OBJCOPY_OUTPUT \
            --binary-architecture $OBJCOPY_ARCH \
            $BUILD_DIR/output/kernel.elf $INSTALL_DIR/kernel.o
    ]]
}

return kernel
