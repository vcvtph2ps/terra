local llvm = require("recipes.tools.llvm")
local support_source = require("recipes.sources.support")

local clang_wrapper = Tool {
    name = "clang-wrapper",
    version = "1.0",
    revision = 1,

    dependencies = {
        support_source
    },

    runtime_dependencies = {
        llvm.tool
    },
    env = {
        TARGET_ARCH = chariot.target_arch,
    },
    build = [[
        cp $SOURCES_DIR/support/$TARGET_ARCH/lunar-clang $BUILD_DIR/lunar-clang
        cp $SOURCES_DIR/support/$TARGET_ARCH/lunar-clang++ $BUILD_DIR/lunar-clang++
    ]],

    install = [[
        install -D lunar-clang $INSTALL_DIR$PREFIX/bin/lunar-clang
        install -D lunar-clang++ $INSTALL_DIR$PREFIX/bin/lunar-clang++
    ]]
}

return clang_wrapper
