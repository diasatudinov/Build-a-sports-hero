//
//  SHWeekStat.swift
//  Build a sports hero
//
//  Created by Dias Atudinov on 27.03.2026.
//


import Foundation

struct SHWeekStat: Identifiable, Hashable {
    let id = UUID()
    let weekStart: Date
    let count: Int
}

struct SHCategoryStat: Identifiable, Hashable {
    let id = UUID()
    let category: SHMissionCategory
    let count: Int
}

extension SHProfileViewModel {

    // MARK: - Weekly stats (last N weeks)

    func weeklyActivity(lastWeeks: Int = 7) -> [SHWeekStat] {
        let cal = calendarForStats()
        let now = Date()
        let thisWeekStart = startOfWeek(for: now, calendar: cal)

        // считаем по неделям весь лог
        var countsByWeek: [Date: Int] = [:]
        for item in completedLog {
            let ws = startOfWeek(for: item.date, calendar: cal)
            countsByWeek[ws, default: 0] += 1
        }

        // возвращаем ровно последние N недель (включая текущую)
        let start = cal.date(byAdding: .weekOfYear, value: -(lastWeeks - 1), to: thisWeekStart) ?? thisWeekStart

        return (0..<lastWeeks).compactMap { i in
            guard let ws = cal.date(byAdding: .weekOfYear, value: i, to: start) else { return nil }
            return SHWeekStat(weekStart: ws, count: countsByWeek[ws, default: 0])
        }
    }

    func thisWeekCount() -> Int {
        let cal = calendarForStats()
        let ws = startOfWeek(for: Date(), calendar: cal)
        return completedLog.filter { startOfWeek(for: $0.date, calendar: cal) == ws }.count
    }

    func bestWeekCount() -> Int {
        let cal = calendarForStats()
        var countsByWeek: [Date: Int] = [:]
        for item in completedLog {
            let ws = startOfWeek(for: item.date, calendar: cal)
            countsByWeek[ws, default: 0] += 1
        }
        return countsByWeek.values.max() ?? 0
    }

    // MARK: - Muscle groups stats (all time)

    func muscleGroupStats() -> [SHCategoryStat] {
        // missionID -> category
        let categoryByMissionID: [String: SHMissionCategory] = Dictionary(
            uniqueKeysWithValues: missions.map { ($0.id, $0.category) }
        )

        var counts: [SHMissionCategory: Int] = [:]
        for item in completedLog {
            if let cat = categoryByMissionID[item.missionID] {
                counts[cat, default: 0] += 1
            }
        }

        // стабильный порядок
        return SHMissionCategory.allCases.map { cat in
            SHCategoryStat(category: cat, count: counts[cat, default: 0])
        }
    }

    // MARK: - Streak (days)

    /// Сколько дней подряд (включая сегодня) были выполненные миссии
    func dayStreak() -> Int {
        let cal = Calendar.current
        let completedDays: Set<Date> = Set(
            completedLog.map { cal.startOfDay(for: $0.date) }
        )

        var streak = 0
        var cursor = cal.startOfDay(for: Date())

        while completedDays.contains(cursor) {
            streak += 1
            guard let prev = cal.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = prev
        }

        return streak
    }

    func totalMissionsCount() -> Int {
        completedLog.count
    }

    // MARK: - helpers

    private func calendarForStats() -> Calendar {
        var c = Calendar.current
        c.firstWeekday = 2 // Monday
        return c
    }

    private func startOfWeek(for date: Date, calendar: Calendar) -> Date {
        // weekOfYear + yearForWeekOfYear дают корректную границу недели
        let comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: comps) ?? date
    }
}