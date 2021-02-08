#' Get path to zippr example
#'
#' zippr comes bundled with a sample archive in its `inst/extdata` directory.
#' This function make it easy to access.
#'
#' @examples
#' zip_example()
#' @importFrom fs fs_path
#' @export
zip_example <- function() {
  zipfile <- system.file(
    "extdata", "example.zip",
    package = "zippr",
    mustWork = TRUE
  )
  fs::fs_path(zipfile)
}
