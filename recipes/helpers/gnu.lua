-- local DEFAULT_MIRROR = "https://ftp.gnu.org/gnu"
local DEFAULT_MIRROR = "https://repo.averymt.zip/gnu"
local DEFAULT_FORMAT_STRING = "{host}/{project}/{project}-{version}.{extension}"


local PROJECT_MIRROR_OVERRIDE = {
    ["gmp"] = "https://mirrors.evalyngoemer.com/gnu",
    ["mpfr"] = "https://mirrors.evalyngoemer.com/gnu",
    ["mpc"] = "https://mirrors.evalyngoemer.com/gnu",
    ["gcc"] = "https://mirrors.evalyngoemer.com/gnu",
}

-- gnu :P
local PROJECT_FORMAT_STRING_OVERRIDE = {
    ["gcc"] = "{host}/{project}/{project}-{version}/{project}-{version}.{extension}",
}

--- Create an gnu archive source table.
--- @param project_name string
--- @param version string
--- @param extention string
--- @param checksum string
--- @return ArchiveSource
function GnuArchive(project_name, version, extention, checksum)
    local host = DEFAULT_MIRROR
    if PROJECT_MIRROR_OVERRIDE[project_name] ~= nil then
        host = PROJECT_MIRROR_OVERRIDE[project_name]
    end

    local format_string = DEFAULT_FORMAT_STRING
    if PROJECT_FORMAT_STRING_OVERRIDE[project_name] ~= nil then
        format_string = PROJECT_FORMAT_STRING_OVERRIDE[project_name]
    end

    local values = {
        host = host,
        project = project_name,
        version = version,
        extension = extention,
    }

    local result = format_string:gsub("{(%w+)}", values)
    return Archive(result, checksum)
end
