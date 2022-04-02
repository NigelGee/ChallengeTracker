//
//  ContentView.swift
//  ChallengeTracker
//
//  Created by Nigel Gee on 16/03/2022.
//

import SwiftUI

struct ContentView: View {

    /// Store the target goal to User Defaults
    @AppStorage("enteredGoal") var enteredGoal = 0.0

    /// Store the activity type to User Defaults
    @AppStorage("activity") var activity = Activity.distance
    /// Store the type of distance measurement to User Defaults
    @AppStorage("distanceType") var distanceType = DistanceType.miles

    @StateObject var vm = ViewModel()

    /// Calculate the target goal by number of days in the month
    var goalPerDay: Double {
        let date = Date.now
        let endDateOfMonth = date.endDateOfMonth
        let daysInMonth = endDateOfMonth.dayNumber
        return enteredGoal / Double(daysInMonth)
    }

    var goalToDate: Double {
        goalPerDay * Double(Date.now.dayNumber)
    }

    var progressState: ProgressState {
        if vm.sumDataSets > enteredGoal {
            return .completed
        } else if vm.sumDataSets > goalPerDay {
            return .doneAhead
        } else {
            return .doneBehind
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                Button {
                    vm.showingSettings = true
                } label: {
                    Text(activity.rawValue.capitalized)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 5)
                }
                .buttonStyle(.borderedProminent)
                .tint(activity.color)
                .padding(.horizontal)

                Spacer()
                ScrollView(showsIndicators: false) {
                    VStack {
                        RingProgressView(enteredGoal: enteredGoal,
                                         amountDone: vm.sumDataSets)
                        .frame(height: 230)
                        .padding(.top)

                        ActivityTextView(dataSets: vm.dataSets,
                                         enteredGoal: enteredGoal,
                                         progressState: progressState)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(width: 260)

                        BarChartView(dataSets: vm.dataSets,
                                     enteredGoal: enteredGoal)
                            .frame(height: 230)
                            .padding()
                            .background(.ultraThickMaterial)
                            .cornerRadius(10)
                            .onTapGesture {
                                vm.showingDetails = true
                            }
                            .accessibilityElement()
                            .accessibilityLabel("chart of \(activity.rawValue)")
                            .accessibilityChartDescriptor(self)
                            .accessibilityAddTraits(.isButton)
                            .sheet(isPresented: $vm.showingDetails) {
                                ListDataView(dataSets: vm.dataSets,
                                             goalPerDay: goalPerDay)
                            }

                        Group {
                            Text("Tap on chart to show details")
                                .accessibilityHidden(true)
                            Text("Updated: \(Date.now, format: .dateTime)")
                        }
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    }
                }
                .emptyState(of: vm.dataSets, emptyContent: ProgressView.init)

                Spacer()

                Button("Refresh") {
                    vm.getHealthData(for: activity, in: distanceType)
                }
                .buttonStyle(.bordered)
                .padding(.bottom)
            }
            .navigationTitle("\(Date.now, format: .dateTime.month(.wide).year())")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        vm.shareResult(enteredGoal: enteredGoal,
                                       activity: activity,
                                       progressState: progressState,
                                       distanceType: distanceType)
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    .disabled(vm.dataSets.isEmpty)
                }
            }
            .onAppear {
                if enteredGoal.isZero {
                    vm.showingSettings = true
                }
                vm.getHealthData(for: activity, in: distanceType)
            }
            .onChange(of: activity) { _ in
                vm.getHealthData(for: activity, in: distanceType)
            }
            .onChange(of: distanceType) { _ in
                vm.getHealthData(for: activity, in: distanceType)
            }
            .onChange(of: enteredGoal) { _ in
                vm.getHealthData(for: activity, in: distanceType)
            }
            .alert("Error", isPresented: $vm.showingErrorAlert) {
                Button("OK") { }
            } message: {
                Text("Opps, error get health data, check that you allow the app to read the data.")
            }
            .alert("Error", isPresented: $vm.showingNoHealthAlert) {
                Button("OK") { }
            } message: {
                Text("Device does not support health data. Please use another device.")
            }
            .fullScreenCover(isPresented: $vm.showingSettings, content: SettingsView.init)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
