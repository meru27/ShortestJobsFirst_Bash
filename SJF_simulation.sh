#! /bin/bash
#shell que corre en nuestro script
#funciones
exec 2> /dev/null

initialChecks() {
	if test ! -d output
	then
		mkdir output
	fi

	if test ! -d input
	then 
		mkdir input
		touch input/datosEntrada.txt
		echo '10,15,5' > input/datosEntrada.txt
		echo 'Tiempo_de_llegada,tiempo_de_ejecucion,tamaño_en_memoria' >> input/datosEntrada.txt
		echo '3,3,11' 	>> input/datosEntrada.txt
		echo '4,2,9'	>> input/datosEntrada.txt
		echo '4,3,4'	>> input/datosEntrada.txt
	fi

	if test ! -d temp
	then 
		mkdir temp
	fi

	if test -e output/informe.txt
	then
		cat  output/informe.txt > output/informeanterior.txt;
		rm  output/informe.txt
	fi
	if test -e output/informeblanco.txt
	then
		cat output/informeblanco.txt > output/informeblancoanterior.txt;
		rm output/informeblanco.txt
	fi
	if test -e temp/sjf.temp
	then
		rm temp/sjf.temp;
	fi

	if test -e temp/ejemplo.txt
	then
		rm temp/ejemplo.txt;
	fi
	printf '\e[8;50;150t'
	clear
}

printCC() {
	echo "############################################################"
	echo "#                     Creative Commons                     #"
	echo "#                                                          #"
	echo "#                   BY - Atribución (BY)                   #"
	echo "#                 NC - No uso Comercial (NC)               #"
	echo "#                SA - Compartir Igual (SA)                 #"
	echo "############################################################"
	echo ""
}

printHeader() {
	echo  "#######################################################################"
	echo  "#                                                                     #"
	echo  "#                         INFORME DE PRÁCTICA                         #"
	echo  "#                         GESTIÓN DE PROCESOS                         #"
	echo  "#             -------------------------------------------             #"
	echo  "#                                                                     #"
	echo  "#     Alumnos: Daniel Meruelo Monzón                                  #"
	echo  "#     Sistemas Operativos 2º Semestre                                 #"
	echo  "#     Versión:   Julio 2022                                           #"
	echo  "#     Grado en ingeniería informática (2018-2019)                     #"
	echo  "#                                                                     #"
	echo  "#######################################################################"
	echo ""
	
}

initialChecks
printCC
printCC > temp/informeSJF.txt
printHeader
printHeader >> temp/informeSJF.txt

echo "" > temp/ejemplo.txt


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

echo "" > temp/terminal.txt
echo "" >> temp/informeSJF.txt
echo "" > temp/sjf.tmp

fuera="s"
while [ $fuera == "s" ] #mientras que contador sea menor que cantidad de procesos
do
	echo "" > temp/sjf.tmp
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
		if [ -e input/datosEntrada.txt ]
		then
			menos=0
			echo "Introduciendo el tamaño de las particiones..."
			npart=`sed -n 1p input/datosEntrada.txt | tr ',' ' ' | wc -w`
			x=0
			echo "hay $npart particiones antes de introducirlas"
			for ((i=0;i<$npart;i++)){
				q=$(expr $i + 1)
				part=$(sed -n 1p input/datosEntrada.txt | cut -d "," -f $q)
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
	    	echo "El numero de particiones es $x" >> temp/ejemplo.txt
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
			npro=$(cat input/datosEntrada.txt | tr '\n' ' ' | wc -w)
			npro=$(( $npro-2 ))
			x=1
			echo "Numero de procesos de input/datosEntrada.txt: $npro"
			for((i=3;i<=`expr $npro + 2`;i++)){	#Introducción de valores desde input/datosEntrada.txt a sus correspondientes variables
				process=$(( $i-2 ))				
				if [ $process -lt 10 ]; then
    				nomPro="P0$process"
				else 
				nomPro="P$process"
				fi
				if es_entero `cat input/datosEntrada.txt | tr '\n' ' ' | cut -d ' ' -f $i | cut -d ',' -f 1` && es_enteropositivo `cat input/datosEntrada.txt | tr '\n' ' ' | cut -d ' ' -f $i | cut -d ',' -f 2` && es_enteropositivo `cat input/datosEntrada.txt | tr '\n' ' ' | cut -d ' ' -f $i | cut -d ',' -f 3` && [ `cat input/datosEntrada.txt | tr '\n' ' ' | cut -d ' ' -f $i | cut -d ',' -f 3` -le $max ]
				then
					proceso[$x]="$nomPro"
					llegada[$x]=$(cat input/datosEntrada.txt | tr '\n' ' ' | cut -d ' ' -f $i | cut -d ',' -f 1)
					tiempo[$x]=$(cat input/datosEntrada.txt | tr '\n' ' ' | cut -d ' ' -f $i | cut -d ',' -f 2)
					tamanoMemoria[$x]=$(cat input/datosEntrada.txt | tr '\n' ' ' | cut -d ' ' -f $i | cut -d ',' -f 3)
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
			echo "No se encuentra el archivo 'input/datosEntrada.txt'"
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
				echo "La particion $i tiene de tamaño: ${particiones[$i]}" >> temp/informeSJF.txt
				#echo "La particion $i tiene de tamaño: ${particiones[$i]}" >> temp/ejemplo.txt
			}
			pasar=1
		fi



		echo "Introducción de datos de procesos"
		if [[ ${#p} -lt 2 ]] ; then
    	p="0${p}"
		fi


		proceso[10#$p]="P$p"
	  	echo "Introducción de datos de procesos"
		echo -n "	Nombre: P$p"  >> temp/sjf.tmp
		clear
		cat temp/terminal.txt
		cat temp/sjf.tmp
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

		echo -n "	Llegada: $llegad"  >> temp/sjf.tmp
		clear
		cat temp/terminal.txt
		cat temp/sjf.tmp

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

		echo -n "	Tiempo de ejec.: $tiemp"  >> temp/sjf.tmp
		clear
		cat temp/terminal.txt
		cat temp/sjf.tmp

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

		echo -n "	Tamaño: $tamano"  >> temp/sjf.tmp
		clear
		cat temp/terminal.txt
		cat temp/sjf.tmp

	fi
	p=`expr $p + 1` #incremento el contador
	pp=`expr $pp + 1` #incremento el contador

	echo "" >> temp/informeSJF.txt
	echo "" >> temp/ejemplo.txt

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

				 echo -e "\t  ${naranja}P  ${naranja}TLL ${naranja}TEJ ${naranja}TAM ${naranja}Estado" >> temp/ejemplo.txt

			 fi
			echo -en "\t ${color[(i % 7)]}${proceso[$i]} " >> temp/ejemplo.txt
			if [ ${llegada[$i]} -lt 10 ]; then
				echo -en " ${color[(i % 7)]}${llegada[$i]}  " >> temp/ejemplo.txt
			else    echo -en " ${color[(i % 7)]}${llegada[$i]} " >> temp/ejemplo.txt
			fi
			if [ ${tiempo[$i]} -lt 10 ]; then
				echo -en " ${color[(i % 7)]}${tiempo[$i]}  " >> temp/ejemplo.txt
			else    echo -en " ${color[(i % 7)]}${tiempo[$i]} " >> temp/ejemplo.txt
			fi
			if [ ${tamanoMemoria[$i]} -lt 10 ]; then
				echo -en " ${color[(i % 7)]}${tamanoMemoria[$i]}  " >> temp/ejemplo.txt
			else    echo -en " ${color[(i % 7)]}${tamanoMemoria[$i]} " >> temp/ejemplo.txt
			fi
     
			if [ ${estado[$i]} -eq 0 ]
			then
				if [ $t -ge ${llegada[$i]} ]
				then
					echo -ne "${color[(i % 7)]}En espera" >> temp/ejemplo.txt
				else
					echo -ne "${color[(i % 7)]}Fuera del sistema" >> temp/ejemplo.txt
				fi
			elif [ ${estado[$i]} -eq 1 ]
			then
				echo -ne "${color[(i % 7)]}En memoria" >> temp/ejemplo.txt
			elif [ ${estado[$i]} -eq 2 ]
			then
				echo -ne "${color[(i % 7)]}En ejecución" >> temp/ejemplo.txt
			else
				echo -ne "${color[(i % 7)]}Terminado" >> temp/ejemplo.txt
			fi
			echo -e "\t\t" >> temp/ejemplo.txt

			}

		#promedios
		echo "" >> temp/ejemplo.txt
		echo "" >> temp/informeSJF.txt
		echo -e "\e[0;31m * T.espera medio: $promedio_espera  -  * T.retorno medio: $promedio_respuesta \e[0m" >> temp/ejemplo.txt
		echo "" >> temp/ejemplo.txt
		cat temp/ejemplo.txt
		echo "" > temp/terminal.txt
		cp temp/ejemplo.txt temp/terminal.txt
		echo "" > temp/ejemplo.txt

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
touch temp/input.txt
for((i=0; i<$npart; i++)){
	echo -ne "${particiones[$i]}," >> temp/input.txt
}
echo -e "\nTiempo_de_llegada,tiempo_de_ejecucion,tamaño_en_memoria" >> temp/input.txt
for((i=1; i<=$npro; i++)){
	echo -e "${llegada[$i]},${tiempo[$i]},${tamanoMemoria[$i]}" >> temp/input.txt
}
cat temp/input.txt > input/datosEntrada.txt
rm temp/input.txt


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
	echo -ne "${proceso[$i]}" > "temp/${proceso[$i]}.tmp"
	for((x=1;x<$espacios;x++)){
		echo -ne " " >> "temp/${proceso[$i]}.tmp"
	}
	echo -ne " " >> "temp/${proceso[$i]}.tmp"
	tamanew[$i]=${tamanoMemoria[$i]}
	tEspera[$i]=0
	tRetorno[$i]=0
	tRestante[$i]=${tiempo[$i]}
	
}

#Se crean el principio de la gráfica de procesos
echo  -e "\n	${naranja}Gráfica${blanco}" > temp/cabecera.tmp
echo -ne "TIEMPO" >> temp/cabecera.tmp
for ((i=0;i<$npart;i++)){
	partocup[$i]=0
}
#Creamos los archivos temporales de la tabla de particiones y la lineal
echo -ne "        " > temp/nombreP.tmp



echo -ne "" > temp/nombreP2.tmp
echo -ne "	┌———————" > temp/primeraP2.tmp
echo -ne "	└———————" > temp/ultimaP2.tmp
echo -ne "       " > temp/nombreL.tmp
echo -ne "        " > temp/primeraL.tmp
echo -ne "        " > temp/ultimaL.tmp
echo -ne "       ${blanco}0" > temp/tiempoL.tmp
echo -ne "TIEMPO " > temp/lineal.tmp
o=0
for((i=0;i<$npart;i++)){
	
	exd=`expr $npart - 1`
	if [ $exd -ne $i ]
	then
		echo -ne " " >> temp/nombreP2.tmp
		echo -ne "┬———————" >> temp/primeraP2.tmp
		echo -ne "┴———————" >> temp/ultimaP2.tmp
		
	fi
}

echo -ne "┘" >> temp/ultimaP2.tmp
echo -ne "┐" >> temp/primeraP2.tmp

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
echo -n "" >  output/informe.txt

for((i=1;i<=$npro;i++)){
	tamanoAnterior[$i]=${tamanoMemoria[$i]}
	guion[$i]=1
	
}

for ((t=0;t<=1000;++t)){
	echo -e "\e[1;34mEstamos en el instante $t.\e[0m" > temp/ejemplo.txt

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
							echo -e "\e[1;32mEl proceso ${proceso[$j]}\e[1;32m se ha metido en la particion_$k y su tiempo de ejecucion es ${tiempo[$j]}.\e[0m" >> temp/ejemplo.txt
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
	echo -e "\t\t" > temp/graficaP.tmp
	cat temp/nombreP.tmp >> temp/graficaP.tmp
	echo -e "" >> temp/graficaP.tmp
	echo -n "" > temp/porcentajeP.tmp
	echo -ne "MEMORIA " > temp/procesoP.tmp
	echo -ne "        0" > temp/ultimaP1.tmp
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
				echo -n "▇▇▇" >> temp/procesoP.tmp
			}
			
			if [ $i -eq 0 ]; then
				for((o=0;o<`expr ${particiones[$i]}*3-2`;o++)){
					echo -n " " >> temp/ultimaP1.tmp
				}
				echo -ne "${tamfin[$i]}" >> temp/ultimaP1.tmp
			else
				if [ ${particiones[$j]} -lt 10 ]; then
					for((o=0;o<`expr ${particiones[$i]}*3-1`;o++)){
						echo -n " " >> temp/ultimaP1.tmp
					}
					echo -ne "${tamfin[$i]}" >> temp/ultimaP1.tmp
				else
					for((o=0;o<`expr ${particiones[$i]}*3-2`;o++)){
						echo -n " " >> temp/ultimaP1.tmp
					}
					echo -ne "${tamfin[$i]}" >> temp/ultimaP1.tmp
				fi
			fi
		else
						
				
			echo -ne "${color[(${partocup[$i]} % 7)]}" >> temp/procesoP.tmp
			for((o=0;o<${tamanew[${partocup[$i]}]};o++)){
				echo -ne "▇▇▇" >> temp/procesoP.tmp	
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

			echo -ne "$blanco" >> temp/procesoP.tmp
			for((o=0;o<$bucle;o++)){
				echo -ne "▇▇▇" >> temp/procesoP.tmp	
			}
			
			
			if [ $i -eq 0 ]; then
				for((o=0;o<`expr ${tamanew[${partocup[$i]}]}*3-1`;o++)){
					echo -ne " " >> temp/ultimaP1.tmp
				}
				echo -ne "$memm" >> temp/ultimaP1.tmp
				if [ $memm -lt 10 ]; then				
				for((o=0;o<`expr $bucle*3-1`;o++)){
					echo -ne " " >> temp/ultimaP1.tmp
				}
				echo -ne "${tamfin[$i]}" >> temp/ultimaP1.tmp
				else
				for((o=0;o<`expr $bucle*3-2`;o++)){
					echo -ne " " >> temp/ultimaP1.tmp
				}
				echo -ne "${tamfin[$i]}" >> temp/ultimaP1.tmp
				fi
			else
				if [ ${tamfin[$j]} -lt 10 ]; then
					for((o=0;o<`expr ${tamanew[${partocup[$i]}]}*3-1`;o++)){
					echo -ne " " >> temp/ultimaP1.tmp
					}
					echo -ne "$memm" >> temp/ultimaP1.tmp
					if [ $memm -lt 10 ]; then
						for((o=0;o<`expr $bucle*3-1`;o++)){
						echo -ne " " >> temp/ultimaP1.tmp
						}
						echo -ne "${tamfin[$i]}" >> temp/ultimaP1.tmp
					else 
						for((o=0;o<`expr $bucle*3-2`;o++)){
						echo -ne " " >> temp/ultimaP1.tmp
						}
						echo -ne "${tamfin[$i]}" >> temp/ultimaP1.tmp
					fi
				else 
					for((o=0;o<`expr ${tamanew[${partocup[$i]}]}*3-2`;o++)){
					echo -ne " " >> temp/ultimaP1.tmp
					}
					echo -ne "$memm" >> temp/ultimaP1.tmp
					if [ $memm -lt 10 ]; then
						for((o=0;o<`expr $bucle*3-1`;o++)){
						echo -ne " " >> temp/ultimaP1.tmp
						}
						echo -ne "${tamfin[$i]}" >> temp/ultimaP1.tmp
					else 
						for((o=0;o<`expr $bucle*3-2`;o++)){
						echo -ne " " >> temp/ultimaP1.tmp
						}
						echo -ne "${tamfin[$i]}" >> temp/ultimaP1.tmp
					fi
				fi	
			fi		
			
			
		fi
		echo -n "" >> temp/procesoP.tmp
	}
	cat temp/procesoP.tmp >> temp/graficaP.tmp
	echo -e "" >> temp/graficaP.tmp
	cat temp/ultimaP1.tmp >>temp/graficaP.tmp
	


	cat temp/nombreP2.tmp >> temp/graficaP.tmp
	echo -e "" >> temp/graficaP.tmp
	cat temp/primeraP2.tmp >> temp/graficaP.tmp
	echo -e "" >> temp/graficaP.tmp
	echo -n "" > temp/porcentajeP.tmp
	for((i=0;i<$npart;i++)){
		echo -ne "\t|${proceso[${partocup[$i]}]}" >> temp/graficaP.tmp
		echo -ne "\t|${color[(${partocup[$i]} % 7)]} ${tamanew[${partocup[$i]}]}$blanco/${particiones[$i]}" >> temp/porcentajeP.tmp
	}
	echo "	|" >> temp/porcentajeP.tmp
	echo "	|" >> temp/graficaP.tmp
	cat temp/porcentajeP.tmp >> temp/graficaP.tmp
	cat temp/ultimaP2.tmp >> temp/graficaP.tmp


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
			
			echo -n "▇▇▇" >> temp/lineal.tmp
			echo -ne "   " >> temp/nombreL.tmp
			echo -ne "  " >> temp/tiempoL.tmp
		else
			if [ $t -lt 10 ]; then			
			let tt=`expr 3*${tiempo[${proAct}]}-3`
			let ttt=`expr 3*${tiempo[${proAct}]}-1`
			else
			let tt=`expr 3*${tiempo[${proAct}]}-3`
			let ttt=`expr 3*${tiempo[${proAct}]}-2`
			fi
			
			echo -ne "${color[($proAct % 7)]}${proceso[$proAct]}$blanco" >> temp/nombreL.tmp
			for((o=0;o<$tt;o++)){
				echo -ne " " >> temp/nombreL.tmp
			}	
			echo -ne "${blanco}$t" >> temp/tiempoL.tmp			
			for((o=0;o<${tiempo[${proAct}]};o++)){
				echo -ne "${color[($proAct % 7)]}▇▇▇" >> temp/lineal.tmp
			}
			for((o=0;o<$ttt;o++)){
				echo -ne " " >> temp/tiempoL.tmp
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
		echo -e "\e[1;33mEl proceso ${proceso[$proAct]}\e[1;33m ha entrado en CPU.\e[0m" >> temp/ejemplo.txt
	fi

	#Si el procesador está ocupado mostrar cuanto tiempo le queda al proceso en cuestión
	if [ $cpus -eq 1 ]
	then
		cpu=`expr $cpu - 1`
		echo "El procesador esta ocupado" >> temp/ejemplo.txt
		echo -e "\e[1;31mAl proceso ${proceso[$proAct]}\e[1;31m le quedan $cpu tiempos de ejecucion.\e[0m" >> temp/ejemplo.txt  #si la cpu esta ocupada estara trabajando y reduciendo el tiempo de ejecucion 1 por cada paso de bucle
		#Dibujamos la gráfica
		for ((i=1;i<=$npro;i++)){
			if [ $i -eq $proAct ]
			then
				echo -ne "${color[($i % 7)]}▇▇▇$blanco" >> "temp/${proceso[$i]}.tmp"
			else
				echo -ne " " >> "temp/${proceso[$i]}.tmp"
			fi
		}
	else
		for ((i=1;i<=$npro;i++)){
			echo -ne " " >> "temp/${proceso[$i]}.tmp"
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
	echo "" >> temp/ejemplo.txt
	echo -e "\t Tabla de procesos" >> temp/ejemplo.txt
	echo -e "\t${naranja}REF ${naranja}TLL ${naranja}TEJ ${naranja}MEM ${naranja}TESP ${naranja}TRET ${naranja}TREJ ${naranja}Estado" >> temp/ejemplo.txt
	
	ejec=0
	ress=0	
	for ((i=1;i<=$npro;i++)){
		echo -ne "\t${color[(i % 7)]}${proceso[$i]}"  >> temp/ejemplo.txt
		if [ ${llegada[$i]} -lt 10 ]; then 		
		echo -ne " ${color[(i % 7)]}${llegada[$i]}  " >> temp/ejemplo.txt
		else
		echo -ne " ${color[(i % 7)]}${llegada[$i]} " >> temp/ejemplo.txt
		fi
		if [ ${tiempo[$i]} -lt 10 ]; then 		
		echo -ne " ${color[(i % 7)]}${tiempo[$i]}  " >> temp/ejemplo.txt
		else
		echo -ne " ${color[(i % 7)]}${tiempo[$i]} " >> temp/ejemplo.txt
		fi 
		if [ ${tamanew[$i]} -lt 10 ]; then 		
		echo -ne " ${color[(i % 7)]}${tamanew[$i]}  " >> temp/ejemplo.txt
		else
		echo -ne " ${color[(i % 7)]}${tamanew[$i]} " >> temp/ejemplo.txt
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
			echo -ne "  -  " >> temp/ejemplo.txt
			echo -ne "  -  " >> temp/ejemplo.txt
			echo -ne "  -  " >> temp/ejemplo.txt
			
		else
			if [ $tRet -lt 10 ]; then
				echo -ne "  ${color[(i % 7)]}$tEsp  " >> temp/ejemplo.txt
			else 	
				echo -ne "  ${color[(i % 7)]}$tEsp " >> temp/ejemplo.txt
			fi
			if [ $tEsp -lt 10 ]; then
				echo -ne "  ${color[(i % 7)]}$tRet  " >> temp/ejemplo.txt
			else 	
				echo -ne "  ${color[(i % 7)]}$tRet " >> temp/ejemplo.txt
			fi
			if [ $tRes -lt 10 ]; then
				echo -ne "  ${color[(i % 7)]}$tRes  " >> temp/ejemplo.txt
			else 	
				echo -ne "  ${color[(i % 7)]}$tRes " >> temp/ejemplo.txt
			fi
	
		fi
		
		if [ ${estado[$i]} -eq 0 ]
		then
			if [ $t -ge ${llegada[$i]} ]
			then
				echo -ne " ${color[(i % 7)]}En espera" >> temp/ejemplo.txt
				tRetorno[$i]=`expr ${tRetorno[$i]} + 1`
				guion[$i]=1
				
				
			else
				echo -ne " ${color[(i % 7)]}Fuera del sistema" >> temp/ejemplo.txt
				guion[$i]=1
				
				
			fi
		elif [ ${estado[$i]} -eq 1 ]
		then
			guion[$i]=0			
			echo -ne " ${color[(i % 7)]}En memoria" >> temp/ejemplo.txt
			tRetorno[$i]=`expr ${tRetorno[$i]} + 1`
			
			ress[$i]=0
			
		elif [ ${estado[$i]} -eq 2 ]
		then
			guion[$i]=0
			echo -ne " ${color[(i % 7)]}En ejecución" >> temp/ejemplo.txt
			ejec=1
			ress[$i]=0
			tRestante[$i]=`expr ${tRestante[$i]} - 1`			
			tRetorno[$i]=`expr ${tRetorno[$i]} + 1`
			
		else
			if [ $i -eq $proAnt ]
			then
				echo -ne " ${color[(i % 7)]}En ejecución " >> temp/ejemplo.txt
				ejec=1
				ress[$i]=0
				tRetorno[$i]=`expr ${tRetorno[$i]} + 1`
				tRestante[$i]=`expr ${tRestante[$i]} - 1`
				guion[$i]=0
			else
				if [ ${tRestante[$i]} -ne 0 ]; then
					tRestante[$i]=`expr ${tRestante[$i]} - 1`
				fi				
				echo -ne " ${color[(i % 7)]}Terminado" >> temp/ejemplo.txt
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
		
		echo -e "\t\t" >> temp/ejemplo.txt
		
		
		ejec=0
	mediaEspera=$(expr $mediaEspera + ${tEspera[$i]})
	
	mediaRetorno=$(expr $mediaRetorno + ${tRetorno[$i]})
	

	}
	mediaEspera=$(expr $mediaEspera/1)	
	promedioMediaEspera=$(echo "scale=2; $mediaEspera / $npro"| bc)
	mediaRetorno=$(expr $mediaRetorno/1)	
	promedioMediaRetorno=$(echo "scale=2; $mediaRetorno / $npro"| bc)	
	
		
	echo -en  "\tMedia de espera: ${blanco}$promedioMediaEspera\t  Media de retorno: ${blanco}$promedioMediaRetorno" >> temp/ejemplo.txt

	echo -e "" >> temp/ejemplo.txt
	
	
	echo "	|" >> temp/porcentajeP.tmp
	cat temp/graficaP.tmp >> temp/ejemplo.txt
	echo "" >> temp/ejemplo.txt
	
	cat temp/nombreL.tmp >> temp/ejemplo.txt
	echo "" >> temp/ejemplo.txt
	
	cat temp/lineal.tmp >> temp/ejemplo.txt
	
	echo "" >> temp/ejemplo.txt
	cat temp/tiempoL.tmp >> temp/ejemplo.txt


	echo "" >> temp/ejemplo.txt
	echo "-------------------------------------------------------------------------------------" >> temp/ejemplo.txt
	echo "" >> temp/ejemplo.txt

	if [ $evento -eq 1 ]
	then
		if [ "$hayEvento" -eq 1 ]
		then
			cat temp/ejemplo.txt >>  output/informe.txt
			clear
			cat  output/informe.txt
		fi
	else
		clear
		cat temp/ejemplo.txt >>  output/informe.txt
		cat  output/informe.txt
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
			echo -e "" >> "temp/${proceso[$i]}.tmp"
		}
		
		
			
		
		echo "" >> temp/cabecera.tmp
		cat temp/cabecera.tmp > temp/grafica.tmp
		
		
		for ((i=1;i<=$npro;i++)){
			cat "temp/${proceso[$i]}.tmp" >> temp/grafica.tmp
		}
		
		#~ cat temp/graficaP.tmp >> temp/grafica.tmp
		#Dibujamos gráfica lineal
		
		echo "|" >> temp/lineal.tmp
		echo "" >> temp/grafica.tmp
		echo -e "	  ${naranja}Gráfica Lineal${blanco} " >> temp/grafica.tmp
		cat temp/nombreL.tmp >> temp/grafica.tmp
		echo "" >> temp/grafica.tmp
		
		cat temp/lineal.tmp >> temp/grafica.tmp
		
		cat temp/tiempoL.tmp >> temp/grafica.tmp
		echo -e "\n" >> temp/grafica.tmp
		cat temp/ejemplo.txt >>  output/informe.txt
		clear
		cat  output/informe.txt
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


cat temp/grafica.tmp > output/grafica.txt
rm temp/*.tmp
rm *.tmp
rm -rf temp
cat  output/informe.txt | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g" >> output/informeblanco.txt 

echo "Fin  del script. Pulsa enter para finalizar..."
read fin
