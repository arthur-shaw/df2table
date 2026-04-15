test_that("construct_columns handles categorical columns", {
  source(testthat::test_path("fixtures.R"), local = TRUE)
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
  source(testthat::test_path("fixtures.R"), local = TRUE)
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
  source(testthat::test_path("fixtures.R"), local = TRUE)
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

test_that("construct_columns handles numeric columns with by", {
  source(testthat::test_path("fixtures.R"), local = TRUE)
  data <- create_test_data()

  col_spec <- list(
    list(type = "numeric", var = "expenditure", label = "Mean expenditure", by = "sex")
  )
  cols <- construct_columns(data, col_spec)

  expect_equal(nrow(cols), 2)
  expect_equal(cols$col_block, c("Mean expenditure", "Mean expenditure"))
  expect_equal(cols$col_level_1, c("Male", "Female"))
  expect_equal(cols$col_level_2, rep(NA_character_, 2))
  expect_true(all(grepl("__", cols$col_id)))
})

test_that("construct_columns handles numeric columns with by and include_total", {
  source(testthat::test_path("fixtures.R"), local = TRUE)
  data <- create_test_data()

  col_spec <- list(
    list(type = "numeric", var = "expenditure", label = "Mean expenditure", by = "sex", include_total = TRUE)
  )
  cols <- construct_columns(data, col_spec)

  expect_equal(nrow(cols), 3)
  expect_equal(cols$col_level_1, c("Male", "Female", "All"))
  expect_equal(cols$col_level_2, rep(NA_character_, 3))
})

test_that("construct_columns handles categorical columns with by", {
  source(testthat::test_path("fixtures.R"), local = TRUE)
  data <- create_test_data()

  col_spec <- list(
    list(type = "categorical", var = "cookstove", by = "sex")
  )
  cols <- construct_columns(data, col_spec)

  # 3 categories (Wood, Gas, Electric) × 2 subgroups (Male, Female) = 6 rows
  expect_equal(nrow(cols), 6)
  expect_equal(cols$col_block, rep("Stove type", 6))
  expect_equal(cols$col_level_1, c(rep("Wood", 2), rep("Gas", 2), rep("Electric", 2)))
  expect_equal(cols$col_level_2, rep(c("Male", "Female"), 3))
  expect_true(all(grepl("__", cols$col_id)))
})

test_that("construct_columns handles categorical columns with by and include_total", {
  source(testthat::test_path("fixtures.R"), local = TRUE)
  data <- create_test_data()

  col_spec <- list(
    list(type = "categorical", var = "cookstove", by = "sex", include_total = TRUE)
  )
  cols <- construct_columns(data, col_spec)

  # 3 categories × 3 subgroups (Male, Female, All) = 9 rows
  expect_equal(nrow(cols), 9)
  expect_equal(cols$col_level_1, c(rep("Wood", 3), rep("Gas", 3), rep("Electric", 3)))
  expect_equal(cols$col_level_2, rep(c("Male", "Female", "All"), 3))
})

test_that("construct_columns does not create duplicate col_ids after expansion", {
  source(testthat::test_path("fixtures.R"), local = TRUE)
  data <- create_test_data()

  col_spec <- list(
    list(type = "categorical", var = "cookstove", by = "sex"),
    list(type = "numeric", var = "expenditure", label = "Mean expenditure", by = "sex")
  )
  cols <- construct_columns(data, col_spec)

  # Should have 6 (categorical) + 2 (numeric) = 8 rows total
  expect_equal(nrow(cols), 8)
  # All col_ids should be unique
  expect_equal(length(cols$col_id), length(unique(cols$col_id)))
})

test_that("construct_columns uses total_label when provided for numeric columns", {
  source(testthat::test_path("fixtures.R"), local = TRUE)
  data <- create_test_data()

  col_spec <- list(
    list(type = "numeric", var = "expenditure", label = "Mean expenditure", by = "sex", include_total = TRUE, total_label = "Overall")
  )
  cols <- construct_columns(data, col_spec)

  expect_equal(nrow(cols), 3)
  expect_equal(cols$col_level_1, c("Male", "Female", "Overall"))
})

test_that("construct_columns uses total_label when provided for categorical columns", {
  source(testthat::test_path("fixtures.R"), local = TRUE)
  data <- create_test_data()

  col_spec <- list(
    list(type = "categorical", var = "cookstove", by = "sex", include_total = TRUE, total_label = "Ensemble")
  )
  cols <- construct_columns(data, col_spec)

  # 3 categories × 3 subgroups (Male, Female, Ensemble) = 9 rows
  expect_equal(nrow(cols), 9)
  expect_equal(cols$col_level_1, c(rep("Wood", 3), rep("Gas", 3), rep("Electric", 3)))
  expect_equal(cols$col_level_2, rep(c("Male", "Female", "Ensemble"), 3))
})

test_that("construct_columns defaults to 'All' when total_label is not provided", {
  source(testthat::test_path("fixtures.R"), local = TRUE)
  data <- create_test_data()

  col_spec <- list(
    list(type = "numeric", var = "expenditure", label = "Mean expenditure", by = "sex", include_total = TRUE)
  )
  cols <- construct_columns(data, col_spec)

  expect_equal(nrow(cols), 3)
  expect_equal(cols$col_level_1, c("Male", "Female", "All"))
})
