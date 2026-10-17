//
//  HomeView.swift
//  TravelCompanion
//
//  Created by User on 3/16/26.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var router: AppRouter

    @State private var recentFlightSearches: [String] = []
    @State private var recentRequirementChecks: [RecentRequirementCheck] = []
    @State private var appeared = false
    @State private var showsTravelPlus = false

    private let recentFlightsKey = "recent_flight_searches"
    private let recentRequirementsKey = "recent_requirement_checks"
    private let contentMaxWidth: CGFloat = 440

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                PremiumBackgroundView()

                TopTravelHeader(title: "Travel", color: .white)
                    .padding(.top, -8)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 26) {
                        featuredHero
                            .frame(maxWidth: contentMaxWidth)
                            .frame(maxWidth: .infinity)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 18)
                            .animation(.spring(response: 0.65, dampingFraction: 0.82).delay(0.05), value: appeared)

                        if PurchaseManager.isEnabledInThisBuild {
                            TravelPlusCompactCard {
                                showsTravelPlus = true
                            }
                            .frame(maxWidth: contentMaxWidth)
                            .frame(maxWidth: .infinity)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 18)
                            .animation(.spring(response: 0.65, dampingFraction: 0.82).delay(0.10), value: appeared)
                        }

                        toolsSection
                            .frame(maxWidth: contentMaxWidth)
                            .frame(maxWidth: .infinity)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 18)
                            .animation(.spring(response: 0.65, dampingFraction: 0.82).delay(0.15), value: appeared)

                        continueSection
                            .frame(maxWidth: contentMaxWidth)
                            .frame(maxWidth: .infinity)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 18)
                            .animation(.spring(response: 0.65, dampingFraction: 0.82).delay(0.25), value: appeared)

                        footerNote
                            .frame(maxWidth: contentMaxWidth)
                            .frame(maxWidth: .infinity)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 12)
                            .animation(.spring(response: 0.65, dampingFraction: 0.82).delay(0.32), value: appeared)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 92)
                    .padding(.bottom, 44)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .sheet(isPresented: $showsTravelPlus) {
                TravelPlusScreen()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        router.openTrips()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(PremiumPalette.whiteSurface)
                                .frame(width: 38, height: 38)
                                .overlay(
                                    Circle()
                                        .stroke(PremiumPalette.whiteBorder, lineWidth: 1)
                                )

                            Image(systemName: "bookmark.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.90))
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .onAppear {
                loadRecentActivity()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                    appeared = true
                }
            }
        }
    }

    // MARK: - Featured Hero

    private var featuredHero: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            PremiumPalette.navy,
                            Color(red: 0.14, green: 0.23, blue: 0.42),
                            PremiumPalette.blue
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.40), radius: 28, x: 0, y: 18)
                .shadow(color: PremiumPalette.accentBlueLight.opacity(0.06), radius: 12, x: 0, y: 2)

            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.055), .clear, Color.black.opacity(0.06)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            HeroFlightPath()
                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                .opacity(0.22)

            RadialGradient(
                colors: [PremiumPalette.gold.opacity(0.14), .clear],
                center: UnitPoint(x: 0.90, y: 0.10),
                startRadius: 10,
                endRadius: 160
            )
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))

            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(Color.white.opacity(0.09), lineWidth: 1)

            VStack(alignment: .leading, spacing: 22) {
                HStack(spacing: 7) {
                    PremiumTag(text: "PREMIUM")
                    PremiumTag(text: "FLIGHTS")
                    PremiumTag(text: "TRAVEL")
                }

                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(PremiumPalette.gold.opacity(0.70))
                            .frame(width: 26, height: 1.5)
                            .cornerRadius(1)
                        Spacer()
                    }

                    LText("Ready for your")
                        .font(.system(size: 15, weight: .medium))
                        .tracking(0.3)
                        .foregroundStyle(PremiumPalette.textSecondary)

                    LText("Next trip?")
                        .font(.system(size: 40, weight: .bold, design: .serif))
                        .tracking(-1.2)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    LText("Track flights, check entry requirements, and keep your travels beautifully organised.")
                        .font(.system(size: 15, weight: .light))
                        .foregroundStyle(PremiumPalette.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(2)
                }

                HStack(spacing: 10) {
                    Button {
                        router.openFlights()
                    } label: {
                        LText("Track flights")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.black)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 13)
                            .background(Color.white)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(ScaleButtonStyle())

                    Button {
                        router.openRequirements()
                    } label: {
                        LText("Check entry")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 13)
                            .background(Color.white.opacity(0.09))
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.13), lineWidth: 1)
                            )
                            .clipShape(Capsule())
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .padding(26)
        }
        .frame(height: 300)
    }

    // MARK: - Tools

    private var toolsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            PremiumSectionHeader(
                title: "Your tools",
                subtitle: "Everything important, one tap away"
            )

            HStack(spacing: 12) {
                Button {
                    router.openFlights()
                } label: {
                    boardingPassTile(
                        title: "Flights",
                        subtitle: "Live tracking",
                        accent: Color(red: 0.64, green: 0.75, blue: 1.00)
                    )
                }
                .buttonStyle(ScaleButtonStyle())

                Button {
                    router.openRequirements()
                } label: {
                    entryRequirementsTile(
                        title: "Entry",
                        subtitle: "Passport & visa",
                        accent: Color(red: 0.74, green: 0.78, blue: 1.00)
                    )
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
    }

    // MARK: - Continue

    @ViewBuilder
    private var continueSection: some View {
        if !recentFlightSearches.isEmpty || !recentRequirementChecks.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                PremiumSectionHeader(
                    title: "Continue",
                    subtitle: "Pick up where you left off"
                )

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        if !recentFlightSearches.isEmpty {
                            recentFlightsPanel
                        }

                        if !recentRequirementChecks.isEmpty {
                            recentChecksPanel
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }
    }

    private var recentFlightsPanel: some View {
        PremiumMiniCard(width: 260, cornerRadius: 26) {
            VStack(alignment: .leading, spacing: 16) {
                panelHeader(title: "Recent flights", icon: "clock.arrow.circlepath")

                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(recentFlightSearches.prefix(3).enumerated()), id: \.offset) { index, code in
                        Button {
                            router.openFlights(with: code)
                        } label: {
                            HStack {
                                Text(code)
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(.white.opacity(0.92))
                                    .tracking(0.5)

                                Spacer()

                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(PremiumPalette.textHint)
                            }
                            .padding(.vertical, 10)
                        }
                        .buttonStyle(.plain)

                        if index < min(recentFlightSearches.count, 3) - 1 {
                            PremiumDivider()
                        }
                    }
                }
            }
        }
    }

    private var recentChecksPanel: some View {
        PremiumMiniCard(width: 300, cornerRadius: 26) {
            VStack(alignment: .leading, spacing: 16) {
                panelHeader(title: "Recent checks", icon: "globe.europe.africa.fill")

                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(recentRequirementChecks.prefix(2).enumerated()), id: \.element.id) { index, item in
                        Button {
                            router.openRequirements(with: item)
                        } label: {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(item.routeText)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.white.opacity(0.92))

                                Text(item.subtitleText)
                                    .font(.system(size: 13, weight: .light))
                                    .foregroundStyle(PremiumPalette.textSecondary)
                                    .lineLimit(2)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 10)
                        }
                        .buttonStyle(.plain)

                        if index < min(recentRequirementChecks.count, 2) - 1 {
                            PremiumDivider()
                        }
                    }
                }
            }
        }
    }

    // MARK: - Footer

    private var footerNote: some View {
        PremiumContentCard(cornerRadius: 26) {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    Circle()
                        .fill(PremiumPalette.gold.opacity(0.12))
                        .frame(width: 44, height: 44)

                    Circle()
                        .stroke(PremiumPalette.gold.opacity(0.22), lineWidth: 1)
                        .frame(width: 44, height: 44)

                    Image(systemName: "shield.checkered")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(PremiumPalette.gold.opacity(0.90))
                }

                VStack(alignment: .leading, spacing: 4) {
                    LText("Travel confidently")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.90))

                    LText("Always confirm final airline updates and official government guidance before departure.")
                        .font(.system(size: 13, weight: .light))
                        .foregroundStyle(PremiumPalette.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(2)
                }

                Spacer(minLength: 0)
            }
        }
    }

    // MARK: - Helpers

    private func loadRecentActivity() {
        if let flights = UserDefaults.standard.array(forKey: recentFlightsKey) as? [String] {
            recentFlightSearches = flights
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() }
                .filter { !$0.isEmpty }
        } else {
            recentFlightSearches = []
        }

        if let data = UserDefaults.standard.data(forKey: recentRequirementsKey),
           let checks = try? JSONDecoder().decode([RecentRequirementCheck].self, from: data) {
            recentRequirementChecks = checks
        } else {
            recentRequirementChecks = []
        }
    }

    private func panelHeader(title: String, icon: String) -> some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(0.07))
                    .frame(width: 38, height: 38)

                Image(systemName: icon)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white.opacity(0.85))
            }

            Text(LocalizedStringKey(title))
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)

            Spacer()
        }
    }

    // MARK: - Tiles

    private func boardingPassTile(title: String, subtitle: String, accent: Color) -> some View {
        ZStack {
            BoardingPassShape(cutoutRadius: 11)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.10, green: 0.17, blue: 0.32),
                            Color(red: 0.18, green: 0.28, blue: 0.50)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.30), radius: 16, x: 0, y: 10)
                .shadow(color: accent.opacity(0.08), radius: 8, x: 0, y: 2)

            BoardingPassShape(cutoutRadius: 11)
                .stroke(Color.white.opacity(0.09), lineWidth: 1)

            BoardingPassShape(cutoutRadius: 11)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.045), .clear],
                        startPoint: .topLeading,
                        endPoint: .center
                    )
                )

            VStack(alignment: .leading, spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(accent.opacity(0.16))
                        .frame(width: 52, height: 52)

                    Image(systemName: "airplane.departure")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(accent)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 3) {
                    Text(LocalizedStringKey(title))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)

                    Text(LocalizedStringKey(subtitle))
                        .font(.system(size: 13, weight: .light))
                        .foregroundStyle(PremiumPalette.textSecondary)
                }

                Spacer()

                Rectangle()
                    .fill(Color.white.opacity(0.10))
                    .frame(height: 1)
                    .padding(.horizontal, -4)

                Spacer().frame(height: 14)

                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 1) {
                        LText("FROM")
                            .font(.system(size: 9, weight: .bold))
                            .tracking(0.8)
                            .foregroundStyle(PremiumPalette.textHint)

                        LText("NOW")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.88))
                    }

                    Spacer()

                    Image(systemName: "arrow.right")
                        .font(.system(size: 11))
                        .foregroundStyle(PremiumPalette.textHint)

                    Spacer()

                    VStack(alignment: .trailing, spacing: 1) {
                        LText("TO")
                            .font(.system(size: 9, weight: .bold))
                            .tracking(0.8)
                            .foregroundStyle(PremiumPalette.textHint)

                        LText("LIVE")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.88))
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
        }
        .frame(maxWidth: .infinity, minHeight: 215)
    }

    private func entryRequirementsTile(title: String, subtitle: String, accent: Color) -> some View {
        ZStack(alignment: .topLeading) {
            PremiumCardBackground(cornerRadius: 26)

            VStack(alignment: .leading, spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(accent.opacity(0.13))
                        .frame(width: 52, height: 52)

                    VisaStampSymbol(accent: accent)
                        .frame(width: 30, height: 30)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 3) {
                    Text(LocalizedStringKey(title))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)

                    Text(LocalizedStringKey(subtitle))
                        .font(.system(size: 13, weight: .light))
                        .foregroundStyle(PremiumPalette.textSecondary)
                }

                Spacer()

                HStack {
                    LText("Verified guidance")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(PremiumPalette.textHint)

                    Spacer()

                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(PremiumPalette.textHint)
                }
            }
            .padding(18)
        }
        .frame(maxWidth: .infinity, minHeight: 215)
    }
}

// MARK: - Supporting Shapes & Views

private struct BoardingPassShape: Shape {
    var cutoutRadius: CGFloat = 10

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let r: CGFloat = 26
        let midY = rect.midY

        path.move(to: CGPoint(x: r, y: 0))
        path.addLine(to: CGPoint(x: rect.width - r, y: 0))
        path.addArc(
            center: CGPoint(x: rect.width - r, y: r),
            radius: r,
            startAngle: .degrees(-90),
            endAngle: .degrees(0),
            clockwise: false
        )

        path.addLine(to: CGPoint(x: rect.width, y: midY - cutoutRadius))
        path.addArc(
            center: CGPoint(x: rect.width, y: midY),
            radius: cutoutRadius,
            startAngle: .degrees(-90),
            endAngle: .degrees(90),
            clockwise: false
        )

        path.addLine(to: CGPoint(x: rect.width, y: rect.height - r))
        path.addArc(
            center: CGPoint(x: rect.width - r, y: rect.height - r),
            radius: r,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )

        path.addLine(to: CGPoint(x: r, y: rect.height))
        path.addArc(
            center: CGPoint(x: r, y: rect.height - r),
            radius: r,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )

        path.addLine(to: CGPoint(x: 0, y: midY + cutoutRadius))
        path.addArc(
            center: CGPoint(x: 0, y: midY),
            radius: cutoutRadius,
            startAngle: .degrees(90),
            endAngle: .degrees(-90),
            clockwise: false
        )

        path.addLine(to: CGPoint(x: 0, y: r))
        path.addArc(
            center: CGPoint(x: r, y: r),
            radius: r,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )

        path.closeSubpath()
        return path
    }
}

private struct VisaStampSymbol: View {
    let accent: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .stroke(accent.opacity(0.88), lineWidth: 1.8)
                .rotationEffect(.degrees(-10))

            VStack(spacing: 2) {
                Capsule()
                    .fill(accent.opacity(0.80))
                    .frame(width: 16, height: 1.8)

                LText("OK")
                    .font(.system(size: 7, weight: .bold))
                    .tracking(0.5)
                    .foregroundStyle(accent)
            }
            .rotationEffect(.degrees(-10))
        }
    }
}

private struct HeroFlightPath: View {
    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height

            ZStack {
                Path { path in
                    path.move(to: CGPoint(x: w * 0.06, y: h * 0.82))
                    path.addQuadCurve(
                        to: CGPoint(x: w * 0.88, y: h * 0.22),
                        control: CGPoint(x: w * 0.46, y: h * 0.02)
                    )
                }
                .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [5, 7]))
                .foregroundStyle(.white.opacity(0.50))

                Circle()
                    .fill(.white.opacity(0.85))
                    .frame(width: 7, height: 7)
                    .position(x: w * 0.06, y: h * 0.82)

                Circle()
                    .fill(.white.opacity(0.85))
                    .frame(width: 7, height: 7)
                    .position(x: w * 0.88, y: h * 0.22)

                Image(systemName: "airplane")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.90))
                    .position(x: w * 0.50, y: h * 0.30)
                    .rotationEffect(.degrees(-20))
            }
        }
    }
}
