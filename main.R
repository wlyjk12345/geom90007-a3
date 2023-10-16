# App dependencies-------------------------------------------------------------
# Please run the following to ensure dependencies are installed
source("./R/libraries.R")
source("./R/data.R")
source("./R/icon.R")
source("./R/ui.R")
source("./R/server.R")

# Define the Shiny app
shinyApp(ui, server)
