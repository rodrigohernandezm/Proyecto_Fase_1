library(readxl)

ruta <- "C:/Users/rodri/OneDrive/Documentos/Maestria/Cuarto_trimestre/Mineria de datos/Proyecto/datasets"

archivos <- list.files(path = ruta, pattern = "\\.xlsx$", full.names = TRUE)

for (archivo in archivos) {
  base<- basename(archivo)
  anio<- regmatches(base, regexpr("\\d{4}", base))
  name<- paste0("df_",anio)
  datos<- read_excel(archivo)
  assign(name, datos)
}



ls()


