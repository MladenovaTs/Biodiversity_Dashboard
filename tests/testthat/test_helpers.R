library(testthat)
library(shiny)
library(dplyr)

# Helper function to initiate a shiny test session for searchServer
test_searchServer <- function(data, input_list, expected_results) {
  testServer(searchServer, args = list(db = NULL, search_results = data), {
    # Set inputs
    session$setInputs(!!!input_list)
    
    # Allow some time for inputs to be processed
    Sys.sleep(1)
    
    # Get the search results
    result <- search_results_reactive()
    
    # Check that the search results match the expected results
    expect_equal(nrow(result), expected_results$nrow)
    if (!is.null(expected_results$species_names)) {
      expect_true(all(result$scientificName %in% expected_results$species_names))
    }
  })
}

# Helper function to initiate a shiny test session for timelineServer
test_timelineServer <- function(data, input_list, expected_results) {
  testServer(timelineServer, args = list(selected_species = reactiveVal(data), timeline_data = data), {
    # Allow some time for inputs to be processed
    Sys.sleep(1)
    
    # Get the calculated total counts and observation span
    total_counts <- total_counts()
    observation_span <- observation_span()
    
    # Check the total counts
    expect_equal(total_counts, expected_results$total_counts)
    
    # Check the observation span
    expect_equal(observation_span, expected_results$observation_span)
  })
}
