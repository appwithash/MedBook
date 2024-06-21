//
//  ButtonStyles.swift
//  MedBook
//
//  Created by ashutosh on 20/06/24.
//

import SwiftUI


extension ButtonStyle where Self == SolidButtonStyle {
    static var solid : Self {
        return .init()
    }
}


struct SolidButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool
    func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding(.vertical)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .background(configuration.isPressed ? Color.blue.opacity(0.9) : Color.blue)
                .opacity(isEnabled ? 1 : 0.5)
                .cornerRadius(8)
    }
}


extension ButtonStyle where Self == StrokeButtonStyle {
    static var stroke : Self {
        return .init()
    }
}


struct StrokeButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool
    func makeBody(configuration: Configuration) -> some View {
            configuration.label
            .padding(.vertical)
            .foregroundStyle(configuration.isPressed ? Color.blue.opacity(0.9) : Color.blue)
            .frame(maxWidth: .infinity)
            .opacity(isEnabled ? 1 : 0.5)
            .overlay(
                RoundedRectangle(cornerRadius: 8).strokeBorder(configuration.isPressed ? Color.blue.opacity(0.8) : Color.blue,lineWidth: 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: 8))
    }
}
