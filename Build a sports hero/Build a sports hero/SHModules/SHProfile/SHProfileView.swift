//
//  SHProfileView.swift
//  Build a sports hero
//
//

import SwiftUI

struct SHProfileView: View {

    @ObservedObject var viewModel: SHProfileViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                levelHeaderCard

                cycleProgressCard

                cycleHistoryCard

                achievementsSection
            }
            .padding()
        }
    }

    // MARK: - Top: Level / Name / Progress

    private var levelHeaderCard: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack(alignment: .firstTextBaseline) {
                Text("Level \(viewModel.currentProfile.level)")
                    .font(.title2.bold())

                Spacer()

                Text(viewModel.currentProfile.name)
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: viewModel.missionProgress)
                .tint(.red)

            HStack {
                Text("\(viewModel.missionCompleted) / \(viewModel.currentProfile.missions) missions")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()

                Text("\(Int(viewModel.missionProgress * 100))%")
                    .font(.subheadline.bold())
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Cycle Progress (currentLevel / 8)

    private var cycleProgressCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cycle Progress")
                .font(.headline)

            HStack(spacing: 16) {
                RingProgressView(
                    progress: CGFloat(viewModel.currentLevel) / CGFloat(viewModel.totalLevelsCount),
                    centerText: "\(viewModel.currentLevel)/\(viewModel.totalLevelsCount)"
                )
                .frame(width: 88, height: 88)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Current cycle position")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text("You are on level \(viewModel.currentLevel) of \(viewModel.totalLevelsCount)")
                        .font(.headline)
                }

                Spacer()
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Cycle History (completed levels)

    private var cycleHistoryCard: some View {
        let completed = completedLevels()

        return VStack(alignment: .leading, spacing: 12) {
            Text("Cycle History")
                .font(.headline)

            if completed.isEmpty {
                Text("No completed levels yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.tertiarySystemFill))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                VStack(spacing: 10) {
                    ForEach(completed, id: \.level) { level in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Level \(level.level)")
                                    .font(.subheadline.bold())
                                Text(level.name)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text("\(level.missions) missions")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(Color(.tertiarySystemFill))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Achievements

    private var achievementsSection: some View {
        let items = achievements()

        return VStack(alignment: .leading, spacing: 12) {
            Text("Achievements")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(items) { ach in
                    AchievementCardView(achievement: ach)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Data for UI

    private func completedLevels() -> [Level] {
        let all = allLevelsStatic()
        let current = viewModel.currentLevel
        guard current > 1 else { return [] }
        return all.filter { $0.level < current }
    }

    // уровни как в VM (для history)
    private func allLevelsStatic() -> [Level] {
        [
            Level(level: 1, name: "Rookie", missions: 100),
            Level(level: 2, name: "Guardian", missions: 120),
            Level(level: 3, name: "Warrior", missions: 150),
            Level(level: 4, name: "Veteran", missions: 180),
            Level(level: 5, name: "Champion", missions: 200),
            Level(level: 6, name: "Legend", missions: 230),
            Level(level: 7, name: "Titan", missions: 250),
            Level(level: 8, name: "God", missions: 300)
        ]
    }

    private func achievements() -> [SHAchievement] {
        let total = viewModel.totalMissionsAllTime()
        let bestWeek = viewModel.bestWeekCount()
        let streak = viewModel.dayStreak()

        // 8 карточек (6 твоих + 2 доп)
        return [
            SHAchievement(
                title: "Missions",
                subtitle: "Complete your first mission",
                systemImage: "flag.checkered",
                isUnlocked: total >= 1,
                progressText: "\(min(total, 1))/1"
            ),
            SHAchievement(
                title: "Week Warrior",
                subtitle: "Complete 15 missions in a week",
                systemImage: "calendar.badge.checkmark",
                isUnlocked: bestWeek >= 15,
                progressText: "\(min(bestWeek, 15))/15"
            ),
            SHAchievement(
                title: "Guardian Rising",
                subtitle: "Reach Guardian level",
                systemImage: "shield.lefthalf.filled",
                isUnlocked: viewModel.currentLevel >= 2,
                progressText: viewModel.currentLevel >= 2 ? "Unlocked" : "Level 2"
            ),
            SHAchievement(
                title: "Century Club",
                subtitle: "Complete 100 missions",
                systemImage: "100.square",
                isUnlocked: total >= 100,
                progressText: "\(min(total, 100))/100"
            ),
            SHAchievement(
                title: "Unstoppable",
                subtitle: "Maintain a 30-day streak",
                systemImage: "flame.fill",
                isUnlocked: streak >= 30,
                progressText: "\(min(streak, 30))/30"
            ),
            SHAchievement(
                title: "Legend Status",
                subtitle: "Reach Legend level",
                systemImage: "crown.fill",
                isUnlocked: viewModel.currentLevel >= 6,
                progressText: viewModel.currentLevel >= 6 ? "Unlocked" : "Level 6"
            ),

            // ✅ 2 доп. ачивки (можешь заменить)
            SHAchievement(
                title: "Champion Mode",
                subtitle: "Reach Champion level",
                systemImage: "medal.fill",
                isUnlocked: viewModel.currentLevel >= 5,
                progressText: viewModel.currentLevel >= 5 ? "Unlocked" : "Level 5"
            ),
            SHAchievement(
                title: "Titan Path",
                subtitle: "Reach Titan level",
                systemImage: "bolt.shield.fill",
                isUnlocked: viewModel.currentLevel >= 7,
                progressText: viewModel.currentLevel >= 7 ? "Unlocked" : "Level 7"
            )
        ]
    }
}

// MARK: - UI components

struct RingProgressView: View {
    let progress: CGFloat
    let centerText: String

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.tertiarySystemFill), lineWidth: 10)

            Circle()
                .trim(from: 0, to: max(0, min(progress, 1)))
                .stroke(Color.red, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))

            Text(centerText)
                .font(.subheadline.bold())
        }
        .accessibilityLabel("Cycle progress \(centerText)")
    }
}

struct SHAchievement: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let systemImage: String
    let isUnlocked: Bool
    let progressText: String?
}

struct AchievementCardView: View {
    let achievement: SHAchievement

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack {
                Image(systemName: achievement.systemImage)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(achievement.isUnlocked ? .green : .secondary)

                Spacer()

                Image(systemName: achievement.isUnlocked ? "checkmark.seal.fill" : "lock.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(achievement.isUnlocked ? .green : .secondary)
            }

            Text(achievement.title)
                .font(.headline)

            Text(achievement.subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)

            if let p = achievement.progressText {
                Text(p)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading)
        .background(Color(.tertiarySystemFill))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(achievement.isUnlocked ? Color.green.opacity(0.25) : Color.clear, lineWidth: 1)
        )
    }
}

#Preview {
    SHProfileView(viewModel: SHProfileViewModel())
}
