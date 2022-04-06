//
//  CaptionView.swift
//  ChallengeTracker
//
//  Created by Nigel Gee on 05/04/2022.
//

import SwiftUI

/// A view that show caption text under the Chart View
struct CaptionView: View {
    var body: some View {
        Group {
            Text("Tap on chart to show details")
                .accessibilityHidden(true)
            Text("Updated: \(Date.now, format: .dateTime)")
        }
        .font(.caption2)
        .foregroundColor(.secondary)
    }
}

struct CaptionView_Previews: PreviewProvider {
    static var previews: some View {
        CaptionView()
    }
}
