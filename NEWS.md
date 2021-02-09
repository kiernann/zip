# zippr (development version)

* Change package name from 'zip' to 'zippr'.

* Remove `zip_process()` and `unzip_process()` for simplicity.

* Remove `zipr()` and `zipr_append()`. Use a `keep_paths` logical argument
  instead of the character `mode` argument.

* Rename `zip()` to `zip_create()`. Rename arguments and move paths to first.

* Rename `unzip()` to `zip_extract()`. Return the extracted file paths.

* Rename `zip_list()` to `zip_info()` and add `zip_ls()` for file names.

* Add `zip_size()` and `zip_ratio()`.
