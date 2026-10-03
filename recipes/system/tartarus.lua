local fabricate = require("recipes.system_tools.fabricate")
local freestanding_c_headers_source = require("recipes.packages.freestanding_headers").freestanding_c_headers.source
local tartarus_source = Source { name = "tartarus", Git("https://github.com/elysium-os/tartarus-bootloader.git", "e95c3651f16d2560424c2d0d514aa8467d440053") }
local pico_efi_source = Source { name = "pico_efi", Git("https://codeberg.org/PicoEFI/PicoEFI.git", "4bd08c13f103de9efd7b215a3e337447f1e2ce37") }
local cc_runtime_source = Source { name = "cc_runtime", Git("https://github.com/osdev0/cc-runtime.git", "dae79833b57a01b9fd3e359ee31def69f5ae899b") }

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
            freestanding_c_headers_source
        },
        configure = ([[
            fabricate --build-dir=$BUILD_DIR setup \
                --config=$SOURCE_DIR/fab.lua \
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
