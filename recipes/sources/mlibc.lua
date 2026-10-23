local mlibc_source = Source {
    name = "mlibc",
    Git("https://github.com/vcvtph2ps/lunar-mlibc.git", "8008bdd233e6859a5c4d133791b883dd1a4f0904"),
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
