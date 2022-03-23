//
//  SettingsView.swift
//  ChallengeTracker
//
//  Created by Nigel Gee on 23/03/2022.
//

import SwiftUI

/// A view that user can set up the tracking challenge
struct SettingsView: View {
    /// Store the activity type to User Defaults
    @AppStorage("activity") var activity = Activity.distance

    /// Store the target goal to User Defaults
    @AppStorage("enteredGoal") var enteredGoal = 0.0

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                Picker("Choose an Activity Type", selection: $activity) {
                    ForEach(Activity.allCases, id: \.self) {
                        Text($0.rawValue.capitalized)
                    }
                }
                
                HStack {
                    Text("Goal:")
                        .padding(.trailing)
                        .accessibilityHidden(true)

                    TextField("Enter goal target", value: $enteredGoal, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.center)
                        .accessibilityHint("Enter goal target")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Dismiss", systemImage: "x.circle")
                    }
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .preferredColorScheme(.dark)
    }
}
