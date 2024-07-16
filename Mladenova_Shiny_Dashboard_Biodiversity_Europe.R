# Mladenova_Shiny_Dashboard_Biodiversity_Europe.R
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
library(DBI)
library(RSQLite)
library(dbplyr)
library(future)
library(promises)
library(memoise)
library(profvis)

plan(multisession)

# Source module files
source("modules/search_module_eu.R")
source("modules/map_module_eu.R")
source("modules/timeline_module_eu.R")
source("modules/add_species_module_eu.R")
source("modules/report_problem_module.R")

# Cache the Europe TopoJSON data loading
load_europe_topojson <- memoise(function() {
  st_read("www/europe.topojson", quiet = TRUE)
})

europe_topojson <- load_europe_topojson()

# SCSS to CSS conversion
css <- sass::sass(
  sass::sass_file("www/styles.scss")
)

# Function to create a new database connection
create_db_connection <- function() {
  dbConnect(SQLite(), dbname = "data/processed_data/biodiversity_data_europe.sqlite")
}

# UI component
ui <- tagList(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css"),
    tags$script(src = "scripts.js"),
    tags$style(HTML(css))  # Inject the CSS converted from SCSS
  ),
  dashboardPage(
    dashboardHeader(title = "Biodiversity Data"),
    dashboardSidebar(
      sidebarMenu(id = "tabs",
                  menuItem("Welcome", tabName = "welcome", icon = icon("home")),
                  menuItem("Search", tabName = "data_overview", icon = icon("search")),
                  menuItem("Add Species", tabName = "add_species", icon = icon("plus")),
                  menuItem("Report Problem", tabName = "report_problem", icon = icon("bug"))
      )
    ),
    dashboardBody(
      shinyjs::useShinyjs(),  # Initialize shinyjs
      tabItems(
        tabItem(tabName = "welcome",
                div(class = "welcome-page",
                    div(class = "welcome-text",
                        style = "text-align: center; padding: 20px; background-color: #007bff; color: white; border-radius: 10px; max-width: 800px; margin: auto;",
                        h1("Welcome to the Biodiversity Dashboard"),
                        p("Explore biodiversity data across Europe. Our dashboard provides a comprehensive overview of species distributions, population trends, and conservation statuses."),
                        p("Navigate through various sections using the menu on the left to search for specific species, add new species records, and report any problems you encounter."),
                        p("In the Search tab, you can look up species by their scientific or common names and see detailed records and maps of their occurrences."),
                        p("If you have new species data to contribute, use the Add Species tab to enter and submit your information."),
                        p("For any technical issues or data inaccuracies, please report them using the Report Problem tab."),
                        p("Thank you for using the Biodiversity Dashboard. We hope it helps you in your research, conservation efforts, and appreciation of Europe's rich biodiversity.")
                    )
                )
        ),
        tabItem(tabName = "data_overview",
                fluidRow(
                  column(width = 4,
                         box(title = "Search", status = "primary", solidHeader = TRUE,
                             searchUI("search"), width = 12, style = "height: 500px; overflow-y: auto;")
                  ),
                  column(width = 8,
                         box(title = "Map", status = "primary", solidHeader = TRUE,
                             mapUI("map"), width = 12, style = "height: 500px; overflow-y: auto;")
                  )
                ),
                fluidRow(
                  column(width = 12,
                         box(title = "Timeline", status = "primary", solidHeader = TRUE,
                             timelineUI("timeline"), width = 12, style = "height: 500px; overflow-y: auto;")
                  )
                )
        ),
        tabItem(tabName = "add_species",
                addSpeciesUI("add_species")
        ),
        tabItem(tabName = "report_problem",
                reportProblemUI("report_problem")
        )
      )
    )
  )
)

# Server component
server <- function(input, output, session) {
  print("Server initialization started")
  db <- create_db_connection()
  
  onSessionEnded(function() {
    cat("Session ended.\n")
    dbDisconnect(db)
  })
  
  # Initialize the search module with db and empty values
  selected_species <- searchServer("search", db, NULL)
  print("searchServer module called")
  
  # Initialize the map module with empty values and europe_topojson
  mapServer("map", selected_species, europe_topojson)
  print("mapServer module called")
  
  # Initialize the timeline module with empty values
  timelineServer("timeline", selected_species, NULL)
  print("timelineServer module called")
  
  # Lazy load the server modules based on selected tab
  observeEvent(input$tabs, {
    if (input$tabs == "add_species") {
      addSpeciesServer("add_species", db)
      print("addSpeciesServer module called")
    } else if (input$tabs == "report_problem") {
      reportProblemServer("report_problem")
      print("reportProblemServer module called")
    }
  })
  print("Server initialization completed")
}

# Run the app
shinyApp(ui = ui, server = server)