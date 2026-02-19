import client/data/user.{type User}
import client/network
import client/route.{type Route}
import client/route/login
import client/route/play
import client/route/profile
import client/route/signup
import client/session.{type Session}
import lustre
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import modem
import rsvp
import shared/api_error.{ApiError}

pub fn main() -> Nil {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
  Nil
}

type Model {
  Model(session: Session, route: Route, page: Page)
}

type Page {
  Signup(signup.Model)
  Login(login.Model)
  Profile(profile.Model)
  Play(play.Model)
}

type Msg {
  UserNavigatedTo(route: Route)
  SignupMsg(signup.Msg)
  LoginMsg(login.Msg)
  ProfileMsg(profile.Msg)
  PlayMsg(play.Msg)
  SessionValidated(Result(User, network.Error))
}

fn init(_args) -> #(Model, Effect(Msg)) {
  let #(model, effect) = load_route(session.unknown(), route.initial_route())

  #(
    model,
    effect.batch([
      effect,
      modem.init(fn(uri) { uri |> route.parse |> UserNavigatedTo }),
    ]),
  )
}

fn load_route(session: Session, route: Route) -> #(Model, Effect(Msg)) {
  let is_protected = route.is_protected(route)

  // where are we allowed to go?
  let #(route, route_effect) = case session, route {
    session.Unknown, route -> #(route, user.get(SessionValidated))
    // cannot visit auth routes if you're already logged in
    session.LoggedIn(_), route.Signup | session.LoggedIn(_), route.Login -> #(
      route.Profile,
      effect.none(),
    )
    session.LoggedOut, _ if is_protected -> #(route.Login, effect.none())
    _, route -> #(route, effect.none())
  }

  // what must happen because we're going there?
  let #(page, page_effect) = case route {
    route.Signup -> {
      let #(page_model, page_effect) = signup.init()

      #(Signup(page_model), page_effect |> effect.map(SignupMsg))
    }
    route.Login -> {
      let #(page_model, page_effect) = login.init()

      #(Login(page_model), page_effect |> effect.map(LoginMsg))
    }
    route.Profile -> {
      let #(page_model, page_effect) = profile.init()

      #(Profile(page_model), page_effect |> effect.map(ProfileMsg))
    }
    route.Play -> {
      let #(page_model, page_effect) = play.init()

      #(Play(page_model), page_effect |> effect.map(PlayMsg))
    }
    route.NotFound(uri:) -> todo
  }

  #(Model(session:, route:, page:), effect.batch([route_effect, page_effect]))
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case model, msg {
    _, UserNavigatedTo(route) -> load_route(model.session, route)
    Model(session:, route: route.Signup, page: Signup(page_model)),
      SignupMsg(msg)
    -> {
      let #(session, page_model, effect) =
        signup.update(session, page_model, msg)

      #(
        Model(..model, session:, page: Signup(page_model)),
        effect |> effect.map(SignupMsg),
      )
    }
    Model(session:, route: route.Login, page: Login(page_model)), LoginMsg(msg) -> {
      let #(session, page_model, effect) =
        login.update(session, page_model, msg)

      #(
        Model(..model, session:, page: Login(page_model)),
        effect |> effect.map(LoginMsg),
      )
    }
    Model(session:, route: route.Profile, page: Profile(page_model)),
      ProfileMsg(msg)
    -> {
      let #(session, page_model, effect) =
        profile.update(session, page_model, msg)

      #(
        Model(..model, session:, page: Profile(page_model)),
        effect |> effect.map(ProfileMsg),
      )
    }
    Model(session:, route: route.Play, page: Play(page_model)), PlayMsg(msg) -> {
      let #(session, page_model, effect) = play.update(session, page_model, msg)

      #(
        Model(..model, session:, page: Play(page_model)),
        effect |> effect.map(PlayMsg),
      )
    }
    Model(session: session.Unknown, route:, page: _), SessionValidated(result) -> {
      let is_protected = route.is_protected(route)
      case result {
        Ok(user) -> #(
          Model(..model, session: session.login(user)),
          route.push(route.Profile),
        )
        Error(network.ApiFailure(ApiError(
          code: api_error.Unauthenticated,
          message: _,
        )))
          if is_protected
        -> #(Model(..model, session: session.logout()), route.push(route.Login))
        Error(_) -> #(Model(..model, session: session.logout()), effect.none())
      }
    }
    model, _ -> #(model, effect.none())
  }
}

fn view(model: Model) -> Element(Msg) {
  case model {
    Model(session: _, route: route.Signup, page: Signup(model)) ->
      signup.view(model) |> element.map(SignupMsg)
    Model(session: _, route: route.Login, page: Login(model)) ->
      login.view(model) |> element.map(LoginMsg)
    Model(session:, route: route.Profile, page: Profile(model)) ->
      profile.view(session, model) |> element.map(ProfileMsg)
    Model(session: _, route: route.Play, page: Play(model)) ->
      play.view(model) |> element.map(PlayMsg)
    _ -> html.text("not found")
  }
}
