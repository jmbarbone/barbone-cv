
with_cleanup <- function(dir, code) {
  old <- fs::dir_ls()
  try(force(code))
  new <- setdiff(fs::dir_ls(), old)
  # ignore the CV and Resume files
  new <- grep("Barbone-(CV|Resume)\\.pdf", new, invert = TRUE, value = TRUE)
  cat("Moving new files", paste("\n-", new, collapse = ", "), "\n")
  fs::dir_create(dir)
  fs::file_move(new, fs::path(dir, new))

  known <- basename(fs::dir_ls(dir))
  fs::file_delete(known[fs::file_exists(known)])
}
