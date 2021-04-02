//
//  Settings.swift
//  TimeTracker
//
//  Created by Tony Chi on 10/2/21.
//

import SwiftUI
import StoreKit

struct Settings: View {
    var body: some View {
        NavigationView {
            SettingContent()
                .navigationBarTitle("", displayMode: .inline)
                .toolbar(content: {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Text("Info & Settings")
                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                            .bold()
                    }
                })
        }
    }
}

struct SettingContent: View {
    @EnvironmentObject var observedActivities: ActivityInitialiser
    @State private var isSettingSheetUp = false
    @State private var isAlertSheetUp = false
    @State private var startOfTheWeek = UserDefaults.standard.string(forKey: "startOfTheWeek") ?? "None"
    @State private var usingDays = UserDefaults.standard.integer(forKey: "usingDays")
    @State private var message = ""
    
    func canViewWeeklySummary() -> Bool {
        let today = Calendar.current.dateComponents([.weekday], from: Date())
        let summaryDay = SettingHelper.calculateWeeklySummaryDay(day: startOfTheWeek)
        if today.weekday == summaryDay {
            return true
        }
        return false
    }
    
    var body: some View {
        GeometryReader { geometry in
            let boxWidth = geometry.size.width/2
            let boxHeight = geometry.size.height/4
            let textSize = geometry.size.width * 0.037
            
            VStack {
                HStack {
                    Text("⏳")
                        .font(.system(size: geometry.size.width * 0.1))
                    VStack {
                        Text("You have been recording")
                        if usingDays == 1 {
                            Text("activities for \(usingDays) day")
                        } else {
                            Text("activities for \(usingDays) days")
                        }
                    }
                    .font(Font.custom("Chalkduster", size: geometry.size.width * 0.05))
                }
                .multilineTextAlignment(.center)
                .frame(width: geometry.size.width * 0.98, height: geometry.size.height/4)
                .onAppear {
                    usingDays = UserDefaults.standard.integer(forKey: "usingDays")
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    usingDays = UserDefaults.standard.integer(forKey: "usingDays")
                }
                Divider()
                HStack {
                    if observedActivities.getActivities().count == 0 || !canViewWeeklySummary() {
                        Button(action: {
                            if observedActivities.getActivities().count == 0 {
                                message = "You don't have any activities"
                            } else if !canViewWeeklySummary() {
                                message = "You can only see your weekly summary the day before the start of the next week. You can set it in \"Settings\""
                            }
                            isAlertSheetUp = true
                        }, label: {
                            BoxContent(image: ("list.bullet.rectangle", Color(red: 141/255, green: 160/255, blue: 119/255)) , text: "Weekly summary", width: boxWidth, left: true, textSize: textSize)
                        })
                        
                    } else {
                        NavigationLink(destination: WeeklySummary()) {
                            BoxContent(image: ("list.bullet.rectangle", Color(red: 141/255, green: 160/255, blue: 119/255)) , text: "Weekly summary", width: boxWidth, left: true, textSize: textSize)
                        }
                    }
                    Divider()
                    Button(action: {
                        isSettingSheetUp = true
                    }, label: {
                        BoxContent(image: ("gearshape.fill", Color(red: 124/255, green: 171/255, blue: 177/255)), text: "Settings", width: boxWidth, left: false, textSize: textSize)
                    })
                }
                .frame(height: boxHeight)
                .sheet(isPresented: $isSettingSheetUp) {
                    GeneralSetting(isSheetUp: $isSettingSheetUp)
                }
                Divider()
                HStack {
                    Button(action: {
                        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                            SKStoreReviewController.requestReview(in: scene)
                        }
                    }, label: {
                        BoxContent(image: ("hand.thumbsup.fill", Color(red: 120/255, green: 146/255, blue: 98/255)), secondImage: ("hand.thumbsdown.fill", Color(red: 204/255, green: 53/255, blue: 54/255)), text: "Rate this app", width: boxWidth, left: true, textSize: textSize)
                    })
                    Divider()
                    NavigationLink(destination: Help()) {
                        BoxContent(image: ("questionmark.circle.fill", Color(red: 185/255, green: 152/255, blue: 116/255)), text: "Help", width: boxWidth, left: false, textSize: textSize)
                    }
                }
                .frame(height: boxHeight)
                Divider()
            }
            .alert(isPresented: $isAlertSheetUp) {
                Alert(title: Text("Alert"), message: Text(message), dismissButton: .default(Text("ok")))
            }
        }
    }
}

struct BoxContent: View {
    var image: (String, Color)
    var secondImage: (String, Color)?
    var text: String
    var width: CGFloat
    var left: Bool
    var textSize: CGFloat
    
    var body: some View {
        VStack {
            if secondImage != nil {
                HStack {
                    Image(systemName: image.0)
                        .foregroundColor(image.1)
                    Image(systemName: secondImage!.0)
                        .foregroundColor(secondImage!.1)
                }
                .font(.largeTitle)
                .padding(.bottom, 2.0)
            } else {
                Image(systemName: image.0)
                    .foregroundColor(image.1)
                    .font(.largeTitle)
                    .padding(.bottom, 2.0)
            }
            Text(text)
                .font(.system(size: textSize))
                .foregroundColor(Color(red: 143/255, green: 152/255, blue: 156/255))
                .frame(width: 125)
        }
        .multilineTextAlignment(.center)
        .padding(left ? .leading : .trailing)
        .frame(width: width)
    }
}



struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
            .environmentObject(ActivityInitialiser())
    }
}


