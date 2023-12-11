library(tidyverse)
library(stringr)

coc_data <- read_csv("../data/2022-PIT-Counts-by-CoC.csv")
load("../data/County_2017den.rda")
county_data <- read_csv("../data/co-est2022-alldata.csv")

coc_data <- coc_data %>%
  select(c("CoC Number", "CoC Name", "CoC Category", "Overall Homeless, 2022"))

county_to_coc <- County_2017den %>% 
  select(c("cnamecounty", "cocnum", "state")) %>%
  rename(`CoC Number` = cocnum, CTYNAME = cnamecounty, STNAME = state) %>%
  na.omit()

coc_total_data <- inner_join(county_data, county_to_coc,
                              by = c("CTYNAME", "STNAME")) %>%
  group_by(`CoC Number`) %>%
  summarise(pop = sum(POPESTIMATE2022, na.rm = TRUE)) %>%
  right_join(coc_data, by = "CoC Number") %>%
  rename(COCNUM = `CoC Number`)

coc_total_data$pop[coc_total_data$`CoC Name` == "Lexington-Fayette County CoC"] <- 320347
coc_total_data$pop[coc_total_data$`CoC Name` == "Connecticut Balance of State CoC"] <- 3626205 - 623290 - 327229
coc_total_data$pop[coc_total_data$`CoC Name` == "Athens-Clarke County CoC"] <- 129185
coc_total_data$pop[coc_total_data$`CoC Name` == "Attleboro, Taunton/Bristol County CoC" ] <- 579895
coc_total_data$pop[coc_total_data$`CoC Name` == "Augusta-Richmond County CoC"] <- 205358
coc_total_data$pop[coc_total_data$`CoC Name` == "Bridgeport, Stamford, Norwalk, Danbury/Fairfield County CoC"] <- 623290 + 327229
coc_total_data$pop[coc_total_data$`CoC Name` == "Dearborn, Dearborn Heights, Westland/Wayne County CoC"] <- 1773073
coc_total_data$pop[coc_total_data$`CoC Name` == "DuPage County CoC"] <- 926448
coc_total_data$pop[coc_total_data$`CoC Name` == "Durham City & County CoC"] <- 329699
coc_total_data$pop[coc_total_data$`CoC Name` == "Eaton County CoC"] <- 109030
coc_total_data$pop[coc_total_data$`CoC Name` == "Fort Collins, Greeley, Loveland/Larimer, Weld Counties CoC"] <- 362713 + 339811
coc_total_data$pop[coc_total_data$`CoC Name` == "Kansas City, Independence, Lee’s Summit/Jackson, Wyandotte Counties, MO & KS"] <- 717616 + 167290
coc_total_data$pop[coc_total_data$`CoC Name` == "Louisville-Jefferson County CoC"] <- 777378
coc_total_data$pop[coc_total_data$`CoC Name` == "Maryland Balance of State CoC"] <- 28757 + 67691 + 155197 + 114664 + 168870 + 104096
coc_total_data$pop[coc_total_data$`CoC Name` == "Cook County CoC"] <- 5177606
coc_total_data$pop[coc_total_data$`CoC Name` == "McHenry County CoC"] <- 311592
coc_total_data$pop[coc_total_data$`CoC Name` == "Nashua/Hillsborough County CoC"] <- 424496
coc_total_data$pop[coc_total_data$`CoC Name` == "Nashville-Davidson County CoC"] <- 703372
coc_total_data$pop[coc_total_data$`CoC Name` == "Nevada County CoC"] <- 103457
coc_total_data$pop[coc_total_data$`CoC Name` == "Norman/Cleveland County CoC"] <- 298099
coc_total_data$pop[coc_total_data$`CoC Name` == "Salem/Marion, Polk Counties CoC"] <- 347775 + 89384
coc_total_data$pop[coc_total_data$`CoC Name` == "Massachusetts Balance of State CoC"] <- 1617099 + 724692 + 807485
coc_total_data$pop[coc_total_data$`CoC Name` == "Atlanta CoC"] <- 496461
coc_total_data$pop[coc_total_data$`CoC Name` == "Cambridge CoC"] <- 117090
coc_total_data$pop[coc_total_data$`CoC Name` == "Chicago CoC"] <- 2665039
coc_total_data$pop[coc_total_data$`CoC Name` == "Glendale CoC"] <- 192366
coc_total_data$pop[coc_total_data$`CoC Name` == "Guam CoC"] <- 170534
coc_total_data$pop[coc_total_data$`CoC Name` == "Long Beach CoC"] <- 456062
coc_total_data$pop[coc_total_data$`CoC Name` == "New Bedford CoC"] <- 100941
coc_total_data$pop[coc_total_data$`CoC Name` == "Pasadena CoC"] <- 135732
coc_total_data$homeless_ratio <- round(coc_total_data$`Overall Homeless, 2022` / coc_total_data$pop * 10000, 1)

coc_total_data <- na.omit(coc_total_data) %>%
  mutate(is_king = ifelse(`CoC Name` == "Seattle/King County CoC", "TRUE", "FALSE"))

breaks <- c(seq(0, 40, by = 5), max(coc_total_data$homeless_ratio, na.rm = TRUE) + 1)
coc_total_data$class <- cut(coc_total_data$homeless_ratio, breaks = breaks, labels = FALSE, 
                      include.lowest = TRUE, right = FALSE)
coc_total_data$class <- as.factor(coc_total_data$class)
write.csv(coc_total_data, "../data/coc_total_data.csv", row.names=FALSE)
