server <- function(input, output) {
  cafes_data <- st_read("cafes-and-restaurants-with-seating-capacity.geojson")
  selected_categories <- c("Cafes and Restaurants", "Takeaway Food Services", "Pubs, Taverns and Bars", "Accommodation", "Bakery Product Manufacturing (Non-factory based)")
  cafes_data <- cafes_data %>%
    dplyr::filter(census_year == "2021" & industry_anzsic4_description %in% selected_categories & !st_is_empty(geometry)) %>%
    group_by(business_address, longitude, latitude, industry_anzsic4_description) %>% 
    summarise(
      total_seats = sum(number_of_seats, na.rm = TRUE),
      trading_name = first(trading_name)
    ) %>% 
    ungroup()
  
  coords <- st_coordinates(st_geometry(cafes_data))
  cafes_data$longitude <- coords[, "X"]
  cafes_data$latitude <- coords[, "Y"]
  
  get_icon <- function(description) {
    switch(description,
           "Cafes and Restaurants" = "icon/cafe.png",
           "Takeaway Food Services" = "icon/takeout_food.png",
           "Pubs, Taverns and Bars" = "icon/bar.png",
           "Accommodation" = "icon/accomodation.png",
           "Bakery Product Manufacturing (Non-factory based)" = "icon/bakery.png"
    )
  }
  
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
  
}