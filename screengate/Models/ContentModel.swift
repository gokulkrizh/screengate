//
//  ContentModel.swift
//  screengate
//
//  Created by gokul on 01/11/25.
//

import Foundation

struct ContentModel: Identifiable, Codable {
    let id = UUID()
    var title: String
    var subtitle: String
    var isCompleted: Bool

    init(title: String, subtitle: String, isCompleted: Bool = false) {
        self.title = title
        self.subtitle = subtitle
        self.isCompleted = isCompleted
    }
}