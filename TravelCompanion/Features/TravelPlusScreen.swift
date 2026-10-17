//
//  TravelPlusScreen.swift
//  TravelCompanion
//
//

import SwiftUI

struct TravelPlusScreen: View {
    @SwiftUI.Environment(\.dismiss) private var dismiss
    @StateObject private var purchaseManager = PurchaseManager.shared
    @State private var purchaseAlertMessage: String?

    private let perks: [TravelPlusPerk] = [
        TravelPlusPerk(symbol: "bell.badge.fill", title: "Real-time alerts", detail: "Gate changes, delays, boarding reminders, and arrival updates."),
        TravelPlusPerk(symbol: "map.fill", title: "Airport guidance", detail: "Bigger gate maps, passenger route guidance, and saved airport notes."),
        TravelPlusPerk(symbol: "doc.badge.plus", title: "Document wallet", detail: "Keep passport, visa, insurance, hotel, and booking reminders together."),
        TravelPlusPerk(symbol: "wifi.slash", title: "Offline trip mode", detail: "Save essentials before departure so the plan still works without roaming.")
    ]

    private let plans: [TravelPlusPlan] = [
        TravelPlusPlan(
            title: "Trip Pass",
            fallbackPrice: "$4.99",
            subtitle: "Best for one journey",
            badge: "POPULAR",
            productID: PurchaseManager.tripPassProductID
        ),
        TravelPlusPlan(
            title: "Travel Plus",
            fallbackPrice: "$3.99/mo",
            subtitle: "For frequent travelers",
            badge: "VALUE",
            productID: PurchaseManager.monthlyProductID
        )
    ]

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                PremiumBackgroundView()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        hero
                        planSection
                        perksSection
                        marketplaceSection
                        productionNote
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 36)
                }
            }
            .navigationTitle(Text(L10n.string("Travel Plus", languageRawValue: AppLanguageCenter.shared.rawValue)))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 34, height: 34)
                            .background(Color.white.opacity(0.10), in: Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .task {
                await purchaseManager.loadProducts()
                await purchaseManager.refreshPurchasedProducts()
            }
            .alert(
                Text(L10n.string("Payment setup needed", languageRawValue: AppLanguageCenter.shared.rawValue)),
                isPresented: Binding(
                    get: { purchaseAlertMessage != nil },
                    set: { if !$0 { purchaseAlertMessage = nil } }
                )
            ) {
                Button("OK", role: .cancel) {
                    purchaseAlertMessage = nil
                }
            } message: {
                Text(L10n.string(purchaseAlertMessage ?? "", languageRawValue: AppLanguageCenter.shared.rawValue))
            }
        }
    }

    private var hero: some View {
        PremiumHeroCard(
            tags: ["PLUS", "ALERTS", "OFFLINE"],
            eyebrow: "Upgrade the journey",
            title: "Know what to do next",
            description: "A paid layer for travelers who want live alerts, saved trip essentials, and airport-ready guidance.",
            minHeight: 300
        ) {
            HStack(spacing: 10) {
                revenueMetric(
                    title: "Trip pass",
                    value: purchaseManager.displayPrice(for: PurchaseManager.tripPassProductID, fallback: "$4.99")
                )
                revenueMetric(
                    title: "Monthly",
                    value: purchaseManager.displayPrice(for: PurchaseManager.monthlyProductID, fallback: "$3.99")
                )
                revenueMetric(title: "Services", value: "Affiliate")
            }
        }
    }

    private var planSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            PremiumSectionHeader(
                title: "Choose a plan",
                subtitle: "Simple pricing that fits how people travel"
            )

            VStack(spacing: 12) {
                ForEach(plans) { plan in
                    planRow(plan)
                }
            }

            Button {
                Task {
                    await purchaseManager.restorePurchases()
                }
            } label: {
                Label {
                    LText("Restore purchases")
                } icon: {
                    Image(systemName: "arrow.clockwise")
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white.opacity(0.72))
            }
            .buttonStyle(.plain)

            if let message = purchaseManager.statusMessage {
                LText(message)
                    .font(.system(size: 12, weight: .light))
                    .foregroundStyle(PremiumPalette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var perksSection: some View {
        PremiumContentCard {
            VStack(alignment: .leading, spacing: 16) {
                PremiumIconHeader(
                    title: "Premium features",
                    subtitle: "Features passengers understand and pay for",
                    symbol: "sparkles"
                )

                VStack(spacing: 12) {
                    ForEach(Array(perks.enumerated()), id: \.element.id) { index, perk in
                        perkRow(perk)
                        if index < perks.count - 1 {
                            PremiumDivider()
                        }
                    }
                }
            }
        }
    }

    private var marketplaceSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            PremiumSectionHeader(
                title: "Travel services",
                subtitle: "Revenue-ready offers to connect with partners"
            )

            VStack(spacing: 12) {
                TravelServiceMarketplaceCard(
                    symbol: "simcard.fill",
                    title: "eSIM data",
                    detail: "Sell destination data plans before departure.",
                    tag: "Affiliate",
                    url: AffiliateLinks.eSIM
                )
                TravelServiceMarketplaceCard(
                    symbol: "sofa.fill",
                    title: "Airport lounge",
                    detail: "Offer lounge access during delays or long transfers.",
                    tag: "Booking",
                    url: AffiliateLinks.lounge
                )
                TravelServiceMarketplaceCard(
                    symbol: "car.fill",
                    title: "Airport transfer",
                    detail: "Connect arrival plans with taxi or train partners.",
                    tag: "Partner",
                    url: AffiliateLinks.transfer
                )
            }
        }
    }

    private var productionNote: some View {
        PremiumContentCard(cornerRadius: 22) {
            VStack(alignment: .leading, spacing: 10) {
                LText("Travel Plus preview")
                    .font(.system(size: 17, weight: .bold, design: .serif))
                    .foregroundStyle(.white)

                LText("Premium plans are a preview. Live alerts, document wallet, and offline premium tools are planned features. Purchases remain disabled until those features and payments are verified.")
                    .font(.system(size: 13, weight: .light))
                    .foregroundStyle(PremiumPalette.textSecondary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func planRow(_ plan: TravelPlusPlan) -> some View {
        PremiumContentCard(cornerRadius: 22) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 5) {
                        HStack(spacing: 8) {
                            LText(plan.title)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.white)

                            LText(plan.badge)
                                .font(.system(size: 9, weight: .bold))
                                .tracking(0.8)
                                .foregroundStyle(PremiumPalette.midnight)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(PremiumPalette.gold, in: Capsule())
                        }

                        LText(plan.subtitle)
                            .font(.system(size: 12, weight: .light))
                            .foregroundStyle(PremiumPalette.textSecondary)
                    }

                    Spacer()

                    Text(purchaseManager.displayPrice(for: plan.productID, fallback: plan.fallbackPrice))
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .foregroundStyle(.white)
                }

                Button {
                    Task {
                        if !purchaseManager.isProductAvailable(plan.productID) {
                            let message = "Create this product in App Store Connect or select a StoreKit configuration file in the Xcode scheme."
                            purchaseManager.statusMessage = message
                            purchaseAlertMessage = message
                            return
                        }
                        await purchaseManager.purchase(productID: plan.productID)
                    }
                } label: {
                    HStack {
                        LText(purchaseManager.isPurchased(plan.productID) ? "Active" : (purchaseManager.purchasesEnabled ? "Continue" : "Coming soon"))
                            .font(.system(size: 14, weight: .bold))
                        Spacer()
                        if purchaseManager.isLoading {
                            ProgressView()
                                .tint(PremiumPalette.midnight)
                                .scaleEffect(0.82)
                        } else {
                            Image(systemName: purchaseManager.isPurchased(plan.productID) ? "checkmark" : "arrow.right")
                                .font(.system(size: 13, weight: .bold))
                        }
                    }
                    .foregroundStyle(PremiumPalette.midnight)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 13)
                    .background(PremiumPalette.gold, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(ScaleButtonStyle())
                .disabled(!purchaseManager.purchasesEnabled || purchaseManager.isLoading || purchaseManager.isPurchased(plan.productID))
            }
        }
    }

    private func perkRow(_ perk: TravelPlusPerk) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: perk.symbol)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(PremiumPalette.gold)
                .frame(width: 34, height: 34)
                .background(PremiumPalette.gold.opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 3) {
                LText(perk.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)

                LText(perk.detail)
                    .font(.system(size: 12, weight: .light))
                    .foregroundStyle(PremiumPalette.textSecondary)
                    .lineSpacing(1.5)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
    }

    private func revenueMetric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            LText(title)
                .font(.system(size: 9, weight: .bold))
                .tracking(0.7)
                .foregroundStyle(.white.opacity(0.45))
                .textCase(.uppercase)

            Text(value)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white)
                .minimumScaleFactor(0.75)
                .lineLimit(1)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.075), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct TravelPlusCompactCard: View {
    var action: () -> Void

    var body: some View {
        PremiumContentCard(cornerRadius: 24) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(PremiumPalette.gold)
                        .frame(width: 42, height: 42)
                        .background(PremiumPalette.gold.opacity(0.14), in: Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        LText("Travel Plus")
                            .font(.system(size: 20, weight: .bold, design: .serif))
                            .foregroundStyle(.white)

                        LText("Live alerts, offline trip essentials, document wallet, and partner services.")
                            .font(.system(size: 13, weight: .light))
                            .foregroundStyle(PremiumPalette.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)
                }

                HStack(spacing: 10) {
                    plusPill("Trip Pass $4.99")
                    plusPill("$3.99/mo")
                    Spacer(minLength: 0)
                }

                Button(action: action) {
                    HStack {
                        LText("View premium options")
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

    private func plusPill(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(.white.opacity(0.82))
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(Color.white.opacity(0.08), in: Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.10), lineWidth: 1))
    }
}

struct TravelServiceMarketplaceCard: View {
    @SwiftUI.Environment(\.openURL) private var openURL

    let symbol: String
    let title: String
    let detail: String
    let tag: String
    var url: URL? = nil

    var body: some View {
        Button {
            if let url {
                openURL(url)
            }
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: symbol)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.09), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        LText(title)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)

                        LText(tag)
                            .font(.system(size: 9, weight: .bold))
                            .tracking(0.6)
                            .foregroundStyle(PremiumPalette.gold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(PremiumPalette.gold.opacity(0.12), in: Capsule())
                    }

                    LText(detail)
                        .font(.system(size: 12, weight: .light))
                        .foregroundStyle(PremiumPalette.textSecondary)
                        .lineSpacing(1.5)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                Image(systemName: url == nil ? "link.badge.plus" : "arrow.up.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(url == nil ? .white.opacity(0.32) : PremiumPalette.gold)
            }
            .padding(20)
            .background(PremiumCardBackground(cornerRadius: 22))
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(url == nil)
        .accessibilityHint(Text(url == nil ? "Configure partner link before release" : "Opens partner service"))
    }
}

private struct TravelPlusPerk: Identifiable {
    let id = UUID()
    let symbol: String
    let title: String
    let detail: String
}

private struct TravelPlusPlan: Identifiable {
    let id = UUID()
    let title: String
    let fallbackPrice: String
    let subtitle: String
    let badge: String
    let productID: String
}

#Preview {
    TravelPlusScreen()
}
