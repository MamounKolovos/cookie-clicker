-- migrate:up

CREATE TABLE sessions (
  id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  token_hash bytea NOT NULL UNIQUE,
  user_id integer NOT NULL REFERENCES users(id),
  created_at timestamp NOT NULL DEFAULT now(),
  expires_at timestamp NOT NULL
);

CREATE INDEX sessions_user_id_idx ON sessions(user_id);

-- migrate:down

DROP TABLE IF EXISTS sessions;