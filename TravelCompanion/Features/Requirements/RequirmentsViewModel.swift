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
    @Published var origin: Country? {
        didSet { if origin?.code != oldValue?.code { clearResults() } }
    }
    @Published var destination: Country? {
        didSet { if destination?.code != oldValue?.code { clearResults() } }
    }
    @Published var nationality: Country? {
        didSet { if nationality?.code != oldValue?.code { clearResults() } }
    }

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var visaResponse: VisaCheckResponse?
    @Published var recentChecks: [RecentRequirementCheck] = []

    private let recentChecksKey = "recent_requirement_checks"
    private let maxRecentChecks = 8
    private let service: RequirementsChecking
    private let defaults: UserDefaults
    private var requestID = UUID()

    init(service: RequirementsChecking? = nil, defaults: UserDefaults = .standard) {
        self.service = service ?? RequirementsService.shared
        self.defaults = defaults
        loadRecentChecks()
    }

    func clearResults() {
        requestID = UUID()
        isLoading = false
        visaResponse = nil
        errorMessage = nil
    }

    func checkRequirements() async {
        clearResults()
        let id = requestID

        guard let destination, let nationality else {
            errorMessage = "Please select destination and nationality."
            return
        }

        let selectedOrigin = origin
        isLoading = true
        defer { if requestID == id { isLoading = false } }

        do {
            let response = try await service.checkVisaRequirements(
                passportCode: nationality.code,
                destinationCode: destination.code
            )
            guard requestID == id,
                  self.origin?.code == selectedOrigin?.code,
                  self.destination?.code == destination.code,
                  self.nationality?.code == nationality.code,
                  !Task.isCancelled else { return }
            guard response.data.passport.code.caseInsensitiveCompare(nationality.code) == .orderedSame,
                  response.data.destination.code.caseInsensitiveCompare(destination.code) == .orderedSame else {
                throw NetworkServiceError.invalidResponse
            }
            visaResponse = response
            addRecentCheck(
                origin: selectedOrigin,
                destination: destination,
                nationality: nationality
            )
        } catch {
            guard requestID == id,
                  self.origin?.code == selectedOrigin?.code,
                  self.destination?.code == destination.code,
                  self.nationality?.code == nationality.code,
                  !Task.isCancelled else { return }
            if error is CancellationError || (error as? URLError)?.code == .cancelled { return }
            errorMessage = error.localizedDescription
        }
    }

    func applyRecentCheck(_ item: RecentRequirementCheck) {
        clearResults()
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
        guard let data = defaults.data(forKey: recentChecksKey) else {
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
            defaults.set(data, forKey: recentChecksKey)
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
