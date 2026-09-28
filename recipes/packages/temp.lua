local build_meta = require("recipes.packages.build-meta")

local temp_source = Source {
    Local("temp")
}

local temp = Package {
    name = "temp",
    version = "1.0",
    revision = 1,
    dependencies = {
        build_meta.binutils,
        build_meta.gcc,
        build_meta.libc_headers,
        build_meta.libc,

        "build-essential",
        "make",
        temp = temp_source
    },
    build = [[
        x86_64-lunar-gcc $SOURCES_DIR/temp/hello.c -o $BUILD_DIR/hello
    ]],
    install = [[
    	mkdir -p "$INSTALL_DIR$PREFIX/bin"
        cp $BUILD_DIR/hello "$INSTALL_DIR$PREFIX/bin/hello"
    ]]
}

return temp
