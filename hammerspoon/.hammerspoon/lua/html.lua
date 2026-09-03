local M = {}

function M.render(template, vars)
    return (template:gsub("{{([%u_]+)}}", function(key)
        return vars[key] or ""
    end))
end

function M.escape(s)
    if not s then
        return ""
    end
    s = s:gsub("&", "&amp;")
    s = s:gsub("<", "&lt;")
    s = s:gsub(">", "&gt;")
    return s
end

return M
