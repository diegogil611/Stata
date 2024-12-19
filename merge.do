*******************************************************
*Pontificia Universidad Católica del Perú   
*LABORATORIO DE CÓMPUTO: MANEJO DE BASES DE DATOS          
*Profesor: Diego Quispe Ortogorin
*Sesión 11
*******************************************************

clear all

global sesion18 ""

*==============================================================================*
* Módulo de vivienda *
*==============================================================================*
	
	use "$sesion18\cpv2017_viv08_mod" , clear 
	
	* Normalmente, solo nos interesan las viviendas ocupadas *
	keep if inlist(c2_p2 , 1,2,3)
	
	* Algunos indicadores *
		* Servicios *
		gen agua = c2_p6 == 1
		gen sshh = c2_p10 == 1
		gen luz = c2_p11 == 1
		gen servicios3 = (agua == 1 & sshh == 1 & luz == 1) // Todos los servicios de máxima calidad
		
		* Título de propiedad *
		gen ctitulo = c2_p13 == 3 // Propia con título
		
		* Servicios + título *
		gen serv3titulo = servicios3 == 1 & ctitulo == 1 
		
	* Guardaremos la base para poder usarla luego *
	keep agua sshh luz servicios3 ctitulo serv3titulo c2_p13 id_viv_imp_f ccdd ccpp ccdi

	save viv.dta, replace
		
	* ¿Podemos obtener indicadores a nivel distrital? ¿Por qué?
	collapse agua sshh luz servicios3 ctitulo serv3titulo , by(ccdd ccpp ccdi)
	gen ubigeo = ccdd + ccpp + ccdi
	*merge 1:1 ubigeo using "$sesion9\ubigeo_mayusM" // , keep(match) nogen


*==============================================================================*
* Módulo de hogar *
*==============================================================================*

	use "$sesion18\cpv2017_hog08_mod" , clear // Activos del hogar
	
	* Qué indicador les interesa?
	gen tvcolor = c3_p2_2 == 1
	gen refri = c3_p2_4 == 1
	
	keep tvcolor refri id_hog_imp_f id_viv_imp_f
	
	save hog.dta, replace
	
*==============================================================================*
* Módulo de población *
*==============================================================================*

	use "$sesion18\cpv2017_pob08_mod" , clear
	
	* Migración *
	gen mig5 = c5_p6 == 3 // Migró de distrito en los últimos 5 años --> De dónde vienen ests personas?
	gen migtotal = c5_p7 == 2 // Migración intergeneracional
	
	* Trabajo *
	gen trabaja = c5_p16 == 1 | inlist(c5_p17 , 1,2,3,4,5)
    tab c5_p21 if trabaja == 1
	tab c5_p21 [iw = factor_pond] if trabaja == 1 // Tipo de trabajador
	tab c5_p22 [iw = factor_pond] if trabaja == 1 // Tipo de trabajador
	
	* Autoidentificación *
	tab c5_p25_i_mc
	
*==============================================================================*
* Unir módulos del CPV *
*==============================================================================*

	merge m:1 id_hog_imp_f using hog.dta , gen(merge_hogar) // Merge con módulo de hogar
	merge m:1 id_viv_imp_f using viv.dta , gen(merge_viv) // Merge con módulo de vivienda
	
*==============================================================================*
* Modelo para trabajar con todas las regiones del CPV  *
*==============================================================================*

* Apilar todas las regiones no es la mejor opción si se tiene un equipo con potencia limitada

	foreach p in "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "23" "24" "25" {
	use "$sesion18\cpv2017_viv`p'_mod" , clear 
	
	* Normalmente, solo nos interesan las viviendas ocupadas *
	keep if inlist(c2_p2 , 1,2,3)
	
	* Algunos indicadores *
		* Servicios *
		gen agua = c2_p6 == 1
		gen sshh = c2_p10 == 1
		gen luz = c2_p11 == 1
		gen servicios3 = (agua == 1 & sshh == 1 & luz == 1) // Todos los servicios de máxima calidad
		
		* Título de propiedad *
		gen ctitulo = c2_p13 == 3 // Propia con título
		
		* Servicios + título *
		gen serv3titulo = servicios3 == 1 & ctitulo == 1 
		
	* Guardaremos la base para poder usarla luego *
	keep agua sshh luz servicios3 ctitulo serv3titulo c2_p13 id_viv_imp_f ccdd ccpp ccdi

	save viv`p'.dta, replace
		
	* ¿Podemos obtener indicadores a nivel distrital? ¿Por qué?
	collapse agua sshh luz servicios3 ctitulo serv3titulo , by(ccdd ccpp ccdi)
	gen ubigeo = ccdd + ccpp + ccdi
	*merge 1:1 ubigeo using "$sesion9\ubigeo_mayusM" // , keep(match) nogen
	
*==============================================================================*
* Módulo de hogar *
*==============================================================================*

	use "$sesion18\cpv2017_hog`p'_mod" , clear // Activos del hogar
	
	* Qué indicador les interesa?
	gen tvcolor = c3_p2_2 == 1
	gen refri = c3_p2_4 == 1
	
	keep tvcolor refri id_hog_imp_f id_viv_imp_f
	
	save hog`p'.dta, replace
	
*==============================================================================*
* Módulo de población *
*==============================================================================*

	use "$sesion18\cpv2017_pob`p'_mod" , clear
	
	* Migración *
	gen mig5 = c5_p6 == 3 // Migró de distrito en los últimos 5 años --> De dónde vienen ests personas?
	gen migtotal = c5_p7 == 2 // Migración intergeneracional
	
	* Trabajo *
	gen trabaja = c5_p16 == 1 | inlist(c5_p17 , 1,2,3,4,5)
    tab c5_p21 if trabaja == 1
	tab c5_p21 [iw = factor_pond] if trabaja == 1 // Tipo de trabajador
	tab c5_p22 [iw = factor_pond] if trabaja == 1 // Tipo de trabajador
	
	* Autoidentificación *
	tab c5_p25_i_mc
	
*==============================================================================*
* Unir módulos del CPV *
*==============================================================================*

	merge m:1 id_hog_imp_f using hog`p'.dta , gen(merge_hogar) // Merge con módulo de hogar
	merge m:1 id_viv_imp_f using viv`p'.dta , gen(merge_viv) // Merge con módulo de vivienda
	
	
		save region`p'	
	}
	
	use `region01' , clear
	foreach x in "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "23" "24" "25" {
		append using `reg`x''
	}
	
	
	
	
	
	
	
	

