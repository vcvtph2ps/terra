local ksym = Tool {
    name = "ksym",
    version = "1.0",
    revision = 1,
    source = Source {
        name = "ksym",
        Local("dist-src/tools/ksym")
    },
    dependencies = { "clang", "lld", "make" },
    build = [[
        cc -g -O2 -pipe $SOURCE_DIR/ksym.c -o ksym
    ]],
    install = [[
        install -D ksym $INSTALL_DIR$PREFIX/bin/ksym
    ]]
}

return ksym
