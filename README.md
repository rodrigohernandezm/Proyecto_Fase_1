# 📊 Proyecto de Integración, Limpieza y Consolidación de Faltas Judiciales (2018--2024)

Este proyecto automatiza la **lectura, estandarización, limpieza y
unificación** de las bases anuales de **faltas judiciales de Guatemala**
publicadas por el **INE**.\
El objetivo técnico es generar una **base consolidada** de los años
**2020--2024**, lista para análisis posteriores.

------------------------------------------------------------------------

## 📁 Estructura del Proyecto

    /Proyecto_Faltas_Judiciales/
    │
    ├── datasets/                         # Archivos fuente en formato Excel
    │   ├── faltas_2018.xlsx
    │   ├── faltas_2019.xlsx
    │   ├── faltas_2020.xlsx
    │   ├── faltas_2021.xlsx
    │   ├── faltas_2022.xlsx
    │   ├── faltas_2023.xlsx
    │   └── faltas_2024.xlsx
    │
    ├── script_limpieza.R                 # Script principal de procesamiento
    └── README.md                         # Documento técnico

------------------------------------------------------------------------

## ⚙️ Requisitos

### 🧩 Paquetes utilizados

``` r
install.packages(c("readxl", "dplyr", "stringi", "arules"))
```

### 💻 Requisitos del sistema

-   R versión 4.2 o superior\
-   RStudio o entorno compatible\
-   Carpeta con permisos de lectura/escritura

------------------------------------------------------------------------

## 🚀 Flujo de Ejecución

1.  **Lectura automática de archivos**
    -   Se obtienen todos los archivos `.xlsx` de la carpeta `datasets/`
        mediante `list.files()`.
    -   Cada archivo se asigna dinámicamente como `df_YYYY` según el
        año.
2.  **Estandarización de columnas**
    -   Conversión de nombres a minúsculas y sin acentos
        (`stringi::stri_trans_general`).
    -   Uniformización de columnas equivalentes (`gran_grupos`,
        `subg_principales`, `g_primarios`).
3.  **Limpieza de datos**
    -   Se eliminan columnas que no aportan valor analítico o que
        contienen información redundante:
        -   `edad_quinquenales`
        -   `ocupacionhabitual`
        -   `filter_$`
        -   `nacionalidad_inf` (alta homogeneidad en los valores)
    -   Se corrigen tipos de datos inconsistentes (ej. `area_geo_inf`
        convertida a texto).
4.  **Unificación de bases**
    -   Se combinan los data frames anuales usando `bind_rows()` en un
        único objeto `df_final`.
    -   Se conservan únicamente los años **2020 a 2024** para mantener
        consistencia estructural.
5.  **Validaciones básicas**
    -   Verificación de cantidad de registros por año.
    -   Revisión de presencia de valores `NA` por columna.
    -   Confirmación de tipos (`str(df_final)`).

------------------------------------------------------------------------

## 📦 Salida esperada

El objeto `df_final` contiene los registros limpios y consolidados.\
Puede exportarse a CSV mediante:

``` r
write.csv(df_final, "df_final.csv", row.names = FALSE, fileEncoding = "UTF-8")
```

------------------------------------------------------------------------

## 🧠 Observaciones técnicas

-   Se comprobó la existencia de un **diccionario de variables oficial**
    (INE), pero no se utilizó directamente dentro del código.
-   Se documentó la eliminación de `filter_$` como paso permanente (debe
    reflejarse en versiones futuras del README).
-   El script es modular y puede adaptarse fácilmente si se agregan años
    adicionales al dataset.

------------------------------------------------------------------------

## 👨‍💻 Autor

**Rodrigo Eduardo Hernández Morales**\
Maestría en Ciencia de la Computación -- Especialidad en Ciencia de
Datos\
Universidad de San Carlos de Guatemala
