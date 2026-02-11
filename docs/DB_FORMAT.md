# Формат данных для заполнения БД (Supabase)

Как заполнять таблицы, чтобы приложение корректно отображало тесты, Reading, Listening и т.д.

---

## 1. Таблица `tests`

| Колонка       | Тип   | Описание                    |
|---------------|-------|-----------------------------|
| id            | uuid  | Авто (gen_random_uuid)      |
| title         | text  | Название теста             |
| topic_slug    | text  | Тема (латиница, например urban_agriculture) |
| created_at    | timestamptz | Опционально, по умолчанию now() |

**Пример INSERT:**

```sql
insert into public.tests (title, topic_slug)
values ('IELTS Practice Test 1', 'urban_agriculture')
returning id;
```

Сохраните возвращённый `id` — он понадобится для `reading_passages`, `questions`, `listening_audio` и т.д. как `test_id`.

---

## 2. Таблица `reading_passages`

Один тест = 3 пассажа (секции Reading 1, 2, 3).

| Колонка            | Тип    | Описание |
|--------------------|--------|----------|
| test_id            | uuid   | ID теста из `tests` |
| passage_number     | smallint | 1, 2 или 3 |
| title              | text   | Заголовок пассажа (например "Urban Agriculture") |
| body_text          | text   | **Весь текст.** Абзацы разделяйте **двумя переносами строки** `\n\n` — приложение разобьёт их на части A, B, C… |
| image_storage_path | text   | Опционально, путь к картинке в Storage |

**Формат `body_text`:** чтобы на экране получились абзацы с метками A, B, C…, пишите абзацы через двойной перенос. В приложении обрабатываются оба варианта:
- **реальные переносы строк** (если вставляете текст из редактора, где между абзацами Enter дважды);
- **буквальные `\n\n`** (если в Supabase вставили текст с символами обратный слэш и n: `\n\n`) — приложение заменит их на переносы и разобьёт абзацы.

```
Первый абзац текста пассажа...

Второй абзац...

Третий абзац...
```

**Пример INSERT (после того как получили test_id):**

```sql
insert into public.reading_passages (test_id, passage_number, title, body_text)
values
  (
    'ваш-test-uuid',
    1,
    'Urban Agriculture',
    'By 2050, nearly 80% of the earth''s population will reside in urban centers...\n\nHistorically, some 15% of that has been laid waste by poor management practices.\n\nNew approaches are needed to feed cities sustainably.'
  ),
  (
    'ваш-test-uuid',
    2,
    'Passage Two Title',
    'Paragraph A text here...\n\nParagraph B text...\n\nParagraph C...'
  ),
  (
    'ваш-test-uuid',
    3,
    'Passage Three Title',
    'First paragraph...\n\nSecond...\n\nThird...'
  );
```

---

## 3. Таблица `questions`

Вопросы для **Reading**: привязка к тесту, секция Reading, часть секции (1/2/3), тип, текст, варианты ответа (если есть), порядок.

| Колонка       | Тип    | Описание |
|---------------|--------|----------|
| test_id       | uuid   | ID теста |
| section       | enum   | **`reading`** (или listening, writing, speaking) |
| section_part  | text   | **`"1"`**, **`"2"`** или **`"3"`** — номер секции Reading (Passage 1, 2, 3) |
| question_type | enum   | См. список ниже |
| question_text | text   | Текст вопроса или утверждения |
| options       | jsonb  | Варианты ответа: **массив строк** в JSON, например `["A", "B", "C", "D", "E", "F"]` или `["Yes", "No", "Not Given"]` |
| order_index   | int    | Порядок вопроса в рамках **всего** Reading (0–39). По нему строятся номера "Questions 1–5", "6–10" и т.д. |

**Типы вопросов (`question_type`) для Reading:**

| Значение в БД           | Использование в приложении |
|-------------------------|----------------------------|
| `matching`              | "Which paragraph contains..." (A–F / A–H) или "Choose the correct heading" (i–ix) |
| `short_answer`         | "NO MORE THAN THREE WORDS" — поле ввода |
| `sentence_completion`  | "Complete with the correct ending A–F" — дропдаун |
| `yes_no_not_given`     | Yes / No / Not Given — дропдаун из 3 вариантов |
| `fill_blank`           | Flow chart, "NO MORE THAN THREE WORDS" — поле ввода |
| `multiple_choice`      | Один из вариантов A/B/C/D — дропдаун |

**Формат `options` (jsonb):** всегда **JSON-массив строк**.

- Буквы абзацев: `["A", "B", "C", "D", "E", "F"]` или `["A", "B", "C", "D", "E", "F", "G", "H"]`
- Заголовки (List of Headings): `["i", "ii", "iii", "iv", "v", "vi", "vii", "viii", "ix"]` (или полные формулировки заголовков)
- Варианты для multiple choice: `["Option A text", "Option B text", "Option C text", "Option D text"]`
- Yes/No/Not Given приложение подставляет само; в БД можно оставить `null` или пустой массив для этого типа.

**Примеры INSERT для Reading (подставьте ваш test_id):**

```sql
-- Секция 1: вопросы 1–5 (which paragraph), 6–10 (three words), 11–13 (correct ending)
insert into public.questions (test_id, section, section_part, question_type, question_text, options, order_index)
values
  ('test-uuid', 'reading', '1', 'matching', 'A description of how urban farming started.', '["A", "B", "C", "D", "E", "F"]', 0),
  ('test-uuid', 'reading', '1', 'matching', 'Mention of the amount of land required for traditional farming.', '["A", "B", "C", "D", "E", "F"]', 1),
  ('test-uuid', 'reading', '1', 'matching', 'Reference to the impact of poor soil management.', '["A", "B", "C", "D", "E", "F"]', 2),
  ('test-uuid', 'reading', '1', 'matching', 'An explanation of why food production will need to increase.', '["A", "B", "C", "D", "E", "F"]', 3),
  ('test-uuid', 'reading', '1', 'matching', 'Examples of crops that can be grown in urban areas.', '["A", "B", "C", "D", "E", "F"]', 4),
  ('test-uuid', 'reading', '1', 'short_answer', 'What proportion of the world''s population will live in cities by 2050?', null, 5),
  ('test-uuid', 'reading', '1', 'short_answer', 'How much additional land will be needed for farming?', null, 6),
  -- ... ещё short_answer с order_index 7, 8, 9
  ('test-uuid', 'reading', '1', 'sentence_completion', 'Traditional farming often causes...', '["A", "B", "C", "D", "E", "F"]', 10),
  ('test-uuid', 'reading', '1', 'sentence_completion', 'Urban agriculture can reduce...', '["A", "B", "C", "D", "E", "F"]', 11),
  ('test-uuid', 'reading', '1', 'sentence_completion', 'Some cities have introduced...', '["A", "B", "C", "D", "E", "F"]', 12);

-- Секция 2: вопросы 14–19 (headings), 20–26 (Yes/No/Not Given)
-- section_part = '2', order_index с 13 до 25
insert into public.questions (test_id, section, section_part, question_type, question_text, options, order_index)
values
  ('test-uuid', 'reading', '2', 'matching', 'Paragraph A', '["i", "ii", "iii", "iv", "v", "vi", "vii", "viii", "ix"]', 13),
  ('test-uuid', 'reading', '2', 'matching', 'Paragraph B', '["i", "ii", "iii", "iv", "v", "vi", "vii", "viii", "ix"]', 14),
  -- ... Paragraph C, D, E, F с order_index 15–18
  ('test-uuid', 'reading', '2', 'yes_no_not_given', 'The writer believes that urban farming will replace traditional agriculture.', null, 19),
  ('test-uuid', 'reading', '2', 'yes_no_not_given', 'Rooftop gardens are only suitable for certain types of vegetables.', null, 20),
  -- ... ещё 5–6 утверждений с order_index 21–25

-- Секция 3: вопросы 27–32 (which paragraph), 33–39 (flow chart), 40 (multiple choice)
-- section_part = '3', order_index с 26 до 39
insert into public.questions (test_id, section, section_part, question_type, question_text, options, order_index)
values
  ('test-uuid', 'reading', '3', 'matching', 'A comparison of different farming methods.', '["A", "B", "C", "D", "E", "F", "G", "H"]', 26),
  -- ... ещё 5 matching с order_index 27–31
  ('test-uuid', 'reading', '3', 'fill_blank', 'Step 1: _____', null, 32),
  ('test-uuid', 'reading', '3', 'fill_blank', 'Step 2: _____', null, 33),
  -- ... ещё fill_blank 34–38
  ('test-uuid', 'reading', '3', 'multiple_choice', 'Choose the most appropriate title for the reading passage.', '["The future of cities", "Feeding cities in 2050", "The end of traditional farming", "Urban agriculture today"]', 39);
```

---

## 4. Таблица `listening_audio`

| Колонка           | Тип    | Описание |
|-------------------|--------|----------|
| test_id           | uuid   | ID теста |
| part              | smallint | 1, 2, 3 или 4 |
| storage_path      | text   | Путь к файлу в bucket `listening_audio`, например `test-uuid/part_1.mp3` |
| duration_seconds  | int    | Длительность в секундах |

**Пример:**

```sql
insert into public.listening_audio (test_id, part, storage_path, duration_seconds)
values
  ('test-uuid', 1, 'test-uuid/part_1.mp3', 330),
  ('test-uuid', 2, 'test-uuid/part_2.mp3', 300);
```

Файлы нужно загрузить в Storage в bucket `listening_audio` по путям из `storage_path`.

---

## 5. Таблицы `writing_prompts` и `speaking_prompts`

**writing_prompts:** `test_id`, `task_number` (1, 2), `prompt_text` (текст задания).

**speaking_prompts:** `test_id`, `part_number` (1, 2, 3), `prompt_text` (текст части Speaking).

**Примеры:**

```sql
insert into public.writing_prompts (test_id, task_number, prompt_text)
values
  ('test-uuid', 1, 'Summarise the information. Write at least 150 words.'),
  ('test-uuid', 2, 'Some people believe that unpaid community service should be a compulsory part of high school programs. To what extent do you agree or disagree?');

insert into public.speaking_prompts (test_id, part_number, prompt_text)
values
  ('test-uuid', 1, 'Describe your hometown.'),
  ('test-uuid', 2, 'Describe a memorable journey.'),
  ('test-uuid', 3, 'Discuss the importance of public transport.');
```

---

## 6. Краткая шпаргалка по Reading

| Что нужно                         | Формат в БД |
|-----------------------------------|-------------|
| Текст пассажа с абзацами A, B, C | `body_text` с абзацами через `\n\n` |
| Секция Reading (1, 2 или 3)      | `section = 'reading'`, `section_part = '1'` / `'2'` / `'3'` |
| Номера вопросов 1–40             | `order_index` от 0 до 39 (уникальные в рамках теста для reading) |
| Варианты для дропдауна           | `options` = JSON-массив строк, например `["A","B","C","D","E","F"]` |
| List of Headings (i–ix)         | Вопросы с `question_type = 'matching'`, `options` = `["i","ii","iii",...]`, `question_text` = "Paragraph A" и т.д. |
| Yes/No/Not Given                 | `question_type = 'yes_no_not_given'`, `options` можно `null` |
| Поле «не более 3 слов»           | `question_type = 'short_answer'` или `'fill_blank'` |

Если что-то из этого изменится в коде (например, новые типы вопросов), обновлю этот файл.
