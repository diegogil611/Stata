*DO

cd "/Users/diegogilore/Documents/2023-2/Base de datos/FINAL "
use "CPV2017_POB.dta", clear

*Quedarnos con las variables relevantes de acceso , sexo distrtito y demas fuera


keep ccdd ccpp ccdi area viv thogar c5_p1 c5_p4_1 c5_p8_1-c5_p8_6 c5_p9_1-c5_p9_7 factor_pond ubigeo2019

destring ccdd, replace


*pie por edades

 
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
 

*datos


generate Edad = 2629040 in 1

replace Edad= 2659643 in 2
replace Edad=  2439321 in 3

replace Edad= 3839105 in 4

replace Edad=  4596771 in 5

replace Edad=  3246896  in 6

replace Edad=  2762887  in 7


gen Edad1=Edad/1000

*Rango de base
gen Rango= .
tostring Rango, replace
 replace Rango = "" if Rango == "."
 replace Rango= "0 a 5 años" in 1
  replace Rango= "6 a 11 años" in 2
   replace Rango= "12 a 17 años" in 3
    replace Rango= "18 a 29 años" in 4
	 replace Rango= "30 a 44 años" in 5
	 replace Rango = "45 a 50 años" in 6
	 replace Rango= "mas de 60 años" in 7
	 
	
*El grafico 
	 
graph bar Edad1, ///
		over(Rango, label(labsize(vsmall) angle(90))) ///
		blabel(total , format(%12.0fc) size(vsmall) color (blue))    ///
		ytitle("Millones de asegurados") ///
		subtitle ("Personas que tienen acceso a un seguro por Edad") ///
		graphregion(color(white)) ylabel(,nogrid) ///
		note ("Fuente: INEI 2017")

graph save "Barras.gph", replace
graph export "Barras.png", as (png) replace
		

	 
*Para  la comparación del total

count if c5_p4_1 >= 0 & c5_p4_1 <= 5 
  3,005,562

count if c5_p4_1 >= 6 & c5_p4_1 <= 11 

 3,179,931
 
count if c5_p4_1 >= 12 & c5_p4_1 <= 17
 3,018,836


count if c5_p4_1 >= 18 & c5_p4_1 <= 29 
 5,867,256
count if c5_p4_1 >= 30 & c5_p4_1 <= 44 
 6,332,438

count if c5_p4_1 >= 45 & c5_p4_1 <= 59 
  4,480,285

count if c5_p4_1 >= 60 
 
   3,497,576
save urural.dta, replace

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
		graphregion(color(white)) ylabel(,nogrid) ///
		note ("Fuente: INEI 2017")
		

graph save "Urbano.gph", replace
graph export "Urbano.png", as (png) replace


*ahora rural
u urural.dta, clear 

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
		graphregion(color(white)) ylabel(,nogrid) ///
		note ("Fuente: INEI 2017")
		

graph save "Rural.gph", replace
graph export "Rural.png", as (png) replace
   


	 


 





 


