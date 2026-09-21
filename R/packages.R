update_cv_library <- function() {
  packages <- subset(
    tools::CRAN_package_db(),
    grepl("jmbarbone@gmail.com", `Authors@R`, fixed = TRUE),
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
