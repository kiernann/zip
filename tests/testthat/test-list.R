
test_that("can list a zip file", {

  dir.create(tmp <- tempfile())
  cat("first file", file = file.path(tmp, "file1"))
  cat("second file", file = file.path(tmp, "file2"))

  zipfile <- tempfile(fileext = ".zip")

  expect_silent(
    withr::with_dir(
      new = dirname(tmp),
      code = zip_create2(zipfile, basename(tmp))
    )
  )

  expect_true(file.exists(zipfile))

  list <- zip_list(zipfile)

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
