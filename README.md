
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ukcensus

<!-- badges: start -->
<!-- badges: end -->

ukcensus is an R package designed to simplify the retrieval of Census
2021 data from England and Wales. It allows you to create custom
datasets of the census, outputting them to tibble format.

## Installation

You can install the development version of ukcensus using the `devtools`
package:

``` r
# Install devtools if not already installed
if (!require(devtools)) {
  install.packages("devtools")
}

# Install ukcensus from GitHub
devtools::install_github("dataknit/ukcensus")
```

## Usage

ukcensus is built around the `create_custom_dataset()` function. For
example, to create a dataset of the age of all usual residents by MSOA,
you could write:

``` r
library(ukcensus)
create_custom_dataset("msoa", "resident_age_6a") |>
  head()
#> 7264 out of 7264 areas available
#> # A tibble: 6 × 3
#>   msoa               resident_age_6a             n
#>   <chr>              <chr>                   <int>
#> 1 City of London 001 Aged 15 years and under   579
#> 2 City of London 001 Aged 16 to 24 years      1149
#> 3 City of London 001 Aged 25 to 34 years      2215
#> 4 City of London 001 Aged 35 to 49 years      1817
#> 5 City of London 001 Aged 50 to 64 years      1617
#> 6 City of London 001 Aged 65 years and over   1206
```

But how do we know what to put into this query? That’s where the
`get_available_` set of functions come in handy. You can use them to get
available:

- populations: (e.g. households and usual residents)
- area types: the level of geographic specificity (e.g. country, Local
  Authority and LSOA)
- areas: what areas are available for a given area type
- variables: what sociodemographic variables (e.g. age, English language
  proficiency, disability status) data is available for
- categorisations: given a variable, how to divide the values of it
  (e.g. age into 101 categories or 2)

Each function outputs the available options as a tibble.

``` r
get_available_variables()
#> # A tibble: 44 × 5
#>    id                       label description total_count quality_statement_text
#>    <chr>                    <chr> <chr>             <int> <chr>                 
#>  1 activity_last_week       Econ… "This vari…           8 "As Census 2021 was d…
#>  2 age_arrival_uk_23a       Age … "The date …          23 ""                    
#>  3 alternative_address_ind… Seco… "An addres…           3 "The true number of p…
#>  4 country_of_birth_190a    Coun… "The count…         190 ""                    
#>  5 country_of_birth_60a     Coun… "The count…          60 ""                    
#>  6 disability               Disa… "People wh…           5 ""                    
#>  7 economic_activity_statu… Econ… "People ag…          12 "As Census 2021 was d…
#>  8 english_proficiency      Prof… "How well …           6 ""                    
#>  9 ethnic_group_tb_20b      Ethn… "The ethni…          20 ""                    
#> 10 has_ever_worked          Empl… "Classifie…           4 "As Census 2021 was d…
#> # ℹ 34 more rows
```

A typical workflow is to go through the `get_available_` functions to
determine what values you will put in `create_custom_dataset`.

## Contribution

We welcome contributions to the ukcensus package. If you have
suggestions, bug reports, or want to contribute code, please open an
issue or submit a pull request on the GitHub repository.

## License

The ukcensus package is open-source and distributed under the MIT
License. See the LICENSE file for more details.

The data accessed through the ukcensus package is sourced from the
Office for National Statistics (ONS) of England and Wales. This data is
made available through the Open Government License (OGL).

## Acknowledgments

The ukcensus package is made possible through England and Wales’ Office
for National Statistics (ONS) work on designing and collecting the
census and making it available through an [open
API](https://developer.ons.gov.uk/). This package uses the [Create a
Custom Dataset](https://developer.ons.gov.uk/createyourowndataset/)
functionality.
