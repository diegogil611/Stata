*******************************************************
*Pontificia Universidad Católica del Perú   
*LABORATORIO DE CÓMPUTO: MANEJO DE BASES DE DATOS          
*Profesor: Diego Quispe Ortogorin
*Sesión 8
*******************************************************

clear all

*** Directorios ***
global sesion8 "/Users/diegogilore/Documents/2023-2/Base de datos/ Semana 6-20230920"

cd "$sesion8"

*---------------------------------*
*** Loops dentro de otros loops ***
*---------------------------------*
	
	/*Cuando se utiliza un loop dentro de otro:
	Se empieza con el primer elemento del primer loop (el más externo)
	Luego opera todo el segundo loop (bajo el primer elemento del primero)
	Luego se pasa al siguiente elemento del primer loop
	Vuelve a operar todo el segundo loop
	Esto se repite hasta que se repitan todos los elementos del primer loop */
		
	* Siempre que usemos loops anidados, cada loop debe tner un elemento iterativo diferente 
	/*
		En la primera repetición: x = 1 & y = 10
		En la segunda repetición: x = 1 & y = 11
		En la tercera repetición: x = 2 & y = 10
		En la cuarta  repetición: x = 2 & y = 11
	*/
	forvalues x = 1/20 {
		forvalues y = 11(2)100 {
			display `x' + `y'
		}
	}
	

	* Veamos un ejemplo aplicado *
	forvalues x = 2018/2019 {
		use "$sesion8\persona1_`x'" , clear // Abrir base personas1
		merge 1:1 idpersona using "$sesion11\persona2_`x'" , keep(match) // Pegar base personas2
		
		* Generar variables *
		gen mujer = p207 == 2
		rename p208a edad
		
			* Variables ficticias de ingreso por fuentes *
			gen ing_dep = uniform() * 10000
			gen ing_ind = uniform() * 10000
			gen ing_rent = uniform() * 10000
			gen ing_tot = ing_dep + ing_ind + ing_rent
		
		codebook ocu500 // La variable ocu500 tiene 4 valores
		* Con el loop a continuación puede generar una dummy para cada valor de ocu500 *
		forvalues y = 1/4 {
			gen ocu`y' = ocu500 == `y'
		}
		
		* Con el loop a continuación podemos obtener el ingreso en logaritmos para cada variable de ingresos
		foreach var of varlist ing_dep ing_ind ing_rent ing_tot {
			gen log`var' = log(`var')
		}
		
	
		* Colapsamos las variables creadas *
		collapse mujer edad ocu1-ocu4 ing_* log*
		gen anio = `x'
		order anio
		
		*tempfile b`x' // Generamos tempfile
		save b`x'.dta, replace // Guardamos tempfile
	}
	
	* Juntar las bases creadas *
	use b2018.dta , clear
	append using b2019.dta
	
*********************************************************************************


*--------------*
*** Gráficos ***
*--------------*
	
	* Scheme --> Hay una infinidad de elementos de los gráficos que se pueden personalizar
	*ssc install plotplain
ssc install s1color
	*set scheme plotplain
set scheme s1color
install economist
	use "persona1_2018.dta" , clear
	merge 1:1 idpersona using "persona2_2018" , keep(match) nogen
	
	gen mujer = p207 == 2
	label define lmujer 0 "Hombre" 1 "Mujer" 
	label values mujer lmujer
	
	gen ocup = ocu500 == 1
	label var ocup "Ocupado/a"
	gen desemp = inlist(ocu500 , 2)
	label var desemp "Desempleado/a"
	gen inact = inlist(ocu500 , 3,4)
	label var inact "Inactivo/a"
	
	
	*** Barras ***
	
		* Gráfico simple *
		graph bar mujer
		graph bar mujer , ytitle("Porcentaje de mujeres")
		graph bar mujer , ytitle("Porcentaje de mujeres") yscale(range(0 1)) ylabel(0(0.25)1) title("Mujeres")
		
		* Usando opción over *
		graph bar p208a, over(mujer)
		graph bar p208a , over(mujer) ytitle("Edad promedio")
		graph bar p208a , over(mujer) ytitle("Edad promedio") blabel(total)
		graph bar p208a , over(mujer) ytitle("Edad promedio") blabel(total , format(%9.2f) size(vhuge))
		graph bar p208a , over(mujer) ytitle("Edad promedio") blabel(total , format(%9.1f) size(medsmall)) yscale(range(0 45))
		graph bar p208a , over(mujer) ytitle("Edad promedio") blabel(total , format(%9.1f) size(medsmall)) yscale(range(0 45)) ylabel(none)
		graph bar p208a , over(mujer) ytitle("") blabel(total , format(%9.1f) size(medsmall)) yscale(range(0 45)) ylabel(none)
		graph bar p208a , over(mujer) ytitle("CANTIDAD PROMEDIO") blabel(total , format(%9.1f) size(medsmall)) yscale(range(0 45)) ylabel(none) title("Edad promedio según sexo")
		
		* Un ejemplo más *
		graph bar ocup desemp inact, over(mujer)
		graph bar ocup desemp inact , over(mujer) ytitle("Porcentaje")
		graph bar ocup desemp inact , over(mujer) ytitle("Porcentaje") blabel(total)
		graph bar ocup desemp inact , over(mujer) ytitle("Porcentaje") blabel(total , format(%9.1f) size(medsmall))
		graph bar ocup desemp inact , over(mujer) ytitle("Porcentaje") blabel(total , format(%9.1f) size(medsmall)) yscale(range(0 0.85))
		graph bar ocup desemp inact , over(mujer) ytitle("Porcentaje") blabel(total , format(%9.1f) size(medsmall)) yscale(range(0 0.85)) ylabel(none)
		
		graph bar ocup desemp inact , over(mujer) ytitle("Porcentaje") blabel(total , format(%9.1f) size(medsmall)) yscale(range(0 0.85)) ylabel(none) ///
			legend(label(1 "Ocupado/a") label(2 "Desempleado/a") label(3 "Inactivo/a"))
			
			
		graph hbar ocup desemp inact , over(mujer) ytitle("Porcentaje") blabel(total , format(%9.2f) size(medsmall)) yscale(range(0 0.85)) ylabel(none) ///
			bar(1 , color(sand)) bar(2 , color(teal)) bar(3 , color(sienna)) ///
			legend(label(1 "Ocupado/a") label(2 "Desempleado/a") label(3 "Inactivo/a") row(1) region(lstyle(none))) 
			
//row se puede cambiar por col para elegir si uno desea la leyenda en fila o en columna//
			
			help colorstyle##colorstyle
		
//COMO SÉ QUE COLORES --> EN HELP / GRAPHS /COLOR /ETC//
	*** Pie ***
		graph pie ocup desemp inact
		graph pie ocup desemp inact , plabel(_all percent , color(white) size(medsmall))
		graph pie ocup desemp inact , plabel(_all percent , color(white) format(%9.1f) size(medsmall)) ///
			legend(col(3) region(lstyle(none))) plotregion(lstyle(none))
		graph pie ocup desemp inact , plabel(_all percent , color(white) format(%9.1f) size(medsmall)) ///
			legend(col(3) region(lstyle(none))) plotregion(lstyle(none)) by(mujer , note(""))
		graph pie ocup desemp inact , plabel(_all percent , color(white) format(%9.1f) size(medsmall)) ///
			legend(col(3) region(lstyle(none))) plotregion(lstyle(none)) by(mujer , note("Fuente: Elaboración propia")) 
		
		
	*** Histograma ***
		histogram p208a
		histogram p208a, frequency
		histogram p208a , xtitle("Edad en años") ytitle("Densidad")
		histogram p208a , xtitle("Edad en años") ytitle("Densidad") width(10) // width(5) width(10)
		histogram p208a , xtitle("Edad en años") ytitle("Densidad") bin(10)
		histogram p208a , xtitle("Edad en años")  width(1) percent // fraction frequency
		histogram p208a , xtitle("Edad en años")  width(1) frequency
		
		
	*** Densidad ***
		kdensity p208a 
		kdensity p208a , xtitle("Edad en años") ytitle("Densidad") // normal
		kdensity p208a , xtitle("Edad en años") ytitle("Densidad") lcolor(red) 
		// y si quiero graficar varias densidades en un solo gráfico?
		
		twoway (kdensity p208a if mujer==0, xtitle("Edad en años") ytitle("Densidad") lcolor(red)) (kdensity p208a if mujer==1, xtitle("Edad en años") ytitle("Densidad") lcolor(blue))
		
	*** Lineas ***
		* Ejemplo 1 *
		import excel using "$sesion8\exportaciones.xlsx" , first clear sheet("ExportsPeru")
		
		twoway scatter AgroNT year
		twoway line AgroNT year
		twoway line AgroNT year , xtitle("Año") ytitle("Crecimiento respecto a 1994")
		
		twoway 	(line AgroNT year) (line OtherNT year, xtitle("Año") ytitle("Crecimiento respecto a 1994"))
		
	twoway 	(line AgroNT year) (line OtherNT year, xtitle("Año") ytitle("Crecimiento respecto a 1994")), legend(label(1 "Exportaciones Agropecuarias") label(2 "Otras exportaciones") )
			
		
		**************************************************************************
		
		* Ejemplo 2 *
		import excel using "$sesion8\exportaciones.xlsx" , first clear sheet("ExportsRegion")
		twoway (line Peru Year , lcolor(dknavy)) ///
				(line Chile Year , lcolor(dkorange)) ///
				(line Colombia Year , lcolor(dkgreen)) /// 
				(line Ecuador Year , lcolor(cranberry) ///
				xtitle("Year") ytitle("Relative growth (base=1995)") legend(off) ///
				text(6.3 2019.8 "Peru     " , color(dknavy) size(small) j(left) place(c)) ///
				text(4 2019.8 "Chile     " , color(dkorange) size(small) j(left) place(c)) ///
				text(2 2019.8 "Colombia" , color(dkgreen) size(small) j(left) place(c)) ///
				text(4.7 2019.8 "Ecuador" , color(cranberry) size(small) j(left)) ///
				xscale(range(1995 2018)) xlabel(1995(4)2022))
				
					
		* Ejemplo 3 *
		rename (Peru Chile Colombia Ecuador) (c1 c2 c3 c4) // Renombrar variables para hacer reshape
		reshape long c , i(Year) j(pais) // Realizamos reshape de la base
		label define lpais 1 "Peru" 2 "Chile" 3 "Colombia" 4 "Ecuador" // Definimos labels
		label values pais lpais // Asignamos labels
		
		twoway (line c Year if pais == 1 , lcolor(dknavy)) ///
				(line c Year if pais == 2 , lcolor(dkorange)) ///
				(line c Year if pais == 3 , lcolor(dkgreen)) /// 
				(line c Year if pais == 4 , lcolor(cranberry) ///
				xtitle("Year") ytitle("Relative growth (base=1995)") legend(off)	///
				text(6.3 2019.8 "Peru     " , color(dknavy) size(small) j(left) place(c)) ///
				text(4 2019.8 "Chile     " , color(dkorange) size(small) j(left) place(c)) ///
				text(2 2019.8 "Colombia" , color(dkgreen) size(small) j(left) place(c)) ///
				text(4.7 2019.8 "Ecuador" , color(cranberry) size(small) j(left)) ///
				xscale(range(1995 2022.5)) xlabel(1995(5)2022.5))
				
				

	
****Mapas*******************************************************************
	
ssc install spmap
ssc install shp2dta  
ssc install mif2dta

*Departamental
shp2dta using "DEPARTAMENTOS_inei_geogpsperu_suyopomalia.shp", database(perudpto) coordinates(corrdpto) genid(id)

use perudpto, clear
gen dpto=OBJECTID
drop if dpto==7
merge 1:1 dpto using car_dpto.dta

format %7.3g f_elec
spmap f_elec using corrdpto.dta, id(id)  fcolor(Greens2) clnumber(4)

spmap v_sex2017 using corrdpto.dta, id(id)  fcolor(Blues) clnumber(5)

*Provincias
shp2dta using "PROVINCIAS_inei_geogpsperu_suyopomalia.shp", database(peruprov) coordinates(corrprov) genid(id)

use peruprov, clear
gen prov=real(IDPROV)
merge 1:1 prov using car_prov.dta

spmap altura using corrprov.dta, id(id) fcolor(Rainbow) clnumber(99) 

spmap densidad_2013 using corrprov.dta, id(id) fcolor(Purples) clnumber(9) 



*Distritos
shp2dta using "DISTRITOS_inei_geogpsperu_suyopomalia.shp", database(perudist) coordinates(coordist) genid(id) 

use perudist, clear
rename UBIGEO ubigeo
merge 1:1 ubigeo using car_dist.dta

spmap noparedes using coordist.dta, id(id) fcolor(YlGnBu) clnumber(9)

spmap DENSIDAD using coordist.dta, id(id) fcolor(Reds) clnumber(9)


*Solo Cusco
*Distritos de una region
keep if NOMBDEP=="CUSCO"
spmap f_desag using coordist.dta, id(id) fcolor(YlGnBu) clnumber(9)
graph save "cusco.png", replace

*Distitros de una provincia
keep if NOMBPROV=="CALCA"
spmap noparedes using coordist.dta, id(id) fcolor(YlGnBu)
	
	
	
