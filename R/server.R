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
  
  
}