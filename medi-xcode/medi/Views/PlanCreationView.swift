import SwiftUI

struct PlanCreationView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var meditationManager: MeditationManager
    @State private var goal: String = "Reduce stress and sleep better"
    @State private var days: Int = 7
    @State private var isGenerating = false
    @State private var errorMessage: String?
    @State private var navigateToPlan = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Your Goal")) {
                    TextField("e.g., Improve focus, reduce stress", text: $goal)
                }
                Section(header: Text("Plan Length")) {
                    Stepper(value: $days, in: 3...30) {
                        Text("\(days) days")
                    }
                }
                Section(footer: Text("We use your recent check-ins to personalize.").font(.footnote)) {
                    Button(action: generatePlan) {
                        HStack {
                            if isGenerating { ProgressView().scaleEffect(0.9) }
                            Text(subscriptionManager.isSubscribed ? "Generate Plan" : "Get Premium to Generate")
                        }
                    }
                    .disabled(!subscriptionManager.isSubscribed || isGenerating)
                }
                if let error = errorMessage {
                    Section {
                        Text(error).foregroundColor(.red)
                    }
                }
                if PlanStorage.load() != nil {
                    Section(header: Text("Existing Plan")) {
                        NavigationLink(destination: PlanDetailView(), isActive: $navigateToPlan) {
                            Text("View Saved Plan")
                        }
                    }
                }
            }
            .navigationTitle("AI Plan")
        }
    }
    
    private func generatePlan() {
        guard subscriptionManager.isSubscribed else { return }
        isGenerating = true
        errorMessage = nil
        Task {
            do {
                let summary = summarizeRecentMood()
                let plan = try await OpenAIManager.shared.generatePlan(goal: goal, days: days, moodSummary: summary)
                PlanStorage.save(plan)
                // Also add to library and set as current
                _ = PlanLibraryStorage.saveNew(title: goal.isEmpty ? "My Plan" : goal, plan: plan)
                navigateToPlan = true
            } catch {
                errorMessage = error.localizedDescription
            }
            isGenerating = false
        }
    }
    
    private func summarizeRecentMood() -> String? {
        let recent = meditationManager.moodSessions.suffix(10)
        guard !recent.isEmpty else { return nil }
        let moods = Dictionary(grouping: recent, by: { $0.mood }).mapValues { $0.count }
        let top = moods.sorted { $0.value > $1.value }.first?.key.rawValue ?? "Unknown"
        return "Recent moods are mostly \(top). Total sessions: \(recent.count)."
    }
}
