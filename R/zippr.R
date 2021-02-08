#' zippr: Cross-Platform 'zip' Compression
#'
#' The zippr package is a forked alternative to the [zip] package built on
#' miniz, a cross-platform, lossless, high performance data compression library.
#'
#'
#' The zippr fork makes three types of changes:
#' 1. Consistently rename _all_ functions with `zip_*` to avoid masking the
#'    `utils::zip()` and `utils::unzip()` functions from base R.
#' 2. Arrange arguments in a consistent order, accepting the primary file paths
#'    as the first argument for easy piping.
#' 3. Return more data with modern, human readable tibble and fs classes.
#'
#' [zip]: https://github.com/r-lib/zip
#'
#'
#' @docType package
#' @name zippr
#' @useDynLib zippr, .registration = TRUE, .fixes = "c_"
NULL
