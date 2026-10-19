local LLVM_VERSION = "23.1.2"

local llvm_source = Source {
    name = "llvm",
    Archive(
        "https://github.com/llvm/llvm-project/releases/download/llvmorg-" .. LLVM_VERSION .. "/llvm-project-" .. LLVM_VERSION .. ".src.tar.xz",
        "c98bbef08a2b4c2613cd50e9aa9ae7b69b1fe6c16b2c40373bc0ab6116fdf78a"
    ),
    patches = {
        "patches/llvm.patch",
    }
}

local llvm_tool = Tool {
    name = "llvm",
    version = LLVM_VERSION,
    revision = 1,
    source = llvm_source,
    dependencies = {
        "build-essential", "clang", "llvm", "lld", "cmake", "ninja-build", "zlib1g-dev", "libzstd-dev",
    },
    configure = [[
        cmake -S "${SOURCE_DIR}"/llvm -B ${BUILD_DIR} -G Ninja \
        -DCMAKE_BUILD_TYPE=MinSizeRel \
        -DLLVM_ENABLE_LTO=Thin \
        -DLLVM_BUILD_STATIC=ON \
        -DCMAKE_C_COMPILER=clang \
        -DCMAKE_CXX_COMPILER=clang++ \
        -DLLVM_USE_LINKER=lld \
        -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
        -DCLANGD_TIDY_CHECKS=OFF \
        -DCLANGD_DECISION_FOREST=OFF \
        -DCLANG_TIDY_ENABLE_STATIC_ANALYZER=OFF \
        -DCLANG_ENABLE_STATIC_ANALYZER=OFF \
        -DLLVM_ENABLE_PIC=OFF \
        -DLLVM_ENABLE_LIBEDIT=OFF \
        -DLLVM_ENABLE_LIBPFM=OFF \
        -DLLVM_ENABLE_LIBXML2=OFF \
        -DLLVM_ENABLE_BACKTRACES=OFF \
        -DLLVM_ENABLE_CRASH_OVERRIDES=OFF \
        -DLLVM_ENABLE_UNWIND_TABLES=OFF \
        -DLLVM_ENABLE_WARNINGS=OFF \
        -DLLVM_INCLUDE_TESTS=OFF \
        -DLLVM_INCLUDE_BENCHMARKS=OFF \
        -DLLVM_INCLUDE_EXAMPLES=OFF \
        -DLLVM_INCLUDE_DOCS=OFF \
        -DLLVM_INCLUDE_UTILS=OFF \
        -DLLVM_INCLUDE_RUNTIMES=OFF \
        -DLLVM_TARGETS_TO_BUILD='X86;RISCV' \
        -DLLVM_ENABLE_PROJECTS='clang;lld;clang-tools-extra' \
        -DLLVM_DISTRIBUTION_COMPONENTS='clang;clang-resource-headers;clangd;lld;llvm-strip;llvm-objcopy;llvm-objdump;llvm-ranlib;llvm-ar;llvm-nm'
    ]],
    build = [[
        cmake --build ${BUILD_DIR} --parallel "$(nproc)" --target distribution
    ]],
    install = [[
        DESTDIR="${INSTALL_DIR}" cmake --build ${BUILD_DIR} --target install-distribution-stripped
    ]],
}

return {
    source = llvm_source,
    tool = llvm_tool
}
