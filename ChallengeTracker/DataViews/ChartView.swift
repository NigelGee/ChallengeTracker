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

    @AppStorage("displayGoalNumber") var displayGoalNumber = false
    @AppStorage("goalAmount") var goalAmount = 0.0
    @AppStorage("doubleAmount") var doubleAmount = false

    var body: some View {
        VStack {
            Chart {
                if displayGoalNumber {
                    RuleMark(y: .value("Daily", goalAmount * (doubleAmount ? 2 : 1)))
                        .lineStyle(StrokeStyle(lineWidth: 3, dash: [3], dashPhase: 3))
                        .foregroundStyle(Color.secondary)

                }
                
                ForEach(completeDataSets(from: dataSets)) { dataSet in
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

    /// Get dateSets for every day of a month
    /// - Parameter dataSets: original dataSets for HealthKit
    /// - Returns: A array of DataSet for each day of month
    func completeDataSets(from dataSets: [DataSet]) -> [DataSet] {
        guard dataSets.isNotEmpty else { return [] }

        let maxValue = dataSets.max()?.value ?? 1
        let remainingDays = Date.now.remainingDaysInMonth

        let newDataSet: [DataSet] = remainingDays.map {
            DataSet(
                date: Date.now.dayInSameMonth($0),
                value: maxValue * 0.02)

        }

        return newDataSet + dataSets
    }
}


@available(iOS 16, *)
struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        ChartView(dataSets: DataSet.example, enteredGoal: 185.6)
            .preferredColorScheme(.dark)
    }
}
