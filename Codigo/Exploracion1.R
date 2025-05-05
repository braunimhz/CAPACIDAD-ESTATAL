#Ruta de acceso para los datos
setwd("C:/Users/nikko/OneDrive/Documents/Semillero R/CAPACIDAD-ESTATAL/Codigo")

#instalacion de paquetes necesarios
install.packages("haven")
install.packages("corrplot")
install.packages("dplyr")
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

