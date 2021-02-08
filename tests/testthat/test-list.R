
test_that("can list a zip file", {

  dir.create(tmp <- tempfile())
  cat("first file", file = file.path(tmp, "file1"))
  cat("second file", file = file.path(tmp, "file2"))

  zipfile <- tempfile(fileext = ".zip")

  expect_silent(
    withr::with_dir(
      new = dirname(tmp),
      code = zip_create(basename(tmp), zipfile, junk_paths = TRUE)
    )
  )

  expect_true(file.exists(zipfile))

  list <- zip_info(zipfile)

  expect_s3_class(list, "data.frame")
  expect_s3_class(list$compressed_size, "fs_bytes")
  expect_s3_class(list$permissions, "fs_perms")

  expect_equal(
    object = basename(list$filename),
    expected = c(basename(tmp), "file1", "file2")
  )

  expect_equal(
    object = colnames(list),
    expected = c("filename", "compressed_size", "uncompressed_size",
                 "timestamp", "permissions")
  )
})

test_that("can list a zip file names only", {

  dir.create(tmp <- tempfile())
  cat("first file", file = file.path(tmp, "file1"))
  cat("second file", file = file.path(tmp, "file2"))

  zipfile <- tempfile(fileext = ".zip")

  expect_silent(
    withr::with_dir(
      new = dirname(tmp),
      code = zip_create(basename(tmp), zipfile, junk_paths = TRUE)
    )
  )

  expect_true(file.exists(zipfile))

  list <- zip_ls(zipfile)

  expect_type(list, "character")
  expect_s3_class(list, "fs_path")


  expect_equal(basename(list), c(basename(tmp), "file1", "file2"))
})
