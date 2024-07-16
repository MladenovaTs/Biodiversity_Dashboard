# Mladenova_Shiny_Dashboard_Biodiversity_Poland.R
library(dplyr)
library(stringr)
library(DT)
library(sf)
library(plotly)
library(viridis)
library(sass)
library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(shinyjs)
library(leaflet)

# Source module files
source("modules/search_module.R")
source("modules/map_module.R")
source("modules/timeline_module.R")
source("modules/additional_charts_module.R")
source("modules/summary_statistics_module.R")
source("modules/add_species_module.R")
source("modules/report_problem_module.R")
source("modules/main_ui.R")
source("modules/main_server.R")

# Load data
load_data <- function() {
  data <- read.csv("data/processed_data/biodiversity_data_poland.csv")
  data$eventDate <- as.Date(data$eventDate)
  return(data)
}

# Load Poland GeoJSON data
poland_geojson <- st_read("www/poland-with-regions_.geojson", quiet = TRUE)

# SCSS to CSS conversion
css <- sass::sass(
  sass::sass_file("www/styles.scss")
)

# UI component
ui <- mainUI(css)

# Server component
server <- function(input, output, session) {
  data <- load_data()
  
  # Call main server module
  mainServer(input, output, session, data, poland_geojson)
}

# Run the app
shinyApp(ui = ui, server = server)
