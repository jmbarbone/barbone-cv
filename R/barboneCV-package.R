#' @keywords internal
"_PACKAGE"

## usethis namespace: start
## usethis namespace: end
NULL

.onLoad <- function(libname, pkgname) {
  options(
    tinytex.verbose = TRUE,
    tidyverse.quiet = TRUE
  )

  library(knitr, warn.conflicts = FALSE)
  library(tidyverse, warn.conflicts = FALSE)
  library(vitae, warn.conflicts = FALSE)
  library(bookdown, warn.conflicts = FALSE)
  library(mark, warn.conflicts = FALSE)

  BUILD <<- "cv"
}
