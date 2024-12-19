*Curso: Laboratorio de Econometría: Stata
*Ciclo: 2023-1
*Profesora: Tania Paredes Zegarra
*Clase 7: Loops
*-------------------------------------------

*==================
* MANEJO DE LOOPS
*==================

global main  "G:\Mi unidad\Dictado PUCP\2023-I\Laboratorio Stata\Laboratorio\Clase_7"
global dos   "$main/1.Do"
global datos   "$main/2.Datos"
global procesadas "$main/3.Procesadas"
global enaho "$main/Enaho"
global suma "$enaho/Sumarias"


use "$suma/sumaria-2021.dta", clear

keep ubigeo conglome vivienda hogar gashog1d gashog2d inghog1d inghog2d pobreza factor07
tab pobreza
codebook pobreza
tab pobreza, nolabel

*ubigeo: departamento/provincia/distrito
*conglomerado-hogar: identificacion de hogar 
*gashog1d gasto monetario
*gashog2d gasto total bruto
*inghog1d ingreso bruto
*inghog2d ingreso bruto total encuesta


gen dpto=substr(ubigeo,1,2) // extraemos el codigo departamental

order dpto, a(ubigeo) // se indica que se ordena a departamento ponerse después de varuable ubigeo

*=========
* foreach 
*=========

* foreach in
*------------
* Lista general 
foreach var in inghog1d inghog2d gashog1d gashog2d {
	summarize `var'
}

* foreach varlist
*-----------------
br gashog1d gashog2d inghog1d inghog2d
foreach var of varlist inghog1d inghog2d gashog1d gashog2d  {
	gen `var'_mens=`var'/12
}

//Hemos creado las mismas variables a nivel mensual

br
foreach var of varlist conglome - pobreza  {
	sum `var'
}

* foreach numlist
*-----------------
br inghog1d

foreach num of numlist 1(1)8 {
	gen ingreso_`num'=inghog1d/`num'
}
br inghog1d ingreso_1-ingreso_8

//qué significa lo sgte de numlist:
//1(1)8, considerar los números del 1 al 8 con saltos de (1)
// Entonces, sería 1, 2, 3, 4, 5, 6, 7, 8
//Luego, estás generando el ingreso dividido por cada números
//Es decir ingreso/1 , ingreso/2, ..., ingreso/8


//Aquí más info sobre el meaning de numlist y los criterios a considerar:
//https://www.stata.com/manuals/u11.pdf#u11.1.8numlist

*===========
* forvalues 
*===========

* Se usa para trabajar variables utilizando algun componente numerico:

* Primera especificacion: a(espacio)b

* Repetición del 1 al 8
br conglome-hogar gashog2d
forvalues x=1(1)8 {
gen gasto_`x'=gashog2d/`x'
sum gasto_`x'
}


* Con intervalo de 2 en 2:
forvalues x=1(2)8 {
sum gasto_`x'
}
br conglome-hogar gasto_*


* Segunda especificacion: a/b
forvalues x=1/8 {
	gen ln_gasto`x'=ln(gasto_`x')
	mean ln_gasto`x'
}
*
br ln_gasto*
br ln_gasto1-ln_gasto8


* Tercera especificacion: a b .. to z
* Valor 1, 3-11
forvalues x= 1 3 to 11 {
gen prueba_`x'=`x' + 2
}
br prueba_1-prueba_11


*=======
* while
*=======
destring dpto, replace
br dpto

* Sin break
local i=1
while `i' {
	display "El código de departamento es " `i'
	tab pobreza if dpto==`i'
	local i=`i'+1   
}
//En el segundo local, estas continuando con el sgte dpto (número) y así irá hasta el infinito
//Como verán, los primeros 25 dptos los corre muy bien y luego te menciona no observaciones. 


* Con break
local i=1
while `i' {
	display "El código de departamento es " `i'
	tab pobreza if dpto==`i'
	local i=`i'+1
if `i'==26 continue, break	
}
//Aquí también continuamos pero le decimos realiza un stop cuando estes en el dpto antes del #6. Por ello, solo nos muestra hasta el 5


* Itera solo la especificación verdadera
local i=1
while `i'<=25 {
	display "El código de departamento es " `i'
	tab pobreza if dpto==`i'
	local i=`i'+1
}
//Aquí le colocamos una condición de menor igual a 6. 


*==========================================
* Ejecución condicional: if, if else, else
*==========================================

clear all

forvalues i=2017/2021 {
append using "$suma/sumaria-`i'.dta"

keep ubigeo conglome vivienda hogar gashog1d gashog2d inghog1d inghog2d pobreza factor07
gen año=`i'
gen dpto=substr(ubigeo,1,2)
order dpto, a(ubigeo)

if año==2017 {
	collapse (sum) gashog2d, by(dpto)
} 
else if año==2018 {
	collapse (mean) gashog2d, by(dpto)
} 
else {
	collapse (min) gashog2d, by(dpto)
}

save "$procesadas/base_`i'.dta", replace
}

//Cómo leer lo anterior, sección if, else if, else:
// Si el año es 2017, genera el sum de la variable de interés
// Ademas si el año es 2018, genera la media de la variable de interés
// Para el resto, genera el minimo de la variable de interés
