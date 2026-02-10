//
//  PassageHeaderView.swift
//  prepy
//
//  Created by Артем Гаврилов on 10.02.26.
//

import SwiftUI

struct PassageHeader: View {
    let passageNumber: Int
    let totalPassages: Int
    let title: String
    let timeRemaining: Int
    
    var formattedTime: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text("PASSAGE \(passageNumber) OF \(totalPassages)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.orange)
                    .tracking(1)
                
                Text(title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Timer
            HStack(spacing: 8) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.orange)
                
                Text(formattedTime)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(white: 0.15))
            )
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        PassageHeader(
            passageNumber: 1,
            totalPassages: 3,
            title: "Urban Agriculture",
            timeRemaining: 1122
        )
        .padding()
    }
}
