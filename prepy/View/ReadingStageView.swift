//
//  ReadingStageView.swift
//  prepy
//
//  Экран этапа Reading: заголовок пассажа, изображение, текст, кнопка «View Questions».
//

import SwiftUI

struct ReadingStageView: View {
    @Binding var showQuestions: Bool

    var passageNumber: Int = 1
    var totalPassages: Int = 3
    var title: String = "Urban Agriculture"
    var timeRemaining: Int = 1122 // 18:42

    private let backgroundColor = Color(white: 0.08)

    var body: some View {
        ZStack(alignment: .bottom) {
            backgroundColor.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    PassageHeader(
                        passageNumber: passageNumber,
                        totalPassages: totalPassages,
                        title: title,
                        timeRemaining: timeRemaining
                    )

                    PassageImage()

                    ZStack(alignment: .bottomTrailing) {
                        PassageText()
                            .padding(.bottom, 20)

                        // Плавающая иконка глаза с зелёной точкой (справа внизу над текстом)
                        floatingEyeButton
                            .padding(.trailing, 20)
                            .padding(.bottom, 100)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 120)
            }
            .scrollIndicators(.hidden)

            // Градиент и кнопка «View Questions»
            VStack(spacing: 0) {
                LinearGradient(
                    colors: [backgroundColor.opacity(0), backgroundColor],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 32)

                ViewQuestionsButton(showQuestions: $showQuestions)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
            }
            .background(backgroundColor)
        }
    }

    private var floatingEyeButton: some View {
        ZStack(alignment: .topTrailing) {
            Button {} label: {
                Image(systemName: "eye")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.orange)
                    .frame(width: 44, height: 44)
                    .background(Color(red: 0.4, green: 0.25, blue: 0.2)) // красновато-коричневый
                    .clipShape(Circle())
            }
            Circle()
                .fill(Color.green)
                .frame(width: 10, height: 10)
                .overlay(Circle().stroke(backgroundColor, lineWidth: 2))
                .offset(x: 2, y: -2)
        }
    }
}

#Preview {
    ReadingStageView(showQuestions: .constant(false))
}
