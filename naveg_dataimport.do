*Sesion 1 - Ciclo 2023-2

*1. Comandos basicos de navegacion en STATA

**Si tengo dudas sobre un comando
help sysuse
help regress

*Abrir bases de datos

*SYSUSE: usar bases de datos del sistema 
sysuse auto.dta
sysuse "auto.dta"  //comillas no son necesarias

*USE: Se utiliza una base de datos guardada en tu computadora

*Para usar bases de datos guardadas en Stata, pueden encontrarlo en Archivo --> Ejemplo de Bases de Datos 


**Primero se establece la direccion de la carpeta

***CD: change directory
cd "G:\Mi unidad\Dictado PUCP\2023-II\Laboratorio de Stata\Laboratorio\Clase_1"  //cambiar la carpeta en tu computadora
use auto.dta
use enaho2021.dta


*BROWSE: Ver la base de datos
sysuse enaho2021.dta, clear

**Ver la base de datos [sin editar] de la Encuesta de Hogares(enaho2021.dta)
browse
br
*  Datos > Editor de Datos > Editor de Datos (Explorar)
help browse

*Ver la base de datos de las primeras 3 variables
browse mes conglome vivienda
browse mes-dominio

*Ver la base de datos solo con las ultimas 5 variables
browse horas salario lnsalario edad2 condicion
browse horas-condicion

*EDIT: modificar la base de datos
edit
*  Datos > Editor de Datos > Editor de Datos (Editar)

*SAVE: Guardar una base de datos
cd "G:\Mi unidad\Dictado PUCP\2023-II\Laboratorio de Stata\Laboratorio\Clase_1"
save enaho2021_mod.dta

*Si ya existe el archivo y quieres modificarlo, pones la opcion de "replace"
save enaho2021_mod.dta,replace

*SAVEOLD: Guardar en la version de stata 13 o anteriores
saveold enaho2021_mod_vs13.dta,replace

**
*Ejercicio 1: Cambiar carpeta actual de directorio y guardar tu base de datos, que ya esta abierta en STATA, en esa nueva carpeta "Bases"

cd "G:\Mi unidad\Dictado PUCP\2023-II\Laboratorio de Stata\Laboratorio\Clase_1\Bases"
save enaho2021_mod.dta

*2. Seleccion de casos y variables
sysuse enaho2021_mod.dta
browse

*2.1.Seleccion de variables

*drop: eliminar variables

**Quedarme con las ultimas 6 variables
sysuse enaho2021_mod.dta,clear
browse

drop mes-estudios //eliminando desde la 1er variables hasta estudios
browse

*keep: quedarme con variables

save enaho2021_mod2.dta

**Quedarme con las ultimas 6 variables

sysuse enaho2021_mod2.dta
keep ingreso horas salario lnsalario edad2 condicion

sysuse enaho2021_mod2.dta,clear
keep ingreso-condicion

*use _ using: abrir bases de datos con ciertas caracteristicas
**Quedarme con las primeras 4 variables
help use
sysuse enaho2021_mod2.dta, clear
saveold enaho2021, replace
use ingreso horas salario lnsalario edad2 condicion using enaho2021_mod2.dta,clear

*dropmiss : 
**quedarme con las variables que no tienen missings
sysuse enaho2021.dta, clear

*ssc install: comand
**#
ssc install dropmiss
h dropmiss
h missings
missings dropvars
missings dropobs 

ssc install nmissing
h nmissing
nmissing, min(1000)  
drop `r(varlist)'

*2.2. Seleccion de casos
cd "G:\Mi unidad\Dictado PUCP\2023-II\Laboratorio de Stata\Laboratorio\Clase_1\Bases"
sysuse enaho2021_mod2.dta

** Por orden (in)
browse

**Primeras la observacion 10
browse in 10

**Primeras 10 observaciones
browse in 1/10

**últimas 10 observaciones
browse in 41/50
browse in -10/-1 //Con negativos, stata entiende que cuente como si la base estuviera ordenada al reves

*drop
sysuse enaho2021.dta
*borrar las primeras 10 observaciones
 drop in 1/10
*borrar las últimas 10 observaciones
 drop in -10/-1

*keep
sysuse enaho2021.dta
*quedarte con las primeras 10 observaciones
keep in 1/10
*quedarte con las ultimas 5 obs.
keep in -5/-1

** Por caracteristicas (if)
sysuse enaho2021.dta,clear

*if
*abrir solo base de datos de las personas que tienen un ingreso mayor a 1025
browse if ingreso>1025

*abrir solo base de datos de las personas con menor o igual ingreso a 1025 

browse if ingreso<=1025

*ver los valores del # de personas por dominio geografico y edad con ingresos mayores a 10 000 soles 

browse dominio ingreso edad if ingreso>=10000


*----------------------------------------------*


clear all

*1) Administrar memoria (solo cuando necesites que stata tenga mayor capacidad)

**Reporte de la memoria
memory
sysuse auto
memory

*mostrar configuracion de la memoria
query memory

*Modificar configuracion de memoria

**Modificar el numero de variables que puede abrir tu  base de datos
clear all
set maxvar 6000  //antes de usarlo, no deben tener bases abiertas
query memory 

** Cambiando "niceness" de tu computadora
clear all
set obs 10000000 //creando una base de 10 millones de observaciones

set niceness 0   //STATA va a usar toda la memoria de tu computadora y no va a dejar a los otros procesos, memoria (30:00)
query memory 

*Contador timer on  & timer off
*(Secciones de tiempo de código registrando e informando el tiempo empleado)

set niceness 10   //STATA le da toda la memoria al resto de procesos y se queda con casi nada. (0:00)
query memory 

set niceness 5 //default

*----------------------------------------------------------------

*2) Comandos descriptivos 

*Describe: descripcion general de tus variables

sysuse census, clear

describe

describe region

describe state2 region pop

*Codebook: descripcion general de tus variables (+ información)

codebook 
codebook region
codebook pop5_17 pop18p pop65p 

*count: contar observaciones

count

**contar cuantas observaciones tienen una poblacion mayor a 5 millones

count if pop>5000000

**contar cuantas observaciones tienen una poblacion mayor a 5 millones y con mas de 2 millones que son mayores de 65 años
count if pop>5000000 & pop65>2000000
br state2 pop pop65 if pop>5000000 & pop65>2000000

**contar cuantas observaciones tienen una poblacion mayor a 5 millones y al mismo tiempo con mas de 1 millon que son mayores de 65 años o que tiene menos de 50 mil muertes

count if pop>5000000 & pop65>1000000 | death<50000

br pop pop65 death state2 if pop>5000000 & pop65>1000000 | death<50000

**contar cuantas estadosde USA de mas de 5 millones de poblacion tienen mas de 1 millon de personas mayores de 65 años o tienen menos de 50 mil muertes

count if pop>5000000 & (pop65>1000000 | death<50000)

br pop pop65 death state2 if pop>5000000 & (pop65>1000000 | death<50000)

*SUMMARIZE (SUM): resumen estadistico de la variable

summarize

*Version mas basica
summ pop

*Version mas detallada
summ pop, detail 


*tabstat

** Media, mediana , min y max de poblacion

tabstat pop , stat(mean sd median min max)

tabstat pop pop18p popurban,stat(me sd median min max sk k)

**Media de la poblacion menor a 18 años por cada region

**Opcion con Summarize

**Region Nort East (NE)
summ pop5_17 if region==1
**Region Norte central (N Cntrl) 
summ pop5_17 if region==2
**Region Sur (South)
summ pop5_17 if region==3
**Region oeste (West)
summ pop5_17 if region==4

**Opcion con tabstat
tabstat pop5_17, stats(mean sd p50 min max sk k) by(region)

*table

*Necesita una variable que agrupa
generate a=1
table a, contents(mean pop5_17 mean pop)

**Media de la poblacion menor a 18 años por cada region
table region, contents(mean pop5_17 mean pop)

**table tiene un limite de estadisticos que es 5
table region, contents(mean pop5_17 mean pop mean pop65p mean popurban mean medage)

*tabulate // frecuencia, porcentaje// acumulado 
**oneway (solo 1 variable)
tab region

*return r()
summ pop
return list

**El total de poblacion en la base 
***r(mean) y r(N)
display r(mean)*r(N) 

***r(sum)
display r(sum)

**Ejemplo de ereturn
reg pop poplt5  //regresion ols
return list
ereturn list

display e(F)

*Tabulate twoway: cruce de variables

*Crear una variable dicotomica que me señale 1 si la poblacion es mayor a la media y 0, caso poblacion

summ pop
return list
gen dummy_mm=1 if pop>r(mean)
replace dummy_mm=0 if pop<=r(mean)

**frecuencias de la variable creada
tab dummy_mm

**por cada region, cuantos estados tienen una poblacion mayor a la media
tab region dummy_mm

**% segun la region donde se localiza el estado
tab region dummy_mm, row  

** % segun el tamaño del estado
tab region dummy_mm, col 

**segun porcentaje del total de estados  
tab region dummy_mm, cell


*Ejercicio 1

**1.1Sin etiquetar o cambiar el directorio de trabajo

cd "G:\Mi unidad\Dictado PUCP\2023-I\Laboratorio Stata\Laboratorio\Clase_2_parte I"

use enaho01-2021-200.dta ,clear

**1.2 Quedarse con las observaciones que son miembros del hogar (p204) y que no se quedan ausentes del hogar por más de 30 días (p205) o aquellos que no son miembros del hogar (p204) y se quedan presentes 30 días o más (p206)
keep if (p204==1&p205==2)|(p204==2&p206==1)

**1.3 Hacer un resumen de estadísticos básicos de las variables de edad y sexo
summ p208a p207  // p207 es i una variable categorica

**1.4. Hacer un resumen de estadísticos básicos con el mínimo, máximo, media y mediana de edad segun sexo de la persona. 

**opcion 1: tabstat
tabstat p208a, by(p207) stats(min max mean median )

**opcion 2 : table
table p207, contents(min p208a max p208a mean p208a median p208a)



*3. Comandos para modificar la base de datos

*Format
help format

clear all 
sysuse auto
describe
**diferencias entre fijo y general

**comando format (3 digitos en total) 

*Formato general (# enteros+ # decimales=general)
format %3.0gc price

*Formato fijo (# enteros=entero fijo y # decimales= decimales fijo)
format %3.0f price
*3
*Justificado a la izquierda
format %-6.0g price

*Sort /gsort
clear all
use "enaho01-2021-200.dta",clear

**Ordenar por edad
br p208a
sort p208a // de menos a más

gsort -p208a // más a menos 
br p208a

**Ordenar por genero y edad
br p207 p208a
sort p207 p208a
br p207 p208a

gsort -p207 p208a
br p207 p208a

*generate : crea variables
*Replace: modifica variables existentes

** De la variable dominio, crear una variable numerica que tenga valores de costa, sierra y selva.

tab dominio
tab dominio, nolabel

gen dominio_2=1 if dominio==1|dominio==2|dominio==3
replace dominio_2=2 if dominio>=4&dominio<=6
replace dominio_2=3 if dominio==7
replace dominio_2=4 if dominio==8

*Recode: modifica variables existentes
generate dominio_3=dominio 
tab dominio_3
recode dominio_3 (1/3=1) (4/6=2) (7=3) (8=4) 
tab dominio_3

*Variables sistematicas _n y :_N
bys p207: gen tot=_N
br p207 tot

bys dominio_2: gen orden=_n
br dominio_2 orden

* Etiquetas (Crear y asignar)

** Conocer las etiquetas en mi base de datos
label list

**Etiquetar la variable creada de dominio_2
label variable dominio_2 "Dominio con 4 valores: costa, sierra, selva y LM"

**Etiquetar los valores de la variable de dominio_2

**Primer paso: crear la etiqueta de valor
label define regiones 1 "Costa" 2 "Sierra" 3 "Selva" 4 "Lima Metropolitana"

*Segundo paso: asignar la etiqueta de valor a la variable
label values dominio_2 regiones

tab dominio_2
tab dominio_2, nolabel

*Ejercicio 
/* Creen una variable que tenga los valores y etiquetas de:
 1: jefe/jefa
 2: parientes
 3: no parientes 
hint: usar la variable p203
*/
*Crear la variable
tab p203
tab p203, nolabel

gen p203_2=1 if p203==1 // jefe de hogar 

replace p203_2=2 if 1<p203 & p203<8 |p203==11 // parientes

replace p203_2=3 if 8<=p203 & p203<=10 // no parientes
*Comprobando si ajusta a la definicion
tab p203 p203_2

**Segundo paso: crear etiquetas
label define parentesco 1 "jefe/jefa" 2 "parientes" 3 "no parientes"

*tercer paso: asignar la etiqueta
label values p203_2 parentesco
tab p203_2
tab p203_2, nolabel

*Otros comandos: sirven para guardar una version anterior de la base sin modificaciones

*preserve / restore 
clear all
use p203 using "enaho01-2021-200.dta",clear

preserve 

keep if p203==1
save "jefes.dta",replace

restore

*snapshot: tomar una foto de tu base

use "enaho01-2021-200.dta",clear
snapshot save, label("Snapshot 1")
keep in 1/10
snapshot restore 1

*----------------------------------------------------------------

*=============================
* I. Organizacion de Carpetas
*=============================

* Primera Opción
cd "G:\Mi unidad\Dictado PUCP\2023-II\Laboratorio de Stata\Laboratorio\Clase_3\2.Datos"

* Segunda Opción
global main  "G:\Mi unidad\Dictado PUCP\2023-II\Laboratorio de Stata\Laboratorio\Clase_3"
global dos   "$main/1.Do"
global dta   "$main/2.Datos"
global procesadas "$main/3.Procesadas"
global graf "$main/4.Graphs"

*==============================================
* II. Usamos Módulo 5 de empleo
*==============================================

use"$dta/enaho01a-2021-500.dta", clear  

*=============================
* III. Traducir Base de datos
*=============================

clear all

h unicode
*El comando unicode proporciona utilidades para ayudarlo a trabajar con cadenas Unicode en sus datos. Si solo tiene caracteres ASCII simples en sus datos (a-z, A-Z, 0-9 y típicos caracteres de puntuación), puedes dejar de leer ahora. De lo contrario, continúe con las Observaciones a continuación.

cd "G:\Mi unidad\Dictado PUCP\2023-II\Laboratorio de Stata\Laboratorio\Clase_3"


unicode analyze "enaho01a-2021-500.dta"  //Analiza si la base de datos contiene unicodes que se deben traducir a otro lenguaje


unicode encoding set "latin1" // puede ser con ISO-8859-10 también 
// El código anterior establece el lenguaje al cual se quiere traducir
unicode translate "enaho01a-2021-500.dta" // traduce la base de datos

** Está listo para usarse sin problemas
use "enaho01a-2021-500.dta"

*======================
* IV. Tipo de Variables
*======================
use "$dta/enaho01a-2021-500.dta", clear

browse ubigeo estrato conglome vivienda hogar codperso p207 p208a p524a1

describe ubigeo

* String 

h format 

format ubigeo %18s //nos permite revisar las variables
describe ubigeo

format ubigeo %6s
describe ubigeo

* Numéricas
br p524a1
format p524a1 %5.0f  //sin decimales
br p524a1

format p524a1 %5.2f  // con dos decimales
br p524a1

format p524a1 %6.0fc  //incluir separador de miles, sin decimales 
br p524a1

format p524a1 %6.5fc  //incluir separador de miles, sin decimales 
br p524a1


h format // aquí podemos ver la variedad de formatos número, string, tiempo 

* Numéricas con etiqueta
label list p207 // sexo: 2 categorías
label list estrato // estrato: 8 categorías

*===========================
* V. Missing values
*===========================

* Missing Values
gen newvar=.
br newvar

ssc install mdesc
h mdesc // proporciona el número de missing values que tiene una variables 

mdesc p524a1 newvar

mdesc ubigeo

*===========================
* VI. Cambiando tipo de almacenaje de variables
*===========================
* El comando destring (string-->numerica)
*---------------------
br ubigeo
gen ubigeo1=ubigeo

br ubigeo ubigeo1
destring ubigeo1, replace // reemplaza la variable


* El comando tostring (numerica-->string)
*---------------------
tostring ubigeo1, gen(str_ubigeo1) force
br ubigeo ubigeo1 str_ubigeo1

* El comando encode (string-->numerica + etiqueta)
*-------------------
br ubigeo
encode ubigeo, gen(id_ubigeo)
label list id_ubigeo

* El comando decode (numérico-->string+etiqueta)
*-------------------
br dominio
label list dominio
decode dominio, gen(str_dominio)
br dominio str_dominio

*================================
* VII. Manipulando Observaciones
*================================

* Reemplazando valores
*======================

* El comando replace
*--------------------
//Generamos la variable ingreso con el comando egen 
*Rowtotal: crea una variable con suma horizontal
egen ing_ocu_pri=rowtotal(i524a1 d529t i530a d536) 
			
egen ing_ocu_sec=rowtotal(i538a1 d540t i541a d543)		
				
rename d544t ing_extra
egen ingreso = rowtotal(ing_ocu_pri ing_ocu_sec ing_extra) 

//Vemos los datos
br conglome vivienda hogar codperso ingreso

//Usamos el comando replace para realizar el ingreso mensual
replace ingreso=ingreso/12
gen lnwage=ln(ingreso)

br ingreso lnwage


* El comando recode
*-------------------
//Veamos la data geográfica
br estrato dominio

* Variables Geográficas
*-----------------------
label list estrato 
recode estrato (1/5=1) (6/8=0), gen(area) 
tab area
// recode variable a utilizarse (las equivalencias), la creación de la nueva variables
// cómo leer lo que hicimos?
//recodifica la variable estrato en dos grupos: del 1 al 5 sea igual a 1 y del 6 al 8 igual al 0, llamaremos a esta variable nueva area

label list dominio
recode dominio (1/3=1 "Costa") (4/6=2 "Sierra") (7=3 "Selva") (8=4 "Lima Metropolitana"), gen(zona)
label list zona // veamos cómo quedó lo realizado

* Variables Socioeconómicas
*---------------------------

* Estado Civil
label list p209
recode p209 (1/2=1 "Casado/Conviviente") (3=2 "Viudo") (4/5=3 "Divorciado/Separado") (6=4 "Soltero"), gen(civil)
label list civil 

* Variables Laborales
*---------------------

* Participación Laboral
label list ocu500
recode ocu500 (1/2=1 "PEA") (3/4=0 "NO PEA") (0=.), gen(pea)
label list pea

*============================
* VIII. Guardar y Exportar
*============================

* El comando save
*------------------
save "base_laboral_2021.dta", replace // guarda en cd""
save "$procesadas/base_laboral_2021vf.dta", replace // guarda en global


* El comando export excel
*-------------------------
export excel using "$procesadas/base_laboral_2021.xlsx", firstrow(variables) replace


* El comando erase
*------------------
erase "base_laboral_2021.dta" // borra archivos en el disco

*============================
* IX. Exportar tablas
*============================
use "$procesadas/base_laboral_2021vf.dta"

* El comando estpost
*--------------------
search st0085_2 //Instalamos
estpost summarize ingreso
esttab using "$procesadas/ejemplo.csv", cells("count mean sd min max") noobs replace
// Este comando será útil cuando tengamos regresiones 
// noobs:  do not display the number of observations


* El comando asdoc (Word)
*--------------------------
ssc install asdoc
asdoc sum ingreso, save(ejemplo.doc)

* Exportar tabulados a excel:
*-----------------------------
* Ver putexcel, tab2xl, 
help tab2xl // instalarlo
tab2xl zona using "$procesadas/tabla.xlsx", col(1) row(1)

* Exportar tabulados a word:
*-----------------------------
help tab2docx // instalarlo
* Primero crean documento
putdocx begin
tab2docx zona
putdocx save "$procesadas/tabla.docx"








