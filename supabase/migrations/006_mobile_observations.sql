create table if not exists public.observations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  image_path text not null,
  common_name text,
  scientific_name text,
  confidence double precision check (confidence >= 0 and confidence <= 1),
  description text,
  created_at timestamptz not null default now()
);

create index if not exists observations_user_created_idx
  on public.observations (user_id, created_at desc);

alter table public.observations enable row level security;

create policy "Users can view their observations"
  on public.observations for select to authenticated
  using (auth.uid() = user_id);

create policy "Users can create their observations"
  on public.observations for insert to authenticated
  with check (auth.uid() = user_id);

create policy "Users can delete their observations"
  on public.observations for delete to authenticated
  using (auth.uid() = user_id);

insert into storage.buckets (id, name, public)
values ('observations', 'observations', false)
on conflict (id) do nothing;

create policy "Users can upload their observation photos"
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'observations'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "Users can read their observation photos"
  on storage.objects for select to authenticated
  using (
    bucket_id = 'observations'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "Users can delete their observation photos"
  on storage.objects for delete to authenticated
  using (
    bucket_id = 'observations'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
