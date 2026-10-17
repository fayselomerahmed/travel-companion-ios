//
//  PreparationScreen.swift
//  TravelCompanion
//
//  Created by Codex on 6/4/26.
//

import SwiftUI

struct PreparationScreen: View {
    @State private var tasks: [PreparationTask] = PreparationTaskStore.load()
    @State private var customTaskTitle = ""
    @State private var appeared = false
    @State private var showsLanguageSettings = false
    @State private var showsTravelPlus = false
    @ObservedObject private var languageCenter = AppLanguageCenter.shared

    private let contentMaxWidth: CGFloat = 440

    private var completedCount: Int {
        tasks.filter(\.isDone).count
    }

    private var progress: Double {
        guard !tasks.isEmpty else { return 0 }
        return Double(completedCount) / Double(tasks.count)
    }

    private var remainingCount: Int {
        max(tasks.count - completedCount, 0)
    }

    private var apiStatuses: [ConfigurationStatus] {
        [
            ConfigurationStatus(
                title: "Flight provider",
                detail: "AviationStack",
                isReady: APIKeys.isConfigured("AVIATIONSTACK_API_KEY")
            ),
            ConfigurationStatus(
                title: "Requirements provider",
                detail: "RapidAPI Travel Buddy",
                isReady: APIKeys.isConfigured("RAPID_API_KEY")
            )
        ]
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                PremiumBackgroundView()

                TopTravelHeader(title: "Plan", color: .white)
                    .padding(.top, -8)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        inlineLanguageStrip
                            .frame(maxWidth: contentMaxWidth)
                            .frame(maxWidth: .infinity)

                        heroSection
                            .frame(maxWidth: contentMaxWidth)
                            .frame(maxWidth: .infinity)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 16)
                            .animation(.spring(response: 0.60, dampingFraction: 0.82).delay(0.05), value: appeared)

                        appSettingsSection
                            .frame(maxWidth: contentMaxWidth)
                            .frame(maxWidth: .infinity)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 16)
                            .animation(.spring(response: 0.60, dampingFraction: 0.82).delay(0.14), value: appeared)

                        checklistSection
                            .frame(maxWidth: contentMaxWidth)
                            .frame(maxWidth: .infinity)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 16)
                            .animation(.spring(response: 0.60, dampingFraction: 0.82).delay(0.20), value: appeared)

                        quickAddSection
                            .frame(maxWidth: contentMaxWidth)
                            .frame(maxWidth: .infinity)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 16)
                            .animation(.spring(response: 0.60, dampingFraction: 0.82).delay(0.28), value: appeared)

                        revenueSection
                            .frame(maxWidth: contentMaxWidth)
                            .frame(maxWidth: .infinity)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 16)
                            .animation(.spring(response: 0.60, dampingFraction: 0.82).delay(0.32), value: appeared)

                        readinessSection
                            .frame(maxWidth: contentMaxWidth)
                            .frame(maxWidth: .infinity)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 16)
                            .animation(.spring(response: 0.60, dampingFraction: 0.82).delay(0.36), value: appeared)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 92)
                    .padding(.bottom, 44)
                }

                Button {
                    showsLanguageSettings = true
                } label: {
                    Image(systemName: "globe")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.white.opacity(0.10), in: Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.14), lineWidth: 1))
                        .shadow(color: .black.opacity(0.18), radius: 10, x: 0, y: 6)
                }
                .buttonStyle(ScaleButtonStyle())
                .accessibilityLabel(Text("Language"))
                .padding(.top, 4)
                .padding(.trailing, 18)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .sheet(isPresented: $showsLanguageSettings) {
                NavigationStack {
                    LanguageSettingsScreen()
                }
            }
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

    private var heroSection: some View {
        PremiumHeroCard(
            tags: ["CHECKLIST", "READY", "OFFLINE"],
            eyebrow: "Before departure",
            title: "Prep your\nnext trip",
            description: "Track the essentials that sit between booking and boarding.",
            minHeight: 250
        ) {
            VStack(alignment: .leading, spacing: 14) {
                ProgressView(value: progress)
                    .tint(PremiumPalette.gold)
                    .background(Color.white.opacity(0.10))
                    .clipShape(Capsule())

                HStack(spacing: 16) {
                    metricBlock(title: "Done", value: "\(completedCount)")
                    metricBlock(title: "Left", value: "\(remainingCount)")
                    metricBlock(title: "Total", value: "\(tasks.count)")
                }
            }
        }
    }

    private var appSettingsSection: some View {
        PremiumContentCard {
            VStack(alignment: .leading, spacing: 16) {
                PremiumIconHeader(
                    title: "App settings",
                    subtitle: "Language and regional preferences",
                    symbol: "gearshape.fill"
                )

                Button {
                    showsLanguageSettings = true
                } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(PremiumPalette.gold.opacity(0.18))
                                .frame(width: 38, height: 38)

                            Image(systemName: "globe.europe.africa.fill")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(PremiumPalette.gold)
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            LText("Language")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.white)

                            HStack(spacing: 6) {
                                LText(selectedLanguage.displayNameKey)
                                Text("•")
                                Text(selectedLanguage.nativeName)
                            }
                            .font(.system(size: 12, weight: .light))
                            .foregroundStyle(.white.opacity(0.56))
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white.opacity(0.38))
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
                .buttonStyle(ScaleButtonStyle())
            }
        }
    }

    private var selectedLanguage: AppLanguage {
        languageCenter.selectedLanguage
    }

    private var inlineLanguageStrip: some View {
        PremiumContentCard(cornerRadius: 22) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: "globe.europe.africa.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(PremiumPalette.gold)

                    VStack(alignment: .leading, spacing: 2) {
                        LText("Language")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)

                        HStack(spacing: 6) {
                            LText(selectedLanguage.displayNameKey)
                            Text(selectedLanguage.nativeName)
                        }
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.58))
                    }

                    Spacer()
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(AppLanguage.allCases) { language in
                            languageChip(language)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .id(languageCenter.rawValue)
    }

    private func languageChip(_ language: AppLanguage) -> some View {
        let isSelected = languageCenter.rawValue == language.rawValue

        return Button {
            withAnimation(.easeInOut(duration: 0.18)) {
                languageCenter.setLanguage(language)
            }
        } label: {
            HStack(spacing: 6) {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                }

                LText(language.displayNameKey)
                    .font(.system(size: 12, weight: .bold))
            }
            .foregroundStyle(isSelected ? PremiumPalette.midnight : .white.opacity(0.82))
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(
                Capsule()
                    .fill(isSelected ? PremiumPalette.gold : Color.white.opacity(0.075))
                    .overlay(Capsule().stroke(Color.white.opacity(isSelected ? 0 : 0.10), lineWidth: 1))
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private var checklistSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            PremiumSectionHeader(
                title: "Preparation",
                subtitle: "Tap an item when it is handled"
            )

            VStack(spacing: 12) {
                ForEach(tasks) { task in
                    checklistRow(task)
                }
            }
        }
    }

    private var quickAddSection: some View {
        PremiumContentCard {
            VStack(alignment: .leading, spacing: 16) {
                PremiumIconHeader(
                    title: "Add your own",
                    subtitle: "Keep personal reminders with the trip basics",
                    symbol: "plus.circle.fill"
                )

                HStack(spacing: 10) {
                    TextField("e.g. Download train tickets", text: $customTaskTitle)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white)
                        .tint(.white)
                        .submitLabel(.done)
                        .onSubmit(addCustomTask)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 13)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.white.opacity(0.07))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(Color.white.opacity(0.10), lineWidth: 1)
                                )
                        )

                    Button(action: addCustomTask) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [PremiumPalette.accentBlue, PremiumPalette.accentBlueLight],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .disabled(customTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(customTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.45 : 1)
                }

                Button {
                    resetDefaults()
                } label: {
                    Label { LText("Reset default checklist") } icon: { Image(systemName: "arrow.counterclockwise") }
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.70))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var readinessSection: some View {
        PremiumContentCard {
            VStack(alignment: .leading, spacing: 16) {
                PremiumIconHeader(
                    title: "App readiness",
                    subtitle: "Provider configuration used by Flights and Requirements",
                    symbol: "checkmark.shield.fill"
                )

                VStack(spacing: 12) {
                    ForEach(apiStatuses) { status in
                        statusRow(status)
                        if status.id != apiStatuses.last?.id {
                            PremiumDivider()
                        }
                    }
                }
            }
        }
    }

    private var revenueSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            PremiumSectionHeader(
                title: "Trip upgrades",
                subtitle: "Passenger services that can turn the app into revenue"
            )

            TravelPlusCompactCard {
                showsTravelPlus = true
            }

            VStack(spacing: 12) {
                TravelServiceMarketplaceCard(
                    symbol: "simcard.fill",
                    title: "eSIM data",
                    detail: "Offer mobile data for the destination before the passenger leaves.",
                    tag: "Affiliate",
                    url: AffiliateLinks.eSIM
                )

                TravelServiceMarketplaceCard(
                    symbol: "shield.lefthalf.filled",
                    title: "Travel insurance",
                    detail: "Place insurance next to passport, visa, and document reminders.",
                    tag: "Partner",
                    url: AffiliateLinks.insurance
                )
            }
        }
    }

    private func checklistRow(_ task: PreparationTask) -> some View {
        Button {
            toggle(task)
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(task.isDone ? PremiumPalette.gold.opacity(0.22) : Color.white.opacity(0.07))
                        .frame(width: 34, height: 34)

                    Image(systemName: task.isDone ? "checkmark" : task.symbol)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(task.isDone ? PremiumPalette.gold : .white.opacity(0.82))
                }

                VStack(alignment: .leading, spacing: 3) {
                    LText(task.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .strikethrough(task.isDone, color: .white.opacity(0.45))

                    LText(task.category)
                        .font(.system(size: 11, weight: .medium))
                        .tracking(0.4)
                        .foregroundStyle(.white.opacity(0.42))
                }

                Spacer()

                if task.isCustom {
                    Button {
                        delete(task)
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.45))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(task.isDone ? Color.white.opacity(0.035) : Color.white.opacity(0.055))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(task.isDone ? PremiumPalette.gold.opacity(0.18) : Color.white.opacity(0.08), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private func metricBlock(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            LText(title).textCase(.uppercase)
                .font(.system(size: 9, weight: .bold))
                .tracking(0.7)
                .foregroundStyle(.white.opacity(0.42))

            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func statusRow(_ status: ConfigurationStatus) -> some View {
        HStack(spacing: 12) {
            Image(systemName: status.isReady ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(status.isReady ? PremiumPalette.gold : Color.orange)

            VStack(alignment: .leading, spacing: 3) {
                LText(status.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)

                LText(status.isReady ? "\(status.detail) is configured" : "\(status.detail) needs a key")
                    .font(.system(size: 12, weight: .light))
                    .foregroundStyle(.white.opacity(0.56))
            }

            Spacer()
        }
    }

    private func toggle(_ task: PreparationTask) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index].isDone.toggle()
        PreparationTaskStore.save(tasks)
    }

    private func addCustomTask() {
        let title = customTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }

        tasks.append(
            PreparationTask(
                title: title,
                category: "PERSONAL",
                symbol: "sparkle",
                isCustom: true
            )
        )
        customTaskTitle = ""
        PreparationTaskStore.save(tasks)
    }

    private func delete(_ task: PreparationTask) {
        tasks.removeAll { $0.id == task.id }
        PreparationTaskStore.save(tasks)
    }

    private func resetDefaults() {
        tasks = PreparationTask.defaultTasks
        PreparationTaskStore.save(tasks)
    }
}

struct PreparationTask: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var title: String
    var category: String
    var symbol: String
    var isDone: Bool = false
    var isCustom: Bool = false

    static let defaultTasks: [PreparationTask] = [
        PreparationTask(title: "Check passport validity", category: "DOCUMENTS", symbol: "person.text.rectangle"),
        PreparationTask(title: "Review visa and entry rules", category: "DOCUMENTS", symbol: "doc.text.magnifyingglass"),
        PreparationTask(title: "Confirm flight status and terminal", category: "FLIGHTS", symbol: "airplane.departure"),
        PreparationTask(title: "Save hotel or stay address", category: "ARRIVAL", symbol: "building.2"),
        PreparationTask(title: "Download offline maps", category: "ARRIVAL", symbol: "map"),
        PreparationTask(title: "Pack charger and travel adapter", category: "PACKING", symbol: "powerplug"),
        PreparationTask(title: "Set travel insurance details aside", category: "SAFETY", symbol: "cross.case"),
        PreparationTask(title: "Share itinerary with someone trusted", category: "SAFETY", symbol: "person.2")
    ]
}

private struct ConfigurationStatus: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let detail: String
    let isReady: Bool
}

enum PreparationTaskStore {
    private static let key = "preparation_tasks"

    static func load() -> [PreparationTask] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let tasks = try? JSONDecoder().decode([PreparationTask].self, from: data),
              !tasks.isEmpty else {
            return PreparationTask.defaultTasks
        }
        return tasks
    }

    static func save(_ tasks: [PreparationTask]) {
        guard let data = try? JSONEncoder().encode(tasks) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}

#Preview {
    PreparationScreen()
}
