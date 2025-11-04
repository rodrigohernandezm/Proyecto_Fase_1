# 📊 Proyecto de Integración y Limpieza de Bases de Faltas Judiciales (2018–2024)

Este proyecto automatiza la **lectura, estandarización y unificación** de bases anuales de datos sobre faltas judiciales, originalmente almacenadas como archivos Excel (`.xlsx`), para generar una base consolidada homogénea y lista para análisis.

---

## 📁 Estructura del Proyecto

```
/Proyecto_Faltas_Judiciales/
│
├── datasets/                         # Carpeta con los archivos Excel
│   ├── faltas_2018.xlsx
│   ├── faltas_2019.xlsx
│   ├── faltas_2020.xlsx
│   ├── faltas_2021.xlsx
│   ├── faltas_2022.xlsx
│   ├── faltas_2023.xlsx
│   └── faltas_2024.xlsx
│
├── script_limpieza.R                 # Script principal (el que contiene tu código)
└── README.md                         # Este archivo
```

---

## ⚙️ Requisitos

### 🧩 Paquetes necesarios

El script usa las siguientes librerías de R:

```r
install.packages(c("readxl", "dplyr", "stringi"))
```

### 💻 Requisitos del sistema

- R 4.2 o superior  
- Sistema operativo Windows (aunque funciona igual en Linux/Mac si se ajusta la ruta)  
- Carpeta con permisos de lectura en OneDrive o local

---

## 🚀 Ejecución del Script

1. **Colocar todos los archivos `.xlsx`** dentro de la carpeta definida en la variable `ruta`:

   ```r
   ruta <- "C:/Users/rodri/OneDrive/Documentos/Maestria/Cuarto_trimestre/Mineria de datos/Proyecto/datasets"
   ```

2. **Ejecutar el script completo** en RStudio o desde la consola de R:

   ```r
   source("script_limpieza.R")
   ```

3. El script:
   - Lee automáticamente todos los archivos Excel de la carpeta.  
   - Detecta el año en el nombre del archivo.  
   - Crea objetos `df_2018`, `df_2019`, ..., `df_2024`.  
   - Convierte todo a `data.frame` y selecciona solo los años **2020–2024**.  
   - Limpia nombres de columnas (minúsculas, sin acentos, sin tildes).  
   - Estandariza nombres equivalentes (`gran_grupos`, `subg_principales`, `g_primarios`).  
   - Elimina columnas no necesarias (`edad_quinquenales`, `ocupacionhabitual`).  
   - Corrige inconsistencias de tipo (`area_geo_inf` → `character`).  
   - Combina todo en un solo `df_final`.

---

## 📦 Salida esperada

El objeto final `df_final` contiene los datos de **2020–2024 unificados y estandarizados**, listo para análisis.

Para exportarlo a CSV (opcional):

```r
write.csv(df_final, "C:/Users/rodri/OneDrive/Documentos/Maestria/Cuarto_trimestre/Mineria de datos/Proyecto/df_final.csv", 
          row.names = FALSE, fileEncoding = "UTF-8")
```

---

## 🧠 Notas Técnicas

- Se omiten los años **2018–2019** para eliminar distorsión causada por la pandemia y diferencias estructurales.  
- Los nombres de columnas fueron normalizados a **snake_case** y sin acentos.  
- Las columnas eliminadas (`edad_quinquenales`, `ocupacionhabitual`) no son consistentes entre años.  
- Si aparecen nuevos archivos, el script los integrará automáticamente si siguen el mismo formato.

---

## 👨‍💻 Autor

**Rodrigo Eduardo Hernández Morales**  
Maestría en Ciencia de la Computación – Especialidad en Ciencia de Datos  
Universidad de San Carlos de Guatemala  
