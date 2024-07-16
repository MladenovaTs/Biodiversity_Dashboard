# report_problem_module.R

# UI component 
reportProblemUI <- function(id) {
  ns <- NS(id)
  tagList(
    textAreaInput(ns("problem_description"), "Describe the problem", placeholder = "e.g., The map is not loading correctly."),
    actionButton(ns("report_problem_button"), "Report Problem")
  )
}

# Server component 
reportProblemServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    observeEvent(input$report_problem_button, {
      problem <- input$problem_description
      
      # Console message
      print(problem)
      
      showModal(modalDialog(
        title = "Problem Reported",
        "Thank you for reporting the problem. We will look into it.",
        easyClose = TRUE,
        footer = NULL
      ))
    })
  })
}