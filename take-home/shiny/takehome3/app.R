library(shiny)
pacman::p_load(sfdep, tidyverse, sf, tmap, lubridate, spatstat)

# Load data
adm1 <- readRDS("data/papua_adm1.rds")
adm2 <- readRDS("data/papua_adm2.rds")
ps <- readRDS("data/points_study.rds")

# Convert event_date to Unix timestamps
ps <- ps %>%
  mutate(event_date_unix = as.numeric(dmy(event_date)))

# UI
ui <- fluidPage(
  titlePanel("Kernel Density Estimation and Spatial Analysis"),
  sidebarLayout(
    sidebarPanel(
      dateRangeInput("date_range", "Select Date Range:",
                     start = as.Date("2020-01-01"),
                     end = as.Date("2020-12-31")),
      selectInput("bandwidth_method", "Bandwidth Selection Method:",
                  choices = c("bw.diggle", "bw.CvL", "bw.scott", "bw.ppl", "adaptive")),
      selectInput("smoothing_kernel", "Smoothing Kernel Method:",
                  choices = c("Gaussian", "Epanechnikov", "Quartic", "Disc")),
      selectInput("second_order_analysis", "Second Order Analysis Method:",
                  choices = c("G-function", "F-function", "K-function", "L-function")),
      numericInput("num_simulations", "Number of Simulations:", value = 99, min = 1),
      selectInput("edge_correction", "Edge Correction:",
                  choices = c("None", "Translational", "Border")),
      actionButton("run_analysis", "Run Analysis")
    ),
    mainPanel(
      plotOutput("mapPlot", width = "100%", height = 400)
    )
  )
)

# Server
server <- function(input, output) {
  observeEvent(input$run_analysis, {
    print("Run Analysis Button Clicked")  # Debugging
    
    # Convert date range input to Unix timestamps
    date_range_unix <- as.numeric(as.Date(input$date_range))
    print(paste("Date Range:", date_range_unix[1], "to", date_range_unix[2]))  # Debugging
    
    # Filter `ps` dataset using the converted Unix timestamps
    filtered_ps <- ps %>%
      filter(event_date_unix >= date_range_unix[1] & event_date_unix <= date_range_unix[2])
    
    # Check if filtered_ps is not empty
    if (nrow(filtered_ps) == 0) {
      output$mapPlot <- renderPlot({ plot.new() })  # If no data, create a blank plot
      output$secondOrderPlot <- renderPlot({ plot.new() })
      return()
    }
    # Transform to target CRS
    target_crs <- 23883
    adm1_proj <- st_transform(adm1, crs = target_crs)
    ps_proj <- st_make_valid(st_transform(filtered_ps, crs = target_crs))  # Ensure valid geometries
    
    # Convert filtered points to a spatial point pattern
    ps_ppp <- as.ppp(st_geometry(ps_proj))  # Use as.ppp directly
    adm1_owin <- as.owin(st_geometry(adm1_proj))
    ps_ppp_adm1 <- ps_ppp[adm1_owin]
    
    # Select bandwidth method
    bandwidth_method <- switch(input$bandwidth_method,
                               "bw.diggle" = bw.diggle,
                               "bw.CvL" = bw.CvL,
                               "bw.scott" = bw.scott,
                               "bw.ppl" = bw.ppl,
                               "adaptive" = function(x) bw.adapt(x, 0.05))  # Example for adaptive
    
    # Select kernel type
    kernel_type <- switch(input$smoothing_kernel,
                          "Gaussian" = "gaussian",
                          "Epanechnikov" = "epanechnikov",
                          "Quartic" = "quartic",
                          "Disc" = "disc")
    
    # Compute Kernel Density Estimation
    kde <- density(ps_ppp_adm1, sigma = bandwidth_method, edge = TRUE, kernel = kernel_type)
    
    # Plot KDE
    output$mapPlot <- renderPlot({
      plot(kde, main = paste("Kernel Density Estimation (Method:", input$bandwidth_method, ")"))
    })
  })
}

# Run the app
shinyApp(ui = ui, server = server)
