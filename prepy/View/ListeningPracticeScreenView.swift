//
//  ListeningPracticeScreenView.swift
//  prepy
//
//  Экран практики Listening по макету: навигация, плеер, вопросы, Submit.
//

import SwiftUI

// MARK: - Модель этапов

private enum PracticeStage: String, CaseIterable {
    case listening = "Listening"
    case reading = "Reading"
    case writing = "Writing"
    case speaking = "Speaking"
}

// MARK: - Основной экран

struct ListeningPracticeScreenView: View {
    /// Показывать ли верхнюю навигацию (Listening | Reading | …). В потоке теста навигация общая.
    var showHeader: Bool = true
    /// Вызывается при нажатии «Submit Part 1» — переход к следующему этапу (Reading).
    var onSubmitPart1: (() -> Void)?

    @State private var currentStage: PracticeStage = .listening
    @State private var isPaused = false
    @State private var elapsedSeconds = 134 // 02:14
    private let totalSeconds = 330 // 05:30
    @State private var selectedQ1: Int?
    @State private var selectedQ2: Int?

    private let backgroundColor = Color(white: 0.08)
    private let cardBackground = Color(white: 0.12)
    private let accentOrange = Color.orange

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                if showHeader { headerNavigation }
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        audioPlayerSection
                        questionsSection
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 120)
                }
                .scrollIndicators(.hidden)

                submitButton
            }
        }
    }

    // MARK: - Верхняя навигация (Listening | Reading | Writing | Speaking + кнопка паузы)

    private var headerNavigation: some View {
        HStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(PracticeStage.allCases, id: \.self) { stage in
                        HStack(spacing: 6) {
                            if stage == currentStage {
                                Circle()
                                    .fill(accentOrange)
                                    .frame(width: 6, height: 6)
                            }
                            Text(stage.rawValue)
                                .font(.system(size: 15, weight: stage == currentStage ? .semibold : .regular))
                                .foregroundColor(stage == currentStage ? accentOrange : .gray)
                        }
                        .fixedSize(horizontal: true, vertical: false)

                        if stage != PracticeStage.allCases.last {
                            Rectangle()
                                .fill(Color.gray.opacity(0.4))
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
                Image(systemName: "pause.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .frame(width: 40, height: 40)
                    .background(Color(white: 0.2))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(white: 0.1))
    }

    // MARK: - Секция аудиоплеера (AUDIO PART 1, кнопка, волна, таймер)

    private var audioPlayerSection: some View {
        let elapsedFormatted = formatTime(elapsedSeconds)
        let totalFormatted = formatTime(totalSeconds)

        return VStack(alignment: .leading, spacing: 16) {
            Text("AUDIO PART 1")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)

            HStack(alignment: .center, spacing: 12) {
                Button {
                    isPaused.toggle()
                } label: {
                    Image(systemName: isPaused ? "play.fill" : "pause.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                        .frame(width: 48, height: 48)
                        .background(accentOrange)
                        .clipShape(Circle())
                }
                .fixedSize()

                // Волновая форма: компактная, чтобы влезала на узкий экран
                waveformView

                HStack(spacing: 2) {
                    Text(elapsedFormatted)
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundColor(accentOrange)
                    Text(" / \(totalFormatted)")
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundColor(.gray)
                }
                .fixedSize(horizontal: true, vertical: false)
            }
            .padding(16)
            .background(cardBackground)
            .cornerRadius(16)
        }
    }

    private var waveformView: some View {
        let totalBars = 20
        let barWidth: CGFloat = 2
        let barSpacing: CGFloat = 2
        let progress = totalSeconds > 0 ? Double(elapsedSeconds) / Double(totalSeconds) : 0
        let filledCount = Int(Double(totalBars) * progress)
        let heights: [CGFloat] = [20, 32, 24, 40, 18, 36, 28, 22, 38, 30, 24, 34, 26, 42, 20, 30, 28, 36, 22, 40]

        return HStack(spacing: barSpacing) {
            ForEach(0..<totalBars, id: \.self) { i in
                RoundedRectangle(cornerRadius: 1)
                    .fill(i < filledCount ? accentOrange : Color.gray.opacity(0.5))
                    .frame(width: barWidth, height: heights[i % heights.count])
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity)
    }

    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    // MARK: - Секция вопросов (Questions 1-5, Part 1, варианты ответов)

    private var questionsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 8) {
                Text("Questions 1-5")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Spacer(minLength: 0)
                Text("Part 1")
                    .font(.system(size: 13))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(white: 0.2))
                    .cornerRadius(8)
            }

            question1Block
            question2Block
        }
    }

    private var question1Block: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 4) {
                Text("1.")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(accentOrange)
                    .fixedSize(horizontal: true, vertical: false)
                Text("What is the customer's primary reason for calling the insurance company?")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
            }

            optionRow(selected: $selectedQ1, value: 1, text: "To renew an existing car insurance policy.")
            optionRow(selected: $selectedQ1, value: 2, text: "To inquire about a quote for a new vehicle.")
            optionRow(selected: $selectedQ1, value: 3, text: "To file a claim for a recent accident.")
        }
    }

    private var question2Block: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 8) {
                Text("2.")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(accentOrange)
                    .fixedSize(horizontal: true, vertical: false)
                Text("Which type of coverage does the agent recommend?")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
                    .layoutPriority(1)
                Spacer(minLength: 0)
                // Кнопка с иконкой глаза и зелёным индикатором
                ZStack(alignment: .topTrailing) {
                    Button {} label: {
                        Image(systemName: "eye")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(accentOrange)
                            .frame(width: 44, height: 44)
                            .background(Color(white: 0.2))
                            .clipShape(Circle())
                    }
                    Circle()
                        .fill(Color.green)
                        .frame(width: 10, height: 10)
                        .overlay(Circle().stroke(backgroundColor, lineWidth: 2))
                        .offset(x: 2, y: -2)
                }
                .fixedSize(horizontal: true, vertical: false)
            }

            optionRow(selected: $selectedQ2, value: 1, text: "Comprehensive only")
            optionRow(selected: $selectedQ2, value: 2, text: "Third-party only")
            optionRow(selected: $selectedQ2, value: 3, text: "Both comprehensive and third-party")
        }
    }

    private func optionRow(selected: Binding<Int?>, value: Int, text: String) -> some View {
        Button {
            selected.wrappedValue = selected.wrappedValue == value ? nil : value
        } label: {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: selected.wrappedValue == value ? "circle.inset.filled" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(selected.wrappedValue == value ? accentOrange : .gray)
                Text(text)
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
            }
            .padding(16)
            .background(cardBackground)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Кнопка Submit Part 1

    private var submitButton: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [backgroundColor.opacity(0), backgroundColor],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 32)

            Button {
                onSubmitPart1?()
            } label: {
                HStack(spacing: 12) {
                    Text("Submit Part 1")
                        .font(.system(size: 18, weight: .semibold))
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
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
    ListeningPracticeScreenView()
}
