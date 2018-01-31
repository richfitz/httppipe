context("httppipe - unix")

test_that("basic use", {
  skip_on_cran()

  h <- httppipe("/var/run/docker.sock")

  path <- "/_ping"
  res <- h("GET", "/_ping")
  expect_is(res, "list")
  expect_is(res$content, "raw")
  expect_identical(res$content, charToRaw("OK"))
  expect_identical(res$status_code, 200L)
  expect_identical(res$url, "http://localhost/_ping")
  expect_is(res$headers, "raw")
  expect_silent(curl::parse_headers(res$headers))
})

test_that("post", {
  skip_on_cran()

  h <- httppipe("/var/run/docker.sock")

  nm <- "httppipe_volume"
  path <- "/v1.29/volumes/create"
  body <- charToRaw(sprintf('{"Name":"%s"}', nm))
  headers <- list("Content-Type" = "application/json")

  res <- h("POST", path, body, headers)

  expect_equal(res$status_code, 201L)
  expect_is(res$content, "raw")
  expect_is(res$headers, "raw")

  ## Need to clean up too!
  if (res$status_code == 201L) {
    path <- sprintf("/v1.29/volumes/%s", nm)
    res <- h("DELETE", path)
    expect_equal(res$status_code, 204L)
    expect_equal(res$content, raw())
  }
})

test_that("no streaming implemented", {
  skip_on_cran()

  h <- httppipe("/var/run/docker.sock")

  nm <- "httppipe_container"
  id <- system2(c("docker", "run", "--rm", "-d", "--name", nm,
                  "bfirsh/reticulate-splines"), stdout = TRUE)
  on.exit(system2(c("docker", "stop", "-t0", id),
                  wait = FALSE, stderr = FALSE, stdout = FALSE))

  path <- sprintf("/v1.29/containers/%s/logs?stdout=true&stderr=true", id)
  res <- h("GET", path)
  expect_true(as.raw(0) %in% res$content[2:7])

  expect_error(h("GET", path, stream = TRUE),
               "streaming connections not yet implemented")
})

test_that("available", {
  expect_true(httppipe_available())
})

test_that("assert_raw", {
  object <- 1
  expect_error(assert_raw(object), "'object' must be raw", fixed = TRUE)
  expect_silent(assert_raw(raw()))
})
