local rdsk = Tool {
    name = "rdsk",
    version = "1.0",
    revision = 1,
    source = Source {
        name = "rdsk",
        Local("dist-src/tools/rdsk")
    },
    dependencies = { "clang", "lld", "make" },
    build = [[
        cc -g -O2 -pipe $SOURCE_DIR/rdsk.c -o rdsk
    ]],
    install = [[
        install -D rdsk $INSTALL_DIR$PREFIX/bin/rdsk
    ]]
}

return rdsk
