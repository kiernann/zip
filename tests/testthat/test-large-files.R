
context("large files")

test_that("can compress large files", {

  skip_on_cran()

  ## Note: it will be also skipped if we cannot find a reasonable quick
  ## way to create a 4GB file.

  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)
  dir.create(tmp <- tempfile())
  file1 <- file.path(tmp, "file1")
  make_big_file(file1, 4000)
  size <- file.info(file1)$size

  zipfile <- tempfile(fileext = ".zip")
  on.exit(unlink(zipfile), add = TRUE)

  zip(zipfile, file1)
  expect_true(file.exists(zipfile))
  list <- zip_list(zipfile)
  expect_equal(list$filename, "file1")
  expect_equal(list$uncompressed_size, size)

  on.exit(unlink(tmp2, recursive = TRUE), add = TRUE)
  dir.create(tmp2 <- tempfile())

  unlink(file1)
  utils::unzip(zipfile, exdir = tmp2)

})