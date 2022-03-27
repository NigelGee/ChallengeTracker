//
//  EmptyProgressView.swift
//  ChallengeTracker
//
//  Created by Nigel Gee on 24/03/2022.
//

import SwiftUI

struct EmptyProgressView: View {
    @Binding var showingNoData: Bool

    var body: some View {
        Group {
            if showingNoData {
                Group {
                    Text("No Data Found!")
                    Text("Select a different activity")
                }
                .foregroundColor(.secondary)
                .font(.caption.italic())
            } else {
                ProgressView()
            }
        }
    }
}

struct EmptyProgressView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyProgressView(showingNoData: .constant(false))
            .preferredColorScheme(.dark)
    }
}
