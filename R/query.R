process_api_response <- function(endpoint, query_params = list()) {
  handle <- "https://api.beta.ons.gov.uk/v1"
  api_url <- paste0(handle, endpoint)
  if (!"limit" %in% names(query_params)) {
    query_params$limit <- 999999999
  }
  response <- httr::GET(api_url, query = query_params)

  if (httr::http_error(response)) {
    stop(glue::glue("Error: Unable to fetch data from {response$url}"))
  }

  data_list <- httr::content(response, as = "parsed")
  data_items <- data_list$items

  data_tibble <- purrr::map_dfr(data_items, tibble::as_tibble)

  return(data_tibble)
}

#' Get available populations
#'
#' @return
#' @export
#'
#' @examples
get_available_populations <- function() {
  endpoint <- "/population-types"
  return(process_api_response(endpoint))
}

#' Get available area types
#'
#' @param population_type
#'
#' @return
#' @export
#'
#' @examples
get_available_area_types <- function(population_type = "UR") {
  endpoint <- paste0("/population-types/", population_type, "/area-types")
  return(process_api_response(endpoint))
}

#' Get available areas
#'
#' @param area_type_id
#' @param search_param
#' @param population_type
#'
#' @return
#' @export
#'
#' @examples
get_available_areas <- function(area_type_id, search_param = NULL, population_type = "UR") {
  endpoint <- paste0("/population-types/", population_type,
                     "/area-types/", area_type_id, "/areas")

  if (!is.null(search_param)) {
    endpoint <- paste0(endpoint, "?q=", search_param)
  }

  return(process_api_response(endpoint))
}

#' Get available variables
#'
#' @param search_param
#' @param population_type
#'
#' @return
#' @export
#'
#' @examples
get_available_variables <- function(search_param = NULL, population_type = "UR") {
  endpoint <- paste0("/population-types/", population_type, "/dimensions")

  if (!is.null(search_param)) {
    endpoint <- paste0(endpoint, "?q=", search_param)
  }

  return(process_api_response(endpoint))
}

#' Get available classifications
#'
#' @param variable
#' @param population_type
#' @param nest
#'
#' @return
#' @export
#'
#' @examples
get_available_categorisations <- function(variable, population_type = "UR", nest = FALSE) {
  endpoint <- paste0("/population-types/", population_type,
                     "/dimensions/", variable, "/categorisations")

  categorisations_tibble <- process_api_response(endpoint)
  categorisations_tibble <- tidyr::unnest_wider(categorisations_tibble, categories, names_sep = "_")

  categorisations_tibble <- categorisations_tibble |>
    select(-categories_id, -quality_statement_text, -default_categorisation)
  if (nest) {
    categorisations_tibble <- categorisations_tibble |>
      tidyr::nest(data = categories_label)
  }

  return(categorisations_tibble)

}

#' Create custom dataset
#'
#' @param area_type
#' @param variables
#' @param population_type
#' @param remove_zeroes
#'
#' @return
#' @export
#'
#' @examples
create_custom_dataset <- function(area_type, variables, population_type = "UR",
                                  remove_zeroes = FALSE, column_names = "id") {
  endpoint <- paste0("/population-types/", population_type, "/census-observations")

  area_type_param <- paste(area_type, collapse = ",")
  variables_param <- paste(variables, collapse = ",")
  query_list <- list("area-type" = area_type_param, "dimensions" = variables_param)

  handle <- "https://api.beta.ons.gov.uk/v1"
  api_url <- paste0(handle, endpoint)
  response <- httr::GET(api_url, query = query_list)

  if (httr::http_error(response)) {
    stop(glue::glue("Error: Unable to fetch data from {response$url}"))
  }

  data_list <- httr::content(response, as = "parsed")
  message(glue::glue("{data_list$total_areas - data_list$blocked_areas} out of {data_list$total_areas} areas available"))
  # if (data_list$blocked_areas > 0) {
  #   warning(glue::glue("Protecting personal data will prevent {data_list$blocked_areas} from being published."))
  # }
  # message(glue::glue("Returning a dataset with {data_list$total_observations} rows"))
  data_items <- data_list$observations

  result_tibble <- purrr::map_dfr(data_items, convert_to_tibble, column_names = column_names)

  result_tibble <- result_tibble |>
    janitor::clean_names()

  if ("observation" %in% names(result_tibble)) {
    result_tibble <- result_tibble |>
      dplyr::rename(n = observation)
  }

  if (remove_zeroes) {
    result_tibble <- result_tibble |>
      dplyr::filter(observation != 0)
  }

  return(result_tibble)
}

convert_to_tibble <- function(list_data, column_names) {
  dimensions <- list_data$dimensions
  if (column_names == "id") {
    dimension_names <- sapply(dimensions, purrr::pluck, "dimension_id")
  } else if (column_names == "name") {
    dimension_names <- sapply(dimensions, purrr::pluck, "dimension")
  } else {
    stop("Error: 'column_names' must be either 'id' or 'name'.")
  }
  option_values <- sapply(dimensions, purrr::pluck, "option")
  # dimension_id <- sapply(dimensions, purrr::pluck, "dimension_id")
  # option_id <- sapply(dimensions, purrr::pluck, "option_id")
  observation <- list_data$observation

  tibble::tibble(
    !!!setNames(option_values, dimension_names),
    # !!!setNames(option_id, paste0(dimension_names, "_id")),
    observation = observation
  )
}
