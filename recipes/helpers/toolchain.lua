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
--- @param pkg { name: string, version: string, revision: number, source: SourceRef?, dependencies?: Dependency[], runtime_dependencies?: PackageRef[], env?: table<string, string | number>, configure?: string, build?: string, install: string }
--- @return PackageRef
function LunarPackage(pkg)
    pkg.env = table.merge(env, pkg.env or {})
    pkg.dependencies = pkg.dependencies or {}
    pkg.runtime_dependencies = pkg.runtime_dependencies or {}
    return Package(pkg)
end

return {
    env = env,
}
