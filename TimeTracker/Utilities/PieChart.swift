//
//  PieChart.swift
//  TimeTracker
//
//  Created by Tony Chi on 22/2/21.
//

import SwiftUI

struct PieChart: View {
    @EnvironmentObject var observedActivities: ActivityInitialiser
    @State var showChart = false
    var radius: CGFloat
    let startY: Int
    
    func startAngle(index: Int, totalTime: Int) -> Double {
        var previousSum = 0.0
        if index != 0 {
            for i in 0..<index {
                previousSum += observedActivities.getActivities()[i].sliceAngle(totalTime: totalTime)
            }
        }
        return previousSum
    }
    
    var body: some View {
        let activities = observedActivities.getActivities()
        let sum = observedActivities.getTotalTime(actualTime: false, forRecorder: false)
        GeometryReader { geometry in
            ZStack {
                ForEach(activities) { activity in
                    let index = activities.firstIndex(of: activity)!
                    Path { path in
                        path.move(to: CGPoint(x: Int(geometry.size.width)/2, y: startY))
                        path.addArc(center: .init(x: Int(geometry.size.width)/2, y: startY), radius: radius, startAngle: Angle(degrees: startAngle(index: index, totalTime: sum)), endAngle: Angle(degrees: startAngle(index: index, totalTime: sum) + activity.sliceAngle(totalTime: sum)), clockwise: false)
                        path.closeSubpath()
                    }
                    .fill(activity.color)
                    .scaleEffect(showChart ? 1:0)
                    .animation(Animation.spring().delay(Double(index) * 0.04))
                }
                .onAppear() {
                    showChart = true
                }
            }
        }
    }
}


struct PieChartDescription: View {
    @EnvironmentObject var observedActivities: ActivityInitialiser
    let columns = [GridItem(.adaptive(minimum: 85, maximum: 120))]
    var body: some View {
        let activities = observedActivities.getActivities()
        VStack {
            ScrollView(.vertical) {
                LazyVGrid(columns: columns, spacing: 5) {
                    ForEach(activities) { activity in
                        HStack {
                            Rectangle()
                                .fill(activity.color)
                                .cornerRadius(10)
                                .frame(width: 14, height: 14)
                            Text(activity.name)
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            HStack {
                Spacer()
                Text("(Scroll down to see more in legend)")
                    .font(.system(size: 12))
                    .bold()
                    .italic()
                    .foregroundColor(.gray)
                    .padding(.trailing)
            }
            .opacity((observedActivities.getActivities().count > 6) ? 1 : 0)
            .padding(.top, -8.0)
        }
    }
}

struct PieChart_Previews: PreviewProvider {
    static var previews: some View {
        PieChartDescription()
            .environmentObject(ActivityInitialiser())
    }
}
