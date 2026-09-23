local BINUTILS_VERSION = "2.44"
local autotools = require("recipes.tools.autotools")
local reconfigure = require("recipes.tools.reconfigure")
local pkgconf = require("recipes.tools.pkgconf")

local binutils_source = Source {
    Archive("https://ftp.gnu.org/gnu/binutils/binutils-" .. BINUTILS_VERSION .. ".tar.gz", "0cdd76777a0dfd3dd3a63f215f030208ddb91c2361d2bcc02acec0f1c16b6a2e"),
    patches = { "patches/binutils.patch" },
    dependencies = { "perl", "m4", pkgconf, reconfigure, autotools.autoconf_2_69, autotools.automake, autotools.libtool, libtool = autotools.libtool_source },
    prepare = [[
        reconfigure.sh -I"$(realpath ./config)"
        ls $SOURCES_DIR/libtool/build-aux/{config.sub,config.guess,install-sh}
        echo gahjksdgkhjasdfgkjhsadfgkhjkhj
        cp -pv $SOURCES_DIR/libtool/build-aux/{config.sub,config.guess,install-sh} libiberty/
    ]]
}

local binutils = Tool {
    name = "binutils",
    version = BINUTILS_VERSION,
    revision = 1,
    dependencies = { "build-essential", "texinfo", pkgconf, autotools.autoconf_2_69, autotools.automake, autotools.libtool, binutils = binutils_source },
    configure = [[
        $SOURCES_DIR/binutils/configure \
            --with-sysroot=$SYSROOT_DIR \
            --prefix=$PREFIX \
            --target=x86_64-lunar \
            --enable-targets=x86_64-elf,x86_64-pe \
            --disable-nls \
            --enable-default-execstack=no \
            --disable-werror
    ]],
    build = [[
        PATH="$PATH:/usr/bin/core_perl" make -j$PARALLELISM
    ]],
    install = [[
        DESTDIR=$INSTALL_DIR make install-strip
    ]]
}

return binutils
