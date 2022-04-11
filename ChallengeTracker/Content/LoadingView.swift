//
//  LoadingView.swift
//  ChallengeTracker
//
//  Created by Nigel Gee on 11/04/2022.
//

import SwiftUI

struct LoadingView: View {
    let activity: Activity

    var body: some View {
        VStack {
            ProgressView()
                .padding()
            Text("Loading…")
                .padding()
        }
        .font(.headline)
        .foregroundColor(activity.color)
        .frame(width: 150, height: 150)
        .background(.ultraThickMaterial)
        .cornerRadius(15)

    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView(activity: .walking)
            .preferredColorScheme(.dark)
    }
}
