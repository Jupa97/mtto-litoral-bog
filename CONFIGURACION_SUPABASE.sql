-- MTTO LITORAL BOG: configuración inicial segura
-- Ejecuta TODO este archivo en Supabase > SQL Editor > New query > Run.

create extension if not exists pgcrypto;

create table if not exists public.actas (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  created_by uuid not null references auth.users(id) on delete restrict,
  created_at timestamptz not null default now(),
  date text not null,
  area text not null,
  equipment text not null,
  type text not null,
  technician text not null,
  work text not null,
  materials text,
  status text not null,
  observations text,
  before_path text not null,
  after_path text not null,
  signature text not null
);

alter table public.actas enable row level security;

drop policy if exists "Usuarios autenticados pueden ver actas" on public.actas;
create policy "Usuarios autenticados pueden ver actas"
on public.actas for select to authenticated using (true);

drop policy if exists "Usuarios autenticados pueden crear actas" on public.actas;
create policy "Usuarios autenticados pueden crear actas"
on public.actas for insert to authenticated with check (auth.uid() = created_by);

drop policy if exists "Usuarios autenticados pueden actualizar actas" on public.actas;
create policy "Usuarios autenticados pueden actualizar actas"
on public.actas for update to authenticated using (true) with check (true);

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('actas-fotos', 'actas-fotos', false, 10485760, array['image/jpeg','image/png','image/webp'])
on conflict (id) do update set public = false, file_size_limit = 10485760,
allowed_mime_types = array['image/jpeg','image/png','image/webp'];

drop policy if exists "Usuarios autenticados ven fotos de actas" on storage.objects;
create policy "Usuarios autenticados ven fotos de actas"
on storage.objects for select to authenticated using (bucket_id = 'actas-fotos');

drop policy if exists "Usuarios autenticados suben fotos de actas" on storage.objects;
create policy "Usuarios autenticados suben fotos de actas"
on storage.objects for insert to authenticated with check (bucket_id = 'actas-fotos');

drop policy if exists "Usuarios autenticados actualizan fotos de actas" on storage.objects;
create policy "Usuarios autenticados actualizan fotos de actas"
on storage.objects for update to authenticated using (bucket_id = 'actas-fotos') with check (bucket_id = 'actas-fotos');
