create extension if not exists "pgcrypto";

create table if not exists public.progress_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  created_at timestamptz not null,
  visual_score int not null,
  confidence text not null,
  posture_score int not null,
  summary text not null,
  symmetry_label text not null default 'جيد',
  comparability_label text not null default 'مقبولة',
  shoulder_waist_change numeric not null default 0,
  recommendation text not null default '',
  weight_kg numeric,
  phase_label text not null default '',
  note text not null default '',
  front_photo_path text,
  side_photo_path text,
  back_photo_path text,
  inserted_at timestamptz not null default now()
);

alter table public.progress_sessions
add column if not exists front_photo_path text;

alter table public.progress_sessions
add column if not exists side_photo_path text;

alter table public.progress_sessions
add column if not exists back_photo_path text;

alter table public.progress_sessions enable row level security;

drop policy if exists "Users can read their own progress sessions"
on public.progress_sessions;

create policy "Users can read their own progress sessions"
on public.progress_sessions
for select
to authenticated
using (auth.uid() = user_id);

drop policy if exists "Users can insert their own progress sessions"
on public.progress_sessions;

create policy "Users can insert their own progress sessions"
on public.progress_sessions
for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists "Users can delete their own progress sessions"
on public.progress_sessions;

create policy "Users can delete their own progress sessions"
on public.progress_sessions
for delete
to authenticated
using (auth.uid() = user_id);

create index if not exists progress_sessions_user_created_idx
on public.progress_sessions (user_id, created_at desc);

insert into storage.buckets (id, name, public)
values ('progress-photos', 'progress-photos', false)
on conflict (id) do nothing;

drop policy if exists "Users can upload their own progress photos"
on storage.objects;

create policy "Users can upload their own progress photos"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'progress-photos'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "Users can read their own progress photos"
on storage.objects;

create policy "Users can read their own progress photos"
on storage.objects
for select
to authenticated
using (
  bucket_id = 'progress-photos'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "Users can update their own progress photos"
on storage.objects;

create policy "Users can update their own progress photos"
on storage.objects
for update
to authenticated
using (
  bucket_id = 'progress-photos'
  and (storage.foldername(name))[1] = auth.uid()::text
)
with check (
  bucket_id = 'progress-photos'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "Users can delete their own progress photos"
on storage.objects;

create policy "Users can delete their own progress photos"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'progress-photos'
  and (storage.foldername(name))[1] = auth.uid()::text
);
