//
//  AppNavigationStyle.swift
//  TravelCompanion
//
//  Created by User on 4/3/26.
//

import SwiftUI

struct AppNavigationStyle: ViewModifier {
    let title: String
    var displayMode: NavigationBarItem.TitleDisplayMode = .large

    func body(content: Content) -> some View {
        content
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(displayMode)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(
                Color(uiColor: .systemBackground).opacity(0.92),
                for: .navigationBar
            )
    }
}

extension View {
    func appNavigationTitle(
        _ title: String,
        displayMode: NavigationBarItem.TitleDisplayMode = .large
    ) -> some View {
        modifier(AppNavigationStyle(title: title, displayMode: displayMode))
    }
}
