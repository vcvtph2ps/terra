local build_meta = require("recipes.packages.build-meta")
local target = require("recipes.helpers.target")

local meow = Package {
    name = "meow",
    version = "1.0",
    revision = 1,
    source = Source {
        name = "meow",
        Local("dist-src/packages/meow")
    },
    dependencies = {
        build_meta.cc,
        build_meta.libc_headers,
        build_meta.libc,

        "build-essential",
        "make",
    },
    env = {
        TARGET_TRIPLE = target.targetTriple[chariot.target_arch]
    },
    build = [[
        clang --target=$TARGET_TRIPLE --sysroot="$SYSROOT_DIR" $SOURCE_DIR/meow.c -o $BUILD_DIR/meow
    ]],
    install = [[
    	mkdir -p "$INSTALL_DIR$PREFIX/bin"
        cp $BUILD_DIR/meow "$INSTALL_DIR$PREFIX/bin/meow"
    ]]
}

return meow
