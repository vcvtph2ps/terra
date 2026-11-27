local mlibc_source = Source {
    name = "mlibc",
    Git("https://github.com/vcvtph2ps/lunar-mlibc.git", "52b83d2b3d11c5f40eea4ac1bc2825b0c8329dbd"),
    patches = {
        "patches/mlibc/1.patch",
        "patches/mlibc/2.patch",
        "patches/mlibc/3.patch",
    },
    dependencies = {
        "meson", "git"
    },
    prepare = [[
        meson subprojects download
    ]]
}

return mlibc_source
