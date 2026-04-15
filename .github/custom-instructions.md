## Core conventions

- **Match the project’s style.** If the file shows a preference (tidyverse vs. base R, `%>%` vs. `|>`), follow it.
- **Prefer clear, vectorized code.** Keep functions small and avoid hidden side effects.
- **Qualify functions for both base and non-base packages**, e.g., `dplyr::mutate()`, `stringr::str_detect()`.

## Pipe Operators

- Native pipe |> (R ≥ 4.1.0): Prefer in R ≥ 4.1 (no extra dependency).
- Magrittr pipe %>%: Continue using in projects already committed to magrittr or when you need features like ., %T>%, or %$%.
- Be consistent: Don't mix |> and %>% within the same script unless there's a clear technical reason.

## Comments

- Prefer comments that say why something is done that what something is doing
- Make sure to provide comments when the approach is novel, the implementation is non-conventional, and/or the code relies on usage of poorly documented base functions or "off-label" uses of functions (i.e. that aren't explained clearly in the documentation)

## Performance considerations

- For large data sets, prefer `tidytable`
- Otherwise, prefer dplyr and tidyverse or tidyverse-adjacent packages for expressive code
