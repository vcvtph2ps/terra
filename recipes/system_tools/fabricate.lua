local fabricate = Tool {
    name = "fabricate",
    version = "1.0",
    revision = 1,
    source = Source { name = "fabricate", Git("https://github.com/elysium-os/fabricate.git", "115d564ca7964229b75ffc3662cccb3a41f6a028") },
    dependencies = {
        "rustc", "cargo", "clang", "libssl-dev", "pkgconf",
    },
    build = [[
        cd $SOURCE_DIR
        cargo build \
            --profile release \
            --target-dir $BUILD_DIR
    ]],
    install = [[
        install -D release/fabricate $INSTALL_DIR$PREFIX/bin/fabricate
    ]]
}

return fabricate
