import formal/form.{type Form}
import gleam/dynamic/decode
import gleam/float
import gleam/http
import gleam/http/request
import gleam/json.{type Json}
import gleam/list
import gleam/time/timestamp.{type Timestamp}
import gleam/uri
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import rsvp
import signup.{type Signup, Signup}
import user.{type User, User}

pub fn main() -> Nil {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
  Nil
}

type Model {
  SignupPage(form: Form(Signup))
  MainPage(data: Signup)
}

fn init(_args) -> #(Model, Effect(Msg)) {
  echo "got to init"
  #(SignupPage(signup_form()), effect.none())
}

fn signup_form() -> Form(Signup) {
  form.new({
    use email <- form.field("email", form.parse_email)
    use name <- form.field("name", form.parse_string |> form.check_not_empty)
    use password <- form.field(
      "password",
      form.parse_string
        |> form.check_not_empty
        |> form.check_string_length_more_than(8),
    )

    use _ <- form.field(
      "confirm_password",
      form.parse_string |> form.check_confirms(password),
    )

    form.success(Signup(email:, name:, password:))
  })
}

type Msg {
  UserClickedSignupButton(Result(Signup, Form(Signup)))
  ApiReturnedUser(Result(User, rsvp.Error))
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    UserClickedSignupButton(result) ->
      case result {
        Ok(signup) -> #(MainPage(signup), post_signup(signup))
        Error(form) -> #(SignupPage(form), effect.none())
      }
    ApiReturnedUser(result) ->
      case result {
        Ok(user) -> todo
        Error(error) -> todo
      }
  }
}

fn post_signup(signup: Signup) -> Effect(Msg) {
  let assert Ok(uri) = rsvp.parse_relative_uri("/api/signup")
  let assert Ok(request) = request.from_uri(uri)

  let body =
    uri.query_to_string([
      #("email", signup.email),
      #("name", signup.name),
      #("password", signup.password),
    ])
  let handler = rsvp.expect_json(user_decoder(), ApiReturnedUser)

  request
  |> request.set_method(http.Post)
  |> request.set_header("content-type", "application/x-www-form-urlencoded")
  |> request.set_body(body)
  |> rsvp.send(handler)
}

pub fn user_decoder() -> decode.Decoder(User) {
  use id <- decode.field("id", decode.int)
  use email <- decode.field("email", decode.string)
  use name <- decode.field("name", decode.string)
  use password_hash <- decode.field("password_hash", decode.string)
  use created_at <- decode.field("created_at", timestamp_decoder())
  use updated_at <- decode.field("updated_at", timestamp_decoder())
  decode.success(User(
    id:,
    email:,
    name:,
    password_hash:,
    created_at:,
    updated_at:,
  ))
}

fn timestamp_decoder() -> decode.Decoder(Timestamp) {
  use value <- decode.then(decode.float)
  value |> float.round |> timestamp.from_unix_seconds |> decode.success
}

fn view(model: Model) -> Element(Msg) {
  case model {
    SignupPage(form) -> signup_page_view(form)
    MainPage(_) -> todo
  }
}

fn signup_page_view(form: Form(Signup)) -> Element(Msg) {
  html.form(
    [
      // prevents default submission and collects field values
      event.on_submit(fn(fields) {
        form |> form.add_values(fields) |> form.run |> UserClickedSignupButton
      }),
    ],
    [
      form_input_field(form, name: "email", type_: "email", label: "Email"),
      form_input_field(form, name: "name", type_: "text", label: "Name"),
      form_input_field(
        form,
        name: "password",
        type_: "password",
        label: "Password",
      ),
      form_input_field(
        form,
        name: "confirm_password",
        type_: "password",
        label: "Confirmation",
      ),
      html.div([], [
        html.input([
          attribute.type_("submit"),
          attribute.value("Sign up"),
          attribute.styles([
            #("margin-top", "1rem"),
            #("padding", "0.6rem 1rem"),
            #("background-color", "#2563eb"),
            #("color", "white"),
            #("font-weight", "600"),
            #("border", "none"),
            #("border-radius", "6px"),
            #("cursor", "pointer"),
            #("width", "100%"),
          ]),
        ]),
      ]),
    ],
  )
}

fn form_input_field(
  form: Form(f),
  name name: String,
  type_ type_: String,
  label label_text: String,
) -> Element(Msg) {
  let errors = form.field_error_messages(form, name)
  let styles =
    attribute.styles([#("display", "block"), #("margin-bottom", "0.75rem")])

  html.label([styles], [
    element.text(label_text),
    html.input([
      attribute.type_(type_),
      attribute.name(name),
      attribute.value(form.field_value(form, name)),
      attribute.styles([
        #("display", "block"),
        #("width", "100%"),
        #("padding", "0.5rem"),
        #("margin-top", "0.25rem"),
        #("border", "1px solid #ccc"),
        #("border-radius", "4px"),
      ]),
      ..{
        case errors {
          [] -> [attribute.none()]
          _ -> [
            attribute.aria_invalid("true"),
            attribute.style("border", "1px solid #dc2626"),
          ]
        }
      }
    ]),

    list.map(errors, fn(error) { html.small([], [element.text(error)]) })
      |> element.fragment,
  ])
}
