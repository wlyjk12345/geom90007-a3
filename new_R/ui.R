source("helper.R")
# A dashboard header with 3 dropdown menus
headers <- dashboardHeader(
  title = tags$a(tags$img(src='https://bit.ly/3rFI94P',
                          height='55', width='160')),
  titleWidth = 250
)

sidebar <- dashboardSidebar(
  width = 250,
  sidebarMenu(
    # Tab for different visualisation
    menuItem("Home",
             tabName = "home",
             selected = T,
             icon = icon('thumbs-up')),
    menuItem("Melbourne Points of Interest",
             tabName = "poi",
             icon = icon('map-location-dot')),
    menuItem("Melbourne Weather",
             tabName = "weather",
             icon = icon('sun')),
    menuItem("Pedestrian Volume Monitor",
             tabName = "pedestrain",
             icon = icon("users")),
    menuItem("Tourist Amenities",
             tabName = "tour",
             icon = icon('plane')),
    menuItem("FAQs",
             tabName = "faqs",
             icon = icon("question")),
    menuItem("Setting",
             tabName = "setting",
             icon = icon("gear"),
             radioButtons("displaymode", "Display Mode", choices = c('Light Mode' = 'lightMode', 'Dark Mode' = 'darkMode'), selected="lightMode"))
  )
)

intro_panel <- tabPanel(
  title = "Intro",
  class = "page-1",
  fluidPage(
    fluidRow(
      includeHTML("home.html"),
      
      tags$h1(class = "shiny-title","Pedestrian Density Map"),  # Add the title here
      tags$hr(),
      tags$p(class = "shiny-p","Explore Melbourne's lively foot traffic with our Pedestrian Density Map. 
             Uncover popular streets and bustling walkways, perfect for strolling through iconic neighborhoods. Gain valuable insights into the city's vibrant, walkable environment and discover Melbourne on foot with ease."),  # Add the description here
      
      fluidRow(
        column(12, 
               tableauPublicViz(
                 id = "tableauviz1",
                 url = "https://public.tableau.com/views/Pedestrain_Map/1_1?:language=en-US&publish=yes&:display_count=n&:origin=viz_share_link"
               )
        )
      ),
      
      tags$hr(),
      tags$h5(class = "footer-note",'Data Source from: ', 
              a("CoM Open Data Portal - City of Melbourne",
                href="https://data.melbourne.vic.gov.au/pages/home/")),
      tags$h5(class = "footer-note",'Tableau map deposit: ', 
              a("Xianrui Gao's Pedestrain_Map",
                href="https://public.tableau.com/app/profile/xianrui.gao/viz/Pedestrain_Map/1_1"))
    )
  )
)


faqs_panel <- tabPanel(
  title = "faqs",
  class = "page-1",
    fluidPage(
    fluidRow(
      includeHTML("faqs.html"),
  ),
)
)

poi_panel <- tabPanel("poi",
            fluidPage(
              tags$h1(class = "shiny-title","Melbourne Points of Interest"),  # Add the title here
              tags$hr(),
              tags$p(class = "shiny-p","Explore Melbourne with the Points of Interest Map. Discover cafes, restaurants, pubs, accommodation, and more. 
                     Filter your search and find your favorites with ease."),  # Add the description here        
    
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
               ),
              tags$hr(),
              tags$h5(class = "footer-note",'Data Source from: ', 
                      a("CoM Open Data Portal - City of Melbourne",
                        href="https://data.melbourne.vic.gov.au/pages/home/"))
            )
)

tour_panel <- tabPanel("tour", 
            fluidPage(
              tags$h1(class = "shiny-title","Tourist Amenities Map"),  # Add the title here
              tags$hr(),
              tags$p(class = "shiny-p","Discover essential tourist amenities at your fingertips with our Tourist Amenities Map. Find Wi-Fi hotspots, tram stops, bus stops, 
                    and more to make your visit to Melbourne convenient and enjoyable. Plan your journey and explore the city with ease, thanks to this handy map."),  # Add the description here        
                         
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
                ),
                tags$hr(),
                tags$h5(class = "footer-note",'Data Source from: ', 
                    a("CoM Open Data Portal - City of Melbourne",
                      href="https://data.melbourne.vic.gov.au/pages/home/"))
            )
)


weather_panel <- tabItem("weather",
                         fluidPage(
                           #h2(HTML(paste("Current Weather of Melbourne", 
                           #               "<br>", 
                           #              format(as_datetime(current_weather$dt, tz = "Australia/Melbourne"), "%b %d %Y, %A"))),
                           #    align = "center"),
                           h1(class = "shiny-title","Today Weather of Melbourne"),
                           hr(),
                           p(class = "shiny-p", HTML(paste("Today is",format(as_datetime(current_weather$dt, tz = "Australia/Melbourne"), "%b %d %Y, %A"), 
                                                           ". Melbourne's weather is known for its unpredictability, so it's a good idea to be prepared for all seasons in a single day." ))),
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
                           h1(class = "shiny-title","Weather Forecast of Melbourne"), 
                           hr(),
                           p(class = "shiny-p","access a 5-day weather forecast for Melbourne, offering key information on wind speed, weather conditions, humidity levels, and precipitation forecasts."),
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
                           h5(class = "footer-note",'Live Weather Data Source from: ', 
                              a("OpenWeather",
                                href="https://openweathermap.org"))
                         )
)


pedestrain_panel <- tabPanel("pedestrain",
                         fluidPage(
                         tags$h1(class = "shiny-title","Pedestrian Density Map"),  # Add the title here
                         tags$hr(),
                         tags$p(class = "shiny-p","Explore Melbourne's lively foot traffic with our Pedestrian Density Map. 
                                Uncover popular streets and bustling walkways, perfect for strolling through iconic neighborhoods. Gain valuable insights into the city's vibrant, walkable environment and discover Melbourne on foot with ease."),  # Add the description here        
                         
                         
                           #h2("Pedestrian Density Map",
                           #   align = "center"),
                           fluidRow(
                               column(12, 
                                    tableauPublicViz(
                                      id = "tableauviz1",
                                      url = "https://public.tableau.com/views/Pedestrain_Map/1_1?:language=en-US&publish=yes&:display_count=n&:origin=viz_share_link"
                              )
                              )
                             ),
                           #h2("Weather Forecast of Melbourne", align = "center"),
                           # hr(),
                           # fluidRow(
                           #   column(12,
                           #   tableauPublicViz(
                           #     id = "tableauviz2",
                           #     url = "https://public.tableau.com/views/Pedestrain_Map/1_1?:language=en-US&publish=yes&:display_count=n&:origin=viz_share_link"
                           #   )
                           # )),
                         tags$hr(),
                         tags$h5(class = "footer-note",'Data Source from: ', 
                                 a("CoM Open Data Portal - City of Melbourne",
                                   href="https://data.melbourne.vic.gov.au/pages/home/")),
                         tags$h5(class = "footer-note",'Tableau map deposit: ', 
                                 a("Xianrui Gao's Pedestrain_Map",
                                   href="https://public.tableau.com/app/profile/xianrui.gao/viz/Pedestrain_Map/1_1"))
                         )
)

ui <- dashboardPage(
  title = "visit mel",       
  header = headers,
  sidebar = sidebar,
  body = dashboardBody(
    id = "mainTabs",
    setUpTableauInShiny(),
    tabItems(
      tabItem("home",
              intro_panel
      ),
      tabItem("poi",
              poi_panel
      ),
      tabItem("weather",
              weather_panel
      ),
      tabItem("pedestrain",
              intro_panel #pedestrain_panel
      ),
      tabItem("tour",
              tour_panel
      ),
      tabItem("faqs",
              faqs_panel
      )
    )
  )
)

