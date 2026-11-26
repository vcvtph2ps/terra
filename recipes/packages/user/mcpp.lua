local build_meta = require("recipes.packages.build-meta")

local mcpp = LunarPackage {
    name = "mcpp",
    version = "1.0",
    revision = 1,
    source = Source {
        name = "mcpp",
        Git("https://github.com/ned14/mcpp", "4787481564c5be03306be32483fab020ec93e409"),
        patches = { "patches/mcpp.patch" }
    },
    dependencies = {
        build_meta.cc,
        build_meta.libc_headers,
        build_meta.libc,

        "make",
    },
    configure = [[
         CFLAGS="-std=c99 -Wno-error=incompatible-pointer-types" $SOURCE_DIR/configure --host=$TARGET_ARCH-lunar --prefix=$PREFIX
    ]],
    build = [[
       make PREFIX=$PREFIX
    ]],
    install = [[
        make install PREFIX=$PREFIX DESTDIR=$INSTALL_DIR
        ln -s mcpp "$INSTALL_DIR$PREFIX/bin/cpp"
    ]]
}

return mcpp
