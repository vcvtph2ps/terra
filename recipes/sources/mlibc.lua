local mlibc_source = Source {
    name = "mlibc",
    Git("https://github.com/vcvtph2ps/lunar-mlibc.git", "c320d00ca230e283c5f083167dba4c65611f7673"),
    patches = {
        "patches/mlibc.patch"
    },
    dependencies = {
        "meson", "git"
    },
    prepare = [[
        meson subprojects download
    ]]
}

return mlibc_source
