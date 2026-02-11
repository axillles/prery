//
//  TestStageNavigationView.swift
//  prepy
//
//  Created by Артем Гаврилов on 10.02.26.
//

import SwiftUI

enum TestStage: String, CaseIterable {
    case listening = "Listening"
    case reading = "Reading"
    case writing = "Writing"
    case speaking = "Speaking"
}

struct TestStageNavigation: View {
    let stages: [TestStage]
    let currentStage: TestStage
    @Binding var isPaused: Bool
    /// При тапе на этап — переключение (например на Writing).
    var onStageTapped: ((TestStage) -> Void)?

    private var currentIndex: Int {
        stages.firstIndex(of: currentStage) ?? 0
    }
    
    private func isStageCompleted(_ stage: TestStage) -> Bool {
        guard let index = stages.firstIndex(of: stage) else { return false }
        return index < currentIndex
    }
    
    private func isStageActive(_ stage: TestStage) -> Bool {
        stage == currentStage
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Этапы в одну строку, без переноса и обрезки — горизонтальный скролл при нехватке места
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(stages, id: \.self) { stage in
                        Button {
                            onStageTapped?(stage)
                        } label: {
                            HStack(spacing: 6) {
                                if isStageActive(stage) {
                                    Circle()
                                        .fill(Color.orange)
                                        .frame(width: 6, height: 6)
                                }
                                Text(stage.rawValue)
                                    .font(.system(size: 15, weight: isStageActive(stage) ? .semibold : .regular))
                                    .foregroundColor(stageTextColor(for: stage))
                                    .lineLimit(1)
                                    .fixedSize(horizontal: true, vertical: false)
                                if isStageCompleted(stage) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.green)
                                }
                            }
                            .fixedSize(horizontal: true, vertical: false)
                        }
                        .buttonStyle(.plain)
                        if stage != stages.last {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 8, height: 2)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
            .frame(maxWidth: .infinity)

            Button {
                isPaused.toggle()
            } label: {
                Image(systemName: isPaused ? "play.circle.fill" : "pause.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.gray)
            }
            .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(white: 0.1))
    }
    
    private func stageTextColor(for stage: TestStage) -> Color {
        if isStageCompleted(stage) {
            return .green
        } else if isStageActive(stage) {
            return .orange
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
            currentStage: .listening,
            isPaused: .constant(false)
        )
    }
}
