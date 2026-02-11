# Интеграция приложения с Supabase

Краткий чеклист: что уже сделано в коде и что нужно сделать вам.

---

## 1. Что уже в проекте

- **Config/SupabaseConfig.swift** — URL и anon key. Нужно подставить свои значения из Dashboard → Settings → API.
- **Models/** — модели под таблицы: `Test`, `ListeningAudio`, `ReadingPassage`, `WritingPrompt`, `SpeakingPrompt`, `Question`, `Attempt`, `AttemptScore`, `AttemptInsight`, `UserStats`.
- **Services/SupabaseRepository.swift** — все запросы к БД:
  - тесты: `fetchTests()`, `fetchTest(id:)`, `fetchFullTestContent(testId:)`;
  - контент по тесту: `fetchListeningAudio`, `fetchReadingPassages`, `fetchWritingPrompts`, `fetchSpeakingPrompts`, `fetchQuestions` (все по `testId`);
  - попытки: `startAttempt(testId:userId:)`, `completeAttempt(attemptId:)`, `saveAttemptScores`, `saveAttemptInsights`, `fetchAttempts`, `fetchAttemptScores`;
  - статистика: `fetchUserStats()`, `updateUserStats(userId:...)`;
  - URL аудио/картинок: `listeningAudioPublicURL(storagePath:)`, `readingImagePublicURL(storagePath:)`.
- В **project.pbxproj** добавлен пакет **supabase-swift** (SPM). При первом открытии проекта Xcode может предложить разрешить пакеты — нажмите «Resolve Package Graph».

---

## 2. Что сделать перед запуском

1. **Подставить ключи в SupabaseConfig.swift**
   - `url` — например `https://ВАШ_PROJECT_REF.supabase.co`
   - `anonKey` — anon public key из API Settings.

2. **RLS и доступ без Auth**
   - Сейчас политики на чтение контента (tests, questions, listening_audio и т.д.) настроены на `authenticated`. Пока Auth не включён, запросы с anon key не пройдут.
   - Варианты:
     - **A)** Временно разрешить чтение для anon. В SQL:
       ```sql
       create policy "tests_select_anon" on public.tests for select to anon using (true);
       -- и аналогично для listening_audio, reading_passages, writing_prompts, speaking_prompts, questions
       ```
       После включения Auth можно оставить только политики для `authenticated` и удалить anon.
     - **B)** Включить Auth и использовать анонимный вход (`signInAnonymously`) или тестового пользователя — тогда запросы пойдут от `authenticated`.

3. **Storage**
   - В Dashboard созданы бакеты (например `listening_audio`, `reading_images`). В коде уже используются имена `listening_audio` и `reading_images` в методах `listeningAudioPublicURL` / `readingImagePublicURL`.
   - Если бакет публичный — URL из `getPublicURL` достаточно. Если приватный — нужна политика на `storage.objects` для select для authenticated (или anon, по вашему выбору).

---

## 3. Как вызывать репозиторий из UI

- Создайте один общий экземпляр (например через `@StateObject`/Environment или синглтон) и вызывайте методы из экранов.

**Пример: список тестов**

```swift
@State private var tests: [Test] = []
@State private var loading = true
@State private var error: Error?

let repo = SupabaseRepository()

// в .task или onAppear:
do {
    tests = try await repo.fetchTests()
} catch {
    self.error = error
}
loading = false
```

**Пример: полный контент теста для TestFlowView**

```swift
let content = try await repo.fetchFullTestContent(testId: selectedTestId)
// content.test, content.listeningAudio, content.readingPassages, content.writingPrompts, content.speakingPrompts, content.questions
```

**Пример: воспроизведение аудио Listening**

- Получить список: `let audio = try await repo.fetchListeningAudio(testId: id)`.
- URL для части: `repo.listeningAudioPublicURL(storagePath: item.storagePath)` (подставить путь из `ListeningAudio.storagePath`).
- Передать URL в AVPlayer или свой плеер.

---

## 4. После включения Auth

- При входе (Email / Apple / Google) получите сессию и сохраняйте `session.user.id` (UUID).
- При начале попытки: `let attempt = try await repo.startAttempt(testId: testId, userId: session.user.id)`.
- При обновлении статистики: `try await repo.updateUserStats(userId: session.user.id, dailyStreak: newStreak, ...)`.
- Запросы `fetchAttempts()`, `fetchUserStats()` будут возвращать только данные текущего пользователя (RLS).

---

## 5. Даты в ответах

Supabase отдаёт даты в ISO8601 (например `2024-01-01T12:00:00.000Z`). Модели используют `Date?`. Если при декодировании появятся ошибки по полям с датами, можно перейти на строки (например `createdAt: String?`) и парсить вручную через `ISO8601DateFormatter` с опцией `.withFractionalSeconds`.

---

## 6. Кэш

После первой успешной загрузки теста/контента можно сохранять результат локально (UserDefaults, файлы, Core Data) и при следующем открытии сначала показывать кэш, затем обновлять в фоне через репозиторий.
