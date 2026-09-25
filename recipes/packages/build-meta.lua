local binutils = require("recipes.tools.binutils")
local gcc = require("recipes.tools.gcc")
local mlibc_headers = require("recipes.packages.mlibc_headers")
local mlibc = require("recipes.packages.mlibc")

return {
    binutils = binutils,
    gcc = gcc,
    libc_headers = mlibc_headers,
    libc = mlibc
}
