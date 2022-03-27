//
//  Chart-Extension.swift
//  ChallengeTracker
//
//  Created by Nigel Gee on 27/03/2022.
//

import SwiftUI

/// extension for audio graph
extension ContentView: AXChartDescriptorRepresentable {
    func makeChartDescriptor() -> AXChartDescriptor {
        let xAxis = AXCategoricalDataAxisDescriptor(
            title: "Date",
            categoryOrder: vm.dataSets.map { "\($0.date.formatted(date: .numeric, time: .omitted))" }
        )

        let min = vm.dataSets.map(\.value).min() ?? 0.0
        let max = vm.dataSets.map(\.value).max() ?? 0.0

        let yAxis = AXNumericDataAxisDescriptor(
            title: "amount done",
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
