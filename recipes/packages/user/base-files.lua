local base_files = Package {
    name = "base-files",
    version = "1.0",
    revision = 1,
    install = [[
        ln -s $PREFIX/bin $INSTALL_DIR/bin
    ]]
}

return base_files
