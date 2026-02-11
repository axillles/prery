//
//  ReadingSectionData.swift
//  prepy
//
//  Вспомогательные типы для экрана Reading: разбиение пассажа на части, группировка вопросов.
//

import Foundation

/// Одна часть (абзац) пассажа с меткой A, B, C...
struct PassagePart: Sendable {
    let label: String
    let text: String
}

/// Разбивает body_text пассажа на части A, B, C…
/// 1) Сначала заменяем буквальные "\n" (обратный слэш + n) на реальный перенос строки — так бывает, если в БД вставили текст с \n\n как текст.
/// 2) Делим по двойному переносу (\n\n или \r\n\r\n).
/// 3) Если получился один кусок — делим по одиночному \n (каждая строка = абзац), короткие строки объединяем.
func passageParts(from passage: ReadingPassage) -> [PassagePart] {
    var normalized = passage.bodyText
        .replacingOccurrences(of: "\r\n", with: "\n")
        .replacingOccurrences(of: "\r", with: "\n")
    normalized = normalized.replacingOccurrences(of: "\\n", with: "\n")
    let trimmed = normalized.trimmingCharacters(in: .whitespacesAndNewlines)

    var chunks: [String] = trimmed.components(separatedBy: "\n\n")
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }

    if chunks.isEmpty {
        return [PassagePart(label: "A", text: trimmed)]
    }
    if chunks.count == 1 {
        chunks = splitBySingleNewline(trimmed)
    }
    if chunks.isEmpty {
        return [PassagePart(label: "A", text: trimmed)]
    }
    if chunks.count == 1 {
        return [PassagePart(label: "A", text: chunks[0])]
    }
    return chunks.enumerated().map { i, text in
        let label = String(UnicodeScalar(65 + i)!)
        return PassagePart(label: label, text: text)
    }
}

/// Делит по одиночному \n, объединяя слишком короткие строки с предыдущим абзацем.
private func splitBySingleNewline(_ text: String) -> [String] {
    let lines = text.components(separatedBy: "\n")
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }
    guard !lines.isEmpty else { return [text] }
    var paragraphs: [String] = []
    var current = lines[0]
    for line in lines.dropFirst() {
        if line.count < 40, !current.isEmpty {
            current += " " + line
        } else {
            paragraphs.append(current)
            current = line
        }
    }
    paragraphs.append(current)
    return paragraphs
}

/// Блок вопросов внутри одной секции Reading (один тип заданий под одной инструкцией).
struct ReadingQuestionBlock: Sendable {
    let instruction: String
    let questionRange: String  // "1–5", "6–10", "14–19"…
    let questions: [Question]
    let questionType: QuestionType
}

/// Группирует вопросы Reading по секции (section_part "1","2","3") и по блокам (подряд идущие с одним типом).
func readingBlocks(passageNumber: Int, questions: [Question]) -> [ReadingQuestionBlock] {
    let sorted = questions.sorted { $0.orderIndex < $1.orderIndex }
    guard let first = sorted.first else { return [] }
    var blocks: [ReadingQuestionBlock] = []
    var currentType = first.questionType
    var currentGroup: [Question] = [first]
    var startIndex = first.orderIndex

    for q in sorted.dropFirst() {
        if q.questionType == currentType {
            currentGroup.append(q)
        } else {
            let from = startIndex + 1
            let to = startIndex + currentGroup.count
            let rangeStr = from == to ? "\(from)" : "\(from)–\(to)"
            let instruction = instructionForBlock(currentType, passageNumber: passageNumber, count: currentGroup.count)
            blocks.append(ReadingQuestionBlock(
                instruction: instruction,
                questionRange: rangeStr,
                questions: currentGroup,
                questionType: currentType
            ))
            currentType = q.questionType
            currentGroup = [q]
            startIndex = q.orderIndex
        }
    }
    if !currentGroup.isEmpty {
        let from = startIndex + 1
        let to = startIndex + currentGroup.count
        let rangeStr = from == to ? "\(from)" : "\(from)–\(to)"
        let instruction = instructionForBlock(currentType, passageNumber: passageNumber, count: currentGroup.count)
        blocks.append(ReadingQuestionBlock(
            instruction: instruction,
            questionRange: rangeStr,
            questions: currentGroup,
            questionType: currentType
        ))
    }
    return blocks
}

private func instructionForBlock(_ type: QuestionType, passageNumber: Int, count: Int) -> String {
    switch type {
    case .matching:
        if count <= 6 {
            return "Which paragraph contains the following information?\nWrite the correct letter, A–F, in boxes on your answer sheet."
        } else {
            return "Choose the correct heading for paragraphs A–F from the list of headings below.\nWrite the correct number, i–ix, in boxes on your answer sheet."
        }
    case .shortAnswer:
        return "Answer the questions below.\nChoose NO MORE THAN THREE WORDS from the passage for each answer.\nWrite your answers in boxes on your answer sheet."
    case .sentenceCompletion:
        return "Complete each sentence with the correct ending, A–F, below.\nWrite the correct letter, A–F, in boxes on your answer sheet."
    case .yesNoNotGiven:
        return "Do the following statements agree with the views of the writer in Reading Passage \(passageNumber)?\nIn boxes on your answer sheet, write\nYes - if the statement agrees with the views of the writer\nNo - if the statement contradicts the views of the writer\nNot Given - if it is impossible to say what the writer thinks about this"
    case .fillBlank:
        return "Complete the flow chart below.\nChoose NO MORE THAN THREE WORDS from the passage for each answer.\nWrite your answers in boxes on your answer sheet."
    case .multipleChoice:
        return "Choose the correct letter, A, B, C or D.\nWrite the correct letter in box on your answer sheet.\nChoose the most appropriate title for the reading passage."
    default:
        return "Answer the questions below."
    }
}
