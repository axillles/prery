//
//  UserStats.swift
//  prepy
//
//  Соответствует таблице public.user_stats. Чтение/запись только для авторизованного пользователя.
//

import Foundation

struct UserStats: Codable, Sendable {
    let userId: UUID
    let dailyStreak: Int
    let wordsLearnedCount: Int
    let lastActivityDate: String?
    let currentLevel: Double?
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case dailyStreak = "daily_streak"
        case wordsLearnedCount = "words_learned_count"
        case lastActivityDate = "last_activity_date"
        case currentLevel = "current_level"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
