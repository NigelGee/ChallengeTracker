//
//  Date-Extension.swift
//  ChallengeTracker
//
//  Created by Nigel Gee on 16/03/2022.
//

import Foundation

/// Date Helper
extension Date {
    /// Calculates the first Date of month
    var startDateOfMonth: Date {
        let calendar = Calendar.current
        guard let date = calendar.date(from: calendar.dateComponents([.month, .year], from: self)) else {
            fatalError("Unable to get start date from date")
        }
        return date
    }

    /// Calculates the first Date of preceding month
    var startDateOfPreviousMonth: Date {
        let calendar = Calendar.current
        guard let date = calendar.date(byAdding: DateComponents(month: -1), to: self.startDateOfMonth) else {
            fatalError("Unable to get end date from date")
        }
        return date
    }

    /// Calculates the end Date of month
    var endDateOfMonth: Date {
        let calendar = Calendar.current
        guard let date = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: self.startDateOfMonth) else {
            fatalError("Unable to get end date from date")
        }
        return date
    }

    /// Calculates the end Date of preceding month
    var endDateOfPreviousMonth: Date {
        let calendar = Calendar.current
        guard let date = calendar.date(byAdding: DateComponents(day: -1), to: self.startDateOfMonth) else {
            fatalError("Unable to get end date from date")
        }
        return date
    }

    /// Calculates the day number of a date
    var dayNumber: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self)
        guard let day = components.day else {
            fatalError("Unable to get day from date")
        }
        return day
    }


    /// Used for Preview
    /// - Parameter number: number of days from date
    /// - Returns: Date of that number
    func nextDay(from number: Int) -> Date {
        guard let date = Calendar.current.date(byAdding: .day, value: number, to: self.startDateOfMonth) else {
            fatalError("Unable to get next day from date")
        }
        return date
    }

    /// Returns an array of day numbers for the rest of the date's month
    /// An error returns an empty array
    var remainingDaysInMonth: [Int] {
        let calendar = Calendar.current
        guard let maxDay = calendar.range(of: .day, in: .month, for: self)?.upperBound,
              let currentDay = calendar.dateComponents([.day], from: self).day,
              maxDay > currentDay + 1 else {
            return []
        }
        
        return Array((currentDay + 1)..<maxDay)
    }

    /// Calculates the date from a Int
    /// - Parameter day: Int of day number
    /// - Returns: A date with the given day number in the same month as the current date
    func dayInSameMonth(_ day: Int) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: self)
        components.day = day
        return calendar.date(from: components) ?? .now
    }
}
