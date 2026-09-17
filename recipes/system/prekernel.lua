local fabricate = require("recipes.system_tools.fabricate")
local clang_tidy_plugin = require("recipes.system_tools.clang-tidy-plugin")
local kernel = require("recipes.system.kernel")

local prekernel_source = Source {
    Git("https://github.com/vcvtph2ps/theia.git", "058684ea7f2b8839c07ed115ea73cde1ee9f08e1"),
    dependencies = { kernel = kernel },
    prepare = [[
        cp $SYSROOT_DIR/kernel.o $SOURCE_DIR/kernel.o
    ]]
}

local prekernel = Package {
    name = "prekernel",
    version = "1.0",
    revision = 1,
    dependencies = {
        prekernel = prekernel_source,
        kernel = kernel,
        clang_tidy_plugin.tools.clang_tidy_plugin,
        fabricate.tools.fabricate,

        "nasm", "clang", "clang-tidy", "lld", "llvm", "ninja-build", "tree"
    },
    configure = [[
        fabricate --build-dir=$BUILD_DIR setup \
            --config=$SOURCES_DIR/prekernel/fab.lua \
            --prefix=/ \
            -o arch=$ARCH \
            -o bootloader="limine" \
    ]],
    build = [[
        run-clang-tidy \
            -load /usr/local/lib/clang-tidy-plugins/libelysium-tidy.so \
            -source-filter "^.*/prekernel/.*\\.c\$" \
            -header-filter "^.*/prekernel/.*\\.h\$" \
            -config-file $SOURCES_DIR/prekernel/.clang-tidy \
            -use-color

        ninja -j$PARALLELISM
    ]],
    install = [[
        fabricate --build-dir=$BUILD_DIR install --dest-dir=$INSTALL_DIR
    ]]
}

return {
    source = prekernel_source,
    package = prekernel
}
