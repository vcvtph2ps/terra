local pkgconf = require("recipes.tools.pkgconf")
local llvm = require("recipes.tools.llvm")
local support_source = require("recipes.sources.support")
local mlibc_source = require("recipes.sources.mlibc")
local mlibc_headers = require("recipes.packages.mlibc_headers")
local freestanding_headers = require("recipes.packages.freestanding_headers")
local target = require("recipes.helpers.target")
local compiler_rt = require("recipes.packages.compiler-rt")

local mlibc = Package {
    name = "mlibc",
    version = "1.0",
    revision = 1,
    source = mlibc_source,
    dependencies = {
        "meson", "git", "cmake",
        mlibc_headers,
        llvm.tool,
        compiler_rt,
        freestanding_headers.freestanding_cxx_headers.package,
        pkgconf,

        support_source,
    },
    runtime_dependencies = {
        compiler_rt,
    },
    env = {
        CROSS_FILE = target.crossFiles[chariot.target_arch],
        TARGET_TRIPLE = target.targetTriple[chariot.target_arch],
        TARGET_CFLAGS = target.cflags[chariot.target_arch],
        TARGET_ARCH = chariot.target_arch,
    },
    configure = [[
        CFLAGS="$TARGET_CFLAGS --target=$TARGET_TRIPLE --sysroot=$SYSROOT_DIR" \
        CXXFLAGS="$TARGET_CFLAGS --target=$TARGET_TRIPLE --sysroot=$SYSROOT_DIR -isystem $SYSROOT_DIR$PREFIX/share/freestnd-cxx-hdrs/$TARGET_ARCH/include -Werror=unknown-attributes" \
        meson setup \
            --cross-file "$SOURCES_DIR/support/${CROSS_FILE}" \
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
