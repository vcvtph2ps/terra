local kernel = require("recipes.system.kernel")
local prekernel = require("recipes.system.prekernel")
local limine = require("recipes.system.limine")
local tartarus = require("recipes.system.tartarus")
local ksym = require("recipes.system_tools.ksym")
local mkimg = require("recipes.system_tools.mkimg")
local initramfs = require("recipes.system.initramfs")

local support_source = Source {
    Local("support")
}

local root_files = {
    "${SYSROOT_DIR}/lunar.elf@/boot/kernel",
    "${SYSROOT_DIR}/initramfs.rdk@/boot/initramfs.rdk",
    "./kernel.ksym@/boot/kernel.ksym",
}

if chariot.options["bootloader"] == "tartarus" then
    table.insert(root_files, "${SOURCES_DIR}/prekernel/support/tartarus.cfg")
else
    table.insert(root_files, "${SOURCES_DIR}/prekernel/support/limine.conf")
end

local root_files_arg = table.concat(root_files, "#")
print(root_files_arg)

print(chariot.target_arch)
local bios_image
if chariot.target_arch == "x86_64" then
    if chariot.options["bootloader"] == "tartarus" then
        bios_image = [[
            mkimg \
                --protective-mbr \
                --dest kernel_tartarus_bios.img \
                --bootsector ${SYSROOT_DIR}${PREFIX}/share/tartarus/x86_64-bios.bin \
                --partition type=file:name=Tartarus:gpt-type=54524154-5241-5355-424F-4F5450415254:file=${SYSROOT_DIR}${PREFIX}/share/tartarus/tartarus.sys \
                --partition type=fs:gpt-type=454C5953-4955-4D52-4F4F-545041525458:fs-type=fat32:fs-size=64:fs-files=${ROOT_FILES}
        ]]
    else
        bios_image = [[
            mkimg \
                --protective-mbr \
                --dest kernel_limine_bios.img \
                --partition type=fs:gpt-type=21686148-6449-6e6f-744e-656564454649:fs-type=fat32:fs-size=1 \
                --partition type=fs:gpt-type=5af96cdc-fcb0-44f8-84ae-42ee9dc9b829:fs-type=fat32:fs-size=64:fs-files=${ROOT_FILES}#${SOURCES_DIR}/limine/limine-bios.sys

            limine bios-install kernel_limine_bios.img 1 --force
        ]]
    end
else
    bios_image = ""
end
print(bios_image)

local efi_files = root_files

if chariot.options["tartarus"] then
    table.insert(efi_files,
        "${SYSROOT_DIR}${PREFIX}/share/tartarus/tartarus.efi@/EFI/BOOT/BOOTX64.EFI"
    )
else
    table.insert(efi_files,
        "${SOURCES_DIR}/limine/BOOTX64.EFI@/EFI/BOOT/BOOTX64.EFI"
    )
    table.insert(efi_files,
        "${SOURCES_DIR}/limine/BOOTRISCV64.EFI@/EFI/BOOT/BOOTRISCV64.EFI"
    )
end

local efi_files_arg = table.concat(efi_files, "#")
print(efi_files_arg)

local image = Package {
    name = "image",
    version = "1.0",
    revision = 1,
    dependencies = {
        kernel,

        prekernel = prekernel.source,
        prekernel.package,

        initramfs,

        mkimg,
        ksym,

        limine = limine.source,
        limine.tool,

        support = support_source,

        "llvm",

        (chariot.target_arch == "x86_64" and tartarus.tartarus_bios) or nil,
        (chariot.target_arch == "x86_64" and tartarus.tartarus_efi) or nil
    },
    build = ([[
        llvm-nm -S $SYSROOT_DIR/kernel.elf -n > ./kernel_symbols.txt
        ksym ./kernel_symbols.txt ./kernel.ksym

        ROOT_FILES=%q
        EFI_ROOT_FILES=%q

        %s

        mkimg \
            --protective-mbr \
            --dest kernel_%s_efi.img \
            --partition type=fs:name=ESP:gpt-type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B:fs-type=fat32:fs-size=64:fs-files=${EFI_ROOT_FILES}
    ]]):format(root_files_arg, efi_files_arg, bios_image, chariot.options["bootloader"]),

    install = ([[
        %s
        install kernel_%s_efi.img $INSTALL_DIR
    ]]):format(chariot.target_arch == "x86_64" and ("install kernel_" .. chariot.options["bootloader"] .. "_bios.img $INSTALL_DIR") or "", chariot.options["bootloader"])
}

return image
