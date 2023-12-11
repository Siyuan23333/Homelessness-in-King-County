library(tidyverse)
library(stringr)
library(ggplot2)

homeless_data <- read_csv("../data/2022-PIT-Counts-by-CoC.csv")
pop_data <- as.data.frame(read_csv("../data/ACSDP1Y2022.DP05-2023-12-11T034310.csv")) %>% 
  rename("Label"="Label (Grouping)", "Estimate"="King County, Washington!!Estimate") %>%
  select(c("Label", "Estimate")) %>%
  na.omit()
pop_data$Label <- str_trim(pop_data$Label)
pop_data <- as.data.frame(t(pop_data))
colnames(pop_data) <- pop_data[1, ]
pop_data <- pop_data[-1, ]
pop_data[] <- lapply(pop_data, as.numeric)


demo_total_data <- homeless_data[homeless_data$`CoC Number` == "WA-500", ] %>%
  na.omit() %>%
  select(c("Overall Homeless, 2022", "Overall Homeless - Under 18, 2022",	
           "Overall Homeless - Age 18 to 24, 2022",	"Overall Homeless - Over 24, 2022",
           "Overall Homeless - Female, 2022",	"Overall Homeless - Male, 2022",
           "Overall Homeless - Transgender, 2022", "Overall Homeless - Gender that is not Singularly Female or Male, 2022",
           "Overall Homeless - Gender Questioning, 2022",
           "Overall Homeless - Hispanic/Latino, 2022",	"Overall Homeless - White, 2022",
           "Overall Homeless - Black, African American, or African, 2022", 
           "Overall Homeless - Asian or Asian American, 2022", 
           "Overall Homeless - American Indian, Alaska Native, or Indigenous, 2022",
           "Overall Homeless - Native Hawaiian or Other Pacific Islander, 2022",
           "Overall Homeless - Multiple Races, 2022",	"Overall Homeless Veterans, 2022")) %>%
  rename_with(~ str_replace_all(., "Overall Homeless - |, 2022", "")) %>%
  rename("Total"="Overall Homeless", "Veteran"="Overall Homeless Veterans")

demo_total_data[2, "Total"] <- pop_data$`Total population`
demo_total_data[2, "Under 18"] <- pop_data$`Under 18 years`
demo_total_data[2, "Age 18 to 24"] <- 186980 # Calculator lol
demo_total_data[2, "Over 24"] <- demo_total_data[2, "Total"] - demo_total_data[2, "Under 18"] - demo_total_data[2, "Age 18 to 24"]
demo_total_data[2, "Female"] <- pop_data$Female
demo_total_data[2, "Male"] <- pop_data$Male
demo_total_data[2, "Hispanic/Latino"] <- pop_data$`Hispanic or Latino (of any race)`
demo_total_data[2, "White"] <- pop_data$`White alone`
demo_total_data[2, "Black, African American, or African"] <- pop_data$`Black or African American alone`
demo_total_data[2, "Asian or Asian American"] <- pop_data$`Asian alone`
demo_total_data[2, "American Indian, Alaska Native, or Indigenous"] <- pop_data$`American Indian and Alaska Native alone`
demo_total_data[2, "Native Hawaiian or Other Pacific Islander"] <- pop_data$`Native Hawaiian and Other Pacific Islander alone`
demo_total_data[2, "Multiple Races"] <- pop_data$`Two or More Races`
demo_total_data[2, "Veteran"] <- 84950
demo_total_data$Nonveteran <- demo_total_data$Total - demo_total_data$Veteran
demo_total_data <- demo_total_data %>%
  rename("Black"="Black, African American, or African", "Asian"="Asian or Asian American", 
         "AI/AN"="American Indian, Alaska Native, or Indigenous",
         "NHOPI"="Native Hawaiian or Other Pacific Islander",
         "18 to 24"="Age 18 to 24")
demo_total_data <- as.data.frame(t(demo_total_data))
demo_total_data$label <- rownames(demo_total_data)
rownames(demo_total_data) <- NULL
colnames(demo_total_data) <- c("homeless", "pop", "label")
demo_total_data$homeless <- as.numeric(demo_total_data$homeless)
demo_total_data$pop <- as.numeric(demo_total_data$pop)
demo_total_data$label <- as.factor(demo_total_data$label)
demo_total_data <- demo_total_data %>%
  mutate(ratio_homeless = round(100 * homeless / demo_total_data[demo_total_data$label == "Total", "homeless"], 1)) %>%
  mutate(ratio_pop = round(100 * pop / demo_total_data[demo_total_data$label == "Total", "pop"], 1)) 
  
write.csv(demo_total_data, "../data/demo_total_data.csv", row.names=FALSE)