//se tiene que abrir una carpeta para usar la base de datos de la cual poder cargar rápidamente en el sistema//
cd "/Users/diegogilore/Documents/2023-2/Lab.Stata"
global main  "/Users/diegogilore/Documents/2023-2/Lab.Stata"
global dos   "$main/1.Do"
global dta   "$main/2.Datos"
global procesadas "$main/3.Procesadas"
global graf "$main/4.Graphs"
//traducir la base de datos luego de darme cuenta que hay signos de interrogación en los nombres//
h unicode
unicode analyze "enaho01a-2021-500.dta"
unicode encoding set "ISO-8859-10"
unicode translate "enaho01a-2021-500.dta" 
use "enaho01a-2021-500.dta"
*======================
* IV. Tipo de Variables
*======================
browse ubigeo estrato conglome vivienda hogar codperso p207 p208a p524a1
describe ubigeo
* String texto
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
*===========================
* V. Missing values
*===========================
gen newvar=.
br newvar
ssc install mdesc 
mdesc p524a1 newvar //permite conocer la cantidad de missing values//
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
egen ing_ocu_pri=rowtotal(i524a1 d529t i530a d536) 		
egen ing_ocu_sec=rowtotal(i538a1 d540t i541a d543)					
rename d544t ing_extra
egen ingreso = rowtotal(ing_ocu_pri ing_ocu_sec ing_extra) 
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
save "base_laboral_2021.dta"
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
