#' Compress Files into 'zip' Archives
#'
#' `zip_create()` creates a new zip archive file.
#'
#' `zip_append()` appends compressed files to an existing 'zip' file.
#'
#' ## Relative paths
#'
#' `zip_create()` and `zip_append()` both use the `junk_paths` argument in lieu
#' of the `mode` argument from [zip::zip()].
#'
#' When `junk_paths` is set to `FALSE` (the default), the directory structure of
#' included files is preserved; the working directory will temporarily be
#' changed to the `root` argument before creating the archive.
#'
#' (Absolute paths are also kept. Note that this might result non-portable
#' archives: some zip tools do not handle ZIP archives that contain absolute
#' file names, or file names that start with `../` or `./`. zippr warns you if
#' this should happen.)
#'
#' When `junk_paths` is set to `TRUE`, the selected files and directories will
#' be at the root of the archive. This mode is handy if you want to select a
#' subset of files and directories, possibly from different paths and put all of
#' the in the archive, at the top level.
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
