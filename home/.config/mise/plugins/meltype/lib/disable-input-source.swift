import Carbon
import Foundation

let prefix = "io.github.yksr-melt.inputmethod.Meltype"

func sourceID(_ source: TISInputSource) -> String {
    guard let value = TISGetInputSourceProperty(source, kTISPropertyInputSourceID) else {
        return ""
    }
    return unsafeBitCast(value, to: CFString.self) as String
}

func isMeltype(_ source: TISInputSource) -> Bool {
    sourceID(source).hasPrefix(prefix)
}

// Meltype を選択したまま無効にしないよう、先に別の入力ソースへ移す
let current = TISCopyCurrentKeyboardInputSource().takeRetainedValue()
if isMeltype(current) {
    let filter = [
        kTISPropertyInputSourceCategory: kTISCategoryKeyboardInputSource!,
        kTISPropertyInputSourceIsSelectCapable: true,
    ] as CFDictionary
    let candidates = TISCreateInputSourceList(filter, false).takeRetainedValue() as! [TISInputSource]
    guard let fallback = candidates.first(where: { !isMeltype($0) }) else {
        fputs("Meltype 以外に選べる入力ソースがありません\n", stderr)
        exit(1)
    }
    let status = TISSelectInputSource(fallback)
    guard status == noErr else {
        fputs("\(sourceID(fallback)) を選択できません: \(status)\n", stderr)
        exit(1)
    }
}

let sources = TISCreateInputSourceList(nil, false).takeRetainedValue() as! [TISInputSource]
for source in sources where isMeltype(source) {
    let status = TISDisableInputSource(source)
    guard status == noErr else {
        fputs("\(sourceID(source)) を無効にできません: \(status)\n", stderr)
        exit(1)
    }
}

// Meltype のインストーラーは有効な入力ソースの一覧に直接書き込む。
// ログインし直すまで macOS が Meltype を有効にしないため、TIS から無効にできない項目が残る。
// macOS はサードパーティの入力ソースを別の一覧にも持ち、Meltype は両方に入りうる
let enabledLists = [
    "com.apple.HIToolbox": "AppleEnabledInputSources",
    "com.apple.inputsources": "AppleEnabledThirdPartyInputSources",
]
for (suite, key) in enabledLists {
    guard let defaults = UserDefaults(suiteName: suite) else {
        fputs("\(suite) を開けません\n", stderr)
        exit(1)
    }
    let enabled = defaults.array(forKey: key) as? [[String: Any]] ?? []
    let remaining = enabled.filter {
        ($0["Bundle ID"] as? String) != prefix &&
        !($0["Input Mode"] as? String ?? "").hasPrefix(prefix)
    }
    if remaining.count != enabled.count {
        defaults.set(remaining, forKey: key)
        defaults.synchronize()
    }
}
