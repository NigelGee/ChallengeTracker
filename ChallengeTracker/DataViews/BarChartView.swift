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
    @AppStorage("distanceType") var distanceType = DistanceType.miles

    var goalPerDay: Double {
        enteredGoal / Double(endDayOfMonth)
    }

    var increment: Double {
        if activity == .distance || activity == .wheelchair || activity == .cycling, distanceType == .kilometers {
            return activity.increment / 1.6
        }

        return activity.increment
    }

    /// Calculates the bottom of the graph depending on the size of the maximum height of data
    var baseHeight: Double {
        let maxDataSet = dataSets.max()
        let maxValue = maxDataSet?.value ?? 0.0
        return maxValue * increment / 2
    }

    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                /// Goal bar and label
                HStack {
                    Rectangle()
                        .frame(width: 310, height: 2)

                    Text("\(goalPerDay, specifier: activity.specifier)")
                        .font(.system(size: 15))

                }
                .offset(CGSize(width: 10, height: baseHeight - (goalPerDay * increment)))
                
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(0..<endDayOfMonth, id: \.self) { index in
                        if index < dataSets.count {
                            if dataSets[index].value == 0 {
                                BarView(doneAmount: 5, activity: activity)
                            } else {
                                BarView(
                                    doneAmount: dataSets[index].value * increment,
                                    activity: activity)
                            }
                        } else {
                            BarView(doneAmount: 5, activity: activity)
                        }
                    }
                }

            }
            .offset(x: 0, y: 45)
        }
    }
}

struct BarChartView_Previews: PreviewProvider {
    static var previews: some View {
        BarChartView(dataSets: DataSet.example, enteredGoal: 185.6, activity: .distance)
            .preferredColorScheme(.dark)
    }
}
