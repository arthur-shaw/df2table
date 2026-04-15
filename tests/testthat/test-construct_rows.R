test_that("construct_rows creates single row for NULL", {
  source(testthat::test_path("fixtures.R"), local = TRUE)
  data <- create_test_data()

  by_list <- list("National" = NULL)
  rows <- construct_rows(data, by_list)

  expect_equal(nrow(rows), 1)
  expect_equal(rows$group[1], "National")
  expect_equal(rows$row_label[1], "National")
})

test_that("construct_rows creates multiple rows from value labels", {
  source(testthat::test_path("fixtures.R"), local = TRUE)
  data <- create_test_data()

  by_list <- list("Zone" = "admin1")
  rows <- construct_rows(data, by_list)

  expect_equal(nrow(rows), 2)
  expect_equal(rows$group, c("Zone", "Zone"))
  expect_equal(rows$row_label, c("North", "South"))
})

test_that("construct_rows combines multiple blocks correctly", {
  source(testthat::test_path("fixtures.R"), local = TRUE)
  data <- create_test_data()

  by_list <- list(
    "National" = NULL,
    "Zone" = "admin1"
  )
  rows <- construct_rows(data, by_list)

  expect_equal(nrow(rows), 3)
  expect_equal(rows$group[1], "National")
  expect_equal(rows$group[2:3], c("Zone", "Zone"))
  expect_equal(rows$row_label[1], "National")
  expect_equal(rows$row_label[2:3], c("North", "South"))
})
