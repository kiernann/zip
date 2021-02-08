test_that("example path returned", {
  zipfile <- zip_example()
  expect_true(file.exists(zipfile))
  expect_s3_class(zipfile, "fs_path")
})
