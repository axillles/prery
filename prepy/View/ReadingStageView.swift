//
//  ReadingStageView.swift
//  prepy
//
//  Reading: 3 секции, в каждой — пассаж (части A, B, C…) и блоки вопросов.
//  Прокручиваемый экран, внизу кнопки «К предыдущей секции» / «К следующей секции».
//

import SwiftUI

// MARK: - Константы

private let backgroundColor = Color(white: 0.08)
private let cardBackground = Color(white: 0.12)
private let accentOrange = Color.orange
private let textPrimary = Color.white
private let textSecondary = Color.gray
private let borderColor = Color(white: 0.25)

// MARK: - ReadingStageView

struct ReadingStageView: View {
    @Binding var showQuestions: Bool

    /// Пассажи для теста (порядок: 1, 2, 3). Если пусто — показываем заглушку.
    var passages: [ReadingPassage] = []
    /// Вопросы секции Reading (section == .reading), отфильтрованные по section_part "1", "2", "3".
    var questions: [Question] = []

    var timeRemaining: Int = 1122
    var onMoveToNextStage: (() -> Void)?

    @State private var currentSectionIndex: Int = 0

    private var totalSections: Int { max(1, passages.count) }
    private var currentSection: Int { min(currentSectionIndex + 1, totalSections) }
    private var passageForCurrentSection: ReadingPassage? {
        guard currentSectionIndex < passages.count else { return nil }
        return passages[currentSectionIndex]
    }
    private var questionsForCurrentSection: [Question] {
        let part = "\(currentSection)"
        return questions.filter { $0.sectionPart == part }.sorted { $0.orderIndex < $1.orderIndex }
    }
    private var blocksForCurrentSection: [ReadingQuestionBlock] {
        readingBlocks(passageNumber: currentSection, questions: questionsForCurrentSection)
    }

    /// Секция 2: сначала блок с заголовками (14–19), потом пассаж, потом Yes/No/NG (20–26).
    private var section2BlocksBeforePassage: [ReadingQuestionBlock] {
        blocksForCurrentSection.filter { isHeadingBlock($0) }
    }
    private var section2BlocksAfterPassage: [ReadingQuestionBlock] {
        blocksForCurrentSection.filter { !isHeadingBlock($0) }
    }
    private func isHeadingBlock(_ block: ReadingQuestionBlock) -> Bool {
        block.questionType == .matching && (block.questions.first?.options?.first?.lowercased().hasPrefix("i") == true)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            backgroundColor.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    sectionHeader
                    if currentSectionIndex == 1 {
                        section2Layout
                    } else {
                        if let passage = passageForCurrentSection {
                            passageContent(passage)
                        } else {
                            placeholderPassage
                        }
                        questionsContent
                    }
                    bottomSpacer
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 140)
            }
            .scrollIndicators(.hidden)

            sectionNavButtons
        }
    }

    // MARK: - Заголовок секции и таймер

    private var sectionHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text("READING SECTION \(currentSection) OF \(totalSections)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(accentOrange)
                    .tracking(1)
                Text(passageForCurrentSection?.title ?? "Reading Passage \(currentSection)")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(textPrimary)
            }
            Spacer()
            HStack(spacing: 8) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 16))
                    .foregroundColor(accentOrange)
                Text(timeFormatted(timeRemaining))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(textPrimary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(white: 0.15)))
        }
    }

    // MARK: - Текст пассажа по частям (A, B, C…)

    private func passageContent(_ passage: ReadingPassage) -> some View {
        let parts = passageParts(from: passage)
        return VStack(alignment: .leading, spacing: 24) {
            Text("Reading Passage \(currentSection) has \(parts.count) paragraph\(parts.count == 1 ? "" : "s"), \(parts.map(\.label).joined(separator: "–")).")
                .font(.system(size: 14))
                .foregroundColor(textSecondary)
            ForEach(Array(parts.enumerated()), id: \.offset) { _, part in
                passagePartView(label: part.label, text: part.text)
            }
        }
    }

    private func passagePartView(label: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 10) {
                Text(label)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(accentOrange)
                    .clipShape(Circle())
                Text("Paragraph \(label)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(textSecondary)
            }
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(textPrimary)
                .lineSpacing(6)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(white: 0.12))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(white: 0.22), lineWidth: 1)
        )
    }

    private var placeholderPassage: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Reading Passage \(currentSection) has six paragraphs, A–F.")
                .font(.system(size: 14))
                .foregroundColor(textSecondary)
            Text("Passage content will load from the database.")
                .font(.system(size: 16))
                .foregroundColor(textSecondary)
        }
    }

    /// Секция 2: блок заголовков → пассаж → блок Yes/No/Not Given.
    private var section2Layout: some View {
        Group {
            ForEach(Array(section2BlocksBeforePassage.enumerated()), id: \.offset) { _, block in
                ReadingBlockView(block: block)
            }
            if let passage = passageForCurrentSection {
                passageContent(passage)
            }
            ForEach(Array(section2BlocksAfterPassage.enumerated()), id: \.offset) { _, block in
                ReadingBlockView(block: block)
            }
        }
    }

    // MARK: - Блоки вопросов

    private var questionsContent: some View {
        VStack(alignment: .leading, spacing: 24) {
            ForEach(Array(blocksForCurrentSection.enumerated()), id: \.offset) { _, block in
                ReadingBlockView(block: block)
            }
        }
    }

    private var bottomSpacer: some View {
        Color.clear.frame(height: 24)
    }

    // MARK: - Кнопки навигации по секциям

    private var sectionNavButtons: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [backgroundColor.opacity(0), backgroundColor],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 28)
            HStack(spacing: 16) {
                if currentSectionIndex > 0 {
                    Button {
                        currentSectionIndex -= 1
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                            Text("К предыдущей секции Reading")
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                if currentSectionIndex < totalSections - 1 {
                    Button {
                        currentSectionIndex += 1
                    } label: {
                        HStack(spacing: 8) {
                            Text("К секции \(currentSectionIndex + 2) Reading")
                            Image(systemName: "chevron.right")
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(accentOrange)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                } else {
                    Button {
                        onMoveToNextStage?()
                    } label: {
                        HStack(spacing: 8) {
                            Text("Move to Writing")
                            Image(systemName: "chevron.right")
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(accentOrange)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .background(backgroundColor)
    }

    private func timeFormatted(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}

// MARK: - Один блок вопросов (инструкция + список)

struct ReadingBlockView: View {
    let block: ReadingQuestionBlock
    @State private var selectedOptions: [UUID: String] = [:]
    @State private var textAnswers: [UUID: String] = [:]

    private func setOption(_ questionId: UUID, _ value: String) {
        selectedOptions = selectedOptions.merging([questionId: value], uniquingKeysWith: { $1 })
    }
    private func setTextAnswer(_ questionId: UUID, _ value: String) {
        let words = value.split(separator: " ").prefix(3)
        textAnswers = textAnswers.merging([questionId: words.joined(separator: " ")], uniquingKeysWith: { $1 })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Questions \(block.questionRange)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(accentOrange)
            Text(block.instruction)
                .font(.system(size: 14))
                .foregroundColor(textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            if block.questionType == .matching && isHeadingStyle(block) {
                headingMatchBlock(block)
            } else {
                ForEach(Array(block.questions.enumerated()), id: \.element.id) { idx, q in
                    questionRow(question: q, number: (block.questions.first?.orderIndex ?? 0) + idx + 1, block: block)
                }
            }
        }
    }

    private func isHeadingStyle(_ block: ReadingQuestionBlock) -> Bool {
        guard let opts = block.questions.first?.options, !opts.isEmpty else { return false }
        let first = opts[0].lowercased()
        return first == "i" || first == "ii" || first == "iii" || first.hasPrefix("i ")
    }

    private func headingMatchBlock(_ block: ReadingQuestionBlock) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("List of Headings")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(textPrimary)
            if let opts = block.questions.first?.options {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(Array(opts.enumerated()), id: \.offset) { _, heading in
                        Text(heading)
                            .font(.system(size: 14))
                            .foregroundColor(textSecondary)
                    }
                }
            }
            ForEach(Array(block.questions.enumerated()), id: \.element.id) { idx, q in
                let questionNumber = (block.questions.first?.orderIndex ?? 0) + idx + 1
                HStack(alignment: .top, spacing: 12) {
                    Text("\(questionNumber)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(accentOrange)
                        .frame(width: 24, alignment: .trailing)
                    Text(q.questionText)
                        .font(.system(size: 14))
                        .foregroundColor(textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    dropdown(options: q.options ?? [], selected: optionBinding(q.id)) {}
                }
            }
        }
    }

    private func questionRow(question: Question, number: Int, block: ReadingQuestionBlock) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(accentOrange)
                .frame(width: 24, alignment: .trailing)
            Text(question.questionText)
                .font(.system(size: 14))
                .foregroundColor(textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            answerControl(question: question, block: block)
        }
    }

    @ViewBuilder
    private func answerControl(question: Question, block: ReadingQuestionBlock) -> some View {
        switch block.questionType {
        case .shortAnswer:
            threeWordField(questionId: question.id)
        case .fillBlank:
            threeWordField(questionId: question.id)
        case .yesNoNotGiven:
            dropdown(
                options: ["Yes", "No", "Not Given"],
                selected: optionBinding(question.id)
            ) {}
        case .multipleChoice:
            dropdown(options: question.options ?? [], selected: optionBinding(question.id)) {}
        case .matching, .sentenceCompletion:
            dropdown(options: question.options ?? [], selected: optionBinding(question.id)) {}
        default:
            dropdown(options: question.options ?? [], selected: optionBinding(question.id)) {}
        }
    }

    private func threeWordField(questionId: UUID) -> some View {
        TextField("", text: Binding(
            get: { textAnswers[questionId] ?? "" },
            set: { setTextAnswer(questionId, $0) }
        ))
            .font(.system(size: 14))
            .foregroundColor(textPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(width: 140)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(borderColor, lineWidth: 1))
    }

    private func dropdown(options: [String], selected: Binding<String>, onSelect: @escaping () -> Void) -> some View {
        Menu {
            ForEach(options, id: \.self) { opt in
                Button(opt) {
                    selected.wrappedValue = opt
                    onSelect()
                }
            }
        } label: {
            HStack {
                Text(selected.wrappedValue.isEmpty ? "Choose" : selected.wrappedValue)
                    .font(.system(size: 14))
                    .foregroundColor(selected.wrappedValue.isEmpty ? textSecondary : textPrimary)
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.system(size: 12))
                    .foregroundColor(textSecondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(minWidth: 80)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(borderColor, lineWidth: 1))
        }
    }

    private func optionBinding(_ questionId: UUID) -> Binding<String> {
        Binding(
            get: { selectedOptions[questionId] ?? "" },
            set: { setOption(questionId, $0) }
        )
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        backgroundColor.ignoresSafeArea()
        ReadingStageView(
            showQuestions: .constant(false),
            passages: [],
            questions: []
        )
    }
}
