//
//  StatCardView.swift
//  prepy
//
//  Created by Артем Гаврилов on 10.02.26.
//

import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let iconColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.gray)
            
            HStack {
                Text(value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(iconColor)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(white: 0.15))
        )
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        HStack(spacing: 16) {
            StatCard(
                title: "Daily Streak",
                value: "12 Days",
                icon: "flame.fill",
                iconColor: .orange
            )
            
            StatCard(
                title: "Words Learned",
                value: "842",
                icon: "graduationcap.fill",
                iconColor: .orange
            )
        }
        .padding()
    }
}
