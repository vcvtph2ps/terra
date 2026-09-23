local autotools = require("recipes.tools.autotools")

local PKGCONF_VERSION = "2.4.3"

local pkgconf_source = Source {
    Archive("https://github.com/pkgconf/pkgconf/archive/refs/tags/pkgconf-" .. PKGCONF_VERSION .. ".tar.gz", "cea5b0ed69806b69c1900ce2f6f223a33f15230ad797243634df9fd56e64b156"),
    dependencies = { autotools.autoconf, autotools.automake, autotools.libtool, "m4", "perl" },
    prepare = [[
        libtoolize -cfvi && autoreconf -fvi
    ]]
}

local pkgconf = Tool {
    name = "pkgconf",
    version = PKGCONF_VERSION,
    revision = 1,
    dependencies = {
        "build-essential", "gcc-multilib",
        autotools.autoconf, autotools.automake, autotools.libtool,
        pkgconf = pkgconf_source
    },
    configure = [[
        $SOURCES_DIR/pkgconf/configure --prefix=$PREFIX
    ]],
    build = [[
        make -j$PARALLELISM
    ]],
    install = [[
        DESTDIR=$INSTALL_DIR make install-strip
        install -d $INSTALL_DIR$PREFIX/share/pkgconfig/personality.d

        PERSONALITY_FILE="$INSTALL_DIR$PREFIX/share/pkgconfig/personality.d/x86_64-lunar.personality"
        echo "Triplet: x86_64-lunar" >> $PERSONALITY_FILE
        echo "SysrootDir: $SYSROOT_DIR" >> $PERSONALITY_FILE
        echo "DefaultSearchPaths: $SYSROOT_DIR/usr/lib/pkgconfig:$SYSROOT_DIR/usr/share/pkgconfig" >> $PERSONALITY_FILE
        echo "SystemIncludePaths: $SYSROOT_DIR/usr/include" >> $PERSONALITY_FILE
        echo "SystemLibraryPaths: $SYSROOT_DIR/usr/lib" >> $PERSONALITY_FILE

        ln -s pkgconf $INSTALL_DIR$PREFIX/bin/x86_64-lunar-pkg-config
    ]]
}

return pkgconf
