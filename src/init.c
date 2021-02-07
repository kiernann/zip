
#include <R.h>
#include <Rinternals.h>
#include <stdlib.h> // for NULL
#include <R_ext/Rdynload.h>

/* .Call calls */
extern SEXP R_zip_list(SEXP);
extern SEXP R_zip_zip(SEXP, SEXP, SEXP, SEXP, SEXP, SEXP, SEXP);
extern SEXP R_zip_unzip(SEXP, SEXP, SEXP, SEXP, SEXP);
extern SEXP R_make_big_file(SEXP, SEXP);

static const R_CallMethodDef CallEntries[] = {
  { "R_zip_list",      (DL_FUNC) &R_zip_list,      1 },
  { "R_zip_zip",       (DL_FUNC) &R_zip_zip,       7 },
  { "R_zip_unzip",     (DL_FUNC) &R_zip_unzip,     5 },
  { "R_make_big_file", (DL_FUNC) &R_make_big_file, 2 },
  { NULL, NULL, 0 }
};

void R_init_zippr(DllInfo *dll) {
  R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
  R_forceSymbols(dll, TRUE);
}
