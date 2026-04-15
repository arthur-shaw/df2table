#' Validate inputs to make_table_shell
#'
#' @param data Data frame to validate
#' @param by_list Named list for row structure
#' @param col_spec List of column specifications
#'
#' @importFrom rlang abort warn
#' @importFrom labelled val_labels
#'
#' @keywords internal
validate_inputs <- function(data, by_list, col_spec) {
  # Validate data
  if (!is.data.frame(data)) {
    rlang::abort("`data` must be a data frame.")
  }

  # Validate by_list
  if (!is.list(by_list) || is.null(names(by_list))) {
    rlang::abort("`by_list` must be a named list.")
  }

  for (i in seq_along(by_list)) {
    val <- by_list[[i]]
    elem_name <- names(by_list)[i]

    if (!is.null(val) && !is.character(val)) {
      rlang::abort(
        paste0(
          "by_list element '", elem_name, "' must be NULL or a character string (variable name)."
        )
      )
    }

    if (is.character(val) && length(val) > 1) {
      rlang::abort(
        paste0(
          "Cartesian product rows (vector by_list values) are not supported. ",
          "Each element must be NULL or a single variable name. ",
          "Element '", elem_name, "' has ", length(val), " values."
        )
      )
    }

    # Check variable exists if specified
    if (is.character(val) && !(val %in% names(data))) {
      rlang::abort(
        paste0("Variable '", val, "' specified in by_list not found in data.")
      )
    }

    # Check has value labels if specified
    if (is.character(val)) {
      labels <- labelled::val_labels(data[[val]])
      if (is.null(labels) || length(labels) == 0) {
        rlang::abort(
          paste0(
            "Variable '", val, "' in by_list has no value labels. ",
            "All by_list variables must be labelled."
          )
        )
      }
    }
  }

  # Validate col_spec
  if (!is.list(col_spec)) {
    rlang::abort("`col_spec` must be a list.")
  }

  for (i in seq_along(col_spec)) {
    spec <- col_spec[[i]]

    if (!is.list(spec)) {
      rlang::abort(paste0("Each element of col_spec must be a list. Element ", i, " is not."))
    }

    if (!("type" %in% names(spec))) {
      rlang::abort(paste0("Column spec element ", i, " is missing 'type' field."))
    }

    if (!(spec$type %in% c("categorical", "numeric"))) {
      rlang::abort(
        paste0(
          "Column spec element ", i, " has invalid type '", spec$type,
          "'. Must be 'categorical' or 'numeric'."
        )
      )
    }

    if (!("var" %in% names(spec))) {
      rlang::abort(paste0("Column spec element ", i, " is missing 'var' field."))
    }

    if (!(spec$var %in% names(data))) {
      rlang::abort(
        paste0(
          "Column spec element ", i, ": variable '", spec$var, "' not found in data."
        )
      )
    }

    # Validate 'by' field if specified
    if (!is.null(spec$by)) {
      if (!is.character(spec$by) || length(spec$by) != 1) {
        rlang::abort(
          paste0(
            "Column spec element ", i, ": 'by' field must be a single character string (variable name)."
          )
        )
      }

      if (!(spec$by %in% names(data))) {
        rlang::abort(
          paste0(
            "Column spec element ", i, ": variable '", spec$by,
            "' specified in 'by' field not found in data."
          )
        )
      }

      by_labels <- labelled::val_labels(data[[spec$by]])
      if (is.null(by_labels) || length(by_labels) == 0) {
        rlang::abort(
          paste0(
            "Column spec element ", i, ": variable '", spec$by,
            "' in 'by' field has no value labels. The 'by' variable must be labelled."
          )
        )
      }
    }

    if (spec$type == "categorical") {
      labels <- labelled::val_labels(data[[spec$var]])
      if (is.null(labels) || length(labels) == 0) {
        rlang::abort(
          paste0(
            "Column spec element ", i, ": variable '", spec$var,
            "' has no value labels. Categorical columns require labelled variables."
          )
        )
      }
    }

    if (spec$type == "numeric") {
      if (!("label" %in% names(spec))) {
        rlang::abort(
          paste0(
            "Column spec element ", i, ": numeric column block requires 'label' argument."
          )
        )
      }
    }
    # Validate total_label field if specified
    if (!is.null(spec$total_label)) {
      # Check that total_label is a single non-empty character string
      if (!is.character(spec$total_label) || length(spec$total_label) != 1 || nchar(spec$total_label) == 0) {
        rlang::abort(
          paste0(
            "Column spec element ", i, ": 'total_label' must be a single non-empty character string."
          )
        )
      }

      # Warn if total_label is provided without include_total = TRUE
      if (is.null(spec$include_total) || !spec$include_total) {
        rlang::warn(
          paste0(
            "Column spec element ", i, ": 'total_label' provided but 'include_total' is not TRUE. ",
            "The label will be ignored."
          )
        )
      }
    }
  }

  invisible(TRUE)
}
