//
//  BrandNavigationBar.swift
//  TravelCompanion
//
//  Created by User on 4/3/26.
//
import SwiftUI

// MARK: - Navigation Chrome

private struct BrandNavigationChromeModifier: ViewModifier {
    @SwiftUIEnvironment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(colorScheme == .dark ? .dark : .light, for: .navigationBar)
    }
}

// MARK: - Brand Navigation Title

struct BrandNavigationBarModifier: ViewModifier {
    let title: String
    var titleColor: Color = .white
    var logoSize: CGSize = CGSize(width: 40, height: 18)
    var logoScale: CGFloat = 0.74
    var logoRotation: Double = -7

    func body(content: Content) -> some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .modifier(BrandNavigationChromeModifier())
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        Text(LocalizedStringKey(title))
                            .font(.system(size: 23, weight: .bold))
                            .tracking(-0.35)
                            .foregroundStyle(titleColor)
                            .lineLimit(1)
                            .minimumScaleFactor(0.9)

                        CommercialPlaneLogoView(
                            color: titleColor,
                            size: logoSize,
                            scale: logoScale,
                            rotation: logoRotation
                        )
                    }
                }
            }
    }
}

extension View {
    func brandNavigationTitle(
        _ title: String,
        titleColor: Color = .white,
        logoSize: CGSize = CGSize(width: 40, height: 18),
        logoScale: CGFloat = 0.74,
        logoRotation: Double = -7
    ) -> some View {
        modifier(
            BrandNavigationBarModifier(
                title: title,
                titleColor: titleColor,
                logoSize: logoSize,
                logoScale: logoScale,
                logoRotation: logoRotation
            )
        )
    }
}

// MARK: - Plane Logo Wrapper

struct CommercialPlaneLogoView: View {
    let color: Color
    var size: CGSize = CGSize(width: 40, height: 18)
    var scale: CGFloat = 0.74
    var rotation: Double = -7

    var body: some View {
        CommercialPlaneView(color: color)
            .frame(width: size.width, height: size.height)
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))
    }
}

// MARK: - Main Plane View

struct CommercialPlaneView: View {
    let color: Color
    var highlightColor: Color = .white

    var body: some View {
        ZStack {
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [color.opacity(0.96), color],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 42, height: 7)

            CommercialPlaneNose()
                .fill(color)
                .frame(width: 10, height: 8)
                .offset(x: 23)

            Rectangle()
                .fill(color)
                .frame(width: 5, height: 7)
                .offset(x: -18)

            CommercialPlaneTailFin()
                .fill(color.opacity(0.96))
                .frame(width: 10, height: 12)
                .offset(x: -20, y: -6)

            Capsule()
                .fill(color.opacity(0.92))
                .frame(width: 12, height: 2.6)
                .offset(x: -21, y: 2)

            CommercialPlaneWing()
                .fill(color.opacity(0.94))
                .frame(width: 18, height: 10)
                .offset(x: -2, y: 1)

            CommercialPlaneRearWing()
                .fill(color.opacity(0.90))
                .frame(width: 14, height: 7)
                .offset(x: -8, y: 4.5)

            RoundedRectangle(cornerRadius: 1.6, style: .continuous)
                .fill(color.opacity(0.88))
                .frame(width: 6, height: 3.6)
                .offset(x: -2, y: 6)

            RoundedRectangle(cornerRadius: 1.6, style: .continuous)
                .fill(color.opacity(0.88))
                .frame(width: 6, height: 3.6)
                .offset(x: 6, y: 5.6)

            Capsule()
                .fill(highlightColor.opacity(0.88))
                .frame(width: 5, height: 1.6)
                .offset(x: 16, y: -1)

            HStack(spacing: 2.4) {
                ForEach(0..<6, id: \.self) { _ in
                    Capsule()
                        .fill(highlightColor.opacity(0.80))
                        .frame(width: 2.2, height: 1.1)
                }
            }
            .offset(x: 0, y: -1.2)
        }
        .frame(width: 54, height: 24)
        .drawingGroup()
        .accessibilityHidden(true)
    }
}

// MARK: - Shapes

struct CommercialPlaneNose: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + rect.height * 0.15))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.midY),
            control: CGPoint(x: rect.maxX, y: rect.minY)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.maxY - rect.height * 0.15),
            control: CGPoint(x: rect.maxX, y: rect.maxY)
        )
        path.closeSubpath()
        return path
    }
}

struct CommercialPlaneTailFin: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + rect.width * 0.2, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.45, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct CommercialPlaneWing: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + rect.height * 0.4))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX * 0.72, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.18, y: rect.maxY * 0.72))
        path.closeSubpath()
        return path
    }
}

struct CommercialPlaneRearWing: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + rect.width * 0.1, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + rect.height * 0.18))
        path.addLine(to: CGPoint(x: rect.maxX * 0.72, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY * 0.55))
        path.closeSubpath()
        return path
    }
}
