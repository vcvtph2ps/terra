local mlibc_headers = require("recipes.packages.system.mlibc_headers")
local mlibc = require("recipes.packages.system.mlibc")
local libcxx = require("recipes.packages.system.libcxx")
local lunar_clang = require("recipes.packages.system.lunar-clang")

return {
    cc = lunar_clang,
    libc_headers = mlibc_headers,
    libc = mlibc,
    libcxx = libcxx,
}
