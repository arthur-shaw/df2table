test_that("construct_columns handles categorical columns", {
  source("fixtures.R", local = TRUE)
  data <- create_test_data()

  col_spec <- list(
    list(type = "categorical", var = "cookstove")
  )
  cols <- construct_columns(data, col_spec)

  expect_equal(nrow(cols), 3)
  expect_equal(cols$col_block[1], "Stove type")
  expect_equal(cols$col_level_1, c("Wood", "Gas", "Electric"))
  expect_equal(cols$col_level_2, rep(NA_character_, 3))
})

test_that("construct_columns handles numeric columns", {
  source("fixtures.R", local = TRUE)
  data <- create_test_data()

  col_spec <- list(
    list(type = "numeric", var = "expenditure", label = "Mean expenditure")
  )
  cols <- construct_columns(data, col_spec)

  expect_equal(nrow(cols), 1)
  expect_equal(cols$col_block, "Mean expenditure")
  expect_true(is.na(cols$col_level_1))
  expect_true(is.na(cols$col_level_2))
})

test_that("construct_columns combines multiple blocks", {
  source("fixtures.R", local = TRUE)
  data <- create_test_data()

  col_spec <- list(
    list(type = "categorical", var = "cookstove"),
    list(type = "numeric", var = "expenditure", label = "Mean expenditure")
  )
  cols <- construct_columns(data, col_spec)

  expect_equal(nrow(cols), 4)
  expect_equal(unique(cols$col_block), c("Stove type", "Mean expenditure"))
})

test_that("make_valid_names creates valid R identifiers", {
  x <- c("Wood", "Gas/Electric", "50% Biomass")
  result <- make_valid_names(x)

  for (name in result) {
    expect_match(name, "^[a-zA-Z_.][a-zA-Z0-9_.]*$")
  }
})
