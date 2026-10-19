local pkgconf = require("recipes.tools.pkgconf")
local support_source = require("recipes.sources.support")
local mlibc_source = require("recipes.sources.mlibc")
local llvm = require("recipes.tools.llvm")
local target = require("recipes.helpers.target")

local mlibc_headers = Package {
    name = "mlibc_headers",
    version = "1.0",
    revision = 1,
    source = mlibc_source,
    dependencies = {
        "meson", llvm.tool,

        pkgconf,

        support_source,
    },
    env = {
        CROSS_FILE = target.crossFiles[chariot.target_arch],
        TARGET_TRIPLE = target.targetTriple[chariot.target_arch],
        TARGET_CFLAGS = target.cflags[chariot.target_arch],
    },
    configure = [[
        CFLAGS="$TARGET_CFLAGS --target=$TARGET_TRIPLE --sysroot=$SYSROOT_DIR" \
        CXXFLAGS="$TARGET_CFLAGS --target=$TARGET_TRIPLE --sysroot=$SYSROOT_DIR" \
        meson setup \
            --cross-file "$SOURCES_DIR/support/${CROSS_FILE}" \
            --prefix=$PREFIX \
            --buildtype=release \
            -Dheaders_only=true \
            $SOURCE_DIR
    ]],
    build = [[
        ninja -j$PARALLELISM
    ]],
    install = [[
        DESTDIR=$INSTALL_DIR ninja install
    ]],
}

return mlibc_headers
