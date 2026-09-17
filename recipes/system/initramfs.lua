local rdsk = require("recipes.system_tools.rdsk")

local initramfs = Package {
    name = "initramfs",
    version = "1.0",
    revision = 1,
    dependencies = {
        rdsk
    },
    build = [[
        mkdir ./root_directory
        rdsk -c ./root_directory -o initramfs.rdk
    ]],
    install = [[
        install initramfs.rdk $INSTALL_DIR
    ]]
}

return initramfs
