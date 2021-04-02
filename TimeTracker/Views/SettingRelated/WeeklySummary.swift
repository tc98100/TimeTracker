//
//  WeeklySummary.swift
//  TimeTracker
//
//  Created by Tony Chi on 6/3/21.
//

import SwiftUI

struct WeeklySummary: View {
    @EnvironmentObject var observedActivities: ActivityInitialiser
    var body: some View {
        ScrollView {
            if observedActivities.getActivities().count == 0 {
                EmptyView()
            } else {
                OverallStatus()
                ActivitySummary()
                ActivitySummaryList()
            }
        }
        .navigationBarTitle("Weekly Summary", displayMode: .inline)
    }
}

struct OverallStatus: View {
    @EnvironmentObject var observedActivities: ActivityInitialiser
    var body: some View {
        Text("Your overall completion rate for activities this week is")
            .frame(width: 300)
            .multilineTextAlignment(.center)
            .padding(.vertical, 1.0)
            .foregroundColor(.gray)
        Text("\(observedActivities.finishedPercentage(), specifier: "%.2f")%")
            .font(.system(size: 35))
            .bold()
        Divider().padding(.top, -5.0)
    }
}

struct ActivitySummary: View {
    @EnvironmentObject var observedActivities: ActivityInitialiser
    
    func summaryData() -> (best: ActivityData, worst: ActivityData, longest: ActivityData, shortest: ActivityData, completion: Int) {
        let activities = observedActivities.getActivities()
        var best = activities[0]
        var worst = activities[0]
        var longest = activities[0]
        var shortest = activities[0]
        var completion = 0
        
        for activity in activities {
            if Double(activity.actualTime)/Double(activity.expectedTime) > Double(best.actualTime)/Double(best.expectedTime) {
                best = activity
            } else {
                worst = activity
            }
            
            if activity.actualTime > longest.actualTime {
                longest = activity
            } else {
                shortest = activity
            }
            
            if activity.status == "overachieved" || activity.status == "completed" {
                completion += 1
            }
        }
        
        return (best, worst, longest, shortest, completion)
    }
    
    var body: some View {
        HStack {
            Text("Summary")
                .font(.title)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.bottom, -2.0)
        Divider()
        VStack {
            let totalCount = observedActivities.getActivities().count
            let data = summaryData()
            let actualTime = TimeHelper().timeFormatter(time: observedActivities.getTotalTime(actualTime: true, forRecorder: false))
            let expectedTime = TimeHelper().timeFormatter(time:observedActivities.getTotalTime(actualTime: false, forRecorder: false))
            
            Text("Total number of activities")
                .font(.system(size: 18))
                .foregroundColor(.gray)
            Text("\(totalCount)")
            HStack {
                SummaryRow(text: "Completion", data: "\(data.completion)")
                Divider()
                SummaryRow(text: "Underachievement", data: "\(totalCount - data.completion)")
            }
            Divider()
            HStack {
                SummaryRow(text: "Total completed time", data: "\(actualTime.0) \(actualTime.1)")
                Divider()
                SummaryRow(text: "Total target time", data: "\(expectedTime.0) \(expectedTime.1)")
            }
            Divider()
            HStack {
                SummaryRow(text: "Best activity", data: data.best.name)
                Divider()
                SummaryRow(text: "Worst activity", data: data.worst.name)
            }
           
            HStack {
                SummaryRow(text: "Longest activity", data: data.longest.name)
                Divider()
                SummaryRow(text: "Shortest activity", data: data.shortest.name)
            }
            Divider()
            HStack {
                Spacer()
                VStack {
                    Text("Best/Worst activity are based on the completion rate")
                        .italic()
                    Text("Longest/Shortest activity are based on the completed hours")
                        .italic()
                }
                .font(.system(size: 10))
                .foregroundColor(.gray)
                .padding(.trailing, 3.0)
            }
            //                Text("number of new activities") // only for first week's
            //                Text("Biggest improvement") //only for non-frist week's
            //                Text("Biggest downfall") //only for non-frist week's
        }
        
    }
}

struct SummaryRow: View {
    var text: String
    var data: String
    var body: some View {
        VStack {
            Text(text)
                .modifier(NotImportantText(size: 13))
            Text(data)
                .font(.footnote)
        }
        .multilineTextAlignment(.center)
        .frame(width: 150)
    }
}

struct ActivitySummaryList: View {
    @EnvironmentObject var observedActivities: ActivityInitialiser
    
    var body: some View {
        HStack {
            Text("Activities")
                .font(.title)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.bottom, -2.0)
        .padding(.top, 2.0)
        Divider()
        VStack {
            ForEach(observedActivities.getActivities()) { activity in
                let actualTime = activity.actualTime
                let expectedTime = activity.expectedTime
                VStack {
                    ActivityStatusMessage(activity: activity, actualTime: actualTime, expectedTime: expectedTime)
                }
                .padding(.horizontal)
                Divider()
            }
        }
    }
}

struct ActivityStatusMessage: View {
    var activity: ActivityData
    var actualTime: Int
    var expectedTime: Int
    
    func statusMessage() -> (String, String) {
        var message = ""
        var emoji = ""
        
        if activity.status == "overachieved" {
            message = "Hooray! You have completed and overachieved in this activity this week."
            emoji = "🥳  "
        } else if activity.status == "completed" {
            message = "Congratulations! You have completed this activity this week."
            emoji = "😀  "
        } else {
            message = "Unfortunately, you have failed to reach the target of this activity this week. Keep Up!"
            emoji = "🙁  "
        }
        
        return (message, emoji)
    }
    
    var body: some View {
        let aTime = TimeConverter().convertTime(time: activity.actualTime)
        let eTime = TimeConverter().convertTime(time: activity.expectedTime)
        let completionRate = 100.0 * Double(actualTime)/Double(expectedTime)
        DisclosureGroup(statusMessage().1 + activity.name) {
            VStack {
                HStack {
                    VStack {
                        Text("Completed")
                            .modifier(NotImportantText(size: 13))
                        Text("\(aTime.0) h  \(aTime.1) m")
                            .font(.headline)
                    }
                    Spacer()
                    VStack {
                        Text("Target")
                            .modifier(NotImportantText(size: 13))
                        Text("\(eTime.0) h  \(eTime.1) m")
                            .font(.headline)
                    }
                    Spacer()
                    VStack {
                        Text("Completion Rate")
                            .modifier(NotImportantText(size: 13))
                        Text("\(completionRate, specifier: "%.2f")%")
                            .font(.headline)
                    }
                }
                .padding(.vertical, 2.0)
                Text(statusMessage().0)
                    .modifier(NotImportantText(size: 13))
                    .multilineTextAlignment(.center)
            }
        }
        .font(.headline)
    }
}

struct NotImportantText: ViewModifier {
    var size: Int
    func body(content: Content) -> some View {
        content
            .font(.system(size: CGFloat(size)))
            .foregroundColor(.gray)
    }
}

struct WeeklySummary_Previews: PreviewProvider {
    static var previews: some View {
        WeeklySummary()
            .environmentObject(ActivityInitialiser())
    }
}
