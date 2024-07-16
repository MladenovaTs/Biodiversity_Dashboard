library(testthat)
library(shiny)
library(shinytest)
library(dplyr)

# Source the helper functions using relative paths
source("test_helpers.R")

# Sample data to be used in the test
test_data <- data.frame(
  scientificName = c("Species A", "Species B", "Species A", "Species B"),
  eventDate = as.Date(c("2022-01-01", "2022-01-02", "2022-01-03", "2022-01-04")),
  individualCount = c(5, 10, 15, 20),
  stringsAsFactors = FALSE
)

# Test 1: Functionality test
test_that("Basic timeline functionality", {
  input_list <- list()
  expected_results <- list(
    total_counts = 50,
    observation_span = "2022 - 2022"
  )
  test_timelineServer(test_data, input_list, expected_results)
})

# Test 2: Timeline with single observation
test_that("Timeline with single observation", {
  single_data <- data.frame(
    scientificName = c("Species A"),
    eventDate = as.Date(c("2022-01-01")),
    individualCount = c(5),
    stringsAsFactors = FALSE
  )
  input_list <- list()
  expected_results <- list(
    total_counts = 5,
    observation_span = "2022 - 2022"
  )
  test_timelineServer(single_data, input_list, expected_results)
})

# Test 3: Timeline with no data
test_that("Timeline with no data", {
  empty_data <- data.frame(
    scientificName = character(),
    eventDate = as.Date(character()),
    individualCount = integer(),
    stringsAsFactors = FALSE
  )
  input_list <- list()
  expected_results <- list(
    total_counts = 0,
    observation_span = "No data available"
  )
  test_timelineServer(empty_data, input_list, expected_results)
})
