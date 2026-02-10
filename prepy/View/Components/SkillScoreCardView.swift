//
//  SkillScoreCardView.swift
//  prepy
//
//  Created by Артем Гаврилов on 10.02.26.
//

import SwiftUI

struct SkillScoreCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let score: Double
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(iconColor)
            }
            
            // Title and score
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                Text(String(format: "%.1f", score))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(white: 0.1))
        )
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack(spacing: 12) {
            SkillScoreCard(
                icon: "headphones.circle.fill",
                iconColor: .blue,
                title: "Listening",
                score: 7.0
            )
            
            SkillScoreCard(
                icon: "book.circle.fill",
                iconColor: .green,
                title: "Reading",
                score: 6.5
            )
        }
        .padding()
    }
}
