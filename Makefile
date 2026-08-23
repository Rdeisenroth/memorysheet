OUT_DIR := build
SOURCE := memorysheet.typ
PDF := $(OUT_DIR)/memorysheet.pdf
WATERMARK := img/tuda_logo.svg
PREVIEW := img/preview.svg

.PHONY: all compile preview watch lint clean download-watermark

all: compile

compile: $(PDF)

$(PDF): $(SOURCE) src/config.typ src/memorysheet.typ $(WATERMARK)

	@mkdir -p $(OUT_DIR)
	typst compile --pdf-standard a-2b $(SOURCE) $@

$(WATERMARK): .github/Dockerfile.logo scripts/download_watermark.sh
	sh scripts/download_watermark.sh

download-watermark: $(WATERMARK)

preview: $(PREVIEW)

$(PREVIEW): src/config.typ src/memorysheet.typ $(WATERMARK)
	printf '%s\n' \
	  '#import "src/memorysheet.typ": memorysheet' \
	  '#show: memorysheet.with(' \
	  '  page-count: 1,' \
	  '  title: [Merkzettel von: #box(width: 3cm, height: 1em, stroke: (bottom: 0.75pt))[]],' \
	  ')' \
	  | typst compile --format svg --pages 1 - $(PREVIEW)

watch:
	typst watch $(SOURCE) $(PDF)

lint:
	typstyle --check --line-width 120 $(SOURCE) src/*.typ

clean:
	rm -rf $(OUT_DIR)
