update_cv_library <- function() {
  i_am_author <- function(x) {
    its_me <- function(p) p$email == "jmbarbone@gmail.com" && "aut" %in% p$role
    any(vapply(x, its_me, NA))
  }

  packages <-
    tools::CRAN_package_db() |>
    subset(!is.na(`Authors@R`)) |>
    subset(grepl("Barbone", `Authors@R`, fixed = TRUE)) |>
    transform(
      `Authors@R` = lapply(`Authors@R`, \(i) eval(str2expression(i)))
    ) |>
    subset(
      vapply(`Authors@R`, i_am_author, NA),
      "Package",
      drop = TRUE
    )

  lib <- Sys.getenv("R_LIB_CV", "~/R/cv-library")
  fs::dir_create(lib, ", ")

  pak::pak(packages, lib = lib, ask = FALSE)

  knitr::write_bib(
    x = packages,
    file = bib("packages"),
    lib.loc = lib
  )
}
