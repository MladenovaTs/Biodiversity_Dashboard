# main_ui.r

mainUI <- function(css) {
  dashboardPage(
    dashboardHeader(title = "Biodiversity Dashboard"),
    dashboardSidebar(
      sidebarMenu(
        menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
        menuItem("Summary Statistics", tabName = "summary", icon = icon("chart-bar")),
        menuItem("Settings", tabName = "settings", icon = icon("cogs"))
      )
    ),
    dashboardBody(
      useShinyjs(),  
      tags$head(
        tags$style(HTML(css))  
      ),
      tabItems(
        tabItem(
          tabName = "dashboard",
          fluidRow(
            column(
              width = 5,
              box(
                title = "Search for a species",
                status = "primary",
                solidHeader = TRUE,
                width = 12,
                height = "auto",
                class = "equal-height",  
                searchUI("search")
              )
            ),
            column(
              width = 7,
              box(
                title = "Map",
                status = "primary",
                solidHeader = TRUE,
                width = 12,
                height = "auto",
                class = "equal-height",  
                mapUI("map")
              )
            )
          ),
          fluidRow(
            box(
              title = "Observation Timeline",
              status = "primary",
              solidHeader = TRUE,
              width = 12,
              height = "auto",
              class = "equal-height",  
              timelineUI("timeline")
            )
          ),
          fluidRow(
            box(
              title = "Additional Charts",
              status = "primary",
              solidHeader = TRUE,
              width = 12,
              height = "auto",
              class = "equal-height",  
              additionalChartsUI("additional_charts")
            )
          ),
          fluidRow(
            div(class = "custom-message")
          )
        ),
        tabItem(
          tabName = "summary",
          fluidRow(
            summaryUI("summary_charts")
          )
        ),
        tabItem(
          tabName = "settings",
          fluidRow(
            column(
              width = 6,
              box(
                title = "Add Species",
                status = "primary",
                solidHeader = TRUE,
                width = 12,
                addSpeciesUI("add_species")
              )
            ),
            column(
              width = 6,
              box(
                title = "Report a Problem",
                status = "primary",
                solidHeader = TRUE,
                width = 12,
                reportProblemUI("report_problem")
              )
            )
          )
        )
      )
    )
  )
}
