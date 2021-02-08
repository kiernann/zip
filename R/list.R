#' List Files in a 'zip' Archive
#'
#' Compared to [zip::zip_list()], archive contents here are given as a tibble
#' data frame when available (use `options(fs.use_tibble = FALSE)` to disable)
#' and columns use classes like [fs::fs_bytes()], which have numeric values in a
#' human readable format.
#'
#' @param zipfile Path to an existing ZIP file.
#' @return A tibble with 'fs' class columns.
#' @family zip/unzip functions
#' @examples
#' zip_list(zip_example())
#' @importFrom fs path_norm fs_path fs_bytes fs_perms
#' @export
zip_list <- function(zipfile) {
  zipfile <- enc2utf8(normalizePath(zipfile))
  res <- .Call(c_R_zip_list, zipfile)
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
