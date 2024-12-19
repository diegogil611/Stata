*******************************************************
*Pontificia Universidad Católica del Perú   
*LABORATORIO DE CÓMPUTO: MANEJO DE BASES DE DATOS          
*Profesor: Diego Quispe Ortogorin
*Sesión 6
*******************************************************

clear all
cls

cd "G:\Mi unidad\Escritorio Diego\2023-1\JPTC\Laboratorio de Cómputo Manejo de Bases de Datos\Sesión 9" 

*----------------*
*** Ejemplo 1A ***
*----------------*
	/* 
	preserve y restore: (ambos comandos q se usan en pareja) preservar base en un momento, restaurar luego. Cuando stata encuentra preserve toma una foto de la base de datos, la almacena y captura cómo está la base de datos en ese momento, cuando stata le da restore esa base volverá a ser igual q antes. Lo q sea q se hace entre ambos comandos si no se guarda, se pierde / se usa para cuando alguien quiere hacer un cambio momentaneo en la base de datos
	
	collapse // Reduce la base al nivel especificado, obteniendo estadísticas resumen para las variables elegidas
	
	save // Guardar base de datos
	
	export // Exportar y guardar base de datos en otro formaro 
	
	erase // Borrar una base de datos (no es reversible)

	*/
	
	use hogar1_2018 , clear
	des // para ver qué hay en la base de datos
	
	* Generar variables *
		gen idreg = substr(ubigeo , 1 , 2) // código de región; empiezo por el primero y saco los 2 primeros digitos de la var. ubigeo y el resultado es una nueva var. llamada idreg
		gen idprov = substr(ubigeo , 3 , 2)
		gen iddis = substr(ubigeo , 5 , 2)
		
		gen pared_ladcem = p102 == 1 // Generar dummy q identifique las viviendas q tienen pared de ladrillo o cemento (es una sola opción)
		rename (p104) (nhabs) // cambio de nombre de variable p104 por el nombre nhabs
		gen cons_at = p104b2 == 1 // generar una dummy de vivienda construida con asistencia técnica 
		gen elect = p1121 == 1 // dummy si el hogar tiene acceso a alumbrado del hogar por electricidad
		gen n = 1 //generar una var. n q solo tenga 1 como observación
		
	preserve //va a preservar la base de datos
		br
		* Colapsamos base 
		*collapse (opcional segun lo q se quiere sacar) variables
		collapse pared_ladcem (sd) nhabs (cv) cons_at elect 
		save resultados.dta, replace //tendremos 1 base de datos con una sola observacion q tiene el prom. de cada var. mencionada; si no señalamos nada, por default Stata nos sacará el promedio
	restore
	
	preserve 
		collapse pared_ladcem nhabs cons_at elect , by(idreg) //con by(idreg) ahora tenemos los promedios de las variables mencionadas para cada región; tenemos estadisticas descriptivas para cada grupo designado //tendremos 25 observaciones, pq saca el promedio horizontalmente
	restore
	
	preserve
	
		collapse pared_ladcem nhabs cons_at elect (sum) n , by(idreg) // el (sum) es para especificar la estadística q quiero sacar y las var. q estén dsp de () es a la q aplicará; se obtiene promedios y sum
	restore
	
	preserve
	
		collapse pared_ladcem nhabs cons_at elect (sum) n (median) nhabs_median = nhabs (max) nhabs_max = nhabs , by(idreg) // mediana y max de la variable nhabs / el n es la variable q se creó anteriormente y si se suma n, es ocmo sumar 1 o sea sumar cuántas observaciones queremos
		*si se quiere tener + de 1 estadistica descriptiva para la misma var., se crean vars. q sean igual a la var. original pero con lo q se le quiere sacar en 
		
		save hogar1_2018_coll , replace //guardar la nueva base
		export excel using hogar1_2018_coll.xlsx , first(var) replace // guardar un archivo --> export excel using (name.xlsx) , first(var) (es para q el excel en la primera fila nos ponga el nombre de las var.s) replace SIEMPRE VA
		export delimited using hogar1_2018_coll.csv , replace
	restore //va a restaurar la base de datos
	
	*erase hogar1_2018_coll.dta // ELIMINA BASE DE DATSO DE TU DIRECTORIO Y YA NO LO VOLVERÁS A VER
	
*----------------*
*** Ejemplo 1B ***
*----------------*
	/* 
	tempfiles // Archivos que se guardan temporalmente, son tan temporales q solo existen mientras se ejecuta el código, una vez q termina de ejecutarse este archivo desaparece. Se usa para guardar una base de datos q en el fondo no la necesitamos guardar
	*el archivo temporal solo existe mientras se ejecute el código, nada más
		Hay 3 claves para guardar tempfiles:
				1. Se hace en dos líneas. En la primera se define el tempfile,
				en la segunda se guarda
				2. El nombre del tempfile debe ser el mismo en las dos líneas
				3. En la segunda línea (en la que se guarda el tempfile), el nombre del archivo debe ir entre `'
	*/
	
	use hogar1_2018 , clear
	
	* Generar variables *
		gen idreg = substr(ubigeo , 1 , 2) // código de región
		gen pared_ladcem = p102 == 1 // Pared de ladrillo o cemento
		rename (p104) (nhabs)
		gen cons_at = p104b2 == 1 // vivienda construida con asistencia técnica 
		gen elect = p1121 == 1 // alumbrado del hogar por electricidad
		gen n = 1
		
	preserve
		
		* Colapsamos base *
		collapse pared_ladcem nhabs cons_at elect , by(idreg)
		
		tempfile hogar1_2018c // Definimos tempfile
		save `hogar1_2018c' // Guardamos tempfile
		
	restore
	
	use `hogar1_2018c' , clear // Si queremos usar el tempfile luego, debemos encerrar su nombre entre `'

*---------------*
*** Ejemplo 2 ***
*---------------*
	* append // apila bases de datos (verticalmente) pega una base de datos debajo de la base de datos q tengo abierta
	
	* append *
	use hogar1_2018 , clear // 37 053 observaciones
	gen anio = 2018
	append using hogar1_2019 , generate(base) // Primero va comando luego base de datos q voy a apilar y se usa la opcion generate(base) genera una var. q señala a qué base de datos corresponde cada una de las obsercaciones de la base de datos (añade una variable q asigna a qué variable corresponde la base de datos). Todas las obsercaciones en br q tienen 0 son las de la primera base y 1 son las de la base añadida
	//la var. base va a tener códigos para c/u de las bases q estoy apilando; para la base original le pondrá 0 y la del 2019 1
	// La variable año la generé en la base del 2018 pero no existía en la del 2019, la variable año tiene un missing pq no tiene valores para esa variable pq no existe
	replace anio = 2019 if base == 1 //condicion para identiciar a todas las del 2019
	*lo mismo del anterior es replace anio = 2019 if base ==.
	save hogar1_todo , replace
	
	* merge // une bases de datos usando una (o más) variable como código de identificación (horizontalmente) / une observaciones de dos bases de datos diferentes y utiliza 1 o + variables como código de identificación
		* Base que se tiene abierta: master base
		* Base que se está pegando : using base
	
	* Tipos de merge *
	* 1:1 // Cada observación de una base se une (con) solo una observación de la otra base
	use persona1_2018 , clear //aqui, cada observ. de la base es 1 persona, hay menos código de hogar q de persona, es decir, cada hogar tiene 1 o + personas
	merge 1:1 idpersona using persona2_2018 // va el comando + tipo de merge q voy a hacer + variable q utilizaré para unir ambas bases + using + la base de datos q voy a pegar
	// Si quiero unir otra base de datos debo poner otro merge pero debo ver qué dimensión o tipo de datos son la primera unión del merge
	
	/*
	not match: total de observaciones q no se han pegado
	luego dice cómo se distribuyen las obsercaciones q no se han pegado entre la master base y la using base
	from master:... (_merge==1) --> hay tantas obsercaciones q estaban en master base q no tienen una pareja en using base
	from using: ... (_merge==2) --> no hay (o hay tantas) observaciones de using base q no tenga una pareja en master base
	matched: ... (_merge==3) num. de observaciones q sí se han pegado
	*/
	
	* m:1 // Varias observaciones de master base se pueden unir con la misma observación de using base. 2 personas x obsercaciones / la var. q se debe usar para hacer el merge es la var. q se repite en ambas (la cual en la master tiene + de 1 obvser. repetida y en el usign no tiene observ. repetidas)
	*todas las observ. repetidas con el mismo num. de idhogar tendrán el mismo valor en la variable añadida
	*en master base idhogar (por ejm.) tiene más de 1 persona con el mismo código
	use persona1_2019 , clear
	merge m:1 idhogar using hogar1_2019
	*TIP: usar el comando 'duplicates report idhogar'. Aqui, se ve q en persona1_2019, hay muchos duplicados en las obsercaciones de idhogar y en hogar1_2019, no tiene repeticiones, por eso es m:1
	
	* 1:m // Cada observación de master base puede unirse con una o más observaciones de using base
	*se abre primero el using y se le agrega la base master / a cada hogar (si la var. en comun quiero q sea idhogar), a cada hogar se le pegan varias personas. Como he invertido el orden, los matched son del using
	use hogar1_2019 , clear
	merge 1:m idhogar using persona1_2019
	*si son + bases de datos, se hace en otra linea lo siguiente. Se tiene q ver a qué nivel es la base master nueva q se ha generado del merge anterior para saber qué merge usar para unirlo a la otra base
*	merge 1:1 
	
	* Preguntas:
		* ¿Para qué sirve el merge m:m? Nunca usar, pq este pega si o si, va a forzar la unión de las bases de alguna manera
		* ¿Cómo unir las bases hogar1, persona1 y persona2 en una sola base?
		* ¿A qué nivel quedaría la base?
		* ¿Importa el orden en el que se unan las bases? 

*---------------*
*** Ejemplo 3 ***
*---------------*	
	
	* Cómo funciona reshape *
	
	* 2018 *
	use hogar1_2018 , clear
	* Generar variables *
	gen idreg = substr(ubigeo , 1 , 2) // código de región
	gen pared_ladcem = p102 == 1 // Pared de ladrillo o cemento
	gen anio = 2018
	collapse pared_ladcem anio , by(idreg)
	
	*tempfile b2018
	save b2018.dta, replace
	
	* 2019 *
	use hogar1_2019 , clear
	* Generar variables *
	gen idreg = substr(ubigeo , 1 , 2) // código de región
	gen pared_ladcem = p102 == 1 // Pared de ladrillo o cemento
	gen anio = 2019
	collapse pared_ladcem anio , by(idreg)
	
	*tempfile b2019
	save b2019.dta, replace
	
	* Apilamos bases *
	use b2018.dta , clear
	append using b2019.dta
	
	order idreg anio
	sort idreg anio
	
	*** reshape ***
	* i --> región , j --> periodo
	reshape wide pared_ladcem , i(idreg) j(anio)
	
	reshape long pared_ladcem, i(idreg) j(anio)
	
	* Es MUY común no recordar cómo funciona reshape, usen help sin verguenza 
