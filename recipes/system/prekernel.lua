local fabricate = require("recipes.system_tools.fabricate")
local clang_tidy_plugin = require("recipes.system_tools.clang-tidy-plugin")
local kernel = require("recipes.system.kernel")

local prekernel_source = Source {
    name = "prekernel",
    base = Git("https://github.com/vcvtph2ps/theia.git", "3c689db22c8a2c5d640620eccf698e7c98c24520"),
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

        "nasm", "clang", "clang-tidy", "lld", "llvm", "ninja-build", "tree",
        "python3", "zstd"
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
            -source-filter "^.*/prekernel/pre_kernel/.*\\.c\$" \
            -header-filter "^.*/prekernel/pre_kernel/.*\\.h\$" \
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
