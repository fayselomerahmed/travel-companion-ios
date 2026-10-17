//
//  CountryDropdownField.swift
//  TravelCompanion
//
//  Created by User on 4/1/26.
//

import SwiftUI

struct CountryDropdownField: View {
    let title: String
    let icon: String
    @Binding var selectedCountry: Country?
    @Binding var expandedField: String?
    let fieldID: String
    @SwiftUI.Environment(\.colorScheme) private var colorScheme

    @State private var inputText: String = ""

    private var isActive: Bool {
        expandedField == fieldID
    }

    private var query: String {
        inputText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private var filteredCountries: [Country] {
        if query.isEmpty {
            return CountryData.countries
        }

        return CountryData.countries.filter {
            $0.name.lowercased().contains(query) ||
            $0.code.lowercased().contains(query)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            selectorRow

            if isActive {
                dropdownPanel
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .onAppear {
            inputText = selectedCountry?.name ?? ""
        }
        .onChange(of: selectedCountry?.name) { _, newValue in
            if !isActive {
                inputText = newValue ?? ""
            }
        }
        .animation(.easeInOut(duration: 0.18), value: isActive)
    }

    private var selectorRow: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(isActive ? brandColor : .secondary)
                .frame(width: 18)

            VStack(alignment: .leading, spacing: 3) {
                Text(LocalizedStringKey(title))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                TextField("Search or select", text: $inputText) { editing in
                    if editing {
                        expandedField = fieldID
                    }
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .submitLabel(.done)
                .onTapGesture {
                    expandedField = fieldID
                }
                .onChange(of: inputText) { _, newValue in
                    expandedField = fieldID

                    if newValue.isEmpty {
                        selectedCountry = nil
                    } else if selectedCountry?.name != newValue {
                        selectedCountry = nil
                    }
                }
            }

            Spacer(minLength: 8)

            Button {
                expandedField = isActive ? nil : fieldID
            } label: {
                Image(systemName: isActive ? "chevron.up" : "chevron.down")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(fieldFillColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(
                    isActive ? brandColor.opacity(colorScheme == .dark ? 0.42 : 0.22) : fieldStrokeColor,
                    lineWidth: 1
                )
        )
        .shadow(
            color: isActive ? brandColor.opacity(colorScheme == .dark ? 0.14 : 0.08) : .clear,
            radius: 10,
            x: 0,
            y: 4
        )
    }

    private var dropdownPanel: some View {
        VStack(spacing: 0) {
            if filteredCountries.isEmpty {
                emptyState
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(filteredCountries.prefix(12).enumerated()), id: \.element.id) { index, country in
                            suggestionRow(country)

                            if index < min(filteredCountries.count, 12) - 1 {
                                Divider()
                                    .overlay(dividerColor)
                                    .padding(.leading, 14)
                            }
                        }
                    }
                }
                .frame(maxHeight: 240)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(panelFillColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(panelStrokeColor, lineWidth: 1)
        )
        .shadow(
            color: Color.black.opacity(colorScheme == .dark ? 0.20 : 0.05),
            radius: 12,
            x: 0,
            y: 5
        )
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "globe.europe.africa")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.secondary)

            Text("No country found")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)

            Text("Try another name or code.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 16)
    }

    private func suggestionRow(_ country: Country) -> some View {
        let isSelected = selectedCountry?.code == country.code

        return Button {
            selectedCountry = country
            inputText = country.name
            expandedField = nil
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(country.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)

                    Text(country.code)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(brandColor)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .contentShape(Rectangle())
            .background(
                isSelected
                ? brandColor.opacity(colorScheme == .dark ? 0.16 : 0.06)
                : Color.clear
            )
        }
        .buttonStyle(.plain)
    }

    private var brandColor: Color {
        Color(red: 0.10, green: 0.23, blue: 0.52)
    }

    private var fieldFillColor: Color {
        colorScheme == .dark
        ? Color.white.opacity(0.06)
        : Color.white.opacity(0.78)
    }

    private var fieldStrokeColor: Color {
        colorScheme == .dark
        ? Color.white.opacity(0.10)
        : Color.black.opacity(0.06)
    }

    private var panelFillColor: Color {
        colorScheme == .dark
        ? Color(red: 0.10, green: 0.12, blue: 0.16).opacity(0.96)
        : Color.white.opacity(0.96)
    }

    private var panelStrokeColor: Color {
        colorScheme == .dark
        ? Color.white.opacity(0.10)
        : Color.black.opacity(0.06)
    }

    private var dividerColor: Color {
        colorScheme == .dark
        ? Color.white.opacity(0.08)
        : Color.black.opacity(0.06)
    }
}

#Preview {
    CountryDropdownField(
        title: "From",
        icon: "airplane.departure",
        selectedCountry: .constant(Optional<Country>.none),
        expandedField: .constant(Optional<String>.none),
        fieldID: "origin"
    )
    .padding()
}
