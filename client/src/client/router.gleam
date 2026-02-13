import gleam/option.{None}
import gleam/uri.{type Uri}
import lustre/attribute.{type Attribute}
import lustre/effect.{type Effect}
import modem

pub type Route {
  Signup
  Login
  Profile
  NotFound(uri: Uri)
}

pub fn initial_route() -> Route {
  case modem.initial_uri() {
    Ok(uri) -> parse(uri)
    Error(Nil) -> Signup
  }
}

pub fn parse(uri: Uri) -> Route {
  case uri.path_segments(uri.path) {
    ["signup"] -> Signup
    ["login"] -> Login
    ["profile"] -> Profile
    _ -> NotFound(uri:)
  }
}

pub fn href(route: Route) -> Attribute(msg) {
  route |> to_path |> attribute.href
}

pub fn push(route: Route) -> Effect(msg) {
  route |> to_path |> modem.push(None, None)
}

fn to_path(route: Route) -> String {
  case route {
    Signup -> "/signup"
    Login -> "/login"
    Profile -> "/profile"
    NotFound(_) -> "/not-found"
  }
}
