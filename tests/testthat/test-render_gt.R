test_that("sub_missing() is applied exactly once", {
  source(testthat::test_path("fixtures.R"), local = TRUE)
  data <- create_test_data()

  by_list <- list("National" = NULL)
  col_spec <- list(
    list(type = "categorical", var = "cookstove")
  )

  result <- make_table_shell(
    data = data,
    by_list = by_list,
    col_spec = col_spec,
    engine = "gt"
  )

  # sub_missing() leaves exactly one entry in _substitutions
  expect_length(result[["_substitutions"]], 1L)
})

test_that("sub_missing() covers all columns", {
  source(testthat::test_path("fixtures.R"), local = TRUE)
  data <- create_test_data()

  by_list <- list("National" = NULL)
  col_spec <- list(
    list(type = "categorical", var = "cookstove")
  )

  result <- make_table_shell(
    data = data,
    by_list = by_list,
    col_spec = col_spec,
    engine = "gt"
  )

  # sub_missing() substitution covers all columns in _data
  expected_cols <- names(result[["_data"]])
  actual_cols <- result[["_substitutions"]][[1]]$cols

  expect_setequal(actual_cols, expected_cols)
})

test_that("sub_missing() covers all rows", {
  source(testthat::test_path("fixtures.R"), local = TRUE)
  data <- create_test_data()

  by_list <- list("National" = NULL)
  col_spec <- list(
    list(type = "categorical", var = "cookstove")
  )

  result <- make_table_shell(
    data = data,
    by_list = by_list,
    col_spec = col_spec,
    engine = "gt"
  )

  # sub_missing() substitution covers all rows in _data
  expected_rows <- seq_len(nrow(result[["_data"]]))
  actual_rows <- result[["_substitutions"]][[1]]$rows

  expect_equal(actual_rows, expected_rows)
})
