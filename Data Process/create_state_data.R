library(tidyverse)

coc_data <- read_csv("../data/2022-PIT-Counts-by-CoC.csv")
pop_data <-  read_csv("../data/NST-EST2022-POP.csv")

coc_data$state_abbreviation <- gsub("-.*", "", coc_data$`CoC Number`)
pop_data$NAME <- sub("^\\.", "", pop_data$`Geographic Area`)
homeless_data <- coc_data %>%
  group_by(state_abbreviation) %>%
  summarise(homeless = sum(`Overall Homeless, 2022`, na.rm = TRUE))
abbreviation_map <- c("AL"="Alabama", "AK"="Alaska", "AZ"="Arizona", "AR"="Arkansas", 
                      "CA"="California", "CO"="Colorado", "CT"="Connecticut", 
                      "DE"="Delaware", "FL"="Florida", "GA"="Georgia", "HI"="Hawaii", 
                      "ID"="Idaho", "IL"="Illinois", "IN"="Indiana", "IA"="Iowa", 
                      "KS"="Kansas", "KY"="Kentucky", "LA"="Louisiana", "ME"="Maine", 
                      "MD"="Maryland", "MA"="Massachusetts", "MI"="Michigan", 
                      "MN"="Minnesota", "MS"="Mississippi", "MO"="Missouri", 
                      "MT"="Montana", "NE"="Nebraska", "NV"="Nevada", "NH"="New Hampshire",
                      "NJ"="New Jersey", "NM"="New Mexico", "NY"="New York", 
                      "NC"="North Carolina", "ND"="North Dakota", "OH"="Ohio", 
                      "OK"="Oklahoma", "OR"="Oregon", "PA"="Pennsylvania", 
                      "RI"="Rhode Island", "SC"="South Carolina", "SD"="South Dakota", 
                      "TN"="Tennessee", "TX"="Texas", "UT"="Utah", "VT"="Vermont", 
                      "VA"="Virginia", "WA"="Washington", "WV"="West Virginia", 
                      "WI"="Wisconsin", "WY"="Wyoming", "PR"="Pureto Rico",
                      "DC"="District of Columbia")
homeless_data$NAME <- abbreviation_map[homeless_data$state_abbreviation]
state_total_data <- pop_data %>%
  select(c("2022", "NAME")) %>%
  rename("pop" = "2022") %>%
  inner_join(homeless_data, by = "NAME")
state_total_data$homeless_ratio <- round(state_total_data$homeless / state_total_data$pop * 10000, 1)
breaks <- c(seq(0, 40, by = 5), max(state_total_data$homeless_ratio, na.rm = TRUE) + 1)
state_total_data$class <- cut(state_total_data$homeless_ratio, breaks = breaks, labels = FALSE, 
                      include.lowest = TRUE, right = FALSE)
state_total_data[9, "class"] <- 9
state_total_data$class <- as.factor(state_total_data$class)
state_total_data <- state_total_data %>%
  mutate(is_wa = ifelse(state_abbreviation == "WA", "TRUE", "FALSE"))
write.csv(state_total_data, "../data/state_total_data.csv", row.names=FALSE)
