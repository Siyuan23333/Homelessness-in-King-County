library(shiny)
library(shinydashboard)

header <- dashboardHeader(title = "Homelessness in King")

sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Homelessness in 2022",
             tabName = "us"),
    menuItem("Who are in Homelessness",
             tabName = "who"),
    menuItem("Trend of Homelessness",
             tabName = "trend"),
    menuItem("Housing for Homelessness",
             tabName = "house"),
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
                         selectInput("us_scale", "Select Scale ",
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
                  "Description of Inequality Issue", width = 8,
                  textOutput("who_text")
                ),
                box(
                  width = 4,
                  selectInput("who_input", "Select a Demographical Category",
                              c("Race", "Age", "Gender", "Veteran"))
                )
              ),
              fluidRow(
                box(
                  "A bar plot and Analysis", width = 12, height = 600,
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
                  "A multiple line plot",
                  width = 8, height = 600,
                  plotOutput("trend_main")
                ),
                box(
                  "Input and Analysis",
                  width = 4, height = 400,
                  selectInput("trend_scale", "Select a Demographical Category",
                              c("Race", "Age", "Gender", "Veteran")),
                  textOutput("trend_main_text")
                )
              )
            )
    ),
    tabItem("house",
            fluidPage(
              fluidRow(
                box(
                  "Description of the housing service",
                  width = 12, height = 200,
                  textOutput("house_sub_text")
                ),
                box(
                  "A multiple line plot and Analysis",
                  width = 12, height = 500,
                  textOutput("house_main_text"),
                  plotOutput("house_main")
                )
              )
            )
    )
  )
)
dashboardPage(header, sidebar, body)
