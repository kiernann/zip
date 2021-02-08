
test_that("base path with spaces", {
  local_temp_dir()
  dir.create("space 1 2")
  setwd("space 1 2")
  dir.create("dir1")
  dir.create("dir2")
  cat("file1", file = "dir1/file1")
  cat("file2", file = "dir2/file2")

  zip_create(c("dir1", "dir2"), "zip1.zip")
  l <- zip_info("zip1.zip")
  expect_equal(l$filename, c("dir1", "dir1/file1", "dir2", "dir2/file2"))

  dir.create("ex1")
  zip_extract("zip1.zip", exdir = "ex1")
  expect_equal(
    sort(dir("ex1", recursive = TRUE)),
    c("dir1/file1", "dir2/file2")
  )

  zip_create(c("dir1", "dir2/file2"), "zip2.zip", junk_paths = TRUE)
  l2 <- zip_info("zip2.zip")
  expect_equal(l2$filename, c("dir1", "dir1/file1", "file2"))

  dir.create("ex2")
  zip_extract("zip2.zip", exdir = "ex2")
  expect_equal(
    sort(dir("ex2", recursive = TRUE)),
    c("dir1/file1", "file2")
  )
})

test_that("uncompressed path with spaces", {
  local_temp_dir()
  root <- "root 1 2"
  dir.create(root)
  cat("contents\n", file = file.path(root, "file 3 4"))
  zip_create(root, "zip1.zip")
  l <- zip_info("zip1.zip")
  expect_equal(
    l$filename,
    c(root, file.path(root, "file 3 4", fsep = "/"))
  )

  dir.create("ex1")
  zip_extract("zip1.zip", exdir = "ex1")
  expect_equal(
    sort(dir("ex1", recursive = TRUE)),
    file.path(root, "file 3 4", fsep = "/")
  )

  zip_create(root, "zip2.zip", junk_paths = TRUE)
  l2 <- zip_info("zip2.zip")

  dir.create("ex2")
  zip_extract("zip2.zip", exdir = "ex2")
  expect_equal(
    l2$filename,
    c(root, file.path(root, "file 3 4", fsep = "/"))
  )
})

test_that("base path with non-ASCII characters", {
  if (tolower(Sys.info()[["sysname"]]) != "windows") {
    skip("Only on Windows")
  }
  local_temp_dir()
  root <- enc2native("\u00fa\u00e1\u00f6\u0151\u00e9")
  dir.create(root)
  setwd(root)
  dir.create("dir1")
  dir.create("dir2")
  cat("file1", file = "dir1/file1")
  cat("file2", file = "dir2/file2")

  zip_create(c("dir1", "dir2"), "zip1.zip")
  l <- zip_info("zip1.zip")
  expect_equal(l$filename, c("dir1/", "dir1/file1", "dir2/", "dir2/file2"))

  dir.create("ex1")
  zip_extract("zip1.zip", exdir = "ex1")
  expect_equal(
    sort(dir("ex1", recursive = TRUE)),
    c("dir1/file1", "dir2/file2")
  )

  zip_create(c("dir1", "dir2/file2"), "zip2.zip", junk_paths = TRUE)
  l2 <- zip_info("zip2.zip")
  expect_equal(l2$filename, c("dir1/", "dir1/file1", "file2"))

  dir.create("ex2")
  zip_extract("zip2.zip", exdir = "ex2")
  expect_equal(
    sort(dir("ex2", recursive = TRUE)),
    c("dir1/file1", "file2")
  )
})

test_that("uncompressed path with non-ASCII characters", {
  if (tolower(Sys.info()[["sysname"]]) != "windows") {
    skip("Only on Windows")
  }
  local_temp_dir()
  root <- enc2native("\u00fa\u00e1\u00f6\u0151\u00e9")
  ufile <- enc2native("ufile\u00fa\u00e1")
  dir.create(root)
  cat("contents\n", file = file.path(root, ufile))
  zip("zip1.zip", root)
  l <- zip_info("zip1.zip")
  expect_equal(
    l$filename,
    c(paste0(root, "/"), file.path(root, ufile, fsep = "/"))
  )
  expect_equal(Encoding(l$filename), rep("UTF-8", 2))

  dir.create("ex1")
  zip_extract("zip1.zip", exdir = "ex1")
  expect_equal(
    sort(dir("ex1", recursive = TRUE)),
    file.path(root, ufile, fsep = "/")
  )

  zip_create(root, "zip2.zip", junk_paths = TRUE)
  l2 <- zip_info("zip2.zip")

  dir.create("ex2")
  zip_extract("zip2.zip", exdir = "ex2")
  expect_equal(
    l2$filename,
    c(paste0(root, "/"), file.path(root, ufile, fsep = "/"))
  )
})

test_that("zip file with spaces", {
  local_temp_dir()
  dir.create("dir1")
  dir.create("dir 2")
  cat("file1", file = "dir1/file 1")
  cat("file2", file = "dir 2/file2")

  zip_create(c("dir1", "dir 2"), "zip1.zip")
  l <- zip_info("zip1.zip")
  expect_equal(l$filename, c("dir1", "dir1/file 1", "dir 2", "dir 2/file2"))

  dir.create("ex1")
  zip_extract("zip1.zip", exdir = "ex1")
  expect_equal(
    sort(dir("ex1", recursive = TRUE)),
    sort(c("dir1/file 1", "dir 2/file2"))
  )

  zip_create(c("dir1", "dir 2/file2"), "zip2.zip", junk_paths = TRUE)
  l2 <- zip_info("zip2.zip")
  expect_equal(l2$filename, c("dir1", "dir1/file 1", "file2"))

  dir.create("ex2")
  zip_extract("zip2.zip", exdir = "ex2")
  expect_equal(
    sort(dir("ex2", recursive = TRUE)),
    c("dir1/file 1", "file2")
  )
})

test_that("zip file with non-ASCII characters", {
  local_temp_dir()
  zipfile <- enc2native("x-\u00fa\u00e1\u00f6\u0151\u00e9.zip")
  dir.create("dir1")
  dir.create("dir2")
  cat("file1", file = "dir1/file1")
  cat("file2", file = "dir2/file2")

  zip_create(c("dir1", "dir2"), zipfile)
  l <- zip_info(zipfile)
  expect_equal(l$filename, c("dir1", "dir1/file1", "dir2", "dir2/file2"))

  dir.create("ex1")
  zip_extract(zipfile, exdir = "ex1")
  expect_equal(
    sort(dir("ex1", recursive = TRUE)),
    c("dir1/file1", "dir2/file2")
  )

  unlink(zipfile)

  # ----------------------------------------------------------------

  zip_create(c("dir1", "dir2/file2"), zipfile, junk_paths = TRUE)
  l2 <- zip_info(zipfile)
  expect_equal(l2$filename, c("dir1", "dir1/file1", "file2"))

  dir.create("ex2")
  zip_extract(zipfile, exdir = "ex2")
  expect_equal(
    sort(dir("ex2", recursive = TRUE)),
    c("dir1/file1", "file2")
  )

  unlink(zipfile)

})
