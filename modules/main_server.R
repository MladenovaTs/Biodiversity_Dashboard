# main_server.r

mainServer <- function(input, output, session, data, poland_geojson) {
  # Call modules with default data
  selected_species <- searchServer("search", data)
  mapServer("map", selected_species, poland_geojson)
  timelineServer("timeline", selected_species)
  additionalChartsServer("additional_charts", data)
  summaryServer("summary_charts", data, poland_geojson)
  
  observe({
    charts_to_display <- input$chart_settings
    shinyjs::hide(selector = ".chart-box")
    lapply(charts_to_display, function(chart) {
      shinyjs::show(selector = paste0("#", chart, "_box"))
    })
  })
  
  # Use the add species module
  addSpeciesServer("add_species", data)
  
  # Use the report problem module
  reportProblemServer("report_problem")
}
