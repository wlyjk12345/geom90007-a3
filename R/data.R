source("libraries.R")
wifi_data <- read.csv("../data/Melbourne_wifi.csv", header = TRUE, stringsAsFactors = FALSE)
  wifi_data$Long.Name <- iconv(wifi_data$Long.Name, from = "UTF-8", to = "UTF-8", sub = "")
  wifi_data$Long.Name <- gsub("<a0>", " ", wifi_data$Long.Name)
  wifi_data$Long.Name <- gsub("[[:space:]]+", " ", wifi_data$Long.Name)
  wifi_data <- dplyr::filter(wifi_data, startsWith(Long.Name, "MEL") & Type == "Mesh")
  
  tram_stops <- read.csv("../data/city-circle-tram-stops.csv", header = TRUE, stringsAsFactors = FALSE)
  tram_stops$Latitude <- as.numeric(sapply(strsplit(tram_stops$`Geo.Point`, ","), `[`, 1))
  tram_stops$Longitude <- as.numeric(sapply(strsplit(tram_stops$`Geo.Point`, ","), `[`, 2))
  
  bus_stops <- read.csv("../data/bus-stops-for-melbourne-visitor-shuttle.csv", header = TRUE, stringsAsFactors = FALSE)
  bus_stops$Latitude <- as.numeric(sapply(strsplit(bus_stops$`Co.ordinates`, ","), `[`, 1))
  bus_stops$Longitude <- as.numeric(sapply(strsplit(bus_stops$`Co.ordinates`, ","), `[`, 2))
  
  bike_share_dock <- read.csv("../data/bike-share-dock-locations.csv", header = TRUE, stringsAsFactors = FALSE)
  
  tram_route <- read.csv("../data/city-circle-tram-route.csv", header = TRUE, stringsAsFactors = FALSE)
  parsed_data <- fromJSON(tram_route$Geo.Shape[1])
  longitude <- parsed_data$coordinates[1, , 1]
  latitude <- parsed_data$coordinates[1, , 2]
  coordinates_df <- data.frame(
    lon = longitude,
    lat = latitude
  )
  
  cafes_data <- st_read("../data/cafes-and-restaurants-with-seating-capacity.geojson")
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