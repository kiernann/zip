
<!-- README.md is generated from README.Rmd. Please edit that file -->

# zippr <img src='man/figures/logo.png' align="right" height="139" />

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/zippr)](https://CRAN.R-project.org/package=zippr)
[![Codecov test
coverage](https://codecov.io/gh/kiernann/zippr/branch/master/graph/badge.svg)](https://codecov.io/gh/kiernann/zippr?branch=master)
[![R build
status](https://github.com/kiernann/zippr/workflows/R-CMD-check/badge.svg)](https://github.com/kiernann/zippr/actions)
<!-- badges: end -->

The goal of zippr is to provide an alternative to the
[zip](https://github.com/r-lib/zip) package built on
[miniz](https://github.com/richgel999/miniz), a cross-platform,
lossless, high performance data compression library. The exact
functionality of this package is still extremely fluid.

Three main types of changes are being made:

1.  Consistently rename *all* functions with `zip_*` to avoid masking
    `utils::zip()` and `utils::unzip()`.
2.  Arrange arguments in a consistent order, accepting the primary file
    paths as the first argument for easy piping.
3.  Return more data (sometimes invisibly) with
    [tibble](https://github.com/tidyverse/tibble/) and
    [fs](https://github.com/r-lib/fs/) classes.

## Installation

You can install the development version of zippr from
[GitHub](https://github.com/kiernann/zippr) with:

``` r
# install.packages("remotes")
remotes::install_github("kiernann/zippr")
```

<!-- refs: start -->
<!-- refs: end -->
