//
//  FirstTime.swift
//  TimeTracker
//
//  Created by Tony Chi on 5/3/21.
//

import SwiftUI

struct IntroSettingBox: View {
    var body: some View {
        let color = Color(red: 216/255, green: 227/255, blue: 223/255)
        Rectangle()
            .cornerRadius(25.0)
            .foregroundColor(color)
            .shadow(color: color ,radius: 20)
    }
}

struct FirstTime: View {
//    @Binding var toMainView: Bool
    @State private var notificationEnabled = true
    @State private var notificationTime = UserDefaults.standard.object(forKey: "notificationTime") as? Date ?? Date()
    @State private var weeklySummaryTime = UserDefaults.standard.object(forKey: "weeklySummaryTime") as? Date ?? Date()
    @State var notFirstTime = UserDefaults.standard.bool(forKey: "notFirstTime")
    @State var valueDidChange = false
    
    var body: some View {
        GeometryReader { geometry in
            let boxWidth = geometry.size.width * 0.8
            let boxHeight = geometry.size.height * 0.08
            let textWidth = geometry.size.width/2.1
            let textFontSize = geometry.size.width/23
            let paddingSize = geometry.size.width/30
            
            VStack(spacing: 30.0) {
                Text("Settings")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 20.0)
                ZStack {
                    IntroSettingBox()
                    NotificationToggle(icon: "🔔", textSize: textFontSize, textWidth: textWidth, paddingSize: paddingSize, notificationEnabled: $notificationEnabled, valueDidChange: $valueDidChange, notFirstTime: $notFirstTime)
                }
                .frame(width: boxWidth, height: boxHeight)
                ZStack {
                    IntroSettingBox()
                    TimePicker(icon: "⏰", iconSize: textFontSize + 4, text: "Reminder time", textSize: textFontSize, textWidth: textWidth, paddingSize: paddingSize, time: $notificationTime)
                }
                .frame(width: boxWidth, height: boxHeight)
                ZStack {
                    IntroSettingBox()
                    TimePicker(icon: "🕰", iconSize: textFontSize + 4, text: "Weekly Summary time", textSize: textFontSize, textWidth: textWidth, paddingSize: paddingSize, time: $weeklySummaryTime)
                }
                .frame(width: boxWidth, height: boxHeight)
                
                Button(action: {
        //            toMainView = true
                    UserDefaults.standard.set(true, forKey: "notFirstTimeUsing")
                    UserDefaults.standard.set(Date(), forKey: "lastUseTime")
                    UserDefaults.standard.set(1, forKey: "usingDays")
                }, label: {
                    Text("Start your Journey")
                })
                .padding()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

struct FirstTime_Previews: PreviewProvider {
    static var previews: some View {
        FirstTime()
    }
}
