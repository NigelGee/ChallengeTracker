//
//  ContentView.swift
//  ChallengeTracker
//
//  Created by Nigel Gee on 16/03/2022.
//

import SwiftUI

struct ContentView: View {
    @StateObject var vm = ViewModel()

    var body: some View {
        NavigationView {
            VStack {
                Button {
                    vm.showingSettings = true
                } label: {
                    Text(vm.activity.rawValue.capitalized)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 5)
                }
                .buttonStyle(.borderedProminent)
                .tint(vm.activity.color)
                .padding(.horizontal)

                Spacer()
                ScrollView(showsIndicators: false) {
                    VStack {
                        RingProgressView(enteredGoal: vm.enteredGoal,
                                         amountDone: vm.sumDataSets)
                        .frame(height: 230)
                        .padding(.top)

                        ActivityTextView(dataSets: vm.dataSets,
                                         enteredGoal: vm.enteredGoal,
                                         progressState: vm.progressState)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(width: 260)

                        BarChartView(dataSets: vm.dataSets,
                                     enteredGoal: vm.enteredGoal)
                            .frame(height: 230)
                            .padding()
                            .background(.ultraThickMaterial)
                            .cornerRadius(10)
                            .onTapGesture {
                                vm.showingDetails = true
                            }
                            .accessibilityElement()
                            .accessibilityLabel("chart of \(vm.activity.rawValue)")
                            .accessibilityChartDescriptor(self)
                            .accessibilityAddTraits(.isButton)
                            .sheet(isPresented: $vm.showingDetails) {
                                ListDataView(dataSets: vm.dataSets,
                                             goalPerDay: vm.goalPerDay)
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

                Button("Refresh", action: vm.getHealthData)
                .buttonStyle(.bordered)
                .padding(.bottom)
            }
            .navigationTitle("\(Date.now, format: .dateTime.month(.wide).year())")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        vm.shareResult(enteredGoal: vm.enteredGoal,
                                       activity: vm.activity,
                                       progressState: vm.progressState,
                                       distanceType: vm.distanceType)
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    .disabled(vm.dataSets.isEmpty)
                }
            }
            .onAppear(perform: vm.checkStatus)
            .onChange(of: vm.activity) { _ in vm.getHealthData() }
            .onChange(of: vm.distanceType) { _ in vm.getHealthData() }
            .onChange(of: vm.enteredGoal) { _ in vm.getHealthData() }
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
