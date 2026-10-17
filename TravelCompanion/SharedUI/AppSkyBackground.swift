//
//  AppSkyBackground.swift
//  TravelCompanion
//
//  Created by User on 4/5/26.
//

import SwiftUI

struct AppSkyBackground: View {
    @SwiftUI.Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            LinearGradient(
                colors: colorScheme == .dark
                ? [
                    Color(red: 0.07, green: 0.10, blue: 0.18),
                    Color(red: 0.10, green: 0.16, blue: 0.27),
                    Color(red: 0.16, green: 0.21, blue: 0.34),
                    Color(red: 0.22, green: 0.21, blue: 0.30)
                ]
                : [
                    Color(red: 0.54, green: 0.72, blue: 0.97),
                    Color(red: 0.73, green: 0.85, blue: 1.00),
                    Color(red: 0.92, green: 0.95, blue: 1.00),
                    Color(red: 0.99, green: 0.93, blue: 0.90)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.white.opacity(colorScheme == .dark ? 0.04 : 0.34))
                .frame(width: 320, height: 320)
                .blur(radius: 90)
                .offset(x: -110, y: -220)

            Circle()
                .fill(Color.blue.opacity(colorScheme == .dark ? 0.14 : 0.22))
                .frame(width: 360, height: 360)
                .blur(radius: 100)
                .offset(x: 170, y: -135)

            Circle()
                .fill(Color.cyan.opacity(colorScheme == .dark ? 0.08 : 0.12))
                .frame(width: 260, height: 260)
                .blur(radius: 95)
                .offset(x: -150, y: 160)

            Circle()
                .fill(Color.orange.opacity(colorScheme == .dark ? 0.03 : 0.08))
                .frame(width: 300, height: 300)
                .blur(radius: 100)
                .offset(x: 120, y: 320)
        }
    }
}

struct AppGlassCardModifier: ViewModifier {
    @SwiftUI.Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(colorScheme == .dark ? Color.white.opacity(0.08) : Color.white.opacity(0.84))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(colorScheme == .dark ? Color.white.opacity(0.08) : Color.white.opacity(0.74), lineWidth: 1)
                    )
                    .shadow(
                        color: .black.opacity(colorScheme == .dark ? 0.16 : 0.06),
                        radius: 10,
                        x: 0,
                        y: 6
                    )
            )
    }
}

extension View {
    func appGlassCard() -> some View {
        modifier(AppGlassCardModifier())
    }
}
