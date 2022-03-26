//
//  EmptyProgressView.swift
//  ChallengeTracker
//
//  Created by Nigel Gee on 24/03/2022.
//

import SwiftUI

struct EmptyProgressView: View {
    @State private var showingNoData = false

    var body: some View {
        VStack {
            ProgressView()

            if showingNoData {
                Group {
                    Text("No Data Found!")
                    Text("Select a different activity")
                }
                .foregroundColor(.secondary)
                .font(.caption.italic())
            }
        }
        .onAppear(perform: noData)
    }

    func noData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            withAnimation {
                showingNoData = true
            }
        }
    }
}

struct EmptyProgressView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyProgressView()
            .preferredColorScheme(.dark)
    }
}
