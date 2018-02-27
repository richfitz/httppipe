## NOTE: using .stevedore for the environment here to keep in line
## with stevedore where this is used.
.stevedore <- new.env(parent = emptyenv())


## This would otherwise come from stevedore
assert_raw <- function(x, name = deparse(substitute(x)), what = "raw") {
  if (!is.raw(x)) {
    stop(sprintf("'%s' must be %s", name, what), call. = FALSE)
  }
  invisible(x)
}
