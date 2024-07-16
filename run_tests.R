# run_tests.R
library(testthat)

# Set working directory to the project's root directory
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Run all tests in the 'tests/testthat' directory
test_dir("tests/testthat")
