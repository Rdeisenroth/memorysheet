#import "config.typ": validate

#let a4-width = 297mm
#let a4-height = 210mm
#let render-sheet(config) = {
  let config = validate(config)
  let inner-width = a4-width - 2 * config.horizontal-margin
  let inner-height = a4-height - 2 * config.margin
  let full-grid-columns = calc.floor(inner-width / config.grid-size)
  let full-grid-rows = calc.floor(inner-height / config.grid-size)
  let remaining-grid-width = inner-width - full-grid-columns * config.grid-size
  let remaining-grid-height = inner-height - full-grid-rows * config.grid-size
  assert(remaining-grid-width == 0pt, message: "horizontal-margin and grid-size must produce whole grid cells")
  assert(remaining-grid-height == 0pt, message: "margin and grid-size must produce whole grid cells")
  let grid-column-sizes = range(full-grid-columns).map(_ => config.grid-size)
  let grid-row-sizes = range(full-grid-rows).map(_ => config.grid-size)
  let grid-columns = grid-column-sizes.len()
  let grid-rows = grid-row-sizes.len()
  let spacer-count = calc.ceil(inner-width / config.column-width) + 1
  assert(config.title-grid-columns <= grid-columns, message: "title box is wider than the grid")
  assert(config.title-grid-rows <= grid-rows, message: "title box is taller than the grid")
  let title-width = config.title-grid-columns * config.grid-size
  let title-height = config.title-grid-rows * config.grid-size
  let title-column = calc.floor((grid-columns - config.title-grid-columns) / 2)
  let page-number-grid-columns = calc.ceil(config.page-number-width / config.grid-size)
  let page-number-column = calc.floor((grid-columns - page-number-grid-columns) / 2)

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
        #image(
          bytes(
            read(config.watermark-path).replace(
              "fill-opacity=\"1\"",
              "fill-opacity=\"" + str(config.watermark-opacity / 100%) + "\"",
            ),
          ),
          format: "svg",
          width: config.watermark-width,
        )
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
      )[ #align(center + horizon)[#config.title] ]
    ]

    #if config.show-credits [
      #place(top + center, dy: config.margin + config.header-height - 2 * 7pt)[
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

// Use this as `#show: memorysheet.with(...)` for named-parameter completion in Typst editors.
#let memorysheet(
  margin: 5mm,
  horizontal-margin: 6mm,
  column-width: 4cm,
  grid-size: 2.5mm,
  grid-thickness: 0.25pt,
  header-height: 1.5cm,
  title: [*NETSEC* Merkzettel von: #box(width: 3cm, height: 1em, stroke: (bottom: 0.75pt))[]],
  title-grid-columns: 29,
  title-grid-rows: 2,
  page-count: 2,
  show-page-numbers: true,
  page-number-width: 1.5cm,
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
    title-grid-columns: title-grid-columns,
    title-grid-rows: title-grid-rows,
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
