//
//  HeroHubView.swift
//  Build a sports hero
//
//

import SwiftUI

struct HeroHubView: View {
    @ObservedObject var viewModel: SHProfileViewModel
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                VStack {
                    Text("Hero Hub")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.black)
                    
                    Rectangle()
                        .frame(height: 2)
                        .foregroundStyle(.black.opacity(0.5))
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 12) {
                        Circle()
                            .frame(height: 80)
                            .foregroundStyle(.red)
                            .overlay {
                                Image(systemName: "shield")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(.white)
                                    .frame(height: 40)
                            }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.currentProfile.name)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(.black)
                            
                            Text("Level \(viewModel.currentProfile.level)")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 0) {
                            Text("Missions")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.black)
                            
                            Text("\(viewModel.missionCompleted)/\(viewModel.currentProfile.missions)")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        
                        ProgressView(value: viewModel.missionProgress)
                            .progressViewStyle(.linear)
                            .tint(viewModel.missionCompleted == viewModel.currentProfile.missions ? .green : .red)
                            .scaleEffect(y: 1.5)
                        
                        Text("100 missions to Guardian")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 0) {
                            Text("Weekly Goal")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.black)
                            
                            Text("\(viewModel.weeklyGoal)/15")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        
                        ProgressView(value: viewModel.weeklyProgress)
                            .progressViewStyle(.linear)
                            .tint(viewModel.weeklyGoal == 15 ? .green : .red)
                            .scaleEffect(y: 1.5)
                    }
                    if !viewModel.completedMissions.isEmpty {
                        VStack {
                            Text("Today's Missions")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(.black)
                            
                            ForEach(viewModel.completedMissions) { mission in
                                
                                HStack {
                                    VStack(alignment: .leading, spacing: 8) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(mission.title)
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundStyle(.black)
                                            
                                            Text(mission.subtitle)
                                                .font(.system(size: 13, weight: .regular))
                                                .foregroundStyle(.secondary)
                                        }
                                        Text(mission.details)
                                            .font(.system(size: 13, weight: .regular))
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    VStack(alignment: .trailing, spacing: 27) {
                                        Text(mission.category.rawValue)
                                            .font(.system(size: 10, weight: .regular))
                                            .foregroundStyle(.secondary)
                                            .padding(4)
                                            .padding(.horizontal, 8)
                                            .background(.secondary.opacity(0.2))
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                        
                                        Button {
                                            viewModel.uncompleteMission(mission)
                                        } label: {
                                            Text(viewModel.isMissionCompleted(mission) ? "Complete" : "+ Add")
                                                .font(.system(size: 13, weight: .semibold))
                                                .foregroundStyle(.white)
                                                .padding(4)
                                                .padding(.horizontal, 8)
                                                .background(.red)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                }
                                .padding()
                                .overlay {
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(lineWidth: 1)
                                        .foregroundStyle(.secondary.opacity(0.3))
                                }
                                
                            }
                        }
                    }
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Available Missions")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.black)
                        
                        ForEach(viewModel.missions) { mission in
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(mission.title)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundStyle(.black)
                                        
                                        Text(mission.subtitle)
                                            .font(.system(size: 13, weight: .regular))
                                            .foregroundStyle(.secondary)
                                    }
                                    Text(mission.details)
                                        .font(.system(size: 13, weight: .regular))
                                        .foregroundStyle(.secondary)
                                }
                                
                                VStack(alignment: .trailing, spacing: 27) {
                                    Text(mission.category.rawValue)
                                        .font(.system(size: 10, weight: .regular))
                                        .foregroundStyle(.secondary)
                                        .padding(4)
                                        .padding(.horizontal, 8)
                                        .background(.secondary.opacity(0.2))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    
                                    Button {
                                        viewModel.completeMission(mission)
                                    } label: {
                                        Text("+ Add")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundStyle(.white)
                                            .padding(4)
                                            .padding(.horizontal, 8)
                                            .background(.red)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            .padding()
                            .overlay {
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(lineWidth: 1)
                                    .foregroundStyle(.secondary.opacity(0.3))
                            }
                        }
                        
                    }
                }.padding(.horizontal, 24)
            }
            
        }
        
    }
}

#Preview {
    HeroHubView(viewModel: SHProfileViewModel())
}
