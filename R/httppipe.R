.httppipe <- new.env(parent = emptyenv())

prepare_python <- function() {
  if (!is.null(.httppipe$python)) {
    .httppipe$python
  }
  path_py <- system.file("py", package = "httppipe", mustWork = TRUE)

  loadNamespace("reticulate")
  reticulate::py_run_string("import sys")
  reticulate::py_run_string(sprintf("sys.path.insert(1, '%s')", path_py))
  .httppipe$python <- reticulate::import("httppipe")
  .httppipe$python
}

##' Construct a httppipe connector.  This returns a function that can
##' be used to make requests over a unix socket or named pipe
##' (depending on the platform).
##'
##' @title Create a httppipe connector
##' @param path The path of the pipe or socket
##' @export
httppipe <- function(path) {
  handle <- prepare_python()$Transporter(path)

  function(method, path, body = NULL, headers = NULL, stream = NULL) {
    if (!is.null(stream)) {
      stop("streaming connections not yet implemented")
    }

    url <- paste0(handle$base_url, path)
    headers <- as.list(headers) # list required for python marshalling

    if (is.null(body)) {
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
httppipe_available <- function() {
  tryCatch(prepare_python(), error = function(e) NULL)
  !is.null(.httppipe$python)
}

assert_raw <- function(x, name = deparse(substitute(x)), what = "raw") {
  if (!is.raw(x)) {
    stop(sprintf("'%s' must be %s", name, what), call. = FALSE)
  }
  invisible(x)
}
