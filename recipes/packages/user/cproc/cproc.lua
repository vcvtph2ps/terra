local build_meta = require("recipes.packages.build-meta")
local config_h = chariot.read_file("recipes/packages/user/cproc/config." .. chariot.target_arch .. ".h")
local config_mk = chariot.read_file("recipes/packages/user/cproc/config.mk")

local cproc = LunarPackage {
    name = "cproc",
    version = "1.0",
    revision = 1,
    source = Source {
        name = "cproc",
        Git("https://git.sr.ht/~mcf/cproc", "d1c53ddf56571573a7025324c8dd5c6d547a4d1f")
    },
    dependencies = {
        build_meta.cc,
        build_meta.libc_headers,
        build_meta.libc,

        "make",
        "qbe",
    },
    configure = [[
    cp -r $SOURCE_DIR/. $BUILD_DIR/

    cat > $BUILD_DIR/config.h <<'EOF'
]] .. config_h .. [[
EOF

    cat > $BUILD_DIR/config.mk <<'EOF'
]] .. config_mk .. [[
EOF
    ]],
    build = [[
        make PREFIX=$PREFIX
    ]],
    install = [[
        make install PREFIX=$PREFIX DESTDIR=$INSTALL_DIR
    ]]
}

return cproc
