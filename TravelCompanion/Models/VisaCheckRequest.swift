//
//  VisaCheckRequest.swift
//  TravelCompanion
//
//  Created by User on 3/16/26.
//

import Foundation

struct VisaCheckRequest: Codable {
    let passport: String
    let destination: String
}
