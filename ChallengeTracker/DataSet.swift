//
//  DataSet.swift
//  ChallengeTracker
//
//  Created by Nigel Gee on 16/03/2022.
//

import Foundation

/// Data for Health data
struct DataSet: Identifiable, Comparable {
    var id = UUID()
    let date: Date
    let value: Double

    static func <(lhs: DataSet, rhs: DataSet) -> Bool {
        lhs.value < rhs.value
    }

    #if DEBUG
    static let example = [
        DataSet(date: Date.now.startDateOfMonth, value: 6.618235340254783),
        DataSet(date: Date.now.nextDay(from: 1), value: 8.076120900361502),
        DataSet(date: Date.now.nextDay(from: 2), value: 7.840323605743683),
        DataSet(date: Date.now.nextDay(from: 3), value: 7.011191423541998),
        DataSet(date: Date.now.nextDay(from: 4), value: 7.717229309299932),
        DataSet(date: Date.now.nextDay(from: 5), value: 10.871981360122156),
        DataSet(date: Date.now.nextDay(from: 6), value: 6.803856611914127),
        DataSet(date: Date.now.nextDay(from: 7), value: 6.94825828830905),
        DataSet(date: Date.now.nextDay(from: 8), value: 5.484037045793714),
        DataSet(date: Date.now.nextDay(from: 9), value: 6.876052160275526),
        DataSet(date: Date.now.nextDay(from: 10), value: 4.183805440464894),
        DataSet(date: Date.now.nextDay(from: 11), value: 5.98709677),
        DataSet(date: Date.now.nextDay(from: 12), value: 15.98709677)
    ]
    #endif
}
