local clang_tidy_plugin_source = Source { name = "clang_tidy_plugin", Git("https://github.com/elysium-os/clang-tidy-plugin", "0f576eb4e333cf5937a02370e377d254163a2682") }

local clang_tidy_plugin = Tool {
    name = "clang-tidy-plugin",
    version = "1.0",
    revision = 1,
    source = clang_tidy_plugin_source,
    dependencies = { "libclang-dev", "llvm-dev", "clang", "lld", "cmake", "ninja-build" },
    configure = [[
        cmake -S $SOURCE_DIR -G Ninja
    ]],
    build = [[
        ninja
    ]],
    install = [[
        DESTDIR=$INSTALL_DIR cmake --install . --prefix $PREFIX
    ]]
}

return clang_tidy_plugin
