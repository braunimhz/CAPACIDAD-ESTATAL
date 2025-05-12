#Ruta de acceso para los datos
setwd("C:/Users/nikko/OneDrive/Documents/Semillero R/CAPACIDAD-ESTATAL/Codigo")

#instalacion de paquetes necesarios
install.packages("haven")
install.packages("corrplot")
install.packages("dplyr")
install.packages("skimr")
library(skimr)
library(corrplot)
library(haven)
library(dplyr)

#leer datos .dta en R
datos_c <- read_dta("C:/Users/nikko/OneDrive/Documents/Semillero R/CAPACIDAD-ESTATAL/Paquete Rep. Nat/Final/main_data_candidate_level.dta")
datos_m <- read_dta("C:/Users/nikko/OneDrive/Documents/Semillero R/CAPACIDAD-ESTATAL/Paquete Rep. Nat/Final/main_data_municipal_level.dta")



#Estadisticos descriptivos de las variables medidas para compra de votos
summary(datos_m %>% 
          select(starts_with("z_likelihood_misdeed_")))

#Matriz de correlacion
correlaciones <- cor(datos_m[, c("z_likelihood_misdeed_1", 
                                 "z_likelihood_misdeed_2",
                                 "z_likelihood_misdeed_3",
                                 "z_likelihood_misdeed_4",
                                 "z_likelihood_misdeed_5",
                                 "z_likelihood_misdeed_6")],
                     use = "complete.obs")  


#Tabla de correlaciones entre las variables medidas para compra de votos
nombres <- c("intimidación de votantes", 
                            "compra de votos", 
                            "fraude de registro",
                            "fraude electoral", 
                            "campaña de servidores públicos", 
                            "publicidad ilícita")

# Cambiar nombres de columnas Y filas
colnames(correlaciones) <- nombres
rownames(correlaciones) <- nombres

# Visualizar la matriz de correlaciones
corrplot(correlaciones, method = "color", type = "upper", 
         addCoef.col = "black", 
         tl.col = "black",      
         tl.srt = 45)            

skim(datos_m[, c("z_likelihood_misdeed_1", 
                 "z_likelihood_misdeed_2",
                 "z_likelihood_misdeed_3",
                 "z_likelihood_misdeed_4",
                 "z_likelihood_misdeed_5",
                 "z_likelihood_misdeed_6")])

#intimidacion de votantes: 639
#compra de votos: 642
# fraude de registro: 639
#fraude electoral: 639
#campaña de servidores publicos: 638
#publicidad ilicita: 634

#variables irregularidades
correlaciones_2 <- cor(datos_m[, c("media_irreg_intimidacion", 
                                 "media_irreg_compra",
                                 "media_irreg_trashumancia",
                                 "media_irreg_fraud",
                                 "media_irreg_intervencion")],
                     use = "complete.obs")  

corrplot(correlaciones_2, method = "color", type = "upper", 
         addCoef.col = "black", 
         tl.col = "black",      
         tl.srt = 45)    




