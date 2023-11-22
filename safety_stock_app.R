library(shiny)
library(readxl)
library(dplyr)
library(norm)

# Define the user interface
ui <- fluidPage(
  titlePanel("Safety Stock Calculator"),
  sidebarLayout(
    sidebarPanel(
      fileInput('file1', 'Choose Excel File',
                accept = c(".xlsx",".xls")
      ),
      numericInput('service_level', 'Service Level (as a decimal)', value = 0.92),
      numericInput('holding_cost', 'Holding Cost Rate', value = 0.08),
      numericInput('opportunity_cost', 'Opportunity Cost Rate', value = 0.05),
      numericInput('lead_time', 'Lead Time in Weeks', value = 2)
    ),
    mainPanel(
      textOutput("safety_stock")
    )
  )
)

# Define server logic
server <- function(input, output) {
  # Reactive expression to read the uploaded file
  demandData <- reactive({
    inFile <- input$file1
    
    if (is.null(inFile))
      return(NULL)
    
    read_excel(inFile$datapath)
  })
  
  # Calculate the safety stock
  output$safety_stock <- renderText({
    df <- demandData()
    if (is.null(df))
      return("Please upload a file.")
    
    # Assume the demand column is the second column in the file
    mean_demand <- mean(df[[2]], na.rm = TRUE)
    std_demand <- sd(df[[2]], na.rm = TRUE)
    
    lead_time_days <- input$lead_time * 7
    z_score <- qnorm(input$service_level)
    
    # Total holding cost rate
    total_holding_cost_rate <- input$holding_cost + input$opportunity_cost
    
    # Calculate safety stock
    safety_stock <- z_score * (std_demand * sqrt(lead_time_days))
    safety_stock <- ceiling(safety_stock)
    
    paste("The calculated safety stock is:", safety_stock)
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
