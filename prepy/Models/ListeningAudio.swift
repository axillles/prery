//
//  ListeningAudio.swift
//  prepy
//
//  Соответствует таблице public.listening_audio. storage_path — путь в bucket listening_audio.
//

import Foundation

struct ListeningAudio: Codable, Identifiable, Sendable {
    let id: UUID
    let testId: UUID
    let part: Int
    let storagePath: String
    let durationSeconds: Int
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case testId = "test_id"
        case part
        case storagePath = "storage_path"
        case durationSeconds = "duration_seconds"
        case createdAt = "created_at"
    }
}
