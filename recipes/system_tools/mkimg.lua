local mkimg_source = Source {
    name = "mkimg",
    Git("https://github.com/elysium-os/mkimg.git", "ef9aace290a4c21bba10be324059031ff6136d70")
}

local mkimg = Tool {
    name = "mkimg",
    version = "1.0",
    revision = 1,
    source = mkimg_source,
    dependencies = { "golang" },
    configure = [[
        cp $SOURCE_DIR/go.mod $SOURCE_DIR/go.sum $SOURCE_DIR/main.go .
    ]],
    build = [[
        go build
    ]],
    install = [[
        install -D mkimg $INSTALL_DIR$PREFIX/bin/mkimg
    ]]
}

return mkimg
