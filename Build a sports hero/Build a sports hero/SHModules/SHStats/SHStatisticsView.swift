//
//  SHStatisticsView.swift
//  Build a sports hero
//
//  Created by Dias Atudinov on 27.03.2026.
//


import SwiftUI
import Charts

struct SHStatisticsView: View {

    @ObservedObject var viewModel: SHProfileViewModel

    private let weeklyGoalTarget: Int = 15

    var body: some View {
        ScrollView {
            VStack {
                Text("Calendar")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.black)
                
                Rectangle()
                    .frame(height: 2)
                    .foregroundStyle(.black.opacity(0.5))
            }
            .padding(.horizontal, -16)
            
            VStack(spacing: 16) {

                weeklyActivityCard

                muscleGroupsCard

                summaryGrid
            }
            .padding()
        }
    }

    // MARK: - Weekly Activity (Line + Points + dashed red goal line)

    private var weeklyActivityCard: some View {
        let data = viewModel.weeklyActivity(lastWeeks: 7)

        return VStack(alignment: .leading, spacing: 10) {
            Text("Weekly Activity")
                .font(.system(size: 20, weight: .semibold))

            Chart {
                ForEach(data) { item in
                    LineMark(
                        x: .value("Week", item.weekStart),
                        y: .value("Missions", item.count)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(.red)
                }

                ForEach(data) { item in
                    PointMark(
                        x: .value("Week", item.weekStart),
                        y: .value("Missions", item.count)
                    )
                    .foregroundStyle(.red)
                }

                RuleMark(y: .value("Goal", weeklyGoalTarget))
                    .foregroundStyle(.red)
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [6, 4]))
            }
            .frame(height: 220)
            .chartYAxis { AxisMarks(position: .leading) }
            .chartXAxis {
                AxisMarks(values: .stride(by: .weekOfYear)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(shortWeekLabel(date))
                        }
                    }
                }
            }

            Text("Red line shows weekly goal of 15 missions")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    // MARK: - Muscle Groups (Bar chart)

    private var muscleGroupsCard: some View {
        let stats = viewModel.muscleGroupStats()

        return VStack(alignment: .leading, spacing: 10) {
            Text("Muscle Groups")
                .font(.system(size: 20, weight: .semibold))

            Chart {
                ForEach(stats) { item in
                    BarMark(
                        x: .value("Group", item.category.rawValue),
                        y: .value("Count", item.count)
                    )
                    .cornerRadius(10)
                    .foregroundStyle(.red)
                }
            }
            .frame(height: 240)
            .chartYAxis { AxisMarks(position: .leading) }
            .chartXAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        // подписи категорий могут быть длинными — чуть уменьшим
                        if let label = value.as(String.self) {
                            Text(label).font(.caption2)
                        }
                    }
                }
            }
        }
        .padding()
    }

    // MARK: - Summary

    private var summaryGrid: some View {
        let total = viewModel.totalMissionsCount()
        let thisWeek = viewModel.thisWeekCount()
        let streak = viewModel.dayStreak()
        let bestWeek = viewModel.bestWeekCount()

        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            metricCard(title: "Total Missions", value: "\(total)")
            metricCard(title: "This Week", value: "\(thisWeek)")
            metricCard(title: "Streak", value: "\(streak) days")
            metricCard(title: "Best Week", value: "\(bestWeek)")
        }
    }

    private func metricCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(.secondary)

            Text(value)
                .font(.system(size: 24, weight: .semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }

    // MARK: - Date formatting

    private func shortWeekLabel(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: date)
    }
}

#Preview {
    SHStatisticsView(viewModel: SHProfileViewModel())
}
