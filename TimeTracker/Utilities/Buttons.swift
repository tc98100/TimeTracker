//
//  Buttons.swift
//  TimeTracker
//
//  Created by Tony Chi on 3/3/21.
//

import SwiftUI

struct NeumorphicButton: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(10)
            .background(
                Group {
                    if configuration.isPressed {
                        Circle()
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: -5, y: -5)
                            .shadow(color: Color.white.opacity(0.7), radius: 5, x: 5, y: 5)
                    } else {
                        Circle()
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 5, y: 5)
                            .shadow(color: Color.white.opacity(0.7), radius: 5, x: -5, y: -5)
                    }
                }
            )
    }
}
