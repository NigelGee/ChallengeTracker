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
    let activity: Activity

    var body: some View {
        VStack {
            List(dataSets) { dataSet in
                HStack {
                    Text(dataSet.date, style: .date)
                    Spacer()
                    Text("\(dataSet.value, specifier: activity.specifier) \(activity.unit)")
                        .foregroundColor(dataSet.value >= goalPerDay ? .primary : .secondary)
                }
                .accessibilityElement(children: .combine)
            }
        }
    }
}

struct ListDataView_Previews: PreviewProvider {
    static var previews: some View {
        ListDataView(dataSets: DataSet.example, goalPerDay: 6.1, activity: .distance)
            .preferredColorScheme(.dark)
    }
}
