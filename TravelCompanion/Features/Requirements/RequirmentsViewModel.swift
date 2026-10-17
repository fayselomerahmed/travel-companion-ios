//
//  RequirmentsViewModel.swift
//  TravelCompanion
//
//  Created by User on 3/9/26.
//
import Foundation
import Combine

@MainActor
final class RequirementsViewModel: ObservableObject {
    @Published var origin: Country?
    @Published var destination: Country?
    @Published var nationality: Country?

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var visaResponse: VisaCheckResponse?
    @Published var recentChecks: [RecentRequirementCheck] = []

    private let recentChecksKey = "recent_requirement_checks"
    private let maxRecentChecks = 8

    init() {
        loadRecentChecks()
    }

    func clearResults() {
        visaResponse = nil
        errorMessage = nil
    }

    func checkRequirements() async {
        clearResults()

        guard let destination, let nationality else {
            errorMessage = "Please select destination and nationality."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let response = try await RequirementsService.shared.checkVisaRequirements(
                passportCode: nationality.code,
                destinationCode: destination.code
            )
            visaResponse = response
            addRecentCheck(
                origin: origin,
                destination: destination,
                nationality: nationality
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func applyRecentCheck(_ item: RecentRequirementCheck) {
        origin = country(for: item.originCode)
        destination = country(for: item.destinationCode)
        nationality = country(for: item.nationalityCode)
    }

    func removeRecentCheck(_ item: RecentRequirementCheck) {
        recentChecks.removeAll { $0.id == item.id }
        saveRecentChecks()
    }

    func clearRecentChecks() {
        recentChecks = []
        saveRecentChecks()
    }

    private func addRecentCheck(origin: Country?, destination: Country, nationality: Country) {
        let item = RecentRequirementCheck(
            originCode: origin?.code,
            originName: origin?.name,
            destinationCode: destination.code,
            destinationName: destination.name,
            nationalityCode: nationality.code,
            nationalityName: nationality.name
        )

        recentChecks.removeAll {
            $0.destinationCode == item.destinationCode &&
            $0.nationalityCode == item.nationalityCode &&
            $0.originCode == item.originCode
        }

        recentChecks.insert(item, at: 0)

        if recentChecks.count > maxRecentChecks {
            recentChecks = Array(recentChecks.prefix(maxRecentChecks))
        }

        saveRecentChecks()
    }

    private func loadRecentChecks() {
        guard let data = UserDefaults.standard.data(forKey: recentChecksKey) else {
            recentChecks = []
            return
        }

        do {
            recentChecks = try JSONDecoder().decode([RecentRequirementCheck].self, from: data)
        } catch {
            recentChecks = []
        }
    }

    private func saveRecentChecks() {
        do {
            let data = try JSONEncoder().encode(recentChecks)
            UserDefaults.standard.set(data, forKey: recentChecksKey)
        } catch {
            #if DEBUG
            assertionFailure("Failed to save recent requirement checks: \(error)")
            #endif
        }
    }

    private func country(for code: String?) -> Country? {
        guard let code, !code.isEmpty else { return nil }
        return CountryData.countries.first { $0.code.caseInsensitiveCompare(code) == .orderedSame }
    }
}

struct RecentRequirementCheck: Codable, Identifiable, Equatable {
    let id: UUID
    let originCode: String?
    let originName: String?
    let destinationCode: String
    let destinationName: String
    let nationalityCode: String
    let nationalityName: String
    let createdAt: Date

    init(
        id: UUID = UUID(),
        originCode: String?,
        originName: String?,
        destinationCode: String,
        destinationName: String,
        nationalityCode: String,
        nationalityName: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.originCode = originCode
        self.originName = originName
        self.destinationCode = destinationCode
        self.destinationName = destinationName
        self.nationalityCode = nationalityCode
        self.nationalityName = nationalityName
        self.createdAt = createdAt
    }

    var routeText: String {
        if let originName, !originName.isEmpty {
            return "\(originName) → \(destinationName)"
        }
        return destinationName
    }

    var subtitleText: String {
        "\(nationalityName) passport"
    }
}
