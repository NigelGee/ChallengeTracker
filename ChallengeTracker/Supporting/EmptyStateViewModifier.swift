//
//  EmptyStateViewModifier.swift
//  ChallengeTracker
//
//  Created by Nigel Gee on 16/03/2022.
//

import SwiftUI

/// A modifier to show a view if there is no data
fileprivate struct EmptyStateViewModifier<EmptyContent: View>: ViewModifier {
    var isEmpty: Bool
    let emptyContent: () -> EmptyContent

    func body(content: Content) -> some View {
        if isEmpty {
            emptyContent()
        } else {
            content
        }
    }
}

extension View {
    /// A modifier to show a view if there is no data
    /// - Parameters:
    ///   - collection: A collection of data that may be nil
    ///   - emptyContent: A View to show when no data
    /// - Returns: A original content if collection has data else the `emptyContent`
    func emptyState<T: Collection, EmptyContent: View>(of collection: T,
                                                       emptyContent: @escaping () -> EmptyContent
    ) -> some View {
        modifier(EmptyStateViewModifier(isEmpty: collection.isEmpty, emptyContent: emptyContent))
    }
}
