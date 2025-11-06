library(readxl)
library(dplyr)
library(stringi)
library(arules)

library(fastDummies)
library(ggplot2)
library(factoextra)

ruta<- "C:/Users/rodri/OneDrive/Documentos/Maestria/Cuarto_trimestre/Mineria de datos/Proyecto/datasets"
ruta<- "C:/Users/rhernandez/Proyecto_Fase_1/datasets"

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

### inspeccionar reglas relacionadas a años

inspect(subset(reglas_sin_ig, grepl("ano_boleta", labels(rhs(reglas_sin_ig)), ignore.case = TRUE)))

## filtrando algunas columnas
##regla 4
reglas_2<- apriori(df_final[, !names(df_final) %in% c('num_corre', 'g_edad_60ymas', 'nacimiento_inf', 'g_primarios', 'gran_grupos')], parameter = list(support=0.2, confidence = 0.5))
inspect(reglas_2[0:130])


########FP Growth

df_final_fp<- df_final %>%
  filter(
    falta_inf != 9,
    sexo_inf != 9,
    cond_alfabetismo_inf != 9,
    est_conyugal_inf != 9,
    grupo_etnico_inf != 9,
    est_ebriedad_inf != 9,
    niv_escolaridad_inf != 9
  )

## filtrando unicamente genero femenino y eliminando los valores ignorados

df_final_fp<- df_final_fp[df_final_fp$sexo_inf == 2,c("num_corre", "depto_boleta", "muni_boleta","mes_boleta","ano_boleta","falta_inf",
                                                      "edad_inf", "grupo_etnico_inf","est_conyugal_inf", "nacimiento_inf",
                                                      "cond_alfabetismo_inf", "niv_escolaridad_inf", "area_geo_inf", "depto_nacimiento_inf")]

reglas_fp <- fim4r(df_final_fp, method="fpgrowth", target ="rules", supp =0.2, conf=0.5)
rf <- as(reglas_fp, "data.frame")
rf

## crear variable quinquenal

df_final_fp <- df_final_fp %>%
  mutate(
    edad_quinquenal = cut(
      edad_inf,
      breaks = seq(0, 100, by = 5),  
      labels = paste(seq(0, 95, by = 5), seq(4, 99, by = 5), sep = "-"),
      include.lowest = TRUE,
      right = TRUE
    )
  )

### regla 2
df_final_fp_2<- df_final_fp[,c("edad_quinquenal", "num_corre", "depto_boleta", "muni_boleta","mes_boleta","ano_boleta","falta_inf",
                                                      "edad_inf", "grupo_etnico_inf","est_conyugal_inf", "nacimiento_inf",
                                                      "cond_alfabetismo_inf", "niv_escolaridad_inf", "area_geo_inf", "depto_nacimiento_inf")]

reglas_fp_2<- fim4r(df_final_fp_2, method="fpgrowth", target ="rules", supp =0.2, conf=0.5)
rf_2<- as(reglas_fp_2, "data.frame")
rf_2


#### kmeans

var_kmeans<- c("edad_quinquenal", "depto_boleta", "muni_boleta","mes_boleta","ano_boleta","falta_inf",
              "edad_inf", "grupo_etnico_inf","est_conyugal_inf", "nacimiento_inf",
              "cond_alfabetismo_inf", "niv_escolaridad_inf", "area_geo_inf", "depto_nacimiento_inf")

df_final_km<- df_final %>%
  filter(
    falta_inf != 9,
    sexo_inf != 9,
    cond_alfabetismo_inf != 9,
    est_conyugal_inf != 9,
    grupo_etnico_inf != 9,
    est_ebriedad_inf != 9,
    niv_escolaridad_inf != 9
  )

df_final_km<- df_final_km%>%
  mutate(
    edad_quinquenal = cut(
      edad_inf,
      breaks = seq(0, 100, by = 5),  
      labels = paste(seq(0, 95, by = 5), seq(4, 99, by = 5), sep = "-"),
      include.lowest = TRUE,
      right = TRUE
    )
  )


df_final_km<- df_final_km[,var_kmeans]

## variables categoricas

cat_vars <- c("edad_quinquenal", "depto_boleta", "muni_boleta",  "mes_boleta", "ano_boleta", "falta_inf", "grupo_etnico_inf","est_conyugal_inf", "nacimiento_inf",
              "cond_alfabetismo_inf", "niv_escolaridad_inf", "area_geo_inf", "depto_nacimiento_inf")

## convertir columnas categoricas a dummies
info_k_dummy<- dummy_cols(
  df_final_km,
  select_columns = cat_vars,
  remove_first_dummy = TRUE,   
  remove_selected_columns = TRUE  
)

## asignarle nombre adecuado a las nuevas variables dummies

names(info_k_dummy) <- gsub("__", "_", names(info_k_dummy))
names(info_k_dummy) <- gsub("_([A-Za-z0-9]+)$", ".\\1", names(info_k_dummy))
names(info_k_dummy) <- gsub("_", ".", names(info_k_dummy))

## normalizacion 

info_scaled <- scale(info_k_dummy)

##### evaluacion de cantidad de clusters #####
fviz_nbclust(info_k_dummy, kmeans, method = "wss") +
  labs(title = "Método del codo para determinar k óptimo") +
  theme_minimal()

set.seed(123)
wss <- c()
for (k in 1:10) {
  kmeans_result <- kmeans(info_k_dummy, centers = k, nstart = 10)
  wss[k] <- kmeans_result$tot.withinss
}

plot(1:10, wss, type = "b", pch = 19, frame = FALSE,
     xlab = "Número de clusters K",
     ylab = "Suma total de cuadrados intra-cluster (WSS)",
     main = "Método del Codo")

####### metodo numerico para numero de clusters ####

info_k_dummy_no_na <- info_k_dummy %>%
  select_if(is.numeric) %>%
  na.omit()

matriz_cov <- cov(info_k_dummy_no_na)

eigen_vals <- eigen(matriz_cov)$values
print(eigen_vals)

num_factores <- sum(eigen_vals > 1)
cat("Número de componentes con eigenvalue > 1:", num_factores, "\n")


#####

info_numerico <- info_k_dummy_no_na %>%
  select_if(is.numeric)

info_numerico <- info_numerico[, apply(info_numerico, 2, var, na.rm = TRUE) != 0]
info_numerico <- info_numerico[complete.cases(info_numerico), ]
info_numerico <- info_numerico[apply(info_numerico, 1, function(x) all(is.finite(x))), ]

nrow(info_numerico)

info_scaled <- scale(info_numerico)

if (nrow(info_scaled) > 2) {
  set.seed(123)
  cluster<- kmeans(info_scaled, centers = 2, nstart = 20)
  print(table(cluster$cluster))
} else {
  print("No hay suficientes filas válidas para agrupar.")
}

pca <- prcomp(info_scaled, scale. = FALSE)

loadings <- pca$rotation[, 1:2] 
top_pc1 <- names(sort(abs(loadings[,1]), decreasing = TRUE))[1:3]
top_pc2 <- names(sort(abs(loadings[,2]), decreasing = TRUE))[1:3]

x_lab <- paste0("PC1 (", paste(top_pc1, collapse = ", "), ")")
y_lab <- paste0("PC2 (", paste(top_pc2, collapse = ", "), ")")

pca_data <- data.frame(
  PC1 = pca$x[,1],
  PC2 = pca$x[,2],
  cluster = as.factor(cluster$cluster)
)

centroids_pca <- as.data.frame(
  predict(pca, newdata = cluster$centers)[,1:2]
)
centroids_pca$cluster <- factor(1:nrow(centroids_pca))

ggplot(pca_data, aes(x = PC1, y = PC2, color = cluster)) +
  geom_point(size = 2, alpha = 0.7) +
  geom_point(data = centroids_pca, aes(x = PC1, y = PC2),
             color = "black", shape = 8, size = 4) +
  geom_text(data = centroids_pca, aes(label = paste("Cluster", cluster)),
            color = "black", vjust = -1) +
  labs(
    title = "K-means visualizado con PCA",
    x = x_lab,
    y = y_lab
  ) +
  theme_minimal()





