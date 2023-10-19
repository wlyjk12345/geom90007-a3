# Helper functions

# Read POI dataset
Sys.setenv(OWM_API_KEY = "25396bb7b2590590fcb12cf2b69fbcc7")

current_weather <- get_current("Melbourne, AU", units = "metric")
rain_measure <- ifelse(is.null(current_weather$rain$`5h`), 0, current_weather$rain$`5h`)

forecast_data <- get_forecast("Melbourne, AU", units = "metric")
forecast_df <- data.frame(
  tmstmp =  forecast_data$list$dt_txt,
  temp = forecast_data$list$main.temp,
  fl_temp = forecast_data$list$main.feels_like,
  humidity = forecast_data$list$main.humidity,
  wind_speed = forecast_data$list$wind.speed,
  pop = forecast_data$list$pop
)
forecast_df$pop <- forecast_df$pop * 100

forecast_df$tmstmp <- ymd_hms(forecast_df$tmstmp)
forecast_df$tmstmp <- as.POSIXlt(forecast_df$tmstmp, tz="Australia/Melbourne")

# Theme for dashboard (Light)
lightTheme <- shinyDashboardThemeDIY(
  ### general
  appFontFamily = "Calibri"
  ,appFontColor = "#2D2D2D"
  ,primaryFontColor = "#000000"
  ,infoFontColor = "#000000"
  ,successFontColor = "#0F0F0F"
  ,warningFontColor = "#D41A1A"
  ,dangerFontColor = "#D41A1A"
  ,bodyBackColor = "#FFFFFF"
  
  ### header
  ,logoBackColor = "#FFFFFF"
  
  ,headerButtonBackColor = "#FFFFFF"
  ,headerButtonIconColor = "#000000"
  ,headerButtonBackColorHover = "#CAE0E6"
  ,headerButtonIconColorHover = "#000000"
  
  ,headerBackColor = "#FFFFFF"
  ,headerBoxShadowColor = ""
  ,headerBoxShadowSize = "0px 0px 0px"
  
  ### sidebar
  ,sidebarBackColor = "#F0F0F0"
  ,sidebarPadding = "3"
  
  ,sidebarMenuBackColor = "transparent"
  ,sidebarMenuPadding = "2"
  ,sidebarMenuBorderRadius = 0
  
  ,sidebarShadowRadius = ""
  ,sidebarShadowColor = "0px 0px 0px"
  
  ,sidebarUserTextColor = "#737373"
  
  ,sidebarSearchBackColor = "#FFFFFF"
  ,sidebarSearchIconColor = "#000000"
  ,sidebarSearchBorderColor = "#DCDCDC"
  
  ,sidebarTabTextColor = "#737373"
  ,sidebarTabTextSize = "15"
  ,sidebarTabBorderStyle = "none"
  ,sidebarTabBorderColor = "none"
  ,sidebarTabBorderWidth = "0"
  
  ,sidebarTabBackColorSelected = "#D1D1D1"
  ,sidebarTabTextColorSelected = "#000000"
  ,sidebarTabRadiusSelected = "0px"
  
  ,sidebarTabBackColorHover = "#F5F5F5"
  ,sidebarTabTextColorHover = "#000000"
  ,sidebarTabBorderStyleHover = "none solid none none"
  ,sidebarTabBorderColorHover = "#C8C8C8"
  ,sidebarTabBorderWidthHover = "4"
  ,sidebarTabRadiusHover = "0px"
  
  ### boxes
  ,boxBackColor = "#FFFFFF"
  ,boxBorderRadius = "5"
  ,boxShadowSize = "none"
  ,boxShadowColor = ""
  ,boxTitleSize = "20"
  ,boxDefaultColor = "#E1E1E1"
  ,boxPrimaryColor = "#5F9BD5"
  ,boxInfoColor = "#B4B4B4"
  ,boxSuccessColor = "#70AD47"
  ,boxWarningColor = "#ED7D31"
  ,boxDangerColor = "#E84C22"
  
  ,tabBoxTabColor = "#F8F8F8"
  ,tabBoxTabTextSize = "15"
  ,tabBoxTabTextColor = "#646464"
  ,tabBoxTabTextColorSelected = "#2D2D2D"
  ,tabBoxBackColor = "#F8F8F8"
  ,tabBoxHighlightColor = "#C8C8C8"
  ,tabBoxBorderRadius = "5"
  
  ### inputs
  ,buttonBackColor = "#E2D2FA"
  ,buttonTextColor = "#2D2D2D"
  ,buttonBorderColor = "#FFFFFF"
  ,buttonBorderRadius = "9"
  
  ,buttonBackColorHover = "#BEBEBE"
  ,buttonTextColorHover = "#000000"
  ,buttonBorderColorHover = "#969696"
  
  ,textboxBackColor = "#FFFFFF"
  ,textboxBorderColor = "#6C6C6C"
  ,textboxBorderRadius = "9"
  ,textboxBackColorSelect = "#F5F5F5"
  ,textboxBorderColorSelect = "#6C6C6C"
  
  ### tables
  ,tableBackColor = "#F8F8F8"
  ,tableBorderColor = "#EEEEEE"
  ,tableBorderTopSize = "5"
  ,tableBorderRowSize = "4"
)

# Theme for dashboard (Dark)
darkTheme = shinyDashboardThemeDIY(
  
  ### general
  appFontFamily = "Calibri"
  ,appFontColor = "#CDCDCD"
  ,primaryFontColor = "#FFFFFF"
  ,infoFontColor = "#FFFFFF"
  ,successFontColor = "#FFFFFF"
  ,warningFontColor = "#FFFFFF"
  ,dangerFontColor = "#FFFFFF"
  ,bodyBackColor = "#242F39"
  
  ### header
  ,logoBackColor = "#46505A"
  
  ,headerButtonBackColor = "#46505A"
  ,headerButtonIconColor = "#DCDCDC"
  ,headerButtonBackColorHover = "#646464"
  ,headerButtonIconColorHover = "#3C3C3C"
  
  ,headerBackColor = "#46505A"
  ,headerBoxShadowColor = ""
  ,headerBoxShadowSize = "0px 0px 0px"
  
  ### sidebar
  ,sidebarBackColor = "#343E48"
  ,sidebarPadding = "0"
  
  ,sidebarMenuBackColor = "transparent"
  ,sidebarMenuPadding = "2"
  ,sidebarMenuBorderRadius = 0
  
  ,sidebarShadowRadius = ""
  ,sidebarShadowColor = "0px 0px 0px"
  
  ,sidebarUserTextColor = "#737373"
  
  ,sidebarSearchBackColor = "#F0F0F0"
  ,sidebarSearchIconColor = "#646464"
  ,sidebarSearchBorderColor = "#DCDCDC"
  
  ,sidebarTabTextColor = "#CDCDCD"
  ,sidebarTabTextSize = "15"
  ,sidebarTabBorderStyle = "none"
  ,sidebarTabBorderColor = "none"
  ,sidebarTabBorderWidth = "0"
  
  ,sidebarTabBackColorSelected = "#46505A"
  ,sidebarTabTextColorSelected = "#FFFFFF"
  ,sidebarTabRadiusSelected = "0px"
  
  ,sidebarTabBackColorHover = "#F5F5F5"
  ,sidebarTabTextColorHover = "#000000"
  ,sidebarTabBorderStyleHover = "none solid none none"
  ,sidebarTabBorderColorHover = "#C8C8C8"
  ,sidebarTabBorderWidthHover = "4"
  ,sidebarTabRadiusHover = "0px"
  
  ### boxes
  ,boxBackColor = "rgb(52,62,72)"
  ,boxBorderRadius = 5
  ,boxShadowSize = "0px 0px 0px"
  ,boxShadowColor = ""
  ,boxTitleSize = 16
  ,boxDefaultColor = "rgb(52,62,72)"
  ,boxPrimaryColor = "rgb(200,200,200)"
  ,boxInfoColor = "rgb(80,95,105)"
  ,boxSuccessColor = "rgb(155,240,80)"
  ,boxWarningColor = "rgb(240,80,210)"
  ,boxDangerColor = "rgb(240,80,80)"
  
  ,tabBoxTabColor = "rgb(52,62,72)"
  ,tabBoxTabTextSize = 15
  ,tabBoxTabTextColor = "rgb(205,205,205)"
  ,tabBoxTabTextColorSelected = "rgb(205,205,205)"
  ,tabBoxBackColor = "rgb(52,62,72)"
  ,tabBoxHighlightColor = "rgb(70,80,90)"
  ,tabBoxBorderRadius = 5
  
  ### inputs
  ,buttonBackColor = "rgb(230,230,230)"
  ,buttonTextColor = "rgb(0,0,0)"
  ,buttonBorderColor = "rgb(50,50,50)"
  ,buttonBorderRadius = 5
  
  ,buttonBackColorHover = "rgb(180,180,180)"
  ,buttonTextColorHover = "rgb(50,50,50)"
  ,buttonBorderColorHover = "rgb(50,50,50)"
  
  ,textboxBackColor = "rgb(68,80,90)"
  ,textboxBorderColor = "rgb(76,90,103)"
  ,textboxBorderRadius = 5
  ,textboxBackColorSelect = "rgb(80,90,100)"
  ,textboxBorderColorSelect = "rgb(255,255,255)"
  
  ### tables
  ,tableBackColor = "#343E48"
  ,tableBorderColor = "#46505A"
  ,tableBorderTopSize = "1"
  ,tableBorderRowSize = "1"
  
)
