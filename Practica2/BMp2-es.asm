section .data               
;Cambiar Nombre y Apellido por vuestros datos.
developer db "Oscar González Tur",0

;Constantes que también están definidas en C.
DimMatrix    equ 10
SizeMatrix   equ 100	

section .text            
;Variables definidas en Ensamblador.
global developer                        

;Subrutinas de ensamblador que se llaman desde C.
global posCurScreenP2, showMinesP2  , updateBoardP2, moveCursorP2
global mineMarkerP2  , searchMinesP2, checkEndP2   , playP2	 

;Variables globales definidas en C.
extern marks, mines

;Funciones de C que se llaman desde ensamblador
extern clearScreen_C, gotoxyP2_C, getchP2_C, printchP2_C
extern printBoardP2_C, printMessageP2_C


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ATENCIÓN: Recordad que las variables y los Parámetros de tipo 'char',
;;   en ensamblador se tienen que asignar a registros de tipo  
;;   BYTE (1 byte): al, ah, bl, bh, cl, ch, dl, dh, sil, dil, ..., r15b
;;   las de tipo 'int' se tienen que assignar a registres de tipo 
;;   DWORD (4 bytes): eax, ebx, ecx, edx, esi, edi, ...., r15d
;;   las de tipo 'long' se tienen que assignar a registres de tipo 
;;   QWORD (8 bytes): rax, rbx, rcx, rdx, rsi, rdi, ...., r15
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Las subrutinas en ensamblador que tenéis que implementar son:
;;   posCurScreenP2, showMinesP2,  updateBoardP2, moveCursorP2
;;   calcIndexP2, mineMarkerP2, searchMinesP2, checkEndP2
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Esta subrutina se da hecha. NO LA PODÉIS MODIFICAR.
; Situar el cursor en una fila y una columna de la pantalla
; en función de la fila (edi) y de la columna (esi) recibidos como 
; parámetro llamando a la función gotoxyP2_C.
; 
; Variables globales utilizadas:	
; Ninguna
; 
; Parámetros de entrada: 
; rdi(edi): (rowScreen) Fila
; rsi(esi): (colScreen) Columna;
; 
; Parámetros de salida : 
; Ninguno
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gotoxyP2:
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

   ; Cuando llamamos a la función gotoxyP2_C(int rowScreen, int colScreen) desde ensamblador
   ; el primer  parámetro (rowScreen) se tiene que pasar por el registro rdi(edi), y 
   ; el segundo parámetro (colScreen) se tiene que pasar por el registro rsi(esi).
   call gotoxyP2_C
 
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
; Mostrar un carácter (dil) en pantalla, recibido como parámetro, 
; en la posición donde está el cursor llamando a la función printchP2_C.
; 
; Variables globales utilizadas:	
; Ninguna
; 
; Parámetros de entrada: 
; rdi(dil): (c) carácter que queremos mostrar
; 
; Parámetros de salida : 
; Ninguno
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
printchP2:
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

   ; Cuando llamamos a la función printchP2_C(char c) desde ensamblador, 
   ; el parámetro (c) se tiene que pasar por el registro rdi(dil).
   call printchP2_C
 
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
; Leer una tecla y retornar el carácter asociado (al) sin
; mostrarlo en pantalla, llamando a la función getchP2_C
; 
; Variables globales utilizadas:	
; Ninguna
; 
; Parámetros de entrada: 
; Ninguno
; 
; Parámetros de salida : 
; rax(al): (c) carácter que leemos de teclado
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getchP2:
   push rbp
   mov  rbp, rsp
   ;guardamos el estado de los registros del procesador porque
   ;las funciones de C no mantienen el estado de los registros.
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

   mov rax, 0
   ; llamamos a la función getchP2_C desde ensamblador, 
   ; retorna sobre el registro rax(al) el carácter leído.
   call getchP2_C
 
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
   
   mov rsp, rbp
   pop rbp
   ret 


;;;;;
; Posicionar el cursor en pantalla dentro del tablero, en función 
; del índice de la matrix (indexMat), posición del cursor dentro del tablero.
; Para calcular la posición del cursor en pantalla utilizar 
; estas fórmulas:
; rowScreen=((indexM/10)*2)+7
; colScreen=((indexM%10)*4)+7
; Para posicionar el cursor se tiene que llamar la subrutina gotoxyP2
; implementando correctamente el paso de parámetros.
; 
; Variables globales utilizadas:	
; Ninguna
; 
; Parámetros de entrada : 
; rdi :(indexM) Índice para acceder a las matrices mines y marks desde ensamblador.
; 
; Parámetros de salida: 
; Ninguno
;;;;;  
posCurScreenP2:
	push rbp
	mov  rbp, rsp
	
	push rax
	push rbx
	push rdx
	push rdi
	push rsi
	
	;-------------------------------------------------------------------
	;Inicializar
	mov rax, rdi		;copiamos en el registro rax el valor pasado por rdi
	mov rbx, 10			;Inicializamos rbx con el valor del divisor.
	mov rdx, 0			;Inicializamos rdx a 0;
	;-------------------------------------------------------------------
	;Operaciones
	div rbx				; División de rax entre el valor del registro rbx,
						; obtenemos el cociente en el registro rax
						; y el resto en el registro rdx. (indexM/10) y (indexM%10)
	shl rax, 1			; Desplazamos los bits una posición a la izquierda
						; que equivale a multiplicar por dos. ((indexM/10)*2)
	add rax, 7			; Por último se le suma 7. rowScreen=((indexM/10)*2)+7
	mov rdi, rax 		; copiamos el valor al registro rdi que es uno
						; de los dos valores que recibirá la función gotoxyP2
						; El registro rdi equivale a la variable rowScreen
	
	shl rdx, 2			; Desplazamos los bits dos posiciones a la izquierda
						; que equivale a multiplicar por 4. ((indexM%10)*4)
	add rdx, 7			; Por último se le suma 7. colScreen=((indexM%10)*4)+7
	mov rsi, rdx 		; copiamos el valor al registro rdi que es uno
						; de los dos valores que recibirá la función gotoxyP2
						; El registro rdi equivale a la variable colScreen  
	
	call gotoxyP2		;Llamamos a la rutina gotoxyP2 para colocar el
						;cursor en las coordenadas resultantes.
	
	;-------------------------------------------------------------------
	; Finalizamos la función devolviendo la pila y los registros
	; a su estado original	
	pop rsi
	pop rdi
	pop rdx
	pop rbx
	pop rax
				
	mov rsp, rbp
	pop rbp
	ret


;;;;;
; Convierte el valor del Número de minas que quedan por marcar (numMines)
; que se recibe como parámetro (entre 0 y 99) a dos caracteres ASCII. 
; Se tiene que dividir el valor (numMines) entre 10, el cociente 
; representará las decenas y el residuo las unidades, y después se
; tienen que convertir a ASCII sumando 48, carácter '0'.
; Mostrar los dígitos (carácter ASCII) de les decenas en la fila 27, 
; columna 24 de la pantalla y las unidades en la fila 27, columna 26.
; Para a posicionar el cursor se tiene que llamar a la subrutina gotoxyP2 y 
; para a mostrar los caracteres a la subrutina printchP2, implementando 
; correctamente el paso de parámetros
; 
; Variables globales utilizadas:
; Ninguna
; 
; Parámetros de entrada : 
; rdi(edi) : (nMines) Número de minas que quedan por marcar.
; 
; Parámetros de salida: 
; Ninguno
;;;;;
showMinesP2:
	push rbp
	mov  rbp, rsp
		
	; Guardamos los registros en la pila para poder trabajar
	; con ellos sin perder información.
	push rax	; Registro para el dividendo y a la vez cociente de la división
	push rdx	; Registro para almacenar el resto de la división
	push rbx	; Registro para almacenar el divisor
	push rdi	; registro con el parametro de entrada y a la vez servirá
				; como parámetro de salida al igual que el registro rsi.
	push rsi
	
	mov rax, 0 	;Inicializamos el registro a 0
	mov eax, edi ;Inicializamos el registro con el valor de nMines almacenado en edi
	mov edx, 0 	;Inicializamos el registro a 0
	
	;-------------------------------------------------------------------
	;Calculamos las decenas (cociente, registro al (1 byte para char)) 
	;y  las unidades (resto, registro dl (1 byte para char))
	mov ebx, 10	;El divisor
	div ebx		;Se divide el dividendo, eax entre ebx, es decir,
				;nMines/10
				
	;-------------------------------------------------------------------			
	;Ahora convertimos el cociente (decenas) y el resto (unidades)			
	;sumando al resultado el caracter "0", ya que en el código ASCII
	;los caracteres de números son correlativos
	add al, "0"
	add dl, "0"
	
	;-------------------------------------------------------------------
	;Mostramos los caracteres por pantalla en las posiciones indicadas
	;para cada valor (decenas y unidades)
	mov edi, 27	;Posición del cursor en la fila 27
	mov esi, 24	;Posición el cursor en la columna 24
	call gotoxyP2 				;Colocamos el puntero en las coordenadas
	
	push rdi
	mov dil, al		;Copiamos el valor de las decenas en el registro
					;dil que se pasará como parametro a la función printchP2
	call printchP2				;y lo mostramos en pantalla
	pop rdi
	
	;Para las unidades desplazamos el curso hacia la derecha
	mov esi, 26
	call gotoxyP2				;Y colocamos el cursor en las nuevas coordenadas
	
	push rdi
	mov dil, dl		;Copiamos el valor de las unidades en el registro 
					;dil que se pasará como parametro a la función printchP2
	call printchP2				;y lo mostramos en pantalla
	pop rdi
	
	mov edi, eax	;le devolvemos el valor nMines
	
	;-------------------------------------------------------------------
	; Finalizamos la función devolviendo la pila y los registros
	; a su estado original
	pop rsi
	pop rdi
	pop rbx
	pop rdx
	pop rax
	
	mov rsp, rbp
	pop rbp
	ret


;;;;;
; Actualizar el contenido del Tablero de Juego con los datos de la 
; matriz (marks) y el número de minas que quedan por marcar que  
; se recibe como parámetro y llamamos (nMines).
; Se tiene que recorrer toda la matriz (marks), y para cada elemento 
; de la matriz posicionar el cursor en pantalla y mostrar los caracteres 
; de la matriz. 
; Después mostrar el valor de (nMines) en la parte inferior del tablero.
; Para posicionar el cursor se tiene que llamar a la subrutina gotoxyP2,
; para mostrar los caracteres se tiene que llamar a la subrutina printchP2
; y para mostrar el número de minas se tiene que llamar a la subrutina
; ShowMinesP2, implementando correctamente el paso de parámetros.
; 
; Variables globales utilizadas:
; marks  : Matriz con las minas marcadas y las minas de las abiertas.
; 
; Parámetros de entrada : 
; rsi(esi)!!!! : (nMines) Número de minas que quedan por marcar.
; 
; Parámetros de salida: 
; Ninguno
;;;;;
updateBoardP2:
	push rbp
	mov  rbp, rsp
	
	;-------------------------------------------------------------------
	; Guardamos los registros en la pila para poder trabajar
	; con ellos sin perder información.
	push rax
	push rbx
	push rcx
	push rdx
	push rsi
	push rdi
	
	
	;-------------------------------------------------------------------
	;Inicializamos las variables
	mov eax, edi	;Registro para guardar nMines
	mov ebx, 0		;Registro para el indice de la matriz marks.
	mov ecx, 0		;Registro para el indice i de la matriz marks
	mov edx, 0 		;Registro para el indice j de la matriz marks

	;-------------------------------------------------------------------
	;copiamos el valor 7 en la variable rowScreen
	mov edi, 7
		
	;-------------------------------------------------------------------
	;Iniciamos el primer bucle for para recorrer las filas de la matriz
	updateBoardP2rowFor:	;equivale a for (i=0;i<DimMatrix;i++)
		cmp ecx, DimMatrix
		jge updateBoardP2rowForEnd ;si rbx>= DimMatrix acaba este ciclo
		
		mov esi, 7			;colScreen = 7
		mov edx, 0			;reinicio del indice j
	
	;-------------------------------------------------------------------
	;Con este segundo bucle for recorreremos las columnas de cada fila
			updateBoardP2colFor: ;Equivale a for (j=0;j<DimMatrix;j++)
				cmp edx, DimMatrix
				jge updateBoardP2colForEnd ;Si rcx>= DimMatrix se acaba
										   ;este ciclo
				call gotoxyP2
				
				push rdi 
				mov dil, BYTE [marks+ebx]   ;Copiamos en la variable dil
									;el valor almacenado en el indice rdx
				call printchP2	;Y lo mostramos en pantalla
				pop rdi
				
				add esi, 4	;colScreen = colScreen +4
				
				;-------------------------------------------------------
				;Aquí realizamos la última parte del bucle for que es
				;incrementar el indice usado en el bucle e iniciar el 
				;siguiente ciclo del bucle
				
				inc edx	;Incrementamos el indice j del for
				inc ebx ;Incrementamos el indice de la matriz marks.
				jmp updateBoardP2colFor ;Saltamos al siguiente ciclo del
										;bucle
			updateBoardP2colForEnd:		;Etiqueta de finalización del bucle
	;-------------------------------------------------------------------
	;Cuando finalizan todos los ciclos del bucle interior updateBoardP2colFor
	;podemos continuar con las sentencias restantes del bucle exterior
	;updateBoardP2rowFor
		add edi, 2	;rowScreen = rowScreen +2
		inc ecx						;Incrementamos la fila en uno para 
						;en el siguiente ciclo pasar a la siguiente.
		jmp updateBoardP2rowFor	;Saltamos al siguiente ciclo del bucle
								;updateBoardP2rowFor
	updateBoardP2rowForEnd:		;Etiqueta de finalización del bucle
	
	;-------------------------------------------------------------------
	;Por último, realizamos la llamada de la subrutina showMinesP2
	mov edi, eax		;restauramos el valor de nMines para pasarlo como
	call showMinesP2	;parametro con la llamada a showMinesP2
					
	;-------------------------------------------------------------------
	; Finalizamos la función devolviendo la pila y los registros
	; a su estado original
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
; Actualizar la posición del cursor en el tablero que tenemos indicada
; con la variable (indexM), que se recibe como parámetro, en función de
; la tecla pulsada (c), que también recibimos como parámetro.
; Si se sale fuera del tablero no actualizar la posición del cursor.
; (i:arriba, j:izquierda, k:abajo, l:derecha)
; Arriba y abajo: ( indexM = indexM +/- 10 ) 
; Derecha y izquierda:  ( indexM = indexM +/- 1 )  
; No se tiene que posicionar el cursor en pantalla.
;  
; Variables globales utilizadas:
; Ninguna
; 
; Parámetros de entrada : 
; rdi      : (indexM) Índice para acceder a las matrices mines y marks desde ensamblador.
; rsi(sil) : (c) Carácter leído de teclado 
; 
; Parámetros de salida: 
; rax      ; (indexMat) Índice para acceder a las matrices mines y marks desde ensamblador.
;;;;;
moveCursorP2:
	push rbp
	mov  rbp, rsp
	
	; Guardamos los registros en la pila para poder trabajar
	; con ellos sin perder información.
	push rax	; Registro para el dividendo y a la vez cociente de la división
	push rdx	; Registro para almacenar el resto de la división
	push rbx	; Registro para almacenar el divisor
	push rsi
	push rdi
	
	
	;-------------------------------------------------------------------
	;Inicializar
	mov rax, rdi		; Copiamos el valor de indexM en nuestro
						;registro para  calcular las coordenadas en el tablero.
	mov rbx, 0
	mov rdx, 0
	mov rbx, 10			;Inicializamos rbx con el valor del divisor.
	
	
	;-------------------------------------------------------------------
	;Operaciones
	div rbx				; División de rax entre el valor del registro rbx,
						; obtenemos el cociente en el registro rax
						; y el resto en el registro rdx. (indexM/10) y (indexM%10)
	
	;-------------------------------------------------------------------
	;En esta subrutina compararemos el valor almacenado en la variable
	;charac, y en consecuencia modificaremos la variable indexM
	
	cmp sil, "i"	;case 'i': //arriba
	je moveCursorP2Up
	cmp sil, "j"	;case 'j': //izquierda
	je moveCursorP2Left
	cmp sil, "k"	;case 'k': //abajo
	je moveCursorP2Down
	cmp sil, "l"	;case 'l': //derecha
	je moveCursorP2Right
	
	;-------------------------------------------------------------------
	;Una vez leído el caracter y comparado, definimos las acciones de 
	;cada posible caso.
	moveCursorP2Up:				;mover el cursor hacia arriba
		cmp rax, 0 				;if(row>0) Comprobamos que no se salga 
		jle moveCursorP2End		;fuera del tablero.
		sub rdi, 10				;indexM=indexM-10;
		jmp moveCursorP2End
	
	moveCursorP2Left:			;mover el cursor hacia la izquierda
		cmp rdx, 0 				;if(col>0) Comprobamos que no se salga 
		jle moveCursorP2End		;fuera del tablero.
		dec rdi					;indexM--;
		jmp moveCursorP2End
		
	moveCursorP2Down:			;mover el cursor hacia abajo			
		cmp rax, DimMatrix-1	;if (row<DimMatrix-1) Comprobamos que 
		jge moveCursorP2End		;no se salga fuera del tablero.
		add rdi, 10				;indexM=indexM+10;
		jmp moveCursorP2End
		
	moveCursorP2Right:			;mover el cursor hacia la derecha
		cmp rdx, DimMatrix-1	;if (col<DimMatrix-1) Comprobamos que 
		jge moveCursorP2End		;no se salga fuera del tablero.
		inc rdi					;indexM++;
		jmp moveCursorP2End
	
	moveCursorP2End:
	
	mov rax, rdi				;copiamos el valor de indexM al registro rax
								;que se usará como parametro de salida.
	
	;-------------------------------------------------------------------
	; Finalizamos la función devolviendo la pila y los registros
	; a su estado original sin devolver a su estado original a rax, ya que
	; es el parametro de salida
	pop rdi
	pop rsi
	pop rbx
	pop rdx
		
	mov rsp, rbp
	pop rbp
	ret


;;;;;  
; Marcar/desmarcar una mina en la matriz (marks) en la posición actual 
; del cursor, indicada por el vector(rowcol), que es recibe como 
; parámetro (fila (rowcol[0]) i columna (rowcol[1])).
; Si en aquella posición de la matriz (marks) hay un espacio en blanco
; y no hemos marcado todas las minas, marcamos una mina poniendo una 
; 'M' y decrementamos el número de minas que quedan por marcar (numMines), 
; que se recibe como parámetro, si en aquella posición de la matriz 
; (marks) hay una 'M', pondremos un espacio (' ') y incrementaremos el
; número de minas que quedan por marcar.
; Si hay otro valor no cambiaremos nada.
; Retornar el número de minas (nMines) que quedan por marcar actualizado.
; ; No se tiene que mostrar la matriz, sólo actualizar la matriz (marks) 
; y la variable (nMines).
; 
; Variables globales utilizadas:
; marks    : Matriz con las minas marcadas y las minas de las abiertas.
; 
; Parámetros de entrada: 
; rdi      : (indexM) Índice para acceder a las matrices mines y marks desde ensamblador.
; rsi(esi) : (nMines) Número de minas que quedan por marcar.
; 
; Parámetros de salida: 
; rax(eax) : Número de minas que quedan por marcar.
;;;;;  
mineMarkerP2:
	push rbp
	mov  rbp, rsp

	;-------------------------------------------------------------------
	;Guardamos el contenido del registro rsi en la pila, ya que lo usaremos
	;como indice para movernos por la matriz marks. Utilizaremos la dirección
	;de la matriz marks y le sumaremos el desplazamiento en bytes de IndexM
	
	push rax
	push rsi
	push rdi
	
	mov rax, rdi	;Copiamos el valor de indexM en el 
								;registro de 8 bytes rsi.
								
	;-------------------------------------------------------------------
	;Primero hacemos el primer if de la función mineMarkerP2_C y su else
	;para luego anidar un if dentro del else.
	cmp BYTE [marks + rax], " "	;if (marks[rowMat][colMat] == ' '
	jne mineMarkerP2Unmarked
	cmp esi, 0
	jle mineMarkerP2Unmarked	; && numMines > 0) 
	
	;-------------------------------------------------------------------
	;Si esa posición está vacía (" ") y numMines > 0
	mov BYTE [marks + rax], "M"	;marks[rowMat][colMat] = 'M'; //Marcar
	dec esi
	jmp mineMarkerP2End
	
	;-------------------------------------------------------------------
	;En el caso que las condiciones no se cumplan se pasaría directamente
	;a este bloque que es el else del primer if
	mineMarkerP2Unmarked:
		;---------------------------------------------------------------
		;Aquí anidamos el if dentro del else
		cmp BYTE [marks + rax], "M"	;
		jne mineMarkerP2End
		mov BYTE [marks + rax], " ";
		inc esi
		
	mineMarkerP2End:
	
	mov rax, rsi
	
	;-------------------------------------------------------------------
	; Finalizamos la función devolviendo la pila y los registros
	; a su estado original, excepto el parametro de salida rax
	pop rdi
	pop rsi
	
	mov rsp, rbp
	pop rbp
	ret
		

;;;;;  
; Abrir casilla. Mirar cuantas minas hay alrededor de la posición 
; actual del cursor, indicada con la variable (indexM), que se recibe como 
; parámetro, de la matriz (mines).
; Si en la posición actual de la matriz (marks) hay un espacio (' ') 
;   Mirar si en la matriz (mines) hay una mina ('*').
;   Si hay una mina cambiar el estado (state), que se recibe como 
;     parámetro a 3 "Explosión", para salir.
;	 Si no, contar cuantas minas hay alrededor de la posición 
;     actual y actualizar la posición del matriz (marks) con 
;     el número  de minas (carácter ASCII del valor, para hacerlo, hay 
;     que sumar 48 ('0') al valor).
; Si no hay un espacio, quiere decir que hay una mina marcada ('M') o 
; la casilla ya está abierta (hay el número de minas que ya se ha 
; calculado anteriormente), no hacer nada.
; Retornar el estado del juego actualizado.
; No se tiene que mostrar la matriz.
;  
; Variables globales utilizadas:
; marks  : Matriz con las minas marcadas y las minas de las abiertas.
; mines  : Matriz donde ponemos las minas.
; 
; Parámetros de entrada : 
; rdi      : (indexM) Índice para acceder a las matrices mines y marks desde ensamblador.
; rsi(esi) : (status) Estado del juego. 
; 
; Parámetros de salida: 
; rax(eax) : (status) Estado del juego. 
;;;;;  
searchMinesP2:
	push rbp
	mov  rbp, rsp

	; Guardamos los registros en la pila para poder trabajar
	; con ellos sin perder información.
	push rax	; Registro para el dividendo y a la vez cociente de la 
				;división (row)
	push rdx	; Registro para almacenar el resto de la división(col)
	push rbx	; Registro para almacenar el divisor
	push rcx	; valor de status
	push rsi
	push rdi
	
	
	;-------------------------------------------------------------------
	;Inicializar
	mov rax, rdi		; Copiamos el valor de indexM en nuestro
						;registro para  calcular las coordenadas en el tablero.
	mov rdx, 0
	mov rbx, 10			;Inicializamos rbx con el valor del divisor.
	mov ecx, esi		;guardamos el estado del juego en el registro ecx
	
	;-------------------------------------------------------------------
	;Operaciones
	div rbx				; División de rax entre el valor del registro rbx,
						; obtenemos el cociente en el registro rax
						; y el resto en el registro rdx. Fila(indexM/10) y Columna(indexM%10)
	mov esi, eax					
	mov al, '0'			;inicializamos el registro para almacenar un caracter
	
	;*********************************************************
	;Comprobar valor en una posición (primer y segundo if en la función
	;searchMinesP2_C
	
	searchMinesP2Marks:
	cmp BYTE[marks+edi], ' '	;comprobamos si esa posición está cerrada o sin marcar
	je searchMinesP2Mines		;if (marks[row][col]==' ')
	jmp searchMinesP2End		;Si está marcada o abierta no hacemos nada
	
	searchMinesP2Mines:
	cmp BYTE[mines+edi], ' '
	je searchMinesP2UpLeft
								;if (mines[row][col]!=' ') 
	mov ecx, 3					;status = 3;
	jmp searchMinesP2End
	
	;**********************************************************
	; Comprobación de posiciones contiguas
	
	searchMinesP2UpLeft:
	cmp esi, 0						;if (row > 0)
	jle searchMinesP2LeftCenter
	cmp edx, 0						;if (col > 0)
	jle searchMinesP2UpCenter
	mov ebx, edi
	sub ebx, 11						;restandole 11 a indexM accedemos a la 
									;posición de la esquina superior izquierda
	cmp BYTE[mines+ebx], '*'		;if (mines[row-1][col-1]=='*')
	jne searchMinesP2UpCenter
	inc al							;digit++
	
	searchMinesP2UpCenter:
	mov ebx, edi
	sub ebx, 10						;restandole 10 a indexM accedemos a la 
									;posición que se encuentra encima
	cmp BYTE[mines+ebx], '*'		;if (mines[row-1][col]=='*')
	jne searchMinesP2UpRight
	inc al							;digit++
	
	searchMinesP2UpRight:
	cmp edx, DimMatrix-1			;if (col < DimMatrix-1)
	jge searchMinesP2LeftCenter		
	mov ebx, edi					
	sub ebx, 9						;;restandole 9 a indexM accedemos a la 
									;posición de la esquina superior derecha
	cmp BYTE[mines+ebx], '*'		;if (mines[row-1][col+1]=='*')
	jne searchMinesP2LeftCenter
	inc al							;digit++
	
	searchMinesP2LeftCenter:
	cmp edx, 0						;if (col > 0)
	jle searchMinesP2RightCenter
	mov ebx, edi
	sub ebx, 1
	cmp BYTE[mines+ebx], '*'		;if (mines[row][col-1]=='*')
	jne searchMinesP2RightCenter
	inc al							;digit++
	
	searchMinesP2RightCenter:
	cmp edx, DimMatrix-1			;if (col < DimMatrix-1)
	jge searchMinesP2DownLeft
	mov ebx, edi
	add ebx,1
	cmp BYTE[mines+ebx], '*'		;if (mines[row][col+1]=='*')
	jne searchMinesP2DownLeft
	inc al							;digit++
	
	searchMinesP2DownLeft:
	cmp esi, DimMatrix-1			;if (row < DimMatrix-1)
	jge searchMinesP2nMines
	cmp edx, 0						;if (col > 0)
	jle searchMinesP2DownCenter
	mov ebx, edi
	add ebx, 9
	cmp BYTE[mines+ebx], '*'		;if (mines[row+1][col-1]=='*')
	jne searchMinesP2DownCenter
	inc al							;digit++
	
	searchMinesP2DownCenter:
	mov ebx, edi
	add ebx, 10
	cmp BYTE[mines+ebx], '*'		;if (mines[row+1][col]=='*')
	jne searchMinesP2DownRight
	inc al							;digit++
	
	searchMinesP2DownRight:
	cmp edx, DimMatrix-1			;if (col < DimMatrix-1)
	jge searchMinesP2nMines
	mov ebx, edi
	add ebx, 11
	cmp BYTE[mines+ebx], '*'		;if (mines[row+1][col+1]=='*')
	jne searchMinesP2nMines
	inc al							;digit++
	
	searchMinesP2nMines:
	mov BYTE[marks+edi], al			;marks[row][col] = digit+'0';
	
	searchMinesP2End
	mov eax, ecx					;copiamos el valor que queremos pasar como
									;parametro de salida en la variable rax(eax)
	pop rdi
	pop rsi
	pop rcx
	pop rbx
	pop rdx
	
	mov rsp, rbp
	pop rbp
	ret


;;;;;  
; Verificar si hemos marcado todas las minas (numMines=0), que se reciben
; como parámetro y hemos abierto o marcado con una mina todas las otras 
; casillas y no hay ningún espacio en blanco (' ') en la matriz (marks),
; si es así, cambiar el estado (state) que se recibe como parámetro, a 
; 2 "Gana la partida".
; Retornar el estado del juego actualizado (status).
; 
; Variables globales utilizadas:	
; marks  : Matriz con las minas marcadas y las minas de las abiertas.
; 
; Parámetros de entrada : 
; rdi(edi) : Número de minas que quedan por marcar.
; rsi(esi) : Estado del juego. 
; 
; Parámetros de salida: 
; rax(eax) : Estado del juego. 
; 
;;;;;  
checkEndP2:
	push rbp
	mov  rbp, rsp

	
	push rax
	push rbx
	push rsi
	push rdi
	
	mov eax, esi		;Guardamos el estado actual del juego en el registro
						;que usaremos como parametro de salida
	;***************************************************************
	;Comprobamos si se han marcado todas las minas
	cmp edi, 0			;if (nMines == 0)
	jg checkEndP2End
	
	mov rbx, 0			;usaremos el registro como indice para el bucle for
	
	checkEndP2For:
	cmp BYTE[marks+ebx], ' '	;if (marks[i][j] == ' ')
	je checkEndP2End
	
	inc ebx
	cmp ebx, SizeMatrix
	jl checkEndP2For
	
	mov eax, 2
	
	checkEndP2End:
	
	pop rdi
	pop rsi
	pop rbx
	 
	mov rsp, rbp
	pop rbp
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Esta subrutina se da hecha. NO LA PODÉIS MODIFICAR.
; Muestra un mensaje debajo del tablero llamando la función printMessageP2_C 
; segun el valor de la varaible (status) recibida como paràmetro.
; (status) 0: Salir, hemos pulsado la tecla 'ESC' para salir.
;          1: Continuamos jugando.
;          2: Gana, se han marcado todas las minas.
; Se espera que se pulse una tecla para continuar.
;  
; Variables globales utilizadas:	
; Ninguna
; 
; Parámetros de entrada: 
; rsi(esi) : (staus) Estado del juego.
; 
; Parámetros de salida : 
; Ninguno
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  

printMessageP2:
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

   ; Cundo llamamos a la función printMessageP2_C(int status) desde ensamblador, 
   ; el parámetro (status) se tiene que passar por el registro rdi(edi).
   call printMessageP2_C
 
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
; Juego del Buscaminas
; Subrutina principal del juego
; Esta subrutina se da hecha. NO LA PODÉIS MODIFICAR.
; Permite jugar al juego del buscaminas llamando a todas las funcionalidades.
;
; Pseudo código:
; Inicializar estado del juego, (state=1)
; Inicializar fila y columna, posición inicial, (rowcol[0]=4) i (rowcol[1]=4)
; Mostrar el tablero de juego (llamando la función PrintBoardP2_C).
; Mientras (state=1) hacer:
;   Actualizar el contenido del Tablero de Juego y el número de minas
;     que quedan por marcar (llamar la subrutina updateBoardP2).
;   Posicionar el cursor dentro del tablero (llamar la subrutina posCurScreenP2).
;   Leer una tecla.
;   Según la tecla leída llamaremos a la función correspondiente.
;     - ['i','j','k' o 'l']       (llamar a la subrutina MoveCursorP2).
;     - 'x'                       (llamar a la subrutina MineMarkerP2).
;     - '<espace>'(codi ASCII 32) (llamar a la subrutina SearchMinesP2).
;     - '<ESC>'  (codi ASCII 27) poner (state = 0) para salir.   
;   Verificar si hemos marcado todas las minas y si hemos abierto todas  
;     las otras casillas (llamar a la subrutina CheckEndP2).
; Fin mientras.
; Salir:
;   Actualizar el contenido del Tablero de Juego y el número de minas que 
;   quedan por marcar (llamar a la subrutina updateBoardP2_C).
;   Mostrar el mensaje de salida que corresponda (llamar a la función
;   printMessageP2_C).
; Se acaba el juego.
; 
; Variables globales utilizadas:	
; Ninguna
; 
; Parámetros de entrada : 
; rdi(edi) : (nMines) Número de minas que quedan por marcar.
; 
; Parámetros de salida: 
; rax(eax) : (nMines) Número de minas que quedan por marcar.
;;;;;  
playP2:
   push rbp
   mov  rbp, rsp

   push rbx
   push rcx
   push rdx
   push rdi
   push rsi

   push rdi
   call printBoardP2_C   ;printBoard2_C();
   pop  rdi
   
   mov rbx, 54           ;indexMat= 54; //Posición inicial del cursor.
   mov ecx, edi          ;int numMines = nMines; 
   mov edx, 1            ;int state = 1;

   playP2_Loop:          ;bucle principal del juego
   cmp  edx, 1
   jne  playP2_PrintMessage

   mov  edi, ecx
   call updateBoardP2    ;updateBoardP2_C(numMines);

   mov  rdi, rbx
   call posCurScreenP2   ;posCurScreenP2_C(indexMat); 

   call getchP2     ; Lleer una tecla y dejarla en el regsitro al.
		
   cmp al, 'i'		; mover cursor arriba
   je  playP2_MoveCursor
   cmp al, 'j'		; mover cursor izquierda
   je  playP2_MoveCursor
   cmp al, 'k'		; mover cursor derecha
   je  playP2_MoveCursor
   cmp al, 'l'		; mover cursor abajo
   je  playP2_MoveCursor
   cmp al, 'm'		; Marcar una mina
   je  playP2_MineMarker
   cmp al, ' '		; Mirar minas
   je  playP2_SearchMines
   cmp al, 27		; Salir del programa
   je  playP2_Exit
   jmp playP2_Check  
    
   playP2_MoveCursor:
   mov  rdi, rbx
   mov  sil, al 
   call moveCursorP2     ;indexMat = moveCursorP2_C(indexMat, c);
   mov  rbx, rax
   jmp  playP2_Check

   playP2_MineMarker:
   mov  rdi, rbx
   mov  esi, ecx
   call mineMarkerP2     ;numMines = mineMarkerP2_C(indexMat, numMines);
   mov  ecx, eax
   jmp  playP2_Check

   playP2_SearchMines:
   mov  rdi, rbx
   mov  esi, edx
   call searchMinesP2    ;state = searchMinesP2_C(indexMat, state);
   mov  edx, eax
   jmp  playP2_Check

   playP2_Exit:
   mov  edx, 0            ;state = 0;
 
   playP2_Check:
   mov  edi, ecx
   mov  esi, edx
   call checkEndP2       ;state = checkEndP2_C(numMines, state);
   mov  edx, eax
   
   jmp  playP2_Loop

   playP2_PrintMessage:
   mov  edi, ecx
   call updateBoardP2    ;updateBoardP2_C(numMines);

   mov  edi, edx
   push rcx
   call printMessageP2_C ;printMessageP2_C(state);
   pop  rcx
   
   playP2_End:
   mov  eax, ecx

   pop  rsi
   pop  rdi
   pop  rdx
   pop  rcx
   pop  rbx
   
   mov rsp, rbp
   pop rbp
   ret
