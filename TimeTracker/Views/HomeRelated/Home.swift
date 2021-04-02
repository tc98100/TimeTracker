//
//  Home.swift
//  TimeTracker
//
//  Created by Tony Chi on 10/2/21.
//

import SwiftUI

struct Home: View {
    @EnvironmentObject var observedActivities: ActivityInitialiser
    @State private var isRecorderUp = false
    @State private var isSettingSheetUp = false
    
    var body: some View {
        NavigationView {
            HomeContent()
                .navigationBarTitle("", displayMode: .inline)
                .toolbar(content: {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Text("Home")
                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                            .bold()
                    }
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        if observedActivities.getActivities().count != 0 {
                            Button(action: {
                                isRecorderUp = true
                            }, label: {
                                Text("Record")
                            })
                        }
                    }
                })
                .sheet(isPresented: $isRecorderUp) {
                    ActivityRecorder(isSheetUp: $isRecorderUp, selectedActivity: observedActivities.activityNone)
                }
        }
    }
}

struct HomeContent: View {
    @EnvironmentObject var observedActivities: ActivityInitialiser
    var body: some View {
        let activities = observedActivities.getActivities()
        if activities.count == 0 {
            Text("It seems like that you don't have any activities yet, you can go to 'Activity' page to add a new one")
                .frame(width: 300)
                .multilineTextAlignment(.center)
                .padding()
        } else {
            VStack {
                HStack {
                    Text("\(observedActivities.finishedPercentage(), specifier: "%.2f")")
                        .font(.custom("Bradley Hand", size: 70))
                        .padding(.leading)
                    Text("%")
                        .font(Font.custom("Bradley Hand", size: 20))
                }
                HStack {
                    Text("Completed")
                        .font(Font.custom("Chalkduster", size: 25))
                    Text("this week")
                        .font(Font.custom("Chalkduster", size: 20))
                }
                .alignmentGuide(VerticalAlignment.center) { _ in 0 }
                Divider()
                HomeContentList()
            }
        }
    }
}

struct HomeContentList: View {
    @EnvironmentObject var observedActivities: ActivityInitialiser
    var body: some View {
        ScrollView {
            ForEach(observedActivities.getActivities()) { activity in
                let actualTime = activity.actualTime
                let timeLeft = activity.expectedTime - activity.actualTime
                let percentage = Double(activity.actualTime)/Double(activity.expectedTime)
                DisclosureGroup(activity.name) {
                    VStack {
                        HStack {
                            VStack {
                                Text("Completed")
                                Text("\(TimeConverter().convertTime(time: actualTime).0) h  \(TimeConverter().convertTime(time: actualTime).1) m")
                            }
                            Spacer()
                            VStack {
                                Text("Unfinished")
                                Text("\(TimeConverter().convertTime(time: timeLeft > 0 ? timeLeft : 0).0) h  \(TimeConverter().convertTime(time: timeLeft > 0 ? timeLeft : 0).1) m")
                            }
                        }
                        ProgressView(value: percentage < 1 ? percentage : 1)
                            .progressViewStyle(CustomProgressViewStyle(color: activity.color))
                        
                    }
                    .padding()
                }
                .padding(.vertical, 4.0)
                Divider()
            }
            .padding(.horizontal)
        }
    }
}


struct CustomProgressViewStyle: ProgressViewStyle {
    let color: Color
    func makeBody(configuration: Configuration) -> some View {
        ProgressView(configuration)
            .accentColor(color)
            .shadow(radius: 4.0, x: 1.0, y: 2.0)
    }
}


struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
            .environmentObject(ActivityInitialiser())
    }
}

