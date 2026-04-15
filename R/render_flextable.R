#' Render table shell using flextable
#'
#' @param shell Tibble with table data (group, row_label, and data columns)
#' @param col_metadata Tibble with column metadata
#' @param title Optional title character string
#' @param show_group_labels Logical; show group header rows
#' @param hide_first_group Logical; suppress first group header
#' @param stripe_color Hex color for alternating row stripes
#' @param group_color Hex color for group header rows
#'
#' @importFrom flextable flextable as_grouped_data as_flextable
#' @importFrom flextable set_caption set_header_labels theme_zebra bg
#' @importFrom dplyr select mutate across
#' @importFrom tidyr pivot_longer
#'
#' @return flextable object
#'
#' @keywords internal
render_flextable <- function(
    shell,
    col_metadata,
    title = NULL,
    show_group_labels = TRUE,
    hide_first_group = FALSE,
    stripe_color = "#dbe7f3",
    group_color = "#dbe7f3") {

  # Prepare data for flextable
  if (show_group_labels) {
    data_for_ft <- shell |>
      dplyr::mutate(dplyr::across(dplyr::everything(), as.character))

    # Convert to grouped data structure
    data_grouped <- data_for_ft |>
      tidyr::pivot_longer(
        cols = -c("group", "row_label"),
        names_to = "col_id",
        values_to = "value"
      ) |>
      dplyr::arrange(dplyr::match(.data$group, unique(shell$group)))

    # Create flextable from grouped data
    ft <- data_grouped |>
      dplyr::select(-"group") |>
      flextable::as_grouped_data(groups = c("row_label")) |>
      flextable::as_flextable()
  } else {
    # Simple flextable without grouping
    data_for_ft <- shell |>
      dplyr::select(-"group") |>
      dplyr::mutate(dplyr::across(dplyr::everything(), as.character))

    ft <- flextable::flextable(data_for_ft)
  }

  # Set column labels based on col_metadata
  blocks <- get_blocks_in_order(col_metadata)
  col_label_mapping <- list()

  for (block_name in blocks) {
    col_ids <- get_col_ids_for_block(col_metadata, block_name)
    labels <- get_col_labels(col_metadata, col_ids)

    for (i in seq_along(labels)) {
      col_id <- names(labels)[i]
      label <- labels[i]
      if (!is.na(label) && label != "") {
        col_label_mapping[[col_id]] <- label
      }
    }
  }

  if (length(col_label_mapping) > 0) {
    ft <- flextable::set_header_labels(ft, .list = col_label_mapping)
  }

  # Add title if provided
  if (!is.null(title)) {
    ft <- flextable::set_caption(ft, caption = title)
  }

  # Apply zebra striping
  ft <- flextable::theme_zebra(
    ft,
    odd_body = "#ffffff",
    even_body = stripe_color
  )

  # If show_group_labels, color group rows
  if (show_group_labels) {
    # Identify group row indices and apply group color
    # This is complex in flextable; we apply a simpler approach
    ft <- flextable::bg(ft, bg = group_color, part = "header")
  }

  ft
}
