local mlibc_source = Source {
    name = "mlibc",
    Git("https://github.com/vcvtph2ps/lunar-mlibc.git", "0251c679c78cdaa2a6c447f68507e0bc8baaedc1"),
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
