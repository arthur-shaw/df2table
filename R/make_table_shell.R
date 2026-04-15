#' Generate a Programmatic Survey Table Shell
#'
#' Constructs an empty table structure (shell) with correct labels, groupings, and
#' column headers from labelled data. The shell contains no computed values, making it
#' suitable for sharing with stakeholders for review.
#'
#' @param data A data frame containing labelled variables (via the `labelled` package).
#'   Only metadata (variable labels and value labels) is used.
#' @param by_list A named list defining row structure. Each element represents a row block:
#'   - `NULL`: creates a single row with label from the element name
#'   - `"var_name"`: creates one row per value label of `var_name`
#'   - All other formats (vectors, etc.) produce an informative error.
#' @param col_spec A list of column block specifications. Each element is a list with:
#'   - `type`: `"categorical"` or `"numeric"`
#'   - `var`: variable name in data
#'   - `label`: (numeric only) display label for the column
#' @param title Optional character string for table title.
#' @param engine `"gt"` or `"flextable"` (default: `gt`). Controls output table class.
#' @param show_group_labels Logical (default `FALSE`). Show group header rows.
#' @param hide_first_group Logical (default `FALSE`). Suppress header row for first group.
#' @param stripe_color Hex color for alternating row stripes (default: `"#dbe7f3"`).
#' @param group_color Hex color for group header rows (default: `"#dbe7f3"`).
#'
#' @return
#' - If `engine = "gt"`: a `gt_tbl` object
#' - If `engine = "flextable"`: a `flextable` object
#'
#' @examples
#' \dontrun{
#' # Create sample labelled data
#' library(labelled)
#' data <- tibble::tibble(
#'   admin1 = labelled(
#'     c(1, 2, 1, 2),
#'     c(North = 1, South = 2)
#'   ),
#'   urb_rur = labelled(
#'     c(1, 1, 2, 2),
#'     c(Urban = 1, Rural = 2)
#'   ),
#'   cookstove_type = labelled(
#'     c(1, 2, 1, 3),
#'     c(Wood = 1, Gas = 2, Electric = 3)
#'   )
#' )
#' var_label(data$admin1) <- "Zone"
#' var_label(data$urb_rur) <- "Settlement"
#' var_label(data$cookstove_type) <- "Cookstove type"
#'
#' # Create table shell
#' make_table_shell(
#'   data = data,
#'   by_list = list(
#'     "Nigeria" = NULL,
#'     "Zone" = "admin1"
#'   ),
#'   col_spec = list(
#'     list(type = "categorical", var = "cookstove_type")
#'   ),
#'   title = "Primary cookstove type by zone",
#'   engine = "gt"
#' )
#' }
#'
#' @importFrom rlang arg_match
#'
#' @export
make_table_shell <- function(
  data,
  by_list,
  col_spec,
  title = NULL,
  engine = c("gt", "flextable"),
  show_group_labels = FALSE,
  hide_first_group = FALSE,
  stripe_color = "#dbe7f3",
  group_color = "#dbe7f3")
{

  engine <- rlang::arg_match(engine)

  # Validate inputs
  validate_inputs(data, by_list, col_spec)

  # Construct rows
  rows_tbl <- construct_rows(data, by_list)

  # Construct column metadata
  col_metadata <- construct_columns(data, col_spec)

  # Build shell tibble
  shell <- add_na_columns(rows_tbl, col_metadata)

  # Render based on engine choice
  if (engine == "gt") {
    render_gt(
      shell = shell,
      col_metadata = col_metadata,
      title = title,
      show_group_labels = show_group_labels,
      hide_first_group = hide_first_group,
      stripe_color = stripe_color,
      group_color = group_color
    )
  } else {
    render_flextable(
      shell = shell,
      col_metadata = col_metadata,
      title = title,
      show_group_labels = show_group_labels,
      hide_first_group = hide_first_group,
      stripe_color = stripe_color,
      group_color = group_color
    )
  }

}
