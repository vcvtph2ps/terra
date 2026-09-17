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
        tartarus.packages.tartarus,
        tartarus.packages.tartarus_efi,

        limine = limine.sources.limine,
        limine.tools.limine,

        support = support_source,

        "llvm"
    },
    build = [[
        llvm-nm -S $SYSROOT_DIR/kernel.elf -n > ./kernel_symbols.txt
        ksym ./kernel_symbols.txt ./kernel.ksym

        ROOT_FILES=${SYSROOT_DIR}/lunar.elf@/boot/kernel#${SYSROOT_DIR}/initramfs.rdk@/boot/initramfs.rdk#./kernel.ksym@/boot/kernel.ksym

        if [ "limine" == "tartarus" ]; then
            ROOT_FILES+=#${SOURCES_DIR}/prekernel/support/tartarus.cfg
        else
            ROOT_FILES+=#${SOURCES_DIR}/prekernel/support/limine.conf
        fi

        if [ "limine" == "tartarus" ]; then
            mkimg \
                --protective-mbr \
                --dest kernel_tartarus_bios.img \
                --bootsector ${SYSROOT_DIR}${PREFIX}/share/tartarus/x86_64-bios.bin \
                --partition type=file:name=Tartarus:gpt-type=54524154-5241-5355-424F-4F5450415254:file=${SYSROOT_DIR}${PREFIX}/share/tartarus/tartarus.sys \
                --partition type=fs:gpt-type=454C5953-4955-4D52-4F4F-545041525458:fs-type=fat32:fs-size=64:fs-files=${ROOT_FILES}
        else
            # @todo: wait for wux to allow mkimg to create empty partitions
            mkimg \
                --protective-mbr \
                --dest kernel_limine_bios.img \
                --partition type=fs:gpt-type=21686148-6449-6e6f-744e-656564454649:fs-type=fat32:fs-size=1 \
                --partition type=fs:gpt-type=5af96cdc-fcb0-44f8-84ae-42ee9dc9b829:fs-type=fat32:fs-size=64:fs-files=${ROOT_FILES}#${SOURCES_DIR}/limine/limine-bios.sys
        fi

        if [ "limine" == "tartarus" ]; then
            ROOT_FILES+=#${SYSROOT_DIR}${PREFIX}/share/tartarus/tartarus.efi@/EFI/BOOT/BOOTX64.EFI
        else
            ROOT_FILES+=#${SOURCES_DIR}/limine/BOOTX64.EFI@/EFI/BOOT/BOOTX64.EFI
            ROOT_FILES+=#${SOURCES_DIR}/limine/BOOTRISCV64.EFI@/EFI/BOOT/BOOTRISCV64.EFI
        fi

        mkimg \
            --protective-mbr \
            --dest kernel_limine_efi.img \
            --partition type=fs:name=ESP:gpt-type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B:fs-type=fat32:fs-size=64:fs-files=${ROOT_FILES}

        if [ "limine" == "limine" ]; then
            limine bios-install kernel_limine_bios.img 1 --force
        fi
    ]],
    install = [[
        install kernel_limine_bios.img $INSTALL_DIR
        install kernel_limine_efi.img $INSTALL_DIR
    ]]
}

return image
