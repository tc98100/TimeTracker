//
//  NavigationMain.swift
//  TimeTracker
//
//  Created by Tony Chi on 10/2/21.
//

import SwiftUI

struct Navigation: View {
    @StateObject var activity = ActivityInitialiser()
    var body: some View {
        TabView {
            Home()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .animation(.spring())
            ActivityOverview()
                .tabItem {
                    Image(systemName: "list.star")
                    Text("Activity")
                }
                .animation(.spring())
            Settings()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Me")
                }
                .animation(.spring())
        }
        .environmentObject(activity)
    
    }
}

struct Navigation_Previews: PreviewProvider {
    static var previews: some View {
        Navigation()
    }
}
