test_that("compressed file sizes listed", {
  s <- zip_size(zip_example())
  expect_type(s, "double")
  expect_s3_class(s, "fs_bytes")
  expect_length(s, 4)
})

test_that("single compressed file sizes listed", {
  s <- zip_size(zip_example(), sum = TRUE)
  expect_type(s, "double")
  expect_s3_class(s, "fs_bytes")
  expect_length(s, 1)
})

test_that("compression ratio listed", {
  s <- zip_ratio(zip_example())
  expect_type(s, "double")
  expect_length(s, 4)
})

test_that("single overall compression ratio listed", {
  s <- zip_ratio(zip_example(), sum = TRUE)
  expect_type(s, "double")
  expect_length(s, 1)
})
