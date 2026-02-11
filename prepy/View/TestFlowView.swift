//
//  TestFlowView.swift
//  prepy
//
//  Общий поток теста: Listening → Reading → … Единая навигация по этапам.
//  При открытии загружает первый тест из БД и передаёт пассажи/вопросы в Reading.
//

import SwiftUI

struct TestFlowView: View {
    @State private var currentStage: TestStage = .listening
    @State private var isPaused = false
    @State private var showQuestions = false

    @State private var currentTestId: UUID?
    @State private var readingPassages: [ReadingPassage] = []
    @State private var readingQuestions: [Question] = []
    @State private var isLoadingContent = true

    private let repository = SupabaseRepository()
    private let backgroundColor = Color(white: 0.08)

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                TestStageNavigation(
                    stages: TestStage.allCases,
                    currentStage: currentStage,
                    isPaused: $isPaused,
                    onStageTapped: { currentStage = $0 }
                )

                Group {
                    switch currentStage {
                    case .listening:
                        ListeningPracticeScreenView(
                            showHeader: false,
                            onSubmitPart1: { currentStage = .reading }
                        )
                    case .reading:
                        ReadingStageView(
                            showQuestions: $showQuestions,
                            passages: readingPassages,
                            questions: readingQuestions,
                            onMoveToNextStage: { currentStage = .writing }
                        )
                        .overlay {
                            if isLoadingContent {
                                Color(white: 0.08).ignoresSafeArea()
                                ProgressView()
                                    .tint(.orange)
                            }
                        }
                    case .writing:
                        WritingStageView(onFinish: { })
                    case .speaking:
                        SpeakingStageScreenView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task {
            await loadTestContent()
        }
    }

    private func loadTestContent() async {
        isLoadingContent = true
        defer { isLoadingContent = false }

        do {
            let tests = try await repository.fetchTests()
            guard let firstTest = tests.first else { return }
            currentTestId = firstTest.id

            async let passagesTask = repository.fetchReadingPassages(testId: firstTest.id)
            async let questionsTask = repository.fetchQuestions(testId: firstTest.id, section: .reading)
            readingPassages = try await passagesTask
            readingQuestions = try await questionsTask
        } catch {
            readingPassages = []
            readingQuestions = []
        }
    }

    private func placeholderStageView(for stage: TestStage) -> some View {
        VStack {
            Spacer()
            Text("\(stage.rawValue) — coming soon")
                .font(.title2)
                .foregroundColor(.white)
            Spacer()
        }
    }
}

#Preview {
    TestFlowView()
}
