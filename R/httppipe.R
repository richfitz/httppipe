## NOTE: using .stevedore for the environment here to keep in line
## with stevedore where this is used.
.stevedore <- new.env(parent = emptyenv())

##' Construct a httppipe connector.  This returns a function that can
##' be used to make requests over a unix socket or named pipe
##' (depending on the platform).
##'
##' @title Create a httppipe connector
##' @param path The path of the pipe or socket
##' @export
httppipe <- function(path) {
  handle <- httppipe_prepare()$Transporter(path)

  function(method, path, body = NULL, headers = NULL, stream = NULL) {
    if (!is.null(stream)) {
      stop("streaming connections not yet implemented")
    }

    url <- paste0(handle$base_url, path)
    headers <- as.list(headers) # list required for python marshalling

    if (!is.null(body)) {
      assert_raw(body)
    }

    res <- handle$simple_request(method, url, headers, body)

    res$headers <- charToRaw(res$headers)
    if (res$is_binary) {
      res$content <- as.raw(as.integer(res$content))
    } else {
      res$content <- charToRaw(res$content)
    }
    res$is_binary <- NULL
    res
  }
}


##' Test httppipe support is available.  This tests that the python
##' module can be loaded (not that any actual server is running on a
##' socket or named pipe).  This is designed to be used in packages
##' that depend on this package as an efficient way of testing if it
##' can be used.
##' @title Test if httppipe available
##' @export
##' @param verbose Print information about failure
httppipe_available <- function(verbose = FALSE) {
  e <- tryCatch(httppipe_prepare(), error = identity)
  err <- inherits(e, "error")
  if (verbose && err) {
    message(sprintf("Failed to load httppipe with error message:\n  %s",
                    e$message))
  }
  !err
}


httppipe_prepare <- function() {
  loadNamespace("reticulate")
  if (!is.null(.stevedore$httppipe)) {
    return(.stevedore$httppipe)
  }

  path_py <- system.file("py", package = "httppipe", mustWork = TRUE)

  python_set_version("docker")
  python_update_search_path(path_py)
  .stevedore$httppipe <- reticulate::import("httppipe")
  .stevedore$httppipe
}


python_locate_version <- function(module) {
  cfg <- reticulate::py_discover_config(module)
  if (is.null(cfg$required_module_path)) {
    stop(sprintf("Did not find required python module '%s'", module),
         call. = FALSE)
  }
  cfg$python
}


python_set_version <- function(module) {
  reticulate::use_python(python_locate_version("docker"), TRUE)
}


python_update_search_path <- function(path) {
  reticulate::py_run_string("import sys")
  search <- reticulate::py_eval("sys.path")
  if (!(path %in% search)) {
    reticulate::py_run_string(sprintf("sys.path.insert(1, '%s')", path))
  }
}


## This would otherwise come from stevedore
assert_raw <- function(x, name = deparse(substitute(x)), what = "raw") {
  if (!is.raw(x)) {
    stop(sprintf("'%s' must be %s", name, what), call. = FALSE)
  }
  invisible(x)
}
