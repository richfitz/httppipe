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

test_that("available", {
  expect_true(httppipe_available())
})
