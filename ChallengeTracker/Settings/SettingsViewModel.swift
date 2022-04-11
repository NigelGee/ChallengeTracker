//
//  SettingsViewModel.swift
//  ChallengeTracker
//
//  Created by Nigel Gee on 08/04/2022.
//

import HealthKit
import SwiftUI

extension SettingsView {
    class ViewModel: ObservableObject {
        /// Store the activity type to User Defaults
        @AppStorage("activity") var activity = Activity.walking

        /// Store the type of distance measurement to User Defaults
        @AppStorage("distanceType") var distanceType = DistanceType.miles

        /// Store the target goal to User Defaults
        @AppStorage("enteredGoal") var enteredGoal = 0.0
        @AppStorage("inputAmount") var inputAmount = 0.0
        @AppStorage("perDay") var perDay = false


        /// Store the goals for new month
        @Published var newMonthlyGoal = 0.0
        @Published var newDailyGoal = 0.0

        /// A Boolean to show alert depending on which alert need to show
        @Published var showingAlert = false
        @Published var alertTitle = ""
        @Published var alertMessage: Text?

        /// an enum to describe the status of getting the data and calculating a goal amount
        private enum Status {
            case loading, noValues, hasValues
        }

        private var status = Status.loading

        /// Shows which suggested goal either perDay or perMonth
        var suggestedGoal: Double {
            withAnimation {
                if perDay {
                    return newDailyGoal
                }
                return newMonthlyGoal
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

        /// If activity has miles or kilometre returns true
        var isDistanceActivity: Bool {
            activity == .walking || activity == .wheelchair || activity == .cycling
        }


        /// Section Footer Text depending on the status of getting data
        var footerText: Text {
            switch status {
            case .loading:
                return Text("Collecting data and calculating a suggested goal.")
            case .noValues:
                return Text("Unable to calculate a goal as no \(activity.rawValue.capitalized) amounts have been done in the previous month. Use a device (eg Apple Watch or similar) or an app that save records to the Health app to be able to calculate a suggested goal next month.")
            case .hasValues:
                return Text("Your goal target based on the \(activity.rawValue.capitalized) amounts of the previous month.")
            }
        }

        /// Calculate a day goal to monthly goal
        func perMonth() {
            if perDay {
                enteredGoal = inputAmount * Double(Date.now.endDateOfMonth.dayNumber)
            } else {
                enteredGoal = inputAmount
            }
        }

        /// A method to get health data
        func getHealthData() {
            let healthStore = HKHealthStore()
            newMonthlyGoal = 0
            newDailyGoal = 0
            status = .loading

            var dataSets = [DataSet]()

            var unit: HKUnit

            switch activity {
            case .move:
                unit = .kilocalorie()
            case .exercise:
                unit = .minute()
            case .walking, .wheelchair, .cycling:
                switch distanceType {
                case .miles:
                    unit = .mile()
                case .kilometers:
                    unit = .meterUnit(with: .kilo)
                }
            case .swimming:
                unit = .meter()
            }

            if HKHealthStore.isHealthDataAvailable() {
                let readData = Set([
                    HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                    HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
                    HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!,
                    HKObjectType.quantityType(forIdentifier: .distanceWheelchair)!,
                    HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
                    HKObjectType.quantityType(forIdentifier: .distanceSwimming)!
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

                        let endDate = Date.now.endDateOfPreviousMonth
                        let startDate = Date.now.startDateOfPreviousMonth

                        var interval = DateComponents()
                        interval.day = 1

                        guard let quantityType = HKObjectType.quantityType(forIdentifier: self.activity.typeIdentifier) else {
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
                                    dataSets.append(dataSet)
                                } else {
                                    let dataSet = DataSet(date: date, value: 0.0)
                                    dataSets.append(dataSet)
                                }

                                DispatchQueue.main.async {
                                    let sumOfGoal = dataSets.map { $0.value }.reduce(0, +)
                                    let previousAmountPerDay = sumOfGoal / Double(endDate.dayNumber)
                                    self.newDailyGoal = previousAmountPerDay * 1.07
                                    self.newMonthlyGoal = self.newDailyGoal * Double(Date.now.endDateOfMonth.dayNumber)

                                    if self.newMonthlyGoal > 0 {
                                        self.status = .hasValues
                                    } else {
                                        self.status = .noValues
                                    }
                                }
                            }
                        }

                        healthStore.execute(query)

                    } else if error != nil {
                        DispatchQueue.main.async {
                            self.alertTitle = AlertItem.retrieveError.title
                            self.alertMessage = AlertItem.retrieveError.message
                            self.showingAlert = true
                        }
                    }
                }
            } else {
                self.alertTitle = AlertItem.deviceError.title
                self.alertMessage = AlertItem.deviceError.message
                self.showingAlert = true
            }
        }
    }
}
