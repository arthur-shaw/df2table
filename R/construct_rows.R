#' Construct row structure from by_list
#'
#' @param data Data frame with labelled variables
#' @param by_list Named list defining row hierarchy
#'
#' @return Tibble with columns: group, row_label
#'
#' @importFrom labelled val_labels
#' @importFrom tibble tibble
#' @importFrom dplyr bind_rows
#'
#' @keywords internal
construct_rows <- function(data, by_list) {
  row_blocks <- lapply(seq_along(by_list), function(i) {
    group_name <- names(by_list)[i]
    var_name <- by_list[[i]]

    if (is.null(var_name)) {
      # Single row for this group
      tibble::tibble(
        group = group_name,
        row_label = group_name
      )
    } else {
      # One row per value label of var_name
      labels <- labelled::val_labels(data[[var_name]])
      tibble::tibble(
        group = group_name,
        row_label = names(labels)
      )
    }
  })

  dplyr::bind_rows(row_blocks)
}
