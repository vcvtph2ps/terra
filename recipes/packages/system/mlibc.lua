local pkgconf = require("recipes.tools.pkgconf")
local support_source = require("recipes.sources.support")
local mlibc_source = require("recipes.sources.mlibc")
local mlibc_headers = require("recipes.packages.system.mlibc_headers")
local basic_compiler_rt = require("recipes.packages.system.basic-compiler-rt")
local lunar_clang = require("recipes.packages.system.lunar-clang")
local libcxx_headers = require("recipes.packages.system.libcxx_headers")

local mlibc = Package {
    name = "mlibc",
    version = "1.0",
    revision = 1,
    source = mlibc_source,
    dependencies = {
        "meson", "git", "cmake",
        mlibc_headers,
        lunar_clang,
        basic_compiler_rt,
        libcxx_headers,
        pkgconf,

        support_source,
    },
    runtime_dependencies = {
        basic_compiler_rt,
    },
    env = {
        TARGET_ARCH = chariot.target_arch,
    },
    configure = [[
        CXXFLAGS="-nostdinc++ -Werror=unknown-attributes" \
        meson setup \
            --cross-file "$SOURCES_DIR/support/$TARGET_ARCH/lunar.cross" \
            --prefix=$PREFIX \
            --libdir=lib \
            --buildtype=debug \
            -Dno_headers=true \
            -Ddefault_library=both \
            -Dbuild_tests=false \
            -Duse_freestnd_hdrs=disabled \
            $SOURCE_DIR
    ]],
    build = [[
        ninja -j$PARALLELISM
    ]],
    install = [[
        DESTDIR=$INSTALL_DIR ninja install
    ]],
}

return mlibc
