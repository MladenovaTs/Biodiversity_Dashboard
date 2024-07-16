# timeline_module_eu.R

# UI component
timelineUI <- function(id) {
  ns <- NS(id)
  tagList(
    plotlyOutput(ns("timeline")),
    textOutput(ns("observation_span"))
  )
}

# Server component
timelineServer <- function(id, selected_species, timeline_data = NULL) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Reactive expression to calculate total observed counts
    total_counts <- reactive({
      data <- selected_species()
      if (is.null(data) || nrow(data) == 0) {
        return(0)
      }
      sum(data$individualCount, na.rm = TRUE)
    })
    
    # Reactive expression to calculate observation span
    observation_span <- reactive({
      data <- selected_species()
      if (is.null(data) || nrow(data) == 0) {
        return("No data available")
      }
      min_date <- min(as.Date(data$eventDate, origin = "1970-01-01"), na.rm = TRUE)
      max_date <- max(as.Date(data$eventDate, origin = "1970-01-01"), na.rm = TRUE)
      paste(format(min_date, "%Y"), "-", format(max_date, "%Y"))
    })
    
    # Reactive expression to calculate the number of countries
    countries_count <- reactive({
      data <- selected_species()
      if (is.null(data) || nrow(data) == 0) {
        return(0)
      }
      length(unique(data$country))
    })
    
    output$observation_span <- renderText({
      span <- observation_span()
      paste("Observation span:", span)
    })
    
    output$timeline <- renderPlotly({
      data <- selected_species()
      if (is.null(data) || nrow(data) == 0) {
        return(NULL)
      }
      
      # Convert eventDate to Date 
      if (is.numeric(data$eventDate)) {
        data <- data %>% mutate(eventDate = as.Date(eventDate, origin = "1970-01-01"))
      } else {
        data <- data %>% mutate(eventDate = as.Date(eventDate))
      }
      
      unique_species <- unique(data$scientificName)
      p <- plot_ly()
      
      for (species in unique_species) {
        species_data <- data %>% 
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
        "<b>Total observed counts:</b> ", total_counts(), 
        "<br><b>Observation span:</b> ", observation_span(),
        "<br><b>Countries:</b> ", countries_count()
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
      x_range <- range(data$eventDate, na.rm = TRUE)
      if (length(unique(data$scientificName)) == 1) {
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
