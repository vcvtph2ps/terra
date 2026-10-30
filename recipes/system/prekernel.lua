local fabricate = require("recipes.system_tools.fabricate")
local clang_tidy_plugin = require("recipes.system_tools.clang-tidy-plugin")
local kernel = require("recipes.system.kernel")

local prekernel_source = Source {
    name = "prekernel",
    base = Git("https://github.com/vcvtph2ps/theia.git", "6e2b4606272190ca623135d5d782da425521a215"),
    dependencies = { kernel.kernel, fabricate },
    prepare = [[
        fabricate fetch
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
    env = {
        ARCH = chariot.target_arch,
        BUILD_TYPE = chariot.options["build_type"] or "debug"
    },
    configure = [[
        fabricate setup \
            --build-dir=$BUILD_DIR \
            --project-dir=$SOURCE_DIR \
            --prefix=/ \
            --option=buildtype="$BUILD_TYPE" \
            --option=arch="$ARCH"
    ]],
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
        fabricate install --build-dir=$BUILD_DIR --dest-dir=$INSTALL_DIR
        install $SOURCE_DIR/support/tartarus.cfg $INSTALL_DIR
        install $SOURCE_DIR/support/limine.conf $INSTALL_DIR
    ]]
}

return {
    source = prekernel_source,
    package = prekernel
}
