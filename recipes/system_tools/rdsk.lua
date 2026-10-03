local rdsk_source = Source {
    name = "rdsk",
    Local("tools/rdsk")
}

local rdsk = Tool {
    name = "rdsk",
    version = "1.0",
    revision = 1,
    dependencies = { "clang", "lld", "make", rdsk_source },
    build = [[
        cc -g -O2 -pipe $SOURCES_DIR/rdsk/rdsk.c -o rdsk
    ]],
    install = [[
        install -D rdsk $INSTALL_DIR$PREFIX/bin/rdsk
    ]]
}

return rdsk
