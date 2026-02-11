//
//  ReadingPassage.swift
//  prepy
//
//  Соответствует таблице public.reading_passages.
//

import Foundation

struct ReadingPassage: Codable, Identifiable, Sendable {
    let id: UUID
    let testId: UUID
    let passageNumber: Int
    let title: String?
    let bodyText: String
    let imageStoragePath: String?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case testId = "test_id"
        case passageNumber = "passage_number"
        case title
        case bodyText = "body_text"
        case imageStoragePath = "image_storage_path"
        case createdAt = "created_at"
    }
}
