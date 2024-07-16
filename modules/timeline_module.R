# timeline_module.R

# UI component
timelineUI <- function(id) {
  ns <- NS(id)
  plotlyOutput(ns("timeline"))
}

# Server component
timelineServer <- function(id, selected_species) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Reactive expression to calculate total observed counts and observation span
    total_counts <- reactive({
      req(selected_species())
      total <- sum(selected_species()$individualCount, na.rm = TRUE)
      total
    })
    
    observation_span <- reactive({
      req(selected_species())
      dates <- selected_species()$eventDate
      span <- range(dates, na.rm = TRUE)
      paste(format(span[1], "%Y"), "-", format(span[2], "%Y"))
    })
    
    output$timeline <- renderPlotly({
      req(selected_species())
      selected_data <- selected_species()
      
      unique_species <- unique(selected_data$scientificName)
      p <- plot_ly()
      
      for (species in unique_species) {
        species_data <- selected_data %>%
          filter(scientificName == species) %>%
          arrange(eventDate)
        
        # Create stacked area chart for cumulative sum
        p <- add_trace(p,
                       x = species_data$eventDate,
                       y = cumsum(species_data$individualCount),
                       type = 'scatter',
                       mode = 'lines',
                       fill = 'tozeroy',
                       name = paste(species, "(Cumulative)"),
                       line = list(shape = 'linear'),
                       fillcolor = 'rgba(0,100,200,0.5)')
        
        # Overlay line plot for individual counts
        p <- add_trace(p,
                       x = species_data$eventDate,
                       y = species_data$individualCount,
                       type = 'scatter',
                       mode = 'lines+markers',
                       name = paste(species, "(Daily Count)"),  
                       marker = list(size = 6),
                       line = list(shape = 'linear'))
      }
      
      # Add custom legend 
      custom_text <- paste(
        "<b>Total observed counts:</b> ", total_counts(), "<br><b>Observation span:</b> ", observation_span()
      )
      
      # Adding invisible traces to include custom text in legend
      p <- add_trace(p, 
                     x = 0, y = 0, 
                     type = 'scatter', 
                     mode = 'markers', 
                     marker = list(size = 0.1, color = 'rgba(0,0,0,0)'),
                     showlegend = TRUE, 
                     name = custom_text)
      
      # Adjust x-axis range based on data 
      x_range <- range(selected_data$eventDate, na.rm = TRUE)
      if (length(unique(selected_data$scientificName)) == 1) {
        # Add padding to x-axis range
        x_padding <- as.numeric(difftime(x_range[2], x_range[1], units = "days")) * 0.05
        x_range <- c(x_range[1] - x_padding, x_range[2] + x_padding)
      }
      
      # Dynamically set date format based on the range of dates
      date_range <- diff(as.numeric(x_range))
      date_format <- if (date_range > 365) "%Y-%m" else "%Y-%m-%d"
      
      p <- layout(p,
                  title = "Observation Timeline",
                  xaxis = list(title = "Date", range = x_range, tickformat = date_format),
                  yaxis = list(title = "Count"),
                  legend = list(
                    x = 1,
                    y = 1,
                    orientation = 'v',
                    traceorder = 'normal'
                  ),
                  margin = list(l = 70, r = 250, b = 50, t = 50, pad = 4),  
                  autosize = TRUE
      )
      
      p
    })
  })
}
