//
//  ActivityOverview.swift
//  TimeTracker
//
//  Created by Tony Chi on 10/2/21.
//

import SwiftUI

struct ActivityOverview: View {
    @EnvironmentObject var observedActivities: ActivityInitialiser
    @State private var isAdderClicked = false
    var body: some View {
        NavigationView {
            if observedActivities.getActivities().count == 0 {
                NoActivity()
                    .navigationBarTitle("", displayMode: .inline)
                    .toolbar(content: {
                        ToolbarItemGroup(placement: .navigationBarLeading) {
                            Text("Activity")
                                .font(.title)
                                .bold()
                        }
                    })
            } else {
                ActivityOverviewContent()
                    .navigationBarTitle("", displayMode: .inline)
                    .toolbar(content: {
                        ToolbarItemGroup(placement: .navigationBarLeading) {
                            Text("Activity")
                                .font(.title)
                                .bold()
                        }
                        ToolbarItemGroup(placement: .navigationBarTrailing) {
                            Button(action: {
                                isAdderClicked = true
                            }, label: {
                                Image(systemName: "plus")
                            })
                            .imageScale(.large)
                        }
                    })
                    .sheet(isPresented: $isAdderClicked) {
                        ActivityAdder(isSheetUp: $isAdderClicked, callingAdder: true)
                    }
            }
        }
    }
}

struct ActivityOverviewContent: View {
    var body: some View {
        GeometryReader { geometry in
            VStack {
                PieChart(radius: (geometry.size.height/6), startY: (Int(geometry.size.height)/6) + 17)
                    .frame(height: (geometry.size.height/3) + 15)
                PieChartDescription()
                    .frame(height: 62)
                ActivityListTitles()
                ActivityOverviewList()
            }
        }
    }
}

struct ActivityListTitles: View {
    var body: some View {
        HStack {
            Text("Activity List")
                .font(.title)
                .bold()
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, -10.0)
        .padding(.bottom, 5.0)
        
        HStack {
            Text("Name")
                .bold()
                .frame(width: 85)
            Spacer()
            Text("Completed")
                .bold()
                .frame(width: 85)
            Spacer()
            Text("Expected")
                .bold()
                .frame(width: 85)
            Image(systemName: "chevron.right")
                .font(.footnote)
                .foregroundColor(.clear)
                .padding(.leading, 7.0)
        }
        .font(.callout)
        .padding(.horizontal)
        .padding(.bottom, -1.0)
        
        Divider().padding(.leading)
    }
}

struct ActivityOverviewList: View {
    @EnvironmentObject var observedActivities: ActivityInitialiser
    
    var body: some View {
        ScrollView {
            ForEach(observedActivities.getActivities()) { activity in
                let actualTime = TimeConverter().convertTime(time: activity.actualTime)
                let expectedTime = TimeConverter().convertTime(time: activity.expectedTime)
                let index = observedActivities.getActivities().firstIndex(of: activity)!
                NavigationLink(destination: DetailedActivity(index: index).background(Color.offWhite.opacity(0.3))) {
                    HStack {
                        Text(activity.name)
                            .frame(width: 85)
                            .multilineTextAlignment(.center)
                        Spacer()
                        Text("\(actualTime.0) h  \(actualTime.1) m")
                            .frame(width: 85)
                        Spacer()
                        Text("\(expectedTime.0) h  \(expectedTime.1) m")
                            .frame(width: 85)
                        Image(systemName: "chevron.right")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .padding(.leading, 7.0)
                    }
                }
                .foregroundColor(.black)
                .padding()
                Divider().padding(.leading)
            }
        }
    }
}


struct ActivityOverview_Previews: PreviewProvider {
    static var previews: some View {
        ActivityOverview()
            .environmentObject(ActivityInitialiser())
    }
}
