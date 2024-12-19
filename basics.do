*******************************************************
*Pontificia Universidad Católica del Perú   
*2023-2
*LABORATORIO DE CÓMPUTO: MANEJO DE BASES DE DATOS          
*Profesor: Diego Quispe Ortogorin
*Sesión 4
*******************************************************
clear all
log using log_sesion4, replace 
cd ""
	
*Mostra valores o texto
display 5+5
display 7*99
display "muy buenos días apreciados estudiantes"

*** Comandos muy largos: ***

*1	
display "Para sobrevivirme te forjé como un arma, como una flecha en mi arco, como una piedra en mi honda. Pero cae la hora de la venganza, y te amo. Cuerpo de piel, de musgo, de leche ávida y firme."

display "Para sobrevivirme te forjé como un arma," /// 
"como una flecha en mi arco, como una piedra en mi honda. Pero cae la hora de la venganza, y te amo. Cuerpo de piel, de musgo, de leche ávida y firme."

display ///
6*77777777   // jfdhfjdshjghjsfjg

display 6*77777777  /*khdfsjghsfhjksgdg */

*2
display /*
*/ 9*66666

*3
# delimit; 
	display 
	9*55555 ;
# delimit cr

*** Otros comando útiles al inicio de un do-file ***
  
  clear
  set obs 30000
  set matsize 1000

  set more off
  
  use "My_data.dta"  , replace
  
  use  "G:\Mi unidad\Escritorio Diego\2023-2\JPTC\Laboratorio de Cómputo Manejo de Bases de Datos\Sesión 4\My_data.dta", replace
  
  tostring id, replace
  destring id, replace
  
  tostring id, gen(id2)
  destring id2, gen(id3)
  
  tabulate edad
  tabulate ingresos
  summarize edad
  summarize ingresos
  
  gen i=1
  gen t=.
  gen estado_civil="casado(a)"
  
  gen genero2=.  
  replace genero2=1 if genero=="femenino"
  replace genero2=2 if genero=="masculino" 
  
  label define genero_ 1 "mujer" 2 "hombre"
  label value genero2 genero_
  
  encode genero, gen(genero3)
  decode genero2, gen(genero4)

  *save, replace
  save "datos_modificados.dta", replace
  
* Bases de datos:

  use "My_data.dta", replace
  use My_data.dta, replace
  use My_data, replace
  
  edit
  browse
  
  ed
  br
  
 *ayuda en stata

  help tabulate  
  help nopomatch
  help encode

  search tabulate
  search anova
	
  *Comando que no está instalado: Quiero un programa que me permita implementar el filtro
  
  findit hodrick prescott

  ssc install hprescott
  
  * Log-file: 

  *** Un log:

 *  Note que en la ventana de resultados aparece la fecha, la hora y el tipo.
  
    log close
  
 * view log_sesion4.smcl
  
  
  
  
  
  
  
  
  
  
  
  

  