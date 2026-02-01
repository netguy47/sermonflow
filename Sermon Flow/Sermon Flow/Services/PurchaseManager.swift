
import Foundation
import StoreKit
import Combine

@MainActor
class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()
    
    @Published private(set) var isSubscribed: Bool = false
    
    private let proMonthlyID = "com.sermonflow.pro.monthly"
    private let proYearlyID = "com.sermonflow.pro.yearly"
    
    private init() {
        Task {
            await updateStatus()
            await observeTransactions()
        }
    }
    
    func updateStatus() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID == proMonthlyID || transaction.productID == proYearlyID {
                    isSubscribed = true
                    return
                }
            }
        }
        isSubscribed = false
    }
    
    private func observeTransactions() async {
        for await result in Transaction.updates {
            if case .verified(_) = result {
                await updateStatus()
            }
        }
    }
    
    func restorePurchases() async {
        try? await AppStore.sync()
        await updateStatus()
    }
}
