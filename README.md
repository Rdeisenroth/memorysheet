# Typst memory sheet

A structured [Typst](https://typst.app/) template for creating memory sheets permitted in exams. It defaults to a 2.5 mm grid, 4 cm columns, two landscape A4 pages, page labels, credits, and a faint TU Darmstadt watermark.

<p align="center">
  <b>Latest memory sheet</b><br>
  <!-- Replace this placeholder Nextcloud public-share URL with your own. -->
  <a href="https://next.hessenbox.de/index.php/s/o9ERzPST68gw9cE?dir=/&editing=false&openfile=true">
    <img src="https://img.shields.io/badge/Download%20Memory%20Sheet-PDF-blue?style=for-the-badge" alt="Download the latest memory sheet PDF">
  </a>
</p>

All day-to-day document settings live in the named `#show: memorysheet.with(...)` call in [`memorysheet.typ`](memorysheet.typ), giving Typst editors autocomplete for every option. The settings are validated at compile time: invalid page counts, dimensions, opacity values, and switches fail with a clear error.

## Build

Install [Typst](https://github.com/typst/typst), then run:

```sh
make
```

The PDF is written to `build/memorysheet.pdf`. Use `make watch` during editing, `make preview` to update the neutral SVG shown below, and `make lint` to check Typst formatting.

The TU Darmstadt watermark is downloaded on demand through Docker and is intentionally not stored in Git. Run `make download-watermark` explicitly, or let `make` fetch it when it is missing.

## Publishing from GitHub Actions

On pushes to `main` or `master`, the workflow builds a PDF/A-2b artifact and deploys it to Nextcloud through WebDAV. Configure these repository secrets before enabling a real upload:

- `NC_WEBDAV_URL` — the destination WebDAV folder URL
- `NC_WEBDAV_USERNAME` — the Nextcloud WebDAV user name
- `NC_WEBDAV_PW` — that user's app password

The destination receives `memorysheet.pdf`; uploads are skipped safely until all three secrets exist.

You might want to turn off page numbers or the credits, if your printer doesn't support borderless printing.

I recommend these pens for writing on the sheet, as they truly are the smallest fineliners I could find (no, this is not an affiliate link): https://www.amazon.de/dp/B07DJNTHGY

They do not last very long, and some can arrive defective out of the box, so I recommend buying the 12-pack directly. They are still worth it for their size though imo.

## Preview
### The template
Here is a preview of the template, with watermark, page numbers and credits turned on:
![Preview](img/preview.svg)

### A filled out example
Here is an example I used during an actual exam:
![Example](img/FMSe-Merkzettel%20(1).jpg)
![Example](img/FMSe-Merkzettel%20(2).jpg)

Nowadays, I also like to use colors to make the sheet more readable and easier to scan. For that, I recommend this Micron pack: https://www.amazon.de/dp/B08RXZYB1P
