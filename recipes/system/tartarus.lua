local fabricate = require("recipes.system_tools.fabricate")
local tartarus_source = Source { name = "tartarus", Git("https://github.com/elysium-os/tartarus-bootloader.git", "cfbc177535718161039f41e7e1e0b6ffbfd497ac") }
local pico_efi_source = Source { name = "pico_efi", Git("https://codeberg.org/PicoEFI/PicoEFI.git", "8b79fdaa72ee548a8ea24e3dc4d87bf281312865") }
local cc_runtime_source = Source { name = "cc_runtime", Git("https://github.com/osdev0/cc-runtime.git", "9891629daf3703d0ddecd295772df7da82ab25b9") }
local smoldtb_source = Source { name = "smoldtb", Git("https://github.com/DeanoBurrito/smoldtb.git", "72d3f8596fb91244e646944e09dcd93e1be03140") }
local freestanding_c_headers_source = Source { name = "tartarus_freestanding_c_headers", Git("https://github.com/osdev0/freestanding-c-hdrs.git", "38fed4e1e3365733ddbfa03b0a28936243ad31e9") }

local function tartarus_build(name, platform)
    return Package {
        name = name,
        version = "1.0",
        revision = 1,
        source = tartarus_source,
        dependencies = {
            "nasm", "clang", "lld", "llvm", "ninja-build",
            fabricate,

            pico_efi_source,
            cc_runtime_source,
            smoldtb_source,
            freestanding_c_headers_source
        },
        configure = ([[
            fabricate --build-dir=$BUILD_DIR setup \
                --config=$SOURCE_DIR/fab.lua \
                --prefix=$PREFIX \
                --dependency-override=freestanding-c-headers=$SOURCES_DIR/tartarus_freestanding_c_headers \
                --dependency-override=cc-runtime=$SOURCES_DIR/cc_runtime \
                --dependency-override=pico-efi=$SOURCES_DIR/pico_efi \
                --dependency-override=smoldtb=$SOURCES_DIR/smoldtb \
                --option=buildtype=debug \
                --option=platform={platform}
        ]]):gsub("{platform}", platform),
        build = [[
            ninja -j$PARALLELISM
        ]],
        install = [[
            fabricate --build-dir=$BUILD_DIR install --dest-dir=$INSTALL_DIR
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
