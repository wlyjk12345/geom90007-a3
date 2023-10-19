get_icon <- function(description) {
    switch(description,
           "Cafes and Restaurants" = "icon/cafe.png",
           "Takeaway Food Services" = "icon/takeout_food.png",
           "Pubs, Taverns and Bars" = "icon/bar.png",
           "Accommodation" = "icon/accomodation.png",
           "Bakery Product Manufacturing (Non-factory based)" = "icon/bakery.png"
    )
  }

  wifi_icon <- makeIcon(
    iconUrl = "icon/wifi.png",
    iconWidth = 25,
    iconHeight = 25
  )
  
  tram_icon <- makeIcon(
    iconUrl = "icon/tram.png",
    iconWidth = 25,
    iconHeight = 25
  )
  
  bus_icon <- makeIcon(
    iconUrl = "icon/bus.png",
    iconWidth = 25,
    iconHeight = 25
  )
  
  bike_icon <- makeIcon(
    iconUrl = "icon/bike.png",
    iconWidth = 25,
    iconHeight = 25
  )