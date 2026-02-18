import client/network
import gleam/bit_array
import gleam/dynamic/decode
import lustre/effect.{type Effect}
import rsvp

pub type Board {
  Board(canvas: Canvas, ctx: Context, snapshot: Snapshot)
}

pub fn draw_board(board: Board) -> Effect(msg) {
  use _ <- effect.from()

  let Snapshot(color_indexes:, width:, height:) = board.snapshot
  do_draw_board(board.ctx, color_indexes, width, height)
}

@external(javascript, "./canvas_ffi.mjs", "drawBoard")
fn do_draw_board(
  ctx: Context,
  color_indexes: BitArray,
  width: Int,
  height: Int,
) -> Nil

/// FFI reference to `HTMLCanvasElement`
pub type Canvas

/// FFI reference to `CanvasRenderingContext2D`
pub type Context

pub fn load_canvas_and_context(
  canvas_id: String,
  to_msg: fn(Canvas, Context) -> msg,
) -> Effect(msg) {
  use dispatch, _ <- effect.after_paint()

  let #(canvas, ctx) = do_load_canvas_and_context(canvas_id)
  to_msg(canvas, ctx) |> dispatch
}

@external(javascript, "./canvas_ffi.mjs", "getCanvasAndContext")
fn do_load_canvas_and_context(canvas_id: String) -> #(Canvas, Context)

pub type Snapshot {
  Snapshot(color_indexes: BitArray, width: Int, height: Int)
}

pub fn fetch_snapshot(
  to_msg: fn(Result(Snapshot, network.Error)) -> msg,
) -> Effect(msg) {
  let handler = network.expect_json(snapshot_decoder(), to_msg)
  rsvp.get("/api/board", handler)
}

fn snapshot_decoder() -> decode.Decoder(Snapshot) {
  use color_indexes <- decode.field("color_indexes", decode.string)

  case bit_array.base64_decode(color_indexes) {
    Ok(color_indexes) -> {
      use width <- decode.field("width", decode.int)
      use height <- decode.field("height", decode.int)
      decode.success(Snapshot(color_indexes:, width:, height:))
    }
    Error(Nil) ->
      decode.failure(Snapshot(<<>>, -1, -1), expected: "color_indexes")
  }
}
