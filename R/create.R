#' Compress files into ZIP archives
#'
#' Compared to [zip::zip()] and [utils::zip()], [zip_create()] takes the path of
#' files to include in the archive as the first argument. Append new compressed
#' files to an existing archive with [zip_append()].
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
#' `zip_create()` (and `zip_append()`) add the permissions of the archived files
#' and directories to the ZIP archive, on Unix systems. Most zip and unzip
#' implementations support these, so they will be recovered after extracting the
#' archive. Note, however that the owner and group (uid and gid) are currently
#' omitted, even on Unix.
#'
#' @param path Character vector of files to add to the archive.
#' @param archive The ZIP file path to create. If the file exists,
#'   [zip_create()] overwrites it, but [zip_append()] appends to it.
#' @param recurse Whether to add the contents of directories recursively.
#' @param level Integer between 1 and 9. Higher compression takes longer.
#' @param junk_paths Whether to remove full file path. See "Relative paths"
#'   below for more. An alternative to the `mode` argument of [zip::zip()].
#' @param include_dirs Whether to explicitly include directories in the archive.
#' @param root Directory to temporarily change to before creating archive.
#'
#' @examples
#' \dontshow{.old_wd <- setwd(tempdir())}
#' library(fs)
#' dir_create(path("mydir"))
#' cat("first file", file = path("mydir", "file1"))
#' cat("second file", file = path("mydir", "file2"))
#'
#' z <- file_temp(ext = "zip")
#' zip_create("mydir", z)
#'
#' ## List contents
#' zip_info(z)
#'
#' ## Add another file
#' cat("third file", file = path("mydir", "file3"))
#' zip_append(path("mydir", "file3"), z)
#' zip_info(z)
#' \dontshow{setwd(.old_wd)}
#'
#' @return The name of the created ZIP archive, invisibly.
#' @importFrom fs fs_path
#' @export
zip_create <- function(path, archive, recurse = TRUE, level = 9,
                       junk_paths = FALSE, include_dirs = TRUE, root = ".") {
  zip_internal(path, archive, recurse, level, append = FALSE,
               root = root, junk_paths = junk_paths,
               include_dirs = include_dirs)
}

#' @rdname zip_create
#' @export
zip_append <- function(path, archive, recurse = TRUE, level = 9,
                       junk_paths = FALSE, include_dirs = TRUE, root = ".") {
  zip_internal(path, archive, recurse, level, append = TRUE,
               root = root, junk_paths = junk_paths,
               include_dirs = include_dirs)
}

zip_internal <- function(path, archive, recurse, level, append, root,
                         junk_paths, include_dirs) {
  oldwd <- setwd(root)
  on.exit(setwd(oldwd), add = TRUE)

  if (any(!file.exists(path))) {
    stop("Some files do not exist", call. = FALSE)
  }

  data <- get_zip_data(
    files = path,
    recurse = recurse,
    keep_path = !junk_paths,
    include_directories = include_dirs
  )
  warn_for_dotdot(data$key)

  .Call(c_R_zip_zip, enc2utf8(archive), enc2utf8(data$key),
        enc2utf8(data$file), data$dir, file.info(data$file)$mtime,
        as.integer(level), append)

  invisible(fs::fs_path(archive))
}
