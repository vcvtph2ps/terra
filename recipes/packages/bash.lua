local build_mlibc_toolchain_deps = require("recipes.packages.build-meta")
local build_meta = require("recipes.packages.build-meta")

local BASH_VERSION = "5.3"

local bash_source = Source {
    Archive("https://ftpmirror.gnu.org/gnu/bash/bash-" .. BASH_VERSION .. ".tar.gz", "0d5cd86965f869a26cf64f4b71be7b96f90a3ba8b3d74e27e8e9d9d5550f31ba"),
    patches = { "patches/bash.patch" }
}

local bash = Package {
    name = "bash",
    version = BASH_VERSION,
    revision = 1,

    dependencies = {
        build_meta.binutils,
        build_meta.gcc,
        build_meta.libc_headers,
        build_meta.libc,

        "build-essential",
        "make",
        bash = bash_source
    },
    configure = [[
        bash_cv_void_sighandler=yes \
        bash_cv_getcwd_malloc=yes \
        bash_cv_job_control_missing=missing \
        CFLAGS="" $SOURCES_DIR/bash/configure \
            --host=x86_64-lunar \
            --prefix=$PREFIX \
            --without-bash-malloc \
            --disable-readline \
            --without-curses \
            --disable-nls || cat config.log
    ]],
    build = [[ make ]],
    install = [[ make install DESTDIR=$INSTALL_DIR ]]
}

return bash
