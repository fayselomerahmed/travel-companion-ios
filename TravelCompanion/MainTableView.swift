//
//  MainTableView.swift
//  TravelCompanion
//
//  Created by User on 3/16/26.
//

import SwiftUI
import UIKit

struct MainTabView: View {
    @StateObject private var router = AppRouter()

    init() {
        configureTabBarAppearance()
    }

    var body: some View {
        TabView(selection: $router.selectedTab) {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label { LText("Home") } icon: { Image(systemName: router.selectedTab == 0 ? "house.fill" : "house") }
            }
            .tag(0)

            NavigationStack {
                FlightSearchScreen()
            }
            .tabItem {
                Label { LText("Flights") } icon: { Image(systemName: router.selectedTab == 1 ? "airplane.circle.fill" : "airplane.circle") }
            }
            .tag(1)

            NavigationStack {
                RequirementsScreen()
            }
            .tabItem {
                Label { LText("Requirements") } icon: { Image(systemName: router.selectedTab == 2 ? "doc.text.magnifyingglass" : "doc.text") }
            }
            .tag(2)

            NavigationStack {
                PreparationScreen()
            }
            .tabItem {
                Label { LText("Plan") } icon: { Image(systemName: router.selectedTab == 3 ? "checklist.checked" : "checklist") }
            }
            .tag(3)

            NavigationStack {
                TripsScreen()
            }
            .tabItem {
                Label { LText("Trips") } icon: { Image(systemName: router.selectedTab == 4 ? "bookmark.fill" : "bookmark") }
            }
            .tag(4)
        }
        .tint(Color.brandPrimary)
        .environmentObject(router)
    }

    private func configureTabBarAppearance() {
        let brandPrimary = UIColor(red: 0.08, green: 0.18, blue: 0.43, alpha: 1.0)
        let brandSecondary = UIColor(red: 0.42, green: 0.47, blue: 0.56, alpha: 1.0)
        let chromeBottom = UIColor(red: 0.94, green: 0.955, blue: 0.975, alpha: 0.96)
        let divider = UIColor.black.withAlphaComponent(0.08)

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()

        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialLight)
        appearance.backgroundColor = chromeBottom
        appearance.shadowColor = divider
        appearance.shadowImage = UIImage()

        let stacked = appearance.stackedLayoutAppearance
        let inline = appearance.inlineLayoutAppearance
        let compactInline = appearance.compactInlineLayoutAppearance

        [stacked, inline, compactInline].forEach { itemAppearance in
            itemAppearance.normal.iconColor = brandSecondary
            itemAppearance.normal.titleTextAttributes = [
                .foregroundColor: brandSecondary,
                .font: UIFont.systemFont(ofSize: 11, weight: .semibold)
            ]

            itemAppearance.selected.iconColor = brandPrimary
            itemAppearance.selected.titleTextAttributes = [
                .foregroundColor: brandPrimary,
                .font: UIFont.systemFont(ofSize: 11, weight: .bold)
            ]

            itemAppearance.normal.badgeBackgroundColor = brandPrimary
            itemAppearance.selected.badgeBackgroundColor = brandPrimary
        }

        appearance.stackedItemPositioning = .automatic

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().isTranslucent = true
    }
}

private extension Color {
    static let brandPrimary = Color(red: 0.08, green: 0.18, blue: 0.43)
}
