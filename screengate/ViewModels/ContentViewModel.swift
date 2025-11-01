//
//  ContentViewModel.swift
//  screengate
//
//  Created by gokul on 01/11/25.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class ContentViewModel: ObservableObject {
    @Published var contentItems: [ContentModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    init() {
        loadContent()
    }

    func loadContent() {
        isLoading = true
        errorMessage = nil

        // Simulate async data loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.contentItems = [
                ContentModel(title: "Hello, world!", subtitle: "Welcome to ScreenGate", isCompleted: false),
                ContentModel(title: "MVVM Pattern", subtitle: "Model-View-ViewModel architecture", isCompleted: true),
                ContentModel(title: "SwiftUI", subtitle: "Modern UI framework for iOS", isCompleted: false)
            ]
            self.isLoading = false
        }
    }

    func toggleCompletion(for item: ContentModel) {
        if let index = contentItems.firstIndex(where: { $0.id == item.id }) {
            contentItems[index].isCompleted.toggle()
        }
    }

    func addNewItem(title: String, subtitle: String) {
        let newItem = ContentModel(title: title, subtitle: subtitle)
        contentItems.append(newItem)
    }

    func deleteItem(at offsets: IndexSet) {
        contentItems.remove(atOffsets: offsets)
    }
}