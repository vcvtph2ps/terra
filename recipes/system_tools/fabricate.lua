local fabricate = Tool {
    name = "fabricate",
    version = "1.0",
    revision = 1,
    dependencies = {
        "rustc", "cargo", "clang", "libssl-dev", "pkgconf",

        Source { name = "fabricate", Git("https://github.com/elysium-os/fabricate.git", "8c0c4686afb4c6d3a2c97b423ff7303c4cb2d9ce") }
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
