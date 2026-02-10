//
//  TestStageNavigationView.swift
//  prepy
//
//  Created by Артем Гаврилов on 10.02.26.
//

import SwiftUI

struct TestStageNavigation: View {
    let stages: [TestStage]
    let currentStage: TestStage
    @Binding var isPaused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(stages, id: \.self) { stage in
                HStack(spacing: 6) {
                    Text(stage.rawValue)
                        .font(.system(size: 15, weight: stage.isActive ? .semibold : .regular))
                        .foregroundColor(stageTextColor(for: stage))
                    
                    if stage.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.green)
                    }
                }
                
                // Separator
                if stage != stages.last {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 8, height: 2)
                }
            }
            
            Spacer()
            
            // Pause button
            Button(action: {
                isPaused.toggle()
            }) {
                Image(systemName: isPaused ? "play.circle.fill" : "pause.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(white: 0.1))
    }
    
    private func stageTextColor(for stage: TestStage) -> Color {
        if stage.isCompleted {
            return .green
        } else if stage.isActive {
            return stage.color
        } else {
            return .gray
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        TestStageNavigation(
            stages: TestStage.allCases,
            currentStage: .reading,
            isPaused: .constant(false)
        )
    }
}
