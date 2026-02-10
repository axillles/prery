//
//  SwiftUIView.swift
//  prepy
//
//  Created by Артем Гаврилов on 10.02.26.
//

import SwiftUI

struct CurrentLevelCard: View {
    let currentLevel: Double
    let listeningScore: Double
    let readingScore: Double
    let writingScore: Double
    let speakingScore: Double
    
    var body: some View {
        VStack(spacing: 20) {
            // Current level header
            Text("CURRENT LEVEL")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.gray)
                .tracking(1.5)
            
            // Main score
            Text(String(format: "%.1f", currentLevel))
                .font(.system(size: 72, weight: .bold))
                .foregroundColor(.white)
            
            // Overall band score label
            Text("Overall Band Score")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.orange)
            
            // Skills grid
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    SkillScoreCard(
                        icon: "headphones.circle.fill",
                        iconColor: .blue,
                        title: "Listening",
                        score: listeningScore
                    )
                    
                    SkillScoreCard(
                        icon: "book.circle.fill",
                        iconColor: .green,
                        title: "Reading",
                        score: readingScore
                    )
                }
                
                HStack(spacing: 12) {
                    SkillScoreCard(
                        icon: "pencil.circle.fill",
                        iconColor: .purple,
                        title: "Writing",
                        score: writingScore
                    )
                    
                    SkillScoreCard(
                        icon: "mic.circle.fill",
                        iconColor: .yellow,
                        title: "Speaking",
                        score: speakingScore
                    )
                }
            }
            .padding(.horizontal, 12)
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(white: 0.15))
        )
        .padding(.horizontal, 20)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        CurrentLevelCard(
            currentLevel: 6.5,
            listeningScore: 7.0,
            readingScore: 6.5,
            writingScore: 6.0,
            speakingScore: 6.5
        )
    }
}
