context("httppipe - unix")

test_that("basic use", {
  skip_on_cran()

  h <- httppipe_handle("/var/run/docker.sock")
  expect_is(h, "httppipe.Transporter")

  path <- "/_ping"
  res <- httppipe_request(h, "GET", "/_ping")
  expect_is(res, "list")
  expect_is(res$content, "raw")
  expect_identical(res$content, charToRaw("OK"))
  expect_identical(res$status_code, 200L)
  expect_identical(res$url, "http://localhost/_ping")
  expect_is(res$headers, "raw")
  expect_silent(curl::parse_headers(res$headers))
})
