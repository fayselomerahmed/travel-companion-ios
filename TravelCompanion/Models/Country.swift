//
//  Country.swift
//  TravelCompanion
//
//  Created by User on 3/10/26.
//

import Foundation

struct Country: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let code: String
}
