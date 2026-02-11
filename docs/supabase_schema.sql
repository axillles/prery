-- =============================================================================
-- prepy — Supabase schema
-- Запускать в SQL Editor в дашборде Supabase (по блокам или целиком).
-- =============================================================================

-- Включить расширение UUID (обычно уже есть)
-- create extension if not exists "uuid-ossp";

-- =============================================================================
-- 1. PROFILES (расширение auth.users)
-- =============================================================================

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  avatar_url text,
  target_band numeric(2,1) check (target_band >= 0 and target_band <= 9),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Триггер: создавать профиль при регистрации
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, display_name)
  values (new.id, coalesce(new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'name', 'User'));
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Обновление updated_at
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger profiles_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

-- =============================================================================
-- 2. ТЕСТЫ И КОНТЕНТ
-- =============================================================================

create table if not exists public.tests (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  topic_slug text not null,
  created_at timestamptz default now()
);

create table if not exists public.listening_audio (
  id uuid primary key default gen_random_uuid(),
  test_id uuid not null references public.tests(id) on delete cascade,
  part smallint not null check (part >= 1 and part <= 4),
  storage_path text not null,
  duration_seconds int not null,
  created_at timestamptz default now(),
  unique(test_id, part)
);

create table if not exists public.reading_passages (
  id uuid primary key default gen_random_uuid(),
  test_id uuid not null references public.tests(id) on delete cascade,
  passage_number smallint not null,
  title text,
  body_text text not null,
  image_storage_path text,
  created_at timestamptz default now(),
  unique(test_id, passage_number)
);

create table if not exists public.writing_prompts (
  id uuid primary key default gen_random_uuid(),
  test_id uuid not null references public.tests(id) on delete cascade,
  task_number smallint not null,
  prompt_text text not null,
  created_at timestamptz default now(),
  unique(test_id, task_number)
);

create table if not exists public.speaking_prompts (
  id uuid primary key default gen_random_uuid(),
  test_id uuid not null references public.tests(id) on delete cascade,
  part_number smallint not null,
  prompt_text text not null,
  created_at timestamptz default now(),
  unique(test_id, part_number)
);

-- Типы вопросов: multiple_choice, fill_blank, matching, yes_no_not_given, etc.
create type public.question_section as enum ('listening', 'reading', 'writing', 'speaking');
create type public.question_type as enum (
  'multiple_choice', 'fill_blank', 'matching', 'yes_no_not_given',
  'true_false_not_given', 'sentence_completion', 'short_answer', 'other'
);

create table if not exists public.questions (
  id uuid primary key default gen_random_uuid(),
  test_id uuid not null references public.tests(id) on delete cascade,
  section public.question_section not null,
  section_part text not null,
  question_type public.question_type not null,
  question_text text not null,
  options jsonb,
  order_index int not null default 0,
  created_at timestamptz default now()
);

create index if not exists idx_questions_test_section on public.questions(test_id, section, section_part);

-- =============================================================================
-- 3. ПОПЫТКИ И РЕЗУЛЬТАТЫ (без сырых ответов)
-- =============================================================================

create type public.attempt_status as enum ('in_progress', 'completed', 'abandoned');

create table if not exists public.attempts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  test_id uuid not null references public.tests(id) on delete cascade,
  started_at timestamptz default now(),
  completed_at timestamptz,
  status public.attempt_status not null default 'in_progress',
  created_at timestamptz default now()
);

create index if not exists idx_attempts_user on public.attempts(user_id);
create index if not exists idx_attempts_completed on public.attempts(user_id, completed_at) where completed_at is not null;

create table if not exists public.attempt_scores (
  id uuid primary key default gen_random_uuid(),
  attempt_id uuid not null references public.attempts(id) on delete cascade,
  section public.question_section not null,
  score numeric(2,1) not null check (score >= 0 and score <= 9),
  created_at timestamptz default now(),
  unique(attempt_id, section)
);

create table if not exists public.attempt_insights (
  id uuid primary key default gen_random_uuid(),
  attempt_id uuid not null references public.attempts(id) on delete cascade,
  section public.question_section not null,
  insights_json jsonb not null default '{}',
  vocabulary_gaps text[],
  created_at timestamptz default now(),
  unique(attempt_id, section)
);

-- =============================================================================
-- 4. СТАТИСТИКА И ГЕЙМИФИКАЦИЯ
-- =============================================================================

create table if not exists public.user_stats (
  user_id uuid primary key references auth.users(id) on delete cascade,
  daily_streak int not null default 0,
  words_learned_count int not null default 0,
  last_activity_date date,
  current_level numeric(2,1) check (current_level is null or (current_level >= 0 and current_level <= 9)),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create trigger user_stats_updated_at
  before update on public.user_stats
  for each row execute function public.set_updated_at();

-- Создавать запись при первом появлении (можно через trigger на profiles или при первой попытке)
create or replace function public.ensure_user_stats()
returns trigger as $$
begin
  insert into public.user_stats (user_id)
  values (new.user_id)
  on conflict (user_id) do nothing;
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists ensure_user_stats_on_attempt on public.attempts;
create trigger ensure_user_stats_on_attempt
  after insert on public.attempts
  for each row execute function public.ensure_user_stats();

-- =============================================================================
-- 5. СЛОВАРЬ И ФЛЕШ-КАРТОЧКИ (будущее)
-- =============================================================================

create table if not exists public.vocabulary (
  id uuid primary key default gen_random_uuid(),
  word text not null,
  definition text,
  example text,
  topic text,
  created_at timestamptz default now()
);

create table if not exists public.user_flashcards (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  vocabulary_id uuid references public.vocabulary(id) on delete set null,
  source_word text,
  source_attempt_id uuid references public.attempts(id) on delete set null,
  mastered boolean not null default false,
  next_review date,
  created_at timestamptz default now(),
  check (vocabulary_id is not null or source_word is not null)
);

create index if not exists idx_user_flashcards_user on public.user_flashcards(user_id);

-- =============================================================================
-- 6. РЕСУРСЫ (заглушка на будущее)
-- =============================================================================

create table if not exists public.resources (
  id uuid primary key default gen_random_uuid(),
  type text not null,
  title text not null,
  url_or_content text,
  metadata jsonb default '{}',
  created_at timestamptz default now()
);

-- =============================================================================
-- 7. ROW LEVEL SECURITY (RLS)
-- =============================================================================

alter table public.profiles enable row level security;
alter table public.attempts enable row level security;
alter table public.attempt_scores enable row level security;
alter table public.attempt_insights enable row level security;
alter table public.user_stats enable row level security;
alter table public.user_flashcards enable row level security;

-- Контент (тесты, вопросы, аудио) — чтение для всех аутентифицированных
alter table public.tests enable row level security;
alter table public.listening_audio enable row level security;
alter table public.reading_passages enable row level security;
alter table public.writing_prompts enable row level security;
alter table public.speaking_prompts enable row level security;
alter table public.questions enable row level security;
alter table public.vocabulary enable row level security;
alter table public.resources enable row level security;

-- Профиль: чтение/запись только своего
create policy "profiles_select_own" on public.profiles for select using (auth.uid() = id);
create policy "profiles_update_own" on public.profiles for update using (auth.uid() = id);

-- Контент: только чтение для авторизованных
create policy "tests_select" on public.tests for select to authenticated using (true);
create policy "listening_audio_select" on public.listening_audio for select to authenticated using (true);
create policy "reading_passages_select" on public.reading_passages for select to authenticated using (true);
create policy "writing_prompts_select" on public.writing_prompts for select to authenticated using (true);
create policy "speaking_prompts_select" on public.speaking_prompts for select to authenticated using (true);
create policy "questions_select" on public.questions for select to authenticated using (true);
create policy "vocabulary_select" on public.vocabulary for select to authenticated using (true);
create policy "resources_select" on public.resources for select to authenticated using (true);

-- Попытки и результаты: только свои
create policy "attempts_all_own" on public.attempts for all using (auth.uid() = user_id);
create policy "attempt_scores_select_own" on public.attempt_scores for select using (
  exists (select 1 from public.attempts a where a.id = attempt_id and a.user_id = auth.uid())
);
create policy "attempt_scores_insert_own" on public.attempt_scores for insert with check (
  exists (select 1 from public.attempts a where a.id = attempt_id and a.user_id = auth.uid())
);
create policy "attempt_insights_select_own" on public.attempt_insights for select using (
  exists (select 1 from public.attempts a where a.id = attempt_id and a.user_id = auth.uid())
);
create policy "attempt_insights_insert_own" on public.attempt_insights for insert with check (
  exists (select 1 from public.attempts a where a.id = attempt_id and a.user_id = auth.uid())
);

-- user_stats: только свой
create policy "user_stats_select_own" on public.user_stats for select using (auth.uid() = user_id);
create policy "user_stats_update_own" on public.user_stats for update using (auth.uid() = user_id);
create policy "user_stats_insert_own" on public.user_stats for insert with check (auth.uid() = user_id);

-- Флеш-карточки: только свои
create policy "user_flashcards_all_own" on public.user_flashcards for all using (auth.uid() = user_id);

-- =============================================================================
-- 8. STORAGE (бакеты создаются в Dashboard или через API)
-- Политики для storage.objects — подставьте имя bucket.
-- =============================================================================

-- В Dashboard: Storage → New bucket:
--   - listening_audio (public или private — если private, ниже policy на select)
--   - reading_images
--   - speaking_recordings (опционально)

-- Пример: разрешить аутентифицированным читать файлы из listening_audio
-- insert into storage.buckets (id, name, public) values ('listening_audio', 'listening_audio', true);
-- Для private bucket:
/*
create policy "listening_audio_read"
on storage.objects for select
to authenticated
using (bucket_id = 'listening_audio');
*/

-- Загрузка файлов контента обычно делается из бэкенда/админки с service_role, не из приложения.
-- Если загрузка из приложения не нужна, отдельные policy на insert/update не требуются.
