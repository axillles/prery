//
//  ViewQuestionButtonView.swift
//  prepy
//
//  Created by Артем Гаврилов on 10.02.26.
//

import SwiftUI

struct ViewQuestionsButton: View {
    @Binding var showQuestions: Bool
    
    var body: some View {
        Button(action: {
            showQuestions = true
            print("View Questions tapped")
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("READY TO ANSWER?")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                        .tracking(1)
                    
                    Text("View Questions")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.15))
                    )
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.orange,
                        Color.orange.opacity(0.9)
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
        VStack {
            Spacer()
            ViewQuestionsButton(showQuestions: .constant(false))
                .padding()
        }
    }
}
