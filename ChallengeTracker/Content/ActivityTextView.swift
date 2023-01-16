//
//  ActivityTextView.swift
//  ChallengeTracker
//
//  Created by Nigel Gee on 18/03/2022.
//

import SwiftUI

///  View that shows the `Text` depend on the state of progress
struct ActivityTextView: View {
    let dataSets: [DataSet]
    let enteredGoal: Double
    let progressState: ProgressState
    
    /// Store the activity type to User Defaults
    @AppStorage("activity") var activity = Activity.walking
    /// Store the type of distance measurement to User Defaults
    @AppStorage("distanceType") var distanceType = DistanceType.miles

    /// A String of the unit type of activity
    var unit: String {
        if activity.unit == "mi" {
            switch distanceType {
            case .miles:
                return "mi"
            case .kilometers:
                return "km"
            }
        }
        return activity.unit
    }

    /// Calculates the average amount to do
    var amountToDoPerDay: Double {
        let date = Date.now
        let daysInMonth = date.endDateOfMonth.dayNumber

        if date.dayNumber == 1 {
            return enteredGoal / Double(daysInMonth)
        } else {
            var values = [Double]()
            if dataSets.count < date.dayNumber {
                values = dataSets.map { $0.value }
            } else {
                var dataSetsCopy = dataSets
                dataSetsCopy.removeLast()
                values = dataSetsCopy.map { $0.value }
            }
            let sumOfValue = values.reduce(0, +)
            return (enteredGoal - sumOfValue) / Double(daysInMonth - (date.dayNumber - 1))
        }
    }

    var body: some View {
        switch progressState {
        case .doneAhead:
            Text("Keep it going. Do an average \(amountToDoPerDay, specifier: activity.specifier) \(unit) per day to reach your goal.")
        case .doneBehind:
            Text("You can do it! Do an average \(amountToDoPerDay, specifier: activity.specifier) \(unit) per day to reach your goal.")
        case .completed:
            Text("You have completed your goal of \(enteredGoal, specifier: activity.specifier) \(unit) this month. Try to see if you can do next month.")
        }
    }
}

struct ActivityTextView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityTextView(dataSets: DataSet.example, enteredGoal: 185.6, progressState: .doneBehind, activity: .walking)
    }
}
