library(shiny)

pacman::p_load(sfdep, tidyverse, sf, tmap)

hunan <- st_read(dsn = "data/geospatial", 
                 layer = "Hunan")
hunan2012 <- read_csv("data/aspatial/Hunan_2012.csv")
hunan_GDP <- left_join(hunan,hunan2012)

# Define UI for application that draws a histogram
ui <- fluidPage(
  titlePanel("that one thing"),
    sidebarLayout(
    sidebarPanel(
      selectInput(inputId = "variable",
                  label = "Mapping Variable",
                  choices = list("Gross Domestic Product" = "GDP",
                                 "Gross Domestic Product Per Capita" = "GDPPC"),
                  selected = "GDPPC"), #what starts selected 
      sliderInput(inputId = "class",
                  label = "No. Classes",
                  min = 5,
                  max = 10,
                  value = c(6))
    ),
    mainPanel(plotOutput("mapPlot", width = "100%", height = 400))
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  output$mapPlot <- renderPlot({
    tmap_options(check.and.fix = TRUE) +
      tm_shape(hunan_GDP)+
      tm_fill(input$variable,
              n = input$class, 
              style = "quantile",
              palette = blues9) +
      tm_borders(lwd = 0.1, alpha = 1)
   #   tm_view(set.zoom.limits = c(6.5,8))
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
