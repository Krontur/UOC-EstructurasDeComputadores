/**
 * Implementación en C de la práctica, para que tengáis una
 * versión funcional en alto nivel de todas les funciones que tenéis 
 * que implementar en ensamblador.
 * Desde este código se hacen las llamadas a les subrutinas de ensamblador. 
 * ESTE CÓDIGO NO SE PUEDE MODIFICAR Y NO HAY QUE ENTREGARLO.
 **/ 
 
#include <stdio.h>
#include <termios.h>    //termios, TCSANOW, ECHO, ICANON
#include <unistd.h>     //STDIN_FILENO

extern int developer;	//Variable declarada en ensamblador que indica el nombre del programador.

/**
 * Constantes
 */
#define DimMatrix  10    //dimensión de la matriz
#define SizeMatrix DimMatrix*DimMatrix  //=100

/**
 * Definición de variables globales
 */
long rowScreen;     //Fila para posicionar el cursor en pantalla.
long colScreen;     //Columna para posicionar el cursor en pantalla
long rowMat;		//Fila para acceder a las matrices mines y marks.
long colMat;	    //Columna para acceder a las matrices mines y marks.
long indexMat; 		//Índice para acceder a las matrices mines y marks desde ensamblador.
char charac;        //Carácter leído de teclado y para escribir en pantalla.

// Matriz 10x10 donde ponemos las minas (Hay 20 minas marcadas)
char mines[DimMatrix][DimMatrix] = { {' ',' ',' ',' ',' ',' ',' ',' ',' ',' '},
                                     {' ',' ',' ',' ',' ',' ',' ',' ',' ',' '},
                                     {' ','*',' ',' ',' ',' ',' ',' ',' ',' '},
                                     {' ',' ',' ','*',' ','*',' ',' ',' ',' '},
                                     {' ','*','*','*','*','*','*','*',' ',' '},
                                     {' ',' ',' ','*',' ','*',' ',' ',' ',' '},
                                     {' ',' ','*','*','*','*','*','*',' ',' '},
                                     {' ',' ',' ','*',' ',' ',' ',' ',' ',' '},
                                     {' ',' ',' ',' ',' ',' ',' ',' ',' ',' '},
                                     {' ',' ',' ',' ',' ',' ',' ',' ',' ','*'} };

// Matriz 10x10 donde se indican las minas marcadas 'M' (Hay 2 minas marcadas)
// y el número de minas de las posiciones abiertas.(Hay 4 posiciones abiertas)              
char marks[DimMatrix][DimMatrix] = { {'0',' ',' ',' ',' ',' ',' ',' ',' ',' '},
                                     {'1',' ',' ',' ',' ',' ',' ',' ',' ',' '},
                                     {'1','M',' ',' ',' ',' ',' ',' ',' ',' '},
                                     {'2',' ',' ',' ',' ',' ',' ',' ',' ',' '},
                                     {' ',' ',' ',' ',' ',' ',' ',' ',' ',' '},
                                     {' ',' ',' ',' ',' ',' ',' ',' ',' ',' '},
                                     {' ',' ',' ',' ',' ',' ',' ',' ',' ',' '},
                                     {' ',' ',' ',' ',' ',' ',' ',' ',' ',' '},
                                     {' ',' ',' ',' ',' ',' ',' ',' ',' ',' '},
                                     {' ',' ',' ',' ',' ',' ',' ',' ',' ','M'} };

int numMines = 18; 	// Número de minas que quedan por marcar.
                    
int state    = 1;	// 0: Salimos, hemos pulsado la tecla 'ESC' para salir del juego.
					// 1: Continuamos jugando.
					// 2: Gana la partida, se han marcado todas las minas.
					

/**
 * Definición de las subrutinas de ensamblador que se llaman desde C
 */
extern void posCurScreenP1();
extern void showMinesP1();
extern void updateBoardP1();
extern void moveCursorP1();
extern void mineMarkerP1();
extern void checkMinesP1();
extern void playP1();

/**
 * Definición de les funciones de C
 */
void clearscreen_C();
void gotoxyP1_C();
void printchP1_C();
void getchP1_C();

void printMenuP1_C();
void printBoardP1_C();

void posCurScreenP1_C();
void showMinesP1_C();
void updateBoardP1_C();
void moveCursorP1_C();
void mineMarkerP1_C();
void checkMinesP1_C();

void printMessageP1_C();
void playP1_C();


/**
 * Borrar la pantalla
 * 
 * Variables globales utilizadas:	
 * Ninguna.
 * 
 * Esta función no se llama desde ensamblador
 * y no hay definida una subrutina de ensamblador equivalente.
 */
void clearScreen_C(){
	
    printf("\x1B[2J");
    
}


/**
 * Situar el cursor en una fila indicada por la variable (rowScreen) y 
 * en la columna indicada por la variable (colScreen) de la pantalla.
 * 
 * Variables globales utilizadas:	
 * rowScreen: Fila de la pantalla donde posicionamos el cursor.
 * colScreen: Columna de la pantalla donde posicionamos el cursor.
 * 
 * Se ha definido una subrutina en ensamblador equivalente 'gotoxyP1'  
 * para poder llamar a esta función guardando el estado de los registros 
 * del procesador. Esto se hace porque las funciones de C no mantienen 
 * el estado de los registros.
 */
void gotoxyP1_C(){
	
   printf("\x1B[%ld;%ldH",rowScreen,colScreen);
   
}


/**
 * Mostrar un carácter guardado en la variable (charc) en pantalla,
 * en la posición donde está el cursor.
 * 
 * Variables globales utilizadas:	
 * charac   : Carácter que queremos mostrar.
 * 
 * Se ha definido un subrutina en ensamblador equivalente 'printchP1' 
 * para llamar a esta función guardando el estado de los registros del 
 * procesador. Esto se hace porque las funciones de C no mantienen 
 * el estado de los registros.
 */
void printchP1_C(){

   printf("%c",charac);
   
}


/**
 * Leer una tecla y guardar el carácter asociado en la variable (charac)
 * sin mostrarlo en pantalla. 
 * 
 * Variables globales utilizadas:	
 * charac   : Carácter que leemos de teclado.
 * 
 * Se ha definido una subrutina en ensamblador equivalente 'getchP1' para
 * llamar a esta función guardando el estado de los registros del procesador.
 * Esto se hace porque las funciones de C no mantienen el estado de los 
 * registros.
 */
void getchP1_C(){

   static struct termios oldt, newt;

   /*tcgetattr obtener los parámetros del terminal
   STDIN_FILENO indica que se escriban los parámetros de la entrada estándard (STDIN) sobre oldt*/
   tcgetattr( STDIN_FILENO, &oldt);
   /*se copian los parámetros*/
   newt = oldt;

    /* ~ICANON para tratar la entrada de teclado carácter a carácter no como línea entera acabada en /n
    ~ECHO para que no se muestre el carácter leído.*/
   newt.c_lflag &= ~(ICANON | ECHO);          

   /*Fijar los nuevos parámetros del terminal para la entrada estándar (STDIN)
   TCSANOW indica a tcsetattr que cambie los parámetros inmediatamente. */
   tcsetattr( STDIN_FILENO, TCSANOW, &newt);

   /*Leer un carácter*/
   charac = (char) getchar();              
    
   /*restaurar los parámetros originales*/
   tcsetattr( STDIN_FILENO, TCSANOW, &oldt);
   
}



/**
 * Mostrar en pantalla el menú del juego y pide una opción.
 * Sólo acepta una de les opciones correctas del menú ('0'-'9')
 * 
 * Variables globales utilizadas:	
 * rowScreen: fila de la pantalla donde posicionamos el cursor.
 * colScreen: columna de la pantalla donde posicionamos el cursor.
 * charac   : carácter que leemos de teclado.
 * developer:((char *)&developer): variable definida en el código ensamblador.
 * 
 * Esta función no se llama desde ensamblador
 * y no hay definida una subrutina de ensamblador equivalente.
 */
void printMenuP1_C(){
	clearScreen_C();
    rowScreen = 1;
    colScreen = 1;
    gotoxyP1_C();
    printf("                                     \n");
    printf("            Developed by:            \n");
	printf("         ( %s )   \n",(char *)&developer);
    printf(" ___________________________________ \n");
    printf("|                                   |\n");
    printf("|          MENU MINESWEEPER         |\n");
    printf("|___________________________________|\n");
    printf("|                                   |\n");
    printf("|          1. posCurScreen          |\n");
    printf("|          2. showMines             |\n");
    printf("|          3. updateBoard           |\n");
    printf("|          4. moveCursor            |\n");
    printf("|          5. mineMarker            |\n");
    printf("|          6.                       |\n");
    printf("|          7. checkMines            |\n");
    printf("|          8. Play Game             |\n");
    printf("|          9. Play Game C           |\n");
    printf("|          0. Exit                  |\n");
    printf("|___________________________________|\n");
    printf("|                                   |\n");
    printf("|             OPTION:               |\n");
    printf("|___________________________________|\n"); 
    
    charac=' ';
    while (charac < '0' || charac > '9') {
      rowScreen = 21;
      colScreen = 23;
      gotoxyP1_C();           //posicionar el cursor
	  getchP1_C();            //Leer una opción
	  printchP1_C();		  //Mostrar opción
	}
	
}


/**
 * Mostrar el tablero de juego en pantalla. Las líneas del tablero.
 * 
 * Variables globales utilizadas:	
 * rowScreen: fila de la pantalla donde posicionamos el cursor.
 * colScreen: columna de la pantalla donde posicionamos el cursor.
 *  
 * Esta función se llama des de C y desde ensamblador,
 * y no hay definida una subrutina de ensamblador equivalente.
 */
void printBoardP1_C(){
   rowScreen = 1;
   colScreen = 1;
   gotoxyP1_C();
   printf(" _____________________________________________ \n");	//01
   printf("|                                             |\n");	//02
   printf("|                  MINESWEEPER                |\n");	//03
   printf("|_____________________________________________|\n");	//04
   printf("|     0   1   2   3   4   5   6   7   8   9   |\n");	//05
   printf("|   +---+---+---+---+---+---+---+---+---+---+ |\n");	//06
   printf("| 0 |   |   |   |   |   |   |   |   |   |   | |\n");	//07
   printf("|   +---+---+---+---+---+---+---+---+---+---+ |\n");	//08
   printf("| 1 |   |   |   |   |   |   |   |   |   |   | |\n");	//09
   printf("|   +---+---+---+---+---+---+---+---+---+---+ |\n");	//10
   printf("| 2 |   |   |   |   |   |   |   |   |   |   | |\n");	//11
   printf("|   +---+---+---+---+---+---+---+---+---+---+ |\n");	//12
   printf("| 3 |   |   |   |   |   |   |   |   |   |   | |\n");	//13
   printf("|   +---+---+---+---+---+---+---+---+---+---+ |\n");	//14
   printf("| 4 |   |   |   |   |   |   |   |   |   |   | |\n");	//15
   printf("|   +---+---+---+---+---+---+---+---+---+---+ |\n");	//16
   printf("| 5 |   |   |   |   |   |   |   |   |   |   | |\n");	//17
   printf("|   +---+---+---+---+---+---+---+---+---+---+ |\n");	//18
   printf("| 6 |   |   |   |   |   |   |   |   |   |   | |\n");	//19
   printf("|   +---+---+---+---+---+---+---+---+---+---+ |\n");	//20
   printf("| 7 |   |   |   |   |   |   |   |   |   |   | |\n");	//21
   printf("|   +---+---+---+---+---+---+---+---+---+---+ |\n");	//22
   printf("| 8 |   |   |   |   |   |   |   |   |   |   | |\n");	//23
   printf("|   +---+---+---+---+---+---+---+---+---+---+ |\n");	//24
   printf("| 9 |   |   |   |   |   |   |   |   |   |   | |\n");	//25
   printf("|   +---+---+---+---+---+---+---+---+---+---+ |\n");	//26
   printf("|     Mines to  Mark:  _ _                    |\n");	//27
   printf("|_____________________________________________|\n");	//28
   printf("|   (m)Mark Mine    (Space)Open  (ESC)Exit    |\n"); //29
   printf("|   (i)Up    (j)Left    (k)Down    (l)Right   |\n"); //30
   printf("|_____________________________________________|\n");	//31
   
}


/**
 * Posicionar el cursor en pantalla dentro del tablero, en función del 
 * índice de la matriz (indexMat), posición del cursor dentro del tablero.
 * Para calcular la posición del cursor en pantalla utilizar 
 * estas fórmulas:
 * rrowScreen=((indexMat/10)*2)+7
 * colScreen=((indexMat%10)*4)+7
 * Para posicionar el cursor se llama a la función gotoxyP1_C.
 * 
 * Variables globales utilizadas:	
 * indexMat : Índice para acceder a las matrices mines y marks desde ensamblador.
 * rowScreen: Fila de la pantalla donde posicionamos el cursor.
 * colScreen: Columna de la pantalla donde posicionamos el cursor.
 * 
 * Esta función no es llama desde ensamblador.
 * HAy una subrutina de ensamblador equivalente 'posCurScreenP1',  
 */
void posCurScreenP1_C() {

   rowScreen=((indexMat/10)*2)+7;
   colScreen=((indexMat%10)*4)+7;
   gotoxyP1_C();
   
}


/**
 * Convierte el valor del número de minas que quedan por marcar (numMines)
 * (entre 0 y 99) a dos caracteres ASCII. 
 * Se tiene que dividir el valor (numMines) entre 10, el cociente 
 * representará las decenas y el residuo las unidades, y después se
 * tienen que convertir a ASCII sumando 48, carácter '0'.
 * Mostrar los dígitos (carácter ASCII) de les decenas en la fila 27, 
 * columna 24 de la pantalla y las unidades en la fila 27, columna 26.
 * Para posicionar el cursor se llama a la función gotoxyP1_C y para 
 * mostrar los caracteres a la función printchP1_C.
 * 
 * Variables globales utilizadas:
 * rowScreen: Fila de la pantalla donde posicionamos el cursor.
 * colScreen: Columna de la pantalla donde posicionamos el cursor.
 * numMines : Número de minas que quedan para marcar.
 * charac   : Carácter a escribir a pantalla.
 * 
 * Esta función no se llama desde ensamblador.
 * Hay una subrutina de ensamblador equivalente 'showMinesP1',  
 */
 void showMinesP1_C() {
	
	charac = numMines/10;//Decenas
	charac = charac + '0';
	rowScreen = 27;
	colScreen = 24;
	gotoxyP1_C();   
	printchP1_C();

	charac = numMines%10;//Unidades
	charac = charac + '0';
	colScreen = 26; 
	gotoxyP1_C();   
	printchP1_C();
	
}


/**
 * Actualizar el contenido del Tablero de Juego con los datos de la 
 * matriz (marks) y el número de minas que quedan por marcar.
 * Se tiene que recorrer toda la matriz (marks), y para cada elemento 
 * de la matriz posicionar el cursor en pantalla y mostrar los caracteres 
 * de la matriz. 
 * Después mostrar el valor de (numMines) en la parte inferior del tablero.
 * Para posicionar el cursor se llama la función gotoxyP1_C, 
 * para a mostrar los caracteres se llama la función printchP1_C y para 
 * mostrar (numMines) se llama a la función showMinesP1_C.
 * 
 * Variables globales utilizadas:	
 * rowScreen: Fila de la pantalla donde posicionamos el cursor.
 * colScreen: Columna de la pantalla donde posicionamos el cursor.
 * charac   : Carácter a escribir en pantalla.
 * marks    : Matriz con las minas marcadas y las minas de las abiertas.   
 * 
 * Esta función no es llama desde ensamblador.
 * Hay una subrutina de ensamblador equivalente 'updateBoardP1', 
 */
void updateBoardP1_C(){

   int i,j;
   
   rowScreen = 7;
   for (i=0;i<DimMatrix;i++){
	  colScreen = 7;
      for (j=0;j<DimMatrix;j++){
         gotoxyP1_C();
         charac = marks[i][j];
         printchP1_C();
         colScreen = colScreen + 4;
      }
      rowScreen = rowScreen + 2;
   }
   showMinesP1_C();   //Mostrar número de minas que quedan por a marcar
   
}


/**
 * Actualizar la posición del cursor en el tablero, que tenemos indicada
 * con la variable (indexMat), en función de la tecla pulsada, 
 * que tenemos en variable (charac). 
 * Si se sale fuera del tablero no actualizar la posición del cursor.
 * (i:arriba, j:izquierda, k:a bajo, l:derecha)
 * Arriba y abajo: ( indexMat = indexMat +/- 10 ) 
 * Derecha y izquierda( indexMat = indexMat +/- 1 ) 
 * No se tiene que posicionar el cursor en pantalla.
 *  
 * Variables globales utilizadas:
 * indexMat : Índice para acceder a las matrices mines y marks desde ensamblador.
 * charac   : Carácter leído de teclado.
 *  
 * Esta función no se llama desde ensamblador.
 * Hay una subrutina en ensamblador equivalente 'moveCursorP1', 
 */
void moveCursorP1_C(){
 
   int row = indexMat/10;
   int col = indexMat%10; 
   
   switch(charac){
      case 'i': //amunt
         if (row>0) indexMat=indexMat-10;
      break;
      case 'j': //esquerra
         if (col>0) indexMat--;
      break;
      case 'k': //avall
         if (row<DimMatrix-1) indexMat=indexMat+10;
      break;
      case 'l': //dreta
		 if (col<DimMatrix-1) indexMat++;
      break;     
	}
	
}


/**
 * Marcar/desmarcar una mina en la matriz (marks) en la posición actual 
 * del cursor, indicada por la variable (indexMat).
 * Si en aquella posición de la matriz (marks) hay un espacio en blanco
 * y no hemos marcado todas las minas, marcamos una mina poniendo una 
 * 'M' en la matriz (marks) y decrementamos el número de minas que quedan
 * por marcar (numMines), si en aquella posición de la matriz (marks) 
 * hay una 'M', pondremos un espacio (' ') e incrementaremos el número 
 * de minas que quedan por marcar (nMines).
 * Si hay otro valor no cambiaremos nada.
 * No se tiene que mostrar la matriz, sólo actualizar la matriz (marks) 
 * y la variable (numMines).
 * 
 * Variables globales utilizadas:
 * marks    : Matriz con las minas marcadas y las minas de las abiertas.
 * indexMat : Índice para acceder a las matrices mines y marks desde ensamblador.
 * numMines : Número de minas que quedan por marcar.
 * 
 * Esta función no se llama desde ensamblador.
 * Hay una subrutina en ensamblador equivalente 'mineMarkerP1'.
 */
void mineMarkerP1_C() {
	
	rowMat = indexMat/10;
    colMat = indexMat%10;
    
	if (marks[rowMat][colMat] == ' ' && numMines > 0) {
		marks[rowMat][colMat] = 'M';      //Marcar
		numMines--;
	} else {
		if (marks[rowMat][colMat] == 'M') {
			marks[rowMat][colMat] = ' ';  //Desmarcar
			numMines++;
		}
	}
		
} 

  
/**
 * Verificar si hemos marcado todas las minas. 
 * Si (numMines==0) cambiar el estado (state=2) (Gana).
 * 
 * Variables globals utilitzades:	
 * numMines : Número de minas que quedan por marcar.
 * state    : Estado del juego.
 * 
 * Esta función no es llama desde ensamblador.
 * Hay una subrutina en ensamblador equivalente 'checkMinesP1', 
 */
void checkMinesP1_C() {
	
	if (numMines == 0) {
		state = 2;
	}
	
} 


/**
 * Mostrar un mensaje debajo del tablero según el valor de la variable 
 * (state).
 * state: 0: Hemos pulsado la tecla 'ESC' para salir del juego.
 * 		  1: Continuamos jugando.
 * 		  2: Gana la partida, se han marcado todas las minas.
 * Se espera que se pulse una tecla para continuar.
 *  
 * Variables globales utilizadas:	
 * rowScreen: Fila de la pantalla donde posicionamos el cursor.
 * colScreen: Columna de la pantalla donde posicionamos el cursor.
 * state    : Estado del juego.
 * 
 * Esta función se llama des de C y desde ensamblador,
 * y no hay definida una subrutina de ensamblador equivalente.
 */
void printMessageP1_C() {

   rowScreen = 27;
   colScreen = 30;
   gotoxyP1_C();  
   
   switch(state){
      case 0:
         printf("<< EXIT: ESC >>");
        break;
      case 2:
         printf("++ YOU WIN ! ++");
      break;
   }
   getchP1_C();		//Espera que el usuario pulse una tecla.
   
}
 

/**
 * Juego del Buscaminas
 * Función principal del juego
 * Permite jugar al juego del buscaminas llamando a todas las funcionalidades.
 *
 * Pseudo código:
 * Inicializar estado del juego, (state=1)
 * Inicializar posición inicial del cursor:
 * fila: 5 y columna: 4, (indexMat=54).
 * Mostrar el tablero de juego llamando la función PrintBoardP1_C).
 * Mientras (state=1) hacer:
 *   Actualizar el contenido del Tablero de Juego y el número de minas
 *     que quedan por marcar (llamar la función updateBoardP1_C).
 *   Posicionar el cursor dentro del tablero (llamar la funció posCurScreenP1_C).
 *   Leer una tecla (llamando la funció getchP1_C) 
 *     y guardarla en la variable local (charac). 
 *   Según la tecla leída llamaremos a la función correspondiente.
 *     - ['i','j','k' o 'l']       (llamar a la función MoveCursorP1_C).
 *     - 'x'                       (llamar a la función MineMarkerP1_C).
 *     - '<ESC>'  (codi ASCII 27) poner (state = 0) para salir.   
 *   Verificar si hemos marcado todas las minas (llamar a la función CheckMinesP1_C).
 * Fin mientras.
 * Salir: 
 *   Actualizar el contenido del Tablero de Juego y el número de minas que 
 *   quedan por marcar (llamar a la función updateBoardP1_C).
 *   Mostrar el mensaje de salida que corresponda (llamar a la función
 *   printMessageP1_C).
 * Se acaba el juego.
 * 
 * Variables globales utilizadas:	
 * indexMat : Índice para acceder a las matrices mines y marks desde ensamblador.
 * charac   : Carácter leído de teclado.
 * state    : Estado del juego.
 * 
 * Esta función no es llama desde ensamblador.
 * Hay una subrutina en ensamblador equivalente 'playP1', 
 */
void playP1_C(){
	
   state = 1;            //Estado para empezar a jugar
			   			   
   indexMat = 54;	     //Posición inicial del cursor.  
  
   printBoardP1_C();
          
   while (state == 1) {  //Bucle principal del juego
	 updateBoardP1_C();
	 posCurScreenP1_C();

     getchP1_C();	//leer una tecla y guardarla en la variable charac.
     if (charac>='i' && charac<='l') { //Mover cursor
       moveCursorP1_C();
     }
     if (charac=='m') {  //Marcar mina
       mineMarkerP1_C();
     }
     if (charac==27) {   //Salir del programa
       state = 0;
     }
     checkMinesP1_C();
   }
   updateBoardP1_C();
   printMessageP1_C();	 //Mostrar el mensaje para indicar como acaba.
   
}


/**
 * Programa Principal
 * 
 * ATENCIÓN: En cada opción se llama a una subrutina de ensamblador.
 * Debajo hay comentada la función en C equivalente que os damos hecha 
 * por si queréis ver como funciona.
 *  */
int main(void){   

   int op=1;
     
   while (op!='0') {
	  clearScreen_C();
      printMenuP1_C();		  //Mostrar menú y leer opción
      op=charac;	   		  
      
      switch(op){
         case '1':// Posicionar el cursor en el tablero.
            printf(" %c",op);
            clearScreen_C();  //Borra la pantalla
            printBoardP1_C(); //Mostrar el tablero
            rowScreen = 27;
			colScreen = 30;
            gotoxyP1_C();
            printf(" Press any key ");
            //=======================================================
            indexMat = 11;    //Fila y columna donde posiciona el cursor
            posCurScreenP1();
            //posCurScreenP1_C();
            //=======================================================
            getchP1_C();
         break;
         case '2': //Mostrar número de minas que quedan por marcar
            printf(" %c",op);
            clearScreen_C();  //Borra la pantalla
            printBoardP1_C(); //Mostrar el tablero
            //=======================================================
            showMinesP1();
            //showMinesP1_C();//Actualitzar número de minas
            //=======================================================
            rowScreen = 27;
			colScreen = 29;
            gotoxyP1_C();
            printf("Press any key ");
            getchP1_C();
         break;
         case '3': //Mostrar el tablero y actualizar el contenido
            printf(" %c",op);
            clearScreen_C();  //Borra la pantalla
            printBoardP1_C(); //Mostrar el tablero
            //=======================================================
            updateBoardP1();
            //updateBoardP1_C();  //Actualizar el contenido del tablero
            //=======================================================
            rowScreen = 27;
			colScreen = 29;
            gotoxyP1_C();
            printf("Press any key ");
            getchP1_C();
         break;
         case '4': //Mover cursor
            clearScreen_C();   //Borra la pantalla
            printBoardP1_C();  //Mostrar el tablero
            printf("\n    Move cursor: i:Up, j:Left, k:Down, l:Right ");
            indexMat=22; //Fila y columna donde se posiciona el cursor
            posCurScreenP1_C();
            getchP1_C();	
            rowScreen = 27;
			colScreen = 29;
            gotoxyP1_C();
			printf(" Press any key ");
	        if (charac>='i' && charac<='l') { 
				//===================================================
				moveCursorP1();
				//moveCursorP1_C();
				//===================================================
				posCurScreenP1_C();
            } else {
				rowScreen = 27;
			    colScreen = 29;
                gotoxyP1_C();
                printf("Incorrect option");
			}
            getchP1_C();
         break;
         case '5': //Marcar Mina
            clearScreen_C();  
            printBoardP1_C(); 
            updateBoardP1_C();  
            rowScreen = 27;
			colScreen = 29;
            gotoxyP1_C();  
            printf(" Mark a Mine  ");
            indexMat=23;      //Fila y columna donde posiciona el cursor
            posCurScreenP1_C();
            getchP1_C();
   			if (charac=='m') {
			    //===================================================
            	mineMarkerP1();
				//mineMarkerP1_C();
				//===================================================
                updateBoardP1_C();
                rowScreen = 27;
			    colScreen = 29;
                gotoxyP1_C();
			    printf(" Press any key ");
			} else {
				rowScreen = 27;
			    colScreen = 29;
                gotoxyP1_C();
			    printf("Incorrect option");
			}	
			getchP1_C();
          break;
          case '7': //Mover curso
            clearScreen_C();   //Borra la pantalla
            printBoardP1_C();  //Mostrar el tablero
            updateBoardP1();
            rowScreen = 27;
			colScreen = 29;
            gotoxyP1_C();
			//===================================================
            int n = numMines;
            numMines = 0;
            checkMinesP1();
			//checkMinesP1_C();
			//===================================================
 	        if (state==2) { 
				printf("++ YOU WIN ! ++");
            } else {
				printf("** MORE MINES **");
			}
			numMines = n;
            getchP1_C();
         break;
          case '8': //Juego completo en ensamblador
            clearScreen_C();
            //=======================================================
            playP1();
            //=======================================================
         break;
         case '9': //Juego completo en C
            clearScreen_C();
            //=======================================================
            playP1_C();
            //=======================================================
         break;
         case '0':
		 break;	 
      }
   }
   printf("\n\n");
   
   return 0;
}
