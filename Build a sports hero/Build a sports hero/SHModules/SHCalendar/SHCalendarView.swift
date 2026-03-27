//
//  SHCalendarView.swift
//  Build a sports hero
//
//

import SwiftUI

struct SHCalendarView: View {
    @ObservedObject var viewModel: SHProfileViewModel
    
    @State private var selectedDate: Date = Date()
    @State private var displayedMonth: Date = Date()
    
    var cal: Calendar = {
        var c = Calendar.current
        c.firstWeekday = 2 // Monday
        return c
    }()
    
    var body: some View {
        VStack(spacing: 16) {
            VStack {
                Text("Calendar")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.black)
                
                Rectangle()
                    .frame(height: 2)
                    .foregroundStyle(.black.opacity(0.5))
            }
            .padding(.horizontal, -16)
            
            header
            VStack {
                weekDays
                
                grid
            }
            .padding()
            .background(.appGray.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            selectedInfo
            
            missionsList
            
            Spacer()
        }
        .padding(.horizontal)
        .onAppear {
            // если приложение долго было закрыто — обновим "today"
            viewModel.checkDailyReset()
        }
    }
    
    private var header: some View {
        HStack {
            Button { displayedMonth = shiftMonth(-1) } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .frame(width: 40, height: 40)
                    .foregroundStyle(.white)
                    .background(.red)
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Text(monthTitle(displayedMonth))
                .font(.system(size: 25, weight: .medium))
            
            Spacer()
            
            Button { displayedMonth = shiftMonth(1) } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .semibold))
                    .frame(width: 40, height: 40)
                    .foregroundStyle(.white)
                    .background(.red)
                    .clipShape(Circle())
            }
        }
    }
    
    private var weekDays: some View {
        let days = ["M","T","W","T","F","S","S"]
        return HStack {
            ForEach(days, id: \.self) { d in
                Text(d)
                    .font(.caption.weight(.medium))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var grid: some View {
        let days = makeDays(for: displayedMonth)
        
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
            ForEach(days.indices, id: \.self) { idx in
                if let date = days[idx] {
                    dayCell(date)
                } else {
                    Color.clear.frame(height: 40)
                }
            }
        }
    }
    
    private func dayCell(_ date: Date) -> some View {
        let isSelected = cal.isDate(date, inSameDayAs: selectedDate)
        let isToday = cal.isDateInToday(date)
        
        return Button {
            selectedDate = date
        } label: {
            ZStack(alignment: .bottomTrailing) {
                Text("\(cal.component(.day, from: date))")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(width: 40, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Date.now < date ? Color.white : viewModel.hasCompletedMissions(on: date) ? Color.green : Color.red)
                    )//
                    .overlay {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 1)
                                .foregroundStyle(.black)
                        }
                    }
            }
        }
        .buttonStyle(.plain)
    }
    
    private var selectedInfo: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(fullDate(selectedDate))
                .font(.system(size: 20, weight: .semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var missionsList: some View {
        let items = viewModel.missionsCompleted(on: selectedDate)
        
        return VStack(alignment: .leading, spacing: 12) {
            if items.isEmpty {
                Text("No completed missions on this day")
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 10) {
                        ForEach(items) { mission in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(mission.title).font(.headline)
                                    Text(mission.subtitle).font(.subheadline).foregroundColor(.secondary)
                                }
                                Spacer()
                                Text(mission.category.rawValue)
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .frame(maxHeight: 320)
            }
        }
    }
    
    // MARK: - Helpers
    
    private func shiftMonth(_ value: Int) -> Date {
        cal.date(byAdding: .month, value: value, to: displayedMonth) ?? displayedMonth
    }
    
    private func monthTitle(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "LLLL yyyy"
        return f.string(from: date)
    }
    
    private func fullDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "dd MMMM yyyy"
        return f.string(from: date)
    }
    
    private func makeDays(for month: Date) -> [Date?] {
        // 1) start of month
        let comps = cal.dateComponents([.year, .month], from: month)
        guard let startOfMonth = cal.date(from: comps),
              let range = cal.range(of: .day, in: .month, for: startOfMonth) else {
            return []
        }
        
        // 2) leading blanks (Mon-first)
        let weekday = cal.component(.weekday, from: startOfMonth)
        let leading = (weekday - cal.firstWeekday + 7) % 7
        
        var result: [Date?] = Array(repeating: nil, count: leading)
        
        // 3) month days
        for day in range {
            if let d = cal.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                result.append(d)
            }
        }
        
        // 4) pad to full weeks
        while result.count % 7 != 0 {
            result.append(nil)
        }
        
        return result
    }
}

#Preview {
    SHCalendarView(viewModel: SHProfileViewModel())
}
