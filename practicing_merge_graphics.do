clear all
cd "/Users/diegogilore/Documents/2023-2/Base de datos/Parcial BASEDATOS/"
global main "/Users/diegogilore/Documents/2023-2/Base de datos/Parcial BASEDATOS/"

/// PRIMERA PARTE ///

** PREGUNTA 1 **

use "relaves_mineros.dta"

//se suman los valores del registro de coincidencias de contaminación para conocer la cantidad de distritos contaminados en un año//

forvalues x=4(1)22 {
   tab v`x'
}

forvalues x=4(1)9 {
   egen suma_200`x' = total (v`x')
}

forvalues x=10(1)22 {
  egen suma_20`x' = total (v`x')
}
br departamento v*

//Reducimos la base a solo los resultados por año//

collapse (mean) suma_20*

//Se crea la variable de distritos solo para ordenar un poco la base de datos y años según la suma//

gen distrito= "distrito"

order distrito, first 

reshape long suma_, i(distrito) j(year)

//con los datos anteriores se crea el gráfico lineal, no es necesaria la variable distrito como se muestra a continuación//

      twoway line suma_ year , xtitle("Años") ytitle("Distritos afectados") title("Evolución del total de distritos afectados por relaves mineros") ///
      xscale(range(2004 2022)) xlabel(2004(2)2022) ///
	  note("Fuente:Instituto Nacional de Estadística e Informática" ///
      "Elaboración: Grupo 7")
graph export "/Users/diegogilore/Documents/2023-2/Base de datos/Parcial BASEDATOS/", as(png) name ("Graph0"), replace
save "relaves_mineros_suma.dta", replace	  

** PREGUNTA 2 **

//Se usa la misma base de datos para la pregunta 1, se eliminan los duplicados de la using data para hacer el merge a un solo dato// 
use "relaves_mineros.dta", clear
duplicates report distrito
duplicates drop distrito, force 
duplicates report distrito
save "relaves_mineros_map.dta", replace

//Ya tenía instalado el paquete para codificar las bases de coordenadas. Así solo corrí el código necesario//
shp2dta using "Distrital INEI 2023 geogpsperu SuyoPomalia.shp", database(perudis) coordinates(coordis) genid(id) 
//Una vez creada la base de coordenadas, usamos aquella base, nombramos a la variable de nuestra master data igual a la variable de la using data y se hace el merge necesario//
use perudis, clear 
rename DISTRITO distrito
merge m:1 distrito using relaves_mineros_map.dta
//Se cambian los valores de los distritos que no han sido afectados de missing values a ceros//
forvalues x=4(1)22 {
   replace v`x' = 0 if missing(v`x')
}
//Para que tengan información sobre las contaminadas o no, se realiza el siguiente loop informativo//

forvalues x=4(1)9 {
   label list
   label variable v`x'
   label define a200`x' 0 "no contaminada" 1 "contaminada"
   label values v`x' a200`x'
}

forvalues x=10(1)22 {
   label list
   label variable v`x'
   label define a20`x' 0 "no contaminada" 1 "contaminada"
   label values v`x' a20`x'
}
//Se realiza el gráfico con los datos para el año 2022 de los distritos afectados por relaves mineros//
spmap v22 using coordis.dta, id(id) ocolor(gray) fcolor(OrRd) clnumber(99) ///
	title("Distritos afectados por relaves mineros") ///
	subtitle("2022") ///
	legend (pos (7) title ("Contaminación", size (*0.5))) ///
	note("Fuente: INEI 2022" ///
	"Elaboración: Grupo 7")
graph export "/Users/diegogilore/Documents/2023-2/Base de datos/Parcial BASEDATOS/graph.png", as(png) name ("Graph1")
graph save "mapa1.gph", replace 


** PREGUNTA 3 **

//siguiendo con la misma base de datos, se genera una variable que resuma el efecto total de todos los años de los distritos afectados//

egen totalefect = rowtotal(v4 v5 v6 v7 v8 v9 v10 v11 v12 v13 v14 v15 v16 v17 v18 v19 v20 v21 v22)
br distrito totalefect
//Con esta información se usa la base de datos de las coordenadas para hacer el gráfico, se usa una paleta de colores alarmante para hacer evidente el efecto// 

spmap totalefect using coordis.dta, id(id) ocolor(gray) fcolor(YlOrRd) clnumber(11) ///
	title("Distritos afectados por relaves mineros") ///
	subtitle("2004-2022") ///
	legend (pos (7) title ("Años de Contaminación", size (*0.6))) ///
	note("Fuente: INEI 2022" ///
	"Elaboración: Grupo 7")
graph export "/Users/diegogilore/Documents/2023-2/Base de datos/Parcial BASEDATOS/Graph.png", as(png) name ("Graph2")
graph save "mapa2.gph", replace 	
save "relaves_mineros_dist.dta", replace

** PREGUNTA 4 **

//en esta pregunta se usa la base de datos que se creo para la pregunta 2 sin ninguna modificación//
u "relaves_mineros_map.dta", clear

//Se usa el siguiente loop para sumar la contaminación por departamento según los distritos afectados, así se encuentra la cantidad de distritos afectados por departamento// 

forvalues x=4(1)22 {
   egen sumdep`x' = total (v`x'), by(departamento)
}
//Se eliminan las variables innecesarias y se eliminan los departamentos repetidos para que solo se encuentren los 24 departamentos relevantes al estudio//
drop provincia distrito
duplicates report departamento
duplicates drop departamento, force 
duplicates report departamento
br departamento sumdep*
//Se crea una variable en porcentajes y se guarda la base de datos para hacer el merge con esta using data//
gen porcent2022 = (sumdep22 / sum(sumdep22))*100 
save "relaves_dep.dta", replace 
//Se crea una variable para coordenadas por departamentos y otra con departamentos en código, la cual se usa como master data//
shp2dta using "DEPARTAMENTOS_inei_geogpsperu_suyopomalia.shp", database(perudep) coordinates(coordep) genid(id) 
use perudep, clear 
//Se cambia el nombre de lso departamentos al nombre usado en la using data y se realiza el merge, se cambia el formato a porcentaje de decimales a dos dígitos//
rename NOMBDEP departamento
merge 1:1 departamento using relaves_dep.dta
format %7.2gc porcent2022
replace porcent2022 = 0 if missing(porcent2022)
br porcent2022
//Ya con la variable se realiza el gráfico usando las coordenadas de los departamentos de la base de datos correspondientes//
spmap porcent2022 using coordep.dta, id(id) ocolor(gray) fcolor(Oranges) clnumber(9) ///
	title("Departamentos según porcentaje de distritos") ///
	subtitle("afectados por relaves mineros 2022") ///
	legend (pos (7) title ("Porcentaje", size (*0.6))) ///
	note("Fuente: INEI 2022" ///
	"Elaboración: Grupo 7")
graph export "mapa3.png", as(png) name ("Graph3"), replace 
graph save "mapa3.gph", replace 

save "deps_map3.dta", replace

/// SEGUNDA PARTE ///

*EJERCICIO 1*******************************+
clear all

* Importar el Excel
import excel "/Users/lucassalamanca/Downloads/Base_gasto_municipal.xlsx", firstrow 

* Convertir las variables año_20 de string a double
destring año_20*, replace dpcomma

* Agrupar el tipo de gasto por años
collapse (sum) año_20*, by(Tipodegasto)

* Transponer data
reshape long año_, i(Tipodegasto) j(Año)

* Generar una nueva variable en la escala de miles de millones
gen Monto_mil_millones = año_/1e6

* Gráfico
twoway (connected Monto_mil_millones Año if Tipodegasto == "Gasto total ejecutado ", lcolor(red) lwidth(medium) msymbol(o) mcolor(red)) ///
       (connected Monto_mil_millones Año if Tipodegasto == "Gastos corrientes ejecutados ", lcolor(orange) lwidth(medium) msymbol(o) mcolor(orange)) ///
       (connected Monto_mil_millones Año if Tipodegasto == "Gastos de capital ejecutados ", lcolor(gold) lwidth(medium) msymbol(o) mcolor(gold)) ///
       (connected Monto_mil_millones Año if Tipodegasto == "Gastos por servicio de deuda ejecutados ", lcolor(green) lwidth(medium) msymbol(o) mcolor(green)), ///
legend(order(1 "Gasto total" 2 "Gastos Corrientes" 3 "Gastos de Capital" 4 "Gastos por pago de deuda") ///
       size(small) col(4) region(fcolor(white)))  ///  
ytitle("Monto (miles de millones de soles)") xtitle("Año") ///
xscale(range(2003 2021)) xlabel(2003(3)2021) ///
graphregion(fcolor(white)) plotregion(fcolor(white)) ///
title("Comportamiento del gasto") ///
subtitle("2003-2021") ///
note("Fuente: Ministerio de Economía y Finanzas" ///
     "Elaboración: Grupo 7")

	
	
	
	
	
*EJERCICIO 2*******************************+
clear all

* Importar el excel 
import excel "/Users/lucassalamanca/Downloads/Base_gasto_municipal.xlsx", firstrow 

* Convertir variables año_20 de string a double
destring año_20*, replace dpcomma

* Agrupar el gasto por departamentos y años 
collapse año_20*, by (Departamento)

* Transponer data
reshape long año_, i(Departamento) j(Año)

* Cambiar nombre de "año_" a "Monto" 
rename año_ Monto

* Dividir entre 500000 para que el eje-y solo tenga valores de un dígito
gen Monto_n = Monto/500000

* Gráfico
twoway (line Monto_n Año, lcolor(red) lwidth(0.2)), ///
by(Departamento, title("Gasto total por departamento") subtitle("2001-2023")) ///
graphregion(fcolor(white)) ///
ytitle("Monto (miles de millones de soles)") ///
xtitle("Año") 






*EJERCICIO 3***********************************
clear all

*Importar el excel
import excel "/Users/lucassalamanca/Downloads/Base_gasto_municipal.xlsx", firstrow 

*Cambiar variable a número
encode Tipodegasto, gen(Tipodegasto_n)
destring año_20*, replace dpcomma

*Mantener solo Tipo de gasto
keep Departamento Tipodegasto_n año_2003-año_2021
keep if Tipodegasto_n==1

* Agrupar el gasto por departamentos y años 
collapse (sd) año_20* , by(Tipodegasto_n)

*Transponer data
reshape long año_, i(Tipodegasto_n) j(Año)

*Dividir entre 1000000 para que el Std.dev salga en el rango deseado
gen Año_n=(año_/1000000)

*Gráfico
graph hbar Año_n , ///
		over(Año,    label(labsize(vsmall))) ///
		blabel()  ///
		bar(1 , color(red)) ///
		title("Dispersión del Gasto", size(medium)) ///
		ytitle("Desviación estándar") ylabel(,nogrid) ///
		graphregion(color(white)) ///
		note ("Fuente: Ministerio de Economía y Finanzas" /// 
                      "Elaboración: Grupo 7")


* Pregunta número 4, parte 2: 
clear all


import excel "Base_gasto_municipal 2.csv", firstrow clear

//Se codifica la variable tipodegasto y crea una nueva variable util para trabajar con variables categóricas
encode tipodegasto, gen(tipodegasto_1)
//Este comando conserva solo las variables "departamento", "tipodegasto_1", "año_2003" y "año_2020" en el conjunto de datos, descartando otras variables.
keep departamento tipodegasto_1 año_2003 año_2020
//Este comando mantiene solo las observaciones donde "tipodegasto_1" es igual a 1.
keep if tipodegasto_1==1
//Estos comandos crean dos nuevas variables, "suma1" y "suma2", que contienen la suma de los valores en las variables "año_2003" y "año_2020" respectivamente.
egen suma1= total(año_2003)
egen suma2= total(año_2020)
//Estos comandos calculan el porcentaje de gasto para los años 2003 y 2020 en relación con la suma total de esos años.
gen ParGas2003=(año_2003/suma1)*100
gen ParGas2020=(año_2020/suma2)*100
//Estos comandos se utilizan para crear dos gráficos de barras apiladas. Uno muestra el porcentaje de gasto para el año 2020, y el otro muestra el porcentaje de gasto para el año 2003. Ambos gráficos están apilados por departamento y contienen etiquetas y títulos personalizados.
graph bar ParGas2020, ///
		over(departamento,  label(labsize(vsmall) angle(90))) ///
		blabel()    ///
		ytitle("Porcentaje") ///
		subtitle ("Año 2020") ///
		graphregion(color(white)) ylabel(,nogrid) ///
		note ("Fuente: Ministerio de Economía y Finanzas" ///
		"Elaboración: Grupo 7")
	
graph bar ParGas2003, ///
		over(departamento,  label(labsize(vsmall) angle(90))) ///
		blabel()    ///
		ytitle("Porcentaje") ///
		subtitle ("Año 2003") ///
		graphregion(color(white)) ylabel(,nogrid) ///
		note ("Fuente: Ministerio de Economía y Finanzas" /// 
		"Elaboración: Grupo 7")

* Pregunta número 5, parte 2:
//Este comando codifica la variable "tipodegasto" y crea una nueva variable llamada "tipodegasto_1" con códigos.
encode tipodegasto, gen(tipodegasto_1)
//Se crea una nueva variable llamada "tipodegasto_2" y se le asigna el valor "Gastos Corrientes" si "tipodegasto_1" es igual a 2.
gen tipodegasto_2="Gastos Corrientes" if tipodegasto_1== 2
//En esta línea, se actualiza la variable "tipodegasto_2" a "Gastos de Capital" si "tipodegasto_1" es igual a 3.
replace tipodegasto_2="Gastos de Capital" if tipodegasto_1==3
//Similarmente, se actualiza "tipodegasto_2" a "Gastos por pago de deuda" si "tipodegasto_1" es igual a 4.
replace tipodegasto_2="Gastos por pago de deuda" if tipodegasto_1==4
//Esta línea cambia "tipodegasto_2" a "Gastos totales" si "tipodegasto_1" es igual a 1.
replace tipodegasto_2="Gastos totales" if tipodegasto_1==1
//Aquí, se codifica la variable "tipodegasto_2" y se crea una nueva variable llamada "Gasto" con códigos.
encode tipodegasto_2, gen(Gasto)
//Se mantienen solo las variables "departamento," "Gasto," y "año_2021."
keep departamento Gasto año_2021
//Se conservan solo las observaciones donde el valor de "departamento" es igual a "LIMA."
keep if departamento=="LIMA"
//Se eliminan las observaciones donde el valor de "Gasto" es igual a 4.
drop if Gasto ==4

//Se crea un gráfico de pastel que muestra la distribución de gasto municipal en Lima para el año 2021, desglosado por la variable "Gasto." El gráfico incluye un título, un subtítulo, una leyenda y notas adicionales.
graph pie año_2021 , over(Gasto) ///
    ///
	title("Distribución de gasto municipal de Lima") ///
	subtitle("2021") ///
	legend(rows(1) region( lcolor(white)) color(black)) plotregion(lstyle(black)) ///
	graphregion(color(white)) ///
		note ("Fuente: Ministerio de Economía y Finanzas" /// 
			  "Elaboración: Grupo 7")	
		
* Pregunta 6, parte 2:

//Los primeros comandos establecen rutas de directorio globales, instalan paquetes (schemepack y shp2dta), y activan un mapa geográfico con grmap.
global main "C:\Users\user\Desktop\Base de Datos\Parcial parte 2"
global graf "$main/4.Graficos"

ssc install schemepack, replace
set scheme rainbow 
ssc install shp2dta, replace
grmap, activate

//El comando shp2dta se utiliza para convertir datos geoespaciales de un archivo Shapefile 
shp2dta using "LIMITE_DEPARTAMENTAL_INEI_geogpsperu.shp" , database(peru) coordinate(perucoord) genid(id) genc(centro) replace

//Luego, se carga el archivo "peru.dta," se renombra la variable "DEPARTAMEN" a "departamento," y se guarda como "peruvf.dta."
use "peru.dta" , clear 
rename DEPARTAMEN departamento
save "peruvf.dta",replace

//El comando merge en Stata se utiliza para combinar dos conjuntos de datos (datasets) basándose en una o más variables comunes. La principal utilidad de este comando es combinar información de dos datasets diferentes en uno solo
use "peruvf.dta", clear
merge 1:1 departamento using "Mapitaa.dta" , nogen
save "Mapo.dta", replace 

//Se crean etiquetas para las ubicaciones geográficas en "Mapo.dta," y se guarda un archivo llamado "LABEL.dta" con esta información.
use "Mapo.dta", clear
preserve
generate label = departamento
keep departamento x_c y_c label
gen length = length(label)
save "LABEL.dta", replace
restore

//Se carga "Mapo.dta," y se crea un mapa utilizando el comando spmap que muestra datos del año 2020, representados por el campo "año2020_1," con un esquema de color "Rainbow."
use "Mapo.dta", clear

gen año2020_1=año_2020/1000000

format %7.2gc año2020_1

spmap año2020_1 using "perucoord.dta", id(id) ocolor(black) fcolor(Rainbow) clnumber(9) ///
	title() ///
	subtitle("(en miles de millones)") ///
	legend (pos (8)  ) ///
	note() 
//Se guarda el mapa generado en el directorio definido por la variable global "graf."
graph save "$graf/mapo1.gph", replace
//A continuación, se carga nuevamente "Mapo.dta," y se calcula el porcentaje de los datos del año 2020 con respecto al gasto de todos los municipios del país. Este porcentaje se representa en otro mapa utilizando spmap.
use "Mapo.dta", clear

help rowtotal
gen año2020_1=(año_2020/1000000)
egen suma = total(año2020_1)

gen porcentaje=(año2020_1/suma)
format %7.3gc porcentaje


spmap porcentaje using "perucoord.dta", id(id) ocolor(black) fcolor(Pastel2) clnumber(8) ///
	title() ///
	subtitle("como porcentaje del gasto de todos los municipios del país") ///
	legend (pos (8)  ) ///
	note() 
//El segundo mapa también se guarda en el directorio definido por la variable global "graf."
	graph save "$graf/mapo2.gph", replace
//Finalmente, se combina y muestra ambos mapas en un solo gráfico utilizando graph combine.
 help graph combine 
	
graph combine mapo1 mapo2, ///
	title("Diferentes Esquemas") ///
	subtitle("Ejemplos") ///
	note()

				
