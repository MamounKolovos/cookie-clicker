SELECT u.id, u.email, u.password_hash, u.username
FROM users u
WHERE u.username = $1;