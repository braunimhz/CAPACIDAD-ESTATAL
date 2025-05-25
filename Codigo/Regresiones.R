setwd("C:/Users/nikko/OneDrive/Documents/Semillero R/CAPACIDAD-ESTATAL/Codigo")

panel <- read_dta("C:/Users/nikko/OneDrive/Documents/Semillero R/CAPACIDAD-ESTATAL/PANEL_BUEN_GOBIERNO(2024).dta")
datos_m <- read_dta("C:/Users/nikko/OneDrive/Documents/Semillero R/CAPACIDAD-ESTATAL/Paquete Rep. Nat/Final/main_data_municipal_level.dta")

pacman::p_load(modelsummary, tidyverse, ggplot2, haven)

# Unir los datos
datos_unidos <- full_join(panel, datos_m, by = c("codmpio" = "ID"))

# Filtrar el año 2019
datos_unidos_2 <- datos_unidos %>% 
  filter(ano == 2019)

# Resumen descriptivo
datasummary(y_no_tribut + y_corr_tribut + g_corr + MDM_g_ejecur +
              g_cap + DF_gast_inv + DF_ing_trans + DF_desemp_fisc ~ 
              Mean + SD + Min + Max,
            data = datos_unidos_2)

# Variables dependientes (irregularidades)
datos_i <- c("media_irreg_intimidacion", 
             "media_irreg_compra", 
             "media_irreg_trashumancia", 
             "media_irreg_fraud", 
             "media_irreg_intervencion")

# Lista para guardar modelos
modelos_Y <- list()

# Iterar y correr regresiones con lm() 
for (var in datos_i) {
  formula_Y <- as.formula(paste(var, "~ log(y_corr_tribut + 1) + log(y_no_tribut + 1) + l_pop2018 + nbi2005"))
  modelos_Y[[var]] <- lm(formula_Y, data = datos_unidos_2)
}

modelos_G <- list()

for (var in datos_i) {
  formula_G <- as.formula(paste(var, "~ log(g_corr + 1) + log(MDM_g_ejecur + 1) + log(g_cap + 1) + l_pop2018 + nbi2005"))
  modelos_G[[var]] <- lm(formula_G, data = datos_unidos_2)
}

modelos_DF <- list()

for (var in datos_i) {
  formula_DF <- as.formula(paste(var, "~ log(DF_gast_inv + 1) + log(DF_ing_trans + 1) + log(DF_desemp_fisc + 1) + l_pop2018 + nbi2005"))
  modelos_DF[[var]] <- lm(formula_DF, data = datos_unidos_2)
}

#Modelos con variables Y
modelsummary(modelos_Y, stars = TRUE, title = "Modelos con variables Y")


#Modelos con variables G
modelsummary(modelos_G, stars = TRUE, title = "Modelos con variables G")

# Modelos con variables DF
modelsummary(modelos_DF, stars = TRUE, title = "Modelos con variables DF")