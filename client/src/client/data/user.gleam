import client/network
import gleam/dynamic/decode
import lustre/effect.{type Effect}
import rsvp

pub type User {
  User(id: Int, username: String)
}

pub fn decoder() -> decode.Decoder(User) {
  use id <- decode.field("id", decode.int)
  use username <- decode.field("username", decode.string)
  decode.success(User(id:, username:))
}

pub fn get(to_msg: fn(Result(User, network.Error)) -> msg) -> Effect(msg) {
  let handler = network.expect_json(decoder(), to_msg)
  rsvp.get("/api/me", handler)
}
