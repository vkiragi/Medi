import Foundation
import SwiftUI

struct PlanLibraryItem: Codable, Identifiable, Equatable {
	let id: UUID
	var title: String
	let createdAt: Date
	var plan: AIMeditationPlan
}

// Equatable by id only
extension PlanLibraryItem {
	static func == (lhs: PlanLibraryItem, rhs: PlanLibraryItem) -> Bool {
		lhs.id == rhs.id
	}
}

enum PlanLibraryStorage {
	private static let listKey = "ai_plan_library"
	private static let currentKey = "ai_plan_current_id"
	
	static func list() -> [PlanLibraryItem] {
		if let data = UserDefaults.standard.data(forKey: listKey),
		   let items = try? JSONDecoder().decode([PlanLibraryItem].self, from: data) {
			return items
		}
		return []
	}
	
	static func saveList(_ items: [PlanLibraryItem]) {
		if let data = try? JSONEncoder().encode(items) {
			UserDefaults.standard.set(data, forKey: listKey)
		}
	}
	
	@discardableResult
	static func saveNew(title: String, plan: AIMeditationPlan) -> PlanLibraryItem {
		var items = list()
		let item = PlanLibraryItem(id: UUID(), title: title, createdAt: Date(), plan: plan)
		items.insert(item, at: 0)
		saveList(items)
		setCurrent(item.id)
		return item
	}
	
	static func rename(id: UUID, newTitle: String) {
		var items = list()
		if let idx = items.firstIndex(where: { $0.id == id }) {
			items[idx].title = newTitle
			saveList(items)
		}
	}
	
	static func delete(id: UUID) {
		var items = list()
		items.removeAll { $0.id == id }
		saveList(items)
		if currentId() == id { UserDefaults.standard.removeObject(forKey: currentKey) }
	}
	
	static func currentId() -> UUID? {
		if let raw = UserDefaults.standard.string(forKey: currentKey) { return UUID(uuidString: raw) }
		return nil
	}
	
	static func setCurrent(_ id: UUID) {
		UserDefaults.standard.set(id.uuidString, forKey: currentKey)
	}
	
	static func current() -> PlanLibraryItem? {
		guard let id = currentId() else { return nil }
		return list().first(where: { $0.id == id })
	}
}
