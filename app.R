#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
library(plotly)
library(parallel)

options(scipen=999)
options(warn = -1)

source("helpers.R")

# Define UI for application that draws a histogram
ui <- navbarPage("R Project: US Elections & data",
    
    tabPanel("Electoral Vote Map",
        sidebarLayout(
            sidebarPanel(
                selectInput("year2", label = h3("Year's election"), 
                            choices = c("1980","1984","1988","1992","1996","2000","2004","2008","2012","2016","2020"), 
                            selected = "2020"),
                radioButtons("var2", label = h3("Map"),
                             choices = c("Party share", "Midterm Election", "Winner Party"), 
                             selected = "Party share"),
                width = 3
            ),
    
            # Show a plot of the generated distribution
            mainPanel(plotOutput("electoralmap"))
        )
    ),
    tabPanel("Data Map",
             sidebarLayout(
                 sidebarPanel(
                     selectInput("year", label = h3("Year's election"), 
                                 choices = c("1980","1984","1988","1992","1996","2000","2004","2008","2012","2016","2020"), 
                                 selected = "2020"),
                     selectInput("var", label = h3("Select variable"), 
                                 choices = c("Real GDP chained to 2012", "Population", "Population density", "Real Per Capita GDP chained to 2012", "Growth","Percentage of Over 65 y.o.", "High level of education" ,"Unemployment", "Number of Great Electors")
                     ),
                     width = 3
                 ),
                 
                 # Show a plot of the generated distribution
                 mainPanel(plotOutput("map"))
             )
    ),
    tabPanel("Plot",
             fluidPage(
                 sidebarPanel(
                     selectInput("year1", label = h3("Year's election"), 
                                 choices = c("1980","1984","1988","1992","1996","2000","2004","2008","2012","2016","2020"), 
                                 selected = "2020"),
                     selectInput("var1", label = h3("Select variable"), 
                                 choices = c("Party share", "Real GDP chained to 2012", "Population", "Population density", "Real Per Capita GDP chained to 2012", "Growth","Percentage of Over 65 y.o.", "High level of education" ,"Unemployment", "Midterm Election", "Number of Great Electors")
                                 ),
                     checkboxGroupInput("stategroup", label = h3("States"), 
                                        #choices = unique(join_state$region),
                                        choices = regions,
                                        selected = regions)
                 ),
                 
                 # Show a plot of the generated distribution
                 mainPanel(plotlyOutput("plot"), height = "auto")
             )        
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    
    output$plot <- renderPlotly({
        d <- subset(dataset, dataset$year == input$year1 & dataset$states %in% input$stategroup)
        Value <- switch(input$var1, 
                    "Party share" = d$share_d,
                    "Real GDP chained to 2012" = d$real_gdp,
                    "Population" = d$population,
                    "Population density" = d$density,
                    "Real Per Capita GDP chained to 2012" = d$real_pc_gdp,
                    "Percentage of Over 65 y.o." = d$perc_over,
                    "High level of education" = d$highlev_educ,
                    "Unemployment" = d$unemployment,
                    "Growth" = d$growth,
                    "Midterm Election" = d$new_midterm,
                    "Number of Great Electors" = d$Great_El)
            
        State <- input$stategroup
        
        plot <- ggplot(d, aes(State, Value)) + geom_bar(stat = "identity", color = "violetred", fill = "mistyrose1") + labs(x = "States", y = input$var1) + coord_flip()  + theme_minimal()
        #+ geom_text(aes(label=round(y, digits = 2)), hjust = "inward", color="black") 
            
        ggplotly(plot, height = 1500)
    })
    
    output$electoralmap <- renderPlot({
        
        data <- switch(input$var2, 
                       "Party share" = join_state$share_d[join_state$year == input$year2],
                       "Midterm Election" = join_state$new_midterm[join_state$year == input$year2],
                       "Winner Party" = join_state$share_d[join_state$year == input$year2])
        colour <- c("red","blue")
        
        custom_map(join_state[join_state$year == input$year2,], data, input$var2, colour)
    })
    
    output$map <- renderPlot({
        
        data <- switch(input$var, 
                       "Real GDP chained to 2012" = join_state$real_gdp[join_state$year == input$year],
                       "Population" = join_state$population[join_state$year == input$year],
                       "Population density" = join_state$density[join_state$year == input$year],
                       "Real Per Capita GDP chained to 2012" = join_state$real_pc_gdp[join_state$year == input$year],
                       "Percentage of Over 65 y.o." = join_state$perc_over[join_state$year == input$year],
                       "High level of education" = join_state$highlev_educ[join_state$year == input$year],
                       "Unemployment" = join_state$unemployment[join_state$year == input$year],
                       "Growth" = join_state$growth[join_state$year == input$year],
                       "Number of Great Electors" = join_state$Great_El[join_state$year == input$year])
        colour <- switch(input$var, 
                       "Real GDP chained to 2012" = c("red","green"),
                       "Population" = c("white","violetred"),
                       "Population density" = c("white","blue"),
                       "Real Per Capita GDP chained to 2012" = c("red","green"),
                       "Percentage of Over 65 y.o." = c("yellow","brown"),
                       "High level of education" = c("lightblue","violet"),
                       "Unemployment" = c("yellow","darkgrey"),
                       "Growth" = c("red","green"),
                       "Number of Great Electors" = c("white","pink"))
        
        custom_map(join_state[join_state$year == input$year,], data, input$var, colour)
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
