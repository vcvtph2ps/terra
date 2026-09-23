local reconfigure = require("recipes.tools.reconfigure")

local AUTOCONF_VERSION = "2.72"
local AUTOMAKE_VERSION = "1.16.5"
local LIBTOOL_VERSION = "2.5.4"
local AUTOCONF_ARCHIVE_VERSION = "2024.10.16"

local autoconf_source = Source {
    Archive("https://ftp.gnu.org/gnu/autoconf/autoconf-" .. AUTOCONF_VERSION .. ".tar.gz", "afb181a76e1ee72832f6581c0eddf8df032b83e2e0239ef79ebedc4467d92d6e"),
    patches = { "patches/autoconf.patch" }
}

local autoconf = Tool {
    name = "autoconf",
    version = AUTOCONF_VERSION,
    revision = 1,
    dependencies = {
        "m4", "make", "gcc", "perl",
        autoconf = autoconf_source
    },
    configure = [[
        $SOURCES_DIR/autoconf/configure --prefix=$PREFIX
    ]],
    build = [[
        make -j$PARALLELISM
    ]],
    install = [[
        DESTDIR=$INSTALL_DIR make install
    ]]
}

local autoconf_2_69_source = Source {
    Archive("https://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz", "954bd69b391edc12d6a4a51a2dd1476543da5c6bbf05a95b59dc0dd6fd4c2969"),
}

-- binutils is a picky little bitch and wants EXACTLY 2.69
local autoconf_2_69 = Tool {
    name = "autoconf_2_69",
    version = "2.69",
    revision = 1,
    dependencies = {
        "m4", "make", "gcc", "perl",
        autoconf = autoconf_2_69_source
    },
    configure = [[
        $SOURCES_DIR/autoconf/configure --prefix=$PREFIX
    ]],
    build = [[
        make -j$PARALLELISM
    ]],
    install = [[
        DESTDIR=$INSTALL_DIR make install
    ]]
}


local automake_source = Source {
    Archive("https://ftp.gnu.org/gnu/automake/automake-" .. AUTOMAKE_VERSION .. ".tar.gz", "07bd24ad08a64bc17250ce09ec56e921d6343903943e99ccf63bbf0705e34605"),
    dependencies = { autoconf = autoconf_source },
    prepare = [[
        cp $SOURCES_DIR/autoconf/build-aux/config.guess ./lib
        cp $SOURCES_DIR/autoconf/build-aux/config.sub ./lib
    ]]
}

local automake = Tool {
    name = "automake",
    version = AUTOMAKE_VERSION,
    revision = 1,
    dependencies = {
        "perl", "m4", "make", "gcc",
        autoconf,

        automake = automake_source
    },
    configure = [[
        $SOURCES_DIR/automake/configure --prefix=$PREFIX
    ]],
    build = [[
        make -j$PARALLELISM
    ]],
    install = [[
        DESTDIR=$INSTALL_DIR make install-strip
    ]]
}

local libtool_source = Source {
    Archive("https://ftp.gnu.org/gnu/libtool/libtool-" .. LIBTOOL_VERSION .. ".tar.xz", "f81f5860666b0bc7d84baddefa60d1cb9fa6fceb2398cc3baca6afaa60266675"),
    dependencies = { reconfigure, autoconf, automake, "perl", "m4" },
    prepare = [[
        LIBTOOLIZE=true reconfigure.sh
    ]]
}

local libtool = Tool {
    name = "libtool",
    version = LIBTOOL_VERSION,
    revision = 1,
    dependencies = {
        "help2man", "m4", "perl", "gcc", "make", "libc6-dev",
        autoconf, automake,

        libtool = libtool_source
    },
    configure = [[
        cp -a "$SOURCES_DIR/libtool" "$BUILD_DIR/libtool-src"
        $BUILD_DIR/libtool-src/configure --prefix=$PREFIX
    ]],
    build = [[
        make -j$PARALLELISM
    ]],
    install = [[
        DESTDIR=$INSTALL_DIR make install-strip
    ]]
}

local autoconf_archive = Tool {
    name = "autoconf_archive",
    version = AUTOCONF_ARCHIVE_VERSION,
    revision = 1,
    dependencies = {
        autoconf_archive = Source {
            Archive("https://ftp.gnu.org/gnu/autoconf-archive/autoconf-archive-" .. AUTOCONF_ARCHIVE_VERSION .. ".tar.xz", "7bcd5d001916f3a50ed7436f4f700e3d2b1bade3ed803219c592d62502a57363")
        }
    },
    install = [[
        mkdir -p $INSTALL_DIR$PREFIX/share/aclocal
        cp -r $SOURCES_DIR/autoconf_archive/m4/. $INSTALL_DIR$PREFIX/share/aclocal/
    ]]
}

return {
    autoconf = autoconf,
    autoconf_2_69 = autoconf_2_69,
    automake = automake,
    libtool_source = libtool_source,
    libtool = libtool,
    autoconf_archive = autoconf_archive
}

-- @collection autotools_2.69 = [tool/autoconf_2.69 tool/automake tool/libtool]

-- // Autoconf



-- // Autoconf 2.69

-- source/autoconf_2.69 {
--     url: "https://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz"
--     b2sum: "7e8a513bbfcabadad1577919c048cc05ca0a084788850b42570f88afc2fa9c25fb32277412f135b81ba1c0d8079465a6b581d2d78662c991d2183b739fac407c"
--     type: "tar.gz"
-- }

-- tool/autoconf_2.69 {
--     dependencies: [ source/autoconf_2.69 ]
--     configure: <sh>
--         $SOURCES_DIR/autoconf_2.69/configure --prefix=$PREFIX
--     </sh>
--     build: <sh>
--         make -j$PARALLELISM
--     </sh>}
--     install: <sh>
--         DESTDIR=$INSTALL_DIR make install
--     </sh>
-- }
