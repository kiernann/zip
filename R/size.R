#' Compressed file sizes and ratios
#'
#' @description
#'
#' `zip_size()` returns the uncompressed size of files within an archive.
#'
#' `zip_ratio()` returns the division of uncompressed size by compressed size.
#'
#' @param archive Path to an existing ZIP archive.
#' @param sum Whether to return a single size or ratio from the sum of sizes.
#' @return A named numeric vector of compression ratios or file sizes.
#' @examples
#' zip_size(zip_example())
#' zip_ratio(zip_example(), sum = TRUE)
#' @importFrom fs fs_bytes
#' @importFrom stats setNames
#' @export
zip_size <- function(archive, sum = FALSE) {
  archive <- enc2utf8(normalizePath(archive))
  res <- .Call(c_R_zip_list, archive)
  if (sum) {
    fs::fs_bytes(sum(res[[3]]))
  } else {
    fs::fs_bytes(res[[3]])
  }
}

#' @rdname zip_size
#' @export
zip_ratio <- function(archive, sum = FALSE) {
  archive <- enc2utf8(normalizePath(archive))
  res <- .Call(c_R_zip_list, archive)
  if (sum) {
    setNames(
      object = sum(res[[3]]) / sum(res[[2]]),
      nm = archive
    )
  } else {
    setNames(
      object = res[[3]] / res[[2]],
      nm = res[[1]]
    )
  }
}
