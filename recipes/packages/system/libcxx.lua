local llvm = require("recipes.tools.llvm")
local basic_compiler_rt = require("recipes.packages.system.basic-compiler-rt")
local mlibc_headers = require("recipes.packages.system.mlibc_headers")
local mlibc = require("recipes.packages.system.mlibc")
local pkgconf = require("recipes.tools.pkgconf")
local target = require("recipes.helpers.target")

local package = Package {
    name = "libcxx",
    version = "1.0",
    revision = 1,
    source = llvm.source,
    dependencies = {
        "build-essential", "cmake", "ninja-build",
        llvm.tool,
        mlibc_headers,
        mlibc,
        pkgconf,
        basic_compiler_rt
    },
    runtime_dependencies = {
        mlibc
    },
    env = {
        TARGET_TRIPLE = target.targetTriple[chariot.target_arch]
    },
    configure = [[
        cmake -S "${SOURCE_DIR}/runtimes" -B "${BUILD_DIR}" -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
        -DCMAKE_SYSROOT="${SYSROOT_DIR}" \
        -DCMAKE_C_COMPILER_TARGET="${TARGET_TRIPLE}" \
        -DCMAKE_CXX_COMPILER_TARGET="${TARGET_TRIPLE}" \
        -DCMAKE_ASM_COMPILER_TARGET="${TARGET_TRIPLE}" \
        -DLLVM_DEFAULT_TARGET_TRIPLE="${TARGET_TRIPLE}" \
        -DCMAKE_C_COMPILER=clang \
        -DCMAKE_CXX_COMPILER=clang++ \
        -DCMAKE_ASM_COMPILER=clang \
        -DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY \
        -DLIBUNWIND_ENABLE_SHARED=ON \
        -DLIBCXX_ENABLE_SHARED=ON \
        -DLIBCXX_ENABLE_THREADS=OFF \
        -DLIBCXXABI_ENABLE_SHARED=ON \
        -DLIBCXXABI_ENABLE_THREADS=OFF \
        -DLIBCXX_USE_COMPILER_RT=ON \
        -DLIBCXXABI_USE_COMPILER_RT=ON \
        -DLIBUNWIND_USE_COMPILER_RT=ON \
        -DLIBCXX_HAS_ATOMIC_LIB=OFF \
        -DLIBCXX_HAS_RT_LIB=OFF \
        -DLLVM_ENABLE_RUNTIMES='libunwind;libcxxabi;libcxx' \
        -DLLVM_INCLUDE_TESTS=OFF
    ]],
    build = [[
	        cmake --build ${BUILD_DIR} --parallel "${PARALLELISM}"
	    ]],
    install = [[
	        DESTDIR="${INSTALL_DIR}" cmake --install ${BUILD_DIR}
	    ]],
}

return package
