*******************************************************
*Pontificia Universidad Católica del Perú   
*LABORATORIO DE CÓMPUTO: MANEJO DE BASES DE DATOS          
*Profesor: Diego Quispe Ortogorin
*Sesión 15
*******************************************************
clear all


*** Directorios ***
cd "/Users/diegogilore/Documents/2023-2/Base de datos/clase sem final"


*=====================================================*
***		 			Datos del BCRP		 			***
*=====================================================*
	
	*** IPC ***
	import delimited "Anuales-20220628-192952.csv" ,  delimiter(",")   clear
	
	rename (v1 v2) (periodo ipc) // Cambiamos nombre de las variables
	drop in 1/2 // Eliminamos encabezados
	drop if periodo == "2022" // No tenemos datos para el 2022 
	destring periodo ipc , replace // Pasamos variables a formato numérico
	
		* Gráfico *
		twoway line ipc periodo , ytitle("IPC (variación porcentual promedio)") xtitle("Año") lcolor(cranberry)
			graph export "$sesion15\line_ipc.png" , as(png) replace
			
		twoway line ipc periodo if periodo >= 2000 , ytitle("IPC (variación porcentual)") xtitle("Año") 	yscale(range(0 7))	ylabel(0(1)7) lcolor(cranberry) yline(1, lcolor(blue)) yline(3, lcolor(blue))
	
	
	
	*** Exportaciones agrícolas ***
	import delimited "Anuales-20220628-192847.csv" , delimiter(",")   clear
	
	drop in 1/2 // Eliminamos encabezados
	br // veamos la base
	compress // Ahorro de espacio
	rename (v1) (periodo) // Cambio de nombre (necesitamos cambiar los demás nombres?)
	drop if periodo == "2022" // No hay datos
	destring * , replace // Todo a numérico
	
	egen trad = rowtotal(v2-v5)
	egen notrad = rowtotal(v6-v11)
	gen ppnotrad = (notrad / (trad + notrad)) * 100
	
	twoway 	(line trad periodo , lcolor(ltblue)) ///
			(line notrad periodo , lcolor(edkblue) ///
			ytitle("FOB millones US$") xtitle("Año") ///
			legend(label(1 "Tradicionales") label(2 "No tradicionales")))
		graph export "$sesion15\line_Xnt.png" , as(png) replace
	* Habría que indicar en el título del gráfico que se trata de Xs agrícolas *
	
	twoway line ppnotrad periodo , ytitle("Porcentaje") xtitle("Año") lcolor(cranberry)
	* Indicar título *
	
	
*=============================================================*
***		 			Datos del Banco Mundial		 			***
*=============================================================*

	import excel "$sesion15\Data_Extract_From_World_Development_Indicators.xlsx" , clear first
	
	drop in 6/10 // Eliminar observaciones que no sirven
	
	* Necesitamos hacer un reshape *
	h reshape
	drop SeriesName SeriesCode CountryName YR2021 // Eliminamos variables que ya no servirán
	reshape long YR , i(CountryCode) j(period)
	rename (YR) (elect)
	
	twoway  (line elect period if CountryCode == "BOL" , lcolor(green)) ///
			(line elect period if CountryCode == "CHL" , lcolor(edkblue)) ///
			(line elect period if CountryCode == "COL" , lcolor(ltblue)) ///
			(line elect period if CountryCode == "ECU" , lcolor(orange)) ///
			(line elect period if CountryCode == "PER" , lcolor(cranberry) ///
			ytitle("Porcentaje") xtitle("Año") ///
			legen(label(1 "BOL") label(2 "CHL") label(3 "COL") label(4 "ECU") label(5 "PER") col(5) region(lwidth(none))))
	
*=============================================================*
***		 			Penn World Table        	 			***
*=============================================================*	
	
use "$sesion15\pwt1001.dta", replace

describe

*Algunas variables
gen GDP=rgdpna/pop
gen logGDP=ln(rgdpna/pop)
gen logK=ln(rnna/pop)
gen logTFP=ln(rtfpna)
gen openness=(csh_x-csh_m)
gen share=csh_i
gen labor=emp/pop
gen humanx=hc
gen t_i=pl_x/pl_m

twoway  line t_i year if country == "Peru" , lcolor(green) ytitle("t_i") xtitle("Año") title("t_i") xlabel(1950(10)2020)

twoway  line humanx year if country == "Peru" , lcolor(green) ytitle("humanx") xtitle("Año") title("humanx") xlabel(1950(10)2020)

twoway  line openness year if country == "Peru" , lcolor(green) ytitle("openness") xtitle("Año") title("openness") xlabel(1950(10)2020)

twoway  line pop year if country == "Peru" , lcolor(green) ytitle("pop") xtitle("Año") title("pop") xlabel(1950(10)2020)

twoway  line logK year if country == "Peru" , lcolor(green) ytitle("logK") xtitle("Año") title("logK") xlabel(1950(10)2020)

twoway  line logTFP year if country == "Peru" , lcolor(green) ytitle("logTFP") xtitle("Año") title("logTFP") xlabel(1950(10)2020)

twoway  line share year if country == "Peru" , lcolor(green) ytitle("share") xtitle("Año") title("share") xlabel(1950(10)2020)

twoway  line GDP year if country == "Peru" , lcolor(green) ytitle("GDP") xtitle("Año") title("PBI per cápita") xlabel(1950(10)2020)

twoway  line logGDP year if country == "Peru" , lcolor(green) ytitle("logGDP") xtitle("Año") title("Logaritmo de PBI per cápita") xlabel(1950(10)2020)  

twoway  (line logGDP year if country == "Peru" , lcolor(green)) ///
		(line logGDP year if country == "Bolivia (Plurinational State of)" , lcolor(edkblue)) ///
		(line logGDP year if country == "Chile" , lcolor(ltblue)) ///
		(line logGDP year if country == "Ecuador" , lcolor(orange)) ///
		(line logGDP year if country == "United States" , lcolor(cranberry) ///
		ytitle("logGDP") legen(label(1 "Perú") label(2 "Bolivia") label(3 "Chile") label(4 "Ecuador") label(5 "Estados Unidos") ///
		col(5) region(lwidth(none))) xtitle("Año") title("Logaritmo de PBI per cápita") xlabel(1950(10)2020))
	
	
	

		
	
	
	
	
	
