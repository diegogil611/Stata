

clear all

global main  "G:\Mi unidad\Dictado PUCP\2023-I\Laboratorio Stata\Laboratorio\Clase_4"
global dos   "$main/1.Do"
global data   "$main/2.Datos"
global procesadas "$main/3.Procesadas"
global enaho  "$main/4.ENAHO"

*Descargar los módulos 
	**100 (Características de la Vivienda y del Hogar) del 2021
	**500 (Empleo e Ingresos) del 2021
	**Sumaria 2021 
	**Sumaria 2010

*=================================================
* I. Creando una base de datos a partir de otra
*=================================================

* El comando collapse
*---------------------

* Sumaria 2021
*-------------
use "$enaho/sumaria-2021.dta", clear

gen ypc=inghog2d/(mieperho*12) //ingreso per capita = ingreso neto total/total de miembros del hogar*12 
gen gpc=gashog2d/(mieperho*12) // gasto per capita = gasto total bruto/total de miembros del hogar*12  

gen dpto=substr(ubigeo,1,2)  // generando el ubigeo departamental

br dpto // variable tipo string 
destring dpto, replace 
br dpto

// Nos preguntamos cuál es el ingreso p/c y el gasto p/c promedio por dpto
collapse (mean) ypc gpc, by(dpto)
br // vemos los datos

//Podemos añadir información adicional como la desviación estandar y crear nuevas variables

collapse (mean) ypc gpc (sd) sd_ypc=ypc (max) max_gpc=gpc, by(dpto)
br // veamos los datos

//Generamos el año
gen year=2021

//Guardamos
save "$procesadas/aux_2021.dta", replace

* Sumaria 2010
*-------------
*Replicamos lo mismo para el 2010*

use "$enaho/sumaria-2010.dta", clear
gen ypc=inghog2d/(mieperho*12)
gen gpc=gashog2d/(mieperho*12)
gen dpto=substr(ubigeo,1,2)
destring dpto, replace
collapse (mean) ypc gpc (sd) sd_ypc=ypc (max) max_gpc=gpc, by(dpto)
gen year=2010 
br
save "$procesadas/aux_2010.dta", replace

*====================================
* II. Estructura de bases de datos
*====================================

* El comando append
*--------------------
use "$procesadas/aux_2021.dta", clear
append using "$procesadas/aux_2010.dta"
br // veamos 

//Cambiamos los nombres de los dptos
label define lab_dpto 1 "Amazonas" 2 "Ancash" 3 "Apurímac" 4 "Arequipa" ///
		5 "Ayacucho" 6 "Cajamarca" 7 "Callao" 8 "Cusco" 9 "Huancavelica" 10 "Huánuco" ///
		11 "Ica" 12 "Junín" 13 "La Libertad" 14 "Lambayeque" 15 "Lima" 	16 "Loreto" ///
		17 "Madre de Dios" 18 "Moquegua" 19 "Pasco" 20 "Piura" 21 "Puno" 22 "San Martín" ///
		23 "Tacna" 24 "Tumbes" 25 "Ucayali"
label values dpto lab_dpto
br // veamos

* El comando reshape wide
*-------------------------
reshape wide ypc gpc sd_ypc max_gpc, i(dpto) j(year) // Recordar el j aquí es existente
save "$procesadas/base_wide.dta", replace


* El comando reshape long
*-------------------------
reshape long 
reshape long ypc gpc sd_ypc max_gpc, i(dpto) j(year) //Recordar el j crea el año
save "$procesadas/base_long.dta", replace

*==================================
* III. Combinación de base de datos
*==================================

use "$enaho/enaho01-2021-100.dta", clear  
count
// 43,524 hogares
duplicates list conglome vivienda hogar  // no hay duplicados
tab result

* El comando merge 1:1
*----------------------
use "$enaho/sumaria-2021.dta", clear   // 34,245 hogares
duplicates list conglome vivienda hogar
keep conglome-hogar mieperho pobreza // var iden , total de per hogar, pobr
merge 1:1 conglome vivienda hogar using "$enaho/enaho01-2021-100.dta", keepusing(result p101 p102 p103 p103a)
tab result _merge


* El comando merge m:1
*----------------------
use "$enaho/enaho01a-2021-500.dta", clear  // 86,806 individuos
duplicates list conglome vivienda hogar codperso // no duplicates
keep conglome vivienda hogar codperso p203-p209
merge m:1 conglome vivienda hogar using "$enaho/sumaria-2021.dta", keepusing(mieperho pobreza)
br

* El comando merge 1:m
*----------------------
use "$enaho/sumaria-2021.dta", clear   // 34,245 hogares
duplicates list conglome vivienda hogar
keep conglome-hogar mieperho pobreza
merge 1:m conglome vivienda hogar using "$enaho/enaho01a-2021-500.dta", keepusing(codperso p203-p209) 


*====================================================================
* MANEJO DE MACROS
*====================================================================
cd "/Users/diegogilore/Documents/2023-2/Lab.Stata/Laboratorio-20230914"
global main  "/Users/diegogilore/Documents/2023-2/Lab.Stata/Laboratorio-20230914"
global dos   "$main/1.Do"
global datos   "$main/2.Datos"
global procesadas "$main/3.Procesadas"

use "base_laboral_2021vf.dta", clear // base de clase 4 de manejo de bd

*============
* I. Display
*============

* Display (String)
display "Hola"
display "Estudio Economia"
display "3+3"
display "((4+2)^3)/4"

* Display (Numérico)
display 3+3
display ((4+2)^3)/4
display (5/2)^1/2

*=============
* II. Scalars
*=============
*Parte I
scalar num=2
display "Latina es el canal " num

scalar n="chupame la pija ok?"
display " me das tu wifi? " n


scalar suma=10+6
display "El contenido del scalar suma es " suma

scalar dia="14/9"
display "La clase de stata es el " dia

*Parte II
* Primera forma
br conglome-codperso ingreso
sum ingreso
gen ingreso_prom=750.4076
gen ingreso_des1=ingreso - ingreso_prom
br ingreso ingreso_prom ingreso_des1

* Segunda Forma
sum ingreso
gen ingreso_des2=ingreso-750.4076

* Tercera Forma (macros)
sum ingreso
return list
display r(mean)
display r(max)
gen ingreso_des3=ingreso-r(mean)

br ingreso_des1 ingreso_des2 ingreso_des3

*=============
* III. Locals
*=============
*debe ejecutarse junto*

local one 1
display `one'

local two = `one' +1 //lo reconoce como string
display `two'

local suma 3+3 
display `suma'    //opera la suma

local vars pais ingreso // véase la diferencia con las comillas
display "`vars'" //despliega los valores de vars

local variables edad ingreso
sum `variables'  //el summarize de las variables

local variables2 edad ingreso
display "`variables2'"  //el summarize de las variables

local texto "Hola"
display "Cuando llego dijo `texto'"

local  num=500
display "El contenido del scalar num es " `num'

local i 1
display "el valor de i es `i'"

//Observación correr juntos el local y la acción siguiente

*=============
* IV. Globals
*=============

global one 1
display $one


global main  "G:\Mi unidad\Dictado PUCP\2023-0\Laboratorio\Clase_3"
global dos   "$main/1.Do"
global datos   "$main/2.Datos"
global procesadas "$main/3.Procesadas"

use "$datos/base_laboral_2021vf.dta", clear

//Ordernar y guardar información
global indiv  "mujer edad jefe civil educ indigena"
global labor  "pea peao informal ingreso lnwage"
global geogr  "dpto zona area"

sum $indiv
sum $indiv $labor $geogr

reg ingreso $indiv $labor
reg ingreso $indiv $geogr 
//sum mujer edad jefe civil educ indigena ...

	
*------------------------------------------------------------------------------*
*** Importar bases de datos DG CONTENT ***
*------------------------------------------------------------------------------*
	use  cenama_ejemplo.dta, clear
	use "cenama_ejemplo.dta" , clear
	
	*import excel using "" , clear
	import delimited using "fallecidos_covid_peru", clear
	import dbase using "RECH0.dbf", clear
    import spss using "RECHM.sav", clear
*------------------------*
*** Explorando la base ***
*------------------------*
	use cenama_ejemplo , clear
	browse // Ver toda la base
	describe // describir las variables
	describe p29 p36_2  
	codebook
	codebook p29 p36_2 // depende del tipo de variable
	
	br
	browse if distrito == "CUSCO"
	br if p29 == 2 // br if p29 == "minorista"
	br if p36_2 > 100
	br if p29 == 2 & p36_2 > 100 // mercados minoristas y con más de 100 puestos
	br if p29 == 2 | p36_2 > 100
	
	br in 10
	br in 1/10
	br in 10/L	
	
*---------------------------*
*** Manipulando variables ***
*---------------------------*

	use cenama_ejemplo , clear
	
	*** gen, egen, bys egen ***
	gen puestos100 = p36_2 >= 100 	// dicotómica que identifica los mercados con 100 puestos o más
*	gen puestos100=.
*	replace puestos100=1 if p36_2 >= 100
*	replace puestos100=0 if p36_2 < 100

	gen x = 1 if p36_2 >= 100 in 1/200 // no dicotómica
	gen puestos_pollocarne = p39_4 + p39_3
	gen puestos_verfru = p39_1 + p39_2     // Pregunta
	br p39_1 p39_2 puestos_verfru
	
	help egen
	egen npuestos_verfru = rowtotal(p39_1 p39_2)
	br p39_1 p39_2 puestos_verfru npuestos_verfru
	
	egen n2puestos_verfru = rowtotal(p39_1 p39_2) , missing
	br p39_1 p39_2 puestos_verfru npuestos_verfru n2puestos
	
	egen rubro_max1 = max(p39_1-p39_9)
	egen rubro_max2 = rowmax(p39_1-p39_9)
	br p39_1-p39_9 rubro_max1 rubro_max2
	
	egen rubro_sd1 = rowsd(p39_1-p39_9)
	egen rubro_sd2 = sd(p39_1-p39_9)
	
	br p39_1-p39_9 rubro_sd1 rubro_sd
	
	
	* Qué pasa si necesito agrupar *
	bysort departamento provincia distrito: egen puestos_dist = total(p36_2) // Qué sucede con los missings
	br departamento provincia distrito p36_2 puestos_dist
	
	bysort departamento provincia distrito: egen puestos_max_dist = max(p36_2)
	br departamento provincia distrito p36_2 puestos_max_dist
	
	sort departamento provincia distrito
	egen puestos_max_dist2 = max(p36_2) , by(departamento provincia distrito)
	
	findit brows

