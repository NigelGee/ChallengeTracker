//
//  RingProgressView.swift
//  ChallengeTracker
//
//  Created by Nigel Gee on 16/03/2022.
//

import SwiftUI

/// A view that compiles the all the Rings views required
struct RingProgressView: View {

    /// The target Goal
    let enteredGoal: Double

    ///  The amount done from heath data
    let amountDone: Double

    /// Store the activity type to User Defaults
    @AppStorage("activity") var activity = Activity.distance


    /// Calculates the amount of target to date as 0 to 1
    var goalToDate: Double {
        let date = Date.now
        let endDateOfMonth = date.endDateOfMonth
        let daysInMonth = endDateOfMonth.dayNumber
        let today = date.dayNumber
        let amountPerDay = enteredGoal / Double(daysInMonth)
        return (amountPerDay * Double(today) / enteredGoal)
    }

    ///  Calculates the amount done from health data as 0 to 1
    var doneAmount: Double {
        amountDone / enteredGoal
    }

    var accessibilityLabel: Text {
        if amountDone > goalToDate {
            return Text("you are ahead of daily goal, \(amountDone, specifier: activity.specifier) \(activity.unit) of \(enteredGoal, specifier: activity.specifier) \(activity.unit)")
        } else {
            return Text("you are behind of daily goal, \(amountDone, specifier: activity.specifier) \(activity.unit) of \(enteredGoal, specifier: activity.specifier) \(activity.unit)")
        }
    }

    var body: some View {
        ZStack {
            VStack {
                if amountDone > enteredGoal {
                    VStack {
                        Text("Well Done!")
                        Text("Goal completed.")
                    }
                    .font(.system(size: 23))
                    .accessibilityElement(children: .combine)
                } else {
                    VStack {
                        Text("\(amountDone, specifier: activity.specifier)")
                        Text("of")
                        Text("\(enteredGoal, specifier: activity.specifier)")
                    }
                    .accessibilityElement()
                    .accessibilityLabel(accessibilityLabel)
                }
            }
            .foregroundColor(activity.color.opacity(0.7))
            .font(.system(size: 30, weight: .bold, design: .rounded))

            RingView(amount: enteredGoal, color: activity.color.opacity(0.1))

            /// which ring is above which ring
            if doneAmount > goalToDate {
                RingView(amount: doneAmount, color: activity.color)
                RingView(amount: goalToDate, color: .black.opacity(0.4))
            } else {
                RingView(amount: goalToDate, color: activity.color.opacity(0.4))
                RingView(amount: doneAmount, color: activity.color)
            }
        }
    }
}

struct RingProgressView_Previews: PreviewProvider {
    static var previews: some View {
        RingProgressView(enteredGoal: 185.6, amountDone:48.1, activity: .distance)
            .preferredColorScheme(.dark)
    }
}
