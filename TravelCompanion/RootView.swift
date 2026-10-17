//
//  RootView.swift
//  TravelCompanion
//
//

import SwiftUI

struct RootView: View {
    @ObservedObject private var languageCenter = AppLanguageCenter.shared

    var body: some View {
        MainTabView()
            .id(languageCenter.selectedLanguage.localeIdentifier)
            .preferredColorScheme(nil)
            .environment(\.locale, Locale(identifier: languageCenter.selectedLanguage.localeIdentifier))
    }
}
