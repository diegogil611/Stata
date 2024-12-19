*DO

cd "C:\Users\51943\Desktop\Cato\BASES DE  DATOS\FINAL"
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



