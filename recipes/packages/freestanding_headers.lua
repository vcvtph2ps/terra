local freestanding_c_headers_source = Source {
    Git("https://github.com/osdev0/freestnd-c-hdrs.git", "4039f438fb1dc1064d8e98f70e1cf122f91b763b")
}

local freestanding_cxx_headers_source = Source {
    Git("https://github.com/osdev0/freestnd-cxx-hdrs.git", "85096df5361a4d7ef2ce46947e555ec248c2858e")
}

local freestanding_c_headers = Package {
    name = "freestanding_c_headers",
    version = "1.0",
    revision = 1,
    dependencies = { freestanding_c_headers = freestanding_c_headers_source },
    build = [[ cp -rpf $SOURCES_DIR/freestanding_c_headers/* . ]],
    install = [[ DESTDIR=$INSTALL_DIR PREFIX=$PREFIX make install ]]
}

local freestanding_cxx_headers = Package {
    name = "freestanding_cxx_headers",
    version = "1.0",
    revision = 1,
    dependencies = { freestanding_cxx_headers = freestanding_cxx_headers_source },
    build = [[ cp -rpf $SOURCES_DIR/freestanding_cxx_headers/* . ]],
    install = [[ DESTDIR=$INSTALL_DIR PREFIX=$PREFIX make install ]]
}

return {
    freestanding_c_headers = {
        source = freestanding_c_headers_source,
        package = freestanding_c_headers
    },
    freestanding_cxx_headers = {
        source = freestanding_cxx_headers_source,
        package = freestanding_cxx_headers
    }
}
