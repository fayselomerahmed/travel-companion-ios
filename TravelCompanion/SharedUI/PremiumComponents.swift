//
//  PremiumComponents.swift
//  TravelCompanion
//
//  Created by User on 4/18/26.
//

import SwiftUI

// MARK: - Premium Tokens

enum PremiumPalette {
    static let midnight = Color(red: 0.03, green: 0.04, blue: 0.07)
    static let navy = Color(red: 0.09, green: 0.15, blue: 0.28)
    static let royal = Color(red: 0.15, green: 0.25, blue: 0.46)
    static let blue = Color(red: 0.22, green: 0.36, blue: 0.62)

    static let accentBlue = Color(red: 0.22, green: 0.46, blue: 0.90)
    static let accentBlueLight = Color(red: 0.40, green: 0.68, blue: 1.0)

    static let gold = Color(red: 0.83, green: 0.72, blue: 0.49)

    static let whiteSurface = Color.white.opacity(0.05)
    static let whiteSurfaceStrong = Color.white.opacity(0.08)
    static let whiteBorder = Color.white.opacity(0.08)
    static let whiteBorderSoft = Color.white.opacity(0.07)

    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.62)
    static let textTertiary = Color.white.opacity(0.46)
    static let textHint = Color.white.opacity(0.40)
}

// MARK: - Premium Background

struct PremiumBackgroundView: View {
    var imageName: String? = nil
    var imageOpacity: Double = 0.10
    var overlayOpacityTop: Double = 0.12
    var overlayOpacityBottom: Double = 0.10

    var body: some View {
        ZStack {
            PremiumPalette.midnight
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

            if let imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .opacity(imageOpacity)

                LinearGradient(
                    colors: [
                        Color.black.opacity(overlayOpacityTop),
                        Color.clear,
                        Color.black.opacity(overlayOpacityBottom)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
        }
    }
}

// MARK: - Premium Card Background

struct PremiumCardBackground: View {
    var cornerRadius: CGFloat = 26

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(PremiumPalette.whiteSurface)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(PremiumPalette.whiteBorder, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.22), radius: 14, x: 0, y: 8)
    }
}

// MARK: - Premium Content Card

struct PremiumContentCard<Content: View>: View {
    private let cornerRadius: CGFloat
    private let content: Content

    init(
        cornerRadius: CGFloat = 26,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .padding(20)
        .background(PremiumCardBackground(cornerRadius: cornerRadius))
    }
}

// MARK: - Premium Hero Card

struct PremiumHeroCard<BottomContent: View>: View {
    let tags: [String]
    let eyebrow: String
    let title: String
    let description: String

    var minHeight: CGFloat = 230
    private let bottomContent: BottomContent

    init(
        tags: [String],
        eyebrow: String,
        title: String,
        description: String,
        minHeight: CGFloat = 230,
        @ViewBuilder bottomContent: () -> BottomContent
    ) {
        self.tags = tags
        self.eyebrow = eyebrow
        self.title = title
        self.description = description
        self.minHeight = minHeight
        self.bottomContent = bottomContent()
    }

    var body: some View {
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

            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 7) {
                    ForEach(tags, id: \.self) { tag in
                        PremiumTag(text: tag)
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Rectangle()
                        .fill(PremiumPalette.gold.opacity(0.65))
                        .frame(width: 24, height: 1.5)
                        .cornerRadius(1)

                    LText(eyebrow)
                        .font(.system(size: 14, weight: .medium))
                        .tracking(0.2)
                        .foregroundStyle(.white.opacity(0.55))

                    LText(title)
                        .font(.system(size: 36, weight: .bold, design: .serif))
                        .tracking(-1.0)
                        .foregroundStyle(.white)
                        .lineSpacing(2)

                    LText(description)
                        .font(.system(size: 14, weight: .light))
                        .foregroundStyle(.white.opacity(0.64))
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(2)
                }

                bottomContent
            }
            .padding(24)
        }
        .frame(minHeight: minHeight)
    }
}

// MARK: - Premium Section Header

struct PremiumSectionHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Rectangle()
                .fill(PremiumPalette.gold.opacity(0.55))
                .frame(width: 24, height: 1.5)
                .cornerRadius(1)

            LText(title)
                .font(.system(size: 24, weight: .bold, design: .serif))
                .tracking(-0.4)
                .foregroundStyle(PremiumPalette.textPrimary)

            LText(subtitle)
                .font(.system(size: 12, weight: .light))
                .foregroundStyle(PremiumPalette.textHint)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Premium Tag

struct PremiumTag: View {
    let text: String

    var body: some View {
        LText(text)
            .font(.system(size: 10, weight: .semibold))
            .tracking(1.2)
            .foregroundStyle(Color.white.opacity(0.75))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.07))
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.09), lineWidth: 1)
            )
            .clipShape(Capsule())
    }
}

// MARK: - Premium Status Capsule

struct PremiumStatusCapsule: View {
    let text: String

    var body: some View {
        LText(text).textCase(.uppercase)
            .font(.system(size: 10, weight: .bold))
            .tracking(0.8)
            .padding(.horizontal, 11)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.14))
            .foregroundStyle(.white)
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.16), lineWidth: 1)
            )
            .clipShape(Capsule())
    }
}

// MARK: - Premium Icon Header

struct PremiumIconHeader: View {
    let title: String
    let subtitle: String
    let symbol: String

    var body: some View {
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
                    .foregroundStyle(PremiumPalette.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
    }
}

// MARK: - Premium Info Row

struct PremiumInfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .top) {
            LText(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.90))

            Spacer()

            Text(LocalizedStringKey(value))
                .font(.system(size: 13, weight: .light))
                .foregroundStyle(PremiumPalette.textSecondary)
                .multilineTextAlignment(.trailing)
        }
    }
}

// MARK: - Premium Hero Info Row

struct PremiumHeroInfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            LText(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.80))

            Spacer()

            Text(LocalizedStringKey(value))
                .font(.system(size: 13, weight: .light))
                .foregroundStyle(.white)
                .multilineTextAlignment(.trailing)
        }
    }
}

// MARK: - Premium Divider

struct PremiumDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.white.opacity(0.08))
            .frame(height: 1)
    }
}

// MARK: - Premium Primary Button

struct PremiumPrimaryButton<Label: View>: View {
    var isEnabled: Bool = true
    var isLoading: Bool = false
    var cornerRadius: CGFloat = 20
    var action: () -> Void
    @ViewBuilder var label: () -> Label

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: isEnabled
                            ? [PremiumPalette.accentBlue, PremiumPalette.accentBlueLight]
                            : [Color.white.opacity(0.10), Color.white.opacity(0.07)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                if isEnabled {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.10), .clear],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                }

                HStack(spacing: 10) {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(0.85)
                    }

                    label()
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 18)
            }
            .frame(maxWidth: .infinity)
            .shadow(
                color: isEnabled ? PremiumPalette.accentBlue.opacity(0.30) : .clear,
                radius: 16,
                x: 0,
                y: 8
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(!isEnabled)
    }
}

// MARK: - Premium Empty State Card

struct PremiumEmptyStateCard<Icon: View>: View {
    let title: String
    let message: String
    @ViewBuilder let icon: () -> Icon

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )

                icon()
            }

            VStack(spacing: 6) {
                LText(title)
                    .font(.system(size: 22, weight: .bold, design: .serif))
                    .tracking(-0.4)
                    .foregroundStyle(.white)

                LText(message)
                    .font(.system(size: 14, weight: .light))
                    .foregroundStyle(Color.white.opacity(0.52))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
        }
        .padding(.vertical, 36)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(Color.white.opacity(0.07), lineWidth: 1)
                )
        )
    }
}

// MARK: - Premium Mini Card

struct PremiumMiniCard<Content: View>: View {
    private let width: CGFloat?
    private let cornerRadius: CGFloat
    private let content: Content

    init(
        width: CGFloat? = nil,
        cornerRadius: CGFloat = 22,
        @ViewBuilder content: () -> Content
    ) {
        self.width = width
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .padding(16)
        .frame(width: width, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

// MARK: - Shared Button Style

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
