server <- function(input, output) {
  cafes_data <- st_read("cafes-and-restaurants-with-seating-capacity.geojson")
  cafes_data <- cafes_data %>% 
    dplyr::filter(!st_is_empty(geometry) & 
                    industry_anzsic4_description == "Cafes and Restaurants" & 
                    number_of_seats >= 50)
  coords <- st_coordinates(st_geometry(cafes_data))
  cafes_data$longitude <- coords[, "X"]
  cafes_data$latitude <- coords[, "Y"]
  
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles(paste0("https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}&key=", google_api_key)) %>%
      setView(144.9631, -37.8136, zoom = 10) %>%  
      addMarkers(data = cafes_data, 
                 ~longitude, ~latitude,
                 popup = ~paste("<strong>", trading_name, "</strong><br>", business_address),
                 clusterOptions = markerClusterOptions())
  })
  
  observeEvent(input$go, {
    leafletProxy("map") %>%
      clearMarkers() %>%
      addMarkers(data = cafes_data, 
                 ~longitude, ~latitude,
                 popup = ~paste("<strong>", trading_name, "</strong><br>", business_address),
                 clusterOptions = markerClusterOptions())
  })
}

shinyApp(ui, server)