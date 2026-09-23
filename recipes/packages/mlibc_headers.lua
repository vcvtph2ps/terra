local pkgconf = require("recipes.tools.pkgconf")
local support_source = require("recipes.sources.support")
local mlibc_source = require("recipes.sources.mlibc")

local mlibc_headers = Package {
    name = "mlibc_headers",
    version = "1.0",
    revision = 1,
    dependencies = {
        "meson", "build-essential",

        pkgconf,

        support = support_source,
        mlibc_headers = mlibc_source
    },
    configure = [[
        meson setup \
            --cross-file $SOURCES_DIR/support/lunar.cross \
            --prefix=$PREFIX \
            --buildtype=release \
            -Dheaders_only=true \
            $SOURCES_DIR/mlibc_headers
    ]],
    build = [[
        ninja -j$PARALLELISM
    ]],
    install = [[
        DESTDIR=$INSTALL_DIR ninja install
    ]],
}

return mlibc_headers
