
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
    `utils::zip()` and `utils::unzip()`. Match to names like
    `fs::dir_info()`.
2.  Arrange arguments in a consistent order, accepting the primary file
    paths as the first argument for easy piping with `%>%`.
3.  Return more data (sometimes invisibly) with human-readable
    [tibble](https://github.com/tidyverse/tibble/) data frames and
    [fs](https://github.com/r-lib/fs/) class vectors.

## Installation

You can install the development version of zippr from
[GitHub](https://github.com/kiernann/zippr) with:

``` r
# install.packages("remotes")
remotes::install_github("kiernann/zippr")
```

Install the release version of zip from
[CRAN](https://cran.r-project.org/package=zip) if needed.

``` r
install.packages("zip")
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
#> 1 sources.zip file        6.25K rw-rw-r--   2021-02-08 20:22:05
```

Directories are added recursively by default.

`zip_append()` is similar to `zip_create()`, but it appends files to an
existing ZIP archive.

### Listing

`zip_info()` lists files in a ZIP archive. It returns a data frame with
human-readable [fs](https://github.com/r-lib/fs/) columns.

``` r
zip_info(tmp)
#> # A tibble: 8 x 5
#>   filename       compressed_size uncompressed_size timestamp           permissions
#>   <fs::path>         <fs::bytes>       <fs::bytes> <dttm>              <fs::perms>
#> 1 R/assertions.R             124               295 2021-02-07 03:01:44 rw-rw-r--  
#> 2 R/create.R               1.48K             3.94K 2021-02-08 20:55:36 rw-rw-r--  
#> 3 R/example.R                235               377 2021-02-08 01:53:56 rw-rw-r--  
#> 4 R/extract.R              1.06K             2.41K 2021-02-08 21:53:02 rw-rw-r--  
#> 5 R/list.R                   600             1.25K 2021-02-09 01:21:28 rw-rw-r--  
#> 6 R/size.R                   449             1.08K 2021-02-09 01:14:36 rw-rw-r--  
#> 7 R/utils.R                1.01K             3.32K 2021-02-07 21:32:46 rw-rw-r--  
#> 8 R/zippr.R                  440               741 2021-02-08 18:41:58 rw-rw-r--
```

To get just the file names, use `zip_ls()`. To get file sizes, use
`zip_size().`

``` r
zip_ls(tmp)
#> R/assertions.R R/create.R     R/example.R    R/extract.R    R/list.R       R/size.R       
#> R/utils.R      R/zippr.R
zip_size(tmp)
#> 295   3.94K 377   2.41K   1.25K   1.08K   3.32K 741
```

### Extracting

`zip_extract()` uncompresses a ZIP archive to a given directory.

``` r
out <- zip_extract(
  zipfile = tmp, 
  exdir = tempdir(), 
  junk_paths = TRUE,
)
file_info(out)[, 1:5]
#> # A tibble: 8 x 5
#>   path                         type         size permissions modification_time  
#>   <fs::path>                   <fct> <fs::bytes> <fs::perms> <dttm>             
#> 1 /tmp/Rtmpn9Cced/assertions.R file          295 rw-rw-r--   2021-02-08 20:22:05
#> 2 /tmp/Rtmpn9Cced/create.R     file        3.94K rw-rw-r--   2021-02-08 20:22:05
#> 3 /tmp/Rtmpn9Cced/example.R    file          377 rw-rw-r--   2021-02-08 20:22:05
#> 4 /tmp/Rtmpn9Cced/extract.R    file        2.41K rw-rw-r--   2021-02-08 20:22:05
#> 5 /tmp/Rtmpn9Cced/list.R       file        1.25K rw-rw-r--   2021-02-08 20:22:05
#> 6 /tmp/Rtmpn9Cced/size.R       file        1.08K rw-rw-r--   2021-02-08 20:22:05
#> 7 /tmp/Rtmpn9Cced/utils.R      file        3.32K rw-rw-r--   2021-02-08 20:22:05
#> 8 /tmp/Rtmpn9Cced/zippr.R      file          741 rw-rw-r--   2021-02-08 20:22:05
```

<!-- refs: start -->
<!-- refs: end -->
