import Foundation

// MARK: - Mechanical Switch Types

enum MechanicalSwitchType: String, CaseIterable, Identifiable, Codable {
    case none = "None"
    case blue = "Blue"
    case red = "Red"
    case brown = "Brown"
    case black = "Black"
    case clear = "Clear"
    case silver = "Silver"

    var id: Self { self }

    var name: String {
        switch self {
        case .none: return "None".i18n()
        case .blue: return "Blue Switch (Clicky)".i18n()
        case .red: return "Red Switch (Linear)".i18n()
        case .brown: return "Brown Switch (Tactile)".i18n()
        case .black: return "Black Switch (Heavy Linear)".i18n()
        case .clear: return "Clear Switch (Heavy Tactile)".i18n()
        case .silver: return "Silver Switch (Fast Linear)".i18n()
        }
    }

    var description: String {
        switch self {
        case .none: return "No sound".i18n()
        case .blue: return "Loud and clicky".i18n()
        case .red: return "Smooth and quiet".i18n()
        case .brown: return "Tactile feedback".i18n()
        case .black: return "Heavy and smooth".i18n()
        case .clear: return "Strong tactile bump".i18n()
        case .silver: return "Fast and light".i18n()
        }
    }
}

// MARK: - Keyboard Sound Trigger Modes

enum KeyboardSoundTriggerMode: String, CaseIterable, Identifiable, Codable {
    case allKeys = "AllKeys"
    case characterKeysOnly = "CharacterKeysOnly"
    case excludeModifiers = "ExcludeModifiers"
    case excludeSpace = "ExcludeSpace"

    var id: Self { self }

    var name: String {
        switch self {
        case .allKeys: return "All Keys".i18n()
        case .characterKeysOnly: return "Character Keys Only".i18n()
        case .excludeModifiers: return "Exclude Modifiers".i18n()
        case .excludeSpace: return "Exclude Space Bar".i18n()
        }
    }
}
