//
//  Notification.swift
//  TimeTracker
//
//  Created by Tony Chi on 6/3/21.
//

import SwiftUI
import UserNotifications

struct SettingHelper {
    static func openSettings() {
        if let bundleIdentifier = Bundle.main.bundleIdentifier, let appSettings = URL(string: UIApplication.openSettingsURLString + bundleIdentifier) {
            if UIApplication.shared.canOpenURL(appSettings) {
                UIApplication.shared.open(appSettings)
            }
        }
    }
    
    static func calculateWeeklySummaryDay(day: String) -> Int {
        switch day {
        case "Sunday":
            return 7
        case "Monday":
            return 1
        case "Tuesday":
            return 2
        case "Wednesday":
            return 3
        case "Thursday":
            return 4
        case "Friday":
            return 5
        case "Saturday":
            return 6
        default:
            return 7
        }
    }
}

struct GeneralSetting: View {
    @Binding var isSheetUp: Bool
    @State private var notificationEnabled = true
    @State private var notificationTime = UserDefaults.standard.object(forKey: "notificationTime") as? Date ?? Date()
    @State private var weeklySummaryTime = UserDefaults.standard.object(forKey: "weeklySummaryTime") as? Date ?? Date()
    @State private var startOfTheWeek = UserDefaults.standard.string(forKey: "startOfTheWeek") ?? "None"
    @State var notFirstTime = UserDefaults.standard.bool(forKey: "notFirstTime")
    @State var valueDidChange = false
    
    
    func saveSetting() {
        UserDefaults.standard.set(notificationTime, forKey: "notificationTime")
        UserDefaults.standard.set(weeklySummaryTime, forKey: "weeklySummaryTime")
        UserDefaults.standard.set(startOfTheWeek, forKey: "startOfTheWeek")
    }
    
    func pushGeneralNotifications() {
        let generalNotificationContent = UNMutableNotificationContent()
        generalNotificationContent.title = "Recording time!"
        generalNotificationContent.body = "☺️ It's time to record what you did today."
        generalNotificationContent.sound = UNNotificationSound.default

        let generalNotificationTime = Calendar.current.dateComponents([.hour, .minute], from: notificationTime)
        let generalNotificationTrigger = UNCalendarNotificationTrigger(dateMatching: generalNotificationTime, repeats: true)
        let generalNotificationRequest = UNNotificationRequest(identifier: UUID().uuidString, content: generalNotificationContent, trigger: generalNotificationTrigger)
        
        UNUserNotificationCenter.current().add(generalNotificationRequest)
    }
    
    func pushWeeklySummaryNotification() {
        let weeklySummaryNotificationContent = UNMutableNotificationContent()
        weeklySummaryNotificationContent.title = "Your weekly summary is avaliable!"
        weeklySummaryNotificationContent.body = "📈 You can view it at \"weekly summary\" page."
        weeklySummaryNotificationContent.sound = UNNotificationSound.default
        
        let selectedTime = Calendar.current.dateComponents([.hour, .minute], from: weeklySummaryTime)
        var weeklySummaryNotificationTime = DateComponents()
        weeklySummaryNotificationTime.weekday = SettingHelper.calculateWeeklySummaryDay(day: startOfTheWeek)
        weeklySummaryNotificationTime.hour = selectedTime.hour
        weeklySummaryNotificationTime.minute = selectedTime.minute
        
        let weeklySummaryNotificationTrigger = UNCalendarNotificationTrigger(dateMatching: weeklySummaryNotificationTime, repeats: true)
        let weeklySummaryNotificationRequest = UNNotificationRequest(identifier: UUID().uuidString, content: weeklySummaryNotificationContent, trigger: weeklySummaryNotificationTrigger)
        
        UNUserNotificationCenter.current().add(weeklySummaryNotificationRequest)
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                let textWidth = geometry.size.width/2.1
                let textFontSize = geometry.size.width/23
                let paddingSize = geometry.size.width/30
                VStack {
                    Group {
                        NotificationToggle(icon: "🔔", textSize: textFontSize, textWidth: textWidth, paddingSize: paddingSize, notificationEnabled: $notificationEnabled, valueDidChange: $valueDidChange, notFirstTime: $notFirstTime)
                        Divider()
                        TimePicker(icon: "⏰", iconSize: textFontSize + 4, text: "Reminder time", textSize: textFontSize, textWidth: textWidth, paddingSize: paddingSize, time: $notificationTime)
                        HStack {
                            Spacer()
                            Text("This is your daily reminder to record the activities")
                                .italic()
                                .modifier(NotImportantText(size: 11))
                        }
                        .padding(.trailing, 2.0)
                        Divider()
                    }
                    
                    Group {
                        NavigationLink(
                            destination: DayList(selectedDay: $startOfTheWeek),
                            label: {
                                HStack {
                                    Text("🔢").font(.system(size: textFontSize + 4))
                                    Text("Start of the week")
                                        .font(.system(size: textFontSize))
                                        .frame(width: textWidth, alignment: .leading)
                                    Spacer()
                                    Text(startOfTheWeek)
                                        .font(.system(size: textFontSize + 2))
                                    Image(systemName: "chevron.right")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                        .padding(.leading, 3.0)
                                }
                            })
                            .foregroundColor(.black)
                            .padding(.vertical)
                            .padding(.leading, paddingSize)
                        Divider()
                        TimePicker(icon: "🕰", iconSize: textFontSize + 4, text: "Weekly Summary time", textSize: textFontSize, textWidth: textWidth, paddingSize: paddingSize, time: $weeklySummaryTime)
                        HStack {
                            Spacer()
                            Text("Weekly Summary will be avaliable at this time the day before the start of the week")
                                .italic()
                                .modifier(NotImportantText(size: 11))
                                .frame(width: 220, alignment: .trailing)
                        }
                        .padding(.trailing, 2.0)
                        Divider()
                    }
                    Spacer()
                }
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal)
            .navigationBarTitle("Settings", displayMode: .inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isSheetUp = false
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Save") {
                        isSheetUp = false
                        saveSetting()
                        if notificationEnabled {
                            pushGeneralNotifications()
                            pushWeeklySummaryNotification()
                        }
                    }
                }
            }
        }
    }
}


struct NotificationToggle: View {
    var icon: String
    var textSize: CGFloat
    var textWidth: CGFloat
    var paddingSize: CGFloat
    @Binding var notificationEnabled: Bool
    @Binding var valueDidChange: Bool
    @Binding var notFirstTime: Bool
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                syncNotificationStatus()
            }
        }
    }
    
    func syncNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                notificationEnabled = true
                valueDidChange = false
            } else {
                notificationEnabled = false
                valueDidChange = true
            }
        }
    }
    
    var body: some View {
        Toggle(isOn: $notificationEnabled, label: {
            HStack {
                if icon != "" {
                    Text(icon).font(.system(size: textSize + 4))
                }
                Text("Enable notification")
                    .font(.system(size: textSize))
                    .frame(width: textWidth, alignment: .leading)
            }
        })
        .toggleStyle(SwitchToggleStyle(tint: .blue))
        .onChange(of: notificationEnabled, perform: { value in
            if value {
                if valueDidChange {
                    if notFirstTime {
                        SettingHelper.openSettings()
                    } else {
                        requestPermission()
                        syncNotificationStatus()
                        UserDefaults.standard.set(true, forKey: "notFirstTime")
                    }
                }
            } else {
                if !valueDidChange {
                    SettingHelper.openSettings()
                }
            }
        })
        .onAppear {
            syncNotificationStatus()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            syncNotificationStatus()
        }
        .padding([.trailing, .vertical])
        .padding(.leading, paddingSize)
    }
}

struct TimePicker: View {
    var icon: String
    var iconSize: CGFloat
    var text: String
    var textSize: CGFloat
    var textWidth: CGFloat
    var paddingSize: CGFloat
    @Binding var time: Date
    
    var body: some View {
        HStack {
            if icon != "" {
                Text(icon).font(.system(size: iconSize))
            }
            Text(text)
                .font(.system(size: textSize))
                .frame(width: textWidth, alignment: .leading)
            DatePicker(
                "",
                selection: $time,
                displayedComponents: [.hourAndMinute]
            )
            .datePickerStyle(DefaultDatePickerStyle())
        }
        .padding(.leading, paddingSize)
        .padding(.top, 2.0)
    }
}

struct DayList: View {
    var days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    @Binding var selectedDay: String
    
    var body: some View {
        List {
            ForEach(days, id: \.self) { day in
                DayRow(selectedDay: $selectedDay, day: day)
            }
        }
    }
}

struct DayRow: View {
    @Binding var selectedDay: String
    var day: String
    @State var isSelected = false
    
    var body: some View {
        HStack {
            Text(day)
            Spacer()
            Image(systemName: "checkmark")
                .foregroundColor(selectedDay == day ? Color.blue : Color.white)
        }
        .background(Color.white)
        .onTapGesture {
            if !isSelected {
                selectedDay = day
                isSelected = true
            } else {
                if selectedDay != day {
                    selectedDay = day
                    isSelected = true
                } else {
                    selectedDay = "None"
                    isSelected = false
                }
            }
        }
        .padding()
    }
}
