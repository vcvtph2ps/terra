local build_meta = require("recipes.packages.build-meta")
local config = chariot.read_file("recipes/packages/user/toybox/toybox_config")

local toybox_source = Source {
    name = "toybox",
    Git("https://codeberg.org/landley/toybox.git", "6a0c0ef5eeb2c43e4feef9781398c1718b8bddcb"),
    patches = { "patches/toybox.patch" }
}

local toybox = LunarPackage {
    name = "toybox",
    version = "1.0",
    revision = 1,
    source = toybox_source,

    dependencies = {
        build_meta.cc,

        build_meta.libc_headers,
        build_meta.libc,

        "build-essential",
        "make",
    },
    configure = [[
        cp -a "$SOURCE_DIR/." "$BUILD_DIR/"
    ]],
    build = [[
        cd "$BUILD_DIR"

        cat > .config <<'EOF'
]] .. config .. [[
EOF

        HOSTCC="gcc" CC="lunar-clang" CFLAGS="-D_GNU_SOURCE" make V=1
    ]],
    install = [[
        cd "$BUILD_DIR"
        make install_flat PREFIX="$INSTALL_DIR$PREFIX/bin"
    ]],
}

return toybox
