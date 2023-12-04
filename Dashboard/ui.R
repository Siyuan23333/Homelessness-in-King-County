library(shiny)
library(shinydashboard)

header <- dashboardHeader(title = "Homelessness in King")

sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Homelessness in 2022.",
             tabName = "us"),
    menuItem("Who are in Homelessness",
             tabName = "who"),
    menuItem("Trend of Homelessness",
             tabName = "trend"),
    menuItem("Resources for the Homeless",
             tabName = "resource"),
    menuItem("Source code",
             href = "https://github.com/Siyuan23333/STAT-451-Final-Project")
  )
)

body <- dashboardBody(
  tabItems(
    tabItem("us",
            fluidPage(
              fluidRow(
                valueBoxOutput("us_total"),
                valueBoxOutput("us_rate"),
                infoBox("PIT Count", "Defintion of the PIT count")
              ),
              fluidRow(
                column(width = 7,
                       box(
                         title = "Distribution of Homelessness in the US", width = NULL,
                         textOutput("us_main_text"),
                         plotOutput("us_main", height = 500)
                       )
                ),
                column(width = 5,
                       box(
                         title = "Input", width = NULL,
                         selectInput("us_input", "Select Scale ",
                                     c("States", "CoC Regions" = "CoC"))
                       ),
                       box(
                         title = "Top regions", width = NULL,
                         plotOutput("us_sub", height = 440)
                       )
                )
              )
            )
    ),
    tabItem("who",
            fluidPage(
              fluidRow(
                box(
                  title = "Description", width = 8,
                  textOutput("who_text")
                ),
                box(
                  width = 4,
                  selectInput("who_input", "Select Scale ",
                              c("Race", "Age", "Gender"))
                )
              ),
              fluidRow(
                box(
                  title = "", width = 12, height = 600,
                  textOutput("who_main_text"),
                  plotOutput("who_main")
                )
              )
            )
    ),
    tabItem("trend",
            fluidPage(
              fluidRow(
                valueBoxOutput("trend_total"),
                valueBoxOutput("trend_rate"),
                box(
                  width = 4, height = 100,
                  numericInput("trend_year", "Which Year's Data to Show", min = 2007, max = 2022, value = 2022)
                )
              ),
              fluidRow(
                box(
                  width = 12, height = 300,
                  textOutput("trend_main_text"),
                  plotOutput("trend_main")
                )
              ),
              fluidRow(
                box(
                  width = 12, height = 300,
                  textOutput("trend_sub_text"),
                  plotOutput("trend_sub")
                )
              )
            )
    ),
    tabItem("resource",
            h2("...")
    )
  )
)

dashboardPage(header, sidebar, body)