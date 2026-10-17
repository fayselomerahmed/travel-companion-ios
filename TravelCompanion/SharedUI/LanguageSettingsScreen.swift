//
//  LanguageSettingsScreen.swift
//  TravelCompanion
//
//  Created by Codex on 6/4/26.
//

import SwiftUI

struct LanguageSettingsScreen: View {
    @ObservedObject private var languageCenter = AppLanguageCenter.shared
    @State private var appeared = false

    private let contentMaxWidth: CGFloat = 440

    private var selectedLanguage: AppLanguage {
        languageCenter.selectedLanguage
    }

    var body: some View {
        ZStack(alignment: .top) {
            PremiumBackgroundView()

            TopTravelHeader(title: "Language", color: .white)
                .padding(.top, -8)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    PremiumContentCard {
                        PremiumIconHeader(
                            title: "App language",
                            subtitle: "Choose the language used across the app",
                            symbol: "globe.europe.africa.fill"
                        )

                        PremiumDivider()
                            .padding(.vertical, 16)

                        VStack(spacing: 10) {
                            ForEach(AppLanguage.allCases) { language in
                                languageRow(language)
                            }
                        }
                    }
                    .frame(maxWidth: contentMaxWidth)
                    .frame(maxWidth: .infinity)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 14)
                    .animation(.spring(response: 0.56, dampingFraction: 0.84), value: appeared)

                    LText("The app updates immediately after you choose a language.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.48))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: contentMaxWidth)
                        .padding(.horizontal, 18)
                }
                .padding(.horizontal, 20)
                .padding(.top, 92)
                .padding(.bottom, 44)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                appeared = true
            }
        }
    }

    private func languageRow(_ language: AppLanguage) -> some View {
        let isSelected = selectedLanguage == language

        return Button {
            withAnimation(.easeInOut(duration: 0.18)) {
                languageCenter.setLanguage(language)
            }
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isSelected ? PremiumPalette.gold.opacity(0.22) : Color.white.opacity(0.07))
                        .frame(width: 36, height: 36)

                    Image(systemName: isSelected ? "checkmark" : "globe")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(isSelected ? PremiumPalette.gold : .white.opacity(0.82))
                }

                VStack(alignment: .leading, spacing: 3) {
                    LText(language.displayNameKey)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)

                    Text(language.nativeName)
                        .font(.system(size: 12, weight: .light))
                        .foregroundStyle(.white.opacity(0.56))
                }

                Spacer()

                if isSelected {
                    LText("Selected")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(PremiumPalette.gold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(PremiumPalette.gold.opacity(0.12), in: Capsule())
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(isSelected ? Color.white.opacity(0.075) : Color.white.opacity(0.045))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(isSelected ? PremiumPalette.gold.opacity(0.22) : Color.white.opacity(0.08), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityLabel(Text(language.nativeName))
    }
}
