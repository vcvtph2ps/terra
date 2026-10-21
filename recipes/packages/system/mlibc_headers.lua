local pkgconf = require("recipes.tools.pkgconf")
local support_source = require("recipes.sources.support")
local mlibc_source = require("recipes.sources.mlibc")
local llvm = require("recipes.tools.llvm")

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
        TARGET_ARCH = chariot.target_arch,
    },
    configure = [[
        meson setup \
            --cross-file "$SOURCES_DIR/support/${TARGET_ARCH}/lunar.cross" \
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
