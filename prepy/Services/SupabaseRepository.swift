//
//  SupabaseRepository.swift
//  prepy
//
//  Единая точка запросов к Supabase: тесты, вопросы, аудио, попытки, статистика.
//  После включения Auth запросы к attempts/scores/insights/user_stats будут идти от текущего user_id (RLS).
//

import Foundation
import Supabase

/// Репозиторий для работы с БД Supabase. Все методы async, бросают при сетевых/серверных ошибках.
@MainActor
final class SupabaseRepository: Sendable {

    private let client = SupabaseConfig.client

    // MARK: - Тесты

    /// Все тесты (список для выбора).
    func fetchTests() async throws -> [Test] {
        let response: [Test] = try await client
            .from("tests")
            .select()
            .order("created_at", ascending: false)
            .execute()
            .value
        return response
    }

    /// Один тест по id.
    func fetchTest(id: UUID) async throws -> Test? {
        let response: [Test] = try await client
            .from("tests")
            .select()
            .eq("id", value: id.uuidString)
            .limit(1)
            .execute()
            .value
        return response.first
    }

    // MARK: - Listening

    /// Аудио для теста (все части 1–4). Упорядочено по part.
    func fetchListeningAudio(testId: UUID) async throws -> [ListeningAudio] {
        let response: [ListeningAudio] = try await client
            .from("listening_audio")
            .select()
            .eq("test_id", value: testId.uuidString)
            .order("part", ascending: true)
            .execute()
            .value
        return response
    }

    /// Публичный URL файла в Storage (bucket listening_audio). После настройки Storage подставьте свой bucket.
    func listeningAudioPublicURL(storagePath: String) -> URL? {
        try? client.storage.from("listening_audio").getPublicURL(path: storagePath)
    }

    // MARK: - Reading

    func fetchReadingPassages(testId: UUID) async throws -> [ReadingPassage] {
        let response: [ReadingPassage] = try await client
            .from("reading_passages")
            .select()
            .eq("test_id", value: testId.uuidString)
            .order("passage_number", ascending: true)
            .execute()
            .value
        return response
    }

    func readingImagePublicURL(storagePath: String) -> URL? {
        try? client.storage.from("reading_images").getPublicURL(path: storagePath)
    }

    // MARK: - Writing

    func fetchWritingPrompts(testId: UUID) async throws -> [WritingPrompt] {
        let response: [WritingPrompt] = try await client
            .from("writing_prompts")
            .select()
            .eq("test_id", value: testId.uuidString)
            .order("task_number", ascending: true)
            .execute()
            .value
        return response
    }

    // MARK: - Speaking

    func fetchSpeakingPrompts(testId: UUID) async throws -> [SpeakingPrompt] {
        let response: [SpeakingPrompt] = try await client
            .from("speaking_prompts")
            .select()
            .eq("test_id", value: testId.uuidString)
            .order("part_number", ascending: true)
            .execute()
            .value
        return response
    }

    // MARK: - Вопросы

    /// Все вопросы теста (все секции). Упорядочены по section, section_part, order_index.
    func fetchQuestions(testId: UUID) async throws -> [Question] {
        let response: [Question] = try await client
            .from("questions")
            .select()
            .eq("test_id", value: testId.uuidString)
            .order("section")
            .order("section_part")
            .order("order_index", ascending: true)
            .execute()
            .value
        return response
    }

    /// Вопросы только по одной секции (listening, reading и т.д.).
    func fetchQuestions(testId: UUID, section: QuestionSection) async throws -> [Question] {
        let response: [Question] = try await client
            .from("questions")
            .select()
            .eq("test_id", value: testId.uuidString)
            .eq("section", value: section.rawValue)
            .order("section_part")
            .order("order_index", ascending: true)
            .execute()
            .value
        return response
    }

    // MARK: - Полный контент теста (одним набором запросов)

    /// Загружает всё необходимое для прохождения теста: тест, аудио, пассажи, промпты, вопросы.
    func fetchFullTestContent(testId: UUID) async throws -> FullTestContent {
        async let testTask: Test? = fetchTest(id: testId)
        async let audioTask = fetchListeningAudio(testId: testId)
        async let passagesTask = fetchReadingPassages(testId: testId)
        async let writingTask = fetchWritingPrompts(testId: testId)
        async let speakingTask = fetchSpeakingPrompts(testId: testId)
        async let questionsTask = fetchQuestions(testId: testId)

        let test = try await testTask
        guard let test else { throw SupabaseRepositoryError.testNotFound(testId) }

        return FullTestContent(
            test: test,
            listeningAudio: try await audioTask,
            readingPassages: try await passagesTask,
            writingPrompts: try await writingTask,
            speakingPrompts: try await speakingTask,
            questions: try await questionsTask
        )
    }

    // MARK: - Попытки и результаты (требуют Auth; после включения входа будут работать по RLS)

    /// Начать попытку. После включения Auth передавайте userId из session.user.id.
    func startAttempt(testId: UUID, userId: UUID) async throws -> Attempt {
        struct Insert: Encodable {
            let userId: UUID
            let testId: UUID
            let status: String
            enum CodingKeys: String, CodingKey {
                case userId = "user_id"
                case testId = "test_id"
                case status
            }
        }
        let insert = Insert(userId: userId, testId: testId, status: AttemptStatus.inProgress.rawValue)
        let response: Attempt = try await client
            .from("attempts")
            .insert(insert)
            .select()
            .single()
            .execute()
            .value
        return response
    }

    /// Завершить попытку (completed_at, status = completed).
    func completeAttempt(attemptId: UUID) async throws -> Attempt {
        struct Update: Encodable {
            let completedAt: Date
            let status: String
            enum CodingKeys: String, CodingKey {
                case completedAt = "completed_at"
                case status
            }
        }
        let update = Update(completedAt: Date(), status: AttemptStatus.completed.rawValue)
        let response: Attempt = try await client
            .from("attempts")
            .update(update)
            .eq("id", value: attemptId.uuidString)
            .select()
            .single()
            .execute()
            .value
        return response
    }

    /// Сохранить баллы по секциям (после ответа нейросети).
    func saveAttemptScores(attemptId: UUID, scores: [(section: QuestionSection, score: Double)]) async throws {
        struct Row: Encodable {
            let attemptId: UUID
            let section: String
            let score: Double
            enum CodingKeys: String, CodingKey {
                case attemptId = "attempt_id"
                case section
                case score
            }
        }
        let rows = scores.map { Row(attemptId: attemptId, section: $0.section.rawValue, score: $0.score) }
        try await client
            .from("attempt_scores")
            .insert(rows)
            .execute()
    }

    /// Сохранить выводы нейросети по секциям.
    func saveAttemptInsights(
        attemptId: UUID,
        section: QuestionSection,
        insightsJson: [String: AnyCodable],
        vocabularyGaps: [String]?
    ) async throws {
        struct Row: Encodable {
            let attemptId: UUID
            let section: String
            let insightsJson: [String: AnyCodable]
            let vocabularyGaps: [String]?
            enum CodingKeys: String, CodingKey {
                case attemptId = "attempt_id"
                case section
                case insightsJson = "insights_json"
                case vocabularyGaps = "vocabulary_gaps"
            }
        }
        let row = Row(attemptId: attemptId, section: section.rawValue, insightsJson: insightsJson, vocabularyGaps: vocabularyGaps)
        try await client
            .from("attempt_insights")
            .insert(row)
            .execute()
    }

    /// История попыток пользователя (для графиков). Работает после включения Auth.
    /// Возвращает все попытки; отфильтровать по completed_at != nil на клиенте при необходимости.
    func fetchAttempts(limit: Int = 50) async throws -> [Attempt] {
        let response: [Attempt] = try await client
            .from("attempts")
            .select()
            .order("created_at", ascending: false)
            .limit(limit)
            .execute()
            .value
        return response
    }

    /// Баллы по попытке (для отображения результата).
    func fetchAttemptScores(attemptId: UUID) async throws -> [AttemptScore] {
        let response: [AttemptScore] = try await client
            .from("attempt_scores")
            .select()
            .eq("attempt_id", value: attemptId.uuidString)
            .execute()
            .value
        return response
    }

    // MARK: - Статистика пользователя (требует Auth)

    func fetchUserStats() async throws -> UserStats? {
        let response: [UserStats] = try await client
            .from("user_stats")
            .select()
            .limit(1)
            .execute()
            .value
        return response.first
    }

    /// Обновить streak / last_activity / current_level (вызывать после завершения попытки или изучения слов).
    /// После включения Auth передавайте userId из session.user.id (RLS обновит только строку этого пользователя).
    func updateUserStats(
        userId: UUID,
        dailyStreak: Int? = nil,
        wordsLearnedCount: Int? = nil,
        lastActivityDate: String? = nil,
        currentLevel: Double? = nil
    ) async throws {
        struct Update: Encodable {
            let dailyStreak: Int?
            let wordsLearnedCount: Int?
            let lastActivityDate: String?
            let currentLevel: Double?
            enum CodingKeys: String, CodingKey {
                case dailyStreak = "daily_streak"
                case wordsLearnedCount = "words_learned_count"
                case lastActivityDate = "last_activity_date"
                case currentLevel = "current_level"
            }
            func encode(to encoder: Encoder) throws {
                var c = encoder.container(keyedBy: CodingKeys.self)
                try c.encodeIfPresent(dailyStreak, forKey: .dailyStreak)
                try c.encodeIfPresent(wordsLearnedCount, forKey: .wordsLearnedCount)
                try c.encodeIfPresent(lastActivityDate, forKey: .lastActivityDate)
                try c.encodeIfPresent(currentLevel, forKey: .currentLevel)
            }
        }
        let update = Update(
            dailyStreak: dailyStreak,
            wordsLearnedCount: wordsLearnedCount,
            lastActivityDate: lastActivityDate,
            currentLevel: currentLevel
        )
        try await client
            .from("user_stats")
            .update(update)
            .eq("user_id", value: userId.uuidString)
            .execute()
    }
}

// MARK: - Вспомогательные типы

/// Полный контент одного теста для экранов Listening / Reading / Writing / Speaking.
struct FullTestContent: Sendable {
    let test: Test
    let listeningAudio: [ListeningAudio]
    let readingPassages: [ReadingPassage]
    let writingPrompts: [WritingPrompt]
    let speakingPrompts: [SpeakingPrompt]
    let questions: [Question]
}

enum SupabaseRepositoryError: Error, Sendable {
    case testNotFound(UUID)
}
