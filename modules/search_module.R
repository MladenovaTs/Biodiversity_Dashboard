#search_module.r

# UI component
searchUI <- function(id) {
  ns <- NS(id)
  tagList(
    useShinyjs(),
    selectizeInput(
      ns("species_search"), 
      "Search for a species:", 
      choices = NULL,
      options = list(
        placeholder = 'Search for species'
      )
    ),
    actionButton(ns("search_button"), "Search"),
    tags$div(id = ns("custom_message"), class = "custom-message", "Do you know we have Brown Bears in Poland?"),
    DT::dataTableOutput(ns("search_results"))
  )
}

# Server component
searchServer <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    data <- data %>%
      filter(!is.na(scientificName)) %>%
      mutate(commonName = ifelse(is.na(commonName), "Unknown", commonName))
    
    species_choices <- data %>%
      mutate(combined_name = paste(scientificName, "(", commonName, ")")) %>%
      arrange(combined_name) %>%
      pull(combined_name)
    
    updateSelectizeInput(session, "species_search", choices = species_choices, server = TRUE, selected = "Ursus arctos (Brown Bear)")
    
    search_results <- reactiveVal(data.frame())
    selected_species <- reactiveVal(data.frame())
    
    observe({
      default_data <- data %>% filter(scientificName == "Ursus arctos")
      search_results(default_data)
      selected_species(default_data)
      shinyjs::show("custom_message")  
    })
    
    output$search_results <- DT::renderDataTable({
      req(search_results())
      DT::datatable(
        search_results() %>%
          select(id, scientificName, commonName, eventDate, locality),
        options = list(
          scrollX = TRUE,
          autoWidth = TRUE,
          pageLength = 10
        )
      )
    })
    
    observeEvent(input$search_results_rows_selected, {
      selected <- input$search_results_rows_selected
      all_data <- search_results()
      selected_data <- all_data[selected, ]
      
      if (!is.null(selected) && length(selected) > 0) {
        selected_species(selected_data)
      } else {
        selected_species(data.frame())
      }
    })
    
    observeEvent(input$species_search, {
      if (input$species_search != "") {
        selected_names <- str_extract(input$species_search, "^[^\\(]+") %>% trimws()
        
        filtered_data <- data %>%
          filter(grepl(selected_names, scientificName, ignore.case = TRUE))
        
        search_results(filtered_data)
        selected_species(filtered_data)
        
        shinyjs::hide("custom_message")
      }
    })
    
    observeEvent(input$search_button, {
      selected_names <- str_extract(input$species_search, "^[^\\(]+") %>% trimws()
      
      filtered_data <- data %>%
        filter(grepl(selected_names, scientificName, ignore.case = TRUE))
      
      search_results(filtered_data)
      selected_species(filtered_data)
      
      session$sendCustomMessage('closeSelectize', ns("species_search"))
      updateSelectizeInput(session, "species_search", selected = character(0))
      shinyjs::hide("custom_message")
    })
    
    return(selected_species)
  })
}
