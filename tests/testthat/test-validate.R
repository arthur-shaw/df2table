test_that("validate_inputs rejects non-data-frame data", {
  expect_error(
    validate_inputs(list(1, 2, 3), list(), list()),
    "must be a data frame"
  )
})

test_that("validate_inputs rejects unnamed by_list", {
  source("fixtures.R", local = TRUE)
  data <- create_test_data()

  expect_error(
    validate_inputs(data, list(NULL), list()),
    "must be a named list"
  )
})

test_that("validate_inputs rejects vector elements in by_list", {
  source("fixtures.R", local = TRUE)
  data <- create_test_data()

  by_list <- list("Region" = c("admin1", "urb_rur"))

  expect_error(
    validate_inputs(data, by_list, list()),
    "not supported"
  )
})

test_that("validate_inputs rejects missing variables in by_list", {
  source("fixtures.R", local = TRUE)
  data <- create_test_data()

  by_list <- list("Region" = "nonexistent_var")

  expect_error(
    validate_inputs(data, by_list, list()),
    "not found in data"
  )
})

test_that("validate_inputs rejects categorical column without labels", {
  source("fixtures.R", local = TRUE)
  data <- create_test_data()
  # Create data with unlabelled variable
  data$unlabelled_var <- c(1, 2, 3, 1, 2, 3)

  col_spec <- list(
    list(type = "categorical", var = "unlabelled_var")
  )

  expect_error(
    validate_inputs(data, list("National" = NULL), col_spec),
    "no value labels"
  )
})

test_that("validate_inputs rejects numeric column without label", {
  source("fixtures.R", local = TRUE)
  data <- create_test_data()

  col_spec <- list(
    list(type = "numeric", var = "expenditure")
  )

  expect_error(
    validate_inputs(data, list("National" = NULL), col_spec),
    "requires 'label'"
  )
})

test_that("validate_inputs accepts valid inputs", {
  source("fixtures.R", local = TRUE)
  data <- create_test_data()

  by_list <- list(
    "National" = NULL,
    "Zone" = "admin1"
  )
  col_spec <- list(
    list(type = "categorical", var = "cookstove"),
    list(type = "numeric", var = "expenditure", label = "Mean")
  )

  expect_silent(validate_inputs(data, by_list, col_spec))
})
