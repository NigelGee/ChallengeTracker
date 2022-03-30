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

    /// Store the type of distance measurement to User Defaults
    @AppStorage("distanceType") var distanceType = DistanceType.miles

    /// A String of the unit type of activity
    var unit: String {
        if activity.unit == "mi" {
            switch distanceType {
            case .miles:
                return "mi"
            case .kilometers:
                return "km"
            }
        }
        return activity.unit
    }

    /// Store the target goal to User Defaults
    @AppStorage("enteredGoal") var enteredGoal = 0.0
    @AppStorage("inputAmount") var inputAmount = 0.0
    @AppStorage("perDay") private var perDay = false

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                Picker("Activity:", selection: $activity) {
                    ForEach(Activity.allCases, id: \.self) {
                        Text($0.rawValue.capitalized)
                    }
                }

                if activity == .distance || activity == .wheelchair || activity == .cycling {
                    Picker("Distance Type", selection: $distanceType) {
                        ForEach(DistanceType.allCases, id:\.self) {
                            Text($0.rawValue.capitalized)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section {
                    HStack {
                        Text("Goal:")
                            .padding(.trailing)
                            .accessibilityHidden(true)

                        TextField("Enter goal target", value: $inputAmount, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .multilineTextAlignment(.center)
                            .accessibilityHint("Enter goal target")
                            .keyboardType(.decimalPad)
                    }

                    Toggle("Per Day", isOn: $perDay)
                }

                Section {
                    HStack {
                        Text("Goal per Month:")
                        Spacer()
                        Text("\(enteredGoal, specifier: activity.specifier) \(unit)")
                    }
                    .accessibilityElement(children: .combine)
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
            .onChange(of: perDay) { _ in
                perMonth()
            }
            .onChange(of: inputAmount) { _ in
                perMonth()
            }
        }
    }

    func perMonth() {
        if perDay {
            enteredGoal = inputAmount * Double(Date.now.endDateOfMonth.dayNumber)
        } else {
            enteredGoal = inputAmount
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .preferredColorScheme(.dark)
    }
}
