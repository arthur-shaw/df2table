#' Render table shell using gt
#'
#' @param shell Tibble with table data (group, row_label, and data columns)
#' @param col_metadata Tibble with column metadata
#' @param title Optional title character string
#' @param show_group_labels Logical; show group header rows
#' @param hide_first_group Logical; suppress first group header
#' @param stripe_color Hex color for alternating row stripes
#' @param group_color Hex color for group header rows
#'
#' @importFrom gt gt tab_header tab_spanner cols_label opt_row_striping
#' @importFrom gt tab_style cell_fill cells_body cells_row_groups tab_row_group
#' @importFrom dplyr select all_of
#'
#' @return gt_tbl object
#'
#' @keywords internal
render_gt <- function(
    shell,
    col_metadata,
    title = NULL,
    show_group_labels = TRUE,
    hide_first_group = FALSE,
    stripe_color = "#dbe7f3",
    group_color = "#dbe7f3") {

  # Select columns based on show_group_labels
  if (show_group_labels) {
    tbl <- gt::gt(shell, rowname_col = "row_label", groupname_col = "group")
  } else {
    tbl <- gt::gt(shell |> dplyr::select(-"group"), rowname_col = "row_label")
  }

  # Add title if provided
  if (!is.null(title)) {
    tbl <- gt::tab_header(tbl, title = title)
  }

  # Build column headers with spanners
  blocks <- get_blocks_in_order(col_metadata)

  for (block_name in blocks) {
    col_ids <- get_col_ids_for_block(col_metadata, block_name)

    if (has_col_level_2(col_metadata, block_name)) {
      # Block has subgroups (col_level_2) - add nested spanners
      # First, add inner spanners for each col_level_1
      level_1_values <- get_unique_level_1_for_block(col_metadata, block_name)

      for (level_1_label in level_1_values) {
        level_1_col_ids <- get_col_ids_for_level_1(col_metadata, block_name, level_1_label)
        tbl <- gt::tab_spanner(
          tbl,
          label = level_1_label,
          columns = dplyr::all_of(level_1_col_ids)
        )
      }

      # Then add outer spanner for the block
      tbl <- gt::tab_spanner(
        tbl,
        label = block_name,
        columns = dplyr::all_of(col_ids)
      )

      # Set column labels from col_level_2
      labels_list <- col_metadata |>
        dplyr::filter(.data$col_id %in% col_ids) |>
        dplyr::select(col_id, col_level_2) |>
        tibble::deframe()

      non_na_labels <- labels_list[!is.na(labels_list)]
      if (length(non_na_labels) > 0) {
        tbl <- gt::cols_label(tbl, .list = non_na_labels)
      }
    } else {
      # Block without subgroups - original behavior
      # Add spanner for this block
      tbl <- gt::tab_spanner(
        tbl,
        label = block_name,
        columns = dplyr::all_of(col_ids)
      )

      # Set individual column labels (for categorical: value labels)
      labels_list <- get_col_labels(col_metadata, col_ids)

      # Only set non-NA labels
      non_na_labels <- labels_list[!is.na(labels_list)]
      if (length(non_na_labels) > 0) {
        # non_na_labels is already a named vector: names = col_id, values = display_label
        # This is exactly what cols_label(.list = ...) expects
        tbl <- gt::cols_label(tbl, .list = non_na_labels)
      }
    }
  }

  # Apply striping to data rows
  tbl <- gt::opt_row_striping(tbl, row_striping = TRUE)

  n_data_rows <- nrow(shell)
  if (n_data_rows > 1) {
    # Stripe every other row starting from row 2
    stripe_rows <- seq(2, n_data_rows, by = 2)
    if (length(stripe_rows) > 0) {
      tbl <- gt::tab_style(
        tbl,
        style = gt::cell_fill(color = stripe_color),
        locations = gt::cells_body(rows = stripe_rows)
      )
    }
  }

  # Color group header rows
  if (show_group_labels) {
    tbl <- gt::tab_style(
      tbl,
      style = gt::cell_fill(color = group_color),
      locations = gt::cells_row_groups()
    )
  }

  # Handle hide_first_group
  if (hide_first_group && show_group_labels) {
    first_group <- unique(shell$group)[1]
    if (!is.na(first_group)) {
      tbl <- gt::tab_row_group(
        tbl,
        group = NA_character_,
        rows = which(shell$group == first_group)
      )
    }
  }

  tbl
}
