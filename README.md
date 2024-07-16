# Biodiversity Dashboard

## Overview

The **Biodiversity Dashboard Poland** and **Biodiversity Dashboard Europe** are interactive Shiny applications designed to visualize observed species within Poland and Europe. They leverage data from the Global Biodiversity Information Facility (GBIF) to provide users with detailed insights into species observations through various visualizations, including maps, timelines, and charts.

## Features

- **Species Search**: Users can search for species by their vernacular or scientific names. The search field returns matching names, and upon selection, the app displays the species' observations on the map.
- **Map Visualization**: The application displays the locations of observed species on an interactive map.
- **Observation Timeline**: Users can view a timeline of when selected species were observed.
- **Summary Statistics**: The app provides additional charts and summary statistics for the observed species.
- **Add Species**: Users can add new species observations to the dataset.
- **Report Problems**: Users can report issues or problems with the data.

## Business Requirements

- **Regional Data**: The app includes observations specific to Poland and Europe.
- **Default View**: The default view provides a meaningful overview, not just an empty map and plot. By default, it will show observations of Brown Bears in Poland.
- **Module Decomposition**: The app's functionalities are decomposed into Shiny modules for better organization and maintainability.

## Technical Requirements

- **No Scaffolding Tools**: The app does not use scaffolding tools like `golem` or `packer`.
- **Readme for Developers**: This readme file provides guidance for potential future developers.
- **Deployment**: The app is deployed to `shinyapps.io`.
- **Unit Tests**: The app includes unit tests for the most important functions and edge cases.

## Extra Features

### Beautiful UI
- **Custom Styling**: The dashboard uses CSS and Sass for enhanced styling, providing a visually appealing interface.
- **Responsive Design**: The UI components are designed to be responsive and user-friendly.

### Performance Optimization
- **Optimized Performance**: The app is optimized to initialize quickly and ensure the search field is responsive.
  - **Memoization**: The use of the `memoise` package caches the Europe TopoJSON data to prevent redundant data loading, enhancing the app's loading speed.
  - **Multisession Plan**: The `future` package with a multisession plan enables parallel processing, improving the app's responsiveness.
  - **Database Connections**: Efficient management of database connections to handle queries without blocking the app's main thread.
  - **Leaflet Proxy**: The use of `leafletProxy` allows for efficient updating of the map without reloading the entire map widget, ensuring smooth user interaction.

### JavaScript Integration
- **Advanced Visualization**: Implemented non-trivial visualizations using JavaScript for a better user experience.

### Infrastructure Deployment
- **Cloud Deployment**: The deployment of the application to a custom cloud instance on Google Cloud was planned and nearly completed. However, the process was halted due to the expiration of the subscription.

## File Structure

- **Docker Images**: Docker images for both **Biodiversity Dashboard Poland** and **Biodiversity Dashboard Europe** Shiny applications are available. These Dockerfiles ensure that all necessary dependencies and configurations are included to run the applications in a containerized environment.
  - Docker images are available at:
    - [Biodiversity Dashboard Poland Docker Image](https://hub.docker.com/r/mladenova/shiny-polish)
    - [Biodiversity Dashboard Europe Docker Image](https://hub.docker.com/r/mladenova/shiny-europe)

- **Mladenova_Shiny_Dashboard_Biodiversity_Poland.R**: Main script to run the Shiny application for Poland.
- **Mladenova_Shiny_Dashboard_Biodiversity_Europe.R**: Main script to run the Shiny application for Europe.
- **run_tests.R**: Script to run unit tests for the most important functions and edge cases.
- **README.md**: Readme file providing an overview and instructions for the application.
- **modules/**: Directory containing Shiny modules for different functionalities.
  - `search_module.R`: Module for species search functionality.
  - `map_module.R`: Module for map visualization.
  - `timeline_module.R`: Module for observation timeline.
  - `additional_charts_module.R`: Module for additional charts.
  - `add_species_module.R`: Module for adding new species.
**Note**: Each of the above files has a corresponding version for the Europe dashboard, with the same name followed by "_eu" and additional optimizations. 
  - `main_ui.R`: Main UI module for the Biodiversity Dashboard Poland.
  - `main_server.R`: Main server module for the Biodiversity Dashboard Poland.
  - `summary_statistics_module.R`: Module for summary statistics for the Biodiversity Dashboard Poland.
  - `report_problem_module.R`: Module for reporting problems.
- **data/**: Directory containing data files.
  - **processed_data/**: Folder containing processed data files:
    - `biodiversity_data_processing.R`
    - `biodiversity_data_poland.csv`
    - `biodiversity_data_europe.sqlite`
- **www/**: Directory containing static files such as CSS and images.
  - `styles.scss`: Custom Sass file for styling.
  - `styles.css`: Compiled CSS file.
  - `styles.css.map`: Source map for CSS.
  - `poland-with-regions_.geojson`: GeoJSON file for Poland's regions.
  - `europe.topojson`: TopoJSON file for Europe.
  - `chart_pie.html`: HTML file for pie chart visualization.
  - `chart2_plants.html`: HTML file for plants chart visualization.
  - `chart1_animals.html`: HTML file for animals chart visualization.
  - `chart_pie_files/`: Directory containing assets for pie chart.
  - `chart2_plants_files/`: Directory containing assets for plants chart.
  - `chart1_animals_files/`: Directory containing assets for animals chart.
- **tests/**: Directory containing test files.
  - **testthat/**: Subfolder containing unit test files:
    - `test_helpers.R`: Helper functions for tests.
    - `test_search_module.R`: Tests for the search module.
    - `test_timeline_module.R`: Tests for the timeline module.

## Running the App from the Browser

<https://mladenova.shinyapps.io/biodiversity_dashboard_poland/>
<https://mladenova.shinyapps.io/biodiversity_dashboard_europe/>

## Unit Testing

The application includes unit tests to ensure the functionality of key components. Tests are written using the `testthat` package. To run the tests, use the run_tests.R script.

## Contact

If you have any questions or need further assistance, please contact:

- Tsvetelina Mladenova
- tsvetelina.bml@gmail.com

Enjoy exploring the biodiversity data with the Mladenova Shiny Dashboard!
