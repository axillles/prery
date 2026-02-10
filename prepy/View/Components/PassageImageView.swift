//
//  PassageImageView.swift
//  prepy
//
//  Created by Артем Гаврилов on 10.02.26.
//

import SwiftUI

struct PassageImage: View {
    var body: some View {
        ZStack {
            // Placeholder for passage image
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(white: 0.2),
                            Color(white: 0.1)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 280)
            
            // Placeholder content - urban garden image simulation
            VStack {
                Spacer()
                HStack(spacing: 8) {
                    ForEach(0..<5) { _ in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.green.opacity(0.3))
                            .frame(width: 60, height: 180)
                    }
                }
                .padding(.bottom, 20)
            }
            
            // You can replace this with actual image:
            // Image("urban_agriculture")
            //     .resizable()
            //     .scaledToFill()
            //     .frame(height: 280)
            //     .clipped()
            //     .cornerRadius(16)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(white: 0.3), lineWidth: 1)
        )
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        PassageImage()
            .padding()
    }
}
