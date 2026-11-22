local function require_recursive(path)
    for _, entry in ipairs(chariot.list_dir(path)) do
        if entry.is_dir then
            require_recursive(path .. "/" .. entry.filename)
        else
            local ext = entry.filename:match("^.+%.(.+)$")
            if ext == "lua" then
                require(string.gsub(path, "%/", ".") .. "." .. entry.filename:gsub("%.[^%.]+$", ""))
            end
        end
    end
end

require_recursive("recipes/helpers")
require_recursive("recipes/sources")
require_recursive("recipes/system_tools")
require_recursive("recipes/system")
require_recursive("recipes/tools")
require_recursive("recipes/packages/system")
require_recursive("recipes/packages/user")
