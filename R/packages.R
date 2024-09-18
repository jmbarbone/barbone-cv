update_cv_library <- function() {
packages <- c(
    "mark",
    "fuj",
    "scribe",
    "echo",
    "openxlsx2",
    NULL
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
