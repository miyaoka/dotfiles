-- 空を返すと mise は展開先の bin を PATH に足すが、mac.zip に bin は無いので install.sh などは露出しない
function PLUGIN:EnvKeys(ctx)
    return {}
end
