//
//  DetailedActivity.swift
//  TimeTracker
//
//  Created by Tony Chi on 21/2/21.
//

import SwiftUI

struct DetailedActivity: View {
    @EnvironmentObject var observedActivities: ActivityInitialiser
    var index: Int
    @State private var isEditorClicked = false
    @State var isDeleted = false
    
    
    var body: some View {
        let activity = isDeleted ? observedActivities.activityNone : observedActivities.getActivities()[index]
        VStack {
            if !isDeleted {
                LineChart(index: index, isDeleted: $isDeleted)
                    .frame(height: 230)
            } else {
                EmptyView()
            }
            Divider()
            DetailedActivityContent(index: index, isDeleted: $isDeleted)
            Spacer()
        }
        .navigationBarTitle(activity.name, displayMode: .inline)
        .toolbar(content: {
            ToolbarItemGroup {
                Button(action: {
                    isEditorClicked = true
                }, label: {
                    Text("Edit")
                })
            }
        })
        .sheet(isPresented: $isEditorClicked) {
            ActivityAdder(activity: activity, isSheetUp: $isEditorClicked, callingAdder: false)
        }
    }
}

struct DetailedActivityContent: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var observedActivities: ActivityInitialiser
    var index: Int
    @State private var isShown = false
    @Binding var isDeleted: Bool
    
    var body: some View {
        let activity = isDeleted ? observedActivities.activityNone : observedActivities.getActivities()[index]
        let actualTime = activity.actualTime
        let expectedTime  = activity.expectedTime
        let unfinishedTime  = activity.expectedTime - activity.actualTime
        ScrollView {
            Text(activity.name)
                .font(.custom("Chalkboard", size: 40))
                .padding([.horizontal, .top])

            Divider()
                .padding(.horizontal)
                .padding(.top, -3.0)
            
            
            HStack {
                VStack {
                    Group {
                        Text("Weekly Target").bold()
                        Text("\(TimeConverter().convertTime(time: expectedTime).0) h  \(TimeConverter().convertTime(time: expectedTime).1) m")
                        Group {
                            let message = TimeHelper().timeFormatter(time: expectedTime/7)
                            Text("around") + Text("\(message.0) \(message.1)").bold()
                            Text("each day")
                        }
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                    }
                    Divider().padding(.horizontal)
                    Group {
                        Text("Completed").bold()
                        Text("\(TimeConverter().convertTime(time: actualTime).0) h  \(TimeConverter().convertTime(time: actualTime).1) m")
                    }
                    Divider().padding(.horizontal)
                    Group {
                        Text("Unfinished").bold()
                        Text("\(TimeConverter().convertTime(time: unfinishedTime).0) h  \(TimeConverter().convertTime(time: unfinishedTime).1) m")
                    }
                    Spacer()
                }
                Divider()
                VStack {
                    Text("Priority")
                        .font(.title)
                    Text("\(activity.priority)")
                        .font(.headline)
                    Divider().padding()
                    Button(action: {
                        self.isShown = true
                    }, label: {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                    })
                    .buttonStyle(NeumorphicButton())
                    .alert(isPresented: $isShown) {
                       Alert(title: Text("Alert"),
                             message: Text("Are you sure that you want to delete this activity?"),
                             primaryButton: .default(Text("Delete")) {
                                observedActivities.deleteActivity(activity: activity)
                                isDeleted = true
                                presentationMode.wrappedValue.dismiss()
                             },
                             secondaryButton: .cancel())
                    }
                }
                
            }
            
            Divider()
                .padding()
            
        }    
    }
}

struct DetailedActivity_Previews: PreviewProvider {
    static var previews: some View {
        DetailedActivity(index: 0)
            .environmentObject(ActivityInitialiser())
    }
}
