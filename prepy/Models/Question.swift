//
//  Question.swift
//  prepy
//
//  Соответствует таблице public.questions. section и question_type в БД — enum, приходят как строки.
//

import Foundation

/// Секция теста (совпадает с public.question_section в БД).
enum QuestionSection: String, Codable, CaseIterable, Sendable {
    case listening
    case reading
    case writing
    case speaking
}

/// Тип вопроса (совпадает с public.question_type в БД).
enum QuestionType: String, Codable, CaseIterable, Sendable {
    case multipleChoice = "multiple_choice"
    case fillBlank = "fill_blank"
    case matching
    case yesNoNotGiven = "yes_no_not_given"
    case trueFalseNotGiven = "true_false_not_given"
    case sentenceCompletion = "sentence_completion"
    case shortAnswer = "short_answer"
    case other
}

struct Question: Codable, Identifiable, Sendable {
    let id: UUID
    let testId: UUID
    let section: QuestionSection
    let sectionPart: String
    let questionType: QuestionType
    let questionText: String
    /// Варианты ответа: для multiple_choice — массив строк, для matching — массив пар и т.д.
    let options: [String]?
    let orderIndex: Int
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case testId = "test_id"
        case section
        case sectionPart = "section_part"
        case questionType = "question_type"
        case questionText = "question_text"
        case options
        case orderIndex = "order_index"
        case createdAt = "created_at"
    }

    /// Декодирование options: в БД jsonb может быть массивом строк или объектом.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        testId = try c.decode(UUID.self, forKey: .testId)
        section = try c.decode(QuestionSection.self, forKey: .section)
        sectionPart = try c.decode(String.self, forKey: .sectionPart)
        questionType = try c.decode(QuestionType.self, forKey: .questionType)
        questionText = try c.decode(String.self, forKey: .questionText)
        orderIndex = try c.decode(Int.self, forKey: .orderIndex)
        createdAt = try c.decodeIfPresent(Date.self, forKey: .createdAt)
        if let arr = try? c.decode([String].self, forKey: .options) {
            options = arr
        } else if let dict = try? c.decode([String: String].self, forKey: .options) {
            options = Array(dict.values)
        } else {
            options = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(testId, forKey: .testId)
        try c.encode(section, forKey: .section)
        try c.encode(sectionPart, forKey: .sectionPart)
        try c.encode(questionType, forKey: .questionType)
        try c.encode(questionText, forKey: .questionText)
        try c.encodeIfPresent(options, forKey: .options)
        try c.encode(orderIndex, forKey: .orderIndex)
        try c.encodeIfPresent(createdAt, forKey: .createdAt)
    }
}
