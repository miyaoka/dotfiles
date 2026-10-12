-- mise の zip 展開は framework 内のシンボリックリンクを通常ファイルとして書き出し、署名検証が通らなくなる。
-- url を返さず、PostInstall で取得して ditto で展開する
function PLUGIN:PreInstall(ctx)
    if RUNTIME.osType ~= "darwin" or RUNTIME.archType ~= "arm64" then
        error("Meltype の Mac 版は Apple シリコンの macOS 専用")
    end
    return { version = ctx.version }
end
