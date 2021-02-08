
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
status](https://github.com/kiernann/zippr/workflows/check-standard/badge.svg)](https://github.com/kiernann/zippr/actions)
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

## Usage

``` r
library(magrittr)
library(zippr)
library(fs)
```

### Compressing

`zip_create()` takes uncompressed files and creates a compressed ZIP
archive. Simply supply all directories and files that you want to
include in the archive. Arguments have been arranged to accept piped
paths.

It makes sense to change to the top-level directory of the files before
archiving them, so that the files are stored using a relative path name.

``` r
tmp <- dir_ls("R") %>% 
  # pipe paths into zip
  zip_create("sources.zip")
```

``` r
file_info(tmp)[, 1:5]
#> # A tibble: 1 x 5
#>   path        type         size permissions modification_time  
#>   <fs::path>  <fct> <fs::bytes> <fs::perms> <dttm>             
#> 1 sources.zip file        5.71K rw-rw-r--   2021-02-08 16:06:11
```

Directories are added recursively by default.

`zip_append()` is similar to `zip_create()`, but it appends files to an
existing ZIP archive.

### Listing

`zip_list()` lists files in a ZIP archive. It returns a tibble with
human readable [fs](https://github.com/r-lib/fs/) columns. To get just
the file *names*, use `zip_ls()`.

``` r
zip_info(tmp)
#> # A tibble: 7 x 5
#>   filename       compressed_size uncompressed_size timestamp           permissions
#>   <fs::path>         <fs::bytes>       <fs::bytes> <dttm>              <fs::perms>
#> 1 R/assertions.R             124               295 2021-02-07 03:01:44 rw-rw-r--  
#> 2 R/create.R               1.48K             3.94K 2021-02-08 20:55:36 rw-rw-r--  
#> 3 R/example.R                235               377 2021-02-08 01:53:56 rw-rw-r--  
#> 4 R/extract.R              1.05K              2.4K 2021-02-08 21:03:32 rw-rw-r--  
#> 5 R/list.R                   616             1.29K 2021-02-08 20:53:54 rw-rw-r--  
#> 6 R/utils.R                1.01K             3.32K 2021-02-07 21:32:46 rw-rw-r--  
#> 7 R/zippr.R                  440               741 2021-02-08 18:41:58 rw-rw-r--
```

### Extracting

`zip_extract()` uncompresses a ZIP archive:

``` r
out <- zip_extract(
  zipfile = tmp, 
  exdir = tempdir(), 
  junk_paths = TRUE,
)
file_info(out)[, 1:5]
#> # A tibble: 7 x 5
#>   path                         type         size permissions modification_time  
#>   <fs::path>                   <fct> <fs::bytes> <fs::perms> <dttm>             
#> 1 /tmp/RtmpcF3nL3/assertions.R file          295 rw-rw-r--   2021-02-08 16:06:11
#> 2 /tmp/RtmpcF3nL3/create.R     file        3.94K rw-rw-r--   2021-02-08 16:06:11
#> 3 /tmp/RtmpcF3nL3/example.R    file          377 rw-rw-r--   2021-02-08 16:06:11
#> 4 /tmp/RtmpcF3nL3/extract.R    file         2.4K rw-rw-r--   2021-02-08 16:06:11
#> 5 /tmp/RtmpcF3nL3/list.R       file        1.29K rw-rw-r--   2021-02-08 16:06:11
#> 6 /tmp/RtmpcF3nL3/utils.R      file        3.32K rw-rw-r--   2021-02-08 16:06:11
#> 7 /tmp/RtmpcF3nL3/zippr.R      file          741 rw-rw-r--   2021-02-08 16:06:11
```

<!-- refs: start -->
<!-- refs: end -->
