//
//  PurchaseManager.swift
//  TravelCompanion
//
//

import Foundation
import Combine
import StoreKit

@MainActor
final class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()

    static let tripPassProductID = "com.faysel.TravelCompanion.tripPass"
    static let monthlyProductID = "com.faysel.TravelCompanion.travelPlusMonthly"

    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published private(set) var isLoading = false
    @Published var statusMessage: String?

    // Enable only after every advertised premium capability and purchase flow is verified.
    var purchasesEnabled: Bool {
        Bundle.main.object(forInfoDictionaryKey: "TravelPlusPurchasesEnabled") as? Bool == true
    }

    private let productIDs: Set<String> = [
        PurchaseManager.tripPassProductID,
        PurchaseManager.monthlyProductID
    ]

    private var transactionUpdatesTask: Task<Void, Never>?

    private init() {
        transactionUpdatesTask = Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                await self.handle(transactionResult: result)
            }
        }

        Task {
            await loadProducts()
            await refreshPurchasedProducts()
        }
    }

    deinit {
        transactionUpdatesTask?.cancel()
    }

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            products = try await Product.products(for: productIDs)
                .sorted { $0.price < $1.price }

            if products.isEmpty {
                statusMessage = "Store products are not available yet. Create matching products in App Store Connect."
            }
        } catch {
            statusMessage = "Could not load StoreKit products. Check product IDs and App Store Connect setup."
        }
    }

    func purchase(productID: String) async {
        guard purchasesEnabled else {
            statusMessage = "Travel Plus is a preview. Purchases are not enabled in this build."
            return
        }
        if products.isEmpty {
            await loadProducts()
        }

        guard let product = products.first(where: { $0.id == productID }) else {
            statusMessage = "This product is not available yet. Check App Store Connect product configuration."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await refreshPurchasedProducts()
                statusMessage = purchasedProductIDs.contains(transaction.productID)
                    ? "Travel Plus is active." : "This purchase is no longer active."
            case .userCancelled:
                statusMessage = "Purchase cancelled."
            case .pending:
                statusMessage = "Purchase is pending approval."
            @unknown default:
                statusMessage = "Purchase could not be completed."
            }
        } catch {
            statusMessage = "Purchase failed. Please try again."
        }
    }

    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await AppStore.sync()
            await refreshPurchasedProducts()
            statusMessage = purchasedProductIDs.isEmpty ? "No previous purchases found." : "Purchases restored."
        } catch {
            statusMessage = "Could not restore purchases. Please try again."
        }
    }

    func refreshPurchasedProducts() async {
        var activeProductIDs = Set<String>()

        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               productIDs.contains(transaction.productID),
               PurchaseEntitlementPolicy.isActive(
                   revocationDate: transaction.revocationDate,
                   expirationDate: transaction.expirationDate,
                   isUpgraded: transaction.isUpgraded
               ) {
                activeProductIDs.insert(transaction.productID)
            }
        }

        purchasedProductIDs = activeProductIDs
    }

    func isPurchased(_ productID: String) -> Bool {
        purchasedProductIDs.contains(productID)
    }

    func isProductAvailable(_ productID: String) -> Bool {
        products.contains { $0.id == productID }
    }

    func displayPrice(for productID: String, fallback: String) -> String {
        products.first(where: { $0.id == productID })?.displayPrice ?? fallback
    }

    private func handle(transactionResult result: VerificationResult<Transaction>) async {
        do {
            let transaction = try checkVerified(result)
            await transaction.finish()
            await refreshPurchasedProducts()
        } catch {
            statusMessage = "A StoreKit transaction could not be verified."
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let value):
            return value
        case .unverified:
            throw StoreError.failedVerification
        }
    }
}

private enum StoreError: Error {
    case failedVerification
}
