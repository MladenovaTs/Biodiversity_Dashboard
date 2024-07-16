# search_module_eu.R

# UI component
searchUI <- function(id) {
  ns <- NS(id)
  tagList(
    useShinyjs(),
    # Add welcome message
    tags$div(
      id = ns("welcome_tab"),
      class = "welcome-tab",
      style = "padding: 10px; background-color: #f8f9fa; border-radius: 10px; margin-bottom: 10px; font-size: 14px;",
      tags$h3("Welcome to the Species Search App!", style = "margin-bottom: 10px;"),
      tags$p("Use this app to search for species based on their scientific or common names."),
      tags$p("Start by typing the name of a species in the search box below and click 'Search' to see the results."),
      tags$p("You can also select a species from the dropdown list to automatically perform a search.")
    ),
    selectizeInput(
      ns("species_search"), 
      "Search for a species:", 
      choices = NULL,
      options = list(
        placeholder = 'Search for species',
        allowEmptyOption = TRUE,
        create = TRUE,  # Allows creating new options which is useful for handling spaces
        persist = FALSE,
        maxOptions = 1000,  # Allow more options to handle spaces and broader searches
        delimiter = " "  # Ensure spaces are handled properly
      )
    ),
    actionButton(ns("search_button"), "Search"),  
    tags$div(id = ns("custom_message"), class = "custom-message", "Do you know we have Brown Bears in Bulgaria?"),
    tags$div(
      style = "height: 400px; overflow-y: auto;",  
      DT::dataTableOutput(ns("search_results"))
    ),
    tags$div(id = ns("error_message"), class = "error-message", style = "color: red; display: none;", "No results found or invalid search input. Please try another search.")
  )
}

# Server component
searchServer <- function(id, db = NULL, search_results) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Initialize with empty search results
    search_results_reactive <- reactiveVal(data.frame(id = numeric(), scientificName = character(), commonName = character(), eventDate = character(), locality = character(), stringsAsFactors = FALSE))
    selected_species <- reactiveVal(data.frame(id = numeric(), scientificName = character(), commonName = character(), eventDate = character(), locality = character(), stringsAsFactors = FALSE))
    
    # Populate the species search input
    observe({
      if (!is.null(db)) {
        species_choices_query <- "SELECT DISTINCT scientificName, commonName FROM biodiversity_data_europe WHERE commonName IS NOT NULL ORDER BY scientificName"
        species_choices <- dbGetQuery(db, species_choices_query) %>%
          mutate(combined_name = paste(scientificName, "(", commonName, ")")) %>%
          pull(combined_name)
      } else {
        species_choices <- search_results %>%
          mutate(combined_name = paste(scientificName, "(", commonName, ")")) %>%
          pull(combined_name)
      }
      
      updateSelectizeInput(session, "species_search", choices = species_choices, server = TRUE, selected = character(0))
    })
    
    # Render the search results DataTable
    output$search_results <- DT::renderDataTable({
      req(search_results_reactive())
      data <- search_results_reactive() %>%
        mutate(eventDate = as.Date(eventDate, origin = "1970-01-01")) %>%
        mutate(eventDate = format(eventDate, "%Y-%m-%d"))
      DT::datatable(
        data %>% select(id, scientificName, commonName, eventDate, locality),
        options = list(
          scrollX = TRUE,
          autoWidth = TRUE,
          pageLength = 10,
          serverSide = FALSE
        )
      )
    }, server = TRUE)
    
    # Update selected species when a row is selected
    observeEvent(input$search_results_rows_selected, {
      selected <- input$search_results_rows_selected
      all_data <- search_results_reactive()
      selected_data <- all_data[selected, ]
      selected_species(selected_data)
    })
    
    # Function to perform the search
    perform_search <- function(search_input) {
      if (nchar(search_input) < 3 || !grepl("^[a-zA-Z() ]+$", search_input)) {
        return(NULL)
      } else {
        # Extract the scientific name or common name from the input
        selected_names <- str_extract(search_input, "^[^\\(]+") %>% trimws()
        common_name <- str_extract(search_input, "\\(([^)]+)\\)") %>% str_remove_all("[\\(\\)]") %>% trimws()
        
        if (!is.null(db)) {
          query <- sprintf("SELECT * FROM biodiversity_data_europe WHERE scientificName = '%s' OR commonName = '%s' LIMIT 1000", selected_names, common_name)
          filtered_data <- tryCatch({
            dbGetQuery(db, query)
          }, error = function(e) {
            return(NULL)
          })
        } else {
          filtered_data <- search_results %>%
            filter(scientificName == selected_names | commonName == common_name)
        }
        return(filtered_data)
      }
    }
    
    # Automatically perform search when a species is selected from the dropdown
    observeEvent(input$species_search, {
      if (input$species_search != "") {
        filtered_data <- perform_search(input$species_search)
        if (is.null(filtered_data) || nrow(filtered_data) == 0) {
          shinyjs::show("error_message")
          search_results_reactive(data.frame(id = numeric(), scientificName = character(), commonName = character(), eventDate = character(), locality = character(), stringsAsFactors = FALSE))
        } else {
          shinyjs::hide("error_message")
          search_results_reactive(filtered_data)
          selected_species(filtered_data)
          shinyjs::hide("custom_message")
        }
      }
    })
    
    # Handle the search button click
    observeEvent(input$search_button, {
      filtered_data <- perform_search(input$species_search)
      if (is.null(filtered_data) || nrow(filtered_data) == 0) {
        shinyjs::show("error_message")
        search_results_reactive(data.frame(id = numeric(), scientificName = character(), commonName = character(), eventDate = character(), locality = character(), stringsAsFactors = FALSE))
      } else {
        shinyjs::hide("error_message")
        search_results_reactive(filtered_data)
        selected_species(filtered_data)
        shinyjs::hide("custom_message")
      }
      session$sendCustomMessage('closeSelectize', ns("species_search"))
      updateSelectizeInput(session, "species_search", selected = character(0))
    })
    
    return(selected_species)
  })
}