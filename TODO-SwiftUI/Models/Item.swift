//
//  Item.swift
//  TODO-SwiftUI
//
//  Created by Appsquadz on 19/01/26.
//


import Foundation
import SwiftData

@Model
final class Item: Identifiable {
    @Attribute(.unique) var id: UUID
    var title: String
    var notes: String
    var priority: Int
    var dueDate: Date?
    var completed: Bool
    var timestamp: Date

    init(id: UUID = UUID(), title: String, notes: String = "", priority: Int = 1, dueDate: Date? = nil, completed: Bool = false, timestamp: Date = Date()) {
        self.id = id
        self.title = title
        self.notes = notes
        self.priority = priority
        self.dueDate = dueDate
        self.completed = completed
        self.timestamp = timestamp
    }
}

extension Item {
    enum Priority: Int, CaseIterable, Identifiable {
        case low = 0
        case medium = 1
        case high = 2
        var id: Int { rawValue }
        var label: String {
            switch self {
            case .low: return "Low"
            case .medium: return "Medium"
            case .high: return "High"
            }
        }
        var systemImage: String {
            switch self {
            case .low: return "arrow.down.circle"
            case .medium: return "circle"
            case .high: return "arrow.up.circle"
            }
        }
    }

    var priorityEnum: Priority {
        get { Priority(rawValue: priority) ?? .medium }
        set { priority = newValue.rawValue }
    }
}
