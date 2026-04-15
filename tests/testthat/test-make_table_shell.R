test_that("make_table_shell produces correct gt structure", {
  source(testthat::test_path("fixtures.R"), local = TRUE)
  data <- create_test_data()

  by_list <- list(
    "National" = NULL,
    "Zone" = "admin1"
  )
  col_spec <- list(
    list(type = "categorical", var = "cookstove")
  )

  result <- make_table_shell(
    data = data,
    by_list = by_list,
    col_spec = col_spec,
    engine = "gt"
  )

  expect_s3_class(result, "gt_tbl")
})

test_that("make_table_shell produces correct flextable structure", {
  source(testthat::test_path("fixtures.R"), local = TRUE)
  data <- create_test_data()

  by_list <- list(
    "National" = NULL,
    "Zone" = "admin1"
  )
  col_spec <- list(
    list(type = "categorical", var = "cookstove")
  )

  result <- make_table_shell(
    data = data,
    by_list = by_list,
    col_spec = col_spec,
    engine = "flextable"
  )

  expect_s3_class(result, "flextable")
})

test_that("make_table_shell with mixed column types", {
  source(testthat::test_path("fixtures.R"), local = TRUE)
  data <- create_test_data()

  by_list <- list("National" = NULL)
  col_spec <- list(
    list(type = "categorical", var = "cookstove"),
    list(type = "numeric", var = "expenditure", label = "Mean expenditure")
  )

  result <- make_table_shell(
    data = data,
    by_list = by_list,
    col_spec = col_spec,
    engine = "gt"
  )

  expect_s3_class(result, "gt_tbl")
})

test_that("make_table_shell includes title when provided", {
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
    title = "Test Title",
    engine = "gt"
  )

  expect_s3_class(result, "gt_tbl")
})

test_that("make_table_shell with show_group_labels = FALSE", {
  source(testthat::test_path("fixtures.R"), local = TRUE)
  data <- create_test_data()

  by_list <- list(
    "National" = NULL,
    "Zone" = "admin1"
  )
  col_spec <- list(
    list(type = "categorical", var = "cookstove")
  )

  result <- make_table_shell(
    data = data,
    by_list = by_list,
    col_spec = col_spec,
    show_group_labels = FALSE,
    engine = "gt"
  )

  expect_s3_class(result, "gt_tbl")
})

test_that("make_table_shell with hide_first_group = TRUE", {
  source(testthat::test_path("fixtures.R"), local = TRUE)
  data <- create_test_data()

  by_list <- list(
    "National" = NULL,
    "Zone" = "admin1"
  )
  col_spec <- list(
    list(type = "categorical", var = "cookstove")
  )

  result <- make_table_shell(
    data = data,
    by_list = by_list,
    col_spec = col_spec,
    hide_first_group = TRUE,
    engine = "gt"
  )

  expect_s3_class(result, "gt_tbl")
})
