# 📊 Proyecto de Integración, Limpieza y Minería de Reglas de Asociación (Faltas Judiciales 2018–2024)

Este proyecto automatiza la **lectura, estandarización, consolidación y análisis de asociación** de bases anuales de datos sobre **faltas judiciales**, originalmente almacenadas en archivos Excel (`.xlsx`).  
El objetivo final es generar un conjunto unificado de datos (2020–2024) y aplicar el algoritmo **Apriori** del paquete `arules` para descubrir patrones relevantes.

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
├── script_apriori.R                  # Script principal (el que contiene todo el código de integración y análisis)
└── README.md                         # Este archivo
```

---

## ⚙️ Requisitos de ejecución

### 🧩 Librerías necesarias

Instalar los paquetes de R que el script requiere:

```r
install.packages(c("readxl", "dplyr", "stringi", "arules"))
```

### 💻 Requisitos del sistema

- R versión 4.2 o superior  
- RStudio (recomendado para ejecución interactiva)  
- Sistema operativo Windows o Linux/Mac (ajustando la ruta en `ruta`)  
- Permisos de lectura en la carpeta de trabajo de OneDrive o local

---

## 🚀 Ejecución del script paso a paso

1. **Colocar los archivos Excel** en la carpeta `datasets`, asegurando que sus nombres contengan el año (por ejemplo: `faltas_2021.xlsx`).

2. **Definir la ruta de trabajo** en el script (ajustar a tu ruta local):

   ```r
   ruta <- "C:/Users/rodri/OneDrive/Documentos/Maestria/Cuarto_trimestre/Mineria de datos/Proyecto/datasets"
   ```

3. **Ejecutar el script completo** en RStudio o desde la consola:

   ```r
   source("script_apriori.R")
   ```

4. **El script realiza automáticamente:**
   - Lectura de todos los `.xlsx` dentro de `ruta`.
   - Extracción del año a partir del nombre del archivo.
   - Creación de objetos `df_2018`, `df_2019`, ..., `df_2024`.
   - Conversión a `data.frame` y unión de los años **2020–2024** (para eliminar el efecto pandemia y garantizar consistencia estructural).
   - Limpieza de nombres de columnas (minúsculas, sin acentos, sin tildes).
   - Renombrado de variables equivalentes:
     - `subg_principales` y `subg_primarios` → `subg_principales`
     - `gran_grupos` (unificación)
   - Eliminación de columnas no homogéneas entre años:  
     `edad_quinquenales`, `ocupacionhabitual`, `filter_$`
   - Conversión de columnas relevantes a texto (`area_geo_inf`).
   - Unión final de todas las bases en un solo `data.frame` llamado **`df_final`**.

---

## 🧽 Limpieza y ajustes adicionales

- Se eliminaron variables que no aportan valor analítico, como `nacionalidad_inf`.
- Se filtraron los valores **“Ignorado” (9)** en columnas clave:
  - `falta_inf`, `sexo_inf`, `cond_alfabetismo_inf`,  
    `est_conyugal_inf`, `grupo_etnico_inf`, `est_ebriedad_inf`.

El resultado de este paso se guarda en `df_sin_ig`, la base depurada para el análisis de reglas.

---

## 🔍 Ejecución del algoritmo Apriori

### Configuración general

```r
reglas <- apriori(df_final[, !names(df_final) %in% c('num_corre')],
                  parameter = list(support = 0.2, confidence = 0.5))
```

- **support = 0.2** → se considera una regla relevante si aparece en al menos el 20 % de los casos.  
- **confidence = 0.5** → se exige que la regla se cumpla en al menos la mitad de las observaciones donde aplica.

Las reglas se ordenan por soporte descendente y se inspeccionan las primeras 130:

```r
reglas <- sort(reglas, by = "support", decreasing = TRUE)
inspect(reglas[0:130])
```

---

## 👥 Segmentos analizados

Se generaron versiones adicionales del dataset para explorar patrones específicos:

| Dataset | Filtro aplicado | Descripción |
|----------|----------------|--------------|
| `df_final_h` | `sexo_inf == 1` | Solo infractores hombres |
| `df_final_e` | `est_ebriedad_inf == 1` | Solo infractores en estado de ebriedad |
| `df_sin_ig` | Exclusión de valores 9 | Sin “Ignorado” en columnas clave |

Cada uno fue analizado con Apriori de forma independiente.

---

## 📊 Exploraciones complementarias

1. **Filtrado por año de boleta (`ano_boleta`)** para observar variaciones temporales.  
2. **Creación de `reglas_2`**, eliminando variables jerárquicas redundantes (`g_edad_60ymas`, `nacimiento_inf`, `g_primarios`, `gran_grupos`) para verificar si influyen en la estructura de reglas.  
3. **Identificación de reglas significativas**, como la **Regla 4**:

   ```
   {area_geo_inf=2} => {falta_inf=[3,5]}
   support = 0.2419 | confidence = 0.7108 | lift = 0.9283
   ```

   Esta regla sugiere que el 71 % de los casos en **área rural** están asociados a faltas de los grupos 3–5, aunque su *lift* indica una tendencia general similar a la media nacional.

---

## 📦 Librerías utilizadas

```r
library(readxl)
library(dplyr)
library(stringi)
library(arules)
```

---

## 📤 Exportación opcional

Para guardar la base final:

```r
write.csv(df_final, "df_final.csv", row.names = FALSE, fileEncoding = "UTF-8")
```

---

## 🧠 Notas técnicas finales

- Los años 2018–2019 fueron excluidos deliberadamente por inconsistencias y el efecto de pandemia.  
- El proceso es **totalmente reproducible**: cualquier nuevo archivo que siga la misma estructura será integrado automáticamente.  
- El análisis puede replicarse con independencia del entorno, ajustando únicamente la variable `ruta`.

---

## 👨‍💻 Autor

**Rodrigo Eduardo Hernández Morales**  
Maestría en Ciencia de la Computación – Especialidad en Ciencia de Datos  
Universidad de San Carlos de Guatemala  
