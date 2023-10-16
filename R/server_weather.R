# Importing libraries
library(shiny)
library(stringr)
library(shinythemes)
library(shinyWidgets)
library(fontawesome)
library(leaflet)
library(plotly)
library(shinydashboard)
library(igraph)
library(highcharter)
library(dplyr)
library(tidyr)
library(owmr)
library(lubridate)
library(rgdal)
library(dashboardthemes)
source("helper.R")

# Define UI for application that draws a histogram
header <- dashboardHeader(
  # Define the header and insert image as title
  title = tags$a(tags$img(src='https://bit.ly/3rFI94P',
                          height='55', width='160')),
  titleWidth = 250
)

sidebar <- dashboardSidebar(
  width = 250,
  sidebarMenu(
    menuItem("Melbourne Weather",
             tabName = "weather",
             icon = icon('sun')),
    menuItem("Setting",
             tabName = "setting",
             icon = icon("gear"),
             radioButtons("displaymode", "Display Mode", choices = c('Light Mode' = 'lightMode', 'Dark Mode' = 'darkMode'), selected="lightMode")
    )
  )
)

body <- dashboardBody(
  uiOutput("myTheme"),
  tabItems(

    tabItem("weather",
            fluidPage(
              h2(HTML(paste("Current Weather of Melbourne", 
                            "<br>", 
                            format(as_datetime(current_weather$dt, tz = "Australia/Melbourne"), "%b %d %Y, %A"))),
                 align = "center"),
              hr(),
              
              # Value box
              fluidRow(
                column(6, valueBoxOutput("cur_temp", width = 15)),
                column(6, valueBoxOutput("temp_range", width = 15))
              ),
              fluidRow(
                column(6, valueBoxOutput("current_condition", width = 15)),
                column(6, valueBoxOutput("rain_5hr", width = 15))
              ),
              fluidRow(
                column(6, valueBoxOutput("sunrise", width = 15)),
                column(6, valueBoxOutput("sunset", width = 15))
              ),
              hr(),
              h2("Weather Forecast of Melbourne", align = "center"), 
              hr(),
              fluidRow(
                column(6, highchartOutput("weather_forecast", height = 300)),
                column(6, highchartOutput("wind_speed_forecast", height = 300))
              ),
              hr(),
              fluidRow(
                column(6, highchartOutput("humidity_forecast", height = 300)),
                column(6, highchartOutput("precipitation_forecast", height = 300))
              ),
              hr(),
              h5('Live Weather Data Source from: ', 
                 a("OpenWeather",
                   href="https://openweathermap.org"))
            )
    )
  )
)

# Putting the UI together
ui <- dashboardPage(
  title = "Visiting Melbourne",
  header, 
  sidebar, 
  body
)

# Server

server_weather <- function(input, output) {
  output$cur_temp <- renderValueBox(
    valueBox(
      value = tags$p(paste(round(current_weather$main$temp), "ºC"), style = "font-size: 85%;"), 
      subtitle = paste("Currently feels like", round(current_weather$main$feels_like), "ºC"),
      icon = fa_i("fas fa-temperature-three-quarters"), 
      color = "aqua"
    )
  )
  
  output$temp_range <- renderValueBox(
    valueBox(
      value = tags$p(paste(round(current_weather$main$temp_min), "ºC -", 
                           round(current_weather$main$temp_max), "ºC"), 
                     style = "font-size: 85%;"),
      subtitle = paste("Temperature ranges from ", round(current_weather$main$temp_min), "ºC to ",
                       round(current_weather$main$temp_max), "ºC"),
      icon = fa_i("fas fa-temperature-arrow-up"), 
      color = "yellow"
    )
  )
  
  output$rain_5hr <- renderValueBox({
    next_5hrs <- forecast_df[1:5, ]
    total_rain_5hrs <- sum(next_5hrs$rain, na.rm = TRUE)
    
    valueBox(
      value = tags$p(paste(total_rain_5hrs, "mm"), style = "font-size: 85%;"),
      subtitle = "Rainfall in the next 5 hours",
      icon = fa_i("fas fa-cloud-rain"),
      color = "blue"
    )
  })
  
  output$current_condition <- renderValueBox({
    # Example decision for icons based on weather description
    weather_icon <- switch(
      str_to_lower(current_weather$weather$description),
      "clear sky" = "fas fa-sun",
      "few clouds" = "fas fa-cloud-sun",
      "scattered clouds" = "fas fa-cloud",
      "broken clouds" = "fas fa-cloud-meatball",
      "shower rain" = "fas fa-cloud-showers-heavy",
      "rain" = "fas fa-cloud-rain",
      "thunderstorm" = "fas fa-bolt",
      "snow" = "fas fa-snowflake",
      "mist" = "fas fa-smog",
      "fas fa-question"  # Default icon for other conditions
    )
    
    valueBox(
      value = tags$p(str_to_title(current_weather$weather$description), 
                     style = "font-size: 85%;"), 
      subtitle = "Current weather condition",
      icon = fa_i(weather_icon), color = "teal"
    )
  })
  
  
  output$sunset <- renderValueBox(
    valueBox(
      value = tags$p(substr(
        as_datetime(current_weather$sys$sunset, 
                    tz = "Australia/Melbourne"), 12, 16), style = "font-size: 85%;"), 
      subtitle = "Expected Sunset Time",
      icon = tags$i(class = "fas fa-moon"), color = "purple"
    )
  )
  
  output$sunrise <- renderValueBox({
    valueBox(
      value = tags$p(substr(as_datetime(current_weather$sys$sunrise, 
                                        tz = "Australia/Melbourne"), 12, 16), 
                     style = "font-size: 85%;"),
      subtitle = "Expected Sunrise Time",
      icon = fa_i("fas fa-sun"),
      color = "orange"
    )
  })
  
  
  output$weather_forecast <- renderHighchart({
    if (input$displaymode == "lightMode"){
      hc_theme = hc_theme_smpl()
    } else{
      hc_theme = hc_theme_db()
    }
    forecast_df$tmstmp <- datetime_to_timestamp(forecast_df$tmstmp)
    
    forecast_df %>%
      hchart("spline", hcaes(x = tmstmp, y = temp)) %>%
      hc_xAxis(type = "datetime",
               tickInterval = 24 * 3600 * 1000,
               dateTimeLabelFormats = list(day='%d %b %Y'), 
               labels = list(enabled = TRUE, format = '{value:%Y-%m-%d}'),
               title = list(text = "")) %>%
      hc_yAxis(title = list(text = "Temperature"), 
               labels = list(format = "{value} ºC")) %>%
      hc_title(text = "Temperature Forecast in the Next 5 Days") %>%
      hc_tooltip(pointFormat = "<br/>Temperature: <b>{point.temp} ºC</b>
                 <br/>Feels Like: <b>{point.fl_temp} ºC</b>") %>%
      hc_plotOptions(series = list(animation = list(duration = 2500))) %>%
      hc_colors("#E6CC00") %>%
      hc_add_theme(hc_theme)
  })
  
  output$precipitation_forecast <- renderHighchart({
    if (input$displaymode == "lightMode"){
      hc_theme = hc_theme_smpl()
    } else{
      hc_theme = hc_theme_db()
    }
    forecast_df$tmstmp <- datetime_to_timestamp(forecast_df$tmstmp)
    
    forecast_df %>%
      hchart("line", hcaes(x = tmstmp, y = pop)) %>%
      hc_xAxis(type = "datetime",
               tickInterval = 24 * 3600 * 1000,
               dateTimeLabelFormats = list(day='%d %b %Y'), 
               labels = list(enabled = TRUE, format = '{value:%Y-%m-%d}'),
               title = list(text = "")) %>%
      hc_yAxis(title = list(text = "Probability of Precipitation"), 
               labels = list(format = "{value}%"), 
               max = 100,
               min = 0) %>%
      hc_title(text = "Probability of Precipitation in the Next 5 Days") %>%
      hc_tooltip(pointFormat = "<br/>Probability of Precipitation: <b>{point.y}%</b>") %>%
      hc_plotOptions(series = list(animation = list(duration = 2500))) %>%
      hc_colors("#4285F4") %>%
      hc_add_theme(hc_theme)
  })
  
  
  
  
  output$wind_speed_forecast <- renderHighchart({
    if (input$displaymode == "lightMode"){
      hc_theme = hc_theme_smpl()
    } else{
      hc_theme = hc_theme_db()
    }
    forecast_df$tmstmp <- datetime_to_timestamp(forecast_df$tmstmp)
    
    forecast_df %>%
      hchart("spline", hcaes(x = tmstmp, y = wind_speed)) %>%
      hc_xAxis(type = "datetime",
               tickInterval = 24 * 3600 * 1000,
               dateTimeLabelFormats = list(day='%d %b %Y'), 
               labels = list(enabled = TRUE, format = '{value:%Y-%m-%d}'),
               title = list(text = "")) %>%
      hc_yAxis(title = list(text = "Wind Speed"), 
               labels = list(format = "{value} m/s")) %>%
      hc_title(text = "Wind Speed Forecast in the Next 5 Days") %>%
      hc_tooltip(pointFormat = "<br/>Wind Speed: <b>{point.wind_speed} m/s</b>") %>%
      hc_plotOptions(series = list(animation = list(duration = 2500))) %>%
      hc_colors("teal") %>%
      hc_add_theme(hc_theme)
  })
  
  output$humidity_forecast <- renderHighchart({
    if (input$displaymode == "lightMode"){
      hc_theme = hc_theme_smpl()
    } else{
      hc_theme = hc_theme_db()
    }
    forecast_df$tmstmp <- datetime_to_timestamp(forecast_df$tmstmp)
    
    forecast_df %>%
      hchart("spline", hcaes(x = tmstmp, y = humidity)) %>%
      hc_xAxis(type = "datetime",
               tickInterval = 24 * 3600 * 1000,
               dateTimeLabelFormats = list(day='%d %b %Y'), 
               labels = list(enabled = TRUE, format = '{value:%Y-%m-%d}'),
               title = list(text = "")) %>%
      hc_yAxis(title = list(text = "Humidity"), 
               labels = list(format = "{value}%")) %>%
      hc_title(text = "Humidity Forecast in the Next 5 Days") %>%
      hc_tooltip(pointFormat = "<br/>Forecast: <b>{point.humidity}%</b>") %>%
      hc_plotOptions(series = list(animation = list(duration = 2500))) %>%
      hc_colors("#80b1d3") %>%
      hc_add_theme(hc_theme)
  })
}


shinyApp(ui, server_weather)