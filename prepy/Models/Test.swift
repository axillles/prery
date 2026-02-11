//
//  Test.swift
//  prepy
//
//  Соответствует таблице public.tests.
//

import Foundation

struct Test: Codable, Identifiable, Sendable {
    let id: UUID
    let title: String
    let topicSlug: String
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case topicSlug = "topic_slug"
        case createdAt = "created_at"
    }
}
