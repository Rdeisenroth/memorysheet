#import "config.typ": validate

/// The width of landscape A4 paper.
#let a4-width = 297mm
/// The height of landscape A4 paper.
#let a4-height = 210mm

/// Returns the number of whole grid cells that fit an extent.
///
/// Arguments:
/// - `extent` (length): The available horizontal or vertical space.
/// - `cell-size` (length): The side length of one grid cell.
/// - `setting-name` (string): Human-readable setting names used in assertion messages.
#let whole-cells(extent, cell-size, setting-name) = {
  let cell-count = calc.floor(extent / cell-size)
  assert(extent - cell-count * cell-size == 0pt, message: setting-name + " must produce whole grid cells")
  cell-count
}

/// Creates equal-size track definitions for a Typst grid.
///
/// Arguments:
/// - `cell-count` (integer): Number of tracks to create.
/// - `cell-size` (length): Width or height of each track.
#let grid-tracks(cell-count, cell-size) = range(cell-count).map(_ => cell-size)

/// Returns the first grid column for an item centered within a grid.
///
/// For odd differences, the one remaining cell is intentionally placed on the right.
///
/// Arguments:
/// - `grid-columns` (integer): Total number of grid columns.
/// - `item-columns` (integer): Width of the item in grid columns.
#let centered-grid-column(grid-columns, item-columns) = calc.floor((grid-columns - item-columns) / 2)

/// Rounds a content width plus horizontal padding up to an exact number of grid cells.
///
/// Arguments:
/// - `content-width` (length): Width returned by `measure` for the title content.
/// - `padding` (length): Space reserved on each side of the content.
/// - `cell-size` (length): Width of one grid cell.
#let fitted-grid-columns(content-width, padding, cell-size) = calc.ceil((content-width + 2 * padding) / cell-size)

/// Loads the SVG watermark and applies the configured opacity to its opaque fills and strokes.
///
/// Arguments:
/// - `path` (path or string): SVG watermark asset path, relative to this module.
/// - `opacity` (ratio): Opacity applied to the watermark's opaque SVG fills and strokes.
/// - `width` (relative length): Rendered width of the watermark.
#let watermark(path, opacity, width) = image(
  bytes(
    read(path)
      .replace("fill-opacity=\"1\"", "fill-opacity=\"" + str(opacity / 100%) + "\"")
      .replace("stroke-opacity=\"1\"", "stroke-opacity=\"" + str(opacity / 100%) + "\""),
  ),
  format: "svg",
  width: width,
)

/// Renders one page of the memory sheet from a validated configuration.
///
/// This internal helper contains the layered page artwork; `memorysheet` manages document-wide
/// settings and repetition.
///
/// Arguments:
/// - `config` (dictionary): Validated visual and layout settings.
#let render-sheet(config) = {
  let config = validate(config)
  context {
    let inner-width = a4-width - 2 * config.horizontal-margin
    let inner-height = a4-height - 2 * config.margin
    let full-grid-columns = whole-cells(inner-width, config.grid-size, "horizontal-margin and grid-size")
    let full-grid-rows = whole-cells(inner-height, config.grid-size, "margin and grid-size")
    let grid-column-sizes = grid-tracks(full-grid-columns, config.grid-size)
    let grid-row-sizes = grid-tracks(full-grid-rows, config.grid-size)
    let grid-columns = grid-column-sizes.len()
    let grid-rows = grid-row-sizes.len()
    let spacer-count = calc.ceil(inner-width / config.column-width) + 1
    let title-content-size = measure(config.title)
    let title-grid-columns = fitted-grid-columns(title-content-size.width, config.title-padding, config.grid-size)
    assert(title-grid-columns <= grid-columns, message: "title box is wider than the grid")
    assert(config.title-grid-rows <= grid-rows, message: "title box is taller than the grid")
    let title-width = title-grid-columns * config.grid-size
    let title-height = config.title-grid-rows * config.grid-size
    let title-column = centered-grid-column(grid-columns, title-grid-columns)
    let page-number-grid-columns = calc.ceil(config.page-number-width / config.grid-size)
    let page-number-column = centered-grid-column(grid-columns, page-number-grid-columns)

    box(width: a4-width, height: a4-height, clip: true)[
      #place(top + left, dx: config.horizontal-margin, dy: config.margin)[
        #box(
          width: inner-width,
          height: inner-height,
        )[
          #grid(
            columns: grid-column-sizes,
            rows: grid-row-sizes,
            column-gutter: 0pt,
            row-gutter: 0pt,
            stroke: (paint: config.grid-color, thickness: config.grid-thickness),
            ..range(grid-columns * grid-rows).map(_ => []),
          )
        ]
      ]

      #if config.show-watermark [
        #place(center + horizon)[
          #watermark(config.watermark-path, config.watermark-opacity, config.watermark-width)
        ]
      ]

      #place(top + left, dx: config.horizontal-margin, dy: config.margin + config.header-height)[
        #line(
          length: inner-width,
          stroke: (paint: config.horizontal-spacer-color, thickness: config.spacer-thickness),
        )
      ]
      #for index in range(spacer-count) [
        #place(
          top + left,
          dx: config.horizontal-margin + index * config.column-width,
          dy: config.margin + config.header-height,
        )[
          #line(
            angle: 90deg,
            length: inner-height - config.header-height,
            stroke: (paint: config.vertical-spacer-color, thickness: config.spacer-thickness),
          )
        ]
      ]

      // Paint the outer border after the grid, so no thin grid stroke can cover it.
      #place(top + left, dx: config.horizontal-margin, dy: config.margin)[
        #rect(
          width: inner-width,
          height: inner-height,
          fill: none,
          stroke: (paint: config.border-color, thickness: config.border-thickness),
        )
      ]

      #place(top + left, dx: config.horizontal-margin + title-column * config.grid-size, dy: config.margin)[
        #box(
          width: title-width,
          height: title-height,
          inset: 0pt,
          fill: config.page-fill,
          stroke: (paint: config.border-color, thickness: config.border-thickness),
        )[
          #place(
            top + left,
            dx: (title-width - title-content-size.width) / 2,
            dy: (title-height - title-content-size.height) / 2 + config.title-vertical-offset,
          )[#config.title]
        ]
      ]

      #if config.show-credits [
        #place(top + center, dy: config.margin + config.header-height - 2 * 7pt + 1.25mm)[
          #text(size: 7pt)[#config.credit]
        ]
      ]

      #if config.show-page-numbers [
        #place(bottom + left, dx: config.horizontal-margin + page-number-column * config.grid-size, dy: -config.margin)[
          #box(
            width: config.page-number-width,
            height: config.page-number-height,
            inset: 0pt,
            fill: config.page-fill,
            stroke: (paint: config.border-color, thickness: config.border-thickness),
          )[ #align(center + horizon)[#text(size: 8pt)[Seite #context counter(page).display()]] ]
        ]
      ]
    ]
  }
}

/// Generates a configurable, printable landscape A4 memory sheet.
///
/// Apply it document-wide with `#show: memorysheet.with(...)`. All named settings appear in
/// Typst editor completion and hover documentation.
///
/// Arguments:
/// - `margin` (length, default: `5mm`): Top and bottom page margin; determines the grid's vertical origin.
/// - `horizontal-margin` (length, default: `6mm`): Left and right page margin; must leave a whole number of grid cells.
/// - `column-width` (length, default: `4cm`): Distance between thick vertical writing-column separators.
/// - `grid-size` (length, default: `2.5mm`): Width and height of one faint graph-paper cell.
/// - `grid-thickness` (length, default: `0.25pt`): Stroke thickness of the faint graph-paper lines.
/// - `header-height` (length, default: `1.5cm`): Height of the title and credit band above the horizontal separator.
/// - `title` (content): Content centered in the top title box; use `*text*` for bold text.
/// - `title-grid-rows` (integer, default: `2`): Fixed title-box height in grid rows.
/// - `title-padding` (length, default: `2.5mm`): Nominal free space on each title side before width is rounded to cells.
/// - `title-vertical-offset` (length, default: `-0.7mm`): Optical adjustment for title glyphs and the baseline-aligned underline box; negative values move them upward.
/// - `page-count` (integer, default: `2`): Number of sheet pages to generate; two pages form one double-sided sheet.
/// - `show-page-numbers` (boolean, default: `true`): Whether to draw the bottom page-number box.
/// - `page-number-width` (length, default: `1.25cm`): Page-number box width; default is five grid cells.
/// - `page-number-height` (length, default: `0.5cm`): Page-number box height; default is two grid cells.
/// - `show-watermark` (boolean, default: `true`): Whether to show the centered, faint watermark.
/// - `show-credits` (boolean, default: `true`): Whether to show the small project credit in the header band.
/// - `page-fill` (color, default: `white`): Background color used for the page and opaque label boxes.
/// - `grid-color` (color, default: `luma(75%)`): Color of the faint graph-paper grid.
/// - `border-color` (color, default: `black`): Color of the outer border and title/page-number boxes.
/// - `horizontal-spacer-color` (color, default: `black`): Color of the thick header separator.
/// - `vertical-spacer-color` (color, default: `black`): Color of the thick writing-column separators.
/// - `border-thickness` (length, default: `2pt`): Stroke thickness of the outer border and small boxes.
/// - `spacer-thickness` (length, default: `2pt`): Stroke thickness of header and writing-column separators.
/// - `watermark-path` (path or string, default: `"../img/tuda_logo.svg"`): SVG watermark asset path.
/// - `watermark-width` (relative length, default: `50%`): Width of the centered watermark relative to the page.
/// - `watermark-opacity` (ratio, default: `10%`): Opacity applied to the watermark.
/// - `credit` (content): Small centered content above the header separator.
/// - `body` (content): Document body supplied automatically by the `show` rule; normally left empty.
#let memorysheet(
  margin: 5mm,
  horizontal-margin: 6mm,
  column-width: 4cm,
  grid-size: 2.5mm,
  grid-thickness: 0.25pt,
  header-height: 1.5cm,
  title: [*NETSEC* Merkzettel von: #box(width: 3cm, height: 1em, stroke: (bottom: 0.75pt))[]],
  title-grid-rows: 2,
  title-padding: 2.5mm,
  title-vertical-offset: -0.7mm,
  page-count: 2,
  show-page-numbers: true,
  page-number-width: 1.25cm,
  page-number-height: 0.5cm,
  show-watermark: true,
  show-credits: true,
  page-fill: white,
  grid-color: luma(75%),
  border-color: black,
  horizontal-spacer-color: black,
  vertical-spacer-color: black,
  border-thickness: 2pt,
  spacer-thickness: 2pt,
  watermark-path: "../img/tuda_logo.svg",
  watermark-width: 50%,
  watermark-opacity: 10%,
  credit: [Created with: #link("https://github.com/Rdeisenroth/memorysheet")],
  body,
) = {
  let config = (
    margin: margin,
    horizontal-margin: horizontal-margin,
    column-width: column-width,
    grid-size: grid-size,
    grid-thickness: grid-thickness,
    header-height: header-height,
    title: title,
    title-grid-rows: title-grid-rows,
    title-padding: title-padding,
    title-vertical-offset: title-vertical-offset,
    page-count: page-count,
    show-page-numbers: show-page-numbers,
    page-number-width: page-number-width,
    page-number-height: page-number-height,
    show-watermark: show-watermark,
    show-credits: show-credits,
    page-fill: page-fill,
    grid-color: grid-color,
    border-color: border-color,
    horizontal-spacer-color: horizontal-spacer-color,
    vertical-spacer-color: vertical-spacer-color,
    border-thickness: border-thickness,
    spacer-thickness: spacer-thickness,
    watermark-path: watermark-path,
    watermark-width: watermark-width,
    watermark-opacity: watermark-opacity,
    credit: credit,
  )

  set page(width: a4-width, height: a4-height, margin: 0pt, fill: page-fill)
  set text(font: "Arial", size: 10pt)
  show strong: set text(font: "Arial", weight: 700, stretch: 75%)
  for _ in range(page-count) {
    render-sheet(config)
    pagebreak(weak: true)
  }
  body
}
