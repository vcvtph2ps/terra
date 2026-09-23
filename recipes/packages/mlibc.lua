local pkgconf = require("recipes.tools.pkgconf")
local binutils = require("recipes.tools.binutils")
local gcc_bootstrap = require("recipes.tools.gcc_bootstrap")
local support_source = require("recipes.sources.support")
local mlibc_source = require("recipes.sources.mlibc")
local mlibc_headers = require("recipes.packages.mlibc_headers")

local mlibc = Package {
    name = "mlibc",
    version = "1.0",
    revision = 1,
    dependencies = {
        "meson", "git", "cmake",
        mlibc_headers,
        binutils,
        gcc_bootstrap,

        pkgconf,

        support = support_source,
        mlibc = mlibc_source
    },
    configure = [[
        meson setup \
            --cross-file $SOURCES_DIR/support/lunar.cross \
            --prefix=$PREFIX \
            --libdir=lib \
            --buildtype=debug \
            -Dno_headers=true \
            -Ddefault_library=both \
            -Dbuild_tests=false \
            -Duse_freestnd_hdrs=disabled \
            $SOURCES_DIR/mlibc
    ]],
    build = [[
        ninja -j$PARALLELISM
    ]],
    install = [[
        DESTDIR=$INSTALL_DIR ninja install
    ]],
}

return mlibc
