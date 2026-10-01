local autotools = require("recipes.tools.autotools")
local reconfigure = require("recipes.tools.reconfigure")
local pkgconf = require("recipes.tools.pkgconf")
local mlibc_headers = require("recipes.packages.mlibc_headers")
local mlibc = require("recipes.packages.mlibc")
local binutils = require("recipes.tools.binutils")
local gcc_source = require("recipes.sources.gcc")

local gcc = Tool {
    name = "gcc",
    version = gcc_source.GCC_VERSION,
    revision = 1,
    dependencies = {
        "build-essential",
        "texinfo",

        "m4",
        "perl",
        "gawk",
        "bison",

        binutils,

        pkgconf,
        reconfigure,
        autotools.autoconf_2_69,
        autotools.automake,
        autotools.libtool,
        autotools.autoconf_archive,
        libtool = autotools.libtool_source,

        mlibc_headers,
        mlibc,

        gcc_source.gcc,
    },
    configure = [[
        cp -a "$SOURCES_DIR/gcc" "$BUILD_DIR/gcc-src"

        CFLAGS="-O2" CXXFLAGS="-O2 -fno-char8_t" $BUILD_DIR/gcc-src/configure \
            --target=x86_64-lunar \
            --prefix=$PREFIX \
            --with-sysroot=$SYSROOT_DIR \
            --enable-languages=c,c++ \
            --disable-nls \
            --disable-multilib \
            --enable-initfini-array \
            --enable-threads=posix \
            --enable-shared \
            --enable-host-shared
    ]],
    build = [[
         export PATH="$PATH:/usr/bin/core_perl"
         make -j$PARALLELISM all-gcc
         make -j$PARALLELISM all-target-libgcc
         make -j$PARALLELISM all-target-libstdc++-v3
    ]],
    install = [[
        DESTDIR=$INSTALL_DIR make install-gcc
        DESTDIR=$INSTALL_DIR make install-target-libgcc
        DESTDIR=$INSTALL_DIR make install-target-libstdc++-v3
    ]],
}

return gcc
