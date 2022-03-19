//
//  ActivityPickerView.swift
//  ChallengeTracker
//
//  Created by Nigel Gee on 16/03/2022.
//

import SwiftUI

/// A view for activity picker
struct ActivityPickerView: View {
    @Binding var activity: Activity
    
    var body: some View {
        HStack {
            Text("Activity Type:")
                .accessibilityHidden(true)
            Spacer()
            Picker("Choose an Activity Type", selection: $activity) {
                ForEach(Activity.allCases, id: \.self) {
                    Text($0.rawValue.capitalized)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct ActivityPickerView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityPickerView(activity: .constant(.distance))
    }
}
