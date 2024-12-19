*******************************************************
*Pontificia Universidad Católica del Perú   
*2023-2
*LABORATORIO DE CÓMPUTO: MANEJO DE BASES DE DATOS          
*Profesor: Diego Quispe Ortogorin
*Sesión 5
*******************************************************

clear all
set more off
cd "/Users/diegogilore/Documents/2023-2/Base de datos/Sesión 4 y 5" 

	
*------------------------------------------------------------------------------*
*** Importar bases de datos ***
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
	bysort p29 : summ p32_2
	bysort p29 : tab p32_2
	bysort distrito p29 : tabstat p32_2
	asdoc tabstat p32_1 p32_2, stat (mean sd cv) by(p29)
	tabstat p32_1 p32_2, stat (mean sd p75) by(departamento)
	tab p29 departamento, row 
	tab p29 departamento, col
	table p29 departamento, contents (mean p32_2 sd p32_1)
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
	
	
