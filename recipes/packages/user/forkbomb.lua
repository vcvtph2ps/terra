local build_meta = require("recipes.packages.build-meta")

local forkbomb = Package {
    name = "forkbomb",
    version = "1.0",
    revision = 1,
    source = Source {
        name = "forkbomb",
        Local("dist-src/packages/forkbomb")
    },
    dependencies = {
        build_meta.cc,
        build_meta.libc_headers,
        build_meta.libc,

        "build-essential",
        "make",
    },
    build = [[
        lunar-clang $SOURCE_DIR/forkbomb.c -o $BUILD_DIR/forkbomb
    ]],
    install = [[
    	mkdir -p "$INSTALL_DIR$PREFIX/bin"
        cp $BUILD_DIR/forkbomb "$INSTALL_DIR$PREFIX/bin/forkbomb"
    ]]
}

return forkbomb
