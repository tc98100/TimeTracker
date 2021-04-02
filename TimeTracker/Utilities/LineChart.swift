//
//  BarChart.swift
//  TimeTracker
//
//  Created by Tony Chi on 23/2/21.
//

import SwiftUI

extension Path {
    static func line(data:[Double], startX: CGFloat,
                     endX: CGFloat, startY: CGFloat,
                     endY: CGFloat, visablePoints: Int) -> (Path, [CGPoint]) {
        var path = Path()
        var points = [CGPoint]()
        let gap = (endX - startX)/CGFloat(visablePoints - 1)
        let startPoint = CGPoint(x: startX, y: startY - CGFloat(data[0]))
        points.append(startPoint)
        path.move(to: startPoint)
        for i in 1..<data.count {
            let newPoint = CGPoint(x: startX + gap * CGFloat(i), y: startY - CGFloat(data[i]))
            points.append(newPoint)
            path.addLine(to: newPoint)
        }
        return (path, points)
    }
}


struct LineChart: View {
    @EnvironmentObject var observedActivities: ActivityInitialiser
    var index: Int
    @Binding var isDeleted: Bool
    let startY = CGFloat(150)
    let endY = CGFloat(50)
    let visablePoints = 7
    
    
    func scaleData(data: [Double], divideFactor: Double, min: Double) -> [Double] {
        var scaledData = [Double]()
        for i in 0..<data.count {
            scaledData.append(data[i])
            scaledData[i] -= min
            scaledData[i] = scaledData[i] / divideFactor
        }
        return scaledData
    }
    
    func expectedLine(value: Double, visiablePoints: Int) -> [Double] {
        var lineData = [Double]()
        for _ in 0..<visiablePoints {
            lineData.append(value)
        }
        return lineData
    }
    
    var body: some View {
        let activity = isDeleted ? observedActivities.activityNone : observedActivities.getActivities()[index]
        GeometryReader { geometry in
            let startX = geometry.size.width * 0.1
            let endX = geometry.size.width * 0.9
            let actualData = activity.actualTimeRecord
            let dailyAverage = Double(activity.expectedTime)/Double(visablePoints)
            let expectedData = expectedLine(value: dailyAverage, visiablePoints: visablePoints)
            let maximum = max(actualData.max()!, dailyAverage)
            let minimum = min(actualData.min()!, dailyAverage)
            let divideFactor = (maximum - minimum)/Double(startY - endY)
            ZStack {
//                Axis(startX: startX, endX: endX, startY: startY, endY: endY)
                let actualScaledData = scaleData(data: actualData, divideFactor: divideFactor, min: minimum)
                let expectedScaledData = scaleData(data: expectedData, divideFactor: divideFactor, min: minimum)
                
                let expectedLine = Path.line(data: expectedScaledData, startX: startX, endX: endX, startY: startY, endY: endY, visablePoints: visablePoints)
                expectedLine.0
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                    .stroke(activity.color)
                    .opacity(0.4)
                ForEach(0..<expectedLine.1.count) { i in
                    IndicatorPoint(pointColor: activity.color)
                        .position(expectedLine.1[i])
                }
                .opacity(0.4)

                let actualLine = Path.line(data: actualScaledData, startX: startX, endX: endX, startY: startY, endY: endY, visablePoints: visablePoints)
                actualLine.0
                    .stroke(activity.color, lineWidth: 2)
                
                if !isDeleted {
                    ForEach(0..<actualLine.1.count) { i in
                        IndicatorPoint(pointColor: activity.color)
                            .position(actualLine.1[i])
                    }
                }
                
                LineChartLegend(activity: activity, startX: startX, endX: endX, startY: startY, points: expectedLine.1)
            }
               
        }
    }
}

struct LineChartLegend: View {
    var days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    var activity: ActivityData
    var startX: CGFloat
    var endX: CGFloat
    var startY: CGFloat
    var points: [CGPoint]
    let offset: CGFloat = 55
    
    
    var body: some View {
        ZStack {
            Group {
                Path { path in
                    path.move(to: CGPoint(x: startX - 10, y: startY + 15))
                    path.addLine(to: CGPoint(x: endX + 10, y: startY + 15))
                }
                .stroke(Color.gray, lineWidth: 2)
                
                ForEach(0..<days.count) { i in
                    Text(days[i])
                        .font(.footnote)
                        .position(x: points[i].x ,y: startY + 25)
                }
            }
            
            Group {
                Path { path in
                    path.move(to: CGPoint(x: startX * 2, y: startY + offset))
                    path.addLine(to: CGPoint(x: startX * 4, y: startY + offset))
                }
                .stroke(activity.color, lineWidth: 2)
                
                IndicatorPoint(pointColor: activity.color)
                    .position(x: startX * 3, y: startY + offset)
                
                Text("Actual")
                    .font(.system(size: 12))
                    .foregroundColor(Color.gray)
                    .position(x: startX * 3, y: startY + offset + 20)
            }
             
            Group {
                Path { path in
                    path.move(to: CGPoint(x: startX * 6, y: startY + offset))
                    path.addLine(to: CGPoint(x: startX * 8, y: startY + offset))
                }
                .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                .stroke(activity.color)
                .opacity(0.4)
                
                IndicatorPoint(pointColor: activity.color)
                    .position(x: startX * 7, y: startY + offset)
                    .opacity(0.4)
                
                Text("Expected")
                    .font(.system(size: 12))
                    .foregroundColor(Color.gray)
                    .position(x: startX * 7, y: startY + offset + 20)
            }
            
            
        }
    }
}

struct IndicatorPoint: View {
    var pointColor: Color
    var body: some View {
        ZStack{
            Circle()
                .fill(pointColor)
            Circle()
                .stroke(Color.white, style: StrokeStyle(lineWidth: 2))
        }
        .frame(width: 11, height: 11)
        .shadow(radius: 6, x: 0, y: 3)
    }
}


struct Axis: View {
    var startX: CGFloat
    var endX: CGFloat
    var startY: CGFloat
    var endY: CGFloat
    
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: startX, y: endY))
            path.addLine(to: CGPoint(x: startX, y: startY))
            path.addLine(to: CGPoint(x: endX, y: startY))

        }
        .stroke(Color.black)
        .zIndex(/*@START_MENU_TOKEN@*/1.0/*@END_MENU_TOKEN@*/)
    }
}


//struct LineChart_Previews: PreviewProvider {
//    static var previews: some View {
//        LineChart(index: 0)
//            .environmentObject(ActivityInitialiser())
//    }
//}
