local freestanding_c_headers_source = Source {
    name = "freestanding_c_headers",
    Git("https://github.com/osdev0/freestnd-c-hdrs.git", "d33711241b46ecb8f2ad33927fcefdcb3ac0162e")
}

local freestanding_cxx_headers_source = Source {
    name = "freestanding_cxx_headers",
    Git("https://github.com/osdev0/freestnd-cxx-hdrs.git", "a6b351e0ab3e74e5789b01fa1447e4cd62373da7")
}

local freestanding_c_headers = Package {
    name = "freestanding_c_headers",
    version = "1.0",
    revision = 1,
    source = freestanding_c_headers_source,
    dependencies = { "make" },
    build = [[ cp -rpf $SOURCE_DIR/* . ]],
    install = [[ DESTDIR=$INSTALL_DIR make install PREFIX=$PREFIX ]]
}

local freestanding_cxx_headers = Package {
    name = "freestanding_cxx_headers",
    version = "1.0",
    revision = 1,
    source = freestanding_cxx_headers_source,
    dependencies = { "make" },
    build = [[ cp -rpf $SOURCE_DIR/* . ]],
    install = [[ DESTDIR=$INSTALL_DIR make install PREFIX=$PREFIX ]]
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
