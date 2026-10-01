bib <- function(x) {
  fs::path_ext(x) <- ".bib"
  here::here("bib", x)
}

typst_string <- function(x) {
  jsonlite::toJSON(as.character(x %||% ""), auto_unbox = TRUE)
}

linkify_urls <- function(x) {
  x <- as.character(x %||% "")

  x <- gsub(
    "(?<!\\()\\bhttps?://(?:dx\\.)?doi\\.org/(?:doi/)?([A-Za-z0-9._;()/:+-]+)",
    "[doi:\\1](https://doi.org/\\1)",
    x,
    perl = TRUE
  )

  gsub(
    "(?<!\\()\\b(https?://[A-Za-z0-9./?=&_%#:+~-]*[A-Za-z0-9/_#])",
    "[\\1](\\1)",
    x,
    perl = TRUE
  )
}

pandoc_md_to_typst <- function(x) {
  x <- linkify_urls(as.character(x %||% ""))
  in_file <- tempfile(fileext = ".md")
  out_file <- tempfile(fileext = ".typ")

  writeLines(x, in_file)
  rmarkdown::pandoc_convert(
    input = in_file,
    to = "typst",
    output = out_file,
    options = c("--wrap=none")
  )

  paste(readLines(out_file, warn = FALSE), collapse = "\n")
}

to_typst_content <- function(x) {
  paste0("[", pandoc_md_to_typst(x), "]")
}

bullet_items <- function(text, max_bullets = Inf) {
  if (is.null(text)) {
    return(character())
  }

  lines <- strsplit(as.character(text), "\\n", fixed = FALSE)[[1]]
  lines <- trimws(lines)
  lines <- lines[nzchar(lines)]
  head(lines, max_bullets)
}

bullet_items_condensed <- function(
  highlights,
  accomplishments,
  max_bullets = 3
) {
  if (!is.null(highlights) && nzchar(trimws(as.character(highlights)))) {
    return(bullet_items(highlights, max_bullets = max_bullets))
  }

  lines <- bullet_items(accomplishments, max_bullets = 100)
  if (length(lines) == 0) {
    return(character())
  }

  supervision_pattern <- paste(
    c(
      "supervis",
      "supervision",
      "train",
      "mentoring",
      "managed?\\s+team",
      "onboard"
    ),
    collapse = "|"
  )

  keep <- !grepl(supervision_pattern, tolower(lines), perl = TRUE)
  filtered <- lines[keep]
  if (length(filtered) == 0) {
    filtered <- lines
  }

  head(filtered, max_bullets)
}

field_value <- function(item, candidates, default = "") {
  for (nm in candidates) {
    val <- item[[nm]]
    if (is.null(val)) {
      next
    }

    text <- as.character(val)
    if (length(text) == 0 || all(is.na(text))) {
      next
    }

    text <- text[!is.na(text)]
    if (length(text) == 0) {
      next
    }

    if (nzchar(trimws(text[1]))) {
      return(text[1])
    }
  }

  default
}

entry_org <- function(item) {
  field_value(
    item,
    c(
      "org",
      "institution",
      "company",
      "organization",
      "entity",
      "provider",
      "what"
    )
  )
}

entry_role <- function(item) {
  field_value(item, c("role", "position", "with"))
}

entry_credential <- function(item) {
  field_value(item, c("credential", "degree", "award", "title"))
}

entry_dates <- function(item) {
  field_value(item, c("dates", "period", "when", "date"))
}

entry_location <- function(item) {
  field_value(item, c("location", "where"))
}

entry_subject <- function(item) {
  field_value(item, c("subject", "course", "name", "what"))
}

parse_month_year <- function(x) {
  x <- trimws(as.character(x %||% ""))
  if (!nzchar(x)) {
    return(as.Date("1900-01-01"))
  }

  x_low <- tolower(x)
  if (x_low %in% c("present", "current")) {
    return(as.Date("9999-12-31"))
  }

  parts <- strsplit(x, "\\s+")[[1]]
  if (length(parts) < 2) {
    return(as.Date("1900-01-01"))
  }

  month_num <- match(parts[1], month.abb)
  year_num <- suppressWarnings(as.integer(parts[2]))
  if (is.na(month_num) || is.na(year_num)) {
    return(as.Date("1900-01-01"))
  }

  as.Date(sprintf("%04d-%02d-01", year_num, month_num))
}

extract_end_date <- function(when) {
  bounds <- strsplit(as.character(when %||% ""), "\\s*-\\s*")[[1]]
  end_part <- if (length(bounds) >= 2) bounds[2] else bounds[1]
  parse_month_year(end_part)
}

extract_start_date <- function(when) {
  bounds <- strsplit(as.character(when %||% ""), "\\s*-\\s*")[[1]]
  start_part <- bounds[1]
  parse_month_year(start_part)
}

sort_experience <- function(experience) {
  if (length(experience) == 0) {
    return(experience)
  }

  end_dates <- vapply(
    experience,
    \(x) extract_end_date(entry_dates(x)),
    as.Date("1970-01-01")
  )
  start_dates <- vapply(
    experience,
    \(x) extract_start_date(entry_dates(x)),
    as.Date("1970-01-01")
  )
  experience[order(end_dates, start_dates, decreasing = TRUE)]
}

bold_me <- function(x) {
  gsub("Barbone, J. M.", "**Barbone, J. M.**", x, fixed = TRUE)
}

format_refs_apa <- function(bib_files, csl_file) {
  bib_files <- normalizePath(bib_files, mustWork = TRUE)
  csl_file <- normalizePath(csl_file, mustWork = TRUE)

  in_file <- tempfile(fileext = ".md")
  out_file <- tempfile(fileext = ".html")

  yaml_block <- c(
    "---",
    paste0("csl: ", csl_file),
    "bibliography:",
    paste0("  - ", bib_files),
    "nocite: '@*'",
    "---",
    "",
    "::: {#refs}",
    ":::"
  )

  writeLines(yaml_block, in_file)
  rmarkdown::pandoc_convert(
    input = in_file,
    to = "html",
    output = out_file,
    options = c("--citeproc", "--wrap=none")
  )

  html <- xml2::read_html(out_file)
  nodes <- xml2::xml_find_all(
    html,
    "//div[@id='refs']/*[contains(@class, 'csl-entry')]"
  )
  refs <- trimws(xml2::xml_text(nodes))
  bold_me(refs[nzchar(refs)])
}

emit_group_items <- function(title, items) {
  items <- as.character(items)
  items <- items[nzchar(trimws(items))]

  out <- c(
    "  (",
    paste0("    title: ", to_typst_content(title), ","),
    "    body: ["
  )

  for (it in items) {
    out <- c(out, paste0("      - ", pandoc_md_to_typst(it)))
  }

  c(out, "    ],", "  ),")
}

emit_named_groups <- function(groups) {
  out <- c("(")
  for (g in groups) {
    out <- c(out, emit_group_items(g$title, g$items))
  }
  out <- c(out, ")")
  paste(out, collapse = "\n")
}

read_package_links <- function(bib_file) {
  bib <- RefManageR::ReadBib(bib_file)

  items <- lapply(bib, function(entry) {
    key <- names(entry)
    title <- as.character(entry[[key]]$title %||% "")
    pkg <- trimws(sub(":.*$", "", title))
    url <- as.character(entry[[key]]$url %||% "")
    if (!nzchar(pkg) || !nzchar(url)) {
      return(NULL)
    }
    list(name = pkg, url = url)
  })

  items <- Filter(Negate(is.null), items)
  unique(items)
}

emit_typst_chunk <- function(lines) {
  cat(sprintf("```{=typst}\n%s\n```\n", paste(lines, collapse = "\n")))
}
