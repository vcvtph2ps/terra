local mlibc_source = Source {
    Git("https://github.com/vcvtph2ps/lunar-mlibc.git", "82b07358779ed92ecbbeb9894b2c5270a4dd5ed2"),
    dependencies = {
        "meson", "git"
    },
    prepare = [[
        meson subprojects download
    ]]
}

return mlibc_source
