local cmd = require("cmd")
local file = require("file")
local meltype = require("meltype")

function PLUGIN:PreUninstall(ctx)
    -- mise upgrade は新しいバージョンを入れてから古いバージョンを消すので、配置済みの Meltype.app が別のバージョンなら触らない
    if not meltype.installed_version_matches(ctx.main.path) then
        return
    end
    local installed = meltype.installed_app()
    local swift = file.join_path(RUNTIME.pluginDirPath, "lib", "disable-input-source.swift")
    cmd.exec("swift " .. meltype.quote(swift), { timeout = 120 })
    cmd.exec("launchctl remove " .. meltype.launchd_label .. " || true")
    cmd.exec("pkill -x Meltype || true")
    cmd.exec(meltype.quote(meltype.lsregister) .. " -u " .. meltype.quote(installed))
    cmd.exec("rm -rf " .. meltype.quote(installed))
    cmd.exec("killall TextInputMenuAgent || true")
end
