import Foundation

struct FrankfurtFlightStatus {
    let flightCode: String
    let terminal: String?
    let gate: String?
    let status: String?
    let sourceName: String
    let sourceURL: URL
}

final class FrankfurtAirportService {
    static let shared = FrankfurtAirportService()

    private let departuresURL = URL(string: "https://www.frankfurt-airport.com/en/flights-and-transfer/departures.html")!
    private let fallbackDeparturesURL = URL(string: "https://www.fra-airport.com/en/departures/")!

    private init() {}

    func status(for flightCode: String) async -> FrankfurtFlightStatus? {
        let normalizedCode = flightCode.uppercased().replacingOccurrences(of: " ", with: "")

        if let status = await status(from: departuresURL, flightCode: normalizedCode, sourceName: "Frankfurt Airport") {
            return status
        }

        // Secondary public FRA board fallback. Keep the UI honest by showing the source name when this is used.
        return await status(from: fallbackDeparturesURL, flightCode: normalizedCode, sourceName: "FRA Airport Status")
    }

    private func status(from url: URL, flightCode: String, sourceName: String) async -> FrankfurtFlightStatus? {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode),
                  let html = String(data: data, encoding: .utf8)
            else { return nil }

            return parseStatus(from: html, flightCode: flightCode, sourceName: sourceName, sourceURL: url)
        } catch {
            return nil
        }
    }

    private func parseStatus(from html: String, flightCode: String, sourceName: String, sourceURL: URL) -> FrankfurtFlightStatus? {
        let normalizedHTML = html
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&#160;", with: " ")
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)

        let spacedCode = flightCode.replacingOccurrences(
            of: #"^([A-Z]{2,3})([0-9].*)$"#,
            with: "$1 $2",
            options: .regularExpression
        )

        guard let range = normalizedHTML.range(of: spacedCode, options: [.caseInsensitive]) ??
                normalizedHTML.range(of: flightCode, options: [.caseInsensitive])
        else { return nil }

        let lower = normalizedHTML.index(range.lowerBound, offsetBy: -900, limitedBy: normalizedHTML.startIndex) ?? normalizedHTML.startIndex
        let upper = normalizedHTML.index(range.upperBound, offsetBy: 900, limitedBy: normalizedHTML.endIndex) ?? normalizedHTML.endIndex
        let window = String(normalizedHTML[lower..<upper])

        let terminal = firstMatch(in: window, pattern: #"Terminal\s*([0-9A-Z]+)"#)
        let gate = firstMatch(in: window, pattern: #"\bGate\s*([A-Z]{1,3}[0-9]{1,3}[A-Z]?)\b"#)
        let status = firstMatch(in: window, pattern: #"\b(Boarding|Delayed|Cancelled|Departed|Final call|Gate open|On time)\b"#)

        guard terminal != nil || gate != nil || status != nil else { return nil }

        return FrankfurtFlightStatus(
            flightCode: flightCode,
            terminal: terminal,
            gate: FlightEndpoint.normalizedPassengerGate(gate, airportCode: "FRA"),
            status: status,
            sourceName: sourceName,
            sourceURL: sourceURL
        )
    }

    private func firstMatch(in text: String, pattern: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return nil }
        let nsRange = NSRange(text.startIndex..<text.endIndex, in: text)
        guard let match = regex.firstMatch(in: text, range: nsRange),
              match.numberOfRanges > 1,
              let range = Range(match.range(at: 1), in: text)
        else { return nil }

        let value = String(text[range]).trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }
}
