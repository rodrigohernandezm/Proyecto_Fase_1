library(readxl)
library(dplyr)
library(stringi)
library(arules)

ruta<- "C:/Users/rodri/OneDrive/Documentos/Maestria/Cuarto_trimestre/Mineria de datos/Proyecto/datasets"

archivos<- list.files(path = ruta, pattern = "\\.xlsx$", full.names = TRUE)

for (archivo in archivos) {
  base<- basename(archivo)
  anio<- regmatches(base, regexpr("\\d{4}", base))
  name<- paste0("df_",anio)
  datos<- read_excel(archivo)
  assign(name, datos)
}


ls()

df_2018<- as.data.frame(df_2018)
df_2019<- as.data.frame(df_2019)
df_2020<- as.data.frame(df_2020)
df_2021<- as.data.frame(df_2021)
df_2022<- as.data.frame(df_2022)
df_2023<- as.data.frame(df_2023)
df_2024<- as.data.frame(df_2024)

df_final<- bind_rows(df_2018, df_2019, df_2020, df_2021, df_2022, df_2023, df_2024)

### voy a usar informacion desde 2020 para quitar el efecto pandemia ademas que la informacion no es la misma
length(colnames(df_2024))

anios <- 2020:2024

### voy a eliminar las filas que solo aparecen en algunos df ya que no me sirven de mucho
### voy a unificar los nombres de las variables ya que algunas varian por algunas mayusculas o tildes
for (i in anios) {
  df <- get(paste0("df_", i))
  
  names(df) <- tolower(stri_trans_general(names(df), "Latin-ASCII"))
  
  df <- df %>%
    rename_with(~ gsub("gran_grupos|gran_grupos", "gran_grupos", .x)) %>%
    rename_with(~ gsub("subg_primarios|subg_principales", "subg_principales", .x)) %>%
    rename_with(~ gsub("g_primarios", "g_primarios", .x))
  
  df <- df %>% select(-any_of(c("edad_quinquenales", "ocupacionhabitual", "filter_$")))
  
  cols_a_texto <- c("area_geo_inf")
  for (col in cols_a_texto) {
    if (col %in% names(df)) {
      df[[col]] <- as.character(df[[col]])
    }
  }
  
  assign(paste0("df_", i), df)
}

df_final <- bind_rows(mget(paste0("df_", anios)))


#### Apriori ####


reglas<- apriori(df_final[, !names(df_final) %in% c('num_corre')], parameter = list(support=0.2, confidence = 0.5))
reglas<- sort(reglas, by = "support", decreasing = TRUE)
inspect(reglas[0:50])

## filtrando unicamente por hombre
df_final_h = df_final[df_final$sexo_inf == 1,]

reglas_h<- apriori(df_final_h[, !names(df_final_h) %in% c('num_corre', 'sexo_inf')], parameter = list(support=0.2, confidence = 0.5))
inspect(reglas_h[0:130])

reglas_h<- sort(reglas_h, by = "support", decreasing = TRUE)
inspect(reglas_h[0:130])

### filtrando solo a los ebrios
df_final <- df_final %>% select(-nacionalidad_inf)

df_final_e = df_final[df_final$est_ebriedad_inf == 1,]
reglas_e<- apriori(df_final_e[, !names(df_final_e) %in% c('num_corre', 'est_ebriedad_inf')], parameter = list(support=0.2, confidence = 0.5))

reglas_e<- sort(reglas_e, by = "support", decreasing = TRUE)
inspect(reglas_e[0:130])

### reglas eliminando lo valores ignorados de algunas columnas

df_sin_ig <- df_final %>%
  filter(
    falta_inf != 9,
    sexo_inf != 9,
    cond_alfabetismo_inf != 9,
    est_conyugal_inf != 9,
    grupo_etnico_inf != 9,
    est_ebriedad_inf != 9
  )

reglas_sin_ig<- apriori(df_sin_ig, parameter = list(support=0.2, confidence = 0.5))
inspect(reglas_sin_ig[0:130])


