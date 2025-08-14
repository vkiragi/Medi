import Foundation
import StoreKit
import Combine

@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    // Configure your product identifiers in App Store Connect to match these IDs
    private let productIds: [String] = [
        "medi.premium.monthly",
        "medi.premium.annual"
    ]
    
    private let devForceKey = "dev_force_premium"
    private var lastEntitlementActive: Bool = false
    
    @Published var products: [Product] = []
    @Published var isSubscribed: Bool = false
    @Published var purchaseInProgress: Bool = false
    @Published var errorMessage: String?
    
    public var isDevForced: Bool { UserDefaults.standard.bool(forKey: devForceKey) }
    
    private var updatesTask: Task<Void, Never>? = nil
    
    init() {
        updatesTask = listenForTransactions()
        Task {
            await refreshProducts()
            await updateSubscriptionStatus()
            reconcileEntitlementWithDevForce()
        }
    }
    
    deinit {
        updatesTask?.cancel()
    }
    
    func refreshProducts() async {
        do {
            let storeProducts = try await Product.products(for: productIds)
            // Sort by price ascending for predictable order
            products = storeProducts.sorted { $0.displayPrice < $1.displayPrice }
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
        }
    }
    
    func purchase(_ product: Product) async {
        purchaseInProgress = true
        defer { purchaseInProgress = false }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .unverified(_, _):
                    errorMessage = "Transaction could not be verified."
                case .verified(let transaction):
                    await transaction.finish()
                    await updateSubscriptionStatus()
                }
            case .userCancelled:
                break
            case .pending:
                break
            @unknown default:
                break
            }
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
        }
    }
    
    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
        } catch {
            errorMessage = "Restore failed: \(error.localizedDescription)"
        }
    }
    
    func updateSubscriptionStatus() async {
        var active = false
        for await entitlement in Transaction.currentEntitlements {
            if case .verified(let transaction) = entitlement {
                if productIds.contains(transaction.productID) {
                    active = true
                }
            }
        }
        lastEntitlementActive = active
        reconcileEntitlementWithDevForce()
    }
    
    public func setDevForcePremium(_ enabled: Bool) {
        let previous = isDevForced
        UserDefaults.standard.set(enabled, forKey: devForceKey)
        print("🛠 DEV: Force Premium toggled from \(previous) to \(enabled)")
        reconcileEntitlementWithDevForce()
        print("🛠 DEV: Effective subscription state isSubscribed=\(isSubscribed) (entitlement=\(lastEntitlementActive), devForce=\(isDevForced))")
    }
    
    private func reconcileEntitlementWithDevForce() {
        isSubscribed = lastEntitlementActive || isDevForced
    }
    
    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await update in Transaction.updates {
                guard let self = self else { continue }
                if case .verified(let transaction) = update {
                    await transaction.finish()
                    await self.updateSubscriptionStatus()
                }
            }
        }
    }
}
