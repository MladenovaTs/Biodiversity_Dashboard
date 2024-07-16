# summary_statistics_module.r

# UI component
summaryUI <- function(id) {
  ns <- NS(id)
  tagList(
    fluidRow(
      column(
        width = 6,
        box(
          title = "Top 10 Most Observed Animal Species",
          status = "primary",
          solidHeader = TRUE,
          width = 12,
          height = "auto",
          plotlyOutput(ns("summary_chart3_animals"))
        )
      ),
      column(
        width = 6,
        box(
          title = "Top 10 Most Observed Plant Species",
          status = "primary",
          solidHeader = TRUE,
          width = 12,
          height = "auto",
          plotlyOutput(ns("summary_chart3_plants"))
        )
      )
    ),
    fluidRow(
      column(
        width = 12,
        box(
          title = "Distribution of Observations by Kingdom",
          status = "primary",
          solidHeader = TRUE,
          width = 12,
          height = "auto",
          plotlyOutput(ns("summary_pie_chart"))
        )
      )
    ),
    fluidRow(
      column(
        width = 6,
        box(
          title = "Geographic Distribution of Animal Observations",
          status = "primary",
          solidHeader = TRUE,
          width = 12,
          height = "auto",
          leafletOutput(ns("summary_map_animals"))
        )
      ),
      column(
        width = 6,
        box(
          title = "Geographic Distribution of Plant Observations",
          status = "primary",
          solidHeader = TRUE,
          width = 12,
          height = "auto",
          leafletOutput(ns("summary_map_plants"))
        )
      )
    )
  )
}

# Server component
summaryServer <- function(id, data, poland_geojson) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Bar chart of top 10 most observed animal species
    output$summary_chart3_animals <- renderPlotly({
      if (nrow(data) > 0) {
        top_species_animals <- data %>%
          filter(kingdom == "Animalia") %>%
          count(scientificName, commonName, sort = TRUE) %>%
          arrange(desc(n)) %>%
          head(10)
        
        colors <- viridis::viridis(10)
        
        plot_ly(top_species_animals, 
                x = ~reorder(paste(scientificName, "(", commonName, ")"), -n), 
                y = ~n, 
                type = 'bar', 
                marker = list(color = colors, line = list(color = 'black', width = 1.5)),
                text = ~n, textposition = 'auto') %>%
          layout(
            xaxis = list(title = "Species", tickangle = -45),
            yaxis = list(title = "Count"),
            margin = list(b = 150),
            showlegend = FALSE
          )
      } else {
        plot_ly() %>% layout(xaxis = list(title = "Species"), yaxis = list(title = "Count"))
      }
    })
    
    # Bar chart of top 10 most observed plant species
    output$summary_chart3_plants <- renderPlotly({
      if (nrow(data) > 0) {
        top_species_plants <- data %>%
          filter(kingdom == "Plantae") %>%
          count(scientificName, commonName, sort = TRUE) %>%
          arrange(desc(n)) %>%
          head(10)
        
        colors <- viridis::viridis(10)
        
        plot_ly(top_species_plants, 
                x = ~reorder(paste(scientificName, "(", commonName, ")"), -n), 
                y = ~n, 
                type = 'bar', 
                marker = list(color = colors, line = list(color = 'black', width = 1.5)),
                text = ~n, textposition = 'auto') %>%
          layout(
            xaxis = list(title = "Species", tickangle = -45),
            yaxis = list(title = "Count"),
            margin = list(b = 150),
            showlegend = FALSE
          )
      } else {
        plot_ly() %>% layout(xaxis = list(title = "Species"), yaxis = list(title = "Count"))
      }
    })
    
    # Pie chart: Distribution of observations by kingdom
    output$summary_pie_chart <- renderPlotly({
      if (nrow(data) > 0) {
        kingdom_counts <- data %>%
          count(kingdom) %>%
          arrange(desc(n))
        
        kingdom_counts <- kingdom_counts %>%
          mutate(kingdom = factor(kingdom, levels = c("Animalia", "Plantae", "Fungi", "NA"))) %>%
          arrange(kingdom)
        
        colors <- viridis::viridis(length(kingdom_counts$kingdom))
        
        kingdom_counts <- kingdom_counts %>%
          mutate(percentage = n / sum(n) * 100,
                 text = paste(kingdom, ": ", round(percentage, 2), "%"))
        
        plot_ly(kingdom_counts, labels = ~kingdom, values = ~n, type = 'pie', marker = list(colors = colors),
                text = ~text, hoverinfo = 'text+percent', textposition = 'inside', textinfo = 'label+percent',
                insidetextorientation = 'horizontal') %>%
          layout(
            showlegend = TRUE,
            legend = list(orientation = 'h', x = 0.5, y = -0.2, xanchor = 'center', yanchor = 'top'),  
            margin = list(l = 50, r = 50, t = 50, b = 100),  
            annotations = list(
              x = 0.5, y = -0.15, 
              text = "Distribution of Observations by Kingdom",
              showarrow = FALSE,
              xref = 'paper', yref = 'paper',
              font = list(size = 15)
            )
          )
      } else {
        plot_ly() %>% layout()
      }
    })
    
    
    
    
    # Geographic distribution of animal observations
    output$summary_map_animals <- renderLeaflet({
      if (nrow(data) > 0) {
        animal_data <- data %>% filter(kingdom == "Animalia")
        leaflet(animal_data) %>%
          addProviderTiles(providers$OpenStreetMap) %>%
          addPolygons(data = poland_geojson, color = "blue", weight = 2, opacity = 0.5) %>%
          addCircleMarkers(
            ~longitudeDecimal, ~latitudeDecimal, 
            popup = ~paste("<b>Scientific Name:</b>", scientificName, "<br><b>Common Name:</b>", commonName),
            radius = 5, color = "red", fillOpacity = 0.8, stroke = FALSE
          ) %>%
          setView(lng = 19.1451, lat = 51.9194, zoom = 6)  
      } else {
        leaflet() %>%
          addProviderTiles(providers$OpenStreetMap) %>%
          setView(lng = 19.1451, lat = 51.9194, zoom = 6)
      }
    })
    
    # Geographic distribution of plant observations
    output$summary_map_plants <- renderLeaflet({
      if (nrow(data) > 0) {
        plant_data <- data %>% filter(kingdom == "Plantae")
        leaflet(plant_data) %>%
          addProviderTiles(providers$OpenStreetMap) %>%
          addPolygons(data = poland_geojson, color = "blue", weight = 2, opacity = 0.5) %>%
          addCircleMarkers(
            ~longitudeDecimal, ~latitudeDecimal, 
            popup = ~paste("<b>Scientific Name:</b>", scientificName, "<br><b>Common Name:</b>", commonName),
            radius = 5, color = "green", fillOpacity = 0.8, stroke = FALSE
          ) %>%
          setView(lng = 19.1451, lat = 51.9194, zoom = 6)  
      } else {
        leaflet() %>%
          addProviderTiles(providers$OpenStreetMap) %>%
          setView(lng = 19.1451, lat = 51.9194, zoom = 6)
      }
    })
  })
}