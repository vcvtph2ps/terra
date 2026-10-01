local build_meta = require("recipes.packages.build-meta")

local meow_source = Source {
    Local("meow")
}

local meow = Package {
    name = "meow",
    version = "1.0",
    revision = 1,
    dependencies = {
        build_meta.binutils,
        build_meta.gcc,
        build_meta.libc_headers,
        build_meta.libc,

        "build-essential",
        "make",
        meow = meow_source
    },
    build = [[
        x86_64-lunar-gcc $SOURCES_DIR/meow/meow.c -o $BUILD_DIR/meow
    ]],
    install = [[
    	mkdir -p "$INSTALL_DIR$PREFIX/bin"
        cp $BUILD_DIR/meow "$INSTALL_DIR$PREFIX/bin/meow"
    ]]
}

return meow
