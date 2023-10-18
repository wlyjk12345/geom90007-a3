server <- function(input, output) {
  cafes_data$iconUrl <- sapply(cafes_data$industry_anzsic4_description, get_icon)
  
  output$map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$OpenStreetMap) %>%
      setView(144.9631, -37.8136, zoom = 16) %>%
      addMarkers(data = cafes_data,
                 ~longitude, ~latitude,
                 icon = ~makeIcon(iconUrl = iconUrl, iconWidth = 25, iconHeight = 25),
                 popup = ~paste("<strong>", trading_name, "</strong><br>", business_address))
  })
  
  observe({
    filtered_data <- cafes_data %>% dplyr::filter(industry_anzsic4_description %in% input$filter)
    
    leafletProxy("map") %>%
      clearMarkers() %>%
      addMarkers(data = filtered_data,
                 ~longitude, ~latitude,
                 icon = ~makeIcon(iconUrl = iconUrl, iconWidth = 25, iconHeight = 25),
                 popup = ~paste("<strong>", trading_name, "</strong><br>", business_address))
  })
  
  observeEvent(input$go, {
    filtered_data <- cafes_data %>% 
      dplyr::filter(grepl(input$geocode, trading_name, ignore.case = TRUE))
    
    proxy <- leafletProxy("map") %>%
      clearMarkers()
    
    if(nrow(filtered_data) > 0) {
      bounds <- c(
        range(filtered_data$latitude),
        range(filtered_data$longitude)
      )
      proxy <- proxy %>% fitBounds(bounds[3], bounds[1], bounds[4], bounds[2])
    }
    
    proxy %>%
      addMarkers(data = filtered_data,
                 ~longitude, ~latitude,
                 icon = ~makeIcon(iconUrl = iconUrl, iconWidth = 25, iconHeight = 25),
                 popup = ~paste("<strong>", trading_name, "</strong><br>", business_address))
  })
  
  ################For Local Facilities#######################
  output$newTabMap <- renderLeaflet({
    map <- leaflet() %>%
      addProviderTiles(providers$OpenStreetMap) %>%
      setView(144.9631, -37.8136, zoom = 16) %>%
      addMarkers(data = wifi_data, ~Longitude, ~Latitude, 
                 icon = ~wifi_icon,popup = ~paste(Name, "<br>", Long.Name, "<br>Type:", Type, "<br>Status:", Status),
                 group = "wifiLayer")%>%
      addMarkers(data = tram_stops,
                 ~Longitude, ~Latitude,
                 icon = ~tram_icon,
                 popup = ~paste(name, "<br>", stop_no),
                 group = "tramLayer")%>%
      addMarkers(data = bus_stops,
                 ~Longitude, ~Latitude,
                 icon = ~bus_icon,
                 popup = ~paste(Name, "<br>", Stop.Number,"<br>",Address),
                 group = "busLayer")%>%
      addMarkers(data = bike_share_dock,
                 ~lon, ~lat,
                 icon = ~bike_icon,
                 popup = ~paste(name, "<br>", capacity),
                 group = "bikeLayer")
    map <- addPolylines(map, data = coordinates_df, 
                        lng = ~lon, lat = ~lat, 
                        color = "blue", group = "routeLayer")
  })
  
  observe({
    # Re-initialize the map
    leafletProxy("newTabMap") %>% clearMarkers()
    leafletProxy("newTabMap") %>% clearShapes()
    
    if ("WiFi" %in% input$newTabFilter) {
      leafletProxy("newTabMap") %>%
        addMarkers(data = wifi_data, ~Longitude, ~Latitude, 
                   icon = ~wifi_icon, popup = ~paste(Name, "<br>", Long.Name, "<br>Type:", Type, "<br>Status:", Status))
    }
    
    if ("Tram Stops" %in% input$newTabFilter) {
      leafletProxy("newTabMap") %>%
        addMarkers(data = tram_stops, ~Longitude, ~Latitude, 
                   icon = ~tram_icon, popup = ~paste(name, "<br>", stop_no))
    }
    
    if ("Bus Stops" %in% input$newTabFilter) {
      leafletProxy("newTabMap") %>%
        addMarkers(data = bus_stops, ~Longitude, ~Latitude, 
                   icon = ~bus_icon, popup = ~paste(Name, "<br>", Stop.Number, "<br>", Address))
    }
    
    if ("Bike Share Docks" %in% input$newTabFilter) {
      leafletProxy("newTabMap") %>%
        addMarkers(data = bike_share_dock, ~lon, ~lat, 
                   icon = ~bike_icon, popup = ~paste(name, "<br>", capacity))
    }
    if ("Routes" %in% input$newTabFilter) {
        leafletProxy("newTabMap") %>%
            addPolylines(data = coordinates_df, 
                         lng = ~lon, lat = ~lat, 
                         color = "blue")
    }
  })
  
  ################For Weather#######################
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