//
//  RingProgressView.swift
//  ChallengeTracker
//
//  Created by Nigel Gee on 16/03/2022.
//

import SwiftUI

/// A view that compiles the all the Rings views required
struct RingProgressView: View, Animatable {
    /// The target Goal
    let enteredGoal: Double
    let goalToDate: Double

    ///  The amount done from heath data
    var amountDone: Double
    let numberGoalMonth: Int

    var animatableData: Double {
        get { amountDone }
        set { amountDone = newValue }
    }

    /// Store the activity type to User Defaults
    @AppStorage("activity") var activity = Activity.walking
    /// Store the type of distance measurement to User Defaults
    @AppStorage("distanceType") var distanceType = DistanceType.miles

    /// Store the variable to determine the number of goals reach in a month
    @AppStorage("goalDays") var goalDays = 14
    @AppStorage("displayGoalNumber") var displayGoalNumber = false
    @AppStorage("goalAmount") var goalAmount = 0.0
    @AppStorage("doubleAmount") var doubleAmount = false

    @State private var switchDisplay = true

    var isShowingGoalNumber: Bool {
        if displayGoalNumber && numberGoalMonth < goalDays {
            if switchDisplay {
                return true
            } else {
                return false
            }
        }

        return false
    }

    var body: some View {
        ZStack {
            VStack {
                if completedGoal {
                    VStack {
                        Text("Well Done!")
                        Text("Goal completed.")
                    }
                    .font(.system(size: 23))
                    .accessibilityElement(children: .combine)
                } else {
                    VStack {
                        if isShowingGoalNumber {
                            Text("\(numberGoalMonth) days")
                            Text("of")
                            Text("\(goalDays) days")
                        } else {
                            Text("\(amountDone, specifier: activity.specifier)")
                            Text("of")
                            Text("\(enteredGoal, specifier: activity.specifier)")
                        }
                    }
                    .onTapGesture {
                        if displayGoalNumber {
                            switchDisplay.toggle()
                        }
                    }
                    .accessibilityElement()
                    .accessibilityLabel(accessibilityLabel)
                    .accessibilityHint(isShowingGoalNumber ? "isButton" : "")
                }
            }
            .foregroundColor(activity.color.opacity(0.7))
            .font(.system(size: 30, weight: .bold, design: .rounded))

            Group {
                /// which ring is above which ring
                if aheadOfDailyGoal {
                    RingView(amount: doneAmount, color: activity.color)
                    RingView(amount: goalToDate, color: .black.opacity(0.4))
                } else {
                    RingView(amount: goalToDate, color: activity.color.opacity(0.4))
                    RingView(amount: doneAmount, color: activity.color)
                }
            }
            .background(
                RingView(amount: enteredGoal, color: activity.color.opacity(0.1))
            )
        }
    }

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

    ///  Calculates the amount done from health data as 0 to 1
    var doneAmount: Double {
        amountDone / enteredGoal
    }

    var aheadOfDailyGoal: Bool {
        doneAmount > goalToDate
    }

    var completedGoal: Bool {
        amountDone > enteredGoal
    }

    var accessibilityLabel: Text {
        if isShowingGoalNumber {
            return Text("you done \(numberGoalMonth) of \(goalDays) days")
        } else if aheadOfDailyGoal {
            return Text("you are ahead of daily goal, you have done \(amountDone, specifier: activity.specifier) of \(enteredGoal, specifier: activity.specifier) \(unit)")
        } else {
            return Text("you are behind of daily goal, you have done \(amountDone, specifier: activity.specifier) of \(enteredGoal, specifier: activity.specifier) \(unit)")
        }
    }
}

struct RingProgressView_Previews: PreviewProvider {
    static var previews: some View {
        RingProgressView(enteredGoal: 185.6,
                         goalToDate: 100,
                         amountDone:48.1,
                         numberGoalMonth: 1,
                         activity: .walking)
            .preferredColorScheme(.dark)
    }
}
