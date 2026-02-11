//
//  Attempt.swift
//  prepy
//
//  Соответствует таблицам public.attempts, attempt_scores, attempt_insights.
//  Запись попыток требует авторизации (user_id).
//

import Foundation

enum AttemptStatus: String, Codable, Sendable {
    case inProgress = "in_progress"
    case completed
    case abandoned
}

struct Attempt: Codable, Identifiable, Sendable {
    let id: UUID
    let userId: UUID
    let testId: UUID
    let startedAt: Date?
    let completedAt: Date?
    let status: AttemptStatus
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case testId = "test_id"
        case startedAt = "started_at"
        case completedAt = "completed_at"
        case status
        case createdAt = "created_at"
    }
}

struct AttemptScore: Codable, Identifiable, Sendable {
    let id: UUID
    let attemptId: UUID
    let section: QuestionSection
    let score: Double
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case attemptId = "attempt_id"
        case section
        case score
        case createdAt = "created_at"
    }
}

struct AttemptInsight: Codable, Identifiable, Sendable {
    let id: UUID
    let attemptId: UUID
    let section: QuestionSection
    let insightsJson: [String: AnyCodable]?
    let vocabularyGaps: [String]?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case attemptId = "attempt_id"
        case section
        case insightsJson = "insights_json"
        case vocabularyGaps = "vocabulary_gaps"
        case createdAt = "created_at"
    }
}

/// Для декодирования произвольного JSON в insights_json.
struct AnyCodable: Codable, Sendable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let b = try? c.decode(Bool.self) { value = b }
        else if let i = try? c.decode(Int.self) { value = i }
        else if let d = try? c.decode(Double.self) { value = d }
        else if let s = try? c.decode(String.self) { value = s }
        else if let a = try? c.decode([AnyCodable].self) { value = a.map(\.value) }
        else if let o = try? c.decode([String: AnyCodable].self) { value = o.mapValues(\.value) }
        else { value = NSNull() }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        switch value {
        case let b as Bool: try c.encode(b)
        case let i as Int: try c.encode(i)
        case let d as Double: try c.encode(d)
        case let s as String: try c.encode(s)
        case let a as [Any]: try c.encode(a.map { AnyCodable($0) })
        case let o as [String: Any]: try c.encode(o.mapValues { AnyCodable($0) })
        default: try c.encodeNil()
        }
    }
}
