local ksym_source = Source {
    Local("tools/ksym")
}

local ksym = Tool {
    name = "ksym",
    version = "1.0",
    revision = 1,
    dependencies = { "clang", "lld", "make", ksym = ksym_source },
    build = [[
        cc -g -O2 -pipe $SOURCES_DIR/ksym/ksym.c -o ksym
    ]],
    install = [[
        install -D ksym $INSTALL_DIR$PREFIX/bin/ksym
    ]]
}

return ksym
