//
//  SavedTrip.swift
//  TravelCompanion
//
//  Created by User on 4/2/26.
//

import Foundation
import SwiftData

@Model
final class SavedTrip {
    var id: UUID
    var type: String
    var title: String
    var subtitle: String
    var route: String
    var summary: String
    var savedAt: Date

    init(
        id: UUID = UUID(),
        type: String,
        title: String,
        subtitle: String,
        route: String,
        summary: String,
        savedAt: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.subtitle = subtitle
        self.route = route
        self.summary = summary
        self.savedAt = savedAt
    }
}
