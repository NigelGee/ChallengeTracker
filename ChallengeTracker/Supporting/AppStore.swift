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
    @AppStorage("runsSinceLastRequest") var runsSinceLastRequest = 1
    @AppStorage("version") var version = ""

    @Published var showingOverlay = false
    let configuration = SKOverlay.AppConfiguration(appIdentifier: "1465159349", position: .bottom)

    func check() {
        let appBuild = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let currentVersion = "v\(appVersion) b\(appBuild)"

        guard version == currentVersion else {
            runsSinceLastRequest = 1
            version = currentVersion
            return
        }

        runsSinceLastRequest += 1
        if runsSinceLastRequest.isMultiple(of: 10)  {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        } else if runsSinceLastRequest == threshold - 3 {
            showingOverlay = true
        }
    }
}
