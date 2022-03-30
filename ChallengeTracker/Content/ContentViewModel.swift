//
//  ContentViewModel.swift
//  ChallengeTracker
//
//  Created by Nigel Gee on 16/03/2022.
//

import HealthKit
import SwiftUI

extension ContentView {

    /// View Model for Content View
    class ViewModel: ObservableObject {

        /// An Obervered object for health data
        @Published var dataSets = [DataSet]()

        /// A Boolean to show details of heath data
        @Published var showingDetails = false

        @Published var showingSettings = false

        /// A Boolean to show alert if unable to access health data
        @Published var showingErrorAlert = false

        @Published var showingNoHealthAlert = false

        /// Calculate the sum of health data for a days
        var sumDataSets: Double {
            dataSets.map { $0.value }.reduce(0, +)
        }


        /// A method to get health data
        /// - Parameter activity: the type of activity
        func getHealthData(for activity: Activity, in distanceType: DistanceType) {
            let healthStore = HKHealthStore()
            dataSets.removeAll(keepingCapacity: true)

            var unit: HKUnit

            switch activity {
            case .move:
                unit = .kilocalorie()
            case .exercise:
                unit = .minute()
            case .distance, .wheelchair, .cycling:
                switch distanceType {
                case .miles:
                    unit = .mile()
                case .kilometers:
                    unit = .meterUnit(with: .kilo)
                }
            }

            if HKHealthStore.isHealthDataAvailable() {
                let readData = Set([
                    HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                    HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
                    HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!,
                    HKObjectType.quantityType(forIdentifier: .distanceWheelchair)!,
                    HKObjectType.quantityType(forIdentifier: .distanceCycling)!
                ])

                healthStore.requestAuthorization(toShare: [], read: readData) { success, error in
                    if success {
                        let calendar = Calendar.current

                        var anchorComponents = calendar.dateComponents([.day, .month, .year], from: Date.now)
                        anchorComponents.day = 1
                        anchorComponents.hour = 0

                        guard let anchorDate = calendar.date(from: anchorComponents) else {
                            fatalError("Unable to create a valid date from the given components")
                        }

                        let endDate = Date.now
                        let startDate = endDate.startDateOfMonth

                        var interval = DateComponents()
                        interval.day = 1

                        guard let quantityType = HKObjectType.quantityType(forIdentifier: activity.typeIdentifier) else {
                            fatalError("Unable to create a Quantity Type")
                        }

                        let query = HKStatisticsCollectionQuery(quantityType: quantityType,
                                                                quantitySamplePredicate: nil,
                                                                options: .cumulativeSum,
                                                                anchorDate: anchorDate,
                                                                intervalComponents: interval)

                        query.initialResultsHandler = { query, results, error in
                            guard let statsCollection = results else {
                                fatalError("An error occurred while calculating the statistics: \(String(describing: error?.localizedDescription))")
                            }

                            statsCollection.enumerateStatistics(from: startDate, to: endDate) { statistics, stop in
                                let date = statistics.startDate
                                if let quantity = statistics.sumQuantity() {
                                    let value = quantity.doubleValue(for: unit)

                                    let dataSet = DataSet(date: date, value: value)
                                    DispatchQueue.main.async {
                                        self.dataSets.append(dataSet)
                                    }
                                } else {
                                    let dataSet = DataSet(date: date, value: 0.0)
                                    DispatchQueue.main.async {
                                        self.dataSets.append(dataSet)
                                    }
                                }
                            }
                        }

                        healthStore.execute(query)

                    } else if error != nil {
                        DispatchQueue.main.async {
                            self.showingErrorAlert = true
                        }
                    }
                }
            } else {
                print("No HealthKit data available")
                self.showingNoHealthAlert = true
            }
        }

        /// a method for share sheet
        /// - Parameters:
        ///   - enteredGoal: the entered goal target
        ///   - activity: the type of activity
        ///   - progressState: progress of the amount above/behind/completed
        func shareResult(enteredGoal: Double, activity: Activity, progressState: ProgressState, distanceType: DistanceType) {
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

            let result = Int((sumDataSets / enteredGoal * 100)).formatted(.percent)
            var resultString = ""
            switch progressState {
            case .doneAhead:
                resultString = "My \(activity.rawValue.capitalized) activity this month: I am beating the daily average with \(result) of \(enteredGoal) \(unit). #ChallengeTracker"
            case .doneBehind:
                resultString = "My \(activity.rawValue.capitalized) activity this month: I have done \(result) of \(enteredGoal) \(unit). #ChallengeTracker"
            case .completed:
                resultString = "I completed this month goal for \(activity.rawValue.capitalized) of \(enteredGoal) \(unit). #ChallengeTracker"
            }

            let activityController = UIActivityViewController(activityItems: [resultString], applicationActivities: nil)
            UIWindow.key?.rootViewController!
                .present(activityController, animated: true)
        }
    }
}
