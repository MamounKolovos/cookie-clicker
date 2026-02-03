SELECT u.id, u.email, u.username, u.created_at, u.updated_at
FROM sessions session
JOIN users u ON session.user_id = u.id
WHERE session.token_hash = $1
  AND session.expires_at > $2;