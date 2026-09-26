with_cleanup <- function(dir, code) {
  old <- fs::dir_ls(dir, recurse = TRUE)
  on.exit({
    new <- fs::dir_ls(dir, recurse = TRUE)
    new <- setdiff(new, old)
    # ignore the CV and Resume files
    new <- grep(
      "Barbone-(CV|Resume)\\.(pdf|log|md|tex|Rmd)$",
      new,
      invert = TRUE,
      value = TRUE
    )
    if (length(new)) {
      cat("Deleting new files", paste("\n-", new, collapse = ", "), "\n")
      fs::file_delete(new)
    }
  })

  force(code)
}

adjust_author_name <- function(a) {
  splits <- strsplit(a, " and ")[[1]]
  switches <- sapply(splits, function(x) {
    x <- gsub("(^.*)[,](.*$)", "\\2 \\1", x)
    x <- gsub("\\s+", " ", x)
    trimws(x)
  })
  paste(switches, collapse = " and ")
}

adjust_author_names <- function(names) {
  sapply(names, adjust_author_name)
}

read_yaml <- function(x) {
  x |>
    yaml::read_yaml() |>
    purrr::pluck(1) |>
    purrr::map(tibble::as_tibble) |>
    purrr::list_rbind()
}

bib <- function(x) {
  fs::path_ext(x) <- ".bib"
  here::here("bib", x)
}

md_to_latex <- function(x) {
  if (is.data.frame(x)) {
    ind <- vapply(x, is.character, NA)
    if (!any(ind)) {
      return(x)
    }

    x[ind] <- lapply(x[ind], md_to_latex)
    return(x)
  }

  # x <- "I want to find **this text** in something"
  x <- do_md_to_latex(x, "**", "textbf")
  x <- do_md_to_latex(x, "_", "textit")
  x
}

do_md_to_latex <- function(x, find, replace, ..remove = FALSE) {
  n <- nchar(find)
  pattern <- paste0("\\", strsplit(find, "")[[1L]], collapse = "")
  pattern <- paste0(pattern, "[[:alnum:][:space:]']+", pattern)
  m <- gregexpr(pattern, x, ignore.case = TRUE)
  do_replace <- if (..remove) {
    \(x) substring(x, n + 1L, nchar(x) - n)
  } else {
    \(x) sprintf("\\%s{%s}", replace, substring(x, n + 1L, nchar(x) - n))
  }
  found <- lapply(regmatches(x, m), do_replace)
  regmatches(x, m) <- found
  x
}
