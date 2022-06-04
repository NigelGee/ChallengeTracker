//
//  AppReview.swift
//  ChallengeTracker
//
//  Created by Nigel Gee on 23/05/2022.
//

import SwiftUI
import StoreKit

class AppStore: ObservableObject {
    var threshold = 10
    @AppStorage("runsSinceLastRequest") var runsSinceLastRequest = 0

    @Published var showingOverlay = false
    let configuration = SKOverlay.AppConfiguration(appIdentifier: "1465159349", position: .bottom)

    func check() {
        runsSinceLastRequest += 1

        if runsSinceLastRequest >= threshold {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        } else if runsSinceLastRequest >= threshold - 3 && runsSinceLastRequest <= threshold {
            showingOverlay = true
        }
    }
}
