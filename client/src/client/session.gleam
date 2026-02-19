import client/data/user.{type User}
import client/route.{type Route}

pub type Session {
  /// initial state on page reload
  /// before update has had a chance to resolve to actual state
  /// TODO: maybe rename to guest? still on the fence
  Unknown
  Pending(on_success: Route, on_error: Route)
  LoggedOut
  LoggedIn(user: User)
}

pub fn unknown() -> Session {
  Unknown
}

pub fn logout() -> Session {
  LoggedOut
}

pub fn login(user: User) -> Session {
  LoggedIn(user:)
}
