//
//  WritingStageView.swift
//  prepy
//
//  Экран Writing Task 2: Essay Response — промпт, поле ввода с тулбаром, кнопка Finish & Review.
//

import SwiftUI

struct WritingStageView: View {
    var onFinish: (() -> Void)?

    @State private var essayText = "In recent years, the debate surrounding mandator... students has gained momentur Proponents argue that such..."
    @State private var timeRemaining = 2295 // 38:15

    private let backgroundColor = Color(white: 0.08)
    private let cardBackground = Color(white: 0.12)
    private let accentOrange = Color.orange

    private var timeFormatted: String {
        let m = timeRemaining / 60
        let s = timeRemaining % 60
        return String(format: "%d:%02d", m, s)
    }

    private let essayPrompt = """
Some people believe that unpaid community service should be a compulsory part of high school programs (for example working for a charity, improving the neighborhood or teaching sports to younger children).
To what extent do you agree or disagree?
"""

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        taskHeader
                        essayPromptCard
                        writingInputCard
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 120)
                }
                .scrollIndicators(.hidden)

                finishButton
            }
        }
    }

    // MARK: - Task Header (WRITING TASK 2, Essay Response, timer)

    private var taskHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text("WRITING TASK 2")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(accentOrange)
                    .tracking(1)
                Text("Essay Response")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
            Spacer()
            HStack(spacing: 8) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 16))
                    .foregroundColor(accentOrange)
                Text(timeFormatted)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Capsule().fill(Color(white: 0.18)))
        }
    }

    // MARK: - Essay Prompt Card

    private var essayPromptCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "doc.text")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                Text("ESSAY PROMPT")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .tracking(1)
            }
            Text(essayPrompt)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .lineSpacing(6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(cardBackground)
        .cornerRadius(16)
    }

    // MARK: - Writing Input Card (toolbar, TextEditor, tip, G button)

    private var writingInputCard: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 0) {
                // Formatting toolbar
                HStack(spacing: 16) {
                    formatButton(title: "B", bold: true)
                    formatButton(title: "I", bold: false)
                    formatButton(title: "U", bold: false)
                    Image(systemName: "list.bullet")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding(.bottom, 12)

                TextEditor(text: $essayText)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 180)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(cardBackground)
            .cornerRadius(16)

            // Floating tip (orange)
            Text("Tip: Use varied vocabulary!")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(accentOrange)
                .cornerRadius(10)
                .offset(x: -16, y: -140)

            // G circle (grammar assistant)
            Button {} label: {
                Text("G")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(accentOrange)
                    .frame(width: 44, height: 44)
                    .background(Color(white: 0.2))
                    .clipShape(Circle())
            }
            .offset(x: -8, y: -12)
        }
    }

    private func formatButton(title: String, bold: Bool) -> some View {
        Text(title)
            .font(.system(size: 16, weight: bold ? .bold : .semibold))
            .foregroundColor(.white)
    }

    // MARK: - Finish & Review Button

    private var finishButton: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [backgroundColor.opacity(0), backgroundColor],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 32)

            Button {
                onFinish?()
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("COMPLETED?")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))
                            .tracking(1)
                        Text("Finish & Review")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Image(systemName: "checkmark")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                .background(accentOrange)
                .cornerRadius(16)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .background(backgroundColor)
    }
}

#Preview {
    WritingStageView()
}
