local build_meta = require("recipes.packages.build-meta")
local mlibc_source = require("recipes.sources.mlibc")
local runsh = chariot.read_file("recipes/packages/user/mlibc-tests/run.sh")

local mlibc_tests = LunarPackage {
    name = "mlibc_tests",
    version = "1.0",
    revision = 1,
    source = mlibc_source,
    dependencies = {
        build_meta.cc,
        build_meta.libc_headers,
        build_meta.libc,

        "build-essential",
        "make",
    },
    env = {
        TARGET_ARCH = chariot.target_arch,
    },
    build = [[
        for suite in posix ansi; do
            mkdir -p "$BUILD_DIR/$suite"
              for src in $SOURCE_DIR/tests/$suite/*.c; do
                    name=$(basename "$src" .c)
                    lunar-clang -D_GNU_SOURCE=1 "$src" -o "$BUILD_DIR/$suite/$name"
              done
        done
    ]],
    install = [[
       	mkdir -p "${INSTALL_DIR}/opt/mlibc-tests"
        cp -r $BUILD_DIR/* "${INSTALL_DIR}/opt/mlibc-tests/"
        cat > ${INSTALL_DIR}/opt/mlibc-tests/run.sh <<'EOF'
]] .. runsh .. [[
EOF
    ]]
}

return mlibc_tests
