-- PreInstall が返した url の zip を mise が展開すると、framework 内のシンボリックリンクが通常ファイルになり署名検証が通らない。
-- url を返さず、PostInstall で取得して ditto で展開する
function PLUGIN:PreInstall(ctx)
    if RUNTIME.osType ~= "darwin" or RUNTIME.archType ~= "arm64" then
        error("Meltype の Mac 版は Apple シリコンの macOS 専用")
    end
    return { version = ctx.version }
end
