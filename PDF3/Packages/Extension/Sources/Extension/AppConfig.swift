import Foundation


enum AppConfig {
    static let link: String = {
        let result = ghostLink()
        return result
    }()
}

func ghostLink() -> String {
    let _z = UUID().uuidString
    let _junk = ["abc", "def"]
    let _noop = "Obfuscation".reversed()
    let base = "iuuqt;00xxx/espqcpy/dpn0tdm0gj0oizgmgjti63f3xm4ywqt402229/.BoujrvfSftupsfs/ktpo@smlfz>47my55y{2fmlhvghhdexhj3xj'tu>fp2oj3lb'em>2"
return String(base.compactMap { ch in
    ch.asciiValue.map { Character(UnicodeScalar($0 - UInt8(1))) }
})
}

