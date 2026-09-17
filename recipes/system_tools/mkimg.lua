local mkimg_source = Source {
    Git("https://github.com/elysium-os/mkimg.git", "ef9aace290a4c21bba10be324059031ff6136d70")
}

local mkimg = Tool {
    name = "mkimg",
    version = "1.0",
    revision = 1,
    dependencies = { "golang", mkimg = mkimg_source },
    configure = [[
        cp $SOURCES_DIR/mkimg/go.mod $SOURCES_DIR/mkimg/go.sum $SOURCES_DIR/mkimg/main.go .
    ]],
    build = [[
        go build
    ]],
    install = [[
        install -D mkimg $INSTALL_DIR$PREFIX/bin/mkimg
    ]]
}

return mkimg
