import envoy
import gleam/erlang/process
import gleam/io
import gleam/otp/actor
import gleam/otp/static_supervisor.{type Supervisor}
import mist
import pog
import server/router
import server/sql
import server/web.{type Context, Context}
import wisp
import wisp/wisp_mist

pub fn main() -> Nil {
  wisp.configure_logger()

  let assert Ok(_) = start()

  process.sleep_forever()
}

pub fn start() -> Result(actor.Started(Supervisor), actor.StartError) {
  let pog_config = pog_config()
  let ctx = Context(db: pog.named_connection(pog_config.pool_name))

  let db_spec = pog_config |> pog.supervised
  let server_spec = mist_config(ctx) |> mist.supervised

  static_supervisor.new(static_supervisor.OneForOne)
  |> static_supervisor.add(db_spec)
  |> static_supervisor.add(server_spec)
  |> static_supervisor.start()
}

pub fn pog_config() -> pog.Config {
  let assert Ok(database_url) = envoy.get("DATABASE_URL")
  let pool_name = process.new_name("db")

  let assert Ok(pog_config) = pog.url_config(pool_name, database_url)
  pog_config |> pog.pool_size(10)
}

pub fn mist_config(
  ctx: Context,
) -> mist.Builder(mist.Connection, mist.ResponseData) {
  let assert Ok(secret_key_base) = envoy.get("SECRET_KEY_BASE")

  router.handle_request(_, ctx)
  |> wisp_mist.handler(secret_key_base)
  |> mist.new()
  |> mist.port(8000)
}
