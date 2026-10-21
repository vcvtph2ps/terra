local build_meta = require("recipes.packages.build-meta")

local hello = Package {
    name = "hello",
    version = "1.0",
    revision = 1,
    source = Source {
        name = "hello",
        Local("dist-src/packages/hello")
    },
    dependencies = {
        build_meta.cc,
        build_meta.libc_headers,
        build_meta.libc,

        "build-essential",
        "make",
    },
    build = [[
        lunar-clang $SOURCE_DIR/hello.c -o $BUILD_DIR/hello
    ]],
    install = [[
    	mkdir -p "$INSTALL_DIR$PREFIX/bin"
        cp $BUILD_DIR/hello "$INSTALL_DIR$PREFIX/bin/hello"
    ]]
}

return hello
