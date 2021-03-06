pkg_loading <- function(){
  if(!require('pacman'))install.packages('pacman')
  pacman::p_load(shiny,tidyverse,mapproj,plotly,parallel)
}

pkg_loading()

dataset <- read.csv(file = 'data/us_election.csv', header = TRUE, sep = ";")

# slight fix for column name "year"
colnames(dataset)[1] <- "year"
dataset$states <- tolower(dataset$states)


state<-as_tibble(map_data("state"))    
join_state <- state %>%
  left_join(dataset, by = c("region" = "states"))

# remove district of columbia region
state <- state[state$region != "district of columbia",]
join_state <- join_state[join_state$region != "district of columbia",]
dataset <- dataset[dataset$states != "district of columbia",]

cl <- makeCluster(detectCores()-1)
clusterExport(cl, "join_state")
regions <- parLapply(cl = cl, unique(join_state$region), invisible)

custom_map <- function (data, var, name, color){
  if(name == "Party share" || name == "Mid Term Election") {
    mean <- 50
  } else if (name == "Growth") {
    mean <- 0
  } else {
    mean <- mean(var)
  }
  
  if (name == "Party share" || name == "Growth" || name == "Midterm Election") {
    data %>%
      ggplot(aes(long, lat, group = subregion)) +
      geom_map (
        aes(map_id = region),
        map = state,
        color = "gray80", fill = "white", size = 0.3
      ) +
      coord_map("ortho", orientation = c(39,-98,0)) +
      geom_polygon(aes(group = group, fill = var), color= "black") +
      scale_fill_gradient2(low = color[1], mid = "white", high = color[2],
                           midpoint = mean ) +
      theme_minimal() +
      labs(
        title = name,
        x = "", y = "", fill = ""
      ) + 
      theme(
        plot.title = element_text(size=26, face="bold", color="blue3"),
        #legend.position = "bottom"
      ) 
  } else if (name == "Winner Party") {
    winner <- var >= 50
    data %>%
      ggplot(aes(long, lat, group = subregion)) +
      geom_map (
        aes(map_id = region),
        map = state,
        color = "gray80", fill = "white", size = 0.3
      ) +
      coord_map("ortho", orientation = c(39,-98,0)) +
      geom_polygon(aes(group = group, fill = winner), color= "black") +
      scale_fill_manual(values = color, labels = c("REP","DEM")) +
      theme_minimal() +
      labs(
        title = name,
        x = "", y = "", fill = ""
      ) + 
      theme(
        plot.title = element_text(size=26, face="bold", color="blue3"),
        #legend.position = "bottom"
      ) 
  } else {
    data %>%
      ggplot(aes(long, lat, group = subregion)) +
      geom_map (
        aes(map_id = region),
        map = state,
        color = "gray80", fill = "white", size = 0.3
      ) +
      coord_map("ortho", orientation = c(39,-98,0)) +
      geom_polygon(aes(group = group, fill = var), color= "black") +
      scale_fill_gradient(low = color[1], high = color[2]) +
      theme_minimal() +
      labs(
        title = name,
        x = "", y = "", fill = ""
      ) + 
      theme(
        plot.title = element_text(size=26, face="bold", color="blue3"),
        #legend.position = "bottom"
      ) 
  }
}

