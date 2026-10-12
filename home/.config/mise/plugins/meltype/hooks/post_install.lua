local cmd = require("cmd")
local http = require("http")
local log = require("log")
local meltype = require("meltype")

function PLUGIN:PostInstall(ctx)
    local asset = meltype.release_asset(ctx.runtimeVersion)
    local zip = ctx.rootPath .. "/" .. asset.name
    http.download_file({ url = asset.url }, zip)
    local sha256 = cmd.exec("shasum -a 256 " .. meltype.quote(zip)):match("^(%x+)")
    if sha256 ~= asset.sha256 then
        error(asset.name .. " sha256 mismatch: expected " .. asset.sha256 .. ", got " .. tostring(sha256))
    end
    cmd.exec("ditto -x -k " .. meltype.quote(zip) .. " " .. meltype.quote(ctx.rootPath))
    os.remove(zip)
    local script = ctx.rootPath .. "/" .. meltype.package_dir .. "/install.sh"
    local ok, err = pcall(cmd.exec, "bash " .. meltype.quote(script), { timeout = 120 })
    if ok then
        return
    end
    -- 初めて入れたときや更新直後は、macOS がログインし直すまで入力ソースを有効にせず、install.sh の最後の選択が失敗する。
    -- ここで失敗させると mise が展開先を消し、配置済みの Meltype.app を mise uninstall で消せなくなる
    if not (meltype.installed_version_matches(ctx.rootPath) and meltype.launchd_job_exists()) then
        error(err)
    end
    log.warn(err)
    log.warn("Meltype.app は配置済み。ログアウトしてログインし直し、入力メニューで Meltype を選ぶ")
end
