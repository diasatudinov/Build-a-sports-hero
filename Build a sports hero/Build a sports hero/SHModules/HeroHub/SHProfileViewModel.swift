//
//  SHProfileViewModel.swift
//  Build a sports hero
//
//

import SwiftUI

final class SHProfileViewModel: ObservableObject {
    
    @Published var currentLevel = 1
    @Published var missionCompleted = 0
    @Published var weeklyGoal = 0
    @Published var completedMissions: [SHMission] = []
    @Published private(set) var completedLog: [SHCompletedMission] = []
    
    private let weeklyGoalTarget = 15
    
    var currentProfile: Level {
        levels.first(where: { $0.level == currentLevel }) ?? levels[0]
    }
    
    var missionProgress: CGFloat {
        guard currentProfile.missions > 0 else { return 0 }
        return min(CGFloat(missionCompleted) / CGFloat(currentProfile.missions), 1.0)
    }
    
    var weeklyProgress: CGFloat {
        guard weeklyGoalTarget > 0 else { return 0 }
        return min(CGFloat(weeklyGoal) / CGFloat(weeklyGoalTarget), 1.0)
    }
    
    var isMaxLevel: Bool {
        currentLevel >= (levels.last?.level ?? 1)
    }
    
    private let lastWeeklyUpdateKey = "weeklyGoalLastUpdate2"
    private let lastDailyUpdateKey = "completedMissionsLastUpdate2"
    
    private let currentLevelKey = "currentLevel2"
    private let missionCompletedKey = "missionCompleted2"
    private let weeklyGoalKey = "weeklyGoal2"
    private let completedMissionsKey = "completedMissions2"
    private let completedLogKey = "completedLog2"
    
    let missions: [SHMission] = [
        SHMission(id: "iron_core", title: "Iron Core", subtitle: "Crunches", details: "3 × 15", category: .core),
        SHMission(id: "shoulder_power", title: "Shoulder Power", subtitle: "Military Press", details: "4 × 10", category: .shoulders),
        SHMission(id: "steel_legs", title: "Steel Legs", subtitle: "Squats", details: "4 × 12", category: .legs),
        SHMission(id: "colossus_chest", title: "Colossus Chest", subtitle: "Push-ups", details: "3 × 20", category: .chest),
        SHMission(id: "titan_back", title: "Titan Back", subtitle: "Pull-ups", details: "3 × 8", category: .back),
        SHMission(id: "cardio_rush", title: "Cardio Rush", subtitle: "Running", details: "1 × 15 min", category: .cardio),
        SHMission(id: "hero_biceps", title: "Hero Biceps", subtitle: "Bicep Curls", details: "3 × 12", category: .arms),
        SHMission(id: "hammer_triceps", title: "Hammer Triceps", subtitle: "Dips", details: "3 × 10", category: .arms),
        SHMission(id: "time_plank", title: "Time Plank", subtitle: "Plank", details: "3 × 60 sec", category: .core),
        SHMission(id: "spartan_lunges", title: "Spartan Lunges", subtitle: "Lunges", details: "3 × 12 per leg", category: .legs),
        SHMission(id: "burpee_storm", title: "Burpee Storm", subtitle: "Burpees", details: "3 × 10", category: .cardio),
        SHMission(id: "row_to_belt", title: "Row to Belt", subtitle: "Dumbbell Row", details: "4 × 10", category: .back),
        SHMission(id: "shadow_boxing", title: "Shadow Boxing", subtitle: "Boxing", details: "3 × 3 min", category: .cardio),
        SHMission(id: "bench_press", title: "Bench Press", subtitle: "Barbell Press", details: "4 × 8", category: .chest),
        SHMission(id: "climber_calves", title: "Climber Calves", subtitle: "Calf Raises", details: "4 × 20", category: .legs),
        SHMission(id: "bicycle", title: "Bicycle", subtitle: "Bicycle Crunches", details: "3 × 20", category: .core),
        SHMission(id: "star_jumps", title: "Star Jumps", subtitle: "Jumping Jacks", details: "3 × 50", category: .cardio),
        SHMission(id: "deadlift_pull", title: "Deadlift Pull", subtitle: "Deadlift", details: "3 × 8", category: .back),
        SHMission(id: "dumbbell_swings", title: "Dumbbell Swings", subtitle: "Lateral Raises", details: "3 × 15", category: .shoulders),
        SHMission(id: "superman", title: "Superman", subtitle: "Hyperextension", details: "3 × 15", category: .back)
    ]
    
    init() {
        loadState()
        checkDailyReset()
        checkWeeklyUpdate()
        refreshTodayCompleted()
    }
    
    private let levels: [Level] = [
        Level(level: 1, name: "Rookie", missions: 100),
        Level(level: 2, name: "Guardian", missions: 120),
        Level(level: 3, name: "Warrior", missions: 150),
        Level(level: 4, name: "Veteran", missions: 180),
        Level(level: 5, name: "Champion", missions: 200),
        Level(level: 6, name: "Legend", missions: 230),
        Level(level: 7, name: "Titan", missions: 250),
        Level(level: 8, name: "God", missions: 300)
    ]
    
    func addMissionProgress(_ value: Int = 1) {
        guard value > 0 else { return }
        
        missionCompleted += value
        updateLevelIfNeeded()
    }
    
    func addWeeklyProgress(_ value: Int = 1) {
        guard value > 0 else { return }
        weeklyGoal += value
    }
    
    private func updateLevelIfNeeded() {
        while missionCompleted >= currentProfile.missions && !isMaxLevel {
            missionCompleted = 0
            currentLevel += 1
        }
        
        if isMaxLevel {
            missionCompleted = min(missionCompleted, currentProfile.missions)
        }
    }
    
    func checkWeeklyUpdate() {
        let now = Date()
        let cal = Calendar.current
        
        guard let lastDate = UserDefaults.standard.object(forKey: lastWeeklyUpdateKey) as? Date else {
            UserDefaults.standard.set(now, forKey: lastWeeklyUpdateKey)
            return
        }
        
        let oldWeek = cal.component(.weekOfYear, from: lastDate)
        let newWeek = cal.component(.weekOfYear, from: now)
        let oldYear = cal.component(.yearForWeekOfYear, from: lastDate)
        let newYear = cal.component(.yearForWeekOfYear, from: now)
        
        if oldWeek != newWeek || oldYear != newYear {
            weeklyGoal = 0
            UserDefaults.standard.set(now, forKey: lastWeeklyUpdateKey)
            saveState()
        }
    }
    
    private func updateWeeklyGoal() {
        weeklyGoal = 0
        
        UserDefaults.standard.set(Date(), forKey: lastWeeklyUpdateKey)
    }
    
    // MARK: - Mission Actions
    
    func completeMission(_ mission: SHMission, on date: Date = Date()) {
        // фикс: не увеличиваем прогресс, если уже выполнено в этот день
        guard !isMissionCompleted(mission, on: date) else { return }
        
        completedLog.append(.init(missionID: mission.id, date: date))
        
        // считаем прогресс уровня/недели только если это "сегодня"
        if Calendar.current.isDateInToday(date) {
            missionCompleted += 1
            
            if weeklyGoal < weeklyGoalTarget {
                weeklyGoal += 1
            }
            
            updateLevelIfNeeded()
            UserDefaults.standard.set(Date(), forKey: lastDailyUpdateKey)
        }
        
        refreshTodayCompleted()
        saveState()
    }
    
    func uncompleteMission(_ mission: SHMission, on date: Date = Date()) {
        let cal = Calendar.current
        
        guard let index = completedLog.firstIndex(where: {
            $0.missionID == mission.id && cal.isDate($0.date, inSameDayAs: date)
        }) else { return }
        
        completedLog.remove(at: index)
        
        if cal.isDateInToday(date) {
            missionCompleted = max(0, missionCompleted - 1)
            weeklyGoal = max(0, weeklyGoal - 1)
            UserDefaults.standard.set(Date(), forKey: lastDailyUpdateKey)
        }
        
        refreshTodayCompleted()
        saveState()
    }
    
    func isMissionCompleted(_ mission: SHMission, on date: Date = Date()) -> Bool {
        let cal = Calendar.current
        return completedLog.contains(where: {
            $0.missionID == mission.id && cal.isDate($0.date, inSameDayAs: date)
        })
    }
    
    func missionsCompleted(on date: Date) -> [SHMission] {
        let cal = Calendar.current
        let ids = completedLog
            .filter { cal.isDate($0.date, inSameDayAs: date) }
            .map(\.missionID)
        
        // уникально и в порядке выполнения
        var seen = Set<String>()
        let uniqueIDs = ids.filter { seen.insert($0).inserted }
        
        return uniqueIDs.compactMap { id in
            missions.first(where: { $0.id == id })
        }
    }
    
    func hasCompletedMissions(on date: Date) -> Bool {
        !missionsCompleted(on: date).isEmpty
    }
    
    // MARK: - Daily Reset
    
    func checkDailyReset() {
        let now = Date()
        let cal = Calendar.current
        
        guard let lastDate = UserDefaults.standard.object(forKey: lastDailyUpdateKey) as? Date else {
            UserDefaults.standard.set(now, forKey: lastDailyUpdateKey)
            return
        }
        
        if !cal.isDate(lastDate, inSameDayAs: now) {
            // историю НЕ чистим — она нужна для календаря
            // просто обновим маркер и "today list"
            UserDefaults.standard.set(now, forKey: lastDailyUpdateKey)
            refreshTodayCompleted()
        }
    }
    
    private func refreshTodayCompleted() {
        completedMissions = missionsCompleted(on: Date())
    }
    
    private func resetDailyCompletedMissions() {
        completedMissions = []
        UserDefaults.standard.set(Date(), forKey: lastDailyUpdateKey)
        saveState()
    }
    
    private func saveState() {
        UserDefaults.standard.set(currentLevel, forKey: currentLevelKey)
        UserDefaults.standard.set(missionCompleted, forKey: missionCompletedKey)
        UserDefaults.standard.set(weeklyGoal, forKey: weeklyGoalKey)
        
        if let data = try? JSONEncoder().encode(completedLog) {
            UserDefaults.standard.set(data, forKey: completedLogKey)
        }
    }
    
    private func loadState() {
        currentLevel = UserDefaults.standard.integer(forKey: currentLevelKey)
        if currentLevel == 0 { currentLevel = 1 }
        
        missionCompleted = UserDefaults.standard.integer(forKey: missionCompletedKey)
        weeklyGoal = UserDefaults.standard.integer(forKey: weeklyGoalKey)
        
        // 1) новое хранилище
        if let data = UserDefaults.standard.data(forKey: completedLogKey),
           let decoded = try? JSONDecoder().decode([SHCompletedMission].self, from: data) {
            completedLog = decoded
            return
        }
        
        // 2) миграция со старого: completedMissions2 -> лог на "сегодня"
        if let data = UserDefaults.standard.data(forKey: completedMissionsKey),
           let decoded = try? JSONDecoder().decode([SHMission].self, from: data) {
            let today = Date()
            completedLog = decoded.map { SHCompletedMission(missionID: $0.id, date: today) }
            
            // чтобы больше не мешало
            UserDefaults.standard.removeObject(forKey: completedMissionsKey)
            
            // сохраним уже в новом формате
            saveState()
        }
    }
    
}


struct Level: Codable, Hashable, Identifiable {
    var id: Int { level }
    let level: Int
    let name: String
    let missions: Int
}

struct SHMission: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let details: String
    let category: SHMissionCategory
    
    init(
        id: String,
        title: String,
        subtitle: String,
        details: String,
        category: SHMissionCategory
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.details = details
        self.category = category
    }
}

enum SHMissionCategory: String, Codable, CaseIterable, Hashable {
    case core = "Core"
    case shoulders = "Shoulders"
    case legs = "Legs"
    case chest = "Chest"
    case back = "Back"
    case cardio = "Cardio"
    case arms = "Arms"
}

struct SHCompletedMission: Identifiable, Codable, Hashable {
    let id: UUID
    let missionID: String
    let date: Date
    
    init(id: UUID = UUID(), missionID: String, date: Date) {
        self.id = id
        self.missionID = missionID
        self.date = date
    }
}
