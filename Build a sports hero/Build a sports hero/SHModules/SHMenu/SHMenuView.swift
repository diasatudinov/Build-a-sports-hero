//
//  SHMenuView.swift
//  Build a sports hero
//
//

import SwiftUI

struct SHMenuContainer: View {
    
    @AppStorage("firstOpenBB") var firstOpen: Bool = true
    var body: some View {
        NavigationStack {
            ZStack {
                SHMenuView()
            }
        }
    }
}

struct SHMenuView: View {
    
    @State var selectedTab = 0
    @StateObject var viewModel = SHProfileViewModel()
    private let tabs = ["Hero Hub", "Calendar", "Stats", "Profile"]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            TabView(selection: $selectedTab) {
                HeroHubView(viewModel: viewModel)
                    .tag(0)
                
                SHCalendarView(viewModel: viewModel)
                    .tag(1)
                
                SHStatisticsView(viewModel: viewModel)
                    .tag(2)
                
                Color.pink
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .padding(.bottom, 95)
            
            customTabBar
        }
        .ignoresSafeArea()
    }
    
    private var customTabBar: some View {
        HStack(spacing: 30) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Button {
                    selectedTab = index
                } label: {
                    VStack(spacing: 4) {
                        Image(selectedTab == index ? selectedIcon(for: index) : icon(for: index))
                            .resizable()
                            .scaledToFit()
                            .frame(height: 36)
                        
                        Text(tabs[index])
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.black)
                            .padding(.bottom, 10)
                    }
                    .padding(.horizontal, 4)
                    .padding(.top, 17)
                    .padding(.bottom, 4)
                    .background(.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 32))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(.white)
        .padding(.bottom, 5)
        .overlay {
            Rectangle()
                .stroke(lineWidth: 2)
                .foregroundStyle(.black.opacity(0.5))
        }
    }
    
    private func icon(for index: Int) -> String {
        switch index {
        case 0: return "tab1IconSH"
        case 1: return "tab2IconSH"
        case 2: return "tab3IconSH"
        case 3: return "tab4IconSH"
        default: return ""
        }
    }
    
    private func selectedIcon(for index: Int) -> String {
        switch index {
        case 0: return "tab1IconSelectedSH"
        case 1: return "tab2IconSelectedSH"
        case 2: return "tab3IconSelectedSH"
        case 3: return "tab4IconSelectedSH"
        default: return ""
        }
    }
}


#Preview {
    SHMenuView()
}
