OUT_DIR := build
SOURCE := memorysheet.typ
PDF := $(OUT_DIR)/memorysheet.pdf
WATERMARK := img/tuda_logo.svg

.PHONY: all compile preview watch lint clean download-watermark

all: compile

compile: $(PDF)

$(PDF): $(SOURCE) src/config.typ src/memorysheet.typ $(WATERMARK)

	@mkdir -p $(OUT_DIR)
	typst compile --pdf-standard a-2b $(SOURCE) $@

$(WATERMARK): .github/Dockerfile.logo scripts/download_watermark.sh
	sh scripts/download_watermark.sh

download-watermark: $(WATERMARK)

preview: compile
	pdftoppm -png -f 1 -singlefile -r 150 $(PDF) $(OUT_DIR)/memorysheet-preview

watch:
	typst watch $(SOURCE) $(PDF)

lint:
	typstyle --check --line-width 120 $(SOURCE) src/*.typ

clean:
	rm -rf $(OUT_DIR)
