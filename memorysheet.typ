#import "src/memorysheet.typ": memorysheet

// Named parameters are surfaced as autocomplete suggestions in Typst editors.
#show: memorysheet.with(
  margin: 5mm,
  horizontal-margin: 6mm,
  column-width: 4cm,
  grid-size: 2.5mm,
  grid-thickness: 0.25pt,
  header-height: 1.5cm,
  title: [Merkzettel von: #box(width: 3cm, height: 1em, stroke: (bottom: 0.75pt))[]],
  title-grid-rows: 2,
  title-padding: 2.5mm,
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
  watermark-width: 50%,
  watermark-opacity: 10%,
)
