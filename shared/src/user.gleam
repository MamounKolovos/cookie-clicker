import gleam/time/timestamp.{type Timestamp}

pub type User {
  User(
    id: Int,
    email: String,
    name: String,
    password_hash: String,
    created_at: Timestamp,
    updated_at: Timestamp,
  )
}
