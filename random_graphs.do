*Configuraciones previas*
cd "/Users/diegogilore/Documents/2023-2/Lab.Stata/Semana 5"
global main 	"/Users/diegogilore/Documents/2023-2/Lab.Stata/Semana 5"
global data       "$main/2.Data"
global procesadas "$main/3.Procesadas"
global graf 	  "$main/4.Graficos"
clear all

u "Trim Feb-Mar-Abr20.dta"

br OCU200
summ OCU200
gen empleado=0 if OCU200
replace empleado=1 if OCU200==1
tab empleado
label list
label variable empleado
label define actividad_empleados 0 "pea no ocupada" 1 "pea ocupada"
label values empleado actividad_empleados
tab empleado 

label list
label variable P109A
label define Nivel_edu 1 "Sin Nivel" 2 "Inicial" 3 "Primaria Incompleta" 4 "Primaria Completa" 5 "Secundaria Incompleta" 6 "Secundaria Completa" 7 "Superior No Universitaria Incompleta" 8 "Superior No Universitaria Completa" 9 "Superior Universitaria Incompleta" 10 "Superior Universitaria Completa"
label values P109A Nivel_edu

*Gráfico de barras*

graph hbar INGTOT , ///
		over(P109A, sort(INGTOT) descending label(labsize(vsmall))) ///
		blabel(total, format(%12.0fc) size(vsmall) color (blue)) ///
		title("Ingreso del trabajador por Nivel educativo", size(medium)) ///
		subtitle ("Año 2021") ///
		ytitle("S/.") ylabel(,nogrid) subtitle("Año 2021") ///
		graphregion(color(white)) ///
		note ("Fuente: INEI 2021")	
graph export "$graf/hbar_plot.png", as(png) replace 	

*Gráfico Histograma*

graph hbox P109A, ///
	over(empleado) graphregion(color(white)) ///
	ytitle("Grado de educación") ///
	title ("Nivel de educación de la PEA") ///
	subtitle ("2021") ///
	note ("Fuente: INEI: Encuesta permanente de empleo")
graph export "$graf/histograma.png", as(png) replace	
	
*Gráfico PIE*
 
label list
label variable P217
label define motivo  1 "No hay trabajo" 2  "Se cansó de buscar" 3 "Por su edad" 4 "Falta de experiencia" 5 "Sus estudios no le permiten" 6 "Los que haceres del hogar no le permiten" 7 "Razones de Salud" 8 "Falta de capital" 9 "Otro" 10 "Ya encontró trabajo" 11 "Si buscó trabajo"
label values P217 motivo 

gen mnocu=1 if empleado==0 & P107==2
keep if mnocu==1 & P217<9

graph pie mnocu, over(P217) ///
    plabel(_all percent, size(biger) format(%16.1fc) color(white)) ///
	title("Motivos de una Mujer no ocupada") ///
	subtitle("2021") ///
	legend(rows(4) region(lcolor(black)) color(black)) ///
	graphregion(color(white)) ///
	note("Fuente: INEI 2021") 
graph export "$graf/pie_plot.png", as(png) replace 
