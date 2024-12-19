cd "/Users/diegogilore/Documents/2023-2/Base de datos/FINAL "
use "CPV2017_POB.dta"
cd "/Users/diegogilore/Documents/2023-2/Base de datos/FINAL "
use "CPV2017_POB.dta"
*Quedarnos con las variables relevantes de acceso , sexo distrtito y los demás los excluimos*

keep ccdd ccpp ccdi area viv thogar c5_p1 c5_p4_1 c5_p8_1-c5_p8_6 c5_p9_1-c5_p9_7 factor_pond ubigeo2019

// tabla de datos descriptivos //
*no se puede hacer tablas más avanzadas con stata 16, no se puede descargar el 17 en mac, así que lo hicimos en Latex con la siguiente información*
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

*Se lleva la base de datos a un do file*
shp2dta using "Departamento_INEI_2017.shp" , database(peru) coordinate(perucoord) genid(id) genc(centro) replace
*Usamos la base*
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

//agregando colores//
ssc install schemepack, replace
set scheme rainbow 
ssc install shp2dta, replace
grmap, activate

*Realizamos el mapa de los asegurados*
spmap paseg using "perucoord.dta", id(id) ocolor(black) fcolor(Blues) clnumber(6) ///
    label(data("labels.dta") x(x_c) y(y_c) ///
		    label(label) size(vsmall) position(0 6) length(21)) ///
	title("Asegurados en el 2017 según departamento") ///
	subtitle("(En porcentajes del total de asegurados)") ///
	legend (pos (8)  ) ///
	note("Fuente: INEI Elaboración: Grupo 7") 
graph save "map1.gph", replace


// siguiente mapa SIS//
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

*mapa 2*
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

*REALIZAMOS EL SIGUIENTE GRÁFICO URBANO Y RURAL*

use "CPV2017_POB.dta", clear

*Quedarnos con las variables relevantes de acceso , sexo distrtito y demas fuera


keep ccdd ccpp ccdi area viv thogar c5_p1 c5_p4_1 c5_p8_1-c5_p8_6 c5_p9_1-c5_p9_7 factor_pond ubigeo2019

drop if area==2

rename c5_p8_1 S
rename c5_p8_2 Es
rename c5_p8_3 SF
rename c5_p8_4 SP
rename c5_p8_5 O

collapse (sum) S Es SF SP O

gen SIS=S/1000
gen Essalud=Es/1000
gen SFA=SF/1000
gen SPrivado=SP/1000
gen Otro=O/1000

graph bar SIS Essalud SFA SPrivado Otro, ///
		blabel(total , format(%12.0fc) size(vsmall) color (purple))    ///
		legend(label(1 SIS) label(2 Essalud) label(3 SFA) label(4 SPrivado) label(5 Otro)) ///
		ytitle("Millones de asegurados") ///
		subtitle ("Acceso a seguros por estrato Urbano") ///
		graphregion(color(white)) ylabel(,nogrid) ///
		note ("Fuente: INEI 2017")
		

graph save "Urbano.gph", replace
graph export "Urbano.png", as (png) replace


*ahora rural
use "CPV2017_POB.dta", clear
keep ccdd ccpp ccdi area viv thogar c5_p1 c5_p4_1 c5_p8_1-c5_p8_6 c5_p9_1-c5_p9_7 factor_pond ubigeo2019

drop if area==1

rename c5_p8_1 S
rename c5_p8_2 Es
rename c5_p8_3 SF
rename c5_p8_4 SP
rename c5_p8_5 O

collapse (sum) S Es SF SP O

gen SIS=S/1000
gen Essalud=Es/1000
gen SFA=SF/1000
gen SPrivado=SP/1000
gen Otro=O/1000

graph bar SIS Essalud SFA SPrivado Otro, ///
		blabel(total , format(%12.0fc) size(vsmall) color (purple))    ///
		legend(label(1 SIS) label(2 Essalud) label(3 SFA) label(4 SPrivado) label(5 Otro)) ///
		ytitle("Millones de asegurados") ///
		subtitle ("Acceso a seguros por estrato Rural") ///
		graphregion(color(white)) ylabel(,nogrid) ///
		note ("Fuente: INEI 2017")
		

graph save "Rural.gph", replace
graph export "Rural.png", as (png) replace

*REALIZAMOS GRÁFICOS DE EDADES*

use "CPV2017_POB.dta", clear 

count if c5_p4_1 >= 0 & c5_p4_1 <= 5 & c5_p8_6==0
*2,629,040*
count if c5_p4_1 >= 6 & c5_p4_1 <= 11 & c5_p8_6==0
*2,659,643*
count if c5_p4_1 >= 12 & c5_p4_1 <= 17 & c5_p8_6==0
*2,439,321*
count if c5_p4_1 >= 18 & c5_p4_1 <= 29 & c5_p8_6==0
*3,839,105*
count if c5_p4_1 >= 30 & c5_p4_1 <= 44 & c5_p8_6==0
 *4,596,771*
count if c5_p4_1 >= 45 & c5_p4_1 <= 59 & c5_p8_6==0
 *3,246,896*
count if c5_p4_1 >= 60 & c5_p8_6==0
 *2,762,887*

* Crear un conjunto de datos
clear
input age_group min_age max_age count_insured
1 0 5 2629040
2 6 11 2659643
3 12 17 2439321
4 18 29 3839105
5 30 44 4596771
6 45 59 3246896
7 60 . 2762887
end

* Etiquetar los grupos de edad
label define age_group_lbl 1 "0-5" 2 "6-11" 3 "12-17" 4 "18-29" 5 "30-44" 6 "45-59" 7 "60+"
label values age_group age_group_lbl

* Convertir count_insured a millones
gen count_insured_millions = count_insured / 1000000

* Crear el gráfico de barras
graph bar count_insured_millions, over(age_group) ylabel(, format(%9.1f) labsize(vsmall)) ytitle("Millones de Personas") title("Distribución de Seguros por Edades")

use "CPV2017_POB.dta", clear

* Quedarnos con las variables relevantes
keep ccdd ccpp ccdi area viv thogar c5_p1 c5_p4_1 c5_p8_1-c5_p8_6 c5_p9_1-c5_p9_7 factor_pond ubigeo2019

rename c5_p9_7 discapacidad
rename c5_p8_1 SIS
rename c5_p8_2 Essalud
rename c5_p8_3 militar
rename c5_p8_4 privado
rename c5_p8_5 otro 

gen otros = militar | otro

* Calcula el número de personas con y sin discapacidad que tienen cada tipo de seguro
egen sis_discapacitados = total(SIS & (1 - discapacidad))
egen essalud_discapacitados = total(Essalud & (1 - discapacidad))
egen privado_discapacitados = total(privado & (1 - discapacidad))
egen otros_discapacitados = total(otros & (1 - discapacidad))

egen sis_no_discapacitados = total(SIS & discapacidad)
egen essalud_no_discapacitados = total(Essalud & discapacidad)
egen privado_no_discapacitados = total(privado & discapacidad)
egen otros_no_discapacitados = total(otros & discapacidad)

* Crear los gráficos de sectores

graph pie sis_discapacitados essalud_discapacitados privado_discapacitados otros_discapacitados, ///
    name(Grafico_discapacitados) title("Distribución de Seguros en Personas con Discapacidad") ///
    legend(label(1 "SIS") label(2 "EsSalud") label(3 "Privado") label(4 "Otros")) plabel(_all percent) replace

graph pie sis_no_discapacitados essalud_no_discapacitados privado_no_discapacitados otros_no_discapacitados, ///
    name(Grafico_no_Discapacitados) title("Distribución de Seguros en Personas sin Discapacidad") ///
    legend(label(1 "SIS") label(2 "EsSalud") label(3 "Privado") label(4 "Otros")) plabel(_all percent) 
	
	* Calcular el número total de personas con y sin discapacidad que tienen seguro
egen total_discapacit_con_seg = total(c5_p8_6 == 0 & discapacidad)
egen total_no_discapacit_con_seg = total(c5_p8_6 == 0 & (1 - discapacidad))

* Calcular el número total de personas con y sin discapacidad
egen total_discapacitados = total(discapacidad)
egen total_no_discapacitados = total(1 - discapacidad)

* Calcular los porcentajes
gen pct_disc_con_seguro = total_discapacit_con_seg / total_discapacitados * 100
gen pct_no_disc_con_seg = total_no_discapacit_con_seg / total_no_discapacitados * 100

* Crear una nueva variable de grupo para el gráfico
gen bar_group = 1 if _n == 1
replace bar_group = 2 if _n == 2

* Asignar los porcentajes a la variable porcentaje
gen porcentaje = pct_disc_con_seguro if _n == 1
replace porcentaje = pct_no_disc_con_seg if _n == 2

* Etiquetar los grupos
label define bar_group_lbl 1 "Discapacitados con Seguro" 2 "No Discapacitados con Seguro"
label values bar_group bar_group_lbl

* Crear el gráfico de barras
graph bar porcentaje, over(bar_group) bar(1, color(red)) bar(2, color(green)) ///
    blabel(bar, position(inside) format(%9.1f) color(white)) ///
    name(Grafico_Porcentaje) title("Porcentaje de Personas con Seguro") ///
    ylabel(0(10)100, format(%9.0f)) ytitle("Porcentaje") ///
    legend(label(1 "Discapacitados con Seguro") label(2 "No Discapacitados con Seguro"))
