-- 탭체크 제보 저장소 설정
-- Supabase > SQL Editor > New query 에 이 파일 내용을 전부 붙여넣고 Run 을 누르세요.
-- 한 번만 실행하면 돼요.

-- 1) 다녀온 사람들의 팁 (모두에게 공개)
create table if not exists public.tips (
  id bigint generated always as identity primary key,
  city text not null check (char_length(city) between 1 and 40),
  role text not null check (role in ('여행자','현지 거주','유학·교환학생')),
  text text not null check (char_length(text) between 1 and 400),
  hidden boolean not null default false,
  created_at timestamptz not null default now()
);

-- 2) 정보가 바뀌었어요 제보 (운영자만 열람)
create table if not exists public.reports (
  id bigint generated always as identity primary key,
  city text not null check (char_length(city) between 1 and 40),
  field text not null check (char_length(field) between 1 and 40),
  text text not null check (char_length(text) between 1 and 400),
  created_at timestamptz not null default now()
);

-- 3) 도시 추가 요청 (운영자만 열람)
create table if not exists public.requests (
  id bigint generated always as identity primary key,
  city text not null check (char_length(city) between 1 and 60),
  note text not null default '' check (char_length(note) <= 300),
  created_at timestamptz not null default now()
);

-- 보안 규칙: 방문자는 "쓰기"만, 팁은 숨기지 않은 것만 "읽기" 가능
alter table public.tips enable row level security;
alter table public.reports enable row level security;
alter table public.requests enable row level security;

drop policy if exists "tips_read_visible" on public.tips;
create policy "tips_read_visible" on public.tips
  for select to anon using (hidden = false);

drop policy if exists "tips_insert" on public.tips;
create policy "tips_insert" on public.tips
  for insert to anon with check (hidden = false);

drop policy if exists "reports_insert" on public.reports;
create policy "reports_insert" on public.reports
  for insert to anon with check (true);

drop policy if exists "requests_insert" on public.requests;
create policy "requests_insert" on public.requests
  for insert to anon with check (true);

-- 방문자(anon)에게 필요한 권한만 열어요.
grant select, insert on public.tips to anon;
grant insert on public.reports to anon;
grant insert on public.requests to anon;
grant usage on all sequences in schema public to anon;

-- 방문자는 hidden 칸을 직접 바꿀 수 없어요. 부적절한 팁은 운영자가
-- Supabase > Table Editor > tips 에서 hidden 을 true 로 바꾸면 사이트에서 사라져요.
