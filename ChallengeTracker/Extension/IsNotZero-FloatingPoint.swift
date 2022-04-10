//
//  IsNotZero-FloatingPoint.swift
//  ChallengeTracker
//
//  Created by Nigel Gee on 10/04/2022.
//

import Foundation

extension FloatingPoint {
    /// A Boolean value indicating whether the instance is not equal to zero.
    ///
    /// The `isNotZero` property of a value `x` is `true` when `x` does represents either
    /// `-0.0` or `+0.0`. `x.isNotZero` is equivalent to the following comparison:
    /// `x != 0.0`.
    var isNotZero: Bool {
        self.isZero == false
    }
}
