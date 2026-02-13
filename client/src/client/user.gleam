import gleam/dynamic/decode

pub type User {
  User(id: Int, username: String)
}

pub fn decoder() -> decode.Decoder(User) {
  use id <- decode.field("id", decode.int)
  use username <- decode.field("username", decode.string)
  decode.success(User(id:, username:))
}
