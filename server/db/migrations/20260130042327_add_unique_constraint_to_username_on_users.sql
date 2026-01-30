-- migrate:up

ALTER TABLE users ADD CONSTRAINT users_username_key UNIQUE (username)

-- migrate:down

ALTER TABLE users DROP CONSTRAINT IF EXISTS users_username_key