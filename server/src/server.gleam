import envoy
import gleam/erlang/process
import gleam/io
import mist
import pog
import router
import sql
import web.{Context}
import wisp
import wisp/wisp_mist

pub fn new_conn() -> pog.Connection {
  let assert Ok(url) = envoy.get("DATABASE_URL")
  let name = process.new_name("db")

  let assert Ok(pog_config) = pog.url_config(name, url)
  let assert Ok(_) = pog_config |> pog.pool_size(10) |> pog.start()

  pog.named_connection(name)
}

pub fn main() -> Nil {
  wisp.configure_logger()

  let assert Ok(secret_key_base) = envoy.get("SECRET_KEY_BASE")

  let ctx = Context(new_conn())

  let assert Ok(_) =
    router.handle_request(_, ctx)
    |> wisp_mist.handler(secret_key_base)
    |> mist.new()
    |> mist.port(8000)
    |> mist.start()

  process.sleep_forever()
}
