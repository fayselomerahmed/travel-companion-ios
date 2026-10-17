// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TravelCompanionCore",
    platforms: [.macOS(.v13)],
    targets: [
        .target(name: "TravelCore", path: "TravelCompanion/Networking", exclude: [
            "APIClient.swift", "Enviroment.swift", "FlightService.swift", "FrankfurtAirportService.swift", "RequirementsService.swift"
        ], sources: ["ConfigurationPolicy.swift"]),
        .testTarget(name: "TravelCoreTests", dependencies: ["TravelCore"], path: "Tests")
    ]
)
