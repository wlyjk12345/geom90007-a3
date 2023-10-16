ui <- fluidPage(
  titlePanel("Melbourne facility"),
  tabsetPanel(
    tabPanel("Search Facilities", 
             sidebarLayout(
               sidebarPanel(
                 h3("Search "),
                 textInput("geocode", "Type the name", placeholder = "e.g., McDonald"),
                 actionButton("go", "Search!"),
                 br(),
                 checkboxGroupInput("filter", "Filter by category:",
                                    choices = c("Cafes and Restaurants", "Takeaway Food Services", 
                                                "Pubs, Taverns and Bars", "Accommodation", 
                                                "Bakery Product Manufacturing (Non-factory based)"),
                                    selected = c("Cafes and Restaurants", "Takeaway Food Services", 
                                                 "Pubs, Taverns and Bars", "Accommodation", 
                                                 "Bakery Product Manufacturing (Non-factory based)")),
                 helpText("Use the search bar to find facility in Melbourne.")
               ),
               mainPanel(
                 leafletOutput("map", height = 1000, width = 600)
               )
             )),
    tabPanel("New Tab", 
             sidebarLayout(
               sidebarPanel(
                 h3("Filter Local Facilities"),
                 checkboxGroupInput("newTabFilter", "Filter by type:",
                                    choices = c("WiFi", "Tram Stops", "Bus Stops", "Bike Share Docks", "Routes"),
                                    selected = c("WiFi", "Tram Stops", "Bus Stops", "Bike Share Docks", "Routes")),
                 helpText("Filter the local facilities shown on the map.")
               ),
               mainPanel(
                 leafletOutput("newTabMap", height = 1000, width = 600)
               )
             ))
  )
)