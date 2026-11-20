local BINUTILS_VERSION = "2.44"
local autotools = require("recipes.tools.autotools")
local reconfigure = require("recipes.tools.reconfigure")
local pkgconf = require("recipes.tools.pkgconf")
local build_meta = require("recipes.packages.build-meta")

-- binutils is a picky little bitch and wants EXACTLY 2.69
local autoconf_2_69 = Tool {
    name = "autoconf_2_69",
    version = "2.69",
    revision = 1,
    source = Source {
        name = "autoconf_2_69",
        GnuArchive("autoconf", "2.69", "tar.gz", "954bd69b391edc12d6a4a51a2dd1476543da5c6bbf05a95b59dc0dd6fd4c2969"),
    },
    dependencies = {
        "m4", "make", "gcc", "perl",
    },
    configure = [[
        $SOURCE_DIR/configure --prefix=$PREFIX
    ]],
    build = [[
        make
    ]],
    install = [[
        DESTDIR=$INSTALL_DIR make install
    ]]
}


local binutils_source = Source {
    name = "binutils",
    GnuArchive("binutils", BINUTILS_VERSION, "tar.gz", "0cdd76777a0dfd3dd3a63f215f030208ddb91c2361d2bcc02acec0f1c16b6a2e"),
    patches = {
        "patches/binutils.patch",
        "patches/binutils-ld-defaults.patch",
    },
    dependencies = { "perl", "m4", pkgconf, reconfigure, autoconf_2_69, autotools.automake, autotools.libtool, autotools.libtool_source },
    prepare = [[
        reconfigure.sh -I"$(realpath ./config)"
        ls $SOURCES_DIR/libtool/build-aux/{config.sub,config.guess,install-sh}
        cp -pv $SOURCES_DIR/libtool/build-aux/{config.sub,config.guess,install-sh} libiberty/
    ]]
}

local binutils = Package {
    name = "binutils",
    version = BINUTILS_VERSION,
    revision = 1,
    source = binutils_source,
    dependencies = {
        build_meta.cc,
        build_meta.libc_headers,
        build_meta.libc,

        "build-essential",
        "texinfo",
        pkgconf,
        autoconf_2_69,
        autotools.automake,
        autotools.libtool,
    },
    env = {
        TARGET_ARCH = chariot.target_arch,
        CC = "lunar-clang",
        AR = "llvm-ar",
        RANLIB = "llvm-ranlib",
        STRIP = "llvm-strip",
    },
    configure = [[
        CFLAGS="-g -O2 -std=gnu17" \
        CXXFLAGS="-g -O2 -std=gnu++17" \
        $SOURCE_DIR/configure \
            --with-sysroot=/ \
            --with-lib-path=/usr/local/lib:/lib:/usr/lib \
            --prefix=$PREFIX \
            --host=$TARGET_ARCH-lunar \
            --target=$TARGET_ARCH-lunar \
            --enable-targets=$TARGET_ARCH-elf,$TARGET_ARCH-pe \
            --disable-nls \
            --enable-default-execstack=no \
            --disable-werror
    ]],
    build = [[
        PATH="$PATH:/usr/bin/core_perl" make
    ]],
    install = [[
        DESTDIR=$INSTALL_DIR make install-strip
    ]]
}

return binutils
