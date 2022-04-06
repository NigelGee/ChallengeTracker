//
//  AlertItem.swift
//  ChallengeTracker
//
//  Created by Nigel Gee on 06/04/2022.
//

import SwiftUI

/// Error alerts
struct AlertItem: Identifiable {
    let id = UUID()
    var title: String
    var message: Text

    static let retrieveError = AlertItem(
        title: "Retrieving Data Error",
        message: Text("Opps, error get health data, check that you allow the app to read the data.")
    )

    static let deviceError = AlertItem(
        title: "Device Error",
        message: Text("Device does not support health data. Please use another device.")
    )
}
