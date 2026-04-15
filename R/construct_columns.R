#' Construct column metadata from col_spec
#'
#' @param data Data frame with labelled variables
#' @param col_spec List of column specifications
#'
#' @return Tibble with columns: col_block, col_level_1, col_level_2, col_id
#'
#' @importFrom labelled val_labels var_label
#' @importFrom tibble tibble
#' @importFrom dplyr bind_rows
#' @importFrom rlang warn
#'
#' @keywords internal
construct_columns <- function(data, col_spec) {
  col_blocks <- lapply(seq_along(col_spec), function(i) {
    spec <- col_spec[[i]]
    var_name <- spec$var

    if (spec$type == "categorical") {
      col_block <- labelled::var_label(data[[var_name]])
      if (is.null(col_block)) col_block <- var_name

      labels <- labelled::val_labels(data[[var_name]])
      label_names <- names(labels)

      col_ids <- make_valid_names(label_names)

      # Check for duplicates and add suffixes if needed
      duplicates <- duplicated(col_ids)
      if (any(duplicates)) {
        for (j in which(duplicates)) {
          suffix <- 1
          new_id <- paste0(col_ids[j], "_", suffix)
          while (new_id %in% col_ids) {
            suffix <- suffix + 1
            new_id <- paste0(col_ids[j], "_", suffix)
          }
          col_ids[j] <- new_id
        }
      }

      tibble::tibble(
        col_block = col_block,
        col_level_1 = label_names,
        col_level_2 = NA_character_,
        col_id = col_ids
      )
    } else {
      # Numeric column
      col_block <- spec$label
      col_id <- make_valid_names(col_block)[1]

      tibble::tibble(
        col_block = col_block,
        col_level_1 = NA_character_,
        col_level_2 = NA_character_,
        col_id = col_id
      )
    }
  })

  col_metadata <- dplyr::bind_rows(col_blocks)

  # Check for duplicate col_ids globally and warn
  if (anyDuplicated(col_metadata$col_id)) {
    dup_ids <- col_metadata$col_id[duplicated(col_metadata$col_id)]
    rlang::warn(
      paste0(
        "Duplicate col_id values detected: ",
        paste(unique(dup_ids), collapse = ", "),
        ". Consider providing more specific labels."
      )
    )
  }

  col_metadata
}

#' Convert character vector to valid R names
#'
#' @param x Character vector
#'
#' @return Character vector of valid R names
#'
#' @keywords internal
make_valid_names <- function(x) {
  # Use make.names but handle edge cases
  names <- make.names(x, unique = FALSE)
  names
}
