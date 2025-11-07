# 📊 Proyecto de Integración, Limpieza y Minería de Reglas de Asociación (Faltas Judiciales 2018–2024)

Este repositorio contiene un flujo de trabajo completo en **R** para integrar bases anuales de faltas judiciales, limpiarlas y aplicar técnicas de **minería de reglas de asociación** y **segmentación (k-means)**.

El script principal (`Fase_1.R`) automatiza la **lectura, estandarización, consolidación y análisis** de archivos Excel (`.xlsx`) que registran las faltas judiciales. El objetivo final es generar un conjunto unificado de datos (2020–2024) y dejar listo un entorno reproducible para que el ingeniero pueda ejecutar los algoritmos de reglas y clustering con todos los preprocesamientos necesarios.

---

## 📁 Estructura del Proyecto

```
/Proyecto_Faltas_Judiciales/
│
├── datasets/                         # Carpeta con los archivos Excel originales
│   ├── faltas_2018.xlsx
│   ├── faltas_2019.xlsx
│   ├── faltas_2020.xlsx
│   ├── faltas_2021.xlsx
│   ├── faltas_2022.xlsx
│   ├── faltas_2023.xlsx
│   └── faltas_2024.xlsx
│
├── Fase_1.R                          # Script principal con toda la lógica del proyecto
└── README.md                         # Este archivo
```

---

## ⚙️ Requisitos de ejecución

### 💻 Requisitos del sistema

- **R 4.2 o superior.** El script utiliza sintaxis y paquetes que requieren versiones recientes.
- **RStudio** (recomendado) o cualquier IDE/terminal que permita ejecutar scripts de R.
- **Sistema operativo:** Windows, macOS o Linux. Se debe ajustar la variable `ruta` a la ubicación del directorio `datasets` en el sistema anfitrión.
- **Permisos de lectura** sobre la carpeta que contiene los archivos Excel y permisos de escritura si se desean exportaciones.

### 🧩 Librerías necesarias

Ejecutar el siguiente bloque una única vez para instalar las dependencias:

```r
install.packages(c(
  "readxl",      # Lectura de archivos .xlsx
  "dplyr",       # Manipulación de datos
  "stringi",     # Normalización de nombres y texto
  "arules",      # Algoritmos Apriori y FP-Growth (fim4r)
  "fastDummies", # Creación de variables dummy
  "ggplot2",     # Visualización de resultados
  "factoextra"   # Utilidades para análisis multivariado
))
```

> 💡 Si su instalación de R está detrás de un proxy, configure la variable `https_proxy` antes de instalar paquetes.

---

## 🚀 Ejecución del script paso a paso

1. **Preparar los archivos fuente**
   - Copie los Excel anuales de faltas judiciales (2018–2024) dentro de `datasets/`.
   - Cada archivo debe contener el año en su nombre (`faltas_2021.xlsx`, `faltas_2022.xlsx`, etc.). El script utiliza esa cadena de cuatro dígitos para identificar el año.

2. **Configurar la ruta de trabajo**
   - Abra `Fase_1.R` y edite la línea:

     ```r
     ruta <- "C:/Users/rodri/OneDrive/Documentos/Maestria/Cuarto_trimestre/Mineria de datos/Proyecto/datasets"
     ```

   - Sustituya el valor por la ruta absoluta hacia su carpeta `datasets`. Ejemplos por sistema operativo:
     - **Windows:** `"D:/Proyectos/FaltasJudiciales/datasets"`
     - **macOS/Linux:** `"/home/usuario/Proyecto_Fase_1/datasets"`

3. **Ejecutar el script completo**
   - Desde RStudio: abra `Fase_1.R`, seleccione *Source* (`Ctrl` + `Shift` + `Enter`).
   - Desde terminal: ubíquese en el directorio del repositorio y ejecute `Rscript Fase_1.R`.

4. **Verificar la salida en consola**
   - Se mostrarán mensajes que confirman la creación de tablas intermedias y la ejecución de los cálculos estadísticos (PCA, matriz de covarianza, k-means).
   - El script genera una gráfica `kmeans.png` en el directorio raíz (si se ejecuta en un entorno con capacidades gráficas) para visualizar los clusters con las transformaciones ya aplicadas.

5. **Exportación opcional**
   - Para guardar la tabla final en CSV, ejecute al final de la sesión:

     ```r
     write.csv(df_final, "df_final.csv", row.names = FALSE, fileEncoding = "UTF-8")
     ```

---

## 🧠 Explicación detallada del código (`Fase_1.R`)

1. **Carga de librerías**
   ```r
   library(readxl)
   library(dplyr)
   library(stringi)
   library(arules)
   library(fastDummies)
   library(ggplot2)
   library(factoextra)
   ```
   Estas dependencias cubren la lectura de Excel, manipulación de datos, normalización de texto, minería de reglas y clustering.

2. **Lectura dinámica de archivos Excel**
   ```r
   archivos <- list.files(path = ruta, pattern = "\\.xlsx$", full.names = TRUE)
   for (archivo in archivos) {
     base <- basename(archivo)
     anio <- regmatches(base, regexpr("\\d{4}", base))
     name <- paste0("df_", anio)
     datos <- read_excel(archivo)
     assign(name, datos)
   }
   ```
   Cada archivo se convierte en un `data.frame` cuyo nombre sigue el patrón `df_<año>`.

3. **Normalización y homologación de columnas (2020–2024)**
   ```r
   for (i in 2020:2024) {
     df <- get(paste0("df_", i))
     names(df) <- tolower(stri_trans_general(names(df), "Latin-ASCII"))
     df <- df %>%
       rename_with(~ gsub("subg_primarios|subg_principales", "subg_principales", .x)) %>%
       rename_with(~ gsub("gran_grupos|gran_grupos", "gran_grupos", .x)) %>%
       select(-any_of(c("edad_quinquenales", "ocupacionhabitual", "filter_$")))
     df[["area_geo_inf"]] <- as.character(df[["area_geo_inf"]])
     assign(paste0("df_", i), df)
   }
   df_final <- bind_rows(mget(paste0("df_", 2020:2024)))
   ```
   Se homogenizan nombres (sin acentos ni mayúsculas) y se eliminan columnas inconsistentes antes de unir los años válidos.

4. **Minería de reglas de asociación (Apriori)**
   ```r
   reglas <- apriori(
     df_final[, !names(df_final) %in% c("num_corre")],
     parameter = list(support = 0.2, confidence = 0.5)
   )
   reglas <- sort(reglas, by = "support", decreasing = TRUE)
   inspect(reglas[0:50])
   ```
  
5. **Segmentos específicos**
   - `df_final_h`: filtra por infractores hombres (`sexo_inf == 1`).
   - `df_final_e`: filtra por estado de ebriedad (`est_ebriedad_inf == 1`).
   - `df_sin_ig`: excluye valores “9” (*Ignorado*) en variables clave.
   Para cada subconjunto se vuelve a ejecutar `apriori` y se inspeccionan las reglas resultantes.

6. **FP-Growth con `fim4r`**
   ```r
   df_final_fp <- df_final %>%
     filter(...)
   reglas_fp <- fim4r(df_final_fp, method = "fpgrowth", target = "rules", supp = 0.2, conf = 0.5)
   ```
   Se enfoca en mujeres sin valores ignorados, crea grupos quinquenales de edad y ejecuta `fim4r` como alternativa más eficiente para reglas de asociación.

7. **Clustering k-means**
   - Se generan variables dummy con `fastDummies::dummy_cols` para convertir las categorías en columnas binarias antes del modelado.
   - Se normalizan las variables (`scale`) para que el cálculo de distancias no se sesgue por escalas distintas.
   - Se aplica `kmeans` con 2 centros y se evalúa la importancia de las componentes principales (`prcomp`).
   - Se grafica el resultado con `ggplot2`, resaltando los centroides y etiquetas de los componentes principales más influyentes, únicamente como verificación visual de las transformaciones.

> 📌 Los objetos clave disponibles al final son: `df_final`, `df_final_h`, `df_final_e`, `df_sin_ig`, `reglas`, `reglas_h`, `reglas_e`, `reglas_sin_ig`, `reglas_fp`, `reglas_fp_2`, `cluster` y `pca`.

---

## 🧽 Limpieza y ajustes adicionales

- Se elimina `nacionalidad_inf` antes de ciertos análisis para evitar ruido.
- Se filtran los valores **“Ignorado” (9)** en `falta_inf`, `sexo_inf`, `cond_alfabetismo_inf`, `est_conyugal_inf`, `grupo_etnico_inf`, `est_ebriedad_inf` y `niv_escolaridad_inf` en los subconjuntos correspondientes.
- Se generan variables quinquenales de edad (`edad_quinquenal`) para análisis demográfico más fino.

---

## 🧮 Manipulación de datos y cálculos estadísticos clave

- **Consolidación temporal:** los `data.frame` anuales se combinan con `bind_rows`, conservando una columna de referencia al año. Esto permite aplicar filtros específicos y garantiza que la estructura sea homogénea antes de crear dummies o agrupar categorías.
- **Normalización de texto:** se usa `stringi::stri_trans_general` para remover tildes y homogeneizar mayúsculas/minúsculas, evitando duplicados originados por inconsistencias ortográficas.
- **Codificación categórica:** `fastDummies::dummy_cols` transforma cada variable categórica relevante en columnas binarias. Este paso es requisito para calcular distancias euclidianas en k-means y para que FP-Growth trabaje con ítems discretos.
- **Matrices filtradas:** los subconjuntos (`df_final_h`, `df_final_e`, `df_sin_ig`, `df_final_fp`) se construyen con `filter` para aislar condiciones específicas. Estos filtros permiten recalcular reglas sin contaminación de valores ignorados o categorías irrelevantes.
- **Matriz de covarianza y PCA:** antes del clustering se calcula `prcomp` sobre las variables normalizadas, lo que genera internamente la matriz de covarianza y sus autovalores. Esta matriz se usa para identificar las componentes que retienen mayor varianza, reemplazando la necesidad de una gráfica de codo tradicional. El cálculo directo fue preferido porque automatiza la selección de componentes en lugar de depender de una inspección visual.
- **Selección de componentes:** el script revisa los eigenvalues (`pca$sdev^2`) para quedarse con aquellas componentes con varianza significativa. Esta lógica reduce dimensionalidad y disminuye el costo computacional del k-means sin perder información clave.
- **Clustering reproducible:** al ejecutar `set.seed(123)` y `kmeans` sobre las componentes principales, el flujo garantiza que cada corrida produzca la misma asignación de clusters, algo útil para pruebas locales del ingeniero.

> ℹ️ Cada bloque está documentado en `Fase_1.R` con comentarios que indican el objetivo del cálculo, de forma que cualquier usuario pueda activar o desactivar secciones según sus necesidades sin perder la consistencia del preprocesamiento.

---

## 🛠️ Implementación en otros ambientes

1. **Clonar el repositorio**
   ```bash
   git clone https://github.com/<usuario>/Proyecto_Fase_1.git
   cd Proyecto_Fase_1
   ```

2. **Configurar R en el entorno objetivo**
   - **Windows:** Instale R y RStudio desde <https://cran.r-project.org/>. Asegúrese de ejecutar RStudio como administrador la primera vez para instalar paquetes globales si es necesario.
   - **macOS:** Instale Xcode Command Line Tools (`xcode-select --install`), luego R y RStudio. Si usa `homebrew`, puede instalar R con `brew install --cask r`.
   - **Linux (Debian/Ubuntu):**
     ```bash
     sudo apt update
     sudo apt install r-base r-base-dev libxml2-dev libssl-dev libcurl4-openssl-dev
     ```

3. **Instalar dependencias** (ver sección de librerías). Ejecute el bloque `install.packages(...)` dentro de R.

4. **Verificar la codificación de los archivos Excel**
   - Los Excel deben usar UTF-8 o ISO-8859-1. Si se detectan caracteres extraños, reexporte desde Excel indicando la codificación.

5. **Actualizar la variable `ruta`** y ejecutar el script como se indicó anteriormente.

6. **Validar transformaciones**
   - Revise los data frames resultantes (`View(df_final)` en RStudio) para comprobar que las columnas dummy y los filtros se hayan aplicado correctamente.
   - Inspeccione los objetos intermedios (`str(df_final_dummy)`, `head(pca$x)`) para validar la normalización y la reducción de dimensionalidad.
   - Compruebe que la matriz de covarianza se generó sin `NA` mediante `cov(na.omit(df_final_dummy))` si se requiere diagnosticar el PCA.

> ✅ La estructura es reproducible en cualquier entorno siempre que las rutas y permisos sean correctos.

---

## 👨‍💻 Autor

**Rodrigo Eduardo Hernández Morales**
Maestría en Ciencia de la Computación – Especialidad en Ciencia de Datos
Universidad de San Carlos de Guatemala
