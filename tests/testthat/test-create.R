
test_that("can compress single directory", {

  on.exit(try(unlink(c(zipfile, tmp), recursive = TRUE)))

  dir.create(tmp <- tempfile())
  cat("first file", file = file.path(tmp, "file1"))
  cat("second file", file = file.path(tmp, "file2"))

  zipfile <- tempfile(fileext = ".zip")

  withr::with_dir(
    dirname(tmp),
    zip_create(basename(tmp), zipfile)
  )

  expect_true(file.exists(zipfile))

  list <- zip_info(zipfile)
  expect_equal(
    list$filename,
    c(basename(tmp), file.path(basename(tmp), c("file1", "file2")))
  )
})

test_that("can compress single file", {

  on.exit(try(unlink(c(zipfile, tmp), recursive = TRUE)))

  tmp <- tempfile()
  cat("compress this if you can!", file = tmp)

  zipfile <- tempfile(fileext = ".zip")

  withr::with_dir(
    dirname(tmp),
    zip_create(basename(tmp), zipfile)
  )

  expect_true(file.exists(zipfile))

  list <- zip_info(zipfile)
  expect_equal(list$filename, basename(tmp))
})

test_that("can compress multiple files", {

  on.exit(try(unlink(c(zipfile, tmp1, tmp2), recursive = TRUE)))

  cat("compress this if you can!", file = tmp1 <- tempfile())
  cat("or even this one", file = tmp2 <- tempfile())

  zipfile <- tempfile(fileext = ".zip")

  withr::with_dir(
    dirname(tmp1),
    zip_create(basename(c(tmp1, tmp2)), zipfile)
  )

  expect_true(file.exists(zipfile))

  list <- zip_info(zipfile)
  expect_equal(list$filename, basename(c(tmp1, tmp2)))
})

test_that("can compress multiple directories", {

  on.exit(try(unlink(c(zipfile, tmp1, tmp2), recursive = TRUE)), add = TRUE)

  dir.create(tmp1 <- tempfile())
  dir.create(tmp2 <- tempfile())
  cat("first file\n", file = file.path(tmp1, "file1"))
  cat("second file\n", file = file.path(tmp1, "file2"))
  cat("third file\n", file = file.path(tmp2, "file3"))
  cat("fourth file\n", file = file.path(tmp2, "file4"))

  zipfile <- tempfile(fileext = ".zip")

  withr::with_dir(
    dirname(tmp1),
    zip_create(basename(c(tmp1, tmp2)), zipfile)
  )

  expect_true(file.exists(zipfile))

  list <- zip_info(zipfile)
  expect_equal(
    list$filename,
    c(basename(tmp1), file.path(basename(tmp1), c("file1", "file2")),
      basename(tmp2), file.path(basename(tmp2), c("file3", "file4")))
  )

  on.exit(try(unlink(c(tmp3), recursive = TRUE)), add = TRUE)
  dir.create(tmp3 <- tempfile())
  utils::unzip(zipfile, exdir = tmp3)
  expect_true(file.info(file.path(tmp3, basename(tmp1)))$isdir)
  expect_true(file.info(file.path(tmp3, basename(tmp2)))$isdir)
  expect_equal(readLines(file.path(tmp1, "file1")),
               readLines(file.path(tmp3, basename(tmp1), "file1")))
  expect_equal(readLines(file.path(tmp1, "file2")),
               readLines(file.path(tmp3, basename(tmp1), "file2")))
  expect_equal(readLines(file.path(tmp2, "file3")),
               readLines(file.path(tmp3, basename(tmp2), "file3")))
  expect_equal(readLines(file.path(tmp2, "file4")),
               readLines(file.path(tmp3, basename(tmp2), "file4")))
})

test_that("can compress files and directories", {

  on.exit(try(unlink(c(zipfile, tmp, file1, file2), recursive = TRUE)))

  dir.create(tmp <- tempfile())
  cat("first file", file = file.path(tmp, "file1"))
  cat("second file", file = file.path(tmp, "file2"))
  cat("third file", file = file1 <- tempfile())
  cat("fourth file", file = file2 <- tempfile())

  zipfile <- tempfile(fileext = ".zip")

  withr::with_dir(
    dirname(tmp),
    zip_create(basename(c(file1, tmp, file2)), zipfile)
  )

  expect_true(file.exists(zipfile))

  list <- zip_info(zipfile)
  expect_equal(
    list$filename,
    c(basename(file1), basename(tmp),
      file.path(basename(tmp), c("file1", "file2")),
      basename(file2))
  )
})

test_that("warning for directories in non-recursive mode", {

  on.exit(try(unlink(c(zipfile, tmp, file1, file2), recursive = TRUE)))

  dir.create(tmp <- tempfile())
  cat("first file", file = file.path(tmp, "file1"))
  cat("second file", file = file.path(tmp, "file2"))
  cat("third file", file = file1 <- tempfile())
  cat("fourth file", file = file2 <- tempfile())

  zipfile <- tempfile(fileext = ".zip")

  expect_warning(
    withr::with_dir(
      dirname(tmp),
      zip_create(basename(c(file1, tmp, file2)), zipfile, recurse = FALSE)
    ),
    "directories ignored"
  )

  expect_true(file.exists(zipfile))

  list <- zip_info(zipfile)
  expect_equal(
    list$filename,
    c(basename(file1), basename(file2))
  )
})

test_that("compression level is used", {

  on.exit(try(unlink(c(zipfile1, zipfile2, file), recursive = TRUE)))

  tmp <- tempfile()
  write(1:10000, file = file <- tempfile())

  zipfile1 <- tempfile(fileext = ".zip")
  zipfile2 <- tempfile(fileext = ".zip")

  withr::with_dir(
    dirname(file),
    zip_create(basename(file), zipfile1, level = 1)
  )

  withr::with_dir(
    dirname(file),
    zip_create(basename(file), zipfile2, level = 9)
  )

  expect_true(file.exists(zipfile1))
  expect_true(file.exists(zipfile2))

  list <- zip_info(zipfile1)
  expect_equal(list$filename, basename(file))

  list <- zip_info(zipfile2)
  expect_equal(list$filename, basename(file))

  expect_true(file.info(zipfile1)$size <= file.info(zipfile2)$size)
})

test_that("can append a directory to an archive", {

  on.exit(try(unlink(c(zipfile, tmp, tmp2), recursive = TRUE)))

  dir.create(tmp <- tempfile())
  cat("first file", file = file.path(tmp, "file1"))
  cat("second file", file = file.path(tmp, "file2"))

  zipfile <- tempfile(fileext = ".zip")

  withr::with_dir(
    dirname(tmp),
    zip_create(basename(tmp), zipfile)
  )

  expect_true(file.exists(zipfile))

  list <- zip_info(zipfile)
  expect_equal(
    list$filename,
    c(basename(tmp), file.path(basename(tmp), c("file1", "file2")))
  )

  dir.create(tmp2 <- tempfile())
  cat("first file2", file = file.path(tmp2, "file3"))
  cat("second file2", file = file.path(tmp2, "file4"))

  withr::with_dir(
    dirname(tmp),
    zip_append(basename(tmp2), zipfile)
  )

  list <- zip_info(zipfile)
  expect_equal(
    list$filename,
    c(basename(tmp), file.path(basename(tmp), c("file1", "file2")),
      basename(tmp2), file.path(basename(tmp2), c("file3", "file4")))
  )
})

test_that("can append a file to an archive", {

  on.exit(try(unlink(c(zipfile, tmp, file1), recursive = TRUE)))

  dir.create(tmp <- tempfile())
  cat("first file", file = file.path(tmp, "file1"))
  cat("second file", file = file.path(tmp, "file2"))

  zipfile <- tempfile(fileext = ".zip")

  withr::with_dir(
    dirname(tmp),
    zip_create(basename(tmp), zipfile)
  )

  expect_true(file.exists(zipfile))

  list <- zip_info(zipfile)
  expect_equal(
    list$filename,
    c(basename(tmp), file.path(basename(tmp), c("file1", "file2")))
  )

  cat("first file2", file = file1 <- tempfile())

  withr::with_dir(
    dirname(tmp),
    zip_append(basename(file1), zipfile)
  )

  list <- zip_info(zipfile)
  expect_equal(
    list$filename,
    c(basename(tmp), file.path(basename(tmp), c("file1", "file2")),
      basename(file1))
  )
})

test_that("can append files and directories to an archive", {

  on.exit(try(unlink(c(zipfile, tmp, tmp2, file1), recursive = TRUE)))

  dir.create(tmp <- tempfile())
  cat("first file", file = file.path(tmp, "file1"))
  cat("second file", file = file.path(tmp, "file2"))

  zipfile <- tempfile(fileext = ".zip")

  withr::with_dir(
    dirname(tmp),
    zip_create(basename(tmp), zipfile)
  )

  expect_true(file.exists(zipfile))

  list <- zip_info(zipfile)
  expect_equal(
    list$filename,
    c(basename(tmp), file.path(basename(tmp), c("file1", "file2")))
  )

  cat("first file2", file = file1 <- tempfile())
  dir.create(tmp2 <- tempfile())
  cat("another", file = file.path(tmp2, "file3"))
  cat("and another", file = file.path(tmp2, "file4"))

  withr::with_dir(
    dirname(tmp),
    zip_append(basename(c(file1, tmp2)), zipfile)
  )

  list <- zip_info(zipfile)
  expect_equal(
    list$filename,
    c(basename(tmp), file.path(basename(tmp), c("file1", "file2")),
      basename(file1),
      basename(tmp2), file.path(basename(tmp2), c("file3", "file4")))
  )
})

test_that("empty directories are archived as directories", {

  on.exit(try(unlink(c(zipfile, tmp), recursive = TRUE)), add = TRUE)
  dir.create(tmp <- tempfile())
  zipfile <- tempfile(fileext = ".zip")

  dir.create(file.path(tmp, "foo", "bar"), recursive = TRUE)
  dir.create(file.path(tmp, "foo", "bar2"))
  cat("contents\n", file = file.path(tmp, "foo", "file1"))

  withr::with_dir(
    dirname(tmp),
    zip_create(basename(tmp), zipfile)
  )

  bt <- basename(tmp)
  list <- zip_info(zipfile)
  expect_equal(
    list$filename,
    c(bt, paste0(bt, "/foo"), paste0(bt, "/foo/bar"),
      paste0(bt, "/foo/bar2"), paste0(bt, "/foo/file1"))
  )

  on.exit(unlink(tmp2, recursive = TRUE), add = TRUE)
  dir.create(tmp2 <- tempfile())
  utils::unzip(zipfile, exdir = tmp2)
  files <- sort(dir(tmp2, recursive = TRUE, include.dirs = TRUE))
  expect_equal(
    files,
    c(bt, file.path(bt, "foo"), file.path(bt, "foo", "bar"),
      file.path(bt, "foo", "bar2"), file.path(bt, "foo", "file1"))
  )

  expect_equal(file.info(file.path(tmp2, files))$isdir,
               c(TRUE, TRUE, TRUE, TRUE, FALSE))

  expect_equal(readLines(file.path(tmp2, bt, "foo", "file1")), "contents")
})

test_that("warn for relative paths", {
  on.exit(try(unlink(tmp, recursive = TRUE)), add = TRUE)
  dir.create(tmp <- tempfile())

  dir.create(file.path(tmp, "foo"))
  dir.create(file.path(tmp, "foo", "bar"))

  on.exit(unlink(zipfile), add = TRUE)
  zipfile <- tempfile(fileext = ".zip")

  withr::with_dir(
    file.path(tmp, "foo"),
    expect_warning(zip_create(file.path("..", "foo"), zipfile))
  )

  withr::with_dir(
    file.path(tmp, "foo"),
    expect_warning(zip_create(file.path("..", "foo", "bar"), zipfile))
  )

  withr::with_dir(
    file.path(tmp, "foo"),
    expect_warning(zip_create(".", zipfile))
  )
})

test_that("example", {
  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)
  dir.create(tmp <- tempfile())

  withr::with_dir(
    tmp,
    {
      dir.create("foo")
      dir.create(file.path("foo", "bar"))
      dir.create(file.path("foo", "bar2"))
      dir.create("foo2")

      cat("contents\n", file = file.path("foo", "bar", "file1"))
      cat("contents\n", file = file.path("foo", "bar2", "file2"))
      cat("contents\n", file = file.path("foo2", "file3"))

      setwd("foo")
      tz <- c(file.path("bar", "file1"), "bar2", file.path("..", "foo2"))
      expect_warning(zip_create(tz, "x.zip"))
      expect_equal(
        zip_ls("x.zip"),
        c(file.path("bar", "file1"), "bar2", file.path("bar2", "file2"),
          paste0("../foo2"), file.path("..", "foo2", "file3"))
      )

      zip_create(tz, "xr.zip", junk_paths = TRUE)
      expect_equal(
        zip_ls("xr.zip"),
        c("file1", "bar2", file.path("bar2", "file2"), "foo2",
          file.path("foo2", "file3"))
      )
    }
  )
})

test_that("can omit directories", {
  on.exit(try(unlink(c(zipfile, tmp), recursive = TRUE)))

  dir.create(tmp <- tempfile())
  cat("first file", file = file.path(tmp, "file1"))
  cat("second file", file = file.path(tmp, "file2"))

  zipfile <- tempfile(fileext = ".zip")

  withr::with_dir(
    dirname(tmp),
    zip_create(basename(tmp), zipfile, include_dirs = FALSE)
  )

  expect_true(file.exists(zipfile))

  list <- zip_info(zipfile)
  expect_equal(
    list$filename,
    file.path(basename(tmp), c("file1", "file2"))
  )
})
