//
//  L10n.swift
//  TravelCompanion
//
//  Created by Codex on 6/4/26.
//

import SwiftUI
import Combine

final class AppLanguageCenter: ObservableObject {
    static let shared = AppLanguageCenter()

    @Published private(set) var rawValue: String

    var selectedLanguage: AppLanguage {
        AppLanguage(rawValue: rawValue) ?? .system
    }

    private init() {
        rawValue = UserDefaults.standard.string(forKey: "app_language") ?? AppLanguage.system.rawValue
    }

    func setLanguage(_ language: AppLanguage) {
        guard rawValue != language.rawValue else { return }
        rawValue = language.rawValue
        UserDefaults.standard.set(language.rawValue, forKey: "app_language")
        UserDefaults.standard.synchronize()
    }
}

enum L10n {
    static func string(_ key: String, languageRawValue: String) -> String {
        let language = AppLanguage(rawValue: languageRawValue) ?? .system
        guard language != .system,
              let path = Bundle.main.path(forResource: language.localeIdentifier, ofType: "lproj"),
              let bundle = Bundle(path: path)
        else {
            return NSLocalizedString(key, comment: "")
        }

        let localized = NSLocalizedString(key, bundle: bundle, comment: "")
        return localized == key ? NSLocalizedString(key, comment: "") : localized
    }
}

struct LText: View {
    @ObservedObject private var languageCenter = AppLanguageCenter.shared

    let key: String

    init(_ key: String) {
        self.key = key
    }

    var body: some View {
        Text(L10n.string(key, languageRawValue: languageCenter.rawValue))
    }
}

struct LTemplateText: View {
    @ObservedObject private var languageCenter = AppLanguageCenter.shared

    let key: String
    let replacements: [String: String]

    init(_ key: String, replacements: [String: String]) {
        self.key = key
        self.replacements = replacements
    }

    var body: some View {
        var value = L10n.string(key, languageRawValue: languageCenter.rawValue)
        for (placeholder, replacement) in replacements {
            value = value.replacingOccurrences(of: placeholder, with: replacement)
        }
        return Text(value)
    }
}
