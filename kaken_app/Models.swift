import Foundation

// MARK: - Goal Model
struct Goal: Codable {
    let id: UUID
    var title: String
    var startDate: Date
    var endDate: Date
    var updatedAt: Date
    var lastViewedScreen: String? // 前回開いていた画面のStoryboard ID
    var currentStep: Int // ウィザードのステップ (1: VC1, 2: VC2, 5: VC5完了)
    
    init(id: UUID = UUID(), title: String = "", startDate: Date = Date(), endDate: Date = Date(), currentStep: Int = 1) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.updatedAt = Date()
        self.lastViewedScreen = nil
        self.currentStep = currentStep
    }
    
    mutating func updateTimestamp() {
        self.updatedAt = Date()
    }
}

// MARK: - Goal Draft (ウィザード途中のデータ)
struct GoalDraft: Codable {
    var id: UUID
    var title: String?
    var startDate: Date?
    var endDate: Date?
    var currentStep: Int
    var createdAt: Date
    
    init(id: UUID = UUID()) {
        self.id = id
        self.title = nil
        self.startDate = nil
        self.endDate = nil
        self.currentStep = 1
        self.createdAt = Date()
    }
    
    // GoalDraftからGoalに変換
    func toGoal() -> Goal? {
        guard let title = self.title,
              let startDate = self.startDate,
              let endDate = self.endDate else {
            return nil
        }
        
        return Goal(
            id: self.id,
            title: title,
            startDate: startDate,
            endDate: endDate,
            currentStep: self.currentStep
        )
    }
}

// MARK: - Goal Manager (データ管理クラス)
class GoalManager {
    static let shared = GoalManager()
    private init() {}
    
    private let goalsListKey = "goals.list.v1"
    private let draftKeyPrefix = "goal.draft."
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        return formatter
    }()
    
    // MARK: - Goal List Management
    
    func loadGoals() -> [Goal] {
        guard let data = UserDefaults.standard.data(forKey: goalsListKey),
              let goals = try? JSONDecoder().decode([Goal].self, from: data) else {
            return []
        }
        return goals.sorted { $0.updatedAt > $1.updatedAt }
    }
    
    func saveGoals(_ goals: [Goal]) {
        if let data = try? JSONEncoder().encode(goals) {
            UserDefaults.standard.set(data, forKey: goalsListKey)
        }
    }
    
    func saveGoal(_ goal: Goal) {
        var goals = loadGoals()
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index] = goal
        } else {
            goals.append(goal)
        }
        saveGoals(goals)
    }
    
    func deleteGoal(id: UUID) {
        // 目標リストから削除
        var goals = loadGoals()
        goals.removeAll { $0.id == id }
        saveGoals(goals)
        
        // 関連するUserDefaultsデータを削除
        deleteGoalData(id: id)
        
        // ドラフトも削除
        deleteDraft(id: id)
    }
    
    private func deleteGoalData(id: UUID) {
        let ud = UserDefaults.standard
        let goalPrefix = "goal.\(id.uuidString)."
        
        // 既知のキーパターンを削除
        let keysToCheck = [
            "\(goalPrefix)mokuhyou",
            "\(goalPrefix)kikan",
            "\(goalPrefix)createdAt",
            "\(goalPrefix)goalEnd"
        ]
        
        // koudou関連
        for row in 1...8 {
            for col in 1...4 {
                keysToCheck.forEach { key in
                    ud.removeObject(forKey: "\(goalPrefix)koudou\(row)\(col)")
                }
            }
        }
        
        // onoff関連（日付ベース）- 実際の日付範囲を取得して削除
        if let goal = loadGoals().first(where: { $0.id == id }) {
            let calendar = Calendar(identifier: .gregorian)
            var currentDate = calendar.startOfDay(for: goal.startDate)
            let endDate = calendar.startOfDay(for: goal.endDate)
            
            while currentDate <= endDate {
                let dateString = dateFormatter.string(from: currentDate)
                for row in 1...32 {
                    ud.removeObject(forKey: "\(goalPrefix)onoff_\(row)_\(dateString)")
                }
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? endDate
            }
        }
        
        keysToCheck.forEach { ud.removeObject(forKey: $0) }
    }
    
    // MARK: - Draft Management
    
    func saveDraft(_ draft: GoalDraft) {
        let key = "\(draftKeyPrefix)\(draft.id.uuidString)"
        if let data = try? JSONEncoder().encode(draft) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    func loadDraft(id: UUID) -> GoalDraft? {
        let key = "\(draftKeyPrefix)\(id.uuidString)"
        guard let data = UserDefaults.standard.data(forKey: key),
              let draft = try? JSONDecoder().decode(GoalDraft.self, from: data) else {
            return nil
        }
        return draft
    }
    
    func deleteDraft(id: UUID) {
        let key = "\(draftKeyPrefix)\(id.uuidString)"
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    // MARK: - Goal Data Access (名前空間付き)
    
    func setGoalData<T>(_ value: T, forKey key: String, goalId: UUID) {
        let namespacedKey = "goal.\(goalId.uuidString).\(key)"
        UserDefaults.standard.set(value, forKey: namespacedKey)
    }
    
    func getGoalData<T>(forKey key: String, goalId: UUID, defaultValue: T) -> T {
        let namespacedKey = "goal.\(goalId.uuidString).\(key)"
        return UserDefaults.standard.object(forKey: namespacedKey) as? T ?? defaultValue
    }
    
    func getGoalData(forKey key: String, goalId: UUID) -> Any? {
        let namespacedKey = "goal.\(goalId.uuidString).\(key)"
        return UserDefaults.standard.object(forKey: namespacedKey)
    }
    
    // MARK: - Screen Tracking
    
    func updateLastViewedScreen(goalId: UUID, screenId: String, step: Int) {
        var goals = loadGoals()
        if let index = goals.firstIndex(where: { $0.id == goalId }) {
            goals[index].lastViewedScreen = screenId
            goals[index].currentStep = step
            goals[index].updateTimestamp()
            saveGoals(goals)
        }
    }
    
    // MARK: - Utility
    
    func dateString(from date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    func date(from string: String) -> Date? {
        return dateFormatter.date(from: string)
    }
}