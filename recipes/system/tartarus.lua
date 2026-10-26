local fabricate = require("recipes.system_tools.fabricate")

local tartarus_source = Source {
    name = "tartarus",
    base = Git("https://github.com/elysium-os/tartarus-bootloader.git", "e95caf03e726e9b01dc6aa9b2b52a91c0253e195"),
    dependencies = {
        fabricate
    },
    prepare = [[
        fabricate fetch
    ]],
}

local function tartarus_build(name, platform)
    return Package {
        name = name,
        version = "1.0",
        revision = 1,
        source = tartarus_source,
        dependencies = {
            "nasm", "clang", "lld", "llvm", "ninja-build",
            fabricate
        },
        env = {
            PLATFORM = platform
        },
        configure = [[
            fabricate setup \
                --build-dir=$BUILD_DIR \
                --project-dir=$SOURCE_DIR \
                --prefix=$PREFIX \
                --option=buildtype=debug \
                --option=platform="$PLATFORM"
        ]],
        build = [[
            ninja -j$PARALLELISM
        ]],
        install = [[
            fabricate install --build-dir=$BUILD_DIR --dest-dir=$INSTALL_DIR
        ]]
    }
end

if chariot.target_arch == "x86_64" then
    local tartarus_bios = tartarus_build("tartarus_bios", chariot.target_arch .. "-bios")
    local tartarus_efi = tartarus_build("tartarus_efi", chariot.target_arch .. "-uefi")

    return {
        tartarus_bios = tartarus_bios, tartarus_efi = tartarus_efi,
    }
end

if chariot.target_arch == "riscv64" then
    local tartarus_opensbi = tartarus_build("tartarus_opensbi", chariot.target_arch .. "-opensbi")
    local tartarus_efi = tartarus_build("tartarus_efi", chariot.target_arch .. "-uefi")

    return {
        tartarus_opensbi = tartarus_opensbi,
        tartarus_efi = tartarus_efi
    }
end

return {}
