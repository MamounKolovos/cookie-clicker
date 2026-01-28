CREATE EXTENSION IF NOT EXISTS citext;

CREATE TABLE users (
  id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  email citext NOT NULL UNIQUE,
  password_hash text NOT NULL,
  name text NOT NULL,
  created_at timestamp NOT NULL DEFAULT NOW(),
  updated_at timestamp NOT NULL DEFAULT NOW()
);

create or replace function update_updated_at()
  returns trigger as $$
begin
  new.updated_at = now() at time zone 'utc';
  return new;
end
$$ language plpgsql;

create trigger users_updated_at
  before update on users
  for each row
  execute procedure update_updated_at();