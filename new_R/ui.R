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
    menuItem("Dining and Accommodation",
             tabName = "poi",
             icon = icon('map-location-dot')),
    menuItem("Weather",
             tabName = "weather",
             icon = icon('sun')),
    #menuItem("Pedestrian Volume Monitor",
    #         tabName = "pedestrain",
    #         selected = T,
    #         icon = icon("users")),
    menuItem("Tourist Amenities",
             tabName = "tour",
             icon = icon('plane')),
    menuItem("FAQs",
             tabName = "faqs",
             icon = icon("question"))
  )
)

intro_panel <- tabPanel(
  title = "Intro",
  class = "page-1",
  fluidPage(
    fluidRow(
      includeHTML("home.html"),
    ),
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
                        tags$h1(class = "shiny-title","Melbourne Dining and Accommodation"),  # Add the title here
                        tags$hr(),
                        tags$p(class = "shiny-p", 
                               "🍵 Discover cafes, restaurants, pubs, and more! Filter your search and find your favorites with ease.", 
                               br(), 
                               "🍹 Dive into the vibrant culinary and hospitality scene of Melbourne with our comprehensive map. From world-class restaurants to cozy cafes and iconic bars - we've got it all.", 
                               br(),
                               "🌮 Whether you're craving delectable cuisine, seeking a quick coffee stop, or hunting for a comfortable place to stay, this guide is your perfect companion.", 
                               br(), 
                               "🌇 Immerse yourself in the inviting atmosphere of Melbourne's dining and accommodation offerings, ensuring a memorable visit to this bustling city."
                        ),
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
                         tags$p(class = "shiny-p", 
                                "🚊️ Discover essential tourist amenities at your fingertips with our Tourist Amenities Map. ",
                                br(),
                                "📶 Find Wi-Fi hotspots, bike share, tram and bus stops, and more to make your visit to Melbourne convenient and enjoyable.",
                                br(),
                                "🚌 Melbourne's essential facilities and services are carefully designed to enhance the tourism experience. ",
                                br(),
                                "🚴 These amenities are thoughtfully placed to make it easier for tourists to explore the city, access transportation, and stay connected."
                         ),
                         sidebarLayout(
                           sidebarPanel(
                             h3("Filter Local Facilities"),
                             checkboxGroupInput("newTabFilter", "Filter by type:",
                                                choices = c("WiFi", "Tram Stops", "Bus Stops", "Bike Share Docks", "Routes"),
                                                selected = c("WiFi", "Tram Stops", "Bus Stops", "Bike Share Docks", "Routes")),
                             helpText("Filter the local facilities shown on the map."),
                             
                             # Add links with the shiny-p class
                             hr(),
                             a("About Melbourne WiFi", href = "https://www.visitvictoria.com/practical-information/wifi-hotspots", class = "shiny-p"),
                             hr(),
                             a("About Tram Stops", href = "https://www.ptv.vic.gov.au/assets/PTV-default-site/Maps-and-Timetables-PDFs/Maps/Network-maps/Victorian-Train-Network-Map-May-2023-v3.pdf.pdf", class = "shiny-p"),
                             hr(),
                             a("About Bus Stops", href = "https://citymapper.com/melbourne/bus/stops?name=&coords=-37.817237%2C144.967974", class = "shiny-p"),
                             hr(),
                             a("About Bike Share Docks", href = "https://melbournebikeshare.com.au/", class = "shiny-p"),
                             hr(),
                             a("About Routes", href = "https://www.ptv.vic.gov.au/more/maps/", class = "shiny-p"),
                             
                             
                             # Add more links as needed
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
                           h1(class = "shiny-title","Today's Weather of Melbourne"),
                           hr(),
                           p(class = "shiny-p", 
                             HTML(paste("📅 Today is <strong>", format(as_datetime(current_weather$dt, tz = "Australia/Melbourne"), "%b %d %Y, %A"), "</strong>.",
                                        "<br>☀️ Melbourne's weather is known for its unpredictability, so it's a good idea to be prepared for all seasons in a single day.",
                                        "<br>🌸 Melbourne experiences four seasons: blooming spring, warm summer, mild autumn, and cool winter, offering a diverse range of weather experiences throughout the year.")
                             )
                           )
                           ,
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
                           p(class = "shiny-p","⛅ Access a 5-day weather forecast for Melbourne, offering key information on wind speed, weather conditions, humidity levels, and precipitation forecasts."),
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
  title = "Melbourne Vacation Planner",       
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
      #tabItem("pedestrain",
      #        pedestrain_panel
      #),
      tabItem("tour",
              tour_panel
      ),
      tabItem("faqs",
              faqs_panel
      )
    )
      ,
      # Also add some custom CSS to make the title background area the same
      # color as the rest of the header.
      tags$head(tags$style(HTML('
        /* logo */
        .skin-blue .main-header .logo {
                              background-color: #fff;
                              }

        /* logo when hovered */
        .skin-blue .main-header .logo:hover {
                              background-color: #fff;
                              }

        /* navbar (rest of the header) */
        .skin-blue .main-header .navbar {
                              background-color: #fff;
                              }        

        /* main sidebar */
        .skin-blue .main-sidebar {
                              background-color: #fff;
                              }

        /* active selected tab in the sidebarmenu */
        .skin-blue .main-sidebar .sidebar .sidebar-menu .active a{
                              background-color: #bcbcbc;
                              }

        /* other links in the sidebarmenu */
        .skin-blue .main-sidebar .sidebar .sidebar-menu a{
                              background-color: #fff;
                              color: #000000;
                              }

        /* other links in the sidebarmenu when hovered */
         .skin-blue .main-sidebar .sidebar .sidebar-menu a:hover{
                              background-color: #fff;
                              }
        /* toggle button when hovered  */                    
         .skin-blue .main-header .navbar .sidebar-toggle:hover{
                              background-color: #fff;
                              }
                              ')))
    )
  )


