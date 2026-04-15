# Test fixtures and helper functions

library(labelled)
library(tibble)

#' Create a sample labelled dataset for testing
#'
#' @return A tibble with labelled variables
create_test_data <- function() {
  data <- tibble(
    admin1 = labelled(
      c(1, 1, 2, 2, 1, 2),
      c(North = 1, South = 2)
    ),
    urb_rur = labelled(
      c(1, 2, 1, 2, 1, 2),
      c(Urban = 1, Rural = 2)
    ),
    cookstove = labelled(
      c(1, 2, 3, 1, 2, 3),
      c(Wood = 1, Gas = 2, Electric = 3)
    ),
    expenditure = labelled(
      c(100, 150, 200, 120, 180, 220),
      NULL
    )
  )

  labelled::var_label(data$admin1) <- "Zone"
  labelled::var_label(data$urb_rur) <- "Settlement"
  labelled::var_label(data$cookstove) <- "Stove type"
  labelled::var_label(data$expenditure) <- "Expenditure (USD)"

  data
}
