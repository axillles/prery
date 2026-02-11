//
//  StartTestButtonView.swift
//  prepy
//
//  Created by Артем Гаврилов on 10.02.26.
//

import SwiftUI

struct StartTestButton: View {
    var action: (() -> Void)?
    
    var body: some View {
        Button(action: {
            action?()
        }) {
            HStack(spacing: 12) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 24))
                
                Text("Start Full Mock Test")
                    .font(.system(size: 18, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.orange,
                        Color.orange.opacity(0.8)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        StartTestButton()
            .padding()
    }
}
