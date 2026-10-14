update_references_bib <- function() {
  temp <- tempfile()
  on.exit(file.remove(temp))
  writeLines(
    readLines(url(
      "https://raw.githubusercontent.com/jmbarbone/bib-references/refs/heads/main/references.bib"
    )),
    temp
  )
  references <- RefManageR::ReadBib(temp)
  references <- as.data.frame(references)

  # references <- mark::read_bib(temp)
  # references$bibtype <- references$field

  has_keywords <- function(entries, keywords) {
    keywords <- tolower(keywords)
    entries <- tolower(entries)
    vapply(
      strsplit(tolower(entries), ", ", fixed = TRUE),
      \(kw) all(keywords %in% kw),
      NA
    )
  }

  write_bib <- function(data, file) {
    RefManageR::WriteBib(
      RefManageR::as.BibEntry(data),
      file = bib(file),
      biblatex = TRUE
    )
  }

  has_me <- function(x) {
    grepl("barbone", tolower(x), fixed = TRUE)
  }

  references |>
    subset(
      tolower(bibtype) == "article" & has_me(author),
    ) |>
    write_bib("publications")

  references |>
    subset(
      tolower(bibtype) == "mastersthesis" & has_me(author),
    ) |>
    write_bib("thesis")

  references |>
    subset(
      tolower(bibtype) == "inproceedings" &
        has_keywords(keywords, "cogstate") &
        has_me(author)
    ) |>
    write_bib("posters_cogstate")

  references |>
    subset(
      tolower(bibtype) == "inproceedings" &
        has_keywords(keywords, "madrigal") &
        has_me(author)
    ) |>
    write_bib("posters_madrigal")

  references |>
    subset(
      tolower(bibtype) == "inproceedings" &
        has_keywords(keywords, "signant health") &
        has_me(author)
    ) |>
    write_bib("posters_signant")

  references |>
    subset(
      tolower(bibtype) == "inproceedings" &
        has_keywords(keywords, "wcupa") &
        has_me(author)
    ) |>
    write_bib("posters_wcupa")
}
