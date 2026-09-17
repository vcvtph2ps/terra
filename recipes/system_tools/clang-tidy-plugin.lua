local clang_tidy_plugin_source = Source { Git("https://github.com/elysium-os/clang-tidy-plugin", "0f576eb4e333cf5937a02370e377d254163a2682") }

local clang_tidy_plugin = Package {
    name = "clang-tidy-plugin",
    version = "1.0",
    revision = 1,
    dependencies = { clang_tidy_plugin = clang_tidy_plugin_source, "libclang-dev", "llvm-dev", "clang", "lld", "cmake", "ninja-build" },
    configure = [[
        cmake -S $SOURCES_DIR/clang_tidy_plugin -G Ninja
    ]],
    build = [[
        ninja
    ]],
    install = [[
        DESTDIR=$INSTALL_DIR cmake --install . --prefix $PREFIX
    ]]
}

return clang_tidy_plugin
