local autotools = require("recipes.tools.autotools")
local reconfigure = require("recipes.tools.reconfigure")
local pkgconf = require("recipes.tools.pkgconf")

local GMP_VERSION = "6.2.1"
local MPFR_VERSION = "4.1.0"
local MPC_VERSION = "1.2.1"
local ISL_VERSION = "0.24"
local GCC_VERSION = "15.2.0"

local gmp_source = Source {
    name = "gmp",
    GnuArchive("gmp", GMP_VERSION, "tar.bz2", "eae9326beb4158c386e39a356818031bd28f3124cf915f8c5b1dc4c7a36b4d7c")
}
local mpfr_source = Source {
    name = "mpfr",
    GnuArchive("mpfr", MPFR_VERSION, "tar.bz2", "feced2d430dd5a97805fa289fed3fc8ff2b094c02d05287fd6133e7f1f0ec926")
}
local mpc_source = Source {
    name = "mpc",
    GnuArchive("mpc", MPC_VERSION, "tar.gz", "17503d2c395dfcf106b622dc142683c1199431d095367c6aacba6eec30340459")
}

local isl_source = Source {
    name = "isl",
    Archive("https://libisl.sourceforge.io/isl-" .. ISL_VERSION .. ".tar.bz2", "fcf78dd9656c10eb8cf9fbd5f59a0b6b01386205fe1934b3b287a0a1898145c0")
}

local gcc_source = Source {
    name = "gcc",
    GnuArchive("gcc", GCC_VERSION, "tar.gz", "7294d65cc1a0558cb815af0ca8c7763d86f7a31199794ede3f630c0d1b0a5723"),
    patches = { "patches/gcc.patch" },
    dependencies = {
        "perl", "m4", "curl", "build-essential", "texinfo", "grep",
        pkgconf, reconfigure,
        autotools.autoconf_2_69, autotools.automake, autotools.libtool,
        autotools.libtool_source,
        gmp_source,
        mpfr_source,
        mpc_source,
        isl_source,
    },
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

return {
    GCC_VERSION = GCC_VERSION,
    gcc = gcc_source,
}
