local mlibc_source = Source {
    name = "mlibc",
    Git("https://github.com/vcvtph2ps/lunar-mlibc.git", "da2d424f05dba652fb23c8cb7f5173d31382a841"),
    patches = {
        "patches/mlibc/1.patch",
        "patches/mlibc/2.patch"
    },
    dependencies = {
        "meson", "git"
    },
    prepare = [[
        meson subprojects download
    ]]
}

return mlibc_source
