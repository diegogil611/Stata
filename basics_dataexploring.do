cd "/Users/diegogilore/Documents/2023-2/Base de datos/Sesión 4 y 5"
log using "logdeprueba5&6"
display "como ti lo llamas mamita" /// "me quivoqué"
set obs 3000 //generar tal num de obs 
generate random=uniform() //generar que las obs sigan una distribución uniforme
br random
set matsize 1000 // ampliar la memoria 
set more off

use "My_data.dta" , replace
cd "/Users/diegogilore/Documents/2023-2/Base de datos/Sesión 4 y 5"
br
tostring id, replace //solo cambiar a texto 
destring id, replace //regresar a número 

tostring id, gen (id2) //creando una nueva variable 
destring id2, gen (id3) // numérica

tabulate edad //mostrar la tabla de frecuencias 
tabulate ingresos
summarize edad // mostrar estadística 
summ edad, detail //detail para mayor estadísticos 

*generar variables*
gen i=1 // constante
gen t=. 
gen estadocivil="casado"
br
gen cantidadhijos=.
replace cantidadhijos=1 if id<10
replace cantidadhijos=0 if id>=10
label define paternidad 0 "no padres" 1 "padres"
label value cantidadhijos paternidad 
*generar categórica para meter a la regression*
encode genero, gen (gen3)
decode gen3, gen (g4)
*guardar base de datos*
save "datos_modifi.dta", replace
*abrir nuevamente el archivo*
use "My_data.dta", replace
*abrir base de datos y modificar con edit*
ed // abreviación de edit 
*abreviaciones importantes: use "u" gen "g" browse "br" tabulate "ta" summarize "summ" help "h" 
h nopomatch 
search nopomatch

clear all
u cenama_ejemplo.dta
*importar base de datos*
import delimited using "fallecidos_covid_peru", clear //dta
import dbase using "RECHO.dbf", clear //archivo en texto
import spss using "RECHM.sav", clear //spss
*usando base cenama*
u cenama_ejemplo.dta, clear 
describe //desribe de qué tratan las variables referidas 
describe p29 p36_2 
codebook // muestra detalladamente el tipo de variable, número, etiqueta, media sd, datos faltantes y demás
codebook p29 p36_2 //para cada variable
*buscar de forma condicional* 
br if distrito=="CUSCO"
br if p29==2 // p29 si 2 es minorista 
br if p29==2 & p36_2 > 100 // mercados minoristas con mayores de 100 puestos 
br if p29==2 | p36_2 > 100 // mercados minoristas o puestos mayores a 100 
br in 10
br in 1/10
br in 10/L
br in 999/L
**notacion que sirve: & eso es "y" != esto es diferente ' comillas simples sirven para nombres temporales**
gen pepito1=0 if p39_2=.
