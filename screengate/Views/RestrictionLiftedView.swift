//
//  RestrictionLiftedView.swift
//  screengate
//
//  Created by Gokul on 2025/11/05.
//

import SwiftUI

struct RestrictionLiftedView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 30) {
            // Success Icon
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)

            // Title
            Text("Restrictions Lifted!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            // Description
            Text("Take a mindful break and enjoy your digital freedom.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            // Action Button
            Button(action: {
                dismiss()
            }) {
                Text("Back to App")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
        .navigationTitle("Break Time")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct RestrictionLiftedView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RestrictionLiftedView()
        }
    }
}