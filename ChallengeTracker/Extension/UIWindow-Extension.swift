//
//  UIWindow-Extension.swift
//  ChallengeTracker
//
//  Created by Nigel Gee on 26/03/2022.
//

import UIKit

/// a extension to UIWindow for share sheet
extension UIWindow {
    static var key: UIWindow? {
        guard let scene = UIApplication.shared.connectedScenes.first,
              let windowSceneDelegate = scene.delegate as? UIWindowSceneDelegate,
              let window = windowSceneDelegate.window else {
            return nil
        }
        return window
    }
}
