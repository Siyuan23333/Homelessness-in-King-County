library(shiny)
library(shinydashboard)
library(tidyverse)
library(ggplot2)
library(sf)
library(leaflet)
library(RColorBrewer)
library(stringr)


function(input, output, session) {
  
  ### First Tab about Homelessness in US
  
  # Load data
  state_total_data <- read_csv("../data/state_total_data.csv")
  state_map <- st_read("../data/cb_2022_us_state_5m/cb_2022_us_state_5m.shp")
  coc_total_data <- read_csv("../data/coc_total_data.csv")
  coc_map <- st_read("../data/CoC_GIS_National_Boundary.gdb",
                     layer = "FY22_CoC_National_Bnd")
  
  # Data for infobox
  nation_mean <- state_total_data %>%
    summarise_if(is.numeric, sum, na.rm = TRUE)
  nation_mean$homeless_ratio <- round(nation_mean$homeless / nation_mean$pop * 10000, 1)
  
  # Data for main map
  state_map_data <- state_map %>%
    select("NAME") %>%
    left_join(state_total_data, by = "NAME")
  coc_map_data <- coc_map %>%
    select(c("ST", "COCNUM", "COCNAME")) %>%
    left_join(coc_total_data, by = "COCNUM")
  
  # Data for sub graph
  state_plot_data <- state_total_data %>%
    arrange(desc(homeless_ratio)) %>%
    top_n(10, homeless_ratio)
  
  coc_plot_data <- coc_total_data %>%
    arrange(desc(homeless_ratio)) %>%
    top_n(20, homeless_ratio) %>%
    mutate(name = paste(gsub("-.*", "", COCNUM), sub("^.*/", "", `CoC Name`), sep = "-")) %>%
    mutate(name =gsub("City & County", "", name)) %>%
    mutate(name =gsub("CoC", "", name))
  coc_plot_data[17, "name"] <- "Shasta Etal. Counties"
  
  # Color hue for maps
  map_pal <- colorFactor(
    palette = brewer.pal(9, "YlOrRd"),
    levels = c("1", "2", "3", "4", "5", "6", "7", "8", "9")
  )
  map_pal_colors <- rev(brewer.pal(9, "YlOrRd"))
  numbers <- seq(0, 45, by = 5)
  map_pal_labs <- rev(sapply(1:(length(numbers) - 1), function(i) {
    paste(numbers[i], "-", numbers[i+1])
  }))
  map_pal_labs[9] <- "< 5"
  map_pal_labs[1] <- ">= 40"
  
  # Infobox
  output$us_total <- renderValueBox({
    valueBox(
      nation_mean$homeless, "Number of People Experiencing Homelessness in 2022"
    )
  })
  
  output$us_rate <- renderValueBox({
    valueBox(
      nation_mean$homeless_ratio, "Rate of Homelessness in 2022 (per 10,000 People)"
    )
  })
  
  # Analysis for main map
  output$us_main_text1 <- renderText({
    if (input$us_scale == "States") {
      "A state-level view allows a large-scale exploration of the 
      geographical distribution of homelessness in the U.S. We can 
      see that the homelessness issue is more severe in the West Coast and 
      the Northeastern states. The home- lessness rates in the central 
      and southern states are relatively low, but there are also 
      individual states where homelessness is a problem to some extent."
    } else {
      "The Continuum of Care (CoC) regions are designated areas in the US that
      coordinate housing and services funding for homeless populations,
      allowing a smaller-scale exploration. Within each state, 
      the distribution of homelessness rates is also uneven 
      and primarily concentrated in large cities and suburban areas. 
      This is more evident in states with overall lower rates of homelessness, 
      where urban areas have significantly higher rates of homelessness 
      than other areas."
    }
  })
  
  output$us_main_text2 <- renderText({
    if (input$us_scale == "States") {
      "The homelessness rates in the top 10 states/regions are much 
      higher than the national average, with the highest being California,
      exceeding the national average by more than double. Washington State 
      is among them and ranks 7th among all states, having a quite serious 
      homelessness problem."
    } else {
      "The problem of homelessness is disproportionately distributed and 
      concentrated in specific areas, as the top 20 regions have 
      homelessness rates several times higher than the national average.
      Although not as severe as in major metropolises like Los Angeles, 
      New York, and San Francisco, Seattle/King County still has a very 
      serious homelessness problem, ranking 16th among all the 386 regions."
    }
  })
  
  # Main map
  output$us_main <- renderLeaflet({
    if (input$us_scale == "States") {
      leaflet(data = state_map_data) %>%
        addProviderTiles(providers$CartoDB.Positron) %>%
        addPolygons(fillColor = ~map_pal(class),
                    weight = 1,
                    color = "white",
                    fillOpacity = 0.7,
                    popup = ~paste0(NAME, "<br> Ratio: ", homeless_ratio)) %>%
        setView(lng = -98.5795, lat = 39.8283, zoom = 4) %>%
        addLegend("bottomright",
                  colors = map_pal_colors,
                  labels = map_pal_labs,
                  opacity = 0.7,
                  title = "Estimated Rate of</br>Homeless per</br>10000 people")
    } else {
      leaflet(data = coc_map_data) %>%
        addProviderTiles(providers$CartoDB.Positron) %>%
        addPolygons(fillColor = ~map_pal(class),
                    weight = 1,
                    color = "white",
                    fillOpacity = 0.7,
                    popup = ~paste0(ST, "-", COCNAME, "<br>Ratio: ", homeless_ratio)) %>%
        setView(lng = -98.5795, lat = 39.8283, zoom = 4) %>%
        addLegend("bottomright", 
                  colors = map_pal_colors, 
                  labels = map_pal_labs,
                  opacity = 0.7,
                  title = "Estimated Rate of</br>Homeless per</br>10000 people")
    }
  })
  
  # Analysis for sub graph
  output$us_sub_text <- renderText({
    "These data come from the Point-in-Time (PIT) count,
    an annual census of homeless individuals conducted 
    on a single night. It often underestimates the number of homeless 
    because it may miss people not visible during the count."
  })
  
  # Sub barplot
  output$us_sub <- renderPlot({
    if (input$us_scale == "States") {
      ggplot(state_plot_data, aes(x = reorder(state_abbreviation, homeless_ratio), y = homeless_ratio, fill = is_wa)) +
        geom_bar(stat = "identity") +
        scale_fill_manual(values = c("TRUE" = "indianred1", "FALSE" = "grey")) +
        geom_hline(yintercept = nation_mean$homeless_ratio, linetype = "dashed", color = "black", linewidth = 0.8) +
        geom_text(x = 10, y = nation_mean$homeless_ratio + 13, color = "grey35", label = "National Average", size = 6) +
        geom_text(x = 4, y = 32.4 + 4, color = "indianred1", label = "32.4", size = 6) +
        labs(x = "", y = "Homeless Rate (per 10,000 population)", 
             title = "Top 10 States/Regions with the Highest \n Estimated Homeless Rate in 2022",
             size = 7) +
        theme_classic() +
        theme(plot.title = element_text(size = 20),
              axis.text = element_text(size = 15),
              axis.title = element_text(size = 15),
              legend.position = "none") +
        coord_flip()
    } else {
      ggplot(coc_plot_data, aes(x = reorder(`name`, homeless_ratio), y = homeless_ratio, fill = is_king)) +
        geom_bar(stat = "identity") +
        scale_fill_manual(values = c("TRUE" = "indianred1", "FALSE" = "grey")) +
        geom_hline(yintercept = nation_mean$homeless_ratio, linetype = "dashed", color = "black", linewidth = 0.8) +
        geom_text(x = 20, y = nation_mean$homeless_ratio + 23, color = "grey35", label = "National Average", size = 5) +
        geom_text(x = 5, y = 59 + 5, color = "indianred1", label = "59.0", size = 4) +
        labs(x = "", y = "Homeless Rate (per 10,000 population)", 
             title = "Top 20 CoC Regions with the Highest \n Estimated Homeless Rate in 2022",
             size = 7) +
        theme_classic() +
        theme(plot.title = element_text(size = 20),
              axis.text.y = element_text(size = 10),
              axis.text.x = element_text(size = 15),
              axis.title = element_text(size = 15),
              legend.position = "none") +
        coord_flip()
    }
  })
  
  ### Second Tab about Demographic Distribution of Homelessness in King
  
  # Load Data
  demo_total_data <- read_csv("../data/demo_total_data.csv")
  
  # Prepare Data
  variables <- c("White", "Black", "Asian", "AI/AN",
                 "NHOPI", "Multiple Races")
  race_plot_data <- demo_total_data[demo_total_data$label %in% variables, ] %>%
    arrange(desc(ratio_homeless)) %>%
    mutate(index = seq.int(1, length(variables)))
  
  variables <- c("Female", "Male")
  gender_plot_data <- demo_total_data[demo_total_data$label %in% variables, ] %>%
    arrange(ratio_homeless) %>%
    mutate(index = seq.int(1, length(variables)))
  
  variables <- c("Veteran", "Nonveteran")
  veteran_plot_data <- demo_total_data[demo_total_data$label %in% variables, ] %>%
    arrange(ratio_homeless) %>%
    mutate(index = seq.int(1, length(variables)))
  
  variables <- c("Under 18", "18 to 24", "Over 24")
  age_plot_data <- demo_total_data[demo_total_data$label %in% variables, ] %>%
    arrange(ratio_homeless) %>%
    mutate(index = seq.int(1, length(variables)))
  
  # Infobox
  output$who_total <- renderValueBox({
    valueBox(
      demo_total_data$homeless[demo_total_data$label == "Total"], 
      "Number of People Experiencing Homelessness in King",
      color = "navy"
    )
  })
  
  output$who_rate <- renderValueBox({
    valueBox(
      round(10000 * demo_total_data$homeless[demo_total_data$label == "Total"] /
              demo_total_data$pop[demo_total_data$label == "Total"], 1), 
      "Rate of Homelessness in King (per 10,000 People)",
      color = "navy"
    )
  })
  
  # Analysis
  output$who_main_text1 <- renderText({
    "The plots show the distribution of homelessness in different demographical 
    groups. The bars represent the percentage of the groups among the homeless 
    people, and the dashed line gives the proportion of the groups in the whole 
    population, revealing the disproportionate impact of homelessness on 
    different groups."
  })
  
  output$who_main_text2 <- renderText({
    "Homelessness influences communities of color more in Seattle/King County. 
    24.9% of people experiencing homelessness in King County identify as 
    Black/African American. However, only 6.5% of King County's population 
    identifies as Black/African-American. Similarly, 8.5% of people experiencing 
    homelessness are American Indian, Alaskan Native, or Indigenous (AI/AN), 
    which group makes up only 0.4% of King County's population. Meanwhile, 
    males are more likely to be impacted by homelessness. 
    In the total population of King County, the male-to-female ratio is 
    generally balanced. However, males account for 65.1% of the homeless population."
  })
  
  # Four plots
  output$who_main <- renderPlot({
    ggplot(race_plot_data, aes(x = reorder(label, -ratio_homeless))) +
      geom_bar(aes(y = ratio_homeless, fill = label), stat = "identity", width = 0.6) +
      geom_segment(aes(x = index - 0.5, xend = index + 0.5, 
                       y = ratio_pop, yend = ratio_pop), 
                   color = "indianred1", linewidth = 0.8, linetype = "dashed") +
      geom_text(aes(x = index, y = ratio_homeless + 1.5, 
                    label = paste0(ratio_homeless, "%")), size = 5) +
      geom_text(aes(x = index + 0.45, y = ratio_pop + 1.5, 
                    label = paste0(ratio_pop, "%")), size = 5, color = "red") +
      labs(x = "", y = "Percentage Among all Homeless People") +
      theme_classic() +
      theme(
        # plot.title = element_text(size = 15),
        axis.text.y = element_text(size = 14),
        axis.text.x = element_text(size = 14),
        axis.title = element_text(size = 16),
        legend.position = "none")
  })
  
  output$who_sub1 <- renderPlot({
    ggplot(gender_plot_data, aes(x = reorder(label, ratio_homeless))) +
      geom_bar(aes(y = ratio_homeless, fill = label), stat = "identity", width = 0.6) +
      geom_segment(aes(x = index - 0.5, xend = index + 0.5, 
                       y = ratio_pop, yend = ratio_pop), 
                   color = "indianred1", linewidth = 0.8, linetype = "dashed") +
      geom_text(aes(x = index, y = ratio_homeless + 7, 
                    label = paste0(ratio_homeless, "%")), size = 5) +
      geom_text(aes(x = index - 0.4, y = ratio_pop + 7, 
                    label = paste0(ratio_pop, "%")), size = 5, color = "red") +
      labs(x = "", y = "") +
      ylim(0, 80) +
      theme_classic() +
      theme(
        # plot.title = element_text(size = 15),
        axis.text.y = element_text(size = 14),
        axis.text.x = element_text(size = 14),
        axis.title = element_blank(),
        legend.position = "none") +
      coord_flip()
  })
  
  output$who_sub2 <- renderPlot({
    ggplot(veteran_plot_data, aes(x = reorder(label, ratio_homeless))) +
      geom_bar(aes(y = ratio_homeless, fill = label), stat = "identity", width = 0.6) +
      geom_segment(aes(x = index - 0.5, xend = index + 0.5, 
                       y = ratio_pop, yend = ratio_pop), 
                   color = "indianred1", linewidth = 0.8, linetype = "dashed") +
      geom_text(aes(x = index, y = ratio_homeless + 11, 
                    label = paste0(ratio_homeless, "%")), size = 5) +
      geom_text(aes(x = index - 0.4, y = ratio_pop + 11, 
                    label = paste0(ratio_pop, "%")), size = 5, color = "red") +
      labs(x = "", y = "") +
      ylim(0, 120) +
      theme_classic() +
      theme(
        # plot.title = element_text(size = 15),
        axis.text.y = element_text(size = 14),
        axis.text.x = element_text(size = 14),
        axis.title = element_blank(),
        legend.position = "none") +
      coord_flip()
  })
  
  output$who_sub3 <- renderPlot({
    ggplot(age_plot_data, aes(x = reorder(label, ratio_homeless))) +
      geom_bar(aes(y = ratio_homeless, fill = label), stat = "identity", width = 0.6) +
      geom_segment(aes(x = index - 0.5, xend = index + 0.5, 
                       y = ratio_pop, yend = ratio_pop), 
                   color = "indianred1", linewidth = 0.8, linetype = "dashed") +
      geom_text(aes(x = index, y = ratio_homeless + 8, 
                    label = paste0(ratio_homeless, "%")), size = 5) +
      geom_text(aes(x = index - 0.4, y = ratio_pop + 8, 
                    label = paste0(ratio_pop, "%")), size = 5, color = "red") +
      labs(x = "", y = "Percentage Among all Homeless People") +
      ylim(0, 90) +
      theme_classic() +
      theme(
        # plot.title = element_text(size = 15),
        axis.text.y = element_text(size = 14),
        axis.text.x = element_text(size = 14),
        axis.title.y = element_blank(),
        axis.title.x = element_text(size = 16),
        legend.position = "none") +
      coord_flip()
  })
  
  ###
  
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
