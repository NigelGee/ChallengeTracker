//
//  RingView.swift
//  ChallengeTracker
//
//  Created by Nigel Gee on 16/03/2022.
//

import SwiftUI

/// A view for single ring view
struct RingView: View {
    /// Require a Double 0 to 1 for the trim of circle
    let amount: Double

    /// Require color for circle fill
    let color: Color

    var body: some View {
        Circle()
            .trim(from: 0.0, to: amount)
            .stroke(color, style: StrokeStyle(lineWidth: 18, lineCap: .round))
            .rotationEffect(.degrees(-90))
            .padding()
            .frame(maxWidth: .infinity)
            .animation(.linear(duration: 2), value: amount)
    }
}

struct RingView_Previews: PreviewProvider {
    static var previews: some View {
        RingView(amount: 0.7, color: .distance)
            .preferredColorScheme(.dark)
    }
}
