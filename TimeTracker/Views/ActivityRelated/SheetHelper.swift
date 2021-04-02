//
//  PrioritySelector.swift
//  TimeTracker
//
//  Created by Tony Chi on 2/3/21.
//

import SwiftUI
import Combine

struct TextFieldWithLimit: View {
    var placeholder: String
    @Binding var text: String
    var limit: Int
    var numberPad: Bool
    
    var body: some View {
        TextField(placeholder, text: $text)
            .keyboardType(numberPad ? .numberPad : .default)
            .onReceive(Just(text)) { inputValue in
                if inputValue.count > limit {
                    text.removeLast()
                }
            }
    }
}

struct PrioritySelector: View {
    @Binding var activityPriority: Double
    @State var isEditing = false
    
    var body: some View {
        HStack {
            Slider(
                value: $activityPriority,
                in: 1...3.99,
                onEditingChanged: { editing in
                    isEditing = editing
                }
            )
            Spacer()
            ZStack {
                Circle()
                    .stroke(Color.offWhite, lineWidth: 2)
                    .frame(width: 45)
                    .shadow(radius: 5)
                    .opacity(isEditing ? 0.6: 0.8)
                Text("\(Int(activityPriority))")
                    .font(.title)
                    .bold()
                    .foregroundColor(.gray)
            }
            .padding(.trailing, -10.0)
        }
    }
}


struct TimeHelper {    
    func timeFormatter(time: Int) -> (String, String) {
        let timeTuple = TimeConverter().convertTime(time: time)
        let hour = timeTuple.0
        let minute = timeTuple.1
        var hourText = ""
        var minuteText = ""

        if hour > 1 {
            hourText = " " + String(hour) + " hours"
        } else if hour == 1 {
            hourText = " " + String(hour) + " hour"
        }

        if minute > 1 {
            minuteText = String(minute) + " minutes"
        } else {
            minuteText = String(minute) + " minute"
        }
       return (hourText, minuteText)
    }
}

struct TimeFooter: View {
    var hourText = ""
    var minuteText = ""
    
    init(time: Int) {
        let message = TimeHelper().timeFormatter(time: time/7)
        hourText = message.0
        minuteText = message.1
    }
    
    var body: some View {
        Text("This is roughly equal to") + Text("\(hourText) \(minuteText)").bold() + Text(" a day")
    }
}

struct PriorityFooter: View {
    var body: some View {
        Text("The system will display the activities based on their priority, with 1 being the highest and 3 being the lowest.")
            .font(.system(size: 12))
            .italic()
    }
}


struct userInputCheck {
    func recorderCheck(activity: ActivityData, activityNone: ActivityData, hour: String, minute: String, time: Int, timeLeft: Int) -> (Bool, String) {
        if activity == activityNone {
            return (false, "You haven't selected an activity yet.")
        }
        if hour == "" && minute == "" {
            return (false, "You forgot to put in time.")
        } else {
            if time > timeLeft {
                let timeTuple = TimeHelper().timeFormatter(time: timeLeft)
                return (false, "Based on what you have done for all activities this week, the maximum amount of time you can record for this one is now\(timeTuple.0) \(timeTuple.1)")
            }
        }
        return (true, "")
    }
    
    func adderCheck(name: String, hour: String, minute: String, time: Int, timeLeft: Int, alreadyExist: Bool) -> (Bool, String) {
        if name == "" {
            return (false, "You have to set a name for the activity.")
        }
        
        if alreadyExist {
            return (false, "This activity already exists.")
        }
        
        if hour == "" && minute == "" {
            return (false, "You have to set a time.")
        } else {
            if time == 0 {
                return (false, "This activity's target time is curretnly 0 minute, try to set a higher value")
            } else if time > timeLeft {
                let timeTuple = TimeHelper().timeFormatter(time: timeLeft)
                if timeLeft == 0 {
                    return (false, "You only have\(timeTuple.0) \(timeTuple.1) of free time left to be allocated. To proceed, you need to delete older activities to free up the time")
                } else {
                    return (false, "You only have\(timeTuple.0) \(timeTuple.1) of free time left to be allocated. To proceed, you can either set a lower activity target time or delete older activities to free up the time")
                }
            }
        }
        return (true, "")
    }
}
