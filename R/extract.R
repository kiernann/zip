#' Uncompress 'zip' Archives
#'
#' `zip_extract()` always restores modification times of the extracted files and
#' directories.
#'
#' @section Permissions:
#'
#' If the zip archive stores permissions and was created on Unix, the
#' permissions will be restored.
#'
#' @param zipfile Path to the zip file to uncompress.
#' @param files Character vector of files to extract from the archive.
#'   Files within directories can be specified, but they must use a forward
#'   slash as path separator, as this is what zip files use internally.
#'   If `NULL` (default), all files will be extracted.
#' @param overwrite Whether to overwrite existing files. If `FALSE` and
#'   a file already exists, then an error is thrown.
#' @param junkpaths Whether to ignore all directory paths when creating
#'   files. If `TRUE`, all files will be extracted to the top level of `exdir`.
#' @param exdir Directory to uncompress the archive to. If it does not
#'   exist, it will be created.
#'
#' @examples
#' \dontshow{.old_wd <- setwd(tempdir())}
#' library(fs)
#' dir_create("mydir")
#' cat("first file",  file = path("mydir", "file1"))
#' cat("second file", file = path("mydir", "file2"))
#'
#' z <- file_temp(ext = "zip")
#' zip_create("mydir", z)
#'
#' ## List contents
#' zip_info(z)
#'
#' ## Extract
#' tmp <- path_temp()
#' out <- zip_extract(z, exdir = tmp)
#' length(out)
#' \dontshow{setwd(.old_wd)}
#'
#' @return
#' An [fs::fs_path()] character vecttor of extracted files, invisibly.
#'
#' This is like the "internal" method of [utils::unzip()] and unlike
#' [zip::unzip()] (See r-lib/zip#35). The [zip_info()] C internal is called
#' separately to get file names, which are not yet returned from the C internal
#' used for extraction.
#' @importFrom fs dir_create path_real
#' @export
zip_extract <- function(zipfile, files = NULL, overwrite = TRUE,
                        junkpaths = FALSE, exdir = ".") {

  stopifnot(
    is_string(zipfile),
    is_character_or_null(files),
    is_flag(overwrite),
    is_flag(junkpaths),
    is_string(exdir))

  zipfile <- fs::path_real(zipfile)

  if (!is.null(files)) {
    files <- enc2utf8(files)
    files2 <- files
  } else {
    res <- .Call(c_R_zip_list, zipfile)
    files2 <- res[[1]]
  }

  exdir <- fs::path_real(fs::dir_create(exdir))

  .Call(c_R_zip_unzip, zipfile, files, overwrite, junkpaths, exdir)

  if (junkpaths) {
    files2 <- basename(files2)
  }
  invisible(fs::path(exdir, files2))
}
