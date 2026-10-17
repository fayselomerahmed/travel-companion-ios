//
//  ProfileScreen.swift
//  TravelCompanion
//
//  Created by User on 3/16/26.
//

import SwiftUI

struct ProfileScreen: View {
    @State private var appeared = false
    @State private var showsTravelPlus = false

    private let contentMaxWidth: CGFloat = 440

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                PremiumBackgroundView()

                TopTravelHeader(title: "Profile", color: .white)
                    .padding(.top, -8)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        heroSection
                            .frame(maxWidth: contentMaxWidth)
                            .frame(maxWidth: .infinity)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 16)
                            .animation(.spring(response: 0.60, dampingFraction: 0.82).delay(0.05), value: appeared)

                        accountSection
                            .frame(maxWidth: contentMaxWidth)
                            .frame(maxWidth: .infinity)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 16)
                            .animation(.spring(response: 0.60, dampingFraction: 0.82).delay(0.12), value: appeared)

                        businessSection
                            .frame(maxWidth: contentMaxWidth)
                            .frame(maxWidth: .infinity)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 16)
                            .animation(.spring(response: 0.60, dampingFraction: 0.82).delay(0.16), value: appeared)

                        providerSection
                            .frame(maxWidth: contentMaxWidth)
                            .frame(maxWidth: .infinity)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 16)
                            .animation(.spring(response: 0.60, dampingFraction: 0.82).delay(0.19), value: appeared)

                        aboutSection
                            .frame(maxWidth: contentMaxWidth)
                            .frame(maxWidth: .infinity)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 16)
                            .animation(.spring(response: 0.60, dampingFraction: 0.82).delay(0.26), value: appeared)

                        noteSection
                            .frame(maxWidth: contentMaxWidth)
                            .frame(maxWidth: .infinity)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 16)
                            .animation(.spring(response: 0.60, dampingFraction: 0.82).delay(0.33), value: appeared)
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
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                    appeared = true
                }
            }
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            PremiumPalette.navy,
                            PremiumPalette.royal,
                            PremiumPalette.blue
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.38), radius: 26, x: 0, y: 16)
                .shadow(color: PremiumPalette.accentBlueLight.opacity(0.08), radius: 12, x: 0, y: 2)

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
                HStack(spacing: 7) {
                    PremiumTag(text: "NATIVE IOS")
                    PremiumTag(text: "SWIFTUI")
                    PremiumTag(text: "TRAVEL")
                }

                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.12))
                            .frame(width: 64, height: 64)

                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 34))
                            .foregroundStyle(.white.opacity(0.92))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        LText("Travel Companion")
                            .font(.system(size: 24, weight: .bold, design: .serif))
                            .tracking(-0.4)
                            .foregroundStyle(.white)

                        LText("Profile & app information")
                            .font(.system(size: 14, weight: .light))
                            .foregroundStyle(.white.opacity(0.62))
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Rectangle()
                        .fill(PremiumPalette.gold.opacity(0.65))
                        .frame(width: 24, height: 1.5)
                        .cornerRadius(1)

                    LText("Inside the product")
                        .font(.system(size: 14, weight: .medium))
                        .tracking(0.2)
                        .foregroundStyle(.white.opacity(0.55))

                    LText("A calm premium\ntravel utility")
                        .font(.system(size: 34, weight: .bold, design: .serif))
                        .tracking(-0.9)
                        .foregroundStyle(.white)
                        .lineSpacing(2)

                    LText("Review app details, current providers, and the product purpose in one refined space.")
                        .font(.system(size: 14, weight: .light))
                        .foregroundStyle(.white.opacity(0.64))
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(24)
        }
        .frame(minHeight: 290)
    }

    // MARK: - Sections

    private var accountSection: some View {
        PremiumContentCard {
            VStack(alignment: .leading, spacing: 16) {
                PremiumIconHeader(
                    title: "Account",
                    subtitle: "Your current app profile details",
                    symbol: "person.circle.fill"
                )

                VStack(spacing: 12) {
                    profileRow(
                        icon: "gearshape.fill",
                        title: "App mode",
                        value: "Development"
                    )

                    PremiumDivider()

                    profileRow(
                        icon: "iphone",
                        title: "Experience",
                        value: "Native SwiftUI app"
                    )
                }
            }
        }
    }

    private var providerSection: some View {
        PremiumContentCard {
            VStack(alignment: .leading, spacing: 16) {
                PremiumIconHeader(
                    title: "Providers",
                    subtitle: "Services currently used by the app",
                    symbol: "network"
                )

                VStack(spacing: 12) {
                    profileRow(
                        icon: "airplane",
                        title: "Flight provider",
                        value: "AviationStack"
                    )

                    PremiumDivider()

                    profileRow(
                        icon: "doc.text.magnifyingglass",
                        title: "Requirements provider",
                        value: "Travel Buddy"
                    )
                }
            }
        }
    }

    private var businessSection: some View {
        PremiumContentCard {
            VStack(alignment: .leading, spacing: 16) {
                PremiumIconHeader(
                    title: "Business model",
                    subtitle: "How this app can earn revenue",
                    symbol: "chart.line.uptrend.xyaxis"
                )

                VStack(spacing: 12) {
                    profileRow(icon: "crown.fill", title: "Premium", value: "Trip pass and subscription")
                    PremiumDivider()
                    profileRow(icon: "link", title: "Affiliate offers", value: "eSIM, lounge, insurance, transfer")
                }

                Button {
                    showsTravelPlus = true
                } label: {
                    HStack {
                        LText("View Travel Plus")
                            .font(.system(size: 14, weight: .bold))
                        Spacer()
                        Image(systemName: "arrow.right")
                            .font(.system(size: 13, weight: .bold))
                    }
                    .foregroundStyle(PremiumPalette.midnight)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 13)
                    .background(PremiumPalette.gold, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
    }

    private var aboutSection: some View {
        PremiumContentCard {
            VStack(alignment: .leading, spacing: 16) {
                PremiumIconHeader(
                    title: "About the app",
                    subtitle: "What this experience is designed to help with",
                    symbol: "sparkles"
                )

                LText("This app combines flight tracking and travel requirement checks in one native SwiftUI experience, helping passengers prepare before they travel.")
                    .font(.system(size: 13, weight: .light))
                    .foregroundStyle(.white.opacity(0.60))
                    .lineSpacing(1.5)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var noteSection: some View {
        PremiumContentCard {
            VStack(alignment: .leading, spacing: 16) {
                PremiumIconHeader(
                    title: "Important note",
                    subtitle: "A reminder for real-world travel use",
                    symbol: "info.circle.fill"
                )

                LText("Flight details, gates, and travel requirements can change. Passengers should always confirm final airline and official government information before departure.")
                    .font(.system(size: 13, weight: .light))
                    .foregroundStyle(.white.opacity(0.60))
                    .lineSpacing(1.5)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: - Components

    private func profileRow(icon: String, title: String, value: String) -> some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 34, height: 34)

                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.88))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(LocalizedStringKey(title))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)

                Text(value)
                    .font(.system(size: 13, weight: .light))
                    .foregroundStyle(.white.opacity(0.58))
            }

            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        ProfileScreen()
    }
}
