import SwiftUI
import SwiftData
import MapKit
import CoreLocation
import Combine

struct FlightDetailScreen: View {
    let flight: FlightItem

    @SwiftUI.Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var router: AppRouter
    @Query(sort: \SavedTrip.savedAt, order: .reverse) private var savedTrips: [SavedTrip]

    @State private var appeared = false
    @State private var embeddedAirportMapRegion: MKCoordinateRegion?
    @State private var isShowingFullScreenMap = false
    @StateObject private var passengerLocationManager = PassengerLocationManager()

    private let contentMaxWidth: CGFloat = 440

    private var departureCode: String { flight.departure?.iata ?? "-" }
    private var arrivalCode: String { flight.arrival?.iata ?? "-" }
    private var flightCode: String { flight.flight?.iata ?? flight.flight?.number ?? "Flight" }
    private var airlineName: String { flight.airline?.name ?? "Unknown Airline" }

    private var tripTitle: String { flightCode }
    private var tripSubtitle: String { airlineName }
    private var tripRoute: String { "\(departureCode) → \(arrivalCode)" }
    private var tripSummary: String {
        "Status: \(readableStatus), Gate: \(reportedGateText), Terminal: \(displayValue(flight.reportedDepartureTerminal, fallback: "Check screens"))"
    }

    private var isAlreadySaved: Bool {
        savedTrips.contains {
            $0.type == "flight" &&
            $0.title == tripTitle &&
            $0.route == tripRoute
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            backgroundView

            TopTravelHeader(title: "Flight Details", color: .white)
                .padding(.top, -8)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    heroSection
                        .frame(maxWidth: contentMaxWidth)
                        .frame(maxWidth: .infinity)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 16)
                        .animation(.spring(response: 0.60, dampingFraction: 0.82).delay(0.05), value: appeared)

                    primaryActionRow
                        .frame(maxWidth: contentMaxWidth)
                        .frame(maxWidth: .infinity)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 16)
                        .animation(.spring(response: 0.60, dampingFraction: 0.82).delay(0.12), value: appeared)

                    nextStepCard
                        .frame(maxWidth: contentMaxWidth)
                        .frame(maxWidth: .infinity)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 16)
                        .animation(.spring(response: 0.60, dampingFraction: 0.82).delay(0.18), value: appeared)

                    quickFactsSection
                        .frame(maxWidth: contentMaxWidth)
                        .frame(maxWidth: .infinity)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 16)
                        .animation(.spring(response: 0.60, dampingFraction: 0.82).delay(0.24), value: appeared)

                    officialGateSourceCard
                        .frame(maxWidth: contentMaxWidth)
                        .frame(maxWidth: .infinity)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 16)
                        .animation(.spring(response: 0.60, dampingFraction: 0.82).delay(0.27), value: appeared)

                    gateGuidanceCard
                        .frame(maxWidth: contentMaxWidth)
                        .frame(maxWidth: .infinity)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 16)
                        .animation(.spring(response: 0.60, dampingFraction: 0.82).delay(0.29), value: appeared)

                    passengerChecklistCard
                        .frame(maxWidth: contentMaxWidth)
                        .frame(maxWidth: .infinity)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 16)
                        .animation(.spring(response: 0.60, dampingFraction: 0.82).delay(0.30), value: appeared)

                    timelineCard
                        .frame(maxWidth: contentMaxWidth)
                        .frame(maxWidth: .infinity)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 16)
                        .animation(.spring(response: 0.60, dampingFraction: 0.82).delay(0.36), value: appeared)

                    airportInfoCard(
                        title: "Departure",
                        subtitle: "Key departure information",
                        symbol: "airplane.departure",
                        airport: flight.departure,
                        isDeparture: true
                    )
                    .frame(maxWidth: contentMaxWidth)
                    .frame(maxWidth: .infinity)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 16)
                    .animation(.spring(response: 0.60, dampingFraction: 0.82).delay(0.42), value: appeared)

                    airportInfoCard(
                        title: "Arrival",
                        subtitle: "Key arrival information",
                        symbol: "airplane.arrival",
                        airport: flight.arrival,
                        isDeparture: false
                    )
                    .frame(maxWidth: contentMaxWidth)
                    .frame(maxWidth: .infinity)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 16)
                    .animation(.spring(response: 0.60, dampingFraction: 0.82).delay(0.48), value: appeared)

                    routeSummaryCard
                        .frame(maxWidth: contentMaxWidth)
                        .frame(maxWidth: .infinity)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 16)
                        .animation(.spring(response: 0.60, dampingFraction: 0.82).delay(0.54), value: appeared)

                    passengerNoteCard
                        .frame(maxWidth: contentMaxWidth)
                        .frame(maxWidth: .infinity)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 16)
                        .animation(.spring(response: 0.60, dampingFraction: 0.82).delay(0.60), value: appeared)
                }
                .padding(.horizontal, 20)
                .padding(.top, 92)
                .padding(.bottom, 44)
            }
        }
        .fullScreenCover(isPresented: $isShowingFullScreenMap) {
            if let coordinate = departureAirportCoordinate {
                FullScreenPassengerAirportMap(
                    region: Binding(
                        get: {
                            embeddedAirportMapRegion ?? airportMapRegion(center: coordinate)
                        },
                        set: { newRegion in
                            embeddedAirportMapRegion = newRegion
                        }
                    ),
                    title: mapAirportLabel,
                    airportCode: departureCode,
                    instructionKey: mapGateInstructionKey,
                    targetCoordinate: coordinate,
                    userCoordinate: passengerLocationManager.coordinate,
                    onClose: {
                        isShowingFullScreenMap = false
                    }
                )
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .animation(.spring(response: 0.35, dampingFraction: 0.80), value: isAlreadySaved)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                appeared = true
            }
        }
    }

    // MARK: - Background

    private var backgroundView: some View {
        ZStack {
            Color(red: 0.03, green: 0.04, blue: 0.07)
                .ignoresSafeArea()

            RadialGradient(
                colors: [
                    Color(red: 0.16, green: 0.32, blue: 0.72).opacity(0.28),
                    .clear
                ],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 400
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [
                    Color(red: 0.52, green: 0.38, blue: 0.14).opacity(0.16),
                    .clear
                ],
                center: .bottomLeading,
                startRadius: 20,
                endRadius: 320
            )
            .ignoresSafeArea()
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: heroGradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: heroShadowColor, radius: 26, x: 0, y: 16)
                .shadow(color: Color.white.opacity(0.03), radius: 12, x: 0, y: 2)

            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.048), .clear],
                        startPoint: .topLeading,
                        endPoint: .center
                    )
                )

            RadialGradient(
                colors: [Color.white.opacity(0.12), .clear],
                center: UnitPoint(x: 0.92, y: 0.08),
                startRadius: 10,
                endRadius: 200
            )
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))

            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color.white.opacity(0.09), lineWidth: 1)

            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .center) {
                    statusCapsule
                    Spacer()
                    detailCapsule(title: "DELAY", value: compactDelayText)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Rectangle()
                        .fill(Color(red: 0.83, green: 0.72, blue: 0.49).opacity(0.65))
                        .frame(width: 24, height: 1.5)
                        .cornerRadius(1)

                    Text(airlineName)
                        .font(.system(size: 14, weight: .medium))
                        .tracking(0.2)
                        .foregroundStyle(.white.opacity(0.55))

                    Text(flightCode)
                        .font(.system(size: 38, weight: .bold, design: .serif))
                        .tracking(-1.0)
                        .foregroundStyle(.white)

                    HStack(spacing: 10) {
                        airportCodePill(departureCode)
                        Image(systemName: "arrow.right")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white.opacity(0.70))
                        airportCodePill(arrivalCode)
                    }
                }

                LText(statusHeadline)
                    .font(.system(size: 14, weight: .light))
                    .foregroundStyle(.white.opacity(0.84))
                    .lineSpacing(2)

                Rectangle()
                    .fill(Color.white.opacity(0.18))
                    .frame(height: 1)

                HStack(spacing: 16) {
                    heroMetric(title: "Departure", value: shortTime(flight.departure?.scheduled))
                    heroMetric(title: "Arrival", value: shortTime(flight.arrival?.scheduled))
                    heroMetric(title: "Terminal", value: displayValue(flight.departure?.terminal, fallback: "Check"))
                }
            }
            .padding(24)
        }
        .frame(minHeight: 300)
    }

    // MARK: - Primary Action

    private var primaryActionRow: some View {
        HStack(alignment: .top, spacing: 14) {
            saveActionCard
            elegantStatCard(title: "ROUTE", value: tripRoute, subtitle: "Current itinerary")
        }
    }

    private var saveActionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill((isAlreadySaved ? Color.green : Color(red: 0.35, green: 0.63, blue: 1.0)).opacity(0.14))
                        .frame(width: 34, height: 34)

                    Image(systemName: isAlreadySaved ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(isAlreadySaved ? .green : Color(red: 0.35, green: 0.63, blue: 1.0))
                }

                VStack(alignment: .leading, spacing: 2) {
                    LText("Save flight")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)

                    LText(isAlreadySaved ? "Already in Trips" : "Keep this flight for later")
                        .font(.system(size: 12, weight: .light))
                        .foregroundStyle(isAlreadySaved ? .green : .white.opacity(0.56))
                }

                Spacer(minLength: 0)
            }

            Button {
                saveFlight()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(
                            isAlreadySaved
                            ? LinearGradient(colors: [Color.green, Color.teal], startPoint: .leading, endPoint: .trailing)
                            : LinearGradient(
                                colors: [
                                    Color(red: 0.22, green: 0.46, blue: 0.90),
                                    Color(red: 0.40, green: 0.68, blue: 1.0)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    if !isAlreadySaved {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.10), .clear],
                                    startPoint: .top,
                                    endPoint: .center
                                )
                            )
                    }

                    LText(isAlreadySaved ? "Saved" : "Save to Trips")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.vertical, 16)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(ScaleButtonStyle())
            .disabled(isAlreadySaved)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(contentCardBackground)
    }

    private func elegantStatCard(title: String, value: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            LText(title)
                .font(.system(size: 9, weight: .semibold))
                .tracking(0.7)
                .foregroundStyle(.white.opacity(0.36))

            Text(value)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)

            Spacer(minLength: 0)

            LText(subtitle)
                .font(.system(size: 12, weight: .light))
                .foregroundStyle(.white.opacity(0.50))
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 126, alignment: .topLeading)
        .background(contentCardBackground)
    }

    // MARK: - Guidance

    private var nextStepCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(nextStepState.backgroundColor)
                        .frame(width: 34, height: 34)

                    Image(systemName: nextStepState.icon)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(nextStepState.foregroundColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    LText("Recommended next step")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)

                    Text(nextStepState.label.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .tracking(0.8)
                        .foregroundStyle(nextStepState.foregroundColor)
                }
            }

            LText(nextStepMessage)
                .font(.system(size: 13, weight: .light))
                .foregroundStyle(.white.opacity(0.60))
                .lineSpacing(1.5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .background(contentCardBackground)
    }

    // MARK: - Quick Facts

    private var quickFactsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(
                title: "Quick facts",
                subtitle: "The most important details at a glance"
            )

            HStack(spacing: 12) {
                quickFactCard(title: "Gate", value: passengerGateDisplayText)
                quickFactCard(title: "Terminal", value: displayValue(flight.reportedDepartureTerminal, fallback: "Check screens"))
                quickFactCard(title: "Status", value: shortStatus)
            }
        }
    }

    private var gateGuidanceCard: some View {
        infoCard(
            title: "Gate guidance",
            subtitle: "Navigate to the airport, then verify the exact gate inside",
            symbol: "location.fill"
        ) {
            VStack(alignment: .leading, spacing: 12) {
                if let coordinate = departureAirportCoordinate {
                    embeddedAirportMap(coordinate: coordinate)
                }

                gateGuidanceSummary

                VStack(spacing: 10) {
                    if let url = appleMapsAirportURL {
                        officialSourceLink(
                            title: "Start route in Maps",
                            subtitle: appleMapsSubtitle,
                            url: url,
                            icon: "map.fill"
                        )
                    }

                    if let url = airportIndoorMapURL {
                        officialSourceLink(
                            title: "Open airport map",
                            subtitle: airportMapSourceName,
                            url: url,
                            icon: "figure.walk"
                        )
                    }
                }
            }
        }
    }

    private func embeddedAirportMap(coordinate: CLLocationCoordinate2D) -> some View {
        let mapHeight = max(360, min(UIScreen.main.bounds.height * 0.48, 460))

        return ZStack {
            PassengerRouteMapView(
                region: Binding(
                    get: {
                        embeddedAirportMapRegion ?? airportMapRegion(center: coordinate)
                    },
                    set: { newRegion in
                        embeddedAirportMapRegion = newRegion
                    }
                ),
                targetCoordinate: coordinate,
                targetTitle: passengerGateMapTargetTitle,
                userCoordinate: passengerLocationManager.coordinate
            )
            .frame(height: mapHeight)
            .saturation(0.92)
            .contrast(1.04)

            LinearGradient(
                colors: [
                    Color.black.opacity(0.42),
                    Color.black.opacity(0.02),
                    Color.black.opacity(0.52)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .allowsHitTesting(false)

            VStack {
                HStack(alignment: .top, spacing: 10) {
                    mapIconBadge(symbol: "figure.walk.circle.fill", tint: PremiumPalette.gold)

                    VStack(alignment: .leading, spacing: 4) {
                        LText("Passenger map")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)

                        Text(mapAirportLabel)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.white.opacity(0.72))
                            .lineLimit(1)
                    }

                    Spacer(minLength: 0)

                    Button {
                        isShowingFullScreenMap = true
                    } label: {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 34, height: 34)
                            .background(.white.opacity(0.18), in: Circle())
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .accessibilityLabel(Text("Open full screen map"))

                    Text(departureCode)
                        .font(.system(size: 11, weight: .bold))
                        .tracking(0.8)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(.white.opacity(0.16), in: Capsule())
                }
                .padding(14)
                .background(
                    LinearGradient(
                        colors: [Color.black.opacity(0.70), Color.black.opacity(0.18)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

                Spacer()

                HStack(spacing: 10) {
                    mapIconBadge(symbol: "location.north.line.fill", tint: Color(red: 0.35, green: 0.63, blue: 1.0))

                    VStack(alignment: .leading, spacing: 3) {
                        LText(passengerLocationManager.coordinate == nil ? "Tap expand or allow location to draw your route" : "Route from your location to gate area")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white)

                        LText(mapGateInstructionKey)
                            .font(.system(size: 11, weight: .light))
                            .foregroundStyle(.white.opacity(0.66))
                            .lineLimit(2)
                    }

                    Spacer(minLength: 0)
                }
                .padding(12)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .padding(12)
            }

            passengerMapMarker
                .allowsHitTesting(false)
        }
        .frame(height: mapHeight)
        .onAppear {
            if embeddedAirportMapRegion == nil {
                embeddedAirportMapRegion = airportMapRegion(center: coordinate)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.22), Color.white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.28), radius: 18, x: 0, y: 12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("Passenger map"))
        .onAppear {
            passengerLocationManager.requestLocation()
        }
    }

    private var passengerMapMarker: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(Color.black.opacity(0.26))
                    .frame(width: 74, height: 74)
                    .blur(radius: 12)
                    .offset(y: 8)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [PremiumPalette.gold, Color(red: 0.98, green: 0.78, blue: 0.28)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 52, height: 52)
                    .overlay(Circle().stroke(Color.white.opacity(0.80), lineWidth: 2))
                    .shadow(color: PremiumPalette.gold.opacity(0.34), radius: 14, x: 0, y: 6)

                Image(systemName: "person.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color(red: 0.05, green: 0.06, blue: 0.08))
            }

            Triangle()
                .fill(PremiumPalette.gold)
                .frame(width: 16, height: 10)
                .rotationEffect(.degrees(180))
                .offset(y: -2)
        }
        .offset(y: -8)
    }

    private func mapIconBadge(symbol: String, tint: Color) -> some View {
        ZStack {
            Circle()
                .fill(tint.opacity(0.18))
                .frame(width: 34, height: 34)

            Image(systemName: symbol)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(tint)
        }
    }

    private func airportMapRegion(center: CLLocationCoordinate2D) -> MKCoordinateRegion {
        MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: 0.022, longitudeDelta: 0.022)
        )
    }

    private var gateGuidanceSummary: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: "signpost.right.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(PremiumPalette.gold)

                if let gate = flight.reportedDepartureGate {
                    LTemplateText("Head toward terminal {terminal}. Gate {gate} must still be verified on airport screens.", replacements: [
                        "{terminal}": displayValue(flight.reportedDepartureTerminal, fallback: "the departure terminal"),
                        "{gate}": gate
                    ])
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.88))
                } else if let area = flight.passengerGateAreaHint {
                    LTemplateText("Use {area} as the likely gate area, then confirm the exact gate on airport screens.", replacements: [
                        "{area}": area
                    ])
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.88))
                } else {
                    LTemplateText("Head toward terminal {terminal}. The gate is not confirmed yet.", replacements: [
                        "{terminal}": displayValue(flight.reportedDepartureTerminal, fallback: "the departure terminal")
                    ])
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.88))
                }
            }

            LText("Indoor gate walking directions depend on official airport maps and live airport screens.")
                .font(.system(size: 12, weight: .light))
                .foregroundStyle(.white.opacity(0.54))
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(1.5)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.045))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }

    private var departureAirportCoordinate: CLLocationCoordinate2D? {
        guard let code = flight.departure?.iata?.uppercased() else { return nil }
        return Self.airportCoordinates[code]
    }

    private var mapAirportLabel: String {
        if let airport = flight.departure?.airport, !airport.isEmpty {
            return "\(airport) · \(departureCode)"
        }
        return departureCode
    }

    private var mapGateInstructionKey: String {
        if flight.reportedDepartureGate != nil {
            return "Confirm gate on airport screens"
        }
        if flight.passengerGateAreaHint != nil {
            return "Gate area shown, exact gate pending"
        }
        if flight.hasRawDepartureGateRejectedForPassenger {
            return "Stand number hidden for passenger safety"
        }
        return "Gate appears here when confirmed"
    }

    private var passengerGateMapTargetTitle: String {
        if let gate = flight.reportedDepartureGate {
            return "Gate \(gate)"
        }
        if let area = flight.passengerGateAreaHint {
            return area
        }
        return "Gate area"
    }

    private static let airportCoordinates: [String: CLLocationCoordinate2D] = [
        "AMS": CLLocationCoordinate2D(latitude: 52.3105, longitude: 4.7683),
        "ARN": CLLocationCoordinate2D(latitude: 59.6519, longitude: 17.9186),
        "ATH": CLLocationCoordinate2D(latitude: 37.9364, longitude: 23.9445),
        "BCN": CLLocationCoordinate2D(latitude: 41.2974, longitude: 2.0833),
        "BER": CLLocationCoordinate2D(latitude: 52.3667, longitude: 13.5033),
        "BRU": CLLocationCoordinate2D(latitude: 50.9014, longitude: 4.4844),
        "CDG": CLLocationCoordinate2D(latitude: 49.0097, longitude: 2.5479),
        "CPH": CLLocationCoordinate2D(latitude: 55.6180, longitude: 12.6508),
        "DUB": CLLocationCoordinate2D(latitude: 53.4213, longitude: -6.2701),
        "DUS": CLLocationCoordinate2D(latitude: 51.2895, longitude: 6.7668),
        "FCO": CLLocationCoordinate2D(latitude: 41.8003, longitude: 12.2389),
        "FRA": CLLocationCoordinate2D(latitude: 50.0379, longitude: 8.5622),
        "HEL": CLLocationCoordinate2D(latitude: 60.3172, longitude: 24.9633),
        "IST": CLLocationCoordinate2D(latitude: 41.2753, longitude: 28.7519),
        "KWI": CLLocationCoordinate2D(latitude: 29.2266, longitude: 47.9689),
        "LHR": CLLocationCoordinate2D(latitude: 51.4700, longitude: -0.4543),
        "LGW": CLLocationCoordinate2D(latitude: 51.1537, longitude: -0.1821),
        "LIS": CLLocationCoordinate2D(latitude: 38.7742, longitude: -9.1342),
        "MAD": CLLocationCoordinate2D(latitude: 40.4983, longitude: -3.5676),
        "MAN": CLLocationCoordinate2D(latitude: 53.3650, longitude: -2.2722),
        "MUC": CLLocationCoordinate2D(latitude: 48.3538, longitude: 11.7861),
        "MXP": CLLocationCoordinate2D(latitude: 45.6306, longitude: 8.7281),
        "OSL": CLLocationCoordinate2D(latitude: 60.1939, longitude: 11.1004),
        "PRG": CLLocationCoordinate2D(latitude: 50.1008, longitude: 14.2632),
        "VIE": CLLocationCoordinate2D(latitude: 48.1103, longitude: 16.5697),
        "WAW": CLLocationCoordinate2D(latitude: 52.1657, longitude: 20.9671),
        "ZRH": CLLocationCoordinate2D(latitude: 47.4581, longitude: 8.5555)
    ]

    private var appleMapsAirportURL: URL? {
        let query: String
        switch departureCode.uppercased() {
        case "FRA":
            query = "Frankfurt Airport Terminal"
        default:
            guard let airport = flight.departure?.airport, !airport.isEmpty else { return nil }
            query = airport
        }

        return URL(string: "https://maps.apple.com/?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query)")
    }

    private var appleMapsSubtitle: String {
        switch departureCode.uppercased() {
        case "FRA":
            return "Apple Maps · Frankfurt Airport"
        default:
            return "Apple Maps · \(flight.departure?.airport ?? departureCode)"
        }
    }

    private var airportIndoorMapURL: URL? {
        switch departureCode.uppercased() {
        case "FRA":
            return URL(string: "https://map.frankfurt-airport.com")
        default:
            return officialAirportStatusURL
        }
    }

    private var airportMapSourceName: String {
        switch departureCode.uppercased() {
        case "FRA":
            return "Frankfurt Airport map"
        default:
            return officialAirportSourceName
        }
    }

    private var officialGateSourceCard: some View {
        infoCard(
            title: "Official gate source",
            subtitle: "Use airport or airline status for final gate information",
            symbol: "checkmark.seal.fill"
        ) {
            VStack(alignment: .leading, spacing: 12) {
                LText(flight.officialDataSourceName == nil ? "Gate assignments can change close to boarding. Airport screens and airline status are the final source." : "This flight includes Frankfurt airport status data when available. Always confirm on airport screens.")
                    .font(.system(size: 13, weight: .light))
                    .foregroundStyle(.white.opacity(0.62))
                    .lineSpacing(1.5)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(spacing: 10) {
                    if let sourceURL = flight.officialDataSourceURL, let url = URL(string: sourceURL) {
                        officialSourceLink(
                            title: "Open live Frankfurt source",
                            subtitle: flight.officialDataSourceName ?? "Frankfurt Airport",
                            url: url,
                            icon: "checkmark.seal.fill"
                        )
                    }

                    if let url = officialAirportStatusURL {
                        officialSourceLink(
                            title: "Open airport departures",
                            subtitle: officialAirportSourceName,
                            url: url,
                            icon: "building.2.fill"
                        )
                    }

                    if let url = officialAirlineStatusURL {
                        officialSourceLink(
                            title: "Open airline flight status",
                            subtitle: officialAirlineSourceName,
                            url: url,
                            icon: "airplane.circle.fill"
                        )
                    }
                }
            }
        }
    }

    private func officialSourceLink(title: String, subtitle: String, url: URL, icon: String) -> some View {
        Link(destination: url) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 34, height: 34)

                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.86))
                }

                VStack(alignment: .leading, spacing: 2) {
                    LText(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)

                    Text(subtitle)
                        .font(.system(size: 12, weight: .light))
                        .foregroundStyle(.white.opacity(0.52))
                }

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white.opacity(0.46))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.055))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
            )
        }
    }

    private var officialAirportStatusURL: URL? {
        switch departureCode.uppercased() {
        case "FRA":
            return URL(string: "https://www.fra-airport.com/en/departures")
        default:
            return nil
        }
    }

    private var officialAirportSourceName: String {
        switch departureCode.uppercased() {
        case "FRA":
            return "Frankfurt Airport"
        default:
            return "Airport departures"
        }
    }

    private var officialAirlineStatusURL: URL? {
        switch flight.flight?.iata?.prefix(2).uppercased() {
        case "KU":
            return URL(string: "https://www.kuwaitairways.com/en/flightstatus")
        default:
            return nil
        }
    }

    private var officialAirlineSourceName: String {
        switch flight.flight?.iata?.prefix(2).uppercased() {
        case "KU":
            return "Kuwait Airways"
        default:
            return "Airline flight status"
        }
    }

    private var passengerChecklistCard: some View {
        infoCard(
            title: "Travel checklist",
            subtitle: "What to confirm before moving through the airport",
            symbol: "checkmark.circle.fill"
        ) {
            checklistRow(
                title: "Flight status",
                detail: readableStatus,
                state: checklistStateForFlightStatus,
                isLast: false
            )
            checklistRow(
                title: "Terminal",
                detail: displayValue(flight.reportedDepartureTerminal, fallback: "Check airport screens"),
                state: availabilityState(for: flight.reportedDepartureTerminal),
                isLast: false
            )
            checklistRow(
                title: "Reported gate",
                detail: reportedGateDetail,
                state: gateChecklistState,
                isLast: false
            )
            checklistRow(
                title: "Departure time",
                detail: readableDateTime(flight.departure?.scheduled, fallback: "Check airline update"),
                state: .info,
                isLast: false
            )
            checklistRow(
                title: "Delay",
                detail: readableDelayMessage,
                state: delayState,
                isLast: true
            )
        }
    }

    private var timelineCard: some View {
        infoCard(
            title: "Flight times",
            subtitle: "Latest reported timing overview",
            symbol: "clock.fill"
        ) {
            timelineRow(label: "Departure", value: readableDateTime(flight.departure?.scheduled), highlighted: false)
            timelineRow(label: "Latest departure", value: readableDateTime(flight.departure?.estimated), highlighted: true)
            timelineRow(label: "Left at", value: readableDateTime(flight.departure?.actual), highlighted: false)

            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 1)

            timelineRow(label: "Arrival", value: readableDateTime(flight.arrival?.scheduled), highlighted: false)
            timelineRow(label: "Latest arrival", value: readableDateTime(flight.arrival?.estimated), highlighted: true)
            timelineRow(label: "Landed at", value: readableDateTime(flight.arrival?.actual), highlighted: false)
        }
    }

    private func airportInfoCard(
        title: String,
        subtitle: String,
        symbol: String,
        airport: FlightEndpoint?,
        isDeparture: Bool
    ) -> some View {
        infoCard(title: title, subtitle: subtitle, symbol: symbol) {
            detailRow("Airport", airport?.airport)
            detailRow("Airport code", airport?.iata)
            detailRow("Terminal", displayValue(airport?.terminal, fallback: "Check screens"))
            detailRow("Reported gate", isDeparture ? passengerGateDisplayText : displayValue(airport?.normalizedGate, fallback: "Check screens"))
            detailRow("Time zone", airport?.timezone)

            if isDeparture {
                detailRow("Delay", readableDelayMessage)
            }
        }
    }

    private var routeSummaryCard: some View {
        infoCard(
            title: "Flight summary",
            subtitle: "A concise overview of the route",
            symbol: "airplane"
        ) {
            detailRow("Airline", airlineName)
            detailRow("Flight", flightCode)
            detailRow("Route", "\(departureCode) → \(arrivalCode)")
            detailRow("Leaving from", flight.departure?.airport)
            detailRow("Going to", flight.arrival?.airport)
            detailRow("Status", readableStatus)
        }
    }

    private var passengerNoteCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label { LText("Passenger note") } icon: { Image(systemName: "info.circle.fill") }
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)

            LText(userFriendlyStatusMessage)
                .font(.system(size: 13, weight: .light))
                .foregroundStyle(.white.opacity(0.60))
                .lineSpacing(1.5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .background(contentCardBackground)
    }

    // MARK: - Shared Cards

    private func infoCard<Content: View>(
        title: String,
        subtitle: String,
        symbol: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 46, height: 46)

                    Image(systemName: symbol)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    LText(title)
                        .font(.system(size: 18, weight: .bold, design: .serif))
                        .foregroundStyle(.white)

                    LText(subtitle)
                        .font(.system(size: 12, weight: .light))
                        .foregroundStyle(.white.opacity(0.46))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }

            VStack(spacing: 12) {
                content()
            }
        }
        .padding(20)
        .background(contentCardBackground)
    }

    private func sectionHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Rectangle()
                .fill(Color(red: 0.83, green: 0.72, blue: 0.49).opacity(0.55))
                .frame(width: 24, height: 1.5)
                .cornerRadius(1)

            LText(title)
                .font(.system(size: 24, weight: .bold, design: .serif))
                .tracking(-0.4)
                .foregroundStyle(.white)

            LText(subtitle)
                .font(.system(size: 12, weight: .light))
                .foregroundStyle(.white.opacity(0.40))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var statusCapsule: some View {
        LText(readableStatus).textCase(.uppercase)
            .font(.system(size: 10, weight: .bold))
            .tracking(0.8)
            .padding(.horizontal, 11)
            .padding(.vertical, 6)
            .background(.white.opacity(0.14))
            .foregroundStyle(.white)
            .overlay(Capsule().stroke(Color.white.opacity(0.16), lineWidth: 1))
            .clipShape(Capsule())
    }

    private func detailCapsule(title: String, value: String) -> some View {
        HStack(spacing: 6) {
            LText(title)
                .foregroundStyle(.white.opacity(0.72))
            Text(value)
                .foregroundStyle(.white)
        }
        .font(.system(size: 10, weight: .bold))
        .tracking(0.6)
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(.white.opacity(0.12))
        .clipShape(Capsule())
    }

    private func airportCodePill(_ text: String) -> some View {
        LText(text)
            .font(.system(size: 14, weight: .bold))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.white.opacity(0.12))
            .foregroundStyle(.white)
            .clipShape(Capsule())
    }

    private func heroMetric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            LText(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.white.opacity(0.60))

            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func quickFactCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            LText(title).textCase(.uppercase)
                .font(.system(size: 9, weight: .semibold))
                .tracking(0.7)
                .foregroundStyle(.white.opacity(0.36))

            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white.opacity(0.90))
                .lineLimit(2)
                .minimumScaleFactor(0.85)
        }
        .frame(maxWidth: .infinity, minHeight: 80, alignment: .topLeading)
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.07), lineWidth: 1)
                )
        )
    }

    private func detailRow(_ title: String, _ value: String?) -> some View {
        HStack(alignment: .top, spacing: 12) {
            LText(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.90))

            Spacer()

            Text(displayValue(value))
                .font(.system(size: 13, weight: .light))
                .foregroundStyle(.white.opacity(0.62))
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 2)
    }

    private func timelineRow(label: String, value: String?, highlighted: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            LText(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.90))

            Spacer()

            Text(displayValue(value, fallback: "Not available"))
                .font(.system(size: 13, weight: highlighted ? .semibold : .light))
                .foregroundStyle(highlighted ? .white : .white.opacity(0.62))
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 2)
    }

    private func checklistRow(title: String, detail: String, state: FlightChecklistState, isLast: Bool) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    Circle()
                        .fill(state.backgroundColor)
                        .frame(width: 30, height: 30)

                    Image(systemName: state.icon)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(state.foregroundColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        LText(title)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)

                        Text(state.label.uppercased())
                            .font(.system(size: 9, weight: .bold))
                            .tracking(0.7)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(state.badgeBackground)
                            .foregroundStyle(state.foregroundColor)
                            .clipShape(Capsule())
                    }

                    gateAwareDetailText(detail)
                        .font(.system(size: 13, weight: .light))
                        .foregroundStyle(.white.opacity(0.62))
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(1.5)
                }

                Spacer(minLength: 0)
            }
            .padding(.vertical, 10)

            if !isLast {
                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 1)
                    .padding(.leading, 0)
            }
        }
    }

    @ViewBuilder
    private func gateAwareDetailText(_ detail: String) -> some View {
        if let gate = flight.reportedDepartureGate,
           let template = gateDetailTemplate(for: detail, gate: gate) {
            LTemplateText(template, replacements: ["{gate}": gate])
        } else {
            LText(detail)
        }
    }

    private func gateDetailTemplate(for detail: String, gate: String) -> String? {
        switch detail {
        case "Likely gate area \(gate). Confirm the exact gate on airport screens.":
            return "Likely gate area {gate}. Confirm the exact gate on airport screens."
        case "Gate \(gate). Because this flight is delayed, the gate may still change.":
            return "Gate {gate}. Because this flight is delayed, the gate may still change."
        case "Gate \(gate). Check airport screens again closer to boarding.":
            return "Gate {gate}. Check airport screens again closer to boarding."
        case "Gate \(gate). Still verify on airport screens before moving.":
            return "Gate {gate}. Still verify on airport screens before moving."
        case "Gate \(gate). Please verify on airport screens.":
            return "Gate {gate}. Please verify on airport screens."
        default:
            return nil
        }
    }

    private var contentCardBackground: some View {
        RoundedRectangle(cornerRadius: 26, style: .continuous)
            .fill(Color.white.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.22), radius: 14, x: 0, y: 8)
    }

    // MARK: - Actions

    private func saveFlight() {
        guard !isAlreadySaved else { return }

        let trip = SavedTrip(
            type: "flight",
            title: tripTitle,
            subtitle: tripSubtitle,
            route: tripRoute,
            summary: tripSummary
        )

        modelContext.insert(trip)
        do {
            try modelContext.save()
        } catch {
            router.showBanner("Unable to save changes")
            return
        }

        router.openTrips(showMessage: "Saved to Trips")
    }

    // MARK: - Data / State Helpers

    private func displayValue(_ value: String?, fallback: String = "-") -> String {
        guard let value, !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return fallback
        }
        return value
    }

    private func availabilityState(for value: String?) -> FlightChecklistState {
        guard let value, !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, value != "-" else {
            return .attention
        }
        return .good
    }

    private var checklistStateForFlightStatus: FlightChecklistState {
        switch flight.flightStatus?.lowercased() {
        case "active", "scheduled":
            return .good
        case "delayed":
            return .attention
        case "cancelled":
            return .warning
        default:
            return .info
        }
    }

    private var delayState: FlightChecklistState {
        guard let delay = flight.departure?.delay else { return .info }
        if delay <= 15 { return .good }
        if delay <= 60 { return .attention }
        return .warning
    }

    private var gateChecklistState: FlightChecklistState {
        guard flight.reportedDepartureGate != nil else {
            return .attention
        }

        switch flight.flightStatus?.lowercased() {
        case "delayed":
            return .attention
        case "cancelled":
            return .warning
        default:
            return .good
        }
    }

    private var shortStatus: String {
        readableStatus
    }

    private var compactDelayText: String {
        guard let delay = flight.departure?.delay else { return "NONE" }
        if delay == 0 { return "NONE" }
        if delay == 1 { return "1 MIN" }
        return "\(delay) MIN"
    }

    private var passengerGateDisplayText: String {
        flight.reportedDepartureGate ?? flight.passengerGateAreaHint ?? "Check screens"
    }

    private var reportedGateText: String {
        flight.reportedDepartureGate ?? "Check screens"
    }

    private var reportedGateDetail: String {
        guard let gate = flight.reportedDepartureGate else {
            if let area = flight.passengerGateAreaHint {
                return "Likely gate area \(area). Confirm the exact gate on airport screens."
            }
            if flight.hasRawDepartureGateRejectedForPassenger {
                return "The provider sent a stand or position number, not a passenger gate. Check airport screens for the real gate."
            }
            return "No gate has been reported yet. Check airport screens closer to boarding."
        }

        switch flight.flightStatus?.lowercased() {
        case "delayed":
            return "Gate \(gate). Because this flight is delayed, the gate may still change."
        case "scheduled":
            return "Gate \(gate). Check airport screens again closer to boarding."
        case "active":
            return "Gate \(gate). Still verify on airport screens before moving."
        default:
            return "Gate \(gate). Please verify on airport screens."
        }
    }

    private var readableStatus: String {
        switch flight.flightStatus?.lowercased() {
        case "active":
            return "In the air"
        case "scheduled":
            return "On time"
        case "delayed":
            return "Running late"
        case "cancelled":
            return "Cancelled"
        default:
            return flight.flightStatus?.capitalized ?? "Unknown"
        }
    }

    private var readableDelayMessage: String {
        guard let delay = flight.departure?.delay else { return "No delay reported" }
        if delay == 0 { return "On time" }
        if delay == 1 { return "1 minute delay" }
        return "\(delay) minute delay"
    }

    private var userFriendlyStatusMessage: String {
        switch flight.flightStatus?.lowercased() {
        case "active":
            return "Your flight appears active. Before moving through the airport, confirm the latest gate and terminal information on the airport screens."
        case "scheduled":
            return "Your flight appears on time. It is still wise to review the gate, terminal, and boarding time again closer to departure."
        case "delayed":
            return "Your flight is running late. Continue checking the airport screens and airline updates because boarding details may still change."
        case "cancelled":
            return "Your flight appears cancelled. Contact the airline as soon as possible or review rebooking options before continuing."
        default:
            return "Flight details can change quickly. Please confirm the latest airport or airline information before you travel."
        }
    }

    private var nextStepState: FlightChecklistState {
        switch flight.flightStatus?.lowercased() {
        case "active":
            return .good
        case "scheduled":
            return .good
        case "delayed":
            return .attention
        case "cancelled":
            return .warning
        default:
            return .info
        }
    }

    private var nextStepMessage: String {
        switch flight.flightStatus?.lowercased() {
        case "active":
            return "Confirm your gate and terminal once more on the airport screens before moving."
        case "scheduled":
            return "You are in a good position. Recheck the gate and terminal again closer to boarding."
        case "delayed":
            return "Wait for the next update and keep watching airport screens, because your gate or boarding time may still change."
        case "cancelled":
            return "Do not continue to the gate yet. Contact the airline or review rebooking options first."
        default:
            return "Check the latest airline or airport update before continuing."
        }
    }

    private func readableDateTime(_ value: String?, fallback: String = "Not available") -> String {
        guard let value, !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return fallback
        }

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        var parsedDate = isoFormatter.date(from: value)
        if parsedDate == nil {
            let fallbackISO = ISO8601DateFormatter()
            fallbackISO.formatOptions = [.withInternetDateTime]
            parsedDate = fallbackISO.date(from: value)
        }

        guard let date = parsedDate else {
            return value
        }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter.string(from: date)
    }

    private var heroGradient: [Color] {
        switch flight.flightStatus?.lowercased() {
        case "active":
            return [
                Color(red: 0.08, green: 0.30, blue: 0.25),
                Color(red: 0.13, green: 0.46, blue: 0.37)
            ]
        case "scheduled":
            return [
                Color(red: 0.09, green: 0.15, blue: 0.28),
                Color(red: 0.15, green: 0.25, blue: 0.46),
                Color(red: 0.22, green: 0.36, blue: 0.62)
            ]
        case "delayed":
            return [
                Color(red: 0.36, green: 0.20, blue: 0.05),
                Color(red: 0.62, green: 0.38, blue: 0.10)
            ]
        case "cancelled":
            return [
                Color(red: 0.34, green: 0.09, blue: 0.12),
                Color(red: 0.56, green: 0.15, blue: 0.18)
            ]
        default:
            return [
                Color(red: 0.24, green: 0.26, blue: 0.33),
                Color(red: 0.34, green: 0.37, blue: 0.44)
            ]
        }
    }

    private var heroShadowColor: Color {
        switch flight.flightStatus?.lowercased() {
        case "active":
            return Color.green.opacity(0.18)
        case "scheduled":
            return Color.blue.opacity(0.18)
        case "delayed":
            return Color.orange.opacity(0.20)
        case "cancelled":
            return Color.red.opacity(0.18)
        default:
            return Color.black.opacity(0.12)
        }
    }

    private var statusHeadline: String {
        switch flight.flightStatus?.lowercased() {
        case "active":
            return "This flight is currently operating."
        case "scheduled":
            return "This flight is currently on time."
        case "delayed":
            return "This flight is currently delayed."
        case "cancelled":
            return "This flight is currently cancelled."
        default:
            return "Live flight information may still change."
        }
    }

    private func shortTime(_ value: String?) -> String {
        readableDateTime(value, fallback: "-")
    }
}

private enum FlightChecklistState {
    case good
    case attention
    case warning
    case info

    var icon: String {
        switch self {
        case .good:
            return "checkmark"
        case .attention:
            return "exclamationmark"
        case .warning:
            return "xmark"
        case .info:
            return "info"
        }
    }

    var label: String {
        switch self {
        case .good:
            return "Good"
        case .attention:
            return "Check"
        case .warning:
            return "Alert"
        case .info:
            return "Info"
        }
    }

    var foregroundColor: Color {
        switch self {
        case .good:
            return .green
        case .attention:
            return .orange
        case .warning:
            return .red
        case .info:
            return .indigo
        }
    }

    var backgroundColor: Color {
        foregroundColor.opacity(0.14)
    }

    var badgeBackground: Color {
        foregroundColor.opacity(0.12)
    }
}

#Preview {
    NavigationStack {
        FlightDetailScreen(
            flight: FlightItem(
                flightDate: "2026-03-16",
                flightStatus: "scheduled",
                departure: FlightEndpoint(
                    airport: "Frankfurt Airport",
                    timezone: "Europe/Berlin",
                    iata: "FRA",
                    icao: "EDDF",
                    terminal: "1",
                    gate: "A23",
                    delay: 20,
                    scheduled: "2026-03-16T10:30:00+01:00",
                    estimated: "2026-03-16T10:50:00+01:00",
                    actual: nil
                ),
                arrival: FlightEndpoint(
                    airport: "John F. Kennedy International Airport",
                    timezone: "America/New_York",
                    iata: "JFK",
                    icao: "KJFK",
                    terminal: "4",
                    gate: nil,
                    delay: nil,
                    scheduled: "2026-03-16T13:10:00-04:00",
                    estimated: "2026-03-16T13:30:00-04:00",
                    actual: nil
                ),
                airline: AirlineInfo(name: "Lufthansa", iata: "LH", icao: "DLH"),
                flight: FlightInfo(number: "400", iata: "LH400", icao: "DLH400")
            )
        )
        .modelContainer(for: SavedTrip.self, inMemory: true)
        .environmentObject(AppRouter())
    }
}


private struct FullScreenPassengerAirportMap: View {
    @Binding var region: MKCoordinateRegion

    let title: String
    let airportCode: String
    let instructionKey: String
    let targetCoordinate: CLLocationCoordinate2D
    let userCoordinate: CLLocationCoordinate2D?
    let onClose: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            PassengerRouteMapView(
                region: $region,
                targetCoordinate: targetCoordinate,
                targetTitle: airportCode,
                userCoordinate: userCoordinate
            )
            .ignoresSafeArea()

            LinearGradient(
                colors: [
                    Color.black.opacity(0.72),
                    Color.black.opacity(0.12),
                    Color.black.opacity(0.36)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(PremiumPalette.gold.opacity(0.18))
                            .frame(width: 42, height: 42)

                        Image(systemName: "figure.walk.circle.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(PremiumPalette.gold)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        LText("Full screen passenger map")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)

                        Text(title)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.white.opacity(0.70))
                            .lineLimit(1)
                    }

                    Spacer(minLength: 0)

                    Text(airportCode)
                        .font(.system(size: 11, weight: .bold))
                        .tracking(0.8)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(.white.opacity(0.16), in: Capsule())

                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 38, height: 38)
                            .background(.black.opacity(0.42), in: Circle())
                            .overlay(Circle().stroke(Color.white.opacity(0.16), lineWidth: 1))
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .accessibilityLabel(Text("Close full screen map"))
                }
                .padding(.horizontal, 18)
                .padding(.top, 18)
                .padding(.bottom, 14)
                .background(.ultraThinMaterial)

                Spacer()

                HStack(spacing: 10) {
                    Image(systemName: "hand.draw.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color(red: 0.35, green: 0.63, blue: 1.0))
                        .frame(width: 34, height: 34)
                        .background(Color.white.opacity(0.12), in: Circle())

                    VStack(alignment: .leading, spacing: 3) {
                        LText(userCoordinate == nil ? "Allow location to draw your route" : "Route from your location to gate area")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white)

                        LText(instructionKey)
                            .font(.system(size: 12, weight: .light))
                            .foregroundStyle(.white.opacity(0.66))
                    }

                    Spacer(minLength: 0)
                }
                .padding(14)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
                .padding(.horizontal, 18)
                .padding(.bottom, 22)
            }
        }
    }
}


private final class PassengerLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var coordinate: CLLocationCoordinate2D?

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocation() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            break
        @unknown default:
            break
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        coordinate = locations.last?.coordinate
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        coordinate = nil
    }
}

private struct PassengerRouteMapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion

    let targetCoordinate: CLLocationCoordinate2D
    let targetTitle: String
    let userCoordinate: CLLocationCoordinate2D?

    func makeCoordinator() -> Coordinator {
        Coordinator(region: $region)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .none
        mapView.pointOfInterestFilter = .includingAll
        mapView.setRegion(region, animated: false)
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        context.coordinator.region = $region
        context.coordinator.sync(
            mapView: mapView,
            region: region,
            targetCoordinate: targetCoordinate,
            targetTitle: targetTitle,
            userCoordinate: userCoordinate
        )
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        var region: Binding<MKCoordinateRegion>
        private var isApplyingRegion = false
        private var lastRouteKey: String?
        private var activeDirections: MKDirections?

        init(region: Binding<MKCoordinateRegion>) {
            self.region = region
        }

        func sync(
            mapView: MKMapView,
            region: MKCoordinateRegion,
            targetCoordinate: CLLocationCoordinate2D,
            targetTitle: String,
            userCoordinate: CLLocationCoordinate2D?
        ) {
            let current = mapView.region
            let shouldMoveMap =
                abs(current.center.latitude - region.center.latitude) > 0.0005 ||
                abs(current.center.longitude - region.center.longitude) > 0.0005 ||
                abs(current.span.latitudeDelta - region.span.latitudeDelta) > 0.0005 ||
                abs(current.span.longitudeDelta - region.span.longitudeDelta) > 0.0005

            if shouldMoveMap {
                isApplyingRegion = true
                mapView.setRegion(region, animated: false)
                isApplyingRegion = false
            }

            mapView.removeAnnotations(mapView.annotations.filter { !($0 is MKUserLocation) })
            let target = MKPointAnnotation()
            target.coordinate = targetCoordinate
            target.title = targetTitle
            mapView.addAnnotation(target)

            if let userCoordinate {
                updateWalkingRoute(
                    mapView: mapView,
                    from: userCoordinate,
                    to: targetCoordinate
                )
            } else {
                lastRouteKey = nil
                activeDirections?.cancel()
                activeDirections = nil
                mapView.removeOverlays(mapView.overlays)
            }
        }

        private func updateWalkingRoute(
            mapView: MKMapView,
            from userCoordinate: CLLocationCoordinate2D,
            to targetCoordinate: CLLocationCoordinate2D
        ) {
            let routeKey = [
                userCoordinate.latitude,
                userCoordinate.longitude,
                targetCoordinate.latitude,
                targetCoordinate.longitude
            ]
            .map { String(format: "%.5f", $0) }
            .joined(separator: "|")

            guard routeKey != lastRouteKey else { return }
            lastRouteKey = routeKey
            activeDirections?.cancel()

            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: userCoordinate))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: targetCoordinate))
            request.transportType = .walking
            request.requestsAlternateRoutes = false

            let directions = MKDirections(request: request)
            activeDirections = directions
            directions.calculate { [weak self, weak mapView] response, error in
                guard let self, let mapView, self.lastRouteKey == routeKey else { return }
                mapView.removeOverlays(mapView.overlays)

                if let route = response?.routes.first {
                    route.polyline.title = "walkingRoute"
                    mapView.addOverlay(route.polyline)
                    mapView.setVisibleMapRect(
                        route.polyline.boundingMapRect,
                        edgePadding: UIEdgeInsets(top: 90, left: 36, bottom: 110, right: 36),
                        animated: true
                    )
                    return
                }

                let fallback = MKPolyline(coordinates: [userCoordinate, targetCoordinate], count: 2)
                fallback.title = "fallbackRoute"
                mapView.addOverlay(fallback)
            }
        }

        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            guard !isApplyingRegion else { return }
            region.wrappedValue = mapView.region
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = UIColor.systemBlue.withAlphaComponent(0.95)
                renderer.lineWidth = polyline.title == "fallbackRoute" ? 5 : 7
                renderer.lineDashPattern = polyline.title == "fallbackRoute" ? [10, 7] : nil
                renderer.lineCap = .round
                renderer.lineJoin = .round
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard !(annotation is MKUserLocation) else { return nil }

            let identifier = "gate-target"
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
                ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.annotation = annotation
            view.markerTintColor = UIColor.systemYellow
            view.glyphImage = UIImage(systemName: "figure.walk")
            view.titleVisibility = .visible
            return view
        }
    }
}


private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
