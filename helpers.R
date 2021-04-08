state <- as_tibble(read.csv(file = 'data/state.csv', header = TRUE, sep = ","))
state <- state[state$region != "district of columbia",]
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
