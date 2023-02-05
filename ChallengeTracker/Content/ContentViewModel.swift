//
//  ContentViewModel.swift
//  ChallengeTracker
//
//  Created by Nigel Gee on 16/03/2022.
//

import HealthKit
import SwiftUI
import StoreKit

extension ContentView {

    /// View Model for Content View
    class ViewModel: ObservableObject {
        /// Store the target goal to User Defaults
        @AppStorage("enteredGoal") var enteredGoal = 0.0 {
            didSet {
                getHealthData()
            }
        }
        /// Store the activity type to User Defaults
        @AppStorage("activity") var activity = Activity.walking {
            didSet {
                getHealthData()
            }
        }
        /// Store the type of distance measurement to User Defaults
        @AppStorage("distanceType") var distanceType = DistanceType.miles {
            didSet {
                getHealthData()
            }
        }

        /// Store the variable to determine the number of goals reach in a month
        @AppStorage("goalDays") var goalDays = 14
        @AppStorage("displayGoalNumber") var displayGoalNumber = false
        @AppStorage("goalAmount") var goalAmount = 0.0
        @AppStorage("doubleAmount") var doubleAmount = false
        
        /// An observable object for health data
        @Published var dataSets = [DataSet]()
        @Published var animatedGoal = 0.0

        /// A Boolean to show details of heath data
        @Published var showingDetails = false

        @Published var showingSettings = false

        /// A Boolean to show alert depending on which alert need to show
        @Published var showingAlert = false
        @Published var alertTitle = ""
        @Published var alertMessage: Text?

        /// Calculate the sum of health data for a days
        var sumDataSets: Double {
            dataSets.map { $0.value }.reduce(0, +)
        }

        /// Calculate the target goal by number of days in the month.
        var goalPerDay: Double {
            let date = Date.now
            let endDateOfMonth = date.endDateOfMonth
            let daysInMonth = endDateOfMonth.dayNumber
            return enteredGoal / Double(daysInMonth)
        }

        /// Calculates the amount of target to date as 0 to 1
        var goalToDate: Double {
            withAnimation {
                let today = Date.now.dayNumber
                return (goalPerDay * Double(today) / enteredGoal)
            }
        }

        /// If status of amount done to goal amount either pre day or total
        var progressState: ProgressState {
            if sumDataSets > enteredGoal {
                return .completed
            } else if sumDataSets > (goalPerDay * Double(Date.now.dayNumber)) {
                return .doneAhead
            } else {
                return .doneBehind
            }
        }

        /// Returns the number of days that the goal is reached
        var numberGoalMonth: Int {
            var totalDaysAchieved = 0
            for data in dataSets {
                if data.value >= goalAmount * (doubleAmount ? 2 : 1) {
                    totalDaysAchieved += 1
                }
            }

            return totalDaysAchieved
        }

        /// Check to see if Goal has been set if not show SettingView first.
        func checkStatus() {
            if enteredGoal.isZero {
                showingSettings = true
            }
            getHealthData()
        }

        /// A method to get health data
        func getHealthData() {
            let healthStore = HKHealthStore()
            dataSets.removeAll(keepingCapacity: true)
            animatedGoal = 0

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
            case .steps:
                unit = .count()
            }

            if HKHealthStore.isHealthDataAvailable() {
                let readData = Set([
                    HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                    HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
                    HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!,
                    HKObjectType.quantityType(forIdentifier: .distanceWheelchair)!,
                    HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
                    HKObjectType.quantityType(forIdentifier: .distanceSwimming)!,
                    HKObjectType.quantityType(forIdentifier: .stepCount)!,
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
                                    DispatchQueue.main.async {
                                        withAnimation {
                                            self.dataSets.append(dataSet)
                                        }
                                    }
                                } else {
                                    let dataSet = DataSet(date: date, value: 0.0)
                                    DispatchQueue.main.async {
                                        self.dataSets.append(dataSet)
                                    }
                                }

                                DispatchQueue.main.async {
                                    withAnimation {
                                        self.animatedGoal = self.goalToDate
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

            var result = "0%"

            if enteredGoal.isNotZero {
                result = Int((sumDataSets / enteredGoal * 100)).formatted(.percent)
            }
            
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

        /// A button in the navigation bar to show share sheet
        var shareToolbarItem: some ToolbarContent {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    self.shareResult(enteredGoal: self.enteredGoal,
                                     activity: self.activity,
                                     progressState: self.progressState,
                                     distanceType: self.distanceType)
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                .disabled(dataSets.isEmpty)
            }
        }

        /// A button in the navigation bar to refresh data
        var refreshToolbarItem: some ToolbarContent {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    self.getHealthData()
                } label: {
                    Label("Refresh", systemImage: "arrow.counterclockwise")
                }
            }
        }
    }
}
