import envoy
import gleam/erlang/process
import gleam/io
import pog
import sql

pub fn new_conn() -> pog.Connection {
  let assert Ok(url) = envoy.get("DATABASE_URL")
  let name = process.new_name("db")

  let assert Ok(pog_config) = pog.url_config(name, url)
  let assert Ok(_) = pog_config |> pog.pool_size(10) |> pog.start()

  pog.named_connection(name)
}

pub fn main() -> Nil {
  let conn = new_conn()

  let assert Ok(user) =
    sql.insert_user(conn, "Mamoun", "mamoun.kolovos@gmail.com", "passhash")

  echo user

  Nil
}
