//
//  ListDataView.swift
//  ChallengeTracker
//
//  Created by Nigel Gee on 16/03/2022.
//

import SwiftUI

/// View that show the list of data from heath data
struct ListDataView: View {
    let dataSets: [DataSet]
    let goalPerDay: Double

    @Environment(\.dynamicTypeSize) var typeSize
    
    /// Store the activity type to User Defaults
    @AppStorage("activity") var activity = Activity.walking

    /// Store the type of distance measurement to User Defaults
    @AppStorage("distanceType") var distanceType = DistanceType.miles

    var body: some View {
        VStack {
            List(dataSets.reversed()) { dataSet in
                if typeSize > .xxLarge {
                    VStack(alignment: .leading) {
                        Text(dataSet.date, style: .date)
                        Text("\(dataSet.value, specifier: activity.specifier) \(unit)")
                            .foregroundColor(dataSet.value >= goalPerDay ? .primary : .secondary)
                    }
                    .accessibilityElement(children: .combine)
                } else {
                    HStack {
                        Text(dataSet.date, style: .date)
                        Spacer()
                        Text("\(dataSet.value, specifier: activity.specifier) \(unit)")
                            .foregroundColor(dataSet.value >= goalPerDay ? .primary : .secondary)
                    }
                    .accessibilityElement(children: .combine)
                }
            }
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
}

struct ListDataView_Previews: PreviewProvider {
    static var previews: some View {
        ListDataView(dataSets: DataSet.example, goalPerDay: 6.1, activity: .walking)
            .preferredColorScheme(.dark)
    }
}
