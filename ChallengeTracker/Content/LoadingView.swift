//
//  LoadingView.swift
//  ChallengeTracker
//
//  Created by Nigel Gee on 11/04/2022.
//

import SwiftUI

/// Loading View overlay while getting health data
struct LoadingView: View {
    let activity: Activity

    var body: some View {
        VStack {
            ProgressView()
                .tint(activity.color)
                .scaleEffect(2.5)
                .padding()
            Text("Loading…")
                .font(.system(size: 18))
                .fontWeight(.bold)
                .padding()
        }
        .foregroundColor(activity.color)
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .background(.ultraThickMaterial)
        .cornerRadius(15)
        .padding(.horizontal, 20)
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView(activity: .walking)
            .preferredColorScheme(.dark)
    }
}
