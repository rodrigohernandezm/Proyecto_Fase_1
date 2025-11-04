# 📊 Proyecto de Integración, Limpieza y Análisis de Faltas Judiciales (2018–2024)

Este proyecto automatiza la **lectura, estandarización, unificación y análisis exploratorio** de las bases anuales de **faltas judiciales en Guatemala**, originalmente publicadas por el **Instituto Nacional de Estadística (INE)**. El objetivo es generar una base consolidada (2020–2024) y analizar patrones de comportamiento mediante **reglas de asociación** enfocadas en los infractores que se encontraban en **estado de ebriedad**.

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
├── script_limpieza.R                 # Script principal (código de integración y limpieza)
└── README.md                         # Este archivo
```

---

## ⚙️ Requisitos

### 🧩 Paquetes necesarios

```r
install.packages(c("readxl", "dplyr", "stringi", "arules"))
```

### 💻 Requisitos del sistema

- R 4.2 o superior  
- Sistema operativo Windows, Linux o MacOS  
- Carpeta con permisos de lectura (local u OneDrive)

---

## 🚀 Ejecución del Script

1. **Colocar todos los archivos `.xlsx`** dentro de la carpeta indicada en la variable `ruta` del script.
2. **Ejecutar el script completo** en RStudio o desde consola:

   ```r
   source("script_limpieza.R")
   ```

3. El script realiza automáticamente:
   - Lectura de todos los archivos Excel y creación dinámica de `df_YYYY`.  
   - Conversión a `data.frame` y selección de años **2020–2024**.  
   - Limpieza de nombres de columnas (minúsculas, sin tildes, sin acentos).  
   - Estandarización de nombres equivalentes (`gran_grupos`, `subg_principales`, `g_primarios`).  
   - Eliminación de columnas **no relevantes o redundantes**:
     - `edad_quinquenales`
     - `ocupacionhabitual`
     - `filter_$`
     - `nacionalidad_inf` (por baja variabilidad analítica; casi todos guatemaltecos)
   - Conversión de tipos inconsistentes (`area_geo_inf` a texto).  
   - Integración final en un único `df_final` mediante `bind_rows()`.

---

## 📦 Salida esperada

El objeto `df_final` contiene los datos unificados de **2020–2024**, listos para análisis posterior.  
Para exportar la base consolidada:

```r
write.csv(df_final, "df_final.csv", row.names = FALSE, fileEncoding = "UTF-8")
```

---

## 🧮 Análisis de Reglas de Asociación

Una vez consolidada la base, se realizó un análisis de **reglas de asociación (Apriori)** sobre los casos donde `est_ebriedad_inf = 1` (infractores en estado de ebriedad), con el fin de identificar patrones socio-demográficos y geográficos.

### 🔹 Variables consideradas
- `falta_inf`: tipo de falta judicial  
- `area_geo_inf`: zona geográfica (urbana o rural)  
- `sexo_inf`: sexo del infractor  
- `grupo_etnico_inf`: grupo étnico  
- `cond_alfabetismo_inf`: condición de alfabetismo  
- `est_conyugal_inf`: estado conyugal

---

## 🔍 Principales hallazgos

1. **Tipo de falta predominante**  
   El 89 % de las faltas cometidas por infractores ebrios corresponden a **faltas contra las buenas costumbres y el orden público**, lo que muestra una clara relación entre consumo de alcohol y conductas disruptivas sociales.

2. **Concentración urbana**  
   Aproximadamente el 67 % de los casos se registran en **áreas urbanas**, reflejando tanto mayor exposición al control institucional como una concentración territorial del fenómeno.

3. **Composición étnica**  
   El 63 % de los infractores pertenecen a **grupos no indígenas o sin registro étnico**, reflejando un sesgo urbano o deficiencias en la cobertura del registro rural.

4. **Relación área–tipo de falta**  
   En zonas urbanas, el **90 % de los infractores ebrios** cometen faltas **contra las buenas costumbres o el orden público**, reforzando el vínculo entre consumo de alcohol y desórdenes en espacios públicos.

---

## 💡 Ejemplo de interpretación

**Regla:**  
`{} => {area_geo_inf=1}` con `support = 0.674`

**Interpretación:**  
> Aproximadamente el 67 % de las faltas judiciales cometidas por personas en estado de ebriedad ocurren en áreas urbanas. Esto evidencia que el fenómeno se concentra en contextos urbanos, donde hay mayor interacción social, consumo público de alcohol y capacidad institucional para documentar los hechos.

---

## 🧠 Conclusiones

- Las faltas vinculadas a la ebriedad presentan un **perfil urbano y socialmente disruptivo**.  
- Las **reglas de asociación** permiten confirmar la relación entre **entorno urbano y comportamiento antisocial**.  
- Variables demográficas como **sexo, alfabetismo y estado civil** tienen registros completos, indicando **buena calidad de los datos**.  
- Se eliminaron columnas sin aporte analítico (`nacionalidad_inf`, `filter_$`, etc.) para mejorar la claridad de los patrones.

---

## 👨‍💻 Autor

**Rodrigo Eduardo Hernández Morales**  
Maestría en Ciencia de la Computación – Especialidad en Ciencia de Datos  
Universidad de San Carlos de Guatemala

