//
//  ChartView.swift
//  ChallengeTracker
//
//  Created by Nigel Gee on 08/12/2022.
//

import SwiftUI
import Charts

@available(iOS 16, *)
struct ChartView: View {
    let dataSets: [DataSet]
    let enteredGoal: Double

    /// Store the activity type to User Defaults
    @AppStorage("activity") var activity = Activity.walking
    @AppStorage("distanceType") var distanceType = DistanceType.miles

    var body: some View {
        VStack {
            Chart {
                ForEach(newDataSets) { dataSet in
                    BarMark(
                        x: .value("Day", dataSet.date, unit: .day),
                        y: .value("Value", dataSet.value)
                    )
                    .foregroundStyle(activity.color.gradient)
                }

                RuleMark(y: .value("Goal", goalPerDay))
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    .annotation(position: .trailing) {
                        Text("\(goalPerDay, specifier: activity.specifier)")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)

                    }
                    .foregroundStyle(Color.secondary)
            }
            .frame(height: 230)
            .chartYAxis(.hidden)
            .chartXAxis(.hidden)
            .chartPlotStyle { plotContent in
                plotContent
                    .padding(.top, 30)
                    .padding([.leading, .vertical])
                    .background(.ultraThickMaterial)
            }
            .padding(.horizontal, 30)
        }
    }

    var goalPerDay: Double {
        let endDayOfMonth = Date.now.endDateOfMonth.dayNumber
        return enteredGoal / Double(endDayOfMonth)
    }

    var newDataSets: [DataSet] {
        var data = dataSets // take a copy of the original array
        let max = dataSets.max()?.value ?? 1 // find the maximum value

        if  dataSets.isNotEmpty { // bail out if original array is empty
            // loop over the last number in array to the number of day in month
            for i in dataSets.count...Date.now.endDateOfMonth.dayNumber {
                // add new date and nominal value to array
                let newDataSet = DataSet(date: Date.now.startDateOfMonth.nextDay(from: i), value: max * 0.02)
                data.append(newDataSet)
            }
        }

        return data
    }
}


@available(iOS 16, *)
struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        ChartView(dataSets: DataSet.example, enteredGoal: 185.6, activity: .walking)
            .preferredColorScheme(.dark)
    }
}
