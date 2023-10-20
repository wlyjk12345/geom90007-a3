source("libraries.R")
source("data.R")
source("icon.R")
source("tableau-in-shiny-v1.0.R")
source("ui.R")
source("server.R")


shinyApp(ui, server, options=list(launch.browser=TRUE))
