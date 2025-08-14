import SwiftUI

struct GuidedMeditationListView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    // Placeholder - no guided meditations available yet
    let guidedMeditations: [GuidedMeditation] = []
    
    @State private var selectedCategory = "All"
    @State private var showingPaywall = false
    let categories = ["All", "Popular", "Sleep", "Stress", "Focus"]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(red: 0.95, green: 0.95, blue: 1.0)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    if !subscriptionManager.isSubscribed {
                        UpsellHeader { showingPaywall = true }
                            .padding(.horizontal, 20)
                            .padding(.top, 12)
                    }
                    
                    // Category selector
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(categories, id: \.self) { category in
                                Button(action: {
                                    selectedCategory = category
                                }) {
                                    Text(category)
                                        .font(.system(size: 16, weight: selectedCategory == category ? .medium : .regular))
                                        .foregroundColor(selectedCategory == category ? .white : Color(red: 0.5, green: 0.5, blue: 0.6))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(selectedCategory == category ? Color(red: 0.6, green: 0.7, blue: 0.9) : Color.clear)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 15)
                    }
                    
                    // Meditations list
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(guidedMeditations) { meditation in
                                NavigationLink(destination: destinationView(for: meditation)) {
                                    GuidedMeditationCard(meditation: meditation)
                                }
                                .simultaneousGesture(TapGesture().onEnded {
                                    if !subscriptionManager.isSubscribed { showingPaywall = true }
                                })
                                .disabled(!subscriptionManager.isSubscribed)
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.vertical, 20)
                    }
                }
            }
            .navigationTitle("Guided")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingPaywall) { PaywallView() }
    }
    
    @ViewBuilder
    private func destinationView(for meditation: GuidedMeditation) -> some View {
        if subscriptionManager.isSubscribed {
            GuidedMeditationPlayerView(meditation: meditation)
        } else {
            EmptyView()
        }
    }
}

private struct UpsellHeader: View {
    let onTap: () -> Void
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: "crown.fill")
                    .foregroundColor(.yellow)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Unlock the full guided library")
                        .font(.headline)
                    Text("Get medi Premium for AI plans and all sessions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
        }
    }
}

struct GuidedMeditationCard: View {
    let meditation: GuidedMeditation
    
    var body: some View {
        HStack(spacing: 15) {
            // Meditation image
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(meditation.imageColor)
                    .frame(width: 80, height: 80)
                
                Image(systemName: "waveform")
                    .font(.system(size: 30))
                    .foregroundColor(.white)
            }
            
            // Meditation details
            VStack(alignment: .leading, spacing: 5) {
                Text(meditation.title)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.4))
                
                Text(meditation.description)
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                    .lineLimit(2)
                
                Text("\(meditation.duration) min")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(red: 0.6, green: 0.7, blue: 0.9))
                    .padding(.top, 2)
            }
            
            Spacer()
            
            // Play button
            Image(systemName: "play.circle.fill")
                .font(.system(size: 30))
                .foregroundColor(Color(red: 0.6, green: 0.7, blue: 0.9))
                .padding(.trailing, 5)
        }
        .padding(15)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct GuidedMeditation: Identifiable {
    let id: String
    let title: String
    let description: String
    let duration: Int
    let imageColor: Color
    let audioFileName: String
} 