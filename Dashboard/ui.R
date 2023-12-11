library(shiny)
library(shinydashboard)
library(tidyverse)
library(ggplot2)
library(sf)
library(leaflet)
library(RColorBrewer)
library(stringr)

header <- dashboardHeader(title = "Homelessness in 2022")

sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Homelessness in US",
             tabName = "us"),
    menuItem("Homelessness in Seattle",
             tabName = "who"),
    #    menuItem("Trend of Homelessness",
    #             tabName = "trend"),
    menuItem("Source code",
             href = "https://github.com/Siyuan23333/STAT-451-Final-Project")
  ),
  hr()
)

body <- dashboardBody(
  tabItems(
    tabItem("us",
            fluidPage(
              fluidRow(
                valueBoxOutput("us_total"),
                valueBoxOutput("us_rate"),
                box(
                  width = 4,
                  selectInput("us_scale", "Select Scale ",
                              c("States", "CoC Regions"))
                )
              ),
              fluidRow(
                column(width = 7,
                       box(
                         title = NULL, id = "us_main_text", width = NULL, height = 700,
                         h3("Homelessness is Unevenly Distributed Across the U.S."),
                         textOutput("us_main_text1"),
                         h4(""),
                         textOutput("us_main_text2"),
                         h3(""),
                         leafletOutput("us_main")
                       )
                ),
                column(width = 5,
                       box(
                         width = NULL,
                         plotOutput("us_sub", height = 530)
                       ),
                       box(title = "Underestimated Number", width = NULL, height = 130,
                           textOutput("us_sub_text")
                       )
                )
              )
            )
    ),
    tabItem("who",
            fluidPage(
              fluidRow(
                column(width = 8,
                       fluidRow(
                         valueBoxOutput("who_total", width = 6),
                         valueBoxOutput("who_rate", width = 6)),
                       box(
                         width = NULL,
                         h3("Homelessness is Unevenly Distributed in Seattle/King County"),
                         textOutput("who_main_text1"),
                         h4(""),
                         textOutput("who_main_text2")
                       ),
                       box(
                         width = NULL, height = 420,
                         h4("Homelessness in Different Race Groups"),
                         plotOutput("who_main", height = 370)
                       )
                ),
                column(width = 4,
                       box(
                         "Homelessness in Different Gender Groups",
                         width = NULL, height = 230,
                         plotOutput("who_sub1", width = 350, height = 190)
                       ),
                       box(
                         "Homelessness in Veteran Groups",
                         width = NULL, height = 230,
                         plotOutput("who_sub2", width = 350, height = 190)
                       ),
                       box(
                         "Homelessness in Different Age Groups",
                         width = NULL, height = 320,
                         plotOutput("who_sub3", width = 350, height = 280)
                       ),
                )
              )
            )
    )
    # tabItem("trend",
    #   fluidPage(
    #     fluidRow(
    #       valueBoxOutput("trend_total"),
    #       valueBoxOutput("trend_rate"),
    #       box(
    #         width = 4, height = 100,
    #         numericInput("trend_year", "Which Year's Data to Show", 
    #                      min = 2007, max = 2022, value = 2022)
    #       )
    #     ),
    #     fluidRow(
    #       box(
    #         "A multiple line plot",
    #         width = 8, height = 600,
    #         plotOutput("trend_main")
    #       ),
    #       box(
    #         "Input and Analysis",
    #         width = 4, height = 400,
    #         selectInput("trend_scale", "Select a Demographical Category",
    #                     c("Race", "Age", "Gender", "Veteran")),
    #         textOutput("trend_main_text")
    #       )
    #     )
    #   )
    # )
  )
)

dashboardPage(header, sidebar, body)
