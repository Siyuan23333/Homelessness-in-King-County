library(shiny)
library(shinydashboard)

function(input, output, session) {
  output$us_total <- renderValueBox({
    valueBox(
      0, "Number of People Experiencing Homelessness in 2022"
    )
  })
  
  output$us_rate <- renderValueBox({
    valueBox(
      0, "Rate of Homelessness in 2022 (per 10,000 People)"
    )
  })
  
  output$trend_total <- renderValueBox({
    valueBox(
      0, paste0("Number of People Experiencing Homelessness in ", input$trend_year)
    )
  })
  
  output$trend_rate <- renderValueBox({
    valueBox(
      0, paste0("Rate of Homelessness in ", input$trend_year, " (per 10,000 People)")
    )
  })
  
}