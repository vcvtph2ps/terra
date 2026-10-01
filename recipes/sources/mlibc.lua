local mlibc_source = Source {
    name = "mlibc",
    Git("https://github.com/vcvtph2ps/lunar-mlibc.git", "6ff48ab5319632eb7f9bc67279f114f9ea576cf2"),
    dependencies = {
        "meson", "git"
    },
    prepare = [[
        meson subprojects download
    ]]
}

return mlibc_source
