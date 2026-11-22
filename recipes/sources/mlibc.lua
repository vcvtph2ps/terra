local mlibc_source = Source {
    name = "mlibc",
    Git("https://github.com/vcvtph2ps/lunar-mlibc.git", "54ffddd423e5b038e9f43ab62c45ab1b907dec3c"),
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
