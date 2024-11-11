# Packages 
pacman::p_load(sfdep, tidyverse, sf, tmap, lubridate, spatstat, dplyr, ggplot2, viridis, magick, raster, sparr, rmapshaper)

# Aspatial Data
ps <- readRDS("data/3data/aspatial/points_study.rds")

# Geospatial Data 
adm1 <- readRDS("data/adm1_window.rds")

ps <- ps %>%
  mutate(event_date = dmy(event_date))

ui <- fluidPage(
  titlePanel("PART 3 - Spatio-Temporal KDE Analysis"),
  sidebarLayout(
    sidebarPanel(
      selectInput("years", "Time Range:",
                  choices = c("All", "2015", "2016", "2017", "2018", "2019", 
                              "2020", "2021", "2022", "2023", "2024"),
                  multiple = TRUE),
      selectInput("study_area", "Study Area:",
                  choices = c("All", "Papua", "Papua Barat", "Papua Barat Daya", 
                              "Papua Pegunungan", "Papua Selatan", "Papua Tengah"),
                  multiple = TRUE),
      radioButtons("qorm", "Split Data By:",
                   choices = c("Quarterly", "Monthly")),
      actionButton("start", "Visualising the Data"),
      br(),
      actionButton("startKDE", "Generate STKDE Animation")
    ),
    mainPanel(
      plotOutput("mapPlot", width = "100%", height = 400)
    )
  )
)

# Server
server <- function(input, output) {
  # Server logic goes here
  observeEvent(input$start, {

  })
}

# Run the app
shinyApp(ui = ui, server = server)
