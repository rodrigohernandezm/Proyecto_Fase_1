# README – Análisis de Faltas Judiciales (Actualización Apriori)

## 🧩 Descripción general
Este proyecto implementa un flujo de análisis para identificar patrones de asociación en registros de **faltas judiciales** utilizando el algoritmo **Apriori** del paquete `arules` en R. Se consolidan múltiples bases anuales (2018–2024), se normalizan los nombres de variables y se realizan distintos escenarios de minería de reglas de asociación.

## ⚙️ Pasos principales del flujo

1. **Lectura y consolidación de bases**  
   - Se importan automáticamente todos los archivos `.xlsx` de la carpeta `datasets` y se asignan nombres dinámicos según el año.  
   - Se combinan las bases 2018–2024 en un solo `data.frame` (`df_final`).

2. **Depuración y normalización**  
   - Se unifican nombres de columnas con funciones `tolower()` y `stri_trans_general()` para eliminar acentos y mayúsculas inconsistentes.  
   - Se renombraron variables equivalentes (`subg_principales`, `gran_grupos`, etc.) y se eliminaron columnas no uniformes entre años (`edad_quinquenales`, `ocupacionhabitual`, `filter_$`).  
   - Se transformaron a texto las columnas necesarias para evitar errores de tipo en Apriori.

3. **Selección de periodo de estudio (2020–2024)**  
   - Se excluyen años anteriores a 2020 para evitar el sesgo del período de pandemia y mantener la consistencia en las variables registradas.

4. **Filtrado adicional**  
   - Se eliminó la variable `nacionalidad_inf` por no aportar valor analítico.  
   - Se generaron versiones filtradas del dataset para casos específicos:  
     - `df_final_h`: solo infractores hombres (`sexo_inf == 1`).  
     - `df_final_e`: solo infractores en estado de ebriedad (`est_ebriedad_inf == 1`).  
     - `df_sin_ig`: sin valores ignorados (`== 9`) en variables clave (`falta_inf`, `sexo_inf`, `cond_alfabetismo_inf`, `est_conyugal_inf`, `grupo_etnico_inf`, `est_ebriedad_inf`).

5. **Ejecución del algoritmo Apriori**  
   - Configuración estándar: `support = 0.2`, `confidence = 0.5`.  
   - Se generaron conjuntos de reglas para:
     - El conjunto completo (`df_final`)
     - Hombres (`df_final_h`)
     - Ebrios (`df_final_e`)
     - Sin ignorados (`df_sin_ig`)
   - En cada escenario, las reglas se ordenaron por *support* y se inspeccionaron los primeros 130 resultados.

6. **Exploraciones adicionales**  
   - Se aplicó un filtro para revisar reglas relacionadas con `ano_boleta`.  
   - Se generó un conjunto adicional (`reglas_2`) excluyendo variables redundantes (`g_edad_60ymas`, `nacimiento_inf`, `g_primarios`, `gran_grupos`) para observar efectos sobre la estructura de las reglas.

## 🧾 Cambios realizados desde la versión anterior
- Se eliminó la variable `nacionalidad_inf` del análisis principal.  
- Se añadió la exclusión de valores `9` (ignorados) en varias variables clave antes de generar reglas.  
- Se agregó un nuevo conjunto de reglas (`reglas_2`) con exclusión de variables de edad y jerarquías redundantes.  
- Se incorporó un análisis complementario de reglas relacionadas con el año (`ano_boleta`).  
- Se definió como **Regla 4** la relación `{area_geo_inf=2} => {falta_inf=[3,5]}`, destacando su valor interpretativo pese a un *lift* ligeramente menor a 1.

## 📦 Librerías utilizadas
```r
library(readxl)
library(dplyr)
library(stringi)
library(arules)
```

## 📊 Próximos pasos
- Filtrar reglas no triviales mediante `lift > 1 & confidence < 1` para priorizar asociaciones relevantes.  
- Documentar las reglas finales seleccionadas (Reglas 1–4) en el informe interpretativo.  
- Explorar reglas específicas por año y región con subconjuntos adicionales de datos.
