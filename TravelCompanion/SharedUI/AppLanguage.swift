//
//  AppLanguage.swift
//  TravelCompanion
//
//  Created by Codex on 6/4/26.
//

import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case system
    case english = "en"
    case german = "de"
    case french = "fr"
    case spanish = "es"
    case italian = "it"
    case portuguese = "pt"
    case dutch = "nl"
    case swedish = "sv"
    case danish = "da"
    case norwegian = "no"
    case finnish = "fi"
    case polish = "pl"
    case czech = "cs"
    case slovak = "sk"
    case hungarian = "hu"
    case romanian = "ro"
    case greek = "el"
    case turkish = "tr"
    case ukrainian = "uk"
    case bulgarian = "bg"
    case croatian = "hr"
    case slovenian = "sl"

    var id: String { rawValue }

    var localeIdentifier: String {
        switch self {
        case .system:
            return Locale.current.identifier
        case .english:
            return "en"
        case .german:
            return "de"
        case .french:
            return "fr"
        case .spanish:
            return "es"
        case .italian:
            return "it"
        case .portuguese:
            return "pt"
        case .dutch:
            return "nl"
        case .swedish:
            return "sv"
        case .danish:
            return "da"
        case .norwegian:
            return "no"
        case .finnish:
            return "fi"
        case .polish:
            return "pl"
        case .czech:
            return "cs"
        case .slovak:
            return "sk"
        case .hungarian:
            return "hu"
        case .romanian:
            return "ro"
        case .greek:
            return "el"
        case .turkish:
            return "tr"
        case .ukrainian:
            return "uk"
        case .bulgarian:
            return "bg"
        case .croatian:
            return "hr"
        case .slovenian:
            return "sl"
        }
    }

    var displayNameKey: String {
        switch self {
        case .system:
            return "System"
        case .english:
            return "English"
        case .german:
            return "German"
        case .french:
            return "French"
        case .spanish:
            return "Spanish"
        case .italian:
            return "Italian"
        case .portuguese:
            return "Portuguese"
        case .dutch:
            return "Dutch"
        case .swedish:
            return "Swedish"
        case .danish:
            return "Danish"
        case .norwegian:
            return "Norwegian"
        case .finnish:
            return "Finnish"
        case .polish:
            return "Polish"
        case .czech:
            return "Czech"
        case .slovak:
            return "Slovak"
        case .hungarian:
            return "Hungarian"
        case .romanian:
            return "Romanian"
        case .greek:
            return "Greek"
        case .turkish:
            return "Turkish"
        case .ukrainian:
            return "Ukrainian"
        case .bulgarian:
            return "Bulgarian"
        case .croatian:
            return "Croatian"
        case .slovenian:
            return "Slovenian"
        }
    }

    var nativeName: String {
        switch self {
        case .system:
            return Locale.current.localizedString(forIdentifier: Locale.current.identifier) ?? "System"
        case .english:
            return "English"
        case .german:
            return "Deutsch"
        case .french:
            return "Français"
        case .spanish:
            return "Español"
        case .italian:
            return "Italiano"
        case .portuguese:
            return "Português"
        case .dutch:
            return "Nederlands"
        case .swedish:
            return "Svenska"
        case .danish:
            return "Dansk"
        case .norwegian:
            return "Norsk"
        case .finnish:
            return "Suomi"
        case .polish:
            return "Polski"
        case .czech:
            return "Čeština"
        case .slovak:
            return "Slovenčina"
        case .hungarian:
            return "Magyar"
        case .romanian:
            return "Română"
        case .greek:
            return "Ελληνικά"
        case .turkish:
            return "Türkçe"
        case .ukrainian:
            return "Українська"
        case .bulgarian:
            return "Български"
        case .croatian:
            return "Hrvatski"
        case .slovenian:
            return "Slovenščina"
        }
    }
}
