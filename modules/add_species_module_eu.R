# add_species_module.R

# UI component 
addSpeciesUI <- function(id) {
  ns <- NS(id)
  tagList(
    textInput(ns("new_species_scientific_name"), "Scientific Name", placeholder = "e.g., Homo sapiens"),
    textInput(ns("new_species_common_name"), "Common Name", placeholder = "e.g., Human"),
    textInput(ns("new_species_kingdom"), "Kingdom", placeholder = "e.g., Animalia"),
    textInput(ns("new_species_phylum"), "Phylum", placeholder = "e.g., Chordata"),
    textInput(ns("new_species_class"), "Class", placeholder = "e.g., Mammalia"),
    textInput(ns("new_species_order"), "Order", placeholder = "e.g., Primates"),
    textInput(ns("new_species_family"), "Family", placeholder = "e.g., Hominidae"),
    textInput(ns("new_species_genus"), "Genus", placeholder = "e.g., Homo"),
    textInput(ns("new_species_species"), "Species", placeholder = "e.g., sapiens"),
    textInput(ns("new_species_subspecies"), "Subspecies", placeholder = "e.g., sapiens sapiens"),
    textInput(ns("new_species_variety"), "Variety", placeholder = "Optional"),
    textInput(ns("new_species_form"), "Form", placeholder = "Optional"),
    textInput(ns("new_species_authority"), "Authority", placeholder = "e.g., Linnaeus, 1758"),
    numericInput(ns("new_species_individual_count"), "Individual Count", value = 1, min = 1),
    textAreaInput(ns("new_species_description"), "Description", placeholder = "Provide a detailed description"),
    textInput(ns("new_species_habitat"), "Habitat", placeholder = "e.g., Forest, Grassland"),
    textInput(ns("new_species_locality"), "Locality", placeholder = "e.g., Białowieża Forest, Poland"),
    numericInput(ns("new_species_latitude"), "Latitude", value = NA, min = -90, max = 90),
    numericInput(ns("new_species_longitude"), "Longitude", value = NA, min = -180, max = 180),
    textInput(ns("new_species_creator"), "Creator", placeholder = "Your name or organization"),
    dateInput(ns("new_species_event_date"), "Event Date", value = Sys.Date()),
    actionButton(ns("add_species_button"), "Add Species")
  )
}

# Server component 
addSpeciesServer <- function(id, db) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    observeEvent(input$add_species_button, {
      new_species <- data.frame(
        scientificName = input$new_species_scientific_name,
        commonName = input$new_species_common_name,
        kingdom = input$new_species_kingdom,
        phylum = input$new_species_phylum,
        class = input$new_species_class,
        order = input$new_species_order,
        family = input$new_species_family,
        genus = input$new_species_genus,
        species = input$new_species_species,
        subspecies = input$new_species_subspecies,
        variety = input$new_species_variety,
        form = input$new_species_form,
        authority = input$new_species_authority,
        individualCount = input$new_species_individual_count,
        description = input$new_species_description,
        habitat = input$new_species_habitat,
        locality = input$new_species_locality,
        latitudeDecimal = input$new_species_latitude,
        longitudeDecimal = input$new_species_longitude,
        creator = input$new_species_creator,
        eventDate = input$new_species_event_date,
        id = nrow(data) + 1,
        stringsAsFactors = FALSE
      )
      
      dbWriteTable(db, "biodiversity_data_europe", new_species, append = TRUE)
      
      # Update any UI components or data-dependent components
      updateSelectizeInput(session, "species_search", choices = unique(data$scientificName), server = TRUE)
      
      showModal(modalDialog(
        title = "Success",
        "New species has been added successfully!",
        easyClose = TRUE,
        footer = NULL
      ))
    })
  })
}