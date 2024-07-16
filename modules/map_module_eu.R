# map_module_eu.R

# UI component
mapUI <- function(id) {
  ns <- NS(id)
  leafletOutput(ns("map"), height = 500)
}

# Server component
mapServer <- function(id, selected_species, europe_topojson) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    output$map <- renderLeaflet({
      leaflet() %>% 
        addProviderTiles(providers$OpenStreetMap) %>% 
        addPolygons(data = europe_topojson, color = "blue", weight = 2, opacity = 0.5) %>% 
        setView(lng = 10, lat = 50, zoom = 3) %>%  # Initial view of Europe
        addPopups(10, 50, 'Search for a species to see its distribution...', options = popupOptions(closeButton = FALSE))
    })
    
    observeEvent(selected_species(), {
      species_data <- selected_species()
      
      leafletProxy(ns("map"), session) %>% 
        clearMarkers() %>% 
        clearMarkerClusters() %>% 
        clearPopups() %>% 
        setView(lng = 10, lat = 50, zoom = 3)  # Reset to initial view of Europe
      
      if (!is.null(species_data) && nrow(species_data) > 0) {
        # Ensure eventDate is correctly converted to Date format
        if (is.character(species_data$eventDate)) {
          species_data <- species_data %>% mutate(eventDate = as.Date(eventDate, format = "%Y-%m-%d"))
        } else if (is.numeric(species_data$eventDate)) {
          species_data <- species_data %>% mutate(eventDate = as.Date(eventDate, origin = "1970-01-01"))
        }
        
        # Format the eventDate for display
        species_data <- species_data %>% mutate(eventDateFormatted = format(eventDate, "%B %d, %Y"))
        
        leafletProxy(ns("map"), session) %>% 
          addMarkers(data = species_data,
                     lng = ~longitudeDecimal, lat = ~latitudeDecimal,
                     popup = ~paste("<br><b>Region:</b>", locality,
                                    "<br><b>Scientific Name:</b>", scientificName,
                                    "<br><b>Creator:</b>", creator,
                                    "<br><b>Date:</b>", eventDateFormatted,
                                    "<br><b>Count:</b>", individualCount,
                                    "<br><img src='", accessURI, "' width='100' height='100'>"),
                     clusterOptions = markerClusterOptions())
      }
    })
  })
}
