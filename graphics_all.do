*Curso: Laboratorio de Econometría: Stata
*Ciclo: 2023-2
*Profesora: Tania Paredes Zegarra
*Sesion 8: Gráficos I
*-------------------------------------------


global main 	"G:\Mi unidad\Dictado PUCP\2023-II\Laboratorio de Stata\Laboratorio\Clase_8"
global data       "$main/2.Data"
global procesadas "$main/3.Procesadas"
global graf 	  "$main/4.Graficos"

use "$procesadas/enaho_laboral.dta", clear

*=========
* Filtros
*=========

* Solo miembros del hogar (Establecer a los residentes habituales)
keep if residente==1

* Se va ocupaciones de fuerzas armadas
drop if skill_ocu==0 

* Redondear factor de expansión
gen facfw=round(fac500a)
// Recordar que el factor de expansión del INEI (fac500a) está con decimales, por eso el redondeo.

* PEA e ingresos positivos
keep if pea==1 & ingreso>0 //nos quedamos con los ingresos positivos y los que pertenecen a la PEA

save "$procesadas/enaho_laborvf.dta", replace

*=============
* Univariante
*=============

*------------------------------
* Gráfico Circular (Pie Plot)
*------------------------------
graph pie pea

graph pie pea, over(zona) //gráf de la PEA por zona en forma de pie_plot

graph pie pea [fw=facfw], over(zona) //Incluimos un criterio de peso (el factor de expansión)

graph pie pea [fw=facfw], over(zona) ///
    plabel(_all percent, size(medium) format(%16.1fc) color (white)) ///
	title("PEA por zona") ///
	subtitle("2021") ///
	legend(rows(1) region(lcolor(white)) color(blue)) ///
	graphregion(color(white)) ///
	note("Fuente: INEI 2021")
	
//Importante: dejar el espacio para las indicaciones (la sangría)!!
//p-label = pie label 

graph save   "$graf/pie_plot.gph", replace
graph export "$graf/pie_plot.png", as(png) replace 

*--------------------
* Gráfico de Barras
*--------------------
sum ingreso
local mean_ingr=r(mean)
display `mean_ingr'

* Barra horizontal
*------------------
graph hbar ingreso [fw=facfw], ///
		over(dpto, sort(ingreso) descending label(labsize(vsmall))) ///
		blabel(total, format(%12.0fc) size(vsmall) color (blue)) yline(`mean_ingr') ///
		title("Ingreso del trabajador por departamento", size(medium)) ///
		subtitle ("Año 2021") ///
		ytitle("S/.") ylabel(,nogrid) subtitle("Año 2021") ///
		graphregion(color(white)) ///
		note ("Fuente: INEI 2021")

//Importante: dejar el espacio para las indicaciones (la sangría)!!
//b-label = bar label 
// over = categoria para la cual se dibujará y criterios detrás
//CORRER DESDE EL SUM!!!
		
graph save "$graf/grafico_barra.gph", replace
graph export "$graf/hbar_plot.png", as(png) replace 


* Barra vertical
*----------------
summ ingreso
local mean_ingr=r(mean) 

graph bar ingreso [fw=facfw], ///
		over(dpto, sort(ingreso) descending label(labsize(vsmall) angle(90))) ///
		blabel(total, format(%12.0fc) size(vsmall) color (purple)) yline(`mean_ingr') ///
		ytitle("Ingreso del trabajador por departamento") ///
		subtitle ("Año 2021") ///
		graphregion(color(white)) ylabel(,nogrid) ///
		note ("Fuente: INEI 2021")
		

graph save "$graf/grafico_barraV.gph", replace
graph export "$graf/barV_plot.png", as(png) replace 

*-------------
* Histogramas
*-------------
histogram ingreso, graphregion(color(white)) //un histograma simple del ingreso
//como se aprecia el gráfico, la mayoria de los datos se concentra en una lado
//por ello, acotamos la información en la siguiente corrida

histogram ingreso if ingreso<6000, graphregion(color(white)) //histograma del ingreso <6000

//Ahora si un gráfico más completo
histogram ingreso if ingreso<6000 [fw=facfw], percent fcolor(purple) ///
	ytitle("Porcentaje") xtitle("Ingreso S/.") ///
	title("Ingreso del trabajador") subtitle("Distribución al 2021") ///
	graphregion(color(white)) ///
	note("Fuente: Elaboración propia en base a la ENAHO 2021")	
	
graph export "$graf/histograma.png", as(png) replace

//Podemos incluir incluso la distribución normal o un kernel de densidad
histogram ingreso if ingreso<6000 [fw=facfw], percent fcolor(purple) normal ///
	ytitle("Porcentaje") xtitle("Ingreso S/.") ///
	title("Ingreso del trabajador") subtitle("Distribución al 2021") ///
	graphregion(color(white)) ///
	normopts (lcolor(red)) kdensity kdenopts (lcolor (yellow)) ///
	note("Fuente: Elaboración propia en base a la ENAHO 2021")	
	
graph export "$graf/histND.png", as(png) replace


*---------------------
* Densidad de Kernel
*--------------------
kdensity ingreso [fw=facfw]

kdensity ingreso [fw=facfw] if ingreso<6000, ///
	lcolor (pink) ///
	ytitle("Densidad") xtitle("Ingreso del trabajador") ///
	title("Distribución 2021") ///
	graphregion(color(white)) ylabel(, nogrid) ///
	legend(label(1 "2021") region(lcolor(white))) ///
	note ("Fuente: INEI 2021")
	
graph export "$graf/kernel.png", replace

*----------------------------
* Gráfico de cajas (Box Plot)
*------------------------------

* Box vertical
*--------------
graph box lnwage [fw=facfw], ///
	graphregion(color(white)) ylabel(, nogrid) ///
	ytitle("Logaritmo del Ingreso") ///
	title ("Ingreso") ///
	subtitle ("2021") ///
	note ("Fuente: INEI")
	
graph export "$graf/box_plot.png", as(png) replace 

//Realizamos una diferencia por area geográfica
graph box lnwage [fw=facfw], ///
	over(area) graphregion(color(white)) ///
	ytitle("Logaritmo del Ingreso") ///
	title ("Ingreso por Área geográfica") ///
	subtitle ("2021") ///
	note ("Fuente: INEI")

graph export "$graf/box_plot_area.png", as(png) replace 

* Box horizontal
*----------------
graph hbox lnwage [fw=facfw], ///
	over(dpto) graphregion(color(white)) ///
	ytitle("Logaritmo del Ingreso por Departamento") ///
	title ("Ingreso del Perú") ///
	subtitle ("2021") ///
	note ("Fuente: INEI")
	
graph export "$graf/box_plot_dpto.png", as(png) replace 

*------------------
* Esquemas
*------------------

set scheme s1color
histogram ingreso, name (a1, replace)

set scheme s2color
histogram ingreso, name (a2, replace)

set scheme s1mono
histogram ingreso, name (a3, replace)

set scheme s2mono
histogram ingreso, name (a4, replace)

set scheme economist
histogram ingreso, name (a5, replace)

set scheme sj
histogram ingreso, name (a6, replace)

graph combine a1 a2 a3 a4 a5 a6, ///
	title("Diferentes Esquemas") ///
	subtitle("Ejemplos") ///
	note("Para más información usar help")

//OJO!!! Aquí no debe existir espacio entre el comando y el parentesis

graph export "$graf/esquemas.png", as(png) replace 




*=====================
* Gráficos Bivariados
*=====================

use "$data/base_sumaria_2021.dta", clear // Información Sumaria 2021

*Numero de observaciones
count

*Creamos dos variables 
gen lypc=ln(ypc) // ypc: ingreso per capita mensual
gen lgpc=ln(gpc) // gpc: gasto per capita mensual



*----------------------------------------
* Gráfico de Dispersión (Scatter Plot)
*----------------------------------------

scatter lgpc lypc, graphregion(color(white))

scatter lgpc lypc, graphregion(color(white)) ///
	xtitle("Logaritmo del Ingreso per cápita") ///
	ytitle("Logaritmo del Gasto per cápita") ///
	title("Relación de DOS variables") ///
	subtitle("en Perulandia") ///
	note("Elaboración propia.") ///

graph export "$graf/scatterplot.png", as(png) replace 
graph save "$graf/scatterplot.gph", replace

*-------------------------------------------------
* Graph Twoway (Dispersión y Predicción Lineal)
*-------------------------------------------------
graph twoway (scatter lgpc lypc) (lfit lgpc lypc), /// 
	graphregion(color(white)) ylabel(,nogrid) ///
	xtitle("Logaritmo del Ingreso per cápita") ///
	ytitle("Logaritmo del Gasto per cápita") ///
	title("Relación de DOS variables") ///
	subtitle("en Perulandia") ///
	note("Elaboración propia.") ///	
	legend(label(1 "Log GPC-Log YPC") label(2 "Fitted Values") ///
		   rows(1) region(lcolor(white)))

		   *Con predicción cuadrática 
graph twoway (scatter lgpc lypc) (qfit lgpc lypc), /// 
	graphregion(color(white)) ylabel(,nogrid) ///
	xtitle("Logaritmo del Ingreso per cápita") ///
	ytitle("Logaritmo del Gasto per cápita") ///
	title("Relación de DOS variables") ///
	subtitle("en Perulandia") ///
	note("Elaboración propia.") ///	
	legend(label(1 "Log GPC-Log YPC") label(2 "Fitted Values") ///
		   rows(1) region(lcolor(white)))
		   
		   
graph export "$graf/scatter_fit.png", as(png) replace 
graph save "$graf/scatterfit.gph", replace

*Hemos incluido un graf de dispersión 
* Con lfit = linear prediction plot
*Podemos incluir otros elementos como una predicción cuadrática, polinomios, etc.
*En Economía normalmente usamos este comando para ver correlación entre variables (correlación diferente a causalidad)
*Estamos colocando la leyenda de la dispersión y la predicción en un formato particular

*-------------------------
* Gráfico de Linea y Área
*-------------------------
import excel "$data/PBI_sectores.xlsx", sheet("Anuales") firstrow clear


*-----------------
* Gráfico de Área
*-----------------
graph twoway (area Manufactura Año) (area Agropecuario Año), ///
     graphregion(color(white)) xlabel(1950(10)2020) ylabel(,nogrid) ///
	 ytitle("Millones S/. 2007") ///
	 legend(label(1 "PIB Manufactura") label(2 "PIB Agropecuario") ///
			rows(1) region(lcolor(white)))  
graph export "$graf/area_plot.png", as(png) replace 
graph save "$graf/areaplot.gph", replace

graph twoway (area Pesca Año) (area Electricidad Año), ///
     graphregion(color(white)) xlabel(1950(20)2020) ylabel(,nogrid) ///
	 ytitle("Millones S/. 2007") ///
	 legend(label(1 "PIB Pesca") label(2 "PIB Electricidad") ///
			rows(1) region(lcolor(white)))  
graph export "$graf/area_plot.png", as(png) replace 
graph save "$graf/areaplot.gph", replace

*Vemos que hemos incluido dos areas: manufactura y agropecuario por año
*Incluso delimitaremos los años


*----------------- 	 
* Gráfico de Línea
*-------------------
graph twoway (line Agropecuario Año) ///
			 (line Manufactura Año)
			 
graph twoway (line Pesca Año) ///
			 (line Electricidad Año)

graph twoway (line Agropecuario Año, color(blue)) ///
			 (line Manufactura Año, color(red)), ///
	graphregion(color(white)) xlabel(1950(10)2020) ylabel(5000(15000)80000,nogrid) ///
	ytitle("Millones S/. 2007") ///
	legend(label(1 "PIB Agropecuario") label(2 "PIB Manufactura") ///
	rows(1) region(lcolor(white)))	

graph export "$graf/line_plot.png", as(png) replace 
graph save "$graf/lineplot.gph", replace
	
graph twoway (line Pesca Año, color(green)) ///
			 (line Electricidad Año, color(pink)), ///
	graphregion(color(white)) xlabel(1950(5)2020) ylabel(500(5000)10000,nogrid) ///
	ytitle("Millones S/. 2007") ///
	legend(label(1 "PIB Pesca") label(2 "PIB Electricidad y Agua") ///
	rows(1) region(lcolor(white)))	
	

h twoway

*-------------
* Combinando
*-------------
*graph combine "scatterplot.gph" "scatterfit.gph"
//No va correr

graph combine "$graf/scatterplot" "$graf/scatterfit"

graph combine "$graf/scatterplot" "$graf/scatterfit", rows(1) ///
	title("Gráficos combinados") ///
	subtitle("del Perú") ///
	note("Fuente: Elaboración propia.")
	
graph export "$graf/combine_plot.png", as(png) replace 
graph save "$graf/combine.gph", replace


*==========
* MAPAS
*==========
cd "G:\Mi unidad\Dictado PUCP\2023-I\Laboratorio Stata\Laboratorio\Clase_9"

global main 		"G:\Mi unidad\Dictado PUCP\2023-I\Laboratorio Stata\Laboratorio\Clase_9"
global data     	"$main/2.Datos"
global procesadas 	"$main/3.Procesadas"
global graf 		"$main/4.Graphs"

* Instalamos
*------------

ssc install shp2dta, replace
grmap, activate
ssc install spmap, replace   // Si no funciona spmap, usar grmap

*-----------------
* Jalamos la data
*-----------------

shp2dta using "$data\DEPARTAMENTOS.shp", database(perulandia) coordinates(perucoord) genid(id) genc(centro) replace

// Le decimos a Stata: 
// Jala el shape y crea un dta con esa info y que se llame perulandia
// Genera las coordenadas (llamadas perucoord), un id (llamado id de referencia a cada departamento) y el centroide (llamado centro)

*VEREMOS QUE LO GUARDO EN NUESTRA CARPETA DE DATA

*---------------
*Veamos la data
*--------------
use "$main/perulandia", clear
br
rename DEPARTAMEN dpto1
save "$data/perulandiavf.dta", replace
// Vemos que es solo info cartográfica


*------------------------------------------
*Usamos la solución de la preg 1 de la PC1
*------------------------------------------

* Lo único que haré es que los dptos estén escritos igual para realizar el merge
* Y convertiré a % los datos 

use "$data/aux_2021.dta", clear
decode dpto, gen (dpto_str)
gen dpto1 = upper(dpto_str)
replace dpto1="APURIMAC" if dpto1=="APURíMAC"
replace dpto1="HUANUCO" if dpto1=="HUáNUCO"
replace dpto1="JUNIN" if dpto1=="JUNíN"
replace dpto1="SAN MARTIN" if dpto1=="SAN MARTíN"
replace poverty=poverty*100
format poverty %5.1f
save "$data/pobrezavf.dta", replace


*----------
* Merge
*----------

use "$data/perulandiavf", clear
merge 1:1 dpto1 using "$data/pobrezavf.dta", nogen
save "$data/base_pobreza.dta", replace

// Ya tenemos un cuadro con una ubicación y una información para dibujar

*------------------
*Generando etiquetas
*-------------------
use "$data/base_pobreza.dta", clear

* Creando base de etiquetas: 
preserve
generate label = dpto1
keep id x_c y_c label
gen length = length(label)
save "$data/Labels.dta", replace
restore



*-------
* Mapa
*-------
*use "$data/base_pobreza.dta", clear //En caso no lo tengas abierto/creado

spmap poverty using "$main/perucoord.dta", id(id) ocolor(black) fcolor(BuRd) ///
	label(data("$data/Labels.dta") x(x_c) y(y_c) ///
		    label(label) size(vsmall) position(0 6) length(21)) ///
	title("Pobreza en el Perú") ///
	subtitle("2021") ///
	legend (pos (7) title ("Rangos de pobreza", size (*0.5))) ///
	note("Fuente: INEI 2021")


graph export "$graf/mapa.png", as(png) name ("Graph"), replace 
graph save "$graf/mapa.gph"


