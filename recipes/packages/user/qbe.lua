local build_meta = require("recipes.packages.build-meta")

local qbe = LunarPackage {
    name = "qbe",
    version = "1.0",
    revision = 1,
    source = Source {
        name = "qbe",
        Archive("https://c9x.me/compile/release/qbe-1.3.tar.xz", "d587905d620dc5e1d2bfa7c2cc642b9b837aa89a3188c6e37b53d756cf66e320")
    },
    dependencies = {
        build_meta.cc,
        build_meta.libc_headers,
        build_meta.libc,

        "make",
    },
    configure = [[
        cp -r $SOURCE_DIR/* $BUILD_DIR
    ]],
    build = [[
        make CC=$CC PREFIX=$PREFIX
    ]],
    install = [[
        make install PREFIX=$PREFIX DESTDIR=$INSTALL_DIR
    ]]
}

return qbe
