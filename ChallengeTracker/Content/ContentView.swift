//
//  ContentView.swift
//  ChallengeTracker
//
//  Created by Nigel Gee on 16/03/2022.
//

import SwiftUI

struct ContentView: View {
    @StateObject var vm = ViewModel()
    @StateObject var appStore = AppStore()
    @Environment(\.scenePhase) var scenePhase

    var body: some View {
        NavigationView {
            ZStack {
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
                                             goalToDate: vm.animatedGoal,
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

                            if #available(iOS 16, *) {
                                ChartView(dataSets: vm.dataSets, enteredGoal: vm.enteredGoal)
                                    .padding(.horizontal)
                                    .onTapGesture {
                                        vm.showingDetails = true
                                    }
                            } else {
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
                            }

                            CaptionView()

                        }
                        .sheet(isPresented: $vm.showingDetails) {
                            ListDataView(dataSets: vm.dataSets,
                                         goalPerDay: vm.goalPerDay)
                        }
                    }

                    Spacer()
                }

                if vm.dataSets.isEmpty {
                    LoadingView(activity: vm.activity)
                }
            }
            .navigationTitle("\(Date.now, format: .dateTime.month(.wide).year())")
            .toolbar {
                vm.shareToolbarItem
                vm.refreshToolbarItem
            }
            .onChange(of: scenePhase) { phase in
                if phase == .active {
                    vm.checkStatus()
                    appStore.check()
                } else if phase == .background {
                    vm.animatedGoal = 0
                    vm.dataSets.removeAll()
                }
            }
            .alert(vm.alertTitle, isPresented: $vm.showingAlert) {
                Button("OK") { }
            } message: {
                vm.alertMessage
            }
            .fullScreenCover(isPresented: $vm.showingSettings, content: SettingsView.init)
            .appStoreOverlay(isPresented: $appStore.showingOverlay) {
                appStore.configuration
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
