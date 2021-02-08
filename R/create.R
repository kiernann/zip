#' @useDynLib zippr, .registration = TRUE, .fixes = "c_"
NULL

#' Compress Files into 'zip' Archives
#'
#' `zip_create()` creates a new zip archive file.
#'
#' `zip_append()` appends compressed files to an existing 'zip' file.
#'
#' ## Relative paths
#'
#' `zip_create()` and `zip_append()` can run in two different modes: mirror
#' mode and cherry picking mode. They handle the specified `files`
#' differently.
#'
#' ### Mirror mode
#'
#' Mirror mode is for creating the zip archive of a directory structure,
#' exactly as it is on the disk. The current working directory will
#' be the root of the archive, and the paths will be fully kept.
#' zip changes the current directory to `root` before creating the
#' archive.
#'
#' (Absolute paths are also kept. Note that this might result
#' non-portable archives: some zip tools do not handle zip archives that
#' contain absolute file names, or file names that start with `../` or
#' `./`. zip warns you if this should happen.)
#'
#' E.g. consider the following directory structure:
#'
#' ``` r
#' dir.create(tmp <- tempfile())
#' oldwd <- getwd()
#' setwd(tmp)
#' dir.create("foo/bar", recursive = TRUE)
#' dir.create("foo/bar2")
#' dir.create("foo2")
#' cat("this is file1", file = "foo/bar/file1")
#' cat("this is file2", file = "foo/bar/file2")
#' cat("this is file3", file = "foo2/file3")
#' fs::dir_tree(tmp)
#' setwd(oldwd)
#' ```
#'
#' Assuming the current working directory is `foo`, the following zip
#' entries are created by `zip`:
#' ``` r
#' setwd(tmp)
#' setwd("foo")
#' zip_create("../test.zip", c("bar/file1", "bar2", "../foo2"))
#' zip_list("../test.zip")[, "filename", drop = FALSE]
#' setwd(oldwd)
#' ```
#'
#' ### Cherry picking mode
#'
#' In cherry picking mode, the selected files and directories
#' will be at the root of the archive. This mode is handy if you
#' want to select a subset of files and directories, possibly from
#' different paths and put all of the in the archive, at the top
#' level.
#'
#' Here is an example with the same directory structure as above:
#'
#' ``` r
#' setwd(tmp)
#' setwd("foo")
#' zip_create(
#'   "../test2.zip",
#'   c("bar/file1", "bar2", "../foo2"),
#'   mode = "cherry-pick"
#')
#' zip_list("../test2.zip")[, "filename", drop = FALSE]
#' setwd(oldwd)
#' ```
#'
#' ## Permissions:
#'
#' `zip_create()` (and `zip_append()`, etc.) add the permissions of the archived
#' files and directories to the ZIP archive, on Unix systems. Most zip and unzip
#' implementations support these, so they will be recovered after extracting the
#' archive.
#'
#' Note, however that the owner and group (uid and gid) are currently omitted,
#' even on Unix.
#'
#' ## `zipr()` and `zipr_append()`
#'
#' These function exist for historical reasons. They are identical to
#' `zip_create()` and `zipr_append()` with a different default for the `mode`
#' argument.
#'
#' @param zipfile The zip file to create. If the file exists, `zip` overwrites
#'   it, but `zip_append` appends to it.
#' @param files List of file to add to the archive. See details below about
#'   absolute and relative path names.
#' @param recurse Whether to add the contents of directories recursively.
#' @param compression_level A number between 1 and 9. 9 compresses best, but it
#'   also takes the longest.
#' @param include_directories Whether to explicitly include directories in the
#'   archive. Including directories might confuse MS Office when reading docx
#'   files, so set this to `FALSE` for creating them.
#' @param root Change to this working directory before creating the archive.
#' @param mode Selects how files and directories are stored in the archice. It
#'   can be `"mirror"` or `"cherry-pick"`. See "Relative Paths" below for
#'   details.
#'
#' @examples
#' ## Some files to zip up. We will run all this in the R sesion's
#' ## temporary directory, to avoid messing up the user's workspace.
#' dir.create(tmp <- tempfile())
#' dir.create(file.path(tmp, "mydir"))
#' cat("first file", file = file.path(tmp, "mydir", "file1"))
#' cat("second file", file = file.path(tmp, "mydir", "file2"))
#'
#' zipfile <- tempfile(fileext = ".zip")
#' zip_create(zipfile, "mydir", root = tmp)
#'
#' ## List contents
#' zip_list(zipfile)
#'
#' ## Add another file
#' cat("third file", file = file.path(tmp, "mydir", "file3"))
#' zip_append(zipfile, file.path("mydir", "file3"), root = tmp)
#' zip_list(zipfile)
#'
#' @return The name of the created zip file, invisibly.
#' @export
zip_create <- function(zipfile, files, recurse = TRUE, compression_level = 9,
                       include_directories = TRUE, root = ".",
                       mode = c("mirror", "cherry-pick")) {
  mode <- match.arg(mode)
  zip_internal(zipfile, files, recurse, compression_level, append = FALSE,
               root = root, keep_path = (mode == "mirror"),
               include_directories = include_directories)
}

#' @rdname zip_create
#' @export
zip_create2 <- function(zipfile, files, recurse = TRUE, compression_level = 9,
                        include_directories = TRUE, root = ".",
                        mode = c("cherry-pick", "mirror")) {
  mode <- match.arg(mode)
  zip_internal(zipfile, files, recurse, compression_level, append = FALSE,
               root = root, keep_path = (mode == "mirror"),
               include_directories = include_directories)
}

#' @rdname zip_create
#' @export
zip_append <- function(zipfile, files, recurse = TRUE,
                       compression_level = 9, include_directories = TRUE,
                       root = ".", mode = c("mirror", "cherry-pick")) {
  mode <- match.arg(mode)
  zip_internal(zipfile, files, recurse, compression_level, append = TRUE,
               root = root, keep_path = (mode == "mirror"),
               include_directories = include_directories)
}

#' @rdname zip_create
#' @export
zip_append2 <- function(zipfile, files, recurse = TRUE,
                        compression_level = 9, include_directories = TRUE,
                        root = ".", mode = c("cherry-pick", "mirror")) {
  mode <- match.arg(mode)
  zip_internal(zipfile, files, recurse, compression_level, append = TRUE,
               root = root, keep_path = (mode == "mirror"),
               include_directories = include_directories)
}

zip_internal <- function(zipfile, files, recurse, compression_level,
                         append, root, keep_path, include_directories) {
  oldwd <- setwd(root)
  on.exit(setwd(oldwd), add = TRUE)

  if (any(! file.exists(files))) stop("Some files do not exist")

  data <- get_zip_data(files, recurse, keep_path, include_directories)
  warn_for_dotdot(data$key)

  .Call(c_R_zip_zip, enc2utf8(zipfile), enc2utf8(data$key),
        enc2utf8(data$file), data$dir, file.info(data$file)$mtime,
        as.integer(compression_level), append)

  invisible(zipfile)
}
