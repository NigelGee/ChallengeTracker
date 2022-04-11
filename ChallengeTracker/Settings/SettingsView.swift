//
//  SettingsView.swift
//  ChallengeTracker
//
//  Created by Nigel Gee on 23/03/2022.
//

import SwiftUI

/// A view that user can set up the tracking challenge
struct SettingsView: View {
    @StateObject var vm = ViewModel()
    @Environment(\.dynamicTypeSize) var typeSize

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                Picker("Activity:", selection: $vm.activity) {
                    ForEach(Activity.allCases, id: \.self) {
                        Text($0.rawValue.capitalized)
                    }
                }

                if vm.isDistanceActivity {
                    Picker("Distance Type", selection: $vm.distanceType) {
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

                        TextField("Enter goal target", value: $vm.inputAmount, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .multilineTextAlignment(.center)
                            .accessibilityHint("Enter goal target")
                            .keyboardType(.decimalPad)
                    }

                    Toggle("Per Day", isOn: $vm.perDay)
                }

                Section {
                    if typeSize > .xxLarge {
                        VStack(alignment: .leading) {
                            Text("Goal per Month:")
                            Text("\(vm.enteredGoal, specifier: vm.activity.specifier) \(vm.unit)")
                        }
                        .accessibilityElement(children: .combine)
                    } else {
                        HStack {
                            Text("Goal per Month:")
                            Spacer()
                            Text("\(vm.enteredGoal, specifier: vm.activity.specifier) \(vm.unit)")
                        }
                        .accessibilityElement(children: .combine)
                    }
                }

                Section {
                    HStack {
                        Spacer()
                        Text("\(vm.suggestedGoal, specifier: vm.activity.specifier) \(vm.unit) \(vm.perDay ? "per day" : "per month")")
                        Spacer()
                    }
                    .animation(.easeInOut, value: vm.suggestedGoal)
                    .foregroundColor(.secondary)
                } header: {
                    Text("Suggested Goal")
                } footer: {
                    vm.footerText
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
            .onAppear(perform: vm.getHealthData)
            .onChange(of: vm.perDay) { _ in
                vm.perMonth()
                vm.getHealthData()
            }
            .onChange(of: vm.inputAmount) { _ in
                vm.perMonth()
            }
            .onChange(of: vm.distanceType) { _ in
                vm.getHealthData()
            }
            .onChange(of: vm.activity) { _ in
                vm.getHealthData()
            }
            .alert(vm.alertTitle, isPresented: $vm.showingAlert) {
                Button("OK") { }
            } message: {
                vm.alertMessage
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
