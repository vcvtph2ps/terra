local env = {
    TARGET_ARCH = chariot.target_arch,

    CC = "lunar-clang",
    CXX = "lunar-clang++",
    CPP = "lunar-clang -E",
    CXXCPP = "lunar-clang++ -E",

    AR = "llvm-ar",
    NM = "llvm-nm",
    RANLIB = "llvm-ranlib",
    STRIP = "llvm-strip",
    OBJCOPY = "llvm-objcopy",
    OBJDUMP = "llvm-objdump",
    LD = "ld.lld",
}

--- Define a target package with the shared lunar toolchain environment.
--- @param pkg table
--- @return PackageRef
function LunarPackage(pkg)
    pkg.env = table.merge(env, pkg.env or {})
    return Package(pkg)
end

return {
    env = env,
}
