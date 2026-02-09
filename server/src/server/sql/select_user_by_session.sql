SELECT u.id, u.email, u.username
FROM sessions session
JOIN users u ON session.user_id = u.id
WHERE session.token_hash = $1
  AND session.expires_at > $2;