//
//  WritingPrompt.swift
//  prepy
//
//  Соответствует таблице public.writing_prompts.
//

import Foundation

struct WritingPrompt: Codable, Identifiable, Sendable {
    let id: UUID
    let testId: UUID
    let taskNumber: Int
    let promptText: String
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case testId = "test_id"
        case taskNumber = "task_number"
        case promptText = "prompt_text"
        case createdAt = "created_at"
    }
}
