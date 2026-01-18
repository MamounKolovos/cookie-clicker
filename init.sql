create table users (
  id integer generated always as identity primary key,
  email text not null,
  password_hash text not null,
  name text not null,
  created_at timestamp not null default now(),
  updated_at timestamp not null default now()
)