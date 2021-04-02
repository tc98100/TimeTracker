//
//  ActivityAdder.swift
//  TimeTracker
//
//  Created by Tony Chi on 17/2/21.
//

import SwiftUI

extension ColorPicker {
    func hide() {
        hideKeyboard()
    }
}

struct ActivityAdder: View {
    @EnvironmentObject var observedActivities: ActivityInitialiser
    @State var isAlertShown = false
    @State private var message: String = ""
    @State private var activityName: String = ""
    @State private var activityPriority = 1.0
    @State private var activityHours: String = ""
    @State private var activityMinutes: String = ""
    @State private var selectedColor = Color(.sRGB, red: 0.98, green: 0.9, blue: 0.2)
    var activity: ActivityData?
    @Binding var isSheetUp: Bool
    var callingAdder: Bool
    
    func activityAlreadyExist(trimmedName: String) -> Bool {
        var alreadyExist = false
        if callingAdder {
            for activityPicked in observedActivities.getActivities() {
                if activityPicked.name == trimmedName {
                    alreadyExist = true
                }
            }
        } else {
            for activityPicked in observedActivities.getActivities() {
                if activityPicked.name == trimmedName && activityPicked.name != activity!.name {
                    alreadyExist = true
                }
            }
        }
        return alreadyExist
    }
    
    var body: some View {
        let time = 60 * (Int(activityHours) ?? 0) + (Int(activityMinutes) ?? 0)
        NavigationView {
            Form {
                Section(header: Text("Name")) {
                    TextFieldWithLimit(placeholder: "Name", text: $activityName, limit: 15, numberPad: false)
                }
                Section(header: Text("Priority"), footer: PriorityFooter()){
                    PrioritySelector(activityPriority: $activityPriority)
                }
                Section(header: Text("Time"), footer: TimeFooter(time: time)) {
                    HStack {
                        TextFieldWithLimit(placeholder: "Hours", text: $activityHours, limit: 5, numberPad: true)
                        Divider()
                        TextFieldWithLimit(placeholder: "Minutes", text: $activityMinutes, limit: 5, numberPad: true)
                    }
                }
                Section(header: Text("Color"), footer: Text("Long press the color board on the right to select colors")) {
                    ColorPicker("Select a color", selection: $selectedColor)
                        .foregroundColor(.gray)
                }       
            }
            .onAppear {
                if !callingAdder {
                    activityName = activity!.name
                    activityPriority = Double(activity!.priority)
                    let oldTime = TimeConverter().convertTime(time: activity!.expectedTime)
                    activityHours = String(oldTime.0)
                    activityMinutes = String(oldTime.1)
                    selectedColor = activity!.color
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
            .navigationBarTitle(callingAdder ? "New Activity" : "Edit Activity", displayMode: .inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isSheetUp = false
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(callingAdder ? "Save" : "Done") {
                        let timeLeft = callingAdder ? observedActivities.getOverallTimePerWeek() : observedActivities.getOverallTimePerWeek() + activity!.expectedTime
                        let trimmedName = activityName.trimmingCharacters(in: .whitespacesAndNewlines)
                        let alreadyExist = activityAlreadyExist(trimmedName: trimmedName)
                        let inputCheck = userInputCheck().adderCheck(name: trimmedName, hour: activityHours, minute: activityMinutes, time: time, timeLeft: timeLeft, alreadyExist: alreadyExist)
                        if inputCheck.0 {
                            if callingAdder {
                                let newActivity = ActivityData(name: trimmedName, priority: Int(activityPriority), expectedTime: time, actualTime: 0, color: selectedColor)
                                observedActivities.addActivity(activity: newActivity)
                            } else {
                                let index = observedActivities.getActivities().firstIndex(of: activity!)!
                                observedActivities.updateActivity(index: index, newName: trimmedName, newPriority: Int(activityPriority), newTime: time, newColor: selectedColor)
                            }
                            isSheetUp = false
                        } else {
                            message = inputCheck.1
                            isAlertShown = true
                        }
                    }
                }
            }
            .alert(isPresented: $isAlertShown) {
                Alert(title: Text("Alert"), message: Text(message), dismissButton: .default(Text("ok")))
            }
        }
    }
}
