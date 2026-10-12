local cmd = require("cmd")
local file = require("file")
local http = require("http")
local json = require("json")

local M = {}

M.releases_url = "https://api.github.com/repos/yksr-melt/Meltype/releases"
M.launchd_label = "io.github.yksr-melt.Meltype.manual"
M.lsregister = "/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"
-- mac.zip の最上位ディレクトリ
M.package_dir = "Meltype-mac"

function M.asset_name(version)
    return "Meltype-" .. version .. "-mac.zip"
end

function M.installed_app()
    return os.getenv("HOME") .. "/Library/Input Methods/Meltype.app"
end

function M.packaged_app(root)
    return root .. "/" .. M.package_dir .. "/Meltype.app"
end

local function bundle_version(app)
    local plist = M.quote(app .. "/Contents/Info.plist")
    return cmd.exec("/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' " .. plist)
end

function M.installed_version_matches(root)
    local installed = M.installed_app()
    if not file.exists(installed) then
        return false
    end
    return bundle_version(installed) == bundle_version(M.packaged_app(root))
end

function M.quote(s)
    return "'" .. s:gsub("'", "'\\''") .. "'"
end

function M.find_asset(release, name)
    for _, asset in ipairs(release.assets) do
        if asset.name == name then
            return asset
        end
    end
    return nil
end

function M.release_asset(version)
    local resp = http.get({ url = M.releases_url .. "/tags/v" .. version })
    if resp.status_code ~= 200 then
        error("GET release v" .. version .. " returned " .. resp.status_code)
    end
    local name = M.asset_name(version)
    local asset = M.find_asset(json.decode(resp.body), name)
    if asset == nil then
        error(name .. " is not in release v" .. version)
    end
    local sha256 = type(asset.digest) == "string" and asset.digest:match("^sha256:(%x+)$")
    if not sha256 then
        error("no sha256 digest for " .. name)
    end
    return { name = name, url = asset.browser_download_url, sha256 = sha256 }
end

function M.launchd_job_exists()
    local ok = pcall(cmd.exec, "launchctl list " .. M.launchd_label)
    return ok
end

return M
