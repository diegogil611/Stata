
clear all


********************************************************************************
cd "G:\Mi unidad\Dictado PUCP\2023-II\Laboratorio de Stata\Laboratorio\Clase_11"
use "card.dta"


***** Descripcion de la base
codebook , c

scatter		lwage educ
twoway		scatter	lwage educ	|| lfit	lwage educ
tabstat		nearc2 nearc4 momdad14 sinmom14 step14 black south66 south smsa /*
*/			smsa66 married libcrd14 reg66*, statistics (cou min mean max)/*
*/			columns(statistics)



* Estimacion por MCO + errores estándar robustos
reg lwage educ exper
mfx
estimates store ols_b

***** Estimación con VI 
ssc install ivreg2


ivreg2 lwage exper (educ=nearc4)
mfx
estimates store iv_c

estimates table ols_b iv_c, star(.1 .05 .01)
estimates table ols_b iv_c, p style(oneline)

***** Estimación con MC2E (con instrumento nearc2 y nearc4 para educ)
ivregress 2sls lwage exper (educ = nearc2)
mfx
estimates store iv_2sls

estimates table ols_b iv_c iv_2sls, star(.1 .05 .01)

*Estimación con dos instrumentos

ivregress 2sls lwage exper (educ = nearc2 nearc4)
mfx
estimates store iv_2sls_2

estimates table ols_b iv_c iv_2sls iv_2sls_2, star(.1 .05 .01)

*--------------------------------------------------------------
*** Test de exogeneidad
qui ivregress 2sls lwage exper (educ = nearc2)
estat endog
*Se encuentra que rechaza la H0 al 1% de significancia, hay endogeneidad

qui ivregress 2sls lwage exper (educ = nearc4)
estat endog
*Se encuentra que rechaza la H0 al 1% de significancia, hay endogeneidad

qui ivregress 2sls lwage exper (educ = nearc2 nearc4)
estat endog
*Se encuentra que rechaza la H0 al 1% de significancia, hay endogeneidad

*--------------------------------------------------------------
*Test de sobreidentificación 
*H0: No hay sobreidentificación
*H1: Hay sobreidentificación

qui ivregress 2sls lwage exper (educ = nearc2)
estat overid
*No aplica

qui ivregress 2sls lwage exper (educ = nearc4)
estat overid
*No aplica 

qui ivregress 2sls lwage exper (educ = nearc2 nearc4)
estat overid
*No se rechaza la hipótesis nula 

*--------------------------------------------------------------
***Test de relevancia de los instrumentos

*Se usa Test de Stock, Wright y Yogo (2002)
reg educ nearc2 exper
test nearc2=0
*Valor de F=9.63<10 -> No rechazamos la Ho -> Instrumento débil

qui ivregress 2sls lwage exper (educ = nearc2)
estat firststage
*Se rechaza la Hipótesis Nula con un F igual a 9.63478, por lo que en este caso no nos encontramos ante un instrumento débil al 1% de significancia.

qui ivregress 2sls lwage exper (educ = nearc4)
estat firststage
*Valor de F=58.0156>10 -> Rechazamos la Ho -> Instrumento NO ES débil

qui ivregress 2sls lwage exper (educ = nearc2 nearc4)
estat firststage
*Valor de F=31.556>10 -> Rechazamos la Ho -> Instrumento NO ES débil

*--------------------------------------------------------------

*-----------------------------------------------------------------

cd "G:\Mi unidad\Dictado PUCP\2023-I\Laboratorio Stata\Laboratorio\Clase_12"

global main  "G:\Mi unidad\Dictado PUCP\2023-I\Laboratorio Stata\Laboratorio\Clase_12"
global graf 	  "$main/1.Graficos"

use base.dta, clear 


*------------------------------------------------------------------
*Parte I - Estimación Logit/Probit 
*------------------------------------------------------------------
*Base de datos con información de ENAHO 2017 
*Evaluaremos la decisión de participar o no en el mercado laboral (Y: dependiente)


*Por lo que, dado lo que hemos revisado en clase, Y tomará el valor de 1 si la persona i decide participar en el mercado laboral y 0 en caso contrario 

describe 
tab lfp2

*Variable endógena (y:dependiente) es lfp2
*Variables exógenas (x: independientes) consideramos área (urbano:1, rural:0), sexo (hombre:1, mujer:0), edad, años de estudio, jefe de hogar, si tiene pareja o no, número de hijos menores de 6 años, número de hijos entre 6 y 17 años, y el logaritmo del ingreso laboral 


*Método MPL
reg lfp2 urban edad anoestud sexo jefe conpareja numhijos6 numhijos18 lning_lab
predict xb
codebook xb
dotplot xb, yline(0) yline(1) //¿qué podemos decir de este resultado?

*Método logit

logit lfp2 urban edad anoestud sexo jefe conpareja numhijos6 numhijos18 lning_lab
estimates store logit 

*Método probit
 
probit lfp2 urban edad anoestud sexo jefe conpareja numhijos6 numhijos18 lning_lab

estimates store probit 

*Reportamos ambos resultados

estimates table logit probit,  b(%9.3f) se(%9,3f) t 
estimates table logit probit,  star(0.1 0.05 0.01)
**option star may not be combined with se, t, or p

**Sobre los resultados tendremos que tener en cuenta que estos no pueden ser interpretados en términos de magnitudes. Lo único que podemos analizar son i) los signos y ii) la significancia de los resultados:

*Por ejemplo:
*i) Ser jefe de familia, ser hombre, ser casado, tener más años de estudios,    y vivir en un área urbana genera un incremento en la probabilidad de pertenecer al mercado laboral de forma significativa. 

*ii) Un año más de vida, tener hijos menores de 6 años, tener hijos entre 6 y 17 años genera una reducción en la probabilidad de pertenecer al mercado laboral de forma significativa. 

*Observación: Analizamos todas las variables dado que tenemos resultados significativos de todos los coeficientes al 1% de significancia o en un intervalo de confianza al 99%.


*------------------------------------------------------------------
*Parte II - Análisis Post-Estimación - Test 
*------------------------------------------------------------------

*Analisis de robustez de los coeficientes y del modelo en general 

*Test de Wald: Comando que se utiliza para poner a prueba el valor verdadero del parámetro basado en la estimación de la muestra. 

qui logit lfp2 urban edad anoestud sexo jefe conpareja numhijos6 numhijos18 lning_lab

**Test de una variable (t)
test numhijos6

*H0: numhijos6=0
*H1: numhijos6 =/ 0

**Test conjunto de las variables (F)

*Tipo 1
test numhijos6 numhijos18
*H0: numhijos6,numhijos18=0
*H1: numhijos6, numhijos18 =/ 0 (al menos uno distinto a cero)

*Tipo 2
test numhijos6=numhijos18

*H0: numhijos6-numhijos18=0
*H1: numhijos6-numhijos18=/0 (coeficientes son distintos)


*Test de Ratio de Versosimilitud: Prueba de hipótesis que compara la bondad de ajuste de dos modelos: 

*(i)  Un modelo no restringido con todos los parámetros libres
*(ii) Un modelo restringido por la hipótesis nula a menos parámetros

*Este test detecta la inclusión o no de una variable tomando en cuenta dos modelos 


*Estimación de modelo irrestricto:
qui logit lfp2 urban edad anoestud sexo jefe conpareja numhijos6 numhijos18 lning_lab

estimates store fmodel // fmodel: full model

*Estimación modelo restringido, omitiendo variables del modelo irrestrico 
qui logit lfp2 urban edad anoestud sexo jefe conpareja lning_lab
*se omite numhijos6 numhijos18
estimates store nmodel 


*Procedemos a comparar ambos modelos con el comando lrtest

lrtest fmodel nmodel 


*Ho: Hipótesis nula refiere al modelo restringido (nmodel)
*H1: Hipótesis alternativa refiere al modelo no restringido/irrestrico (fmodel)

*Si se rechaza la Ho, nos quedamos con el modelo irrestricto y las variables son significativas


*------------------------------------------------------------------
*Parte II - Análisis Post-Estimación - Medida de ajuste 
*------------------------------------------------------------------

*instalar paquete findit fitstat

findit fitstat // instalamos el paquete spost9_ado

qui logit lfp2 urban edad anoestud sexo jefe conpareja numhijos6 numhijos18 lning_lab 

fitstat

*Ahora, para la comparación de dos modelos, se creará la variable edad al cuadrado

generate 
gen edad_sq=(edad^2)
g


*En el modelo 1, tenemos el modelo general sin edad_sq

qui logit lfp2 urban edad anoestud sexo jefe conpareja numhijos6 numhijos18 lning_lab // Modelo 1 sin edad

qui fitstat, saving(mod1) // Saved Model

*Una vez estimado el modelo, guardamos con la opción fitsata las medidas de ajuste del primer modelo.

*Ahora procedemos a estimar el segundo modelo con edad_sq

qui logit lfp2 urban edad edad_sq anoestud sexo jefe conpareja numhijos6 numhijos18 lning_lab // Modelo 2 con edad

fitstat, using(mod1) // Current Model


*En este caso, el modelo que tiene mayor verosimilitud es el mejor. Asimismo, siempre el menor BIC y AIC es el que se prefiere. 

*En nuestro ejemplo, el segundo modelo es el que tiene menor BIC y AIC, es decir, el modelo que incluye edad al cuadrado (modelo actual).


*------------------------------------------------------------------
*Parte II - Análisis Post-Estimación - Comparando Logit vs Probit
*------------------------------------------------------------------

qui logit lfp2 urban edad anoestud sexo jefe conpareja numhijos6 numhijos18 lning_lab

qui fitstat, saving(log) // Saving Model

qui probit lfp2 urban edad anoestud sexo jefe conpareja numhijos6 numhijos18 lning_lab

fitstat, using(log) force // Current Model

*El mejor modelo que se ajusta será el logit 

*------------------------------------------------------------------
*Parte II - Análisis Post-Estimación - Predicciones del modelo 
*------------------------------------------------------------------

*Para el modelo logit 

qui logit lfp2 urban edad anoestud sexo jefe conpareja numhijos6 numhijos18 lning_lab

predict prlogit 

codebook prlogit 
sum prlogit 

*Se observa que es 0.26 la probabilidad de que la persona entre a la fuerza laboral. 

*Usando un gráfico de puntos, observaremos la distribución de la probabilidad de entrar a la fuerza laboral 

dotplot prlogit, yline(1) yline(0)
graph save "$graf/logit.gph", replace
graph export "$graf/logit.png", as(png) replace 

*Este mismo procedimiento podemos hacerlo con el modelo probit 

qui probit lfp2 urban edad anoestud sexo jefe conpareja numhijos6 numhijos18 lning_lab

predict prprobit
codebook prprobit  

sum prprobit

dotplot prprobit, yline(1) yline(0)
graph save "$graf/probit.gph", replace
graph export "$graf/probit.png", as(png) replace 


*------------------------------------------------------------------
*Parte II - Análisis Post-Estimación - Predicciones individuales
*------------------------------------------------------------------

*En este caso, haremos inferencias a nivel de individuos con ciertas características 

*i) mujeres con ciertas características 
qui logit lfp2 urban edad anoestud sexo jefe conpareja numhijos6 numhijos18 lning_lab

prvalue, x(sexo=0 edad=25 numhijos6=2 lning_lab=7) rest(mean)

*Rest(mean) implica que todas las variables están ceteris paribus 

*La probabilidad de que entre a la fuerza laboral es de 17.32%

*ii) También podemos analizarlo desde la perspectiva del individuo promedio 

prvalue

*En este caso la probabilidad es de 18.85%

*iii) Análisis de predicciones en la probabilidad de entrar al mercado laboral a medida que se incrementa el número de hijos menores de 6 años, diferenciando por género

prtab numhijos6 sexo, rest(mean)

*La probabilidad de ingresar al mercado laboral se reduce para hombres y mujeres cuando hay más hijos en el hogar 


*------------------------------------------------------------------
*Parte II - Análisis Post-Estimación - Efectos marginales 
*------------------------------------------------------------------

margins, at (lning_lab=(0(10)20) edad=(20(10)60)) 

*A medida que aumenta la edad, el efecto marginal de entrar al mercado laboral aumenta progresivamente 

marginsplot

*------------------------------------------------------------------
*Parte III - Análisis Post-Estimación - Graficando probabilidades
*------------------------------------------------------------------

quietly prgen lning_lab, from(0) to(12) generate(p20) x(edad=20) rest(mean) n(11)
label var p20p1 "20 años"

quietly prgen lning_lab, from(0) to(12) generate(p30) x(edad=30) rest(mean) n(11)

label var p30p1 "30 años"

quietly prgen lning_lab, from(0) to(12) generate(p40) x(edad=40) rest(mean) n(11)
label var p40p1 "40 años"

quietly prgen lning_lab, from(0) to(12) generate(p50) x(edad=50) rest(mean) n(11)

label var p50p1 "50 años"

 quietly prgen lning_lab, from(0) to(12) generate(p60) x(edad=60) rest(mean) n(11)
 label var p60p1 "60 años"
 
list p20p1 p30p1 p40p1 p50p1 p60p1 p60x in 1/11
 
 graph twoway connected p20p1 p30p1 p40p1 p50p1 p60p1 p60x, ytitle("Pr(Fuerza Laboral)") ylabel(0(.25)1) xtitle("Ingreso")
 
*En el gráfico anterior se observa que la probabilidad de entrar a la fuerza laboral es mayor cuando se es más joven.

*Para estimar los efectos marginales usamos el comando margins y especificamos en que rango del ingreso laboral y edad queremos obtener dichos efectos:

margins, at(lning_lab=(0(10)12) edad=(20(10)60))

marginsplot, noci legend(cols(3)) ytitle("Pr(In Labor Force)") scheme(s2mono) ylabel(0(0.1)1)

*Se obtiene que a medida que aumenta la edad, el efecto marginal de entrar al mercado laboral aumenta progresivamente







