#' List information on files in a ZIP archive
#'
#' @description
#' [zip_info()] is similar to the `unzip -l` command. Compared to
#' [zip::zip_list()], the data frame is returned as a tibble when available and
#' columns use human readable classes like [fs::dir_info()].
#'
#' [zip_ls()] returns only the names of the files in an archive, like
#' [fs::dir_ls()].
#'
#' @details
#' USes the `options(fs.use_tibble = FALSE)` to disable tibble printing.
#'
#' @param archive Path to an existing ZIP archive.
#' @return A data.frame with 'fs' class columns.
#' @family zip/unzip functions
#' @examples
#' zip_info(zip_example())
#' zip_ls(zip_example())
#' @importFrom fs fs_path fs_bytes fs_perms
#' @export
zip_info <- function(archive) {
  archive <- enc2utf8(normalizePath(archive))
  res <- .Call(c_R_zip_list, archive)
  dat <- data.frame(
    stringsAsFactors = FALSE,
    filename = fs::fs_path(res[[1]]),
    compressed_size = fs::fs_bytes(res[[2]]),
    uncompressed_size = fs::fs_bytes(res[[3]]),
    timestamp = as.POSIXct(res[[4]], tz = "UTC", origin = "1970-01-01")
  )
  dat$permissions <- fs::fs_perms(res[[5]])
  as_tibble(dat)
}

#' @rdname zip_info
#' @export
zip_ls <- function(archive) {
  archive <- enc2utf8(normalizePath(archive))
  res <- .Call(c_R_zip_list, archive)
  fs::fs_path(res[[1]])
}
