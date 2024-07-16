# additional_charts_module.R

# UI component
additionalChartsUI <- function(id) {
  ns <- NS(id)
  fluidRow(
    column(4, plotlyOutput(ns("chart1"), height = "100%")),  
    column(8, plotlyOutput(ns("chart2"), height = "100%"))   
  )
}

# Server component
additionalChartsServer <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    output$chart1 <- renderPlotly({
      filtered_data <- data %>%
        filter(!is.na(eventDate)) %>%
        group_by(eventDate = format(eventDate, "%Y"), kingdom) %>%
        summarise(count = n(), .groups = 'drop')
      
      plot_ly(
        data = filtered_data,
        x = ~eventDate,
        y = ~count,
        color = ~kingdom,  
        type = 'bar',
        text = ~kingdom,  
        hoverinfo = 'text+y'  
      ) %>%
        layout(
          barmode = 'stack',  
          title = list(text = "Event Dates Distribution by Kingdom", y = 0.95),
          xaxis = list(title = "Year", tickformat = "%Y", titlefont = list(size = 12), automargin = TRUE),
          yaxis = list(title = "Count"),
          legend = list(title = list(text = 'Kingdom')),
          margin = list(t = 50, b = 150, l = 50, r = 50),
          autosize = TRUE
        )
    })
    
    output$chart2 <- renderPlotly({
      data <- data %>% mutate(displayName = ifelse(is.na(commonName), scientificName, commonName))
      
      plot_ly(
        data = data,
        x = ~displayName,
        type = 'histogram',
        histfunc = 'count',
        name = "Species Count",
        marker = list(color = 'rgb(158,202,225)')
      ) %>%
        layout(
          title = list(text = "Species Count", y = 0.95),
          xaxis = list(title = "Species", tickangle = -45, tickfont = list(size = 10), titlefont = list(size = 12), automargin = TRUE),
          yaxis = list(title = "Count"),
          bargap = 0.2,
          margin = list(t = 50, b = 150, l = 50, r = 50),
          autosize = TRUE
        )
    })
  })
}

