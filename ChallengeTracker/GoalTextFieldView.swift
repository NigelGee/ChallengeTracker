//
//  GoalTextFieldView.swift
//  ChallengeTracker
//
//  Created by Nigel Gee on 16/03/2022.
//

import SwiftUI

/// A view for TextField style for target goal
struct GoalTextFieldView: View {
    @Binding var enteredGoal: Double

    var body: some View {
        HStack {
            Text("Goal:")
                .padding(.trailing)
                .accessibilityHidden(true)

            TextField("Enter goal target", value: $enteredGoal, format: .number)
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.center)
                .accessibilityHint("Enter goal target")
        }
        .padding(.horizontal)
    }
}

struct GoalTextFieldView_Previews: PreviewProvider {
    static var previews: some View {
        GoalTextFieldView(enteredGoal: .constant(185.6))
    }
}
