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
    case distance = "Walking + Running Distance"
    case wheelchair = "Wheelchair Distance"
    case cycling = "Cycling Distance"
    case swimming = "Swimming Distance"

    /// A color depend on activity
    var color: Color {
        switch self {
        case .move:
            return .move
        case .exercise:
            return .exercise
        case .distance, .wheelchair, .cycling:
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
        case .distance, .wheelchair, .cycling:
            return "mi"
        case .swimming:
            return "m"

        }
    }

    /// A String of number of decimal place depend on type of activity
    var specifier: String {
        switch self {
        case .move, .exercise:
            return "%.f"
        case .distance, .wheelchair, .cycling, .swimming:
            return "%.1f"
        }
    }

    /// A Double so to change the height of `BarView`
    var increment: Double {
        switch self {
        case.move:
            return 0.1
        case .exercise:
            return 1
        case .distance, .wheelchair:
            return 10
        case .cycling:
            return 5
        case .swimming:
            return 0.1
        }
    }

    var typeIdentifier: HKQuantityTypeIdentifier {
        switch self {
        case .move:
            return .activeEnergyBurned
        case .exercise:
            return .appleExerciseTime
        case .distance:
            return .distanceWalkingRunning
        case .wheelchair:
            return .distanceWheelchair
        case .cycling:
            return .distanceCycling
        case .swimming:
            return .distanceSwimming
        }
    }
}
