setwd("C:/Users/nikko/OneDrive/Documents/Semillero R/CAPACIDAD-ESTATAL/Codigo")

library(haven)
library(dplyr)

panel <- read_dta("C:/Users/nikko/OneDrive/Documents/Semillero R/CAPACIDAD-ESTATAL/PANEL_BUEN_GOBIERNO(2024).dta")
datos_m <- read_dta("C:/Users/nikko/OneDrive/Documents/Semillero R/CAPACIDAD-ESTATAL/Paquete Rep. Nat/Final/main_data_municipal_level.dta")


datos_unidos <- full_join(panel, datos_m, by = c("codmpio" = "ID"))



datos_unidos_2 <- datos_unidos %>% 
  filter(ano == 2019)





