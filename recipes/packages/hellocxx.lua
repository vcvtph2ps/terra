local build_meta = require("recipes.packages.build-meta")
local target = require("recipes.helpers.target")

local hellocxx = Package {
    name = "hellocxx",
    version = "1.0",
    revision = 1,
    source = Source {
        name = "hellocxx",
        Local("dist-src/packages/hellocxx")
    },
    dependencies = {
        build_meta.cc,
        build_meta.libc_headers,
        build_meta.libc,
        build_meta.libcxx,

        "build-essential",
        "make",
    },
    env = {
        TARGET_TRIPLE = target.targetTriple[chariot.target_arch]
    },
    build = [[
        clang++ --target=$TARGET_TRIPLE --sysroot="$SYSROOT_DIR" -std=c++23 $SOURCE_DIR/hellocxx.cpp -o $BUILD_DIR/hellocxx
    ]],
    install = [[
    	mkdir -p "$INSTALL_DIR$PREFIX/bin"
        cp $BUILD_DIR/hellocxx "$INSTALL_DIR$PREFIX/bin/hellocxx"
    ]]
}

return hellocxx
