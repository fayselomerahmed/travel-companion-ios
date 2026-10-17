import SwiftUI
import SwiftData

typealias SwiftUIEnvironment = SwiftUI.Environment

struct RequirementsScreen: View {
    @StateObject private var vm = RequirementsViewModel()
    @State private var expandedField: String? = nil
    @State private var appeared = false

    @SwiftUIEnvironment(\.modelContext) private var modelContext
    @EnvironmentObject private var router: AppRouter
    @Query(sort: \SavedTrip.savedAt, order: .reverse) private var savedTrips: [SavedTrip]

    private let contentMaxWidth: CGFloat = 440

    private var canCheckRequirements: Bool {
        vm.destination != nil && vm.nationality != nil && !vm.isLoading
    }

    private var selectedItemsCount: Int {
        [vm.origin, vm.destination, vm.nationality].compactMap { $0 }.count
    }

    private var requirementTripTitle: String { "Travel Requirements" }

    private var requirementTripSubtitle: String {
        "\(vm.nationality?.name ?? "Passport") → \(vm.destination?.name ?? "Destination")"
    }

    private var requirementTripRoute: String {
        "\(vm.origin?.name ?? "-") → \(vm.destination?.name ?? "-")"
    }

    private var requirementTripSummary: String {
        guard let result = vm.visaResponse else {
            return "No requirement result available"
        }

        let primary = result.data.visaRules.primaryRule.name ?? "Unknown"
        let passportValidity = result.data.destination.passportValidity ?? "Check passport validity"
        return "Rule: \(primary), Passport validity: \(passportValidity)"
    }

    private var isRequirementAlreadySaved: Bool {
        guard vm.visaResponse != nil else { return false }

        return savedTrips.contains {
            $0.type == "requirement" &&
            $0.title == requirementTripTitle &&
            $0.subtitle == requirementTripSubtitle &&
            $0.route == requirementTripRoute
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            PremiumBackgroundView(
                imageName: "requirements_hero_scene",
                imageOpacity: 0.10,
                overlayOpacityTop: 0.12,
                overlayOpacityBottom: 0.10
            )

            TopTravelHeader(title: "Requirements", color: .white)
                .padding(.top, -8)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    plannerSection
                        .frame(maxWidth: contentMaxWidth)
                        .frame(maxWidth: .infinity)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 16)
                        .animation(.spring(response: 0.60, dampingFraction: 0.82).delay(0.05), value: appeared)

                    recentChecksSection
                        .frame(maxWidth: contentMaxWidth)
                        .frame(maxWidth: .infinity)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 16)
                        .animation(.spring(response: 0.60, dampingFraction: 0.82).delay(0.14), value: appeared)

                    messageSection
                        .frame(maxWidth: contentMaxWidth)
                        .frame(maxWidth: .infinity)

                    emptyStateSection
                        .frame(maxWidth: contentMaxWidth)
                        .frame(maxWidth: .infinity)

                    resultSection
                        .frame(maxWidth: contentMaxWidth)
                        .frame(maxWidth: .infinity)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 16)
                        .animation(.spring(response: 0.60, dampingFraction: 0.82).delay(0.22), value: appeared)
                }
                .padding(.horizontal, 20)
                .padding(.top, 92)
                .padding(.bottom, 44)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .animation(.spring(response: 0.35, dampingFraction: 0.80), value: vm.isLoading)
        .animation(.spring(response: 0.35, dampingFraction: 0.80), value: vm.visaResponse != nil)
        .animation(.spring(response: 0.35, dampingFraction: 0.80), value: vm.errorMessage != nil)
        .animation(.spring(response: 0.35, dampingFraction: 0.80), value: expandedField)
        .onTapGesture {
            if expandedField != nil {
                expandedField = nil
            }
        }
        .onAppear {
            applyPendingRequirementCheckIfNeeded()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                appeared = true
            }
        }
    }

    // MARK: - Planner

    private var plannerSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            plannerHeroCard
            plannerButton
        }
    }

    private var plannerHeroCard: some View {
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
                colors: [PremiumPalette.accentBlueLight.opacity(0.18), .clear],
                center: UnitPoint(x: 0.92, y: 0.08),
                startRadius: 10,
                endRadius: 200
            )
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))

            RadialGradient(
                colors: [PremiumPalette.gold.opacity(0.10), .clear],
                center: UnitPoint(x: 0.08, y: 0.92),
                startRadius: 10,
                endRadius: 180
            )
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))

            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color.white.opacity(0.09), lineWidth: 1)

            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    HStack(spacing: 7) {
                        PremiumTag(text: "ENTRY")
                        PremiumTag(text: "VISA")
                        PremiumTag(text: "PASSPORT")
                    }

                    Spacer()

                    if selectedItemsCount > 0 {
                        Button(L10n.string("Reset", languageRawValue: AppLanguageCenter.shared.rawValue)) {
                            resetSelections()
                        }
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.55))
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Rectangle()
                        .fill(PremiumPalette.gold.opacity(0.65))
                        .frame(width: 24, height: 1.5)
                        .cornerRadius(1)

                    LText("Plan your route")
                        .font(.system(size: 14, weight: .medium))
                        .tracking(0.2)
                        .foregroundStyle(.white.opacity(0.55))

                    LText("Check travel\nrequirements")
                        .font(.system(size: 36, weight: .bold, design: .serif))
                        .tracking(-1.0)
                        .foregroundStyle(.white)
                        .lineSpacing(2)

                    LText("Choose your route and passport nationality to review entry guidance before travel.")
                        .font(.system(size: 14, weight: .light))
                        .foregroundStyle(.white.opacity(0.64))
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(2)
                }

                VStack(spacing: 12) {
                    plannerFieldRow(
                        title: "From",
                        subtitle: vm.origin?.name ?? "Select departure country",
                        icon: "airplane.departure",
                        tint: Color(red: 0.48, green: 0.66, blue: 1.00)
                    ) {
                        CountryDropdownField(
                            title: "From",
                            icon: "airplane.departure",
                            selectedCountry: $vm.origin,
                            expandedField: $expandedField,
                            fieldID: "origin"
                        )
                    }

                    plannerFieldRow(
                        title: "To",
                        subtitle: vm.destination?.name ?? "Select destination country",
                        icon: "mappin.and.ellipse",
                        tint: Color(red: 0.62, green: 0.70, blue: 1.00)
                    ) {
                        CountryDropdownField(
                            title: "To",
                            icon: "mappin.and.ellipse",
                            selectedCountry: $vm.destination,
                            expandedField: $expandedField,
                            fieldID: "destination"
                        )
                    }

                    plannerFieldRow(
                        title: "Passport / Nationality",
                        subtitle: vm.nationality?.name ?? "Select passport nationality",
                        icon: "doc.text",
                        tint: Color(red: 0.40, green: 0.63, blue: 0.99)
                    ) {
                        CountryDropdownField(
                            title: "Passport / Nationality",
                            icon: "doc.text",
                            selectedCountry: $vm.nationality,
                            expandedField: $expandedField,
                            fieldID: "nationality"
                        )
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        LText("Trip progress")
                            .font(.system(size: 13, weight: .medium))
                            .tracking(0.2)
                            .foregroundStyle(.white.opacity(0.75))

                        Spacer()

                        Text("\(selectedItemsCount)/3")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.85))
                    }

                    GeometryReader { proxy in
                        let width = max(
                            proxy.size.width * CGFloat(selectedItemsCount) / 3.0,
                            selectedItemsCount == 0 ? 0 : 30
                        )

                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.18))
                                .frame(height: 6)

                            Capsule()
                                .fill(Color.white.opacity(0.94))
                                .frame(width: width, height: 6)
                        }
                    }
                    .frame(height: 6)
                }

                if let destination = vm.destination?.name,
                   let nationality = vm.nationality?.name {
                    routePreviewCard(destination: destination, nationality: nationality)
                }
            }
            .padding(24)
        }
        .frame(minHeight: 430)
    }

    private func plannerFieldRow<Content: View>(
        title: String,
        subtitle: String,
        icon: String,
        tint: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(tint.opacity(0.16))
                        .frame(width: 42, height: 42)

                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(tint)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(LocalizedStringKey(title))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)

                    Text(LocalizedStringKey(subtitle))
                        .font(.system(size: 13, weight: .light))
                        .foregroundStyle(.white.opacity(0.58))
                        .lineLimit(1)
                }

                Spacer()
            }

            content()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }

    private var plannerButton: some View {
        PremiumPrimaryButton(
            isEnabled: canCheckRequirements,
            isLoading: vm.isLoading,
            action: {
                expandedField = nil
                Task { await vm.checkRequirements() }
            }
        ) {
            Text(vm.isLoading ? "Checking…" : "Check requirements")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(canCheckRequirements ? .white : .white.opacity(0.35))

            if !vm.isLoading {
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(canCheckRequirements ? .white.opacity(0.85) : .white.opacity(0.30))
            }
        }
    }

    private func routePreviewCard(destination: String, nationality: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 36, height: 36)

                Image(systemName: "sparkles")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.84))
            }

            VStack(alignment: .leading, spacing: 3) {
                LText("Preview")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.46))

                Text("\(nationality) passport to \(destination)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.92))
            }

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.07), lineWidth: 1)
                )
        )
    }

    // MARK: - Recent Checks

    @ViewBuilder
    private var recentChecksSection: some View {
        if !vm.recentChecks.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                PremiumSectionHeader(
                    title: "Recent checks",
                    subtitle: "Quick access to your latest routes"
                )

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(vm.recentChecks.prefix(5)) { item in
                            recentCheckCard(item)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }
    }

    private func recentCheckCard(_ item: RecentRequirementCheck) -> some View {
        Button {
            expandedField = nil
            vm.applyRecentCheck(item)
        } label: {
            PremiumMiniCard(width: 220) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(item.routeText)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.92))

                    Text(item.subtitleText)
                        .font(.system(size: 12, weight: .light))
                        .foregroundStyle(.white.opacity(0.50))
                        .lineLimit(2)

                    LText("Use this check")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.72))
                }
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Message

    @ViewBuilder
    private var messageSection: some View {
        if let error = vm.errorMessage {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.14))
                        .frame(width: 38, height: 38)

                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(.red.opacity(0.90))
                }

                VStack(alignment: .leading, spacing: 3) {
                    LText("Something needs attention")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.red.opacity(0.90))

                    Text(error)
                        .font(.system(size: 13, weight: .light))
                        .foregroundStyle(.white.opacity(0.65))
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(2)
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.red.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(Color.red.opacity(0.16), lineWidth: 1)
                    )
            )
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var emptyStateSection: some View {
        if vm.visaResponse == nil && !vm.isLoading && vm.errorMessage == nil {
            PremiumEmptyStateCard(
                title: "Ready to check?",
                message: "Choose your route above to see entry rules,\npassport validity and official guidance."
            ) {
                Image(systemName: "globe.europe.africa.fill")
                    .font(.system(size: 30, weight: .light))
                    .foregroundStyle(.white.opacity(0.60))
            }
        }
    }

    @ViewBuilder
    private var resultSection: some View {
        if let result = vm.visaResponse {
            VStack(alignment: .leading, spacing: 16) {
                PremiumSectionHeader(
                    title: "Results",
                    subtitle: "Entry summary and official guidance"
                )

                readinessHero(result)
                saveActionCard
                checklistCard(result)
                linksCard(result)
                destinationInfoCard(result)
                noticeCard
            }
        }
    }

    private func readinessHero(_ result: VisaCheckResponse) -> some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: readinessGradient(result),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: heroShadowColor(result), radius: 18, x: 0, y: 10)

            VStack(alignment: .leading, spacing: 14) {
                PremiumStatusCapsule(text: badgeText(for: result))

                Text(LocalizedStringKey(readinessTitle(for: result)))
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .tracking(-0.6)
                    .foregroundStyle(.white)

                Text(LocalizedStringKey(readinessMessage(for: result)))
                    .font(.system(size: 14, weight: .light))
                    .foregroundStyle(.white.opacity(0.88))
                    .lineSpacing(2)

                Rectangle()
                    .fill(Color.white.opacity(0.18))
                    .frame(height: 1)

                VStack(spacing: 10) {
                    PremiumHeroInfoRow(title: "Destination", value: result.data.destination.name)
                    PremiumHeroInfoRow(title: "Passport", value: result.data.passport.name)
                    PremiumHeroInfoRow(title: "Validity", value: result.data.destination.passportValidity ?? "-")
                }
            }
            .padding(22)
        }
        .frame(maxWidth: .infinity, minHeight: 220)
    }

    private var saveActionCard: some View {
        PremiumContentCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill((isRequirementAlreadySaved ? Color.green : brandColor).opacity(0.14))
                            .frame(width: 34, height: 34)

                        Image(systemName: isRequirementAlreadySaved ? "bookmark.fill" : "bookmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(isRequirementAlreadySaved ? .green : brandColor)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        LText("Save check")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)

                        LText(isRequirementAlreadySaved ? "Already in Trips" : "Keep this result for later")
                            .font(.system(size: 12, weight: .light))
                            .foregroundStyle(isRequirementAlreadySaved ? .green : .white.opacity(0.56))
                    }

                    Spacer()
                }

                Button {
                    saveRequirementCheck()
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(
                                isRequirementAlreadySaved
                                ? LinearGradient(colors: [Color.green, Color.teal], startPoint: .leading, endPoint: .trailing)
                                : LinearGradient(
                                    colors: [PremiumPalette.accentBlue, PremiumPalette.accentBlueLight],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )

                        LText(isRequirementAlreadySaved ? "Saved" : "Save to Trips")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.vertical, 16)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(ScaleButtonStyle())
                .disabled(isRequirementAlreadySaved)
            }
        }
    }

    private func checklistCard(_ result: VisaCheckResponse) -> some View {
        infoCard(
            title: "Travel checklist",
            subtitle: "The essentials to review before departure",
            symbol: "checkmark.square.fill"
        ) {
            checklistItem(
                title: "Passport validity",
                detail: result.data.destination.passportValidity ?? "Review passport validity requirement",
                state: checklistState(from: result.data.visaRules.primaryRule.color, defaultState: .required)
            )

            checklistItem(
                title: "Main rule",
                detail: result.data.visaRules.primaryRule.name ?? "Review main requirement",
                state: checklistState(from: result.data.visaRules.primaryRule.color, defaultState: .required)
            )

            checklistItem(
                title: "Allowed stay",
                detail: result.data.visaRules.primaryRule.duration ?? "Check allowed stay duration",
                state: .info
            )

            if let registration = result.data.mandatoryRegistration {
                checklistItem(
                    title: "Extra registration",
                    detail: registration.name ?? "Additional registration may be needed",
                    state: checklistState(from: registration.color, defaultState: .required)
                )
            }

            checklistItem(
                title: "Official sources",
                detail: "Review official links before departure",
                state: .info,
                isLast: true
            )
        }
    }

    private func checklistItem(title: String, detail: String, state: ChecklistState, isLast: Bool = false) -> some View {
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
                        Text(LocalizedStringKey(title))
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

                    Text(LocalizedStringKey(detail))
                        .font(.system(size: 13, weight: .light))
                        .foregroundStyle(.white.opacity(0.62))
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(1.5)
                }

                Spacer()
            }
            .padding(.vertical, 10)

            if !isLast {
                PremiumDivider()
            }
        }
    }

    private func linksCard(_ result: VisaCheckResponse) -> some View {
        infoCard(
            title: "Official links",
            subtitle: "Useful sources for rules and embassy information",
            symbol: "link"
        ) {
            if let primary = result.data.visaRules.primaryRule.link, !primary.isEmpty {
                linkLine("Main rule", primary)
            }

            if let secondary = result.data.visaRules.secondaryRule?.link, !secondary.isEmpty {
                PremiumDivider()
                linkLine("Alternative option", secondary)
            }

            if let embassy = result.data.destination.embassyURL, !embassy.isEmpty {
                PremiumDivider()
                linkLine("Embassy / official info", embassy)
            }
        }
    }

    private func destinationInfoCard(_ result: VisaCheckResponse) -> some View {
        infoCard(
            title: "Destination information",
            subtitle: "Useful destination details",
            symbol: "globe.europe.africa.fill"
        ) {
            PremiumInfoRow(title: "Destination", value: result.data.destination.name)
            PremiumInfoRow(title: "Passport", value: result.data.passport.name)
            PremiumInfoRow(title: "Capital", value: result.data.destination.capital ?? "-")
            PremiumInfoRow(title: "Currency", value: currencyText(result))
            PremiumInfoRow(title: "Timezone", value: result.data.destination.timezone ?? "-")
        }
    }

    private var noticeCard: some View {
        PremiumContentCard {
            VStack(alignment: .leading, spacing: 10) {
                Label { LText("Important notice") } icon: { Image(systemName: "info.circle.fill") }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)

                LText("Always confirm final boarding, visa, and entry rules with your airline and official government sources before departure.")
                    .font(.system(size: 13, weight: .light))
                    .foregroundStyle(.white.opacity(0.60))
                    .lineSpacing(1.5)
            }
        }
    }

    private func infoCard<Content: View>(
        title: String,
        subtitle: String,
        symbol: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        PremiumContentCard {
            VStack(alignment: .leading, spacing: 16) {
                PremiumIconHeader(
                    title: title,
                    subtitle: subtitle,
                    symbol: symbol
                )

                VStack(spacing: 12) {
                    content()
                }
            }
        }
    }

    // MARK: - Helpers

    private func linkLine(_ title: String, _ urlString: String) -> some View {
        HStack(alignment: .top) {
            Text(LocalizedStringKey(title))
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.90))

            Spacer()

            if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
                Link(destination: url) {
                    HStack(spacing: 6) {
                        LText("Open")
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                }
            } else {
                Text(urlString)
                    .font(.system(size: 13, weight: .light))
                    .foregroundStyle(.white.opacity(0.62))
                    .multilineTextAlignment(.trailing)
            }
        }
    }

    private func applyPendingRequirementCheckIfNeeded() {
        let item = router.consumePendingRequirementCheck()
        let shouldAutoRun = router.consumeShouldAutoRunRequirementCheck()

        guard let item else { return }

        expandedField = nil
        vm.applyRecentCheck(item)

        if shouldAutoRun {
            Task { await vm.checkRequirements() }
        }
    }

    private func saveRequirementCheck() {
        guard vm.visaResponse != nil, !isRequirementAlreadySaved else { return }

        let trip = SavedTrip(
            type: "requirement",
            title: requirementTripTitle,
            subtitle: requirementTripSubtitle,
            route: requirementTripRoute,
            summary: requirementTripSummary
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

    private func resetSelections() {
        expandedField = nil
        vm.origin = nil
        vm.destination = nil
        vm.nationality = nil
        vm.errorMessage = nil
        vm.visaResponse = nil
    }

    private func checklistState(from raw: String?, defaultState: ChecklistState) -> ChecklistState {
        switch raw?.lowercased() {
        case "green": return .good
        case "orange": return .required
        case "red": return .warning
        case "blue": return .info
        default: return defaultState
        }
    }

    private func readinessGradient(_ result: VisaCheckResponse) -> [Color] {
        switch result.data.visaRules.primaryRule.color?.lowercased() {
        case "green":
            return [Color.green.opacity(0.80), Color.teal.opacity(0.90)]
        case "orange":
            return [Color.orange.opacity(0.90), Color.yellow.opacity(0.80)]
        case "red":
            return [Color.red.opacity(0.85), Color.pink.opacity(0.75)]
        default:
            return [PremiumPalette.accentBlue, PremiumPalette.accentBlueLight]
        }
    }

    private func heroShadowColor(_ result: VisaCheckResponse) -> Color {
        switch result.data.visaRules.primaryRule.color?.lowercased() {
        case "green": return .green.opacity(0.18)
        case "orange": return .orange.opacity(0.20)
        case "red": return .red.opacity(0.18)
        default: return .blue.opacity(0.18)
        }
    }

    private func readinessTitle(for result: VisaCheckResponse) -> String {
        switch result.data.visaRules.primaryRule.color?.lowercased() {
        case "green": return "Ready to prepare"
        case "orange": return "Additional documents required"
        case "red": return "High attention required"
        default: return "Travel guidance"
        }
    }

    private func badgeText(for result: VisaCheckResponse) -> String {
        result.data.visaRules.primaryRule.name ?? "Unknown"
    }

    private func readinessMessage(for result: VisaCheckResponse) -> String {
        switch result.data.visaRules.primaryRule.color?.lowercased() {
        case "green":
            return "Your route appears straightforward, but you should still review the listed requirements before travelling."
        case "orange":
            return "Additional documents or approvals may be required before departure."
        case "red":
            return "This trip may require special preparation before travel. Review the official guidance carefully."
        default:
            return "Review the information below to understand what may be required before travel."
        }
    }

    private func currencyText(_ result: VisaCheckResponse) -> String {
        let currency = result.data.destination.currency ?? "-"
        let code = result.data.destination.currencyCode ?? "-"
        if currency == "-" && code == "-" { return "-" }
        if code == "-" { return currency }
        if currency == "-" { return code }
        return "\(currency) (\(code))"
    }

    private var brandColor: Color {
        PremiumPalette.accentBlue
    }
}

private enum ChecklistState {
    case good
    case required
    case warning
    case optional
    case info

    var icon: String {
        switch self {
        case .good: return "checkmark"
        case .required: return "exclamationmark"
        case .warning: return "xmark"
        case .optional: return "plus"
        case .info: return "info"
        }
    }

    var label: String {
        switch self {
        case .good: return "Good"
        case .required: return "Required"
        case .warning: return "Review"
        case .optional: return "Optional"
        case .info: return "Info"
        }
    }

    var foregroundColor: Color {
        switch self {
        case .good: return .green
        case .required: return .orange
        case .warning: return .red
        case .optional: return .blue
        case .info: return .indigo
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
        RequirementsScreen()
            .modelContainer(for: SavedTrip.self, inMemory: true)
            .environmentObject(AppRouter())
    }
}
