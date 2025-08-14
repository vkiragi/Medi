import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var subManager = SubscriptionManager.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("medi premium")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.5))
                        Text("Unlock AI plans, advanced insights, and the full guided library")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 16)
                    
                    // Benefits
                    VStack(spacing: 12) {
                        BenefitRow(icon: "brain.head.profile", text: "Custom AI meditation plans")
                        BenefitRow(icon: "chart.bar.fill", text: "Deep insights and trends")
                        BenefitRow(icon: "waveform", text: "Full guided meditation library")
                        BenefitRow(icon: "bell.badge", text: "Smart reminders & streaks")
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(14)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    .padding(.horizontal)
                    
                    // Products
                    VStack(spacing: 12) {
                        if subManager.products.isEmpty {
                            ProgressView("Loading offers…")
                                .padding()
                        } else {
                            ForEach(subManager.products, id: \.id) { product in
                                ProductRow(product: product) {
                                    Task { await subManager.purchase(product) }
                                }
                            }
                        }
                        
                        if let error = subManager.errorMessage {
                            Text(error)
                                .font(.footnote)
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Restore + Legal
                    VStack(spacing: 8) {
                        Button("Restore Purchases") {
                            Task { await subManager.restorePurchases() }
                        }
                        .font(.callout)
                        .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.9))
                        
                        Text("By subscribing, you agree to our Terms and Privacy Policy.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 16)
                }
            }
            .background(Color(red: 0.95, green: 0.95, blue: 1.0).ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

private struct ProductRow: View {
    let product: Product
    let onTap: () -> Void
    @State private var isPurchasing = false
    
    var body: some View {
        Button(action: {
            guard !isPurchasing else { return }
            isPurchasing = true
            onTap()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                isPurchasing = false
            }
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.displayName)
                        .font(.headline)
                    Text(product.displayPrice)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: isPurchasing ? "hourglass" : "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
        }
    }
}

private struct BenefitRow: View {
    let icon: String
    let text: String
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color(red: 0.5, green: 0.6, blue: 0.9))
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
            Spacer()
        }
    }
}
