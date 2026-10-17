import Foundation

enum ConfigurationPolicy {
    static func value(environment: String?, bundled: String?) -> String? {
        for candidate in [environment, bundled] {
            guard let value = candidate?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !value.isEmpty, !value.contains("$("),
                  !value.lowercased().hasPrefix("your-"),
                  !value.uppercased().hasPrefix("YOUR_"), !value.uppercased().hasPrefix("REPLACE_") else { continue }
            return value
        }
        return nil
    }

    static func secureURL(_ value: String) -> URL? {
        guard let url = URL(string: value), url.scheme?.lowercased() == "https",
              let host = url.host, !host.isEmpty,
              url.user == nil, url.password == nil else { return nil }
        return url
    }
}

enum PurchaseEntitlementPolicy {
    static func isActive(revocationDate: Date?, expirationDate: Date?, isUpgraded: Bool, now: Date = .now) -> Bool {
        revocationDate == nil && !isUpgraded && (expirationDate.map { $0 > now } ?? true)
    }
}
