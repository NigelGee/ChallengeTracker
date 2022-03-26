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

        /// Calculate the sum of health data for a days
        var sumDataSets: Double {
            dataSets.map { $0.value }.reduce(0, +)
        }


        /// A method to get health data
        /// - Parameter activity: the type of activity to get
        func getHealthData(for activity: Activity) {
            let healthStore = HKHealthStore()
            dataSets.removeAll(keepingCapacity: true)

            var typeIdentifier: HKQuantityTypeIdentifier
            var unit: HKUnit

            switch activity {
            case .move:
                typeIdentifier = .activeEnergyBurned
                unit = .kilocalorie()
            case .exercise:
                typeIdentifier = .appleExerciseTime
                unit = .minute()
            case .distance:
                typeIdentifier = .distanceWalkingRunning
                unit = .mile()
            case .wheelchair:
                typeIdentifier = .distanceWheelchair
                unit = .mile()
            case .cycling:
                typeIdentifier = .distanceCycling
                unit = .mile()
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

                        guard let quantityType = HKObjectType.quantityType(forIdentifier: typeIdentifier) else {
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
                                if let quantity = statistics.sumQuantity() {
                                    let value = quantity.doubleValue(for: unit)
                                    let date = statistics.startDate
                                    let dataSet = DataSet(date: date, value: value)
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
            }
        }

        func shareResult(enteredGoal: Double, activity: Activity, progressState: ProgressState) {
            let result = Int((sumDataSets / enteredGoal * 100)).formatted(.percent)
            var resultString = ""
            switch progressState {
            case .doneAhead, .doneBehind:
                resultString = "Challenge Tracker for \(activity.rawValue.capitalized): I have done \(result) of \(enteredGoal) \(activity.unit)."
            case .completed:
                resultString = "Challenge Tracker for \(activity.rawValue.capitalized): I completed this month goal."
            }

            let activityController = UIActivityViewController(activityItems: [resultString], applicationActivities: nil)
            UIWindow.key?.rootViewController!
                .present(activityController, animated: true)
        }
    }
}

extension ContentView: AXChartDescriptorRepresentable {
    func makeChartDescriptor() -> AXChartDescriptor {
        let xAxis = AXCategoricalDataAxisDescriptor(
            title: "Date",
            categoryOrder: vm.dataSets.map { "\($0.date.formatted(date: .numeric, time: .omitted))" }
        )

        let min = vm.dataSets.map(\.value).min() ?? 0.0
        let max = vm.dataSets.map(\.value).max() ?? 0.0

        let yAxis = AXNumericDataAxisDescriptor(
            title: "\(activity.unit) done",
            range: min...max,
            gridlinePositions: []) { value in
                "\(value) \(activity.unit)"
            }

        let series = AXDataSeriesDescriptor(
            name: "",
            isContinuous: false,
            dataPoints: vm.dataSets.map {
                .init(x: $0.date.formatted(date: .numeric, time: .omitted), y: $0.value)
            }
        )

        return AXChartDescriptor(
            title: "A chart representing \(activity.rawValue)",
            summary: "your maximum amount is \(max) \(activity.unit)",
            xAxis: xAxis,
            yAxis: yAxis,
            additionalAxes: [],
            series: [series])
    }
}
