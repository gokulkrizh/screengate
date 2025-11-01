//
//  ContentView.swift
//  screengate
//
//  Created by gokul on 01/11/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading content...")
                        .padding()
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    List {
                        ForEach(viewModel.contentItems) { item in
                            ContentItemView(item: item) {
                                viewModel.toggleCompletion(for: item)
                            }
                        }
                        .onDelete(perform: viewModel.deleteItem)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("ScreenGate")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        viewModel.addNewItem(
                            title: "New Item",
                            subtitle: "Added at \(Date().formatted(date: .omitted, time: .shortened))"
                        )
                    }
                }
            }
        }
    }
}

struct ContentItemView: View {
    let item: ContentModel
    let onTap: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                    .strikethrough(item.isCompleted, color: .primary)
                Text(item.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(item.isCompleted ? .green : .gray)
                .font(.title2)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

#Preview {
    ContentView()
}
