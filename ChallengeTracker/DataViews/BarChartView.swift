//
//  BarChartView.swift
//  ChallengeTracker
//
//  Created by Nigel Gee on 16/03/2022.
//

import SwiftUI

/// View that that put all the `BarView` in a chart format
struct BarChartView: View {
    let dataSets: [DataSet]
    let enteredGoal: Double
    let endDayOfMonth = Date.now.endDateOfMonth.dayNumber

    /// Store the activity type to User Defaults
    @AppStorage("activity") var activity = Activity.distance

    var goalPerDay: Double {
        enteredGoal / Double(endDayOfMonth)
    }

    /// Calculates the bottom of the graph depending on the size of the maximum height of data
    var baseHeight: Double {
        let maxDataSet = dataSets.max()
        let maxValue = maxDataSet?.value ?? 0.0
        return maxValue * activity.increment / 2
    }

    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                /// Goal bar and label
                HStack {
                    Rectangle()
                        .frame(width: 310, height: 2)
                        .offset(CGSize(width: 10, height: baseHeight - (goalPerDay * activity.increment)))

                    Text("\(goalPerDay, specifier: activity.specifier)")
                        .font(.system(size: 15))
                        .offset(CGSize(width: 10, height: baseHeight - (goalPerDay * activity.increment)))
                }
                
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(0..<endDayOfMonth, id: \.self) { index in
                        if index < dataSets.count {
                            if dataSets[index].value == 0 {
                                BarView(doneAmount: 5, activity: activity)
                            } else {
                                BarView(
                                    doneAmount: dataSets[index].value * activity.increment,
                                    activity: activity)
                            }
                        } else {
                            BarView(doneAmount: 5, activity: activity)
                        }
                    }
                }
            }
            Group {
                Text("Tap on chart to show details")
                Text("Updated: \(Date.now, format: .dateTime)")
            }
            .font(.caption2)
            .foregroundColor(.secondary)
        }
    }
}

struct BarChartView_Previews: PreviewProvider {
    static var previews: some View {
        BarChartView(dataSets: DataSet.example, enteredGoal: 185.6, activity: .distance)
            .preferredColorScheme(.dark)
    }
}
