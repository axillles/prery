//
//  SpeakingPrompt.swift
//  prepy
//
//  Соответствует таблице public.speaking_prompts.
//

import Foundation

struct SpeakingPrompt: Codable, Identifiable, Sendable {
    let id: UUID
    let testId: UUID
    let partNumber: Int
    let promptText: String
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case testId = "test_id"
        case partNumber = "part_number"
        case promptText = "prompt_text"
        case createdAt = "created_at"
    }
}
