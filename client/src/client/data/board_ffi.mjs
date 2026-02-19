import { BitArray$BitArray } from "../../gleam.mjs"

/**
 * @param {string} canvas_id
 * @returns {[HTMLCanvasElement, CanvasRenderingContext2D]}
 */
export function getCanvasAndContext(canvas_id) {
  /** @type {HTMLCanvasElement} */
  const canvas = document.getElementById(canvas_id)
  /** @type {CanvasRenderingContext2D} */
  const ctx = canvas.getContext("2d")
  return [canvas, ctx]
}

/**
 * 
 * @param {HTMLCanvasElement} canvas 
 * @param {number} width
 * @param {number} height
 */
export function setDimensions(canvas, width, height) {
  canvas.width = width;
  canvas.height = height;
}

/**
 * @param {CanvasRenderingContext2D} ctx
 * @param {BitArray$BitArray} color_indexes 
 * @param {number} width
 * @param {number} height
 */
export function drawBoard(ctx, color_indexes, width, height) {
  /** 
   * [hhhhllll, hhhhllll, ...]
   * @type {Uint8Array}
   */
  const colorIndexPairs = color_indexes.rawBuffer
  // filled with ABGR pixels but stored as RGBA internally due to little-endian memory layout
  // [RGBA, RGBA, ...]
  const rgbaPixels = new Uint32Array(colorIndexPairs.length * 2)

  for (let i = 0; i < colorIndexPairs.length; i++) {
    const indexPair = colorIndexPairs[i]

    const highIndex = indexPair >> 4;
    const lowIndex = indexPair & 0x0F;

    rgbaPixels[i * 2] = colorIndexToAbgr[highIndex]
    rgbaPixels[i * 2 + 1] = colorIndexToAbgr[lowIndex]
  }

  // [R, G, B, A, R, G, B, A, ...]
  const rgbaBytes = new Uint8ClampedArray(rgbaPixels.buffer)
  let imageData = new ImageData(rgbaBytes, width, height)
  ctx.putImageData(imageData, 0, 0)
}

const colorIndexToAbgr = [
  0xFFFFFFFF, // White
  0xFFE4E4E4, // Light Gray
  0xFF888888, // Gray
  0xFF222222, // Black
  0xFFD1A7FF, // Pink
  0xFF0000E5, // Red
  0xFF0095E5, // Orange
  0xFF426AA0, // Brown
  0xFF00D9E5, // Yellow
  0xFF44E094, // Light Green
  0xFF01BE02, // Green
  0xFFDDD300, // Cyan
  0xFFC78300, // Sky Blue
  0xFFEA0000, // Blue
  0xFFE46ECF, // Violet
  0xFF800082  // Purple
];
