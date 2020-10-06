.model small
.data
	innitialInstructions DB 'Cualquier otra tecla terminara el programa$'
	firstExInstruction DB 'Ingrese "1" para generar un nuevo UUID$'
	secondExInstruction DB 'Ingrese "2" para evaluar si el UUID es valido o no$'
	optionSelected DB ?							;Almacena la opcion seleccionada en el menu de opciones
.stack
.code
Program:
	MOV AX, @DATA
	MOV DS, AX
	
InnitialIns:
	MOV DL, 0Ah									;Salto de linea
	MOV AH, 02h
	INT 21h
	MOV DX, OFFSET innitialInstructions
	MOV AH, 09h
	INT 21h
	
	MOV DL, 0Ah									;Salto de linea
	MOV AH, 02h
	INT 21h
	
	MOV DX, OFFSET firstExInstruction
	MOV AH, 09h
	INT 21h
	
	MOV DL, 0Ah									;Salto de linea
	MOV AH, 02h
	INT 21h
	
	MOV DX, OFFSET secondExInstruction
	MOV AH, 09h
	INT 21h
	
	MOV DL, 0Ah									;Salto de linea
	MOV AH, 02h
	INT 21h	
	;Leer Opcion seleccionada por el teclado
	MOV AH, 01h
	INT 21h
	MOV optionSelected, AL						;Almacenar en la variable la opcion seleccionada
	
	CMP AL, 31h									;Evaluar si se selecciono la opcion 1
	JE FirstExercise
	CMP AL, 32h									;Evaluar si es el segundo ejercicio
	JE SecondExercise
	JMP Finalize								;Cualquier tecla que no sea 1 o 2 quiere decir que quiere salir del programa

FirstExercise:
	MOV DL, 0Ah									;Salto de linea
	MOV AH, 02h
	INT 21h		
	JMP InnitialIns
SecondExercise:
	MOV DL, 0Ah									;Salto de linea
	MOV AH, 02h
	INT 21h	
	JMP InnitialIns
Finalize:
	MOV AH, 4Ch
	INT 21h
END Program