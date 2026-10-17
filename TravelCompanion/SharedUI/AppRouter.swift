//
//  AppRouter.swift
//  TravelCompanion
//
//  Created by User on 4/2/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class AppRouter: ObservableObject {
    @Published var selectedTab: Int = 0

    @Published var pendingFlightCode: String?
    @Published var shouldAutoRunFlightSearch: Bool = false

    @Published var pendingRequirementCheck: RecentRequirementCheck?
    @Published var shouldAutoRunRequirementCheck: Bool = false

    @Published var globalBannerMessage: String?

    func openFlights(with code: String? = nil, autoRun: Bool = false) {
        pendingFlightCode = code
        shouldAutoRunFlightSearch = autoRun && code != nil
        selectedTab = 1
    }

    func openRequirements(with check: RecentRequirementCheck? = nil, autoRun: Bool = false) {
        pendingRequirementCheck = check
        shouldAutoRunRequirementCheck = autoRun && check != nil
        selectedTab = 2
    }

    func openPlan() {
        selectedTab = 3
    }

    func openTrips(showMessage message: String? = nil) {
        globalBannerMessage = message
        selectedTab = 4
    }

    func openProfile() {
        openPlan()
    }

    func showBanner(_ message: String) {
        globalBannerMessage = message
    }

    func clearBanner() {
        globalBannerMessage = nil
    }

    func consumePendingFlightCode() -> String? {
        defer { pendingFlightCode = nil }
        return pendingFlightCode
    }

    func consumeShouldAutoRunFlightSearch() -> Bool {
        defer { shouldAutoRunFlightSearch = false }
        return shouldAutoRunFlightSearch
    }

    func consumePendingRequirementCheck() -> RecentRequirementCheck? {
        defer { pendingRequirementCheck = nil }
        return pendingRequirementCheck
    }

    func consumeShouldAutoRunRequirementCheck() -> Bool {
        defer { shouldAutoRunRequirementCheck = false }
        return shouldAutoRunRequirementCheck
    }
}
