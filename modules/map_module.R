# map_module.r

# UI component
mapUI <- function(id) {
  ns <- NS(id)
  leafletOutput(ns("map"), height = 500)
}

# Server component
mapServer <- function(id, selected_species, poland_geojson) {
  moduleServer(id, function(input, output, session) {
    output$map <- renderLeaflet({
      leaflet() %>%
        addProviderTiles(providers$OpenStreetMap) %>%
        addPolygons(data = poland_geojson, color = "blue", weight = 2, opacity = 0.5) %>%
        setView(lng = 19.1451, lat = 51.9194, zoom = 6)  # Initial view of Poland
    })
    
    observe({
      species_data <- selected_species()
      leafletProxy("map", session) %>%
        clearMarkers() %>%  
        clearMarkerClusters()  
      
      if (!is.null(species_data) && nrow(species_data) > 0) {
        leafletProxy("map", session) %>%
          addMarkers(data = species_data,
                     lng = ~longitudeDecimal, lat = ~latitudeDecimal,
                     popup = ~paste("<br><b>Region:</b>", locality,
                                    "<br><b>Scientific Name:</b>", scientificName,
                                    "<br><b>Creator:</b>", creator,
                                    "<br><b>Date:</b>", eventDate,
                                    "<br><img src='", accessURI, "' width='100' height='100'>"),
                     clusterOptions = markerClusterOptions())
      }
    })
    
    # Reset the map view when a new species is selected
    observeEvent(selected_species(), {
      leafletProxy("map", session) %>%
        setView(lng = 19.1451, lat = 51.9194, zoom = 6)  # Reset to initial view of Poland
    })
  })
}