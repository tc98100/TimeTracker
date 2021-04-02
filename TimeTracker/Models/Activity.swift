//
//  Activity.swift
//  TimeTracker
//
//  Created by Tony Chi on 14/2/21.
//

import Foundation
import SwiftUI

class ActivityInitialiser: ObservableObject {
    
    @Published private var activities = [ActivityData]()
    let activityNone = ActivityData(name: "None", priority: 0, expectedTime: 0, actualTime: 0, color: Color.clear)
    private var overallTimeLeft: Int = 10080
    
    init() {
        let newActivity = ActivityData(name: "Exercise", priority: 1, expectedTime: 2360, actualTime: 2330, color: Color.red, actualTimeRecord: [400.0, 480.0, 460.0, 500.0, 490.0, 480, 400])
        let newActivity2 = ActivityData(name: "Study", priority: 1, expectedTime: 3360, actualTime: 0, color: Color.green, actualTimeRecord: [400.0, 480.0])
        let newActivity3 = ActivityData(name: "Sleep", priority: 1, expectedTime: 3360, actualTime: 0, color: Color.blue)
        
        addActivity(activity: newActivity)
        addActivity(activity: newActivity2)
        addActivity(activity: newActivity3)
    }
    
    func getOverallTimePerWeek() -> Int {
        return overallTimeLeft
    }
    
    func getTotalTime(actualTime: Bool, forRecorder: Bool) -> Int {
        var sum = 0
        if actualTime {
            for activity in activities {
                if forRecorder {
                    sum += activity.actualTime
                } else {
                    if activity.actualTime >= activity.expectedTime {
                        sum += activity.expectedTime
                    } else {
                        sum += activity.actualTime
                    }
                }
            }
        } else {
            for activity in activities {
                sum += activity.expectedTime
            }
        }
        return sum
    }
    
    func finishedPercentage() -> Double {
        return 100 * Double(getTotalTime(actualTime: true, forRecorder: false))/Double(getTotalTime(actualTime: false, forRecorder: false))
    }
    
    func recordTime(activity: ActivityData, newTime: Int) {
        let index = activities.firstIndex(of: activity)!
        activities[index].record(newTime: newTime)
    }
    
    func addActivity(activity: ActivityData) {
        activities.append(activity)
        overallTimeLeft -= activity.expectedTime
    }
    
    func getActivities() -> [ActivityData] {
        return activities
    }
    
    func updateActivity(index: Int, newName: String, newPriority: Int, newTime: Int, newColor: Color) {
        let oldTime = activities[index].expectedTime
        overallTimeLeft = overallTimeLeft + oldTime - newTime
        activities[index].updateName(newName: newName)
        activities[index].updatePriority(newPriority: newPriority)
        activities[index].updateTime(newTime: newTime)
        activities[index].changeColor(newColor: newColor)
    }
    
    func deleteActivity(activity: ActivityData) {
        let index = activities.firstIndex(of: activity)!
        activities.remove(at: index)
        overallTimeLeft += activity.expectedTime
    }
}


struct ActivityData: Identifiable, Equatable {
    var id = UUID()
    var name: String
    var priority: Int
    var expectedTime: Int
    var actualTime: Int
    var color: Color
    var actualTimeRecord: [Double] = [0.0]
    var onTrack = true
    var status: String {
        get {
            if actualTime > expectedTime {
                return "overachieved"
            } else if actualTime == expectedTime {
                return "completed"
            } else {
                return "underachieved"
            }
        }
    }
    
    mutating func updateName(newName: String) {
        name = newName
    }

    mutating func updatePriority(newPriority: Int) {
        priority = newPriority
    }

    mutating func updateTime(newTime: Int) {
        expectedTime = newTime
    }
    
    mutating func record(newTime: Int) {
        actualTime += newTime
    }
    
    mutating func changeColor(newColor: Color) {
        color = newColor
    }
    
    func sliceAngle(totalTime: Int) -> Double {
        return Double(360 * expectedTime)/Double(totalTime)
    }    
}

