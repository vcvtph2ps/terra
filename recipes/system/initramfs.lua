local rdsk = require("recipes.system_tools.rdsk")
local mlibc = require("recipes.packages.mlibc")
local bash = require("recipes.packages.bash")

local initramfs = Package {
    name = "initramfs",
    version = "1.0",
    revision = 1,
    dependencies = {
        rdsk, mlibc, bash
    },
    build = [[
        mkdir ./root_directory

        mkdir -p ./root_directory/test/meow
        echo "Hello, World!" > ./root_directory/hello.txt
        echo "moewwwwww" > ./root_directory/test/mrrp.txt
        echo "nesting :3" > ./root_directory/test/meow/nesting.txt

        mkdir -p ./root_directory/usr
        mkdir -p ./root_directory/usr/{bin,lib}
        mkdir -p ./root_directory/dev

        cp -r $SYSROOT_DIR/usr/bin ./root_directory/usr
        cp -r $SYSROOT_DIR/usr/lib ./root_directory/usr
        cp -r $SYSROOT_DIR/usr/include ./root_directory/usr
        cp -r $SYSROOT_DIR/usr/share ./root_directory/usr

        rdsk -c ./root_directory -o initramfs.rdk
    ]],
    install = [[
        install initramfs.rdk $INSTALL_DIR
    ]]
}

return initramfs
