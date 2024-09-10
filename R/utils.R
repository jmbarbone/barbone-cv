
with_cleanup <- function(dir, code) {
  old <- fs::dir_ls(dir, recurse = TRUE)
  on.exit({
    new <- fs::dir_ls(dir, recurse = TRUE)
    new <- setdiff(new, old)
    # ignore the CV and Resume files
    new <- grep("Barbone-(CV|Resume)\\.(pdf|log)$", new, invert = TRUE, value = TRUE)
    if (length(new)) {
      cat("Deleting new files", paste("\n-", new, collapse = ", "), "\n")
      fs::file_delete(new)
    }

  })

  force(code)
}
