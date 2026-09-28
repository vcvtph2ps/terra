local mlibc_source = Source {
    Git("https://github.com/vcvtph2ps/lunar-mlibc.git", "06048722c5021426df74d7d702d0509a8b188633"),
    dependencies = {
        "meson", "git"
    },
    prepare = [[
        meson subprojects download
    ]]
}

return mlibc_source
