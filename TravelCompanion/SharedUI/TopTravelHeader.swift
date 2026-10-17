//
//  TopTravelHeader.swift
//  TravelCompanion
//
//  Created by User on 4/18/26.
//

import SwiftUI

struct TopTravelHeader: View {
    let title: String
    let color: Color

    var showsRunway: Bool = true
    var parksPlaneAtEnd: Bool = true
    var animationDuration: Double = 8.4
    var titleFontSize: CGFloat = 23
    var planeWidth: CGFloat = 40
    var parkedGap: CGFloat = 18

    @State private var planeProgress: CGFloat = 0
    @State private var didAnimate = false
    @State private var showAnimatedPlane = true
    @State private var showParkedPlane = false

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let headerCenterX = width / 2
            let titleWidth = measuredTitleWidth(for: title, fontSize: titleFontSize)
            let parkedPlaneX = parkedPlanePosition(
                headerCenterX: headerCenterX,
                titleWidth: titleWidth,
                planeWidth: planeWidth,
                parkedGap: parkedGap,
                totalWidth: width
            )

            let runwayY: CGFloat = 38
            let titleY: CGFloat = 15
            let finalPlaneLift = runwayY - titleY

            let x = planeXPosition(progress: planeProgress, endX: parkedPlaneX)
            let lift = planeLift(for: planeProgress, finalY: finalPlaneLift)
            let pitch = planePitch(for: planeProgress)
            let scale = planeScale(for: planeProgress)
            let shadowOpacity = planeShadowOpacity(for: planeProgress)

            ZStack {
                if showsRunway && showAnimatedPlane {
                    runway(width: width - 32)
                        .position(x: width / 2, y: runwayY)

                    runwayLights(width: width - 32)
                        .position(x: width / 2, y: runwayY + 4)

                    takeoffTrail(lift: lift)
                        .position(x: x - 18, y: runwayY - lift)

                    CommercialPlaneView(color: .black.opacity(shadowOpacity))
                        .blur(radius: 0.8)
                        .scaleEffect(scale * 0.985)
                        .scaleEffect(y: max(0.80, 0.94 - (lift * 0.008)))
                        .position(x: x + 1.5, y: runwayY + 2.5)

                    CommercialPlaneView(color: color)
                        .scaleEffect(scale)
                        .rotationEffect(.degrees(pitch), anchor: UnitPoint(x: 0.25, y: 0.7))
                        .position(x: x, y: runwayY - lift)
                }

                LText(title)
                    .font(.system(size: titleFontSize, weight: .bold))
                    .tracking(-0.35)
                    .foregroundStyle(color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
                    .position(x: headerCenterX, y: titleY)

                if parksPlaneAtEnd && showParkedPlane {
                    CommercialPlaneLogoView(
                        color: color,
                        size: CGSize(width: planeWidth, height: 18),
                        scale: 0.74,
                        rotation: -7
                    )
                    .position(x: parkedPlaneX, y: titleY)
                    .transition(.opacity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: 52)
        .allowsHitTesting(false)
        .onAppear {
            guard !didAnimate else { return }
            didAnimate = true
            runOneTimeAnimation()
        }
    }

    // MARK: - Layout

    private func measuredTitleWidth(for title: String, fontSize: CGFloat) -> CGFloat {
        let font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        let attrs: [NSAttributedString.Key: Any] = [.font: font]
        let baseWidth = (title as NSString).size(withAttributes: attrs).width
        return ceil(baseWidth) - 4
    }

    private func parkedPlanePosition(
        headerCenterX: CGFloat,
        titleWidth: CGFloat,
        planeWidth: CGFloat,
        parkedGap: CGFloat,
        totalWidth: CGFloat
    ) -> CGFloat {
        let preferred = headerCenterX + (titleWidth / 2) + parkedGap + (planeWidth / 2)
        let safeMax = totalWidth - 26
        return min(preferred, safeMax)
    }

    private func planeXPosition(progress: CGFloat, endX: CGFloat) -> CGFloat {
        let clamped = max(0, min(1, progress))
        return -36 + ((endX + 36) * clamped)
    }

    // MARK: - Runway

    private func runway(width: CGFloat) -> some View {
        ZStack {
            Capsule()
                .fill(Color.white.opacity(0.08))
                .frame(width: width, height: 6)

            HStack(spacing: 8) {
                ForEach(0..<18, id: \.self) { _ in
                    Capsule()
                        .fill(Color.white.opacity(0.62))
                        .frame(width: 9, height: 1.2)
                }
            }
            .frame(width: width - 20)
        }
    }

    private func runwayLights(width: CGFloat) -> some View {
        HStack(spacing: 12) {
            ForEach(0..<18, id: \.self) { _ in
                Circle()
                    .fill(Color.white.opacity(0.10))
                    .frame(width: 2.2, height: 2.2)
            }
        }
        .frame(width: width - 10)
    }

    private func takeoffTrail(lift: CGFloat) -> some View {
        Capsule()
            .fill(
                LinearGradient(
                    colors: [
                        Color.clear,
                        color.opacity(lift > 2 ? 0.11 : 0.06)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: lift > 3 ? 24 : 16, height: 1.1)
    }

    // MARK: - Animation Curves

    private func planeLift(for progress: CGFloat, finalY: CGFloat) -> CGFloat {
        let t = max(0, min(1, progress))
        if t < 0.76 { return 0 }
        let normalized = (t - 0.76) / 0.24
        return pow(normalized, 1.65) * finalY
    }

    private func planePitch(for progress: CGFloat) -> Double {
        let t = max(0, min(1, progress))
        if t < 0.70 { return 0 }
        if t < 0.86 {
            let normalized = (t - 0.70) / 0.16
            return normalized * -7
        }
        return -7
    }

    private func planeScale(for progress: CGFloat) -> CGFloat {
        let t = max(0, min(1, progress))
        if t < 0.55 { return 0.88 }
        if t < 0.80 {
            let normalized = (t - 0.55) / 0.25
            return 0.88 + (normalized * 0.03)
        }
        return 0.91
    }

    private func planeShadowOpacity(for progress: CGFloat) -> Double {
        let t = max(0, min(1, progress))
        if t < 0.80 { return 0.10 }
        let normalized = (t - 0.80) / 0.20
        return max(0.03, 0.10 - (normalized * 0.06))
    }

    // MARK: - One-time Animation

    private func runOneTimeAnimation() {
        planeProgress = 0
        showAnimatedPlane = true
        showParkedPlane = false

        withAnimation(.linear(duration: animationDuration)) {
            planeProgress = 1
        }

        guard parksPlaneAtEnd else {
            DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                withAnimation(.easeOut(duration: 0.18)) {
                    showAnimatedPlane = false
                }
            }
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + max(0.1, animationDuration - 0.25)) {
            withAnimation(.easeOut(duration: 0.18)) {
                showAnimatedPlane = false
                showParkedPlane = true
            }
        }
    }
}
