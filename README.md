# df2table: Programmatic Survey Table Shells

Generate beautiful survey table shells from labelled data using R. Separate table structure from computation with automatic row hierarchy, column definitions, and professional styling.

## Features

- **Metadata-driven**: All labels come from `labelled` package variable and value labels
- **Structure-only shells**: Perfect for stakeholder review and comment before data computation
- **Flexible row hierarchy**: Support nested groupings (e.g., National → Zone → Sector)
- **Mixed column types**: Categorical (one column per value) and numeric summary columns
- **Multi-level headers**: Automatic column spanners from metadata
- **Two rendering engines**: Choose between `gt` and `flextable` for different use cases
- **Beautiful styling**: Configurable row striping and group header colors

## Installation

```r
# Install from local directory
devtools::install()
```

## Quick Start

```r
library(df2table)
library(labelled)

# Create sample labelled data
data <- tibble::tibble(
  zone = labelled(
    c(1, 1, 2, 2),
    c("North" = 1, "South" = 2)
  ),
  stove_type = labelled(
    c(1, 2, 3, 1),
    c("1-Wood" = 1, "Gas" = 2, "Electric" = 3)
  )
)
var_label(data$zone) <- "Zone"
var_label(data$stove_type) <- "Cookstove Type"

# Generate table shell
make_table_shell(
  data = data,
  by_list = list(
    "Country" = NULL,
    "Zone" = "zone"
  ),
  col_spec = list(
    list(type = "categorical", var = "stove_type")
  ),
  title = "Primary Cookstove Type by Zone",
  engine = "gt"
)
```

## API

### `make_table_shell()`

Main function to generate table shells.

**Arguments:**

- `data`: Data frame with labelled variables
- `by_list`: Named list defining row hierarchy
  - `NULL`: Single-row group
  - `"var_name"`: One row per value label of `var_name`
- `col_spec`: List of column specifications
  - `list(type = "categorical", var = "var_name")`
  - `list(type = "numeric", var = "var_name", label = "Display Label")`
- `title`: Optional table title
- `engine`: `"gt"` or `"flextable"` (default: `"gt"`)
- `show_group_labels`: Show group header rows (default: `TRUE`)
- `hide_first_group`: Suppress first group header (default: `FALSE`)
- `stripe_color`: Hex color for alternating rows (default: `"#dbe7f3"`)
- `group_color`: Hex color for group headers (default: `"#dbe7f3"`)

**Returns:** `gt_tbl` or `flextable` object depending on engine choice

## Design Philosophy

This package implements a **clean separation of concerns**:

- **Shell layer** (this package): Creates precise table structures from metadata
- **Computation layer** (user responsibility): Joins computed values to shell by column name

This design allows stakeholders to review and approve table structure *before* time-intensive computation and aggregation.

## Example: From Shell to Results

```r
# 1. Create shell with exact structure needed
shell <- make_table_shell(
  data = survey_data,
  by_list = list("All" = NULL, "Region" = "region"),
  col_spec = list(
    list(type = "categorical", var = "energy_source"),
    list(type = "numeric", var = "expenditure", label = "Mean (USD)")
  ),
  engine = "gt"
)

# 2. Share with stakeholders for review
print(shell)

# 3. Once approved, compute values (NOT shown here)
# means_by_region <- survey_data %>%
#   group_by(region) %>%
#   summarise(across(energy_source, list(n = n()), mean_expenditure = mean(expenditure)))

# 4. Join results to shell and render final table
# final_table <- shell %>% add_data(means_by_region)
```

## Testing

Run the included tests to verify the implementation:

```r
devtools::test()
```

Tests cover:
- Input validation (7 tests)
- Row construction (3 tests)
- Column construction (4 tests)
- Integration (7 tests)

## Requirements

- R ≥ 4.1
- **labelled**: For variable and value labels
- **dplyr**: Data manipulation
- **tidyr**: Data reshaping
- **tibble**: Modern data frames
- **gt**: HTML table rendering (if using gt engine)
- **flextable**: Office table rendering (if using flextable engine)
- **rlang**: Error handling utilities

## Limitations & Future Work

Current version:
- ✅ Single-level column subgroups not yet supported (reserved: `col_level_2`)
- ✅ Cartesian product rows not yet supported (each by_list element must be NULL or single variable)
- ✅ Column spanners (top-level grouping) not yet supported

See `dev/table_shell_spec.md` Section 10 for planned enhancements.

## License

MIT License

## Author

Implemented following the technical specification in `dev/table_shell_spec.md`.
