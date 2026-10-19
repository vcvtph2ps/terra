local llvm = require("recipes.tools.llvm")
local mlibc_headers = require("recipes.packages.mlibc_headers")
local mlibc = require("recipes.packages.mlibc")
local libcxx = require("recipes.packages.libcxx")

return {
    cc = llvm.tool,
    libc_headers = mlibc_headers,
    libc = mlibc,
    libcxx = libcxx,
}
