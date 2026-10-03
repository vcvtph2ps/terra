local autotools = require("recipes.tools.autotools")
local reconfigure = require("recipes.tools.reconfigure")
local pkgconf = require("recipes.tools.pkgconf")
local mlibc_headers = require("recipes.packages.mlibc_headers")
local binutils = require("recipes.tools.binutils")
local gcc_source = require("recipes.sources.gcc")

local gcc_bootstrap = Tool {
    name = "gcc_bootstrap",
    version = gcc_source.GCC_VERSION,
    revision = 1,
    dependencies = {
        "build-essential",
        "texinfo",
        "m4",
        "perl",
        binutils,

        pkgconf,
        reconfigure,
        autotools.autoconf_2_69,
        autotools.automake,
        autotools.libtool,
        autotools.autoconf_archive,
        autotools.libtool_source,

        mlibc_headers,

        gcc_source.gcc,
    },
    configure = [[
        cp -a "$SOURCES_DIR/gcc" "$BUILD_DIR/gcc-src"

        CFLAGS="-O2" CXXFLAGS="-O2 -fno-char8_t" $BUILD_DIR/gcc-src/configure \
            --target=x86_64-lunar \
            --prefix=$PREFIX \
            --with-sysroot=$SYSROOT_DIR \
            --enable-languages=c,c++ \
            --without-headers \
            --without-newlib \
            --enable-languages=c,c++ \
            --disable-multilib \
            --enable-initfini-array \
            --disable-shared \
            --disable-hosted-libstdcxx \
            --disable-fixincludes \
            --disable-wchar_t \
            --disable-libssp \
            --disable-libsanitizer \
            --disable-libquadmath
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

return gcc_bootstrap
