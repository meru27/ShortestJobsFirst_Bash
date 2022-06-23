#! /bin/bash
#shell que corre en nuestro script
#funciones
exec 2> /dev/null
if test -e informe.txt
then
	cat informe.txt > informeanterior.txt;
	rm informe.txt
fi
if test -e informeblanco.txt
then
	cat informeblanco.txt > informeblancoanterior.txt;
	rm informeblanco.txt
fi
if test -e sjf.temp
then
	rm sjf.temp;
fi

if test -e ejemplo.txt
then
	rm ejemplo.txt;
fi
printf '\e[8;50;150t'
clear
echo "############################################################"
echo "#                     Creative Commons                     #"
echo "#                                                          #"
echo "#                   BY - Atribución (BY)                   #"
echo "#                 NC - No uso Comercial (NC)               #"
echo "#                SA - Compartir Igual (SA)                 #"
echo "############################################################"
echo "############################################################" > informeSJF.txt
echo "#                     Creative Commons                     #" >> informeSJF.txt
echo "#                                                          #" >> informeSJF.txt
echo "#                   BY - Atribución (BY)                   #" >> informeSJF.txt
echo "#                 NC - No uso Comercial (NC)               #" >> informeSJF.txt
echo "#                SA - Compartir Igual (SA)                 #" >> informeSJF.txt
echo "############################################################" >> informeSJF.txt

echo ""
echo >> informeSJF.txt

echo "#######################################################################" >> informeSJF.txt
echo "#                                                                     #" >> informeSJF.txt
echo "#                         INFORME DE PRÁCTICA                         #" >> informeSJF.txt
echo "#                         GESTIÓN DE PROCESOS                         #" >> informeSJF.txt
echo "#             -------------------------------------------             #" >> informeSJF.txt
echo "#                                                                     #" >> informeSJF.txt
echo "#     Alumnos: Daniel Meruelo Monzón                                  #" >> informeSJF.txt
echo "#     Sistemas Operativos 2º Semestre                                 #" >> informeSJF.txt
echo "#     Versión:    Junio 2019                                         #" >> informeSJF.txt
echo "#     Grado en ingeniería informática (2018-2019)                     #" >> informeSJF.txt
echo "#                                                                     #" >> informeSJF.txt
echo "#######################################################################" >> informeSJF.txt
echo "" >> informeSJF.txt

echo -e "\033[1;34m#######################################################################\033[0m"
echo -e "\033[1;34m#                                                                     #\033[0m"
echo -e "\033[1;34m#                         INFORME DE PRÁCTICA                         #\033[0m"
echo -e "\033[1;34m#                         GESTIÓN DE PROCESOS                         #\033[0m"
echo -e "\033[1;34m#             -------------------------------------------             #\033[0m"
echo -e "\033[1;34m#                                                                     #\033[0m"
echo -e "\033[1;34m#     Alumnos: Daniel Meruelo Monzón                                  #\033[0m"
echo -e "\033[1;34m#     Sistemas Operativos 2º Semestre                                 #\033[0m"
echo -e "\033[1;34m#     Versión:   Junio 2019                                           #\033[0m"
echo -e "\033[1;34m#     Grado en ingeniería informática (2018-2019)                     #\033[0m"
echo -e "\033[1;34m#                                                                     #\033[0m"
echo -e "\033[1;34m#######################################################################\033[0m"
echo ""

echo "" > ejemplo.txt

#cabecera del algoritmo en el que nos encontramos
echo -e "Algoritmo SJF"
echo -e "Daniel Meruelo Monzón"
echo -e "Versión Junio 2019"


#función que comprueba que un nombre es correcto
Comprobarn(){
	palabra=$(echo $1 $2 | wc -w); #cuento las lineas
	if [ $palabra -ne 1 ]  #si es distinto pido otro nombre para el proceso
	then
		echo "No se admiten espacios"
		valido=1;
	else
		valido=0;
	fi

	if [ ${#1} -gt 7 ]
	then
		echo "Nombre demasiado largo"
		valido=1
	fi

	if [ ! -z $hola ]
	then
		echo "Nombre vacío"
		valido=1
	fi

	if [ $valido -eq 1 ]
	then
		echo "Vuelva a introducir el nombre"
	fi
	return $valido
}

# Nos permite saber si el parámetro pasado es entero positivo.
#Devuelve 0 cuando es entero, 1 cuando es negativo y 2 cuando es decimal
es_entero() {
    [ "$1" -eq "$1" -a "$1" -ge "0" ] > /dev/null 2>&1  # En caso de error, sentencia falsa (Compara variables como enteros)
    entero=$?                          				# Retorna si la sentencia anterior fue verdadera
    return $entero
}

es_enteropositivo() {
	[ "$1" -eq "$1" -a "$1" -ge "0" ] > /dev/null 2>&1  # En caso de error, sentencia falsa (Compara variables como enteros)
    entero=$?                          				# Retorna si la sentencia anterior fue verdadera
    if [ "$1" -eq "0" ]
    then
		entero=$(expr $entero + 1)
    fi
    return "$entero"
}

#función que comprueba que los nombres introducidos para los procesos no sean iguales
CompruebaNombre() {
	correcto=0;
	for(( z=1 ; z <= ${#proceso[@]} ; z++ )){
		contador=0;
		valor=${proceso[$z]};
		for(( j=1 ; j<= ${#proceso[@]} ; j++ )){
			valor2=${proceso[$j]};
			if [ "$valor" == "$valor2" ] #si los valores del vector coinciden
			then
					contador=`expr $contador + 1`;
			fi
			if [ "$contador" -gt 1 ] #si el contador es mayor que uno
			then
				correcto=1; #Valor de la variable a 1 para un valor mal introducido
			else
				correcto=0; #Valor de la variable a 0 para un valor introducido
			fi
		}
	}
	if [ $correcto -eq 1 ]
	then
		echo "Nombre repetido"
	fi
	return $correcto
}

#Comprueba introducción automatica
compruebaRep() {
	rep=0
	for((z=1;z<= ${#proceso[@]}; z++)){
		if [ "$1" == "${proceso[$z]}" ]
		then
			rep=1
		fi
	}
	return $rep
}

#variables
p=1;              #contador
pp=2;
i=0;
t=-1
anterior=-1
suma_espera=0;
suma_respuesta=0;
espera=0;
respuesta=0;
suma_ejecucion=0;
tamano=0;
npart=0;
outer=1;
parts=0;
npro=0;
evento=0	#Sirve para saber si quiere informe por evento o por tiempo
proAct=0;	#Proceso actual
rojo="\033[0;31m";
verde="\033[0;32m";
naranja="\033[0;33m";
azul="\033[1;34m";
violeta="\033[1;35m";
cian="\033[0;95m";
amarillo="\033[1;90m";
blanco="\033[0m";
salioAnt="";

#vectores
color=();
proceso=();
llegada=();
tiempo=();
espera=();
tEspera=();
tamanoMemoria=();
procesosmem=();   		#vector que contiene los procesos dentro de la memoria.
particiones=();			#vector que contiene el tamaño de las particiones.
huecos=();				#vector que guarda los procesos segun su tamaño .
partocup=();			#vector booleano que dice si esta la particion ocupado a no
ejecutar=();			#teniendo en cuanta como el algoritmo ha ordenado los procesos se van guardando en cada posicion del vector el numero de la particion donde se han guardado.
estado=();
memm=();
borrar=0
pasar=0
qw=2

color[0]=$naranja
color[1]=$verde
color[2]=$rojo
color[3]=$azul
color[4]=$violeta
color[5]=$cian
color[6]=$amarillo

echo "" > terminal.txt
echo "" >> informeSJF.txt
echo "" > sjf.tmp

fuera="s"
while [ $fuera == "s" ] #mientras que contador sea menor que cantidad de procesos
do
	echo "" > sjf.tmp
	echo "Empieza la introducción de datos"
	if [ $p = 1 ]
	then

		echo "¿Desea introducir los datos de forma manual?(s/n):"
       		read "op"
		until [ "$op" == "n" -o "$op" == "s" ] #Validación de datos s o n
			do
				echo "Respuesta introducida no válida"
				echo "Introduce una respuesta que sea s/n"
				read "op"
			done
	fi


	if [ "$op" = "n" ] #Introducción de datos automática
	then
		if [ -e datosEntrada.txt ]
		then
			menos=0
			echo "Introduciendo el tamaño de las particiones..."
			npart=`sed -n 1p datosEntrada.txt | tr ',' ' ' | wc -w`
			x=0
			echo "hay $npart particiones antes de introducirlas"
			for ((i=0;i<$npart;i++)){
				q=$(expr $i + 1)
				part=$(sed -n 1p datosEntrada.txt | cut -d "," -f $q)
				if ! es_entero $part
				then
					echo "No se ha podido introducir la partición número $i"
					particiones[$i]=-1
					menos=`expr $menos + 1`
				else
					particiones[$i]=$part
					x=$(expr $x + 1)
				fi
			}
			pasar=1
			npart=$x
	    	echo "El numero de particiones es $x" >> ejemplo.txt
	    	echo "El numero de particiones es $x"
	    	max=0
			for ((i=0;i<$npart;i++)){	#convierte $max en el tamaño de la partición más grande
				if [ "${particiones[$i]}" -ge $max ]
				then
					max=${particiones[$i]}
				fi
			}
			echo "La partición más grande es de $max"
			echo "Introduciendo los procesos..."
			menos=0
			nomPro=" "
			npro=$(cat datosEntrada.txt | tr '\n' ' ' | wc -w)
			npro=$(( $npro-2 ))
			x=1
			echo "Numero de procesos de datosEntrada.txt: $npro"
			for((i=3;i<=`expr $npro + 2`;i++)){	#Introducción de valores desde datosEntrada.txt a sus correspondientes variables
				process=$(( $i-2 ))				
				if [ $process -lt 10 ]; then
    				nomPro="P0$process"
				else 
				nomPro="P$process"
				fi
				if es_entero `cat datosEntrada.txt | tr '\n' ' ' | cut -d ' ' -f $i | cut -d ',' -f 1` && es_enteropositivo `cat datosEntrada.txt | tr '\n' ' ' | cut -d ' ' -f $i | cut -d ',' -f 2` && es_enteropositivo `cat datosEntrada.txt | tr '\n' ' ' | cut -d ' ' -f $i | cut -d ',' -f 3` && [ `cat datosEntrada.txt | tr '\n' ' ' | cut -d ' ' -f $i | cut -d ',' -f 3` -le $max ]
				then
					proceso[$x]="$nomPro"
					llegada[$x]=$(cat datosEntrada.txt | tr '\n' ' ' | cut -d ' ' -f $i | cut -d ',' -f 1)
					tiempo[$x]=$(cat datosEntrada.txt | tr '\n' ' ' | cut -d ' ' -f $i | cut -d ',' -f 2)
					tamanoMemoria[$x]=$(cat datosEntrada.txt | tr '\n' ' ' | cut -d ' ' -f $i | cut -d ',' -f 3)
					estado[$x]=0
					x=`expr $x + 1`
				else
					echo -e "\033[0;31mEl proceso $nomPro no ha podido ser introducido\033[0m"
					menos=`expr $menos + 1`
				fi
			}
			npro=`expr $npro - $menos`
			echo -e "\033[0;32mSe han introducido $npro procesos\033[0m"
			


		
	
			
		
		else
			echo "No se encuentra el archivo 'datosEntrada.txt'"
		fi
		
		
		
		echo "Fin de introducción de datos..."
		break

	else	#introdución de datos manual

		if [ $pasar -eq 0 ]
			then
				while [ $outer -eq 1 ]
					do
							echo "Introduce el tamaño de la partición $parts."
			 				read capacidad
							while ! es_enteropositivo $capacidad
								do
									read -p "Entrada no válida. Introduce un tamaño de particion entero:" capacidad
								done
								particiones[$parts]=$capacidad;
								npart=`expr $npart + 1`
								parts=`expr $parts + 1`
								echo "¿Quieres introducir otra partición? (s/n)"
								read "sn"
								if [ $sn = "n" ]; then
								outer=0

								fi
		     		done

			max=0

			for ((i=0;i<$npart;i++)){	#convierte $max en el tamaño de la partición más grande
				if [ ${particiones[$i]} -ge $max ]
				then
					max=${particiones[$i]}
				fi
			}

			for ((i=0;i<$npart;++i)){ #Escribe en el informe el tamaño de las particiones
				echo "La particion $i tiene de tamaño: ${particiones[$i]}" >> informeSJF.txt
				#echo "La particion $i tiene de tamaño: ${particiones[$i]}" >> ejemplo.txt
			}
			pasar=1
		fi



		echo "Introducción de datos de procesos"
		if [[ ${#p} -lt 2 ]] ; then
    p="0${p}"
		fi


		proceso[10#$p]="P$p"
	  echo "Introducción de datos de procesos"
		echo -n "	Nombre: P$p"  >> sjf.tmp
		clear
		cat terminal.txt
		cat sjf.tmp
		echo ""
		echo ""
		echo "Tiempo De llegada de P$p:"
		read llegad
		while ! es_entero $llegad;
		do
			echo "No se pueden introducir tiempos de llegada negativos ni decimales"
			echo "Introduce un nuevo tiempo de llegada"
			read llegad
		done

		
		llegada[10#$p]=$llegad;   #añado al vector el tiempo de llegada

		echo -n "	Llegada: $llegad"  >> sjf.tmp
		clear
		cat terminal.txt
		cat sjf.tmp

		echo ""
		echo ""
		echo "Tiempo De Ejecución de P$p"
		read tiemp
		while ! es_enteropositivo $tiemp;
		do
			echo "No se pueden introducir tiempos de ejecución negativos"
			echo "Introduce un nuevo tiempo de ejecución"
			read tiemp
		done

		tiempo[10#$p]=$tiemp;   #añado al vector el tiempo de ejecución

		echo -n "	Tiempo de ejec.: $tiemp"  >> sjf.tmp
		clear
		cat terminal.txt
		cat sjf.tmp

		echo ""
		echo ""
		echo "Tamaño del proceso_P$p:"
		read tamano
		until es_enteropositivo $tamano && [ $tamano -le $max ];
		do
			if [ $tamano -le 0 ]
			then
				echo "No se pueden introducir tamaños negativos"
			fi
			if [ $tamano -ge $max ]
			then
				echo "El proceso no cabe en la particion."
			fi
			echo "Introduce un nuevo tamaño de proceso."
			read tamano
		done
	
		
		tamanoMemoria[10#$p]=$tamano;   #añado al vector el tamaño del proceso

		estado[10#$p]=0

		echo -n "	Tamaño: $tamano"  >> sjf.tmp
		clear
		cat terminal.txt
		cat sjf.tmp

	fi
	p=`expr $p + 1` #incremento el contador
	pp=`expr $pp + 1` #incremento el contador

	echo "" >> informeSJF.txt
	echo "" >>ejemplo.txt

	tam=${#llegada[@]}

	ant=0

			for ((i=1;i<=${#tiempo[@]};i++)){	#Calcula el promedio de tiempo de espera y respuesta

				if [ $i -eq 1 ]    #si la posición 0 = 0
					then
				        espera=0;                 #valores de inicio
				        respuesta=${tiempo[$i]};
						ultimaEspera=0;
						suma_ejecucion=`expr ${llegada[$i]} + ${tiempo[$i]}`
					else
						ant=`expr $i - 1`
						restaTiempo=`expr ${llegada[$i]} - ${llegada[$ant]}`
						restaEjecucion=`expr ${tiempo[$ant]} - $restaTiempo`
						if [ $suma_ejecucion -gt ${llegada[$i]} ]			#si la suma contiene la llegada
							then
								espera=`expr $restaEjecucion + $ultimaEspera`                     #voy sumando tiempos de espera
								suma_ejecucion=`expr ${tiempo[$i]} + $suma_ejecucion`	#Voy sumando las ejecuciones para saber en que instante estoy
							else
								espera=0
								suma_ejecucion=`expr ${llegada[$i]} + ${tiempo[$i]}`	#Voy sumando las ejecuciones para saber en que instante estoy
						fi

								respuesta=`expr $espera + ${tiempo[$i]}` 		 #voy sumando los tiempos de respuesta

								suma_espera=`expr $suma_espera + $espera`            #suma para sacar su promedio
								promedio_espera=`expr $suma_espera / ${#tiempo[@]}`  #promedio

								suma_respuesta=`expr $suma_respuesta + $respuesta`   #suma para sacar su promedio
								promedio_respuesta=`expr $suma_respuesta / ${#tiempo[@]}`  #promedio
								ultimaEspera=$espera					#espera del proceso anterior
			       	fi
			 if [ $i -eq 1 ]
			 then

				 echo -e "\t  ${naranja}P  ${naranja}TLL ${naranja}TEJ ${naranja}TAM ${naranja}Estado" >> ejemplo.txt

			 fi
			echo -en "\t ${color[(i % 7)]}${proceso[$i]} " >> ejemplo.txt
			if [ ${llegada[$i]} -lt 10 ]; then
				echo -en " ${color[(i % 7)]}${llegada[$i]}  " >> ejemplo.txt
			else    echo -en " ${color[(i % 7)]}${llegada[$i]} " >> ejemplo.txt
			fi
			if [ ${tiempo[$i]} -lt 10 ]; then
				echo -en " ${color[(i % 7)]}${tiempo[$i]}  " >> ejemplo.txt
			else    echo -en " ${color[(i % 7)]}${tiempo[$i]} " >> ejemplo.txt
			fi
			if [ ${tamanoMemoria[$i]} -lt 10 ]; then
				echo -en " ${color[(i % 7)]}${tamanoMemoria[$i]}  " >> ejemplo.txt
			else    echo -en " ${color[(i % 7)]}${tamanoMemoria[$i]} " >> ejemplo.txt
			fi
     
			if [ ${estado[$i]} -eq 0 ]
			then
				if [ $t -ge ${llegada[$i]} ]
				then
					echo -ne "${color[(i % 7)]}En espera" >> ejemplo.txt
				else
					echo -ne "${color[(i % 7)]}Fuera del sistema" >> ejemplo.txt
				fi
			elif [ ${estado[$i]} -eq 1 ]
			then
				echo -ne "${color[(i % 7)]}En memoria" >> ejemplo.txt
			elif [ ${estado[$i]} -eq 2 ]
			then
				echo -ne "${color[(i % 7)]}En ejecución" >> ejemplo.txt
			else
				echo -ne "${color[(i % 7)]}Terminado" >> ejemplo.txt
			fi
			echo -e "\t\t" >> ejemplo.txt

			}

		#promedios
		echo "" >> ejemplo.txt
		echo "" >> informeSJF.txt
		echo -e "\e[0;31m * T.espera medio: $promedio_espera  -  * T.retorno medio: $promedio_respuesta \e[0m" >> ejemplo.txt
		echo "" >> ejemplo.txt
		cat ejemplo.txt
		echo "" > terminal.txt
		cp ejemplo.txt terminal.txt
		echo "" > ejemplo.txt

		echo "¿Quieres introducir mas procesos? [s/n]:"
		read fuera
		until [ "$fuera" = "s" -o "$fuera" = "n" ]
		do
			echo "La respuesta introducida no es valida"
			echo "¿Quieres introducir mas procesos? [s/n]:"
			read fuera
		done
		npro=`expr $npro + 1`

done #Cerraos while de introducción de datos
touch datosentrada.txt
for((i=0; i<$npart; i++)){
	echo -ne "${particiones[$i]}," >> datosentrada.txt
}
echo -e "\nTiempo_de_llegada,tiempo_de_ejecucion,tamaño_en_memoria" >> datosentrada.txt
for((i=1; i<=$npro; i++)){
	echo -e "${llegada[$i]},${tiempo[$i]},${tamanoMemoria[$i]}" >> datosentrada.txt
}
cat datosentrada.txt > datosEntrada.txt
rm datosentrada.txt


#Ordena el vector dependiendo del tiempo de llegada, de menos a mas
for i in $(seq 1 $(($npro-1))); do
	for j in $(seq 1 $(($npro-$i))); do
		if [ ${llegada[$j]} -gt ${llegada[$j+1]} ] ; then
			k=${llegada[$[$j+1]]}
			llegada[$j+1]=${llegada[$j]}
			llegada[$j]=$k
			q=${proceso[$[$j+1]]}
			proceso[$j+1]=${proceso[$j]}
			proceso[$j]=$q
			x=${tiempo[$[$j+1]]}
			tiempo[$j+1]=${tiempo[$j]}
			tiempo[$j]=$x
			z=${tamanoMemoria[$[$j+1]]}
			tamanoMemoria[$j+1]=${tamanoMemoria[$j]}
			tamanoMemoria[$j]=$z
		fi
	done
done

echo -e "\t${naranja}INSTANTE INICIAL; T=0"			
			echo -e "\t  ${naranja}P  ${naranja}TLL ${naranja}TEJ ${naranja}TAM ${naranja}Estado" 
			for((i=1; i<=npro; i++)){
				echo -en "\t ${color[(i % 7)]}${proceso[$i]} " 
		if [ ${llegada[$i]} -lt 10 ]; then 		
		echo -ne " ${color[(i % 7)]}${llegada[$i]}  " 
		else
		echo -ne " ${color[(i % 7)]}${llegada[$i]} " 
		fi
		if [ ${tiempo[$i]} -lt 10 ]; then 		
		echo -ne " ${color[(i % 7)]}${tiempo[$i]}  " 
		else
		echo -ne " ${color[(i % 7)]}${tiempo[$i]} " 
		fi 
		if [ ${tamanoMemoria[$i]} -lt 10 ]; then 		
		echo -ne " ${color[(i % 7)]}${tamanoMemoria[$i]}  " 
		else
		echo -ne " ${color[(i % 7)]}${tamanoMemoria[$i]} " 
		fi   
		echo -en "${color[(i % 7)]}Fuera del sistema"
				
			
			
			echo -e "\t\t" 

			}
echo "¿Quiere un informe por tiempos o por eventos? (t/e)"
read modo
while [ "$modo" != "t" ] && [ "$modo" != "e" ]
do
	echo "Modo no válido. Vuelva a teclearlo: (t/e)"
	read modo
done

if [ $modo = 'e' ]
then
	evento=1
else
	evento=0
fi

echo "Pulse enter para empezar informe..."
read continuar

#Creamos array con nombres de colores, array de memorias e iniciamos nuevos documentos
tamanew=();
for((i=1;i<=$npro;i++)){
	espacios=`expr 8 - ${#proceso[$i]}`
	proceso[i]=${color[($i % 7)]}${proceso[i]}$blanco
	echo -ne "${proceso[$i]}" > "${proceso[$i]}.tmp"
	for((x=1;x<$espacios;x++)){
		echo -ne " " >> "${proceso[$i]}.tmp"
	}
	echo -ne " " >> "${proceso[$i]}.tmp"
	tamanew[$i]=${tamanoMemoria[$i]}
	tEspera[$i]=0
	tRetorno[$i]=0
	tRestante[$i]=${tiempo[$i]}
	
}

#Se crean el principio de la gráfica de procesos
echo  -e "\n	${naranja}Gráfica${blanco}" > cabecera.tmp
echo -ne "TIEMPO" >> cabecera.tmp
for ((i=0;i<$npart;i++)){
	partocup[$i]=0
}
#Creamos los archivos temporales de la tabla de particiones y la lineal
echo -ne "        " > nombreP.tmp



echo -ne "" > nombreP2.tmp
echo -ne "	┌———————" > primeraP2.tmp
echo -ne "	└———————" > ultimaP2.tmp
echo -ne "       " > nombreL.tmp
echo -ne "        " > primeraL.tmp
echo -ne "        " > ultimaL.tmp
echo -ne "       ${blanco}0" > tiempoL.tmp
echo -ne "TIEMPO " > lineal.tmp
o=0
for((i=0;i<$npart;i++)){
	
	exd=`expr $npart - 1`
	if [ $exd -ne $i ]
	then
		echo -ne " " >> nombreP2.tmp
		echo -ne "┬———————" >> primeraP2.tmp
		echo -ne "┴———————" >> ultimaP2.tmp
		
	fi
}

echo -ne "┘" >> ultimaP2.tmp
echo -ne "┐" >> primeraP2.tmp

final=$npro
h=0
z=0
x=0
xx=1
t=0
cpus=0
cpu=0
fuera=0
nproo=`expr $npro + 1`
centinela=0
ocupadas=();
imprimir=();
echo -n "" > informe.txt

for((i=1;i<=$npro;i++)){
	tamanoAnterior[$i]=${tamanoMemoria[$i]}
	guion[$i]=1
	
}

for ((t=0;t<=1000;++t)){
	echo -e "\e[1;34mEstamos en el instante $t.\e[0m" > ejemplo.txt

	for ((j=1;j<$nproo;++j)){
		centinela=0
		for ((k=0;k<$npart;++k)){
			if [ "${llegada[$j]}" -le $t ]  #hay que hacerlo para que se recorran todas las particiones.
			then			#tiene que haber llegado el proceso, que quepa en una particion y que este libre.
				if [ ${tamanoMemoria[$j]} -le ${particiones[$k]} ]
				then
					if [ ${partocup[$k]} -eq 0 ]
					then
						if [ $centinela -eq 0 ]
						then
							hueco[$k]=${tiempo[$j]}
							imprimir[$k]=${tamanoMemoria[$j]}
							tamanoMemoria[$j]=1000
							ocupadas[$k]=${proceso[$j]}
							aux[$k]=$k
							estado[$j]=1
							echo -e "\e[1;32mEl proceso ${proceso[$j]}\e[1;32m se ha metido en la particion_$k y su tiempo de ejecucion es ${tiempo[$j]}.\e[0m" >> ejemplo.txt
							hayEvento=1
							ejecutar[$z]=$k
							z=`expr $z + 1`
							partocup[$k]=$j
							centinela=1
						fi
					fi
				fi
			fi
		}
		if [ ${tamanoAnterior[$j]} -eq ${tamanoMemoria[$j]} ]
		then
			if [ ${tamanoMemoria[$j]} -ne 1000 ]
			then
				j=100
			fi
		fi

		if [ $h -eq $npart ]	#procesos que entran a memoria
		then
			break
		fi
	}

	#Creamos tabla de particiones
	echo -e "\t\t" > graficaP.tmp
	cat nombreP.tmp >> graficaP.tmp
	echo -e "" >> graficaP.tmp
	echo -n "" > porcentajeP.tmp
	echo -ne "MEMORIA " > procesoP.tmp
	echo -ne "        0" > ultimaP1.tmp
	for((i=0;i<$npart;i++)){
			j=`expr $i - 1`		
			if [ $i -eq 0 ]; then
				tamfin[$i]=${particiones[$i]}
			else 
				tamfin[$i]=`expr ${tamfin[`expr $i-1`]} + ${particiones[$i]}`
			fi
		
		if [ ${partocup[$i]} -eq 0 ]
		then	
			
			for((o=0;o<${particiones[$i]};o++)){
				echo -n "▇▇▇" >> procesoP.tmp
			}
			
			if [ $i -eq 0 ]; then
				for((o=0;o<`expr ${particiones[$i]}*3-2`;o++)){
					echo -n " " >> ultimaP1.tmp
				}
				echo -ne "${tamfin[$i]}" >> ultimaP1.tmp
			else
				if [ ${particiones[$j]} -lt 10 ]; then
					for((o=0;o<`expr ${particiones[$i]}*3-1`;o++)){
						echo -n " " >> ultimaP1.tmp
					}
					echo -ne "${tamfin[$i]}" >> ultimaP1.tmp
				else
					for((o=0;o<`expr ${particiones[$i]}*3-2`;o++)){
						echo -n " " >> ultimaP1.tmp
					}
					echo -ne "${tamfin[$i]}" >> ultimaP1.tmp
				fi
			fi
		else
						
				
			echo -ne "${color[(${partocup[$i]} % 7)]}" >> procesoP.tmp
			for((o=0;o<${tamanew[${partocup[$i]}]};o++)){
				echo -ne "▇▇▇" >> procesoP.tmp	
			}
			
			
			
						
			bucle=`expr ${particiones[$i]} - ${tamanew[${partocup[$i]}]}`
			
			if [ $i -eq 0 ]; then
				memm=${tamanew[${partocup[$i]}]}	
			elif [ $i -eq 1 ]; then
				resto=`expr ${particiones[0]} - ${tamanew[${partocup[0]}]}`			
				memm=`expr $memm  + $resto + ${tamanew[${partocup[$i]}]}`
			else
				resto=`expr ${particiones[$j]} - ${tamanew[${partocup[$j]}]}`
				memm=`expr $memm  + $resto + ${tamanew[${partocup[$i]}]}`	
			fi
			if [ $i -eq 0 ]; then
				tamfin[$i]=${particiones[$i]}
			else
				tamfin[$i]=`expr ${tamfin[$j]} + ${particiones[$i]}`
			fi

			echo -ne "$blanco" >> procesoP.tmp
			for((o=0;o<$bucle;o++)){
				echo -ne "▇▇▇" >> procesoP.tmp	
			}
			
			
			if [ $i -eq 0 ]; then
				for((o=0;o<`expr ${tamanew[${partocup[$i]}]}*3-1`;o++)){
					echo -ne " " >> ultimaP1.tmp
				}
				echo -ne "$memm" >> ultimaP1.tmp
				if [ $memm -lt 10 ]; then				
				for((o=0;o<`expr $bucle*3-1`;o++)){
					echo -ne " " >> ultimaP1.tmp
				}
				echo -ne "${tamfin[$i]}" >> ultimaP1.tmp
				else
				for((o=0;o<`expr $bucle*3-2`;o++)){
					echo -ne " " >> ultimaP1.tmp
				}
				echo -ne "${tamfin[$i]}" >> ultimaP1.tmp
				fi
			else
				if [ ${tamfin[$j]} -lt 10 ]; then
					for((o=0;o<`expr ${tamanew[${partocup[$i]}]}*3-1`;o++)){
					echo -ne " " >> ultimaP1.tmp
					}
					echo -ne "$memm" >> ultimaP1.tmp
					if [ $memm -lt 10 ]; then
						for((o=0;o<`expr $bucle*3-1`;o++)){
						echo -ne " " >> ultimaP1.tmp
						}
						echo -ne "${tamfin[$i]}" >> ultimaP1.tmp
					else 
						for((o=0;o<`expr $bucle*3-2`;o++)){
						echo -ne " " >> ultimaP1.tmp
						}
						echo -ne "${tamfin[$i]}" >> ultimaP1.tmp
					fi
				else 
					for((o=0;o<`expr ${tamanew[${partocup[$i]}]}*3-2`;o++)){
					echo -ne " " >> ultimaP1.tmp
					}
					echo -ne "$memm" >> ultimaP1.tmp
					if [ $memm -lt 10 ]; then
						for((o=0;o<`expr $bucle*3-1`;o++)){
						echo -ne " " >> ultimaP1.tmp
						}
						echo -ne "${tamfin[$i]}" >> ultimaP1.tmp
					else 
						for((o=0;o<`expr $bucle*3-2`;o++)){
						echo -ne " " >> ultimaP1.tmp
						}
						echo -ne "${tamfin[$i]}" >> ultimaP1.tmp
					fi
				fi	
			fi		
			
			
		fi
		echo -n "" >> procesoP.tmp
	}
	cat procesoP.tmp >> graficaP.tmp
	echo -e "" >> graficaP.tmp
	cat ultimaP1.tmp >>graficaP.tmp
	


	cat nombreP2.tmp >> graficaP.tmp
	echo -e "" >> graficaP.tmp
	cat primeraP2.tmp >> graficaP.tmp
	echo -e "" >> graficaP.tmp
	echo -n "" > porcentajeP.tmp
	for((i=0;i<$npart;i++)){
		echo -ne "\t|${proceso[${partocup[$i]}]}" >> graficaP.tmp
		echo -ne "\t|${color[(${partocup[$i]} % 7)]} ${tamanew[${partocup[$i]}]}$blanco/${particiones[$i]}" >> porcentajeP.tmp
	}
	echo "	|" >> porcentajeP.tmp
	echo "	|" >> graficaP.tmp
	cat porcentajeP.tmp >> graficaP.tmp
	cat ultimaP2.tmp >> graficaP.tmp


	out=1
	w=0
	time=99
	cambiar=0

	while [ $out = 1 ]	#Se introduce en la cpu el proceso con menos tiempo de ejecución que hay en memoria
	do
		if [ "${partocup[$w]}" -ne 0 ]
		then
			if [ ${tiempo[${partocup[$w]}]} -le $time ]
			then
				if [ $cpus -eq 0 ]
				then
					if [ ${tiempo[${partocup[$w]}]} -eq $time ]
					then
						if [ $proAct -gt ${partocup[$w]} ]
						then
							proAct=${partocup[$w]}
							cambiar=1
							time=${tiempo[${partocup[$w]}]}
						fi
					else
						proAct=${partocup[$w]}
						cambiar=1
						time=${tiempo[${partocup[$w]}]}
					fi
				fi
			fi
		fi

		w=`expr $w + 1`

		if [ $w -eq $npart -o $cpus -eq 1 ]
		then
			out=0
		fi
	done

	#Creando gráfica lineal
	if [ $anterior -ne $proAct ]
	then
		if [ $proAct -eq 0 ]
		then
			
			echo -n "▇▇▇" >> lineal.tmp
			echo -ne "   " >> nombreL.tmp
			echo -ne "  " >> tiempoL.tmp
		else
			if [ $t -lt 10 ]; then			
			let tt=`expr 3*${tiempo[${proAct}]}-3`
			let ttt=`expr 3*${tiempo[${proAct}]}-1`
			else
			let tt=`expr 3*${tiempo[${proAct}]}-3`
			let ttt=`expr 3*${tiempo[${proAct}]}-2`
			fi
			
			echo -ne "${color[($proAct % 7)]}${proceso[$proAct]}$blanco" >> nombreL.tmp
			for((o=0;o<$tt;o++)){
				echo -ne " " >> nombreL.tmp
			}	
			echo -ne "${blanco}$t" >> tiempoL.tmp			
			for((o=0;o<${tiempo[${proAct}]};o++)){
				echo -ne "${color[($proAct % 7)]}▇▇▇" >> lineal.tmp
			}
			for((o=0;o<$ttt;o++)){
				echo -ne " " >> tiempoL.tmp
			}
			
			
	fi
		
		
			
		
		
	fi
	anterior=$proAct
	#Introducción de proceso que estaba en memoria a la cpu
	if [ $cambiar -eq 1 ]
	then
		cpu=${tiempo[$proAct]}
		cpus=1
		out=0
		hayEvento=1
		estado[$proAct]=2
		echo -e "\e[1;33mEl proceso ${proceso[$proAct]}\e[1;33m ha entrado en CPU.\e[0m" >> ejemplo.txt
	fi

	#Si el procesador está ocupado mostrar cuanto tiempo le queda al proceso en cuestión
	if [ $cpus -eq 1 ]
	then
		cpu=`expr $cpu - 1`
		echo "El procesador esta ocupado" >> ejemplo.txt
		echo -e "\e[1;31mAl proceso ${proceso[$proAct]}\e[1;31m le quedan $cpu tiempos de ejecucion.\e[0m" >> ejemplo.txt  #si la cpu esta ocupada estara trabajando y reduciendo el tiempo de ejecucion 1 por cada paso de bucle
		#Dibujamos la gráfica
		for ((i=1;i<=$npro;i++)){
			if [ $i -eq $proAct ]
			then
				echo -ne "${color[($i % 7)]}▇▇▇$blanco" >> "${proceso[$i]}.tmp"
			else
				echo -ne " " >> "${proceso[$i]}.tmp"
			fi
		}
	else
		for ((i=1;i<=$npro;i++)){
			echo -ne " " >> "${proceso[$i]}.tmp"
		}
	fi

	proAnt=$proAct
	#Si el tiempo de ejecución restante es 0, sacar el proceso de la memoria y de la cpu
	if [ $cpu -eq 0 ]
	then
		if [ $cpus -eq 1 ]
		then
			hayEventoSig=2
			salioAnt="\e[1;35mEl proceso ${proceso[$proAct]}\e[1;35m ha salido de la CPU y de la memoria.\e[0m"
			cpus=0
			estado[$proAct]=3
			for (( i=0; i<$npart; i++)){
				if [ ${partocup[$i]} -eq $proAct ]
				then
					partocup[$i]=0
				fi
			}
			proAct=0
		fi
	fi


	#Crea la tabla de procesos
	echo "" >> ejemplo.txt
	echo -e "\t Tabla de procesos" >> ejemplo.txt
	echo -e "\t${naranja}REF ${naranja}TLL ${naranja}TEJ ${naranja}MEM ${naranja}TESP ${naranja}TRET ${naranja}TREJ ${naranja}Estado" >> ejemplo.txt
	
	ejec=0
	ress=0	
	for ((i=1;i<=$npro;i++)){
		echo -ne "\t${color[(i % 7)]}${proceso[$i]}"  >> ejemplo.txt
		if [ ${llegada[$i]} -lt 10 ]; then 		
		echo -ne " ${color[(i % 7)]}${llegada[$i]}  " >> ejemplo.txt
		else
		echo -ne " ${color[(i % 7)]}${llegada[$i]} " >> ejemplo.txt
		fi
		if [ ${tiempo[$i]} -lt 10 ]; then 		
		echo -ne " ${color[(i % 7)]}${tiempo[$i]}  " >> ejemplo.txt
		else
		echo -ne " ${color[(i % 7)]}${tiempo[$i]} " >> ejemplo.txt
		fi 
		if [ ${tamanew[$i]} -lt 10 ]; then 		
		echo -ne " ${color[(i % 7)]}${tamanew[$i]}  " >> ejemplo.txt
		else
		echo -ne " ${color[(i % 7)]}${tamanew[$i]} " >> ejemplo.txt
		fi   
     		
		if [ ${estado[$i]} -eq 0 ]; then
			guion[$i]=1
		else guion[$i]=0
		fi
		
			
		tRet=${tRetorno[$i]}
		tEsp=${tEspera[$i]}
		tRes=${tRestante[$i]}
		if [ ${guion[$i]} -eq 1 ]
		then
			echo -ne "  -  " >> ejemplo.txt
			echo -ne "  -  " >> ejemplo.txt
			echo -ne "  -  " >> ejemplo.txt
			
		else
			if [ $tRet -lt 10 ]; then
				echo -ne "  ${color[(i % 7)]}$tEsp  " >> ejemplo.txt
			else 	
				echo -ne "  ${color[(i % 7)]}$tEsp " >> ejemplo.txt
			fi
			if [ $tEsp -lt 10 ]; then
				echo -ne "  ${color[(i % 7)]}$tRet  " >> ejemplo.txt
			else 	
				echo -ne "  ${color[(i % 7)]}$tRet " >> ejemplo.txt
			fi
			if [ $tRes -lt 10 ]; then
				echo -ne "  ${color[(i % 7)]}$tRes  " >> ejemplo.txt
			else 	
				echo -ne "  ${color[(i % 7)]}$tRes " >> ejemplo.txt
			fi
	
		fi
		
		if [ ${estado[$i]} -eq 0 ]
		then
			if [ $t -ge ${llegada[$i]} ]
			then
				echo -ne " ${color[(i % 7)]}En espera" >> ejemplo.txt
				tRetorno[$i]=`expr ${tRetorno[$i]} + 1`
				guion[$i]=1
				
				
			else
				echo -ne " ${color[(i % 7)]}Fuera del sistema" >> ejemplo.txt
				guion[$i]=1
				
				
			fi
		elif [ ${estado[$i]} -eq 1 ]
		then
			guion[$i]=0			
			echo -ne " ${color[(i % 7)]}En memoria" >> ejemplo.txt
			tRetorno[$i]=`expr ${tRetorno[$i]} + 1`
			
			ress[$i]=0
			
		elif [ ${estado[$i]} -eq 2 ]
		then
			guion[$i]=0
			echo -ne " ${color[(i % 7)]}En ejecución" >> ejemplo.txt
			ejec=1
			ress[$i]=0
			tRestante[$i]=`expr ${tRestante[$i]} - 1`			
			tRetorno[$i]=`expr ${tRetorno[$i]} + 1`
			
		else
			if [ $i -eq $proAnt ]
			then
				echo -ne " ${color[(i % 7)]}En ejecución " >> ejemplo.txt
				ejec=1
				ress[$i]=0
				tRetorno[$i]=`expr ${tRetorno[$i]} + 1`
				tRestante[$i]=`expr ${tRestante[$i]} - 1`
				guion[$i]=0
			else
				if [ ${tRestante[$i]} -ne 0 ]; then
					tRestante[$i]=`expr ${tRestante[$i]} - 1`
				fi				
				echo -ne " ${color[(i % 7)]}Terminado" >> ejemplo.txt
				tRestante="/"
				
				
				
			fi
		fi
		if [ "${estado[$i]}" -lt "2" ]
		then
			if [ "${estado[$i]}" -eq "1" ]
			then
				tEspera[$i]=`expr ${tEspera[$i]} + 1`
				guion[$i]=0
			else
				if [ ${llegada[$i]} -le $t ]
				then
					tEspera[$i]=`expr ${tEspera[$i]} + 1`
					guion[$i]=0
				fi
			fi
		fi
		
		echo -e "\t\t" >> ejemplo.txt
		
		
		ejec=0
	mediaEspera=$(expr $mediaEspera + ${tEspera[$i]})
	
	mediaRetorno=$(expr $mediaRetorno + ${tRetorno[$i]})
	

	}
	mediaEspera=$(expr $mediaEspera/1)	
	promedioMediaEspera=$(echo "scale=2; $mediaEspera / $npro"| bc)
	mediaRetorno=$(expr $mediaRetorno/1)	
	promedioMediaRetorno=$(echo "scale=2; $mediaRetorno / $npro"| bc)	
	
		
	echo -en  "\tMedia de espera: ${blanco}$promedioMediaEspera\t  Media de retorno: ${blanco}$promedioMediaRetorno" >> ejemplo.txt

	echo -e "" >> ejemplo.txt
	
	
	echo "	|" >> porcentajeP.tmp
	cat graficaP.tmp >> ejemplo.txt
	echo "" >> ejemplo.txt
	
	cat nombreL.tmp >> ejemplo.txt
	echo "" >> ejemplo.txt
	
	cat lineal.tmp >> ejemplo.txt
	
	echo "" >> ejemplo.txt
	cat tiempoL.tmp >> ejemplo.txt


	echo "" >> ejemplo.txt
	echo "-------------------------------------------------------------------------------------" >> ejemplo.txt
	echo "" >> ejemplo.txt

	if [ $evento -eq 1 ]
	then
		if [ "$hayEvento" -eq 1 ]
		then
			cat ejemplo.txt >> informe.txt
			clear
			cat informe.txt
		fi
	else
		clear
		cat ejemplo.txt >> informe.txt
		cat informe.txt
	fi
	finalYa=0
	if [ $final -eq 0 ]
	then
		finalYa=1
	fi

	final=0
	for ((i=1;i<=$npro;i++)){
		if [ ${estado[$i]} -ne 3 ]
		then
			final=1
		fi
	}

	if [ $finalYa -eq 1 ]				#Si se acaban los procesos por ejectuar se sale del bucle.
	then #Juntamos todos los archivos temporales para hacer la gráfica
		for ((i=1;i<=$npro;i++)){
			echo -e "" >> "${proceso[$i]}.tmp"
		}
		
		
			
		
		echo "" >> cabecera.tmp
		cat cabecera.tmp > grafica.tmp
		
		
		for ((i=1;i<=$npro;i++)){
			cat "${proceso[$i]}.tmp" >> grafica.tmp
		}
		
		#~ cat graficaP.tmp >> grafica.tmp
		#Dibujamos gráfica lineal
		
		echo "|" >> lineal.tmp
		echo "" >> grafica.tmp
		echo -e "	  ${naranja}Gráfica Lineal${blanco} " >> grafica.tmp
		cat nombreL.tmp >> grafica.tmp
		echo "" >> grafica.tmp
		
		cat lineal.tmp >> grafica.tmp
		
		cat tiempoL.tmp >> grafica.tmp
		echo -e "\n" >> grafica.tmp
		cat ejemplo.txt >> informe.txt
		clear
		cat informe.txt
		break
	fi

	if [ $evento -eq 1 ]
	then
		if [ $hayEvento -eq 1 ] || [ $hayEventoSig -eq 1 ]
		then
			echo "Pulse una enter para continuar..."
			read continuar
		fi
	else
		echo "Pulse una enter para continuar..."
		read continuar
	fi

	hayEventoSig=`expr $hayEventoSig - 1`
	hayEvento=0
}


cat grafica.tmp > grafica.txt
rm *.tmp

cat informe.txt | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g" >> informeblanco.txt 
rm terminal.txt
rm ejemplo.txt
rm informeSJF.txt
echo "Fin  del script. Pulsa enter para finalizar..."
read fin
