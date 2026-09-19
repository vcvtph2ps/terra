local fabricate = require("recipes.system_tools.fabricate")

local tartarus_source = Source { Git("https://github.com/elysium-os/tartarus-bootloader.git", "e95c3651f16d2560424c2d0d514aa8467d440053") }
local pico_efi_source = Source { Git("https://codeberg.org/PicoEFI/PicoEFI.git", "4bd08c13f103de9efd7b215a3e337447f1e2ce37") }
local cc_runtime_source = Source { Git("https://github.com/osdev0/cc-runtime.git", "dae79833b57a01b9fd3e359ee31def69f5ae899b") }
local freestanding_c_headers_source = Source { Git("https://github.com/osdev0/freestnd-c-hdrs.git", "4039f438fb1dc1064d8e98f70e1cf122f91b763b") }

local function tartarus_build(name, platform)
    return Package {
        name = name,
        version = "1.0",
        revision = 1,
        dependencies = {
            "nasm", "clang", "lld", "llvm", "ninja-build",
            fabricate,

            tartarus = tartarus_source,
            pico_efi = pico_efi_source,
            cc_runtime = cc_runtime_source,
            freestanding_c_headers = freestanding_c_headers_source
        },
        configure = ([[
            fabricate --build-dir=$BUILD_DIR setup \
                --config=$SOURCES_DIR/tartarus/fab.lua \
                --prefix=$PREFIX \
                --dependency-override=freestanding-c-headers=$SOURCES_DIR/freestanding_c_headers \
                --dependency-override=cc-runtime=$SOURCES_DIR/cc_runtime \
                --dependency-override=pico-efi=$SOURCES_DIR/pico_efi \
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
    local tartarus_bios = tartarus_build("tartarus", chariot.target_arch .. "-bios")
    local tartarus_efi = tartarus_build("tartarus_efi", chariot.target_arch .. "-uefi")

    return {
        tartarus_bios = tartarus_bios, tartarus_efi = tartarus_efi,
    }
end

return {}
