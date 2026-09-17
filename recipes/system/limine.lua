local LIMINE_VERSION = "12.4.0"

local limine_source = Source {
    Archive("https://github.com/Limine-Bootloader/Limine/releases/download/v" .. LIMINE_VERSION .. "/limine-binary.tar.xz", "4e788c85c427c3e12c7592938e3b0f49853e7f150fa470b37ac931371e079e8e")
}


local limine = Tool {
    name = "limine",
    version = LIMINE_VERSION,
    revision = 1,
    dependencies = { "clang", "lld", "make", limine = limine_source },
    build = [[
        cc -g -O2 -pipe -std=c99 $SOURCES_DIR/limine/limine.c -o limine
    ]],
    install = [[
        install -D limine $INSTALL_DIR$PREFIX/bin/limine
    ]]
}

return {
    source = limine_source,
    tool = limine
}
