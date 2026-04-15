# quiet R CMD warnings notes about no visible global bindings
# for bare column names that, per tidyselect, should not have a `.data` prefix
# where tidyselect expressions are expected
utils::globalVariables(c("col_id", "col_level_1", "col_level_2"))
#' Add NA columns to row tibble
#'
#' @param rows_tbl Tibble with group and row_label columns
#' @param col_metadata tibble with col_id column
#'
#' @return Tibble with rows, row labels, and NA columns for each col_id
#'
#' @importFrom dplyr select all_of
#'
#' @keywords internal
add_na_columns <- function(rows_tbl, col_metadata) {
  col_ids <- unique(col_metadata$col_id)

  for (col_id in col_ids) {
    rows_tbl[[col_id]] <- NA_character_
  }

  # Reorder columns: group, row_label, then col_ids in order
  col_order <- c("group", "row_label", col_ids)
  rows_tbl <- dplyr::select(rows_tbl, dplyr::all_of(col_order))

  rows_tbl
}

#' Get column block structure
#'
#' Returns information about column blocks (spanners) and their columns.
#'
#' @param col_metadata Tibble with column metadata
#'
#' @return List with structure: list(blocks = list(block_name = list(label_1 = col_id, ...)), ...)
#'
#' @keywords internal
get_col_block_structure <- function(col_metadata) {
  blocks <- list()

  for (i in seq_len(nrow(col_metadata))) {
    row <- col_metadata[i, ]
    block_name <- row$col_block
    level_1 <- row$col_level_1
    col_id <- row$col_id

    if (is.na(block_name) || block_name == "") {
      block_name <- "NA"
    }

    if (!(block_name %in% names(blocks))) {
      blocks[[block_name]] <- list()
    }

    if (is.na(level_1)) {
      level_1 <- ""
    }

    blocks[[block_name]][[col_id]] <- list(
      label = level_1,
      col_id = col_id
    )
  }

  blocks
}

#' Get unique blocks in order
#'
#' @param col_metadata Tibble with column metadata
#'
#' @return Character vector of unique col_block values in order of appearance
#'
#' @keywords internal
get_blocks_in_order <- function(col_metadata) {
  unique(col_metadata$col_block)
}

#' Get column IDs for a block
#'
#' @param col_metadata Tibble with column metadata
#' @param block_name Character string for block name
#'
#' @return Character vector of col_ids
#'
#' @importFrom dplyr filter pull
#'
#' @keywords internal
get_col_ids_for_block <- function(col_metadata, block_name) {
  col_metadata |>
    dplyr::filter(.data$col_block == block_name) |>
    dplyr::pull(.data$col_id)
}

#' Get column labels for a set of col_ids
#'
#' @param col_metadata Tibble with column metadata
#' @param col_ids Character vector of col_ids
#'
#' @return Named character vector with col_id = label
#'
#' @importFrom dplyr filter select
#' @importFrom tibble deframe
#'
#' @keywords internal
get_col_labels <- function(col_metadata, col_ids) {
  labels <- col_metadata |>
    dplyr::filter(.data$col_id %in% col_ids) |>
    dplyr::select(col_id, col_level_1) |>
    tibble::deframe()

  labels
}

#' Check if a block has subgroups (col_level_2)
#'
#' @param col_metadata Tibble with column metadata
#' @param block_name Character string for block name
#'
#' @return Logical; TRUE if the block has any non-NA col_level_2 values
#'
#' @importFrom dplyr filter
#'
#' @keywords internal
has_col_level_2 <- function(col_metadata, block_name) {
  block_rows <- col_metadata |>
    dplyr::filter(.data$col_block == block_name)
  any(!is.na(block_rows$col_level_2))
}

#' Get column IDs for a specific col_level_1 within a block
#'
#' @param col_metadata Tibble with column metadata
#' @param block_name Character string for block name
#' @param level_1_label Character string for col_level_1 value
#'
#' @return Character vector of col_ids
#'
#' @importFrom dplyr filter pull
#'
#' @keywords internal
get_col_ids_for_level_1 <- function(col_metadata, block_name, level_1_label) {
  col_metadata |>
    dplyr::filter(
      .data$col_block == block_name,
      .data$col_level_1 == level_1_label
    ) |>
    dplyr::pull(.data$col_id)
}

#' Get unique col_level_1 values for a block
#'
#' @param col_metadata Tibble with column metadata
#' @param block_name Character string for block name
#'
#' @return Character vector of unique non-NA col_level_1 values in order of appearance
#'
#' @importFrom dplyr filter pull
#'
#' @keywords internal
get_unique_level_1_for_block <- function(col_metadata, block_name) {
  col_metadata |>
    dplyr::filter(
      .data$col_block == block_name,
      !is.na(.data$col_level_1)
    ) |>
    dplyr::pull(.data$col_level_1) |>
    unique()
}
