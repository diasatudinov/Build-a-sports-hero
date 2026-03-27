import SwiftUI
import Charts

struct SHStatisticsView: View {

    @ObservedObject var viewModel: SHProfileViewModel

    private let weeklyGoalTarget: Int = 15

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                weeklyActivityCard

                muscleGroupsCard

                summaryGrid
            }
            .padding()
        }
        .navigationTitle("Statistics")
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Weekly Activity

    private var weeklyActivityCard: some View {
        let data = viewModel.weeklyActivity(lastWeeks: 7)

        return VStack(alignment: .leading, spacing: 10) {
            Text("Weekly Activity")
                .font(.headline)

            Chart {
                ForEach(data) { item in
                    BarMark(
                        x: .value("Week", item.weekStart),
                        y: .value("Missions", item.count)
                    )
                    .cornerRadius(6)
                }

                RuleMark(y: .value("Goal", weeklyGoalTarget))
                    .foregroundStyle(.red)
                    .lineStyle(StrokeStyle(lineWidth: 2))
            }
            .frame(height: 220)
            .chartYAxis {
                AxisMarks(position: .leading)
            }
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
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Muscle Groups

    private var muscleGroupsCard: some View {
        let stats = viewModel.muscleGroupStats()

        return VStack(alignment: .leading, spacing: 10) {
            Text("Muscle Groups")
                .font(.headline)

            Chart {
                ForEach(stats) { item in
                    BarMark(
                        x: .value("Count", item.count),
                        y: .value("Group", item.category.rawValue)
                    )
                    .cornerRadius(6)
                }
            }
            .frame(height: 240)
            .chartXAxis {
                AxisMarks(position: .bottom)
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
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
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.title3.bold())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Date formatting

    private func shortWeekLabel(_ date: Date) -> String {
        // пример: "Mar 4"
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: date)
    }
}