//
//  AffiliateLinks.swift
//  TravelCompanion
//
//  Created by Codex on 6/6/26.
//

import Foundation

enum AffiliateLinks {
    static let eSIM = configuredURL(named: "ESIM_AFFILIATE_URL")
    static let lounge = configuredURL(named: "LOUNGE_AFFILIATE_URL")
    static let insurance = configuredURL(named: "INSURANCE_AFFILIATE_URL")
    static let transfer = configuredURL(named: "TRANSFER_AFFILIATE_URL")

    private static func configuredURL(named key: String) -> URL? {
        let rawValue = ProcessInfo.processInfo.environment[key]
            ?? Bundle.main.object(forInfoDictionaryKey: key) as? String

        guard let rawValue,
              !rawValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let url = URL(string: rawValue),
              ["https", "itms-apps"].contains(url.scheme?.lowercased()) else {
            return nil
        }

        return url
    }
}
