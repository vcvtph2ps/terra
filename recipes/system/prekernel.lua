local fabricate = require("recipes.system_tools.fabricate")
local clang_tidy_plugin = require("recipes.system_tools.clang-tidy-plugin")
local kernel = require("recipes.system.kernel")

local prekernel_source = Source {
    name = "prekernel",
    Git("https://github.com/vcvtph2ps/theia.git", "044a14ecc8d5970bb8b1ed3a038072752a4cf723"),
    dependencies = { kernel.kernel },
    prepare = [[
        cp $SYSROOT_DIR/kernel.o $SOURCE_DIR/kernel.o
    ]]
}

local prekernel = Package {
    name = "prekernel",
    version = "1.0",
    revision = 1,
    source = prekernel_source,
    dependencies = {
        kernel.kernel,
        clang_tidy_plugin,
        fabricate,

        "nasm", "clang", "clang-tidy", "lld", "llvm", "ninja-build", "tree"
    },
    configure = ([[
        fabricate --build-dir=$BUILD_DIR setup \
            --config=$SOURCE_DIR/fab.lua \
            --prefix=/ \
            -o arch="{arch}" \
    ]]):gsub("{arch}", chariot.target_arch),
    build = [[
        run-clang-tidy \
            -load /usr/local/lib/clang-tidy-plugins/libelysium-tidy.so \
            -source-filter "^.*/prekernel/.*\\.c\$" \
            -header-filter "^.*/prekernel/.*\\.h\$" \
            -config-file $SOURCE_DIR/.clang-tidy \
            -use-color

        ninja -j$PARALLELISM
    ]],
    install = [[
        fabricate --build-dir=$BUILD_DIR install --dest-dir=$INSTALL_DIR
        install $SOURCE_DIR/support/tartarus.cfg $INSTALL_DIR
        install $SOURCE_DIR/support/limine.conf $INSTALL_DIR
    ]]
}

return {
    source = prekernel_source,
    package = prekernel
}
