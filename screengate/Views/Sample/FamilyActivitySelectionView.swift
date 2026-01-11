//
//  FamilyActivitySelectionView.swift
//  DeviceActivityMonitorDemo
//
//  Created by Gokul on 2025/11/05.
//

import SwiftUI
import FamilyControls

struct FamilyActivitySelectionView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @Binding var selection: FamilyActivitySelection
    
    @State private var selectionTemp: FamilyActivitySelection = FamilyActivitySelection()
    
    var body: some View {
        NavigationStack {
            FamilyActivityPicker(selection: $selectionTemp)
                .ignoresSafeArea()
                .navigationTitle("Select Activity")
                .navigationBarTitleDisplayMode(.large)
                .toolbar(content: {
                    ToolbarItem(placement: .topBarTrailing, content: {
                        Button(action: {
                            self.dismiss()
                        }, label: {
                            Image(systemName: "xmark")
                        })
                        .buttonStyle(.bordered)
                    })
                    .sharedBackgroundVisibility(.hidden)
                    
                    ToolbarItem(placement: .topBarTrailing, content: {
                        Button(action: {
                            selection = selectionTemp
                            self.dismiss()
                        }, label: {
                            Image(systemName: "checkmark")
                        })
                        .buttonStyle(.glass)
                    })
                    .sharedBackgroundVisibility(.hidden)
                })
                .onAppear {
                    self.selectionTemp = selection
                }
        }

    }
}
