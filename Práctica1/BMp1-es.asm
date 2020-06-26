section .data               
;Cambiar Nombre y Apellido por vuestros datos.
developer db "Oscar Gonzalez Tur",0

;Constantes que también están definidas en C.
DimMatrix    equ 10
SizeMatrix   equ 100

section .text            
;Variables definidas en Ensamblador.
global developer     
                         
;Subrutinas de ensamblador que se llaman desde C.
global posCurScreenP1, showMinesP1, updateBoardP1, moveCursorP1
global mineMarkerP1, checkMinesP1, printMessageP1, playP1	 

;Variables globales definidas en C.
extern rowScreen, colScreen, rowMat, colMat, indexMat
extern charac, mines, marks, numMines, state

;Funciones de C que se llaman desde ensamblador
extern gotoxyP1_C, getchP1_C, printchP1_C
extern printBoardP1_C, printMessageP1_C,  	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ATENCIÓN: Recordad que las variables y los Parámetros de tipo 'char',
;;   en ensamblador se tienen que asignar a registros de tipo  
;;   BYTE (1 byte): al, ah, bl, bh, cl, ch, dl, dh, sil, dil, ..., r15b
;;   las de tipo 'int' se tienen que assignar a registres de tipo 
;;   DWORD (4 bytes): eax, ebx, ecx, edx, esi, edi, ...., r15d
;;   las de tipo 'long' se tienen que assignar a registros de tipo 
;;   QWORD (8 bytes): rax, rbx, rcx, rdx, rsi, rdi, ...., r15
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Las subrutinas en ensamblador que tenéis que implementar son:
;;   posCurScreenP1, showMinesP1, updateBoardP1
;;   moveCursorP1, mineMarkerP1, checkMinesP1
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Esta subrutina se da hecha. NO LA PODÉIS MODIFICAR.
; Situar el cursor en una fila indicada por la variable (rowScreen) y en 
; una columna indicada por la variable (colScreen) de pantalla 
; llamando a la función gotoxyP1_C.
; 
; Variables globales utilizadas:	
; rowScreen: fila de la pantalla donde posicionamos el cursor.
; colScreen: columna de la pantalla donde posicionamos el cursor.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gotoxyP1:
   push rbp
   mov  rbp, rsp
   ;guardamos el estado de los registros del procesador porque
   ;las funciones de C no mantienen el estado de los registros.
   push rax
   push rbx
   push rcx
   push rdx
   push rsi
   push rdi
   push r8
   push r9
   push r10
   push r11
   push r12
   push r13
   push r14
   push r15

   call gotoxyP1_C
 
   pop r15
   pop r14
   pop r13
   pop r12
   pop r11
   pop r10
   pop r9
   pop r8
   pop rdi
   pop rsi
   pop rdx
   pop rcx
   pop rbx
   pop rax

   mov rsp, rbp
   pop rbp
   ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Esta subrutina se da hecha. NO LA PODÉIS MODIFICAR.
; Mostrar un carácter guradado en la variable (charac) en pantalla, en
; la posición donde está el cursor llamando a la función printchP1_C.
; 
; Variables globales utilizadas:	
; charac   : carácter que queremos mostrar.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
printchP1:
   push rbp
   mov  rbp, rsp
   ;guardamos el estado de los registros del procesador porque
   ;las funciones de C no mantienen el estado de los registros.
   push rax
   push rbx
   push rcx
   push rdx
   push rsi
   push rdi
   push r8
   push r9
   push r10
   push r11
   push r12
   push r13
   push r14
   push r15

   call printchP1_C
 
   pop r15
   pop r14
   pop r13
   pop r12
   pop r11
   pop r10
   pop r9
   pop r8
   pop rdi
   pop rsi
   pop rdx
   pop rcx
   pop rbx
   pop rax

   mov rsp, rbp
   pop rbp
   ret
   

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Esta subrutina se da hecha. NO LA PODÉIS MODIFICAR.
; Leer una tecla y guardar el carácter asociado en la variable (charac) 
; sin mostrarlo en pantalla, llamando a la función getchP1_C
; 
; Variables globales utilizadas:	
; charac   : carácter que queremos mostrar.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getchP1:
   push rbp
   mov  rbp, rsp
   ;guardamos el estado de los registros del procesador porque
   ;las funciones de C no mantienen el estado de los registros.
   push rax
   push rbx
   push rcx
   push rdx
   push rsi
   push rdi
   push r8
   push r9
   push r10
   push r11
   push r12
   push r13
   push r14
   push r15

   call getchP1_C
 
   pop r15
   pop r14
   pop r13
   pop r12
   pop r11
   pop r10
   pop r9
   pop r8
   pop rdi
   pop rsi
   pop rdx
   pop rcx
   pop rbx
   pop rax
   
   mov rsp, rbp
   pop rbp
   ret 
   

;;;;;
; Posicionar el cursor en pantalla dentro del tablero, en función del 
; índice de la matriz (indexMat), posición del cursor dentro del tablero.
; Para calcular la posición del cursor en pantalla utilizar 
; estas fórmulas:
; rowScreen=((indexMat/10)*2)+7
; colScreen=((indexMat%10)*4)+7
; Para posicionar el cursor se llama a la subrutina gotoxyP1
;
; Variables globales utilizadas:	
; indexMat : Índice para acceder a las matrices mines y marks desde ensamblador.
; rowScreen: Fila de la pantalla donde posicionamos el cursor.
; colScreen: Columna de la pantalla donde posicionamos el cursor.
;;;;;  
posCurScreenP1:
	push rbp
	mov  rbp, rsp
	
	; Guardamos los registros en la pila para poder trabajar
	; con ellos sin perder información.
	push rax	; Registro para el dividendo y a la vez cociente de la división
	push rdx	; Registro para almacenar el resto de la división
	push rbx	; Registro para almacenar el divisor
	
	;-------------------------------------------------------------------
	;Inicializar
	mov rax, QWORD [indexMat]; Copiamos el valor de indexMat en nuestro
						;registro para  calcular las coordenadas en el tablero.
	mov rbx, 10			;Inicializamos rbx con el valor del divisor.
	mov rdx, 0			;Inicializamos rdx a 0;
	;-------------------------------------------------------------------
	;Operaciones
	div rbx				; División de rax entre el valor del registro rbx,
						; obtenemos el cociente en el registro rax
						; y el resto en el registro rdx. (indexMat/10) y (indexMat%10)
	shl rax, 1			; Desplazamos los bits una posición a la izquierda
						; que equivale a multiplicar por dos. ((indexMat/10)*2)
	add rax, 7			; Por último se le suma 7. rowScreen=((indexMat/10)*2)+7
	mov  QWORD [rowScreen], rax ; copiamos el valor a la variable rowScreen
	
	shl rdx, 2			; Desplazamos los bits dos posiciones a la izquierda
						; que equivale a multiplicar por 4. ((indexMat%10)*4)
	add rdx, 7			; Por último se le suma 7. colScreen=((indexMat%10)*4)+7
	mov QWORD [colScreen], rdx ; copiamos el valor a la variable colScreen
	
	call gotoxyP1		;Llamamos a la rutina gotoxyP1 para colocar el
						;curso en las coordenadas resultantes.
	
	;-------------------------------------------------------------------
	; Finalizamos la función devolviendo la pila y los registros
	; a su estado original	
	pop rbx
	pop rdx
	pop rax
				
	mov rsp, rbp
	pop rbp
	ret


;;;;;
; Convierte el valor del Número de minas que quedan por marcar (numMines)
; (entre 0 y 99) a dos caracteres ASCII. 
; Se tiene que dividir el valor (numMines) entre 10, el cociente 
; representará las decenas y el residuo las unidades, y después se
; tienen que convertir a ASCII sumando 48, carácter '0'.
; Mostrar los dígitos (carácter ASCII) de les decenas en la fila 27, 
; columna 24 de la pantalla y las unidades en la fila 27, columna 26.
; (la posición se indica através de las variables rowScreen y colScreen).
; Para posicionar el cursor se llama a la subrutina gotoxyP1 y para 
; mostrar los caracteres a la subrutina printchP1.
;
; Variables globales utilizadas:	
; rowScreen: Fila de la pantalla donde posicionamos el cursor.
; colScreen: Columna de la pantalla donde posicionamos el cursor.
; numMines : Número de minas que quedan por marcar.
; charac   : Carácter a escribir en pantalla
;;;;;
showMinesP1:
	push rbp
	mov  rbp, rsp
		
	; Guardamos los registros en la pila para poder trabajar
	; con ellos sin perder información.
	push rax	; Registro para el dividendo y a la vez cociente de la división
	push rdx	; Registro para almacenar el resto de la división
	push rbx	; Registro para almacenar el divisor
	
	mov rax, 0 	;Inicializamos el registro a 0
	mov eax, DWORD [numMines] ;Inicializamos el registro con el valor de numMines
	mov edx, 0 	;Inicializamos el registro a 0
	
	;-------------------------------------------------------------------
	;Calculamos las decenas (cociente, registro al (1 byte para char)) 
	;y  las unidades (resto, registro dl (1 byte para char))
	mov ebx, 10	;El divisor
	div ebx		;Se divide el dividendo, eax entre ebx, es decir,
				;numMines/10
				
	;-------------------------------------------------------------------			
	;Ahora convertimos el cociente (decenas) y el resto (unidades)			
	;sumando al resultado el caracter "0", ya que en el código ASCII
	;los caracteres de números son correlativos
	add al, "0"
	add dl, "0"
	
	;-------------------------------------------------------------------
	;Mostramos los caracteres por pantalla en las posiciones indicadas
	;para cada valor (decenas y unidades)
	mov QWORD [rowScreen], 27	;Posición del cursor en la fila 27
	mov QWORD [colScreen], 24	;Posición el cursor en la columna 24
	call gotoxyP1 				;Colocamos el puntero en las coordenadas
	
	mov BYTE [charac], al		;Copiamos el valor de las decenas en la 
								;variable charac
	call printchP1				;y lo mostramos en pantalla
	
	;Para las unidades desplazamos el curso hacia la derecha
	mov QWORD [colScreen], 26
	call gotoxyP1				;Y colocamos el cursor en las nuevas coordenadas
	
	mov BYTE [charac], dl		;Copiamos el valor de las unidades en la 
								;variable charac
	call printchP1				;y lo mostramos en pantalla
	
	;-------------------------------------------------------------------
	; Finalizamos la función devolviendo la pila y los registros
	; a su estado original
	pop rbx
	pop rdx
	pop rax
	
	mov rsp, rbp
	pop rbp
	ret


;;;;;
; Actualizar el contenido del Tablero de Juego con los datos de la 
; matriz (marks) y el número de minas que quedan por marcar.
; Se tiene que recorrer toda la matriz (marks), y para cada elemento 
; de la matriz posicionar el cursor en pantalla y mostrar los caracteres 
; de la matriz. 
; Después mostrar el valor de (numMines) en la parte inferior del tablero.
; Para posicionar el cursor se llama la subrutina gotoxyP1, 
; para a mostrar los caracteres se llama la subrutina printchP1 y para 
; mostrar (numMines) se llama a la subrutina ShowMinesP1.
;
; Variables globales utilizadas:	
; rowScreen: Fila de la pantalla donde posicionamos el cursor.
; colScreen: Columna de la pantalla donde posicionamos el cursor.
; charac   : Carácter a escribir en pantalla.
; marks    : Matriz con las minas marcadas y las minas abiertas.   
;;;;;  
updateBoardP1:
	push rbp
	mov  rbp, rsp

	;-------------------------------------------------------------------
	; Guardamos los registros en la pila para poder trabajar
	; con ellos sin perder información.
	push rax
	push rbx
	push rcx
	push rdx
	
	;-------------------------------------------------------------------
	;Inicializamos las variables
	mov al, 0		;Registro para el caracter (1 byte)
	mov rbx, 0		;Registro para la fila de la matriz
	mov rcx, 0		;Registro para la columna de la matriz
	mov rdx, 0		;Registro para el indice de la matriz marks

	;-------------------------------------------------------------------
	;Siguiendo los pasos de la función updateBoardP1_C() copiamos el 
	;valor 7 en la variable rowScreen
	mov QWORD [rowScreen], 7
		
	;-------------------------------------------------------------------
	;Iniciamos el primer bucle for para recorrer las filas de la matriz
	updateBoardP1rowFor:	;equivale a for (i=0;i<DimMatrix;i++)
		cmp rbx, DimMatrix
		jge updateBoardP1rowForEnd ;si rbx>= DimMatrix acaba este ciclo
		
		mov QWORD [colScreen], 7 ;colScreen = 7
		mov rcx, 0				 ;Reinicializamos el registro de la
								 ;columna a 0 para recorrer la siguiente
								 ;fila.
	;-------------------------------------------------------------------
	;Con este segundo bucle for recorreremos las columnas de cada fila
			updateBoardP1colFor: ;Equivale a for (j=0;j<DimMatrix;j++)
				cmp rcx, DimMatrix
				jge updateBoardP1colForEnd ;Si rcx>= DimMatrix se acaba
										   ;este ciclo
				call gotoxyP1
				
				mov al, BYTE [marks+rdx]   ;Copiamos en la variable al
						;el valor almacenado en el indice rdx
				mov BYTE [charac], al	;Copiamos el valor guardado en
						;el registro al en la variable charac
				call printchP1	;Y lo mostramos en pantalla
				add QWORD [colScreen], 4	;colScreen = colScreen +4
				
				;-------------------------------------------------------
				;Aquí realizamos la última parte del bucle for que es
				;incrementar el indice usado en el bucle e iniciar el 
				;siguiente ciclo del bucle
				
				inc rdx	;Incrementamos el indice de la matriz marks.
				inc rcx ;Incrementamos el indice del bucle 2, saltando 
						;así a la siguiente columna de la fila.
				jmp updateBoardP1colFor ;Saltamos al siguiente ciclo del
										;bucle
			updateBoardP1colForEnd:		;Etiqueta de finalización del bucle
	;-------------------------------------------------------------------
	;Cuando finalizan todos los ciclos del bucle interior updateBoardP1colFor
	;podemos continuar con las sentencias restantes del bucle exterior
	;updateBoardP1rowFor
		add QWORD [rowScreen], 2	;rowScreen = rowScreen +2
		inc rbx						;Incrementamos la fila en uno para 
						;en el siguiente ciclo pasar a la siguiente.
		jmp updateBoardP1rowFor	;Saltamos al siguiente ciclo del bucle
								;updateBoardP1rowFor
	updateBoardP1rowForEnd:		;Etiqueta de finalización del bucle
	
	;-------------------------------------------------------------------
	;Por último, realizamos la llamada de la subrutina showMinesP1
	call showMinesP1
				
	;-------------------------------------------------------------------
	; Finalizamos la función devolviendo la pila y los registros
	; a su estado original
	pop rdx
	pop rcx
	pop rbx
	pop rax

	mov rsp, rbp
	pop rbp
	ret


;;;;;		
; Actualizar la posición del cursor en el tablero, que tenemos indicada 
; con la variable (indexMat), en función de la tecla pulsada, 
; que tenemos en la variable (charac). 
; Si se sale fuera del tablero no actualizar la posición del cursor.
; Arriba y abajo:      ( indexMat = indexMat +/- 10 ) 
; Derecha y Izquierda: ( indexMat = indexMat +/- 1 ) 
; No se tiene que posicionar el cursor en pantalla.
;
; Variables globales utilizadas:	
; indexMat : Índice para acceder a las matrices mines y marks desde ensamblador.
; charac   : Carácter leído de teclado.
;;;;;  
moveCursorP1:
	push rbp
	mov  rbp, rsp
	
	; Guardamos los registros en la pila para poder trabajar
	; con ellos sin perder información.
	push rax	; Registro para el dividendo y a la vez cociente de la división
	push rdx	; Registro para almacenar el resto de la división
	push rbx	; Registro para almacenar el divisor
	
	;-------------------------------------------------------------------
	;Inicializar
	mov rax, QWORD [indexMat]; Copiamos el valor de indexMat en nuestro
						;registro para  calcular las coordenadas en el tablero.
	mov rbx, 0
	mov rdx, 0
	mov rbx, 10			;Inicializamos rbx con el valor del divisor.
	
	
	;-------------------------------------------------------------------
	;Operaciones
	div rbx				; División de rax entre el valor del registro rbx,
						; obtenemos el cociente en el registro rax
						; y el resto en el registro rdx. (indexMat/10) y (indexMat%10)
	
	;-------------------------------------------------------------------
	;En esta subrutina compararemos el valor almacenado en la variable
	;charac, y en consecuencia modificaremos la variable indexMat
	
	cmp BYTE [charac], "i"	;case 'i': //amunt
	je moveCursorP1Up
	cmp BYTE [charac], "j"	;case 'j': //esquerra
	je moveCursorP1Left
	cmp BYTE [charac], "k"	;case 'k': //avall
	je moveCursorP1Down
	cmp BYTE [charac], "l"	;case 'l': //dreta
	je moveCursorP1Right
	
	;-------------------------------------------------------------------
	;Una vez leído el caracter y comparado, definimos las acciones de 
	;cada posible caso.
	moveCursorP1Up:				;mover el cursor hacia arriba
		cmp rax, 0 				;if(row>0) Comprobamos que no se salga 
		jle moveCursorP1End		;fuera del tablero.
		sub QWORD [indexMat], 10;indexMat=indexMat-10;
		jmp moveCursorP1End
	
	moveCursorP1Left:			;mover el cursor hacia la izquierda
		cmp rdx, 0 				;if(col>0) Comprobamos que no se salga 
		jle moveCursorP1End		;fuera del tablero.
		dec QWORD [indexMat]	;indexMat--;
		jmp moveCursorP1End
		
	moveCursorP1Down:			;mover el cursor hacia abajo			
		cmp rax, DimMatrix-1	;if (row<DimMatrix-1) Comprobamos que 
		jge moveCursorP1End		;no se salga fuera del tablero.
		add QWORD [indexMat], 10;indexMat=indexMat+10;
		jmp moveCursorP1End
		
	moveCursorP1Right:			;mover el cursor hacia la derecha
		cmp rdx, DimMatrix-1	;if (col<DimMatrix-1) Comprobamos que 
		jge moveCursorP1End		;no se salga fuera del tablero.
		inc QWORD [indexMat]	;indexMat++;
		jmp moveCursorP1End
	
	moveCursorP1End:
	
	;-------------------------------------------------------------------
	; Finalizamos la función devolviendo la pila y los registros
	; a su estado original
	pop rbx
	pop rdx
	pop rax
	
	mov rsp, rbp
	pop rbp
	ret


;;;;;  
; Marcar/desmarcar una mina en la matriz (marks) en la posición actual 
; del cursor indicada por la variable (indexMat).
; Si en aquella posición de la matriz (marks) hay un espacio en blanco
; y no hemos marcado todas las minas, marcamos una mina poniendo una 
; 'M' en la matriz (marks) y decrementamos el número de minas que quedan 
; por marcar (numMines), si en aquella posición de la matriz (marks) hay
; una 'M', pondremos un espacio (' ') en la matriz (marks) e 
; incrementaremos el número de minas que quedan por marcar (numMines).
; Si hay otro valor no cambiaremos nada.
; No se tiene que mostrar la matriz, sólo actualizar la matriz (marks) 
; y la variable (numMines).
;
; Variables globales utilizadas:	
; indexMat : índice para acceder a la matriz marks.
; marks    : Matriz con las minas marcadas y las minas abiertas.
; numMines : número de minas que quedan por marcar.
;;;;;  
mineMarkerP1:
	push rbp
	mov  rbp, rsp

	;-------------------------------------------------------------------
	;Guardamos el contenido del registro rsi en la pila, ya que lo usaremos
	;como indice para movernos por la matriz marks. Utilizaremos la dirección
	;de la matriz marks y le sumaremos el desplazamiento en bytes de IndexMat
	
	push rsi
	
	mov rsi, QWORD [indexMat]	;Copiamos el valor de indexMat en el 
								;registro de 8 bytes rsi.
								
	;-------------------------------------------------------------------
	;Primero hacemos el primer if de la función mineMarkerP1_C y su else
	;para luego anidar un if dentro del else.
	cmp BYTE [marks + rsi], " "	;if (marks[rowMat][colMat] == ' '
	jne mineMarkerP1Unmarked
	cmp QWORD [numMines], 0
	jle mineMarkerP1Unmarked	; && numMines > 0) 
	
	;-------------------------------------------------------------------
	;Si esa posición está vacía (" ") y numMines > 0
	mov BYTE [marks + rsi], "M"	;marks[rowMat][colMat] = 'M'; //Marcar
	dec QWORD[numMines]
	jmp mineMarkerP1End
	
	;-------------------------------------------------------------------
	;En el caso que las condiciones no se cumplan se pasaría directamente
	;a este bloque que es el else del primer if
	mineMarkerP1Unmarked:
		;---------------------------------------------------------------
		;Aquí anidamos el if dentro del else
		cmp BYTE [marks + rsi], "M"	;
		jne mineMarkerP1End
		mov BYTE [marks + rsi], " ";
		inc QWORD [numMines]
		
	mineMarkerP1End:
	
	;-------------------------------------------------------------------
	; Finalizamos la función devolviendo la pila y los registros
	; a su estado original
	pop rsi
	
	mov rsp, rbp
	pop rbp
	ret
	

;;;;;  
; Verificar si hemos marcado todas las minas 
; Si (numMines=0) cambiar el estado a 2 (state=2) (Gana).
;
; Variables globales utilizadas:	
; numMines : Número de minas que quedan por marcar.
; state    : Indica el estado del juego
;;;;;  
checkMinesP1:
	push rbp
	mov  rbp, rsp

	cmp DWORD [numMines], 0	;if(numMines == 0)
	jne checkMinesP1End
	mov DWORD [state], 2	;state = 2;
	
	checkMinesP1End:

	mov rsp, rbp
	pop rbp
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Esta subrutina se da hecha. NO LA PODÉIS MODIFICAR.
; Muestra un mensaje debajo del tablero según el valor de la variable
; (state) llamando la función printMessageP1_C.
; (state) 0: Salir, hemos pulsado la tecla 'ESC' para salir.
;         1: Continuamos jugando.
;         2: Gana, se han marcado todas las minas.
; Se espera que se pulse una tecla para continuar.
;         
; Variables globales utilizadas:	
; rowScreen: Fila de la pantalla donde posicionamos el cursor.
; colScreen: Columna de la pantalla donde posicionamos el cursor.
; state    : Indica el estado del juego
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
printMessageP1:
   push rbp
   mov  rbp, rsp
   ;guardamos el estado de los registros del procesador porque
   ;las funciones de C no mantienen el estado de los registros.
   push rax
   push rbx
   push rcx
   push rdx
   push rsi
   push rdi
   push r8
   push r9
   push r10
   push r11
   push r12
   push r13
   push r14
   push r15

   ;Llamamos a la función printMessageP1_C() desde ensamblador, 
   call printMessageP1_C
 
   pop r15
   pop r14
   pop r13
   pop r12
   pop r11
   pop r10
   pop r9
   pop r8
   pop rdi
   pop rsi
   pop rdx
   pop rcx
   pop rbx
   pop rax

   mov rsp, rbp
   pop rbp
   ret

  
;;;;;
; Esta subrutina se da hecha. NO LA PODÉIS MODIFICAR.
; Juego del Buscaminas
; Función principal del juego
; Permite jugar al juego del buscaminas llamando a todas las funcionalidades.
;
; Pseudo código:
; Inicializar estado del juego, (state=1)
; Inicializar posición inicial del cursor:
; fila: 5 y columna: 4, (indexMat=54).
; Mostrar el tablero de juego llamando la función PrintBoardP1_C.
; Mientras (state=1) hacer:
;   Actualizar el contenido del Tablero de Juego y el número de minas
;     que quedan por marcar (llamar la subrutina updateBoardP1).
;   Posicionar el cursor dentro del tablero (llamar a la subrutina posCurScreenP1).
;   Leer una tecla y guardarla en la variable (charac) (llamar a la subrutina getchP1). 
;   Según la tecla leída llamaremos a la función correspondiente.
;     - ['i','j','k' o 'l']       (llamar a la subrutina MoveCursorP1).
;     - 'm'                       (llamar a la subrutina MineMarkerP1).
;     - '<ESC>'  (codi ASCII 27) poner (state = 0) para salir.   
;   Verificar si hemos marcado todas las minas (llamar a la subrutina CheckMinesP1).
; Fin mientras.
; Salir: 
;   Actualizar el contenido del Tablero de Juego y el número de minas que 
;   quedan por marcar (llamar a la subrutina updateBoardP1).
;   Mostrar el mensaje de salida que corresponda (llamar a la subrutina
;   printMessageP1).
; Se acaba el juego.
; 
; Variables globales utilizadas:	
; indexMat : índice para acceder a la matriz marks.
; charac   : Carácter leido de teclado.
; state    : Estado del juego.
;;;;;  
playP1:
	push rbp
	mov  rbp, rsp

	mov DWORD[state], 1       ;Estado para empezar a jugar

	mov QWORD[indexMat], 54   ;indexMat = 54;
	
	call printBoardP1_C       ;printBoardP1_C();

	playP1_Loop:              
		cmp  DWORD[state], 1  ;while (state == 1)
		jne  playP1_PrintMessage

		call updateBoardP1    ;updateBoardP1_C();
		
		call posCurScreenP1   ;posCurScreenP1_C();
		
		call getchP1          ;getchP1_C(); 
		mov  al, BYTE[charac] 

		cmp al, 'i'		      ;if (charac>='i' && charac<='l')
		je  playP1_MoveCursor
		cmp al, 'j'		      
		je  playP1_MoveCursor
		cmp al, 'k'		      
		je  playP1_MoveCursor
		cmp al, 'l'		      
		je  playP1_MoveCursor
		cmp al, 'm'		      ;if (charac=='m')
		je  playP1_MineMarker
		cmp al, 27		      ;if (charac==27)
		je  playP1_Exit
		jmp playP1_Check

		playP1_MoveCursor     
		call moveCursorP1     ;moveCursorP1_C();
		jmp  playP1_Check

		playP1_MineMarker     ;mineMarkerP1_C();
		call mineMarkerP1
		jmp  playP1_Check

		playP1_Exit:
		mov DWORD[state], 0   ;state = 0;
		
		playP1_Check:
		call checkMinesP1     ;checkMinesP1_C();

		jmp  playP1_Loop

	playP1_PrintMessage:
	call updateBoardP1        ;updateBoardP1_C();
	call printMessageP1       ;printMessageP1_C();
    
	playP1_End:		
	mov rsp, rbp
	pop rbp
	ret
