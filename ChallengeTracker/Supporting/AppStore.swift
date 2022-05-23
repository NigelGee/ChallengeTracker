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
    @AppStorage("version") var version = ""

    @Published var showingOverlay = false
    let configuration = SKOverlay.AppConfiguration(appIdentifier: "1465159349", position: .bottom)

    func check() {
        runsSinceLastRequest += 1
        let appBuild = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let thisVersion = "v\(appVersion)b\(appBuild)"

        if thisVersion != version {
            if runsSinceLastRequest >= threshold {
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                    version = thisVersion
                    runsSinceLastRequest = 0
                }
            } else if runsSinceLastRequest == threshold - 2 {
                showingOverlay = true
            }
        } else {
            runsSinceLastRequest = 0
        }
    }
}
