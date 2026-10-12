local http = require("http")
local json = require("json")
local meltype = require("meltype")

function PLUGIN:Available(ctx)
    local resp = http.get({ url = meltype.releases_url .. "?per_page=100" })
    if resp.status_code ~= 200 then
        error("GET releases returned " .. resp.status_code)
    end
    local result = {}
    for _, release in ipairs(json.decode(resp.body)) do
        local version = release.tag_name:gsub("^v", "")
        if not release.draft and not release.prerelease and meltype.find_asset(release, meltype.asset_name(version)) then
            table.insert(result, { version = version })
        end
    end
    return result
end
