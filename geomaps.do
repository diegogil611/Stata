cd "/Users/diegogilore/Documents/2023-2/Base de datos/FINAL "
use "CPV2017_POB.dta"
*Quedarnos con las variables relevantes de acceso , sexo distrtito y demas fuera

keep ccdd ccpp ccdi area viv thogar c5_p1 c5_p4_1 c5_p8_1-c5_p8_6 c5_p9_1-c5_p9_7 factor_pond ubigeo2019
*variables que serán usadas para los mapas* 
rename c5_p8_1 afisis 
rename c5_p8_6 asegurado
rename ccdd departamento
*Se crea la variable que agrupa si se tiene seguro de salud o no*
replace asegurado=4 if asegurado==0
replace asegurado=0 if asegurado==1
replace asegurado=1 if asegurado==4
label define aseg 1 "cuenta con seguro" 0 "no cuenta con seguro"
label values asegurado aseg
*guandando*
save merge1.dta, replace
destring departamento 

* se hará un collapse según tipo de departamento por seguro de salud *
collapse (sum) asegurado factor_pond, by (departamento)

save mapita.dta, replace 

*traemos la base de datos a un do file, facilito nomas*
shp2dta using "Departamento_INEI_2017.shp" , database(peru) coordinate(perucoord) genid(id) genc(centro) replace
*llamamos a la base*
use "peru.dta" , clear 
rename ccdd departamento
save "peru.dta",replace

//El comando merge en Stata se utiliza para combinar dos conjuntos de datos (datasets) basándose en una o más variables comunes. La principal utilidad de este comando es combinar información de dos datasets diferentes en uno solo
use "peru.dta", clear
merge 1:1 departamento using "mapita.dta" , nogen
save "Map1.dta", replace 
*creamos una variable para el porcentaje de los asegurados según departamento*
gen porcentaje=(asegurado/factor_pond)*100
format %7.3gc porcentaje
rename porcentaje paseg

*creando etiquetas*
generate label = nombdep
keep id x_centro y_centro label
gen length = length(label)
save "labels.dta", replace 
restore 

//agragando colorcitos cheveres//
ssc install schemepack, replace
set scheme rainbow 
ssc install shp2dta, replace
grmap, activate

*haciendo el mapita de los asegurados*
spmap paseg using "perucoord.dta", id(id) ocolor(black) fcolor(Blues) clnumber(6) ///
    label(data("labels.dta") x(x_c) y(y_c) ///
		    label(label) size(vsmall) position(0 6) length(21)) ///
	title("Asegurados en el 2017 según departamento") ///
	subtitle("(En porcentajes del total de asegurados)") ///
	legend (pos (8)  ) ///
	note("Fuente: INEI Elaboración: Grupo 7") 
graph save "map1.gph", replace



// siguiente mapita SIS//
u merge1.dta, clear 
collapse (sum) afisis factor_pond, by (departamento)
save mapita2.dta, replace 
*merge con la base del mapa *
use "peru.dta", clear
merge 1:1 departamento using "mapita2.dta" , nogen
save "Map2.dta", replace 
*creamos una variable para el porcentaje de los asegurados según departamento*
gen porcentaje=(afisis/factor_pond)*100
format %7.3gc porcentaje
rename porcentaje paseg

*mapita 2*
spmap paseg using "perucoord.dta", id(id) ocolor(black) fcolor(OrRd) clnumber(5) ///
    label(data("labels.dta") x(x_c) y(y_c) ///
		    label(label) size(vsmall) position(0 6) length(21)) ///
	title("Asegurados con SIS en el 2017") ///
	subtitle("(En porcentajes del total de asegurados según departamento)") ///
	legend (pos (8)  ) ///
	note("Fuente: INEI Elaboración: Grupo 7") 
graph save "map2.gph", replace

label list
label variable codigo_departamento
label define departamentos 1 "Amazonas" 2 "Ancash" 3 "Apurimac" 4 "Arequipa" 5 "Ayacucho" 6 "Cajamarca" 7 "Callao" 8 "Cusco" 9 "Huancavelica" 10 "Huánuco" 11 "Ica" 12 "Junín" 13 "La Libertad" 14 "Lambayeque" 15 "Lima" 16 "Loreto" 17 "Madre de Dios" 18 "Moquegua" 19 "Pasco" 20 "Piura" 21 "Puno" 22 "San Martín" 23 "Tacna" 24 "Tumbes" 25 "Ucayali"
label values codigo_departamento departamentos
tab codigo_departamento
// tablita de datos descriptivos //
u merge1.dta
rename c5_p8_2 afiessalud
rename c5_p8_3 afifuerzas
rename c5_p8_4 afipriv
rename c5_p8_5 afiotros

table afisis afiessalud, c(freq) by (departamento)
table afisis afifuerzas, c(freq) by (departamento)
table afisis afipriv, c(freq) by (departamento)
table afisis afiotros, c(freq) by (departamento)

table afisis afiessalud, c(freq)
table afisis afifuerzas, c(freq)
table afisis afipriv, c(freq)
table afisis afiotros, c(freq)
