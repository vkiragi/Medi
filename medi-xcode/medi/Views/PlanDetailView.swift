import SwiftUI

struct PlanDetailView: View {
    @State private var plan: AIMeditationPlan? = PlanStorage.load()
    @State private var library: [PlanLibraryItem] = PlanLibraryStorage.list()
    @State private var currentId: UUID? = PlanLibraryStorage.currentId()
    @State private var showingRename = false
    @State private var newTitle: String = ""
    
    var body: some View {
        Group {
            if let currentPlan = plan {
                List {
                    // Library switcher
                    if !library.isEmpty {
                        Section(header: Text("Saved Plans")) {
                            Picker("Current", selection: Binding(
                                get: { currentId ?? library.first?.id },
                                set: { setCurrent(id: $0) }
                            )) {
                                ForEach(library) { item in
                                    Text(item.title).tag(Optional(item.id))
                                }
                            }
                        }
                    }
                    Section(header: Text(library.first(where: { $0.id == currentId })?.title ?? currentPlan.goal)) {
                        ForEach(currentPlan.days) { day in
                            HStack(alignment: .top, spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Day \(day.dayNumber): \(day.title)")
                                        .font(.headline)
                                    Text("Focus: \(day.focus) • \(day.durationMinutes)m")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(day.tip)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Button(action: { toggleComplete(dayId: day.id) }) {
                                    Image(systemName: day.completed ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(day.completed ? .green : .gray)
                                }
                            }
                            // Start session row
                            startSessionRow(for: day)
                        }
                    }
                    Button("Rename Plan") { startRename() }
                    Button("Delete Plan") { deleteCurrent() }.foregroundColor(.red)
                    Button("Clear Local Current Plan") {
                        PlanStorage.clear()
                        plan = nil
                    }
                    .foregroundColor(.red)
                }
                .navigationTitle("Your Plan")
            } else {
                VStack(spacing: 12) {
                    Text("No saved plan")
                    Text("Create a plan to see details here.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .navigationTitle("Your Plan")
            }
        }
        .onAppear { reload() }
        .alert("Rename Plan", isPresented: $showingRename) {
            TextField("Title", text: $newTitle)
            Button("Save") { commitRename() }
            Button("Cancel", role: .cancel) {}
        }
    }
    
    @ViewBuilder
    private func startSessionRow(for day: AIMeditationPlan.Day) -> some View {
        if case let .guided(meditation) = PlanPlaybackResolver.resolve(for: day) {
            NavigationLink(destination: GuidedMeditationPlayerView(meditation: meditation)) {
                HStack {
                    Image(systemName: "play.circle.fill").foregroundColor(.blue)
                    Text("Start Session")
                    Spacer()
                }
            }
        }
    }
    
    private func reload() {
        library = PlanLibraryStorage.list()
        currentId = PlanLibraryStorage.currentId() ?? library.first?.id
        if let id = currentId, let item = library.first(where: { $0.id == id }) {
            plan = item.plan
            PlanStorage.save(item.plan) // keep local current in sync
        } else {
            plan = PlanStorage.load()
        }
    }
    
    private func setCurrent(id: UUID?) {
        guard let id else { return }
        PlanLibraryStorage.setCurrent(id)
        reload()
    }
    
    private func startRename() {
        guard let id = currentId, let item = library.first(where: { $0.id == id }) else { return }
        newTitle = item.title
        showingRename = true
    }
    
    private func commitRename() {
        guard let id = currentId else { return }
        PlanLibraryStorage.rename(id: id, newTitle: newTitle)
        reload()
    }
    
    private func deleteCurrent() {
        guard let id = currentId else { return }
        PlanLibraryStorage.delete(id: id)
        reload()
    }
    
    private func toggleComplete(dayId: UUID) {
        guard let current = plan else { return }
        if let idx = current.days.firstIndex(where: { $0.id == dayId }) {
            var newDays = current.days
            var d = newDays[idx]
            d.completed.toggle()
            newDays[idx] = d
            let newPlan = AIMeditationPlan(goal: current.goal, days: newDays)
            plan = newPlan
            PlanStorage.save(newPlan)
            // Update library item if current selected
            if let id = currentId {
                var items = PlanLibraryStorage.list()
                if let i = items.firstIndex(where: { $0.id == id }) {
                    items[i].plan = newPlan
                    PlanLibraryStorage.saveList(items)
                }
            }
        }
    }
}
