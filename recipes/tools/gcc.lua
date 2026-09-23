local autotools = require("recipes.tools.autotools")
local reconfigure = require("recipes.tools.reconfigure")
local pkgconf = require("recipes.tools.pkgconf")
local mlibc_headers = require("recipes.packages.mlibc_headers")
local mlibc = require("recipes.packages.mlibc")
local binutils = require("recipes.tools.binutils")

local GMP_VERSION = '6.2.1'
local MPFR_VERSION = '4.1.0'
local MPC_VERSION = '1.2.1'
local ISL_VERSION = '0.24'
local GETTEXT_VERSION = '0.22'
local GCC_VERSION = "15.2.0"

-- yes. I needed to make this a variable, because gnu ftp is so fucking slow...
local GNU_MIRROR = "https://mirrors.evalyngoemer.com"

local function GnuArchive(project, version, extention)
    -- print(GNU_MIRROR .. "/gnu/" .. project .. "/" .. project .. "-" .. version .. extention)
    return GNU_MIRROR .. "/gnu/" .. project .. "/" .. project .. "-" .. version .. extention
end

local function GnuArchive2(project, version, extention)
    -- print(GNU_MIRROR ..
    -- "/gnu/" .. project .. "/" .. project .. "-" .. version .. "/" .. project .. "-" .. version .. extention)
    return GNU_MIRROR ..
        "/gnu/" .. project .. "/" .. project .. "-" .. version .. "/" .. project .. "-" .. version .. extention
end


local gmp_source = Source {
    Archive(GnuArchive("gmp", GMP_VERSION, ".tar.bz2"), "eae9326beb4158c386e39a356818031bd28f3124cf915f8c5b1dc4c7a36b4d7c")
}
local mpfr_source = Source {
    Archive(GnuArchive("mpfr", MPFR_VERSION, ".tar.bz2"), "feced2d430dd5a97805fa289fed3fc8ff2b094c02d05287fd6133e7f1f0ec926")
}
local mpc_source = Source {
    Archive(GnuArchive("mpc", MPC_VERSION, ".tar.gz"), "17503d2c395dfcf106b622dc142683c1199431d095367c6aacba6eec30340459")
}
local isl_source = Source {
    Archive("https://libisl.sourceforge.io/isl-" .. ISL_VERSION .. ".tar.bz2", "fcf78dd9656c10eb8cf9fbd5f59a0b6b01386205fe1934b3b287a0a1898145c0")
}
-- local gettext_source = Source {
--     Archive(GnuArchive("gettext", GETTEXT_VERSION, ".tar.bz2"), "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")
-- }

local gcc_deps = {
    gmp = gmp_source,
    mpfr = mpfr_source,
    mpc = mpc_source,
    isl = isl_source,
    -- gettext = gettext_source
}

local gcc_source = Source {
    Archive(GnuArchive2("gcc", GCC_VERSION, ".tar.gz"), "7294d65cc1a0558cb815af0ca8c7763d86f7a31199794ede3f630c0d1b0a5723"),
    patches = { "patches/gcc.patch" },
    dependencies = table.merge({
        "perl", "m4", "curl", "build-essential", "texinfo", "grep",
        pkgconf, reconfigure,
        autotools.autoconf_2_69, autotools.automake, autotools.libtool,
        libtool = autotools.libtool_source,
    }, gcc_deps),
    prepare = [[
        cp -a "$SOURCES_DIR/gmp"  ./gmp
        cp -a "$SOURCES_DIR/mpfr" ./mpfr
        cp -a "$SOURCES_DIR/mpc"  ./mpc
        cp -a "$SOURCES_DIR/isl"  ./isl
        rm -rf gettext*

        reconfigure.sh -I"$(realpath ./config)"

        cp -pv $SOURCES_DIR/libtool/build-aux/{config.sub,config.guess,install-sh} libiberty/
        cp -pv $SOURCES_DIR/libtool/build-aux/{config.sub,config.guess,install-sh} libgcc/
    ]],
}

local gcc = Tool {
    name = "gcc",
    version = GCC_VERSION,
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

        gcc = gcc_source,
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
