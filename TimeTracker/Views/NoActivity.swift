//
//  NoActivity.swift
//  TimeTracker
//
//  Created by Tony Chi on 18/2/21.
//

import SwiftUI

struct NoActivity: View {
    @State var isAdderClicked = false
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("No activity yet, start by adding a new one")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
                Button(action: {
                    isAdderClicked = true
                }, label: {
                    Text("Add a new activity")
                })
                
            }
            .sheet(isPresented: $isAdderClicked) {
                ActivityAdder(isSheetUp: $isAdderClicked, callingAdder: true)
            }
            .frame(width: geometry.size.width, height: 400, alignment: .center)
            .offset(x: 0, y: geometry.size.height * 0.12)
        }
    }
}
