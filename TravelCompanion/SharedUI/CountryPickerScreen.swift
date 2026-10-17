//
//  CountryPickerScreen.swift
//  TravelCompanion
//
//  Created by User on 3/10/26.
//

import SwiftUI

struct CountryPickerScreen: View {
    @SwiftUI.Environment(\.dismiss) private var dismiss: DismissAction
    @Binding var selectedCountry: Country?
    @State private var searchText = ""

    private let suggestedCountryCodes = ["DE", "US", "GB", "FR", "ET", "TR", "AE"]

    private var filteredCountries: [Country] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        if query.isEmpty {
            return CountryData.countries
        }

        return CountryData.countries.filter {
            $0.name.lowercased().contains(query) ||
            $0.code.lowercased().contains(query)
        }
    }

    private var suggestedCountries: [Country] {
        CountryData.countries.filter { suggestedCountryCodes.contains($0.code) }
    }

    private var showSuggestedSection: Bool {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack {
            backgroundView

            VStack(spacing: 18) {
                topHeader

                if filteredCountries.isEmpty {
                    emptyStateView
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 22) {
                            if showSuggestedSection {
                                countrySection(
                                    title: "Popular Countries",
                                    subtitle: "Quick picks for faster selection",
                                    countries: suggestedCountries
                                )
                            }

                            countrySection(
                                title: showSuggestedSection ? "All Countries" : "Search Results",
                                subtitle: showSuggestedSection ? "Browse the full country list" : "Results matching your search",
                                countries: filteredCountries
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .navigationTitle("Select Country")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "Search country or code")
    }

    private var backgroundView: some View {
        LinearGradient(
            colors: [
                Color(uiColor: .systemGroupedBackground),
                Color.blue.opacity(0.03),
                Color.indigo.opacity(0.02),
                Color(uiColor: .secondarySystemGroupedBackground)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var topHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                headerTag("Country")
                headerTag("Code")
                headerTag("Quick Search")
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Pick a country")
                    .font(.system(size: 28, weight: .bold))
                    .tracking(-0.3)

                Text("Search by country name or 2-letter code like DE, ET, or US.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    private func countrySection(title: String, subtitle: String, countries: [Country]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(LocalizedStringKey(title))
                    .font(.title3.weight(.bold))

                Text(LocalizedStringKey(subtitle))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 12) {
                ForEach(countries) { country in
                    countryCard(country)
                }
            }
        }
    }

    private func countryCard(_ country: Country) -> some View {
        Button {
            selectedCountry = country
            dismiss()
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.blue.opacity(0.10))
                        .frame(width: 50, height: 50)

                    Text(country.code)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.blue)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(country.name)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text("Country code: \(country.code)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if selectedCountry == country {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.12))
                            .frame(width: 30, height: 30)

                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.blue)
                    }
                } else {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(uiColor: .secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.85), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(.plain)
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.10))
                    .frame(width: 84, height: 84)

                Image(systemName: "globe.europe.africa.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(.blue)
            }

            Text("No country found")
                .font(.title3.weight(.bold))

            Text("Try searching by full country name or a 2-letter code like DE or ET.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 28)

            Spacer()
        }
        .padding(.horizontal, 20)
    }

    private func headerTag(_ text: String) -> some View {
        Text(LocalizedStringKey(text))
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(Capsule())
            .overlay(
                Capsule().strokeBorder(Color.white.opacity(0.85), lineWidth: 1)
            )
    }
}
