// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TravelCompanionCore",
    platforms: [.macOS(.v13)],
    targets: [
        .target(name: "TravelCore", path: "TravelCompanion", exclude: [
            "Assets.xcassets", "PrivacyInfo.xcprivacy", "MainTableView.swift", "RootView.swift", "SavedTrip.swift", "SharedUI", "TravelCompanionApp.swift",
            "bg.lproj", "cs.lproj", "da.lproj", "de.lproj", "el.lproj", "en.lproj", "es.lproj", "fi.lproj", "fr.lproj", "hr.lproj", "hu.lproj",
            "it.lproj", "nl.lproj", "no.lproj", "pl.lproj", "pt.lproj", "ro.lproj", "sk.lproj", "sl.lproj", "sv.lproj", "tr.lproj", "uk.lproj",
            "Features/HomeView.swift", "Features/PreparationScreen.swift", "Features/Profile", "Features/TravelPlusScreen.swift", "Features/Trips",
            "Features/Flights/FlightDetailScreen.swift", "Features/Flights/FlightSearchScreen.swift", "Features/Requirements/RequirementsScreen.swift"
        ], sources: ["Networking", "Models", "Features/Flights/FlightViewModel.swift", "Features/Requirements/RequirmentsViewModel.swift"]),
        .testTarget(name: "TravelCoreTests", dependencies: ["TravelCore"], path: "Tests")
    ]
)
