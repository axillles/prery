//
//  HeaderSectionView.swift
//  prepy
//
//  Created by Артем Гаврилов on 10.02.26.
//

import SwiftUI

struct HeaderSection: View {
    let userName: String
    let targetBand: Double
    
    var body: some View {
        VStack(spacing: 16) {
            // Owl mascot
            ZStack {
                Circle()
                    .stroke(Color.orange.opacity(0.5), lineWidth: 3)
                    .frame(width: 140, height: 140)
                
                Image(systemName: "eye.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.cyan)
            }
            
            // Title text
            VStack(spacing: 4) {
                HStack(spacing: 0) {
                    Text("Ready to reach ")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Band")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.orange)
                }
                
                HStack(spacing: 0) {
                    Text("\(String(format: "%.1f", targetBand))")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.orange)
                    
                    Text(", \(userName)?")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            // Subtitle
            Text("Let's crush your goals today.")
                .font(.system(size: 16))
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        HeaderSection(userName: "Alex", targetBand: 8.0)
    }
}
