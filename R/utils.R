
with_cleanup <- function(dir, code) {
  wd <- getwd()
  old <- fs::dir_ls()
  try(force(code))
  withr::with_dir(wd, {
    new <- setdiff(fs::dir_ls(), old)
    # ignore the CV and Resume files
    new <- new[grep("$Barbone-(CV|Resume)\\.pdf$", basename(new), invert = TRUE)]
    cat("Moving new files", paste("\n-", new, collapse = ", "), "\n")
    fs::dir_create(dir)
    fs::file_move(new, fs::path(dir, new))

    known <- basename(fs::dir_ls(dir))
    fs::file_delete(known[fs::file_exists(known)])
  })
}
