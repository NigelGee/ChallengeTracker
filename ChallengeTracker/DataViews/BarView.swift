//
//  BarView.swift
//  ChallengeTracker
//
//  Created by Nigel Gee on 16/03/2022.
//

import SwiftUI

/// View for a single bar view
struct BarView: View {
    let doneAmount: Double
    let activity: Activity

    var body: some View {
        Rectangle()
            .frame(width: 5, height: doneAmount)
            .foregroundColor(activity.color)
    }
}

struct BarView_Previews: PreviewProvider {
    static var previews: some View {
        BarView(doneAmount: 50, activity: .distance)
            .preferredColorScheme(.dark)
    }
}
