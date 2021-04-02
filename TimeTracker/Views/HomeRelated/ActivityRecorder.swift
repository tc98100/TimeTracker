//
//  ActivityRecorder.swift
//  TimeTracker
//
//  Created by Tony Chi on 24/2/21.
//

import SwiftUI

struct ActivityRecorder: View {
    @EnvironmentObject var observedActivities: ActivityInitialiser
    @Binding var isSheetUp: Bool
    @State var isAlertShown = false
    @State var selectedActivity: ActivityData
    @State private var activityHours: String = ""
    @State private var activityMinutes: String = ""
    @State private var message: String = ""
    
    func updateUsingDays() {
        let usingDays = UserDefaults.standard.integer(forKey: "usingDays")
        let lastUseTime = UserDefaults.standard.object(forKey: "lastUseTime") as? Date ?? Date()
        let today = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        let lastUseDay = Calendar.current.dateComponents([.year, .month, .day], from: lastUseTime)
        if today != lastUseDay {
            UserDefaults.standard.set(usingDays + 1, forKey: "usingDays")
            UserDefaults.standard.set(Date(), forKey: "lastUseTime")
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(
                    destination: ActivityList(selectedActivity: $selectedActivity),
                    label: {
                        HStack {
                            Text("Activity")
                            Spacer()
                            Text(selectedActivity.name)
                        }
                    })
                    .padding()
                HStack {
                    TextFieldWithLimit(placeholder: "Hours", text: $activityHours, limit: 5, numberPad: true)
                    Divider()
                    TextFieldWithLimit(placeholder: "Minutes", text: $activityMinutes, limit: 5, numberPad: true)
                }
                .padding(.horizontal)
            }
            .navigationBarTitle("Record activity", displayMode: .inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button(action: {
                        self.isSheetUp = false
                    }, label: {
                        Text("Cancel")
                    })
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        let time = 60 * (Int(activityHours) ?? 0) + (Int(activityMinutes) ?? 0)
                        let timeLeft = 7 * 24 * 60 - observedActivities.getTotalTime(actualTime: true, forRecorder: true)
                        let inputCheck = userInputCheck().recorderCheck(activity: selectedActivity, activityNone: observedActivities.activityNone,
                                                                        hour: activityHours, minute: activityMinutes, time: time, timeLeft: timeLeft)
                        if inputCheck.0 {
                            observedActivities.recordTime(activity: selectedActivity, newTime: time)
                            updateUsingDays()
                            self.isSheetUp = false
                        } else {
                            message = inputCheck.1
                            isAlertShown = true
                        }
                    }, label: {
                        Text("Save")
                    })
                }
            }
            .alert(isPresented: $isAlertShown) {
                Alert(title: Text("Alert"), message: Text(message), dismissButton: .default(Text("ok")))
            }
        }
    }
}


struct ActivityList: View {
    @EnvironmentObject var observedActivities: ActivityInitialiser
    @Binding var selectedActivity: ActivityData

    var body: some View {
        List() {
            ForEach(observedActivities.getActivities()) { activity in
                ActivityRow(selectedActivity: $selectedActivity, activity: activity)
            }
        }
    }
}

struct ActivityRow: View {
    @EnvironmentObject var observedActivities: ActivityInitialiser
    @Binding var selectedActivity: ActivityData
    var activity: ActivityData
    @State var isSelected = false
    
    var body: some View {
        HStack {
            Text(activity.name)
            Spacer()
            Image(systemName: "checkmark")
                .foregroundColor(selectedActivity == activity ? Color.blue : Color.white)
        }
        .background(Color.white)
        .onTapGesture {
            if !isSelected {
                selectedActivity = activity
                isSelected = true
            } else {
                if selectedActivity != activity {
                    selectedActivity = activity
                    isSelected = true
                } else {
                    selectedActivity = observedActivities.activityNone
                    isSelected = false
                }
            }
        }
        .padding()
    }
}
