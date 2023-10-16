# App dependencies-------------------------------------------------------------
# Please run the following to ensure dependencies are installed
source("libraries.R")
source("data.R")
source("icon.R")
source("ui.R")
source("server.R")

# Define the Shiny app
shinyApp(ui, server)
