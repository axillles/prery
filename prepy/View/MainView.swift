//
//  MainView.swift
//  prepy
//
//  Created by Артем Гаврилов on 9.02.26.
//

import SwiftUI

struct MainView: View {
    @State private var currentLevel: Double = 6.5
    @State private var targetBand: Double = 8.0
    @State private var userName: String = "Alex"
    @State private var dailyStreak: Int = 12
    @State private var wordsLearned: Int = 842
    
    @State private var listeningScore: Double = 7.0
    @State private var readingScore: Double = 6.5
    @State private var writingScore: Double = 6.0
    @State private var speakingScore: Double = 6.5
    
    @State private var showSettings = false
    @State private var showExam = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header with owl mascot
                    HeaderSection(userName: userName, targetBand: targetBand)
                    
                    // Current level card
                    CurrentLevelCard(
                        currentLevel: currentLevel,
                        listeningScore: listeningScore,
                        readingScore: readingScore,
                        writingScore: writingScore,
                        speakingScore: speakingScore
                    )
                    
                    // Stats row
                    HStack(spacing: 16) {
                        StatCard(
                            title: "Daily Streak",
                            value: "\(dailyStreak) Days",
                            icon: "flame.fill",
                            iconColor: .orange
                        )
                        
                        StatCard(
                            title: "Words Learned",
                            value: "\(wordsLearned)",
                            icon: "graduationcap.fill",
                            iconColor: .orange
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    // Start test button
                    StartTestButton {
                        showExam = true
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
                .padding(.top, 20)
            }
            .overlay(alignment: .topTrailing) {
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                        .symbolRenderingMode(.hierarchical)
                }
                .padding(.top, 8)
                .padding(.trailing, 20)
            }
        }
        .sheet(isPresented: $showSettings) {
            Text("Settings")
                .foregroundColor(.white)
                .presentationDetents([.medium])
        }
        .fullScreenCover(isPresented: $showExam) {
            TestFlowView()
        }
    }
}

#Preview {
    MainView()
}
