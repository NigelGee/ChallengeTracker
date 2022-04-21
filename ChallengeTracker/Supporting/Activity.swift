//
//  Activity.swift
//  ChallengeTracker
//
//  Created by Nigel Gee on 16/03/2022.
//

import SwiftUI
import HealthKit

/// An enum for the types of activity from health data
enum Activity: String, CaseIterable {
    case move
    case exercise
    case walking = "Walking + Running Distance"
    case wheelchair = "Wheelchair Distance"
    case cycling = "Cycling Distance"
    case swimming = "Swimming Distance"
    case steps

    /// A color depend on activity
    var color: Color {
        switch self {
        case .move:
            return .move
        case .exercise:
            return .exercise
        case .walking, .wheelchair, .cycling, .steps:
            return .distance
        case .swimming:
            return .swimming
        }
    }

    /// A String of the unit type of activity
    var unit: String {
        switch self {
        case .move:
            return "kCal"
        case .exercise:
            return "min"
        case .walking, .wheelchair, .cycling:
            return "mi"
        case .swimming:
            return "m"
        case .steps:
            return "steps"
        }
    }

    /// A String of number of decimal place depend on type of activity
    var specifier: String {
        switch self {
        case .move, .exercise, .steps:
            return "%.f"
        case .walking, .wheelchair, .cycling, .swimming:
            return "%.1f"
        }
    }

    /// A Double so to change the height of `BarView`
    var increment: Double {
        switch self {
        case.move, .swimming:
            return 0.1
        case .exercise:
            return 1
        case .walking, .wheelchair:
            return 10
        case .cycling:
            return 5
        case .steps:
            return 0.01
        }
    }

    var typeIdentifier: HKQuantityTypeIdentifier {
        switch self {
        case .move:
            return .activeEnergyBurned
        case .exercise:
            return .appleExerciseTime
        case .walking:
            return .distanceWalkingRunning
        case .wheelchair:
            return .distanceWheelchair
        case .cycling:
            return .distanceCycling
        case .swimming:
            return .distanceSwimming
        case .steps:
            return .stepCount
        }
    }
}
