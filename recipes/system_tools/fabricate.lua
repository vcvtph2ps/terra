local fabricate = Tool {
    name = "fabricate",
    version = "1.0",
    revision = 1,
    dependencies = {
        "rustc", "cargo", "clang", "libssl-dev", "pkgconf",

        fabricate = Source { Git("https://github.com/elysium-os/fabricate.git", "fb7c59d1f638ea8647f5c2b0b2846739d9f3fe7d") }
    },
    build = [[
        cd $SOURCES_DIR/fabricate
        cargo build \
            --profile release \
            --target-dir $BUILD_DIR
    ]],
    install = [[
        install -D release/fabricate $INSTALL_DIR$PREFIX/bin/fabricate
    ]]
}

return fabricate
