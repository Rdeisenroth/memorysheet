OUT_DIR := build
SOURCE := memorysheet.typ
PDF := $(OUT_DIR)/memorysheet.pdf

.PHONY: all compile preview watch lint clean

all: compile

compile: $(PDF)

$(PDF): $(SOURCE) src/config.typ src/memorysheet.typ img/tuda_logo.svg

	@mkdir -p $(OUT_DIR)
	typst compile --pdf-standard a-2b $(SOURCE) $@

preview: compile
	pdftoppm -png -f 1 -singlefile -r 150 $(PDF) $(OUT_DIR)/memorysheet-preview

watch:
	typst watch $(SOURCE) $(PDF)

lint:
	typstyle --check --line-width 120 $(SOURCE) src/*.typ

clean:
	rm -rf $(OUT_DIR)
