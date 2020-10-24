.model small
.386
.data
	innitialInstructions 	DB 'Cualquier otra tecla terminara el programa$'
	firstExInstruction 		DB 'Ingrese "1" para generar un nuevo UUID$'
	secondExInstruction 	DB 'Ingrese "2" para evaluar si el UUID es valido o no$'
	InstructionsForUUIDVal 	DB 'Ingrese el UUID que desea validar$'
	validUUID 				DB 'El UUID ingresado es valido$'
	invalidUUID 			DB 'El UUID ingresado NO es valido$'
	invalidCharacter 		DB 'el caracter ingresado no es valido para un UUID$'
	noNumber1InEx 			DB 'El UUID deberia tener un 1 en esta posicion$'
	sintaxErrorInEx 		DB 'El UUID deberia tener uno de estos caracteres en esta posicion: 8, 9, a, b, A o B$'
	noHyphenInEx 			DB 'El UUID deberia tener un - en esta posicion$'
	optionSelected 			DB ?									;Almacena la opcion seleccionada en el menu de opciones
	actualPositionForUUID 	DB 0

	;Variables para el generador de uuid
	cnt 					DB 00h
	tmp 					DD 00h
	charactersAmount 		DB 00h										;Cantidad de caracteres generados en la fase 1
	ResidueQty				DD 00h										;Para obtener el residuo de cada division para imprimir el caracter
.stack
.code
Program:
	MOV AX, @DATA
	MOV DS, AX
	
InnitialIns:

	CALL newline

	MOV DX, OFFSET innitialInstructions
	CALL printMessage

	CALL newline
	
	MOV DX, OFFSET firstExInstruction
	CALL printMessage

	CALL newline
	
	MOV DX, OFFSET secondExInstruction
	CALL printMessage

	CALL newline
	
	;Leer Opcion seleccionada por el teclado
	MOV AH, 01h
	INT 21h
	MOV optionSelected, AL									;Almacenar en la variable la opcion seleccionada
	
	CMP AL, 31h										;Evaluar si se selecciono la opcion 1
	JE GenerateUUID

	CMP AL, 32h										;Evaluar si es la segunda opcion, validar UUID
	JE ValidateUUID

	JMP Finalize										;Cualquier tecla que no sea 1 o 2 quiere decir que quiere salir del programa
;--------------------------------------------------
GenerateUUID:
	
	MOV charactersAmount, 00h
	CALL newline

	CALL gen_uuid

	JMP InnitialIns
;--------------------------------------------------
ValidateUUID:

	;Segunda serie
	MOV CX, 24h										;Cantidad de caracteres a leer para validar el UUID, contador del ciclo
	CALL newline
	ReadAllUUID:
		MOV BX, 1Ch
		CMP CX, BX									;Si es el caracter numero 9 debe validar que sea la representacion del - en el ASCII, Como va de 32 a 0(mayor que) se valida contra 28
		JE ValidateHyphen

		MOV BX, 17h
		CMP CX, BX									;Si es el caracter numero 14 debe validar que sea la representacion del - en el ASCII, Como va de 32 a 0(mayor que) se valida contra 23
		JE ValidateHyphen

		MOV BX, 16h
		CMP CX, BX									;Si es el caracter numero 15 debe validar que sea la representacion del 1 en el ASCII, Como va de 32 a 0(mayor que) se valida contra 22
		JE ValidateFirstRule

		MOV BX, 12h
		CMP CX, BX									;Si es el caracter numero 19 debe validar que sea la representacion del - en el ASCII, Como va de 32 a 0(mayor que) se valida contra 18
		JE ValidateHyphen
		
		MOV BX, 11h
		CMP CX, BX									;Si es el caracter numero 20 debe validar que sea la representacion de uno de estos caracteres en el ASCII:  8, 9, a, b, A o B, como va de 32 a 0(mayor que) se valida contra 17
		JE SecondRuleValidation

		MOV BX, 0Dh
		CMP CX, BX									;Si es el caracter numero 24 debe validar que sea la representacion del - en el ASCII, Como va de 32 a 0(mayor que) se valida contra 13
		JE ValidateHyphen
		
		CALL readCharacter								;Si no salta en ninguno de los anteriores, solo debe validarse que sea cualquier digito del sistema hexadecimal
		
	LOOP ReadAllUUID									;Para que se procesen los 32 caracteres que conforman el UUID a validar
	
	CALL newline
	
	MOV DX, OFFSET validUUID
	CALL printMessage
	JMP InnitialIns	
;--------------------------------------------------	
ValidateHyphen:

	DEC CX											;Como el salto lo saco del loop y si cumple debe regresar a este, se tiene que restar 1 para que se avance en el loop

	MOV AH, 01h										;Leer el caracter y validar que sea un guion
	INT 21h	

	CMP AL, 2Dh 										
	JE ReadAllUUID 										;Es la representacion del - en ASCII

	CALL newline

	MOV DX, OFFSET noHyphenInEx
	CALL printMessage
	JMP InvalidUUIDMSG
;--------------------------------------------------	
ValidateFirstRule:

	DEC CX											;Como el salto lo saco del loop y si cumple debe regresar a este, se tiene que restar 1 para que se avance en el loop
	
	MOV AH, 01h										;Leer el caracter y validar que este en formato hexadecimal y que sea cualquiera de los siguientes valores: 8, 9, A, B, a, b
	INT 21h	
	
	CMP AL, 31h
	JE ReadAllUUID										;Es la representacion del 1 en ASCII, numero valido en hexadecimal y cumple con el formato de la expresion regular en ese punto (septimo byte)
	
	CALL newline
	
	MOV DX, OFFSET noNumber1InEx
	CALL printMessage
	JMP InvalidUUIDMSG
;--------------------------------------------------
SecondRuleValidation:

	DEC CX											;Como el salto lo saco del loop y si cumple debe regresar a este, se tiene que restar 1 para que se avance en el loop
	
	MOV AH, 01h										;Leer el caracter y validar que este en formato hexadecimal y que sea cualquiera de los siguientes valores: 8, 9, A, B, a, b
	INT 21h	
	
	CMP AL, 38h
	JE ReadAllUUID										;Es la representacion del 8 en ASCII, numero valido en hexadecimal y cumple con el formato de la expresion regular
	CMP AL, 39h
	JE ReadAllUUID										;Es la representacion del 9 en ASCII, numero valido en hexadecimal y cumple con el formato de la expresion regular
	
	CMP AL, 41h
	JE ReadAllUUID										;Es la representacion de la letra A en ASCII, numero valido en hexadecimal y cumple con el formato de la expresion regular
	CMP AL, 42h
	JE ReadAllUUID										;Es la representacion de la letra B en ASCII, numero valido en hexadecimal y cumple con el formato de la expresion regular
	
	CMP AL, 61h
	JE ReadAllUUID										;Es la representacion de la letra a en ASCII, numero valido en hexadecimal y cumple con el formato de la expresion regular
	CMP AL, 62h
	JNE printError										;Es la representacion de la letra b en ASCII, numero valido en hexadecimal y cumple con el formato de la expresion regular
	JMP ReadAllUUID
	
	printError:
	
	CALL newline
	MOV DX, OFFSET sintaxErrorInEx
	CALL printMessage
	JMP InvalidUUIDMSG
;--------------------------------------------------
	;Procedimiento solicitar cada caracter del UUID al usuario
	readCharacter PROC NEAR
	
		MOV AH, 01h										;Leer cada caracter y validar que este en formato hexadecimal
		INT 21h	
		
		CMP AL, 30h
		JL SintaxisError									;Quieren digitar algo que es menor que la representacion de 0 en el ASCII, algo que no es un numero ni caracter valido en hexadecimal
		CMP AL, 39h
		JLE ReturnValue										;Como no saltÎsmALalto, estan digitando la representacion de un noSCII, vdos en el sistema hexadecimal
		CMP AL, 41h
		JL SintaxisError									;Es un caracter que es mayor que la representacion del 9 en ASCII, pero menor que la letra A en ASCII, no es ningun numero valido en hexadecimal
		CMP AL, 46h
		JLE ReturnValue										;Es un caracter entre las representaciones de un numero entre A, B, C, D, E, F en el ASCII,  vÎdos en el sistema hexadecimal

		CMP AL, 61h
		JL SintaxisError									;Es un caracter que es mayor que la representacion de la letra F en ASCII, pero menor que la letra a en ASCII, no es ningun numero valido en hexadecimal
		CMP AL, 66h
		JG SintaxisError									;Es un caracter que esta fuera del rango de caracteres vÎdos en el sistema hexadecimal, es un valor no valido para el sistema hexadecimal
		
		ReturnValue:
		RET
	readCharacter ENDP
;--------------------------------------------------
SintaxisError:

	CALL newline
	MOV DX, OFFSET invalidCharacter
	CALL printMessage
	JMP InvalidUUIDMSG
;--------------------------------------------------
InvalidUUIDMSG:

	CALL newline
	MOV DX, OFFSET invalidUUID
	CALL printMessage
	JMP InnitialIns
;---------------------------------------------------
	;Procedimiento principal para generar el uuid
	gen_uuid PROC NEAR

		XOR EDX,EDX
		XOR EAX,EAX
		XOR EBX,EBX

		;Interruption para obtener fecha actual
		MOV AH,2Ah
		INT 21h
		XOR AX,AX

		;Obtener el mes y Multiplicarlo por 30
		MOV AL,DH
		sub AL,01h
		MOV BL,1Eh
		MUL BL

		;Obtener los días y sumarlos
		XOR BX,BX
		MOV BL,DL
		add AX,BX
		sub AX,01h

		;Convertir a horas MULtiplicando por 24
		XOR BX,BX
		MOV BX,18h
		MUL BX

		;Convertir a segundos MULtiplicando por 3600
		XOR BX,BX
		MOV BX,0E10h
		MUL BX

		;Guardar la parte baja de EAX(AX) en BX y la alta(DX) en AX
		MOV BX,AX
		MOV AX,DX

		XOR CX,CX

		MOV CL,10h
		
		;Shift a la derecha para colocar a AX como la parte altaS
		shl EAX,CL
		
		;Colocar la parte baja EAX de nuevo en AX
		MOV AX,BX

		;Sumar años en segundos y mover EAX a tmp
		add EAX,5DFC0F00h
		MOV tmp,EAX
		XOR EAX,EAX

		XOR BX,BX
		XOR CX,CX
		XOR AX,AX

		CALL get_time

		;Convertir horas MULtiplicando por 3600
		MOV AL,CH
		MOV BX,0E10h
		MUL BX

		;Sumarlo a tmp
		add tmp,EAX

		XOR BX,BX
		XOR CX,CX
		XOR AX,AX

		CALL get_time

		;Convertir minutos MULtiplicando por 60
		MOV AL,CL
		MOV BX,3Ch
		MUL BX

		;Sumarlo a tmp
		add tmp,EAX

		XOR BX,BX
		XOR CX,CX
		XOR AX,AX

		CALL get_time

		;Sumar los segundos a tmp
		MOV AL,DH
		add tmp,EAX

		;Mover tmp a EAX para guardar su estado
		XOR EAX,EAX
		MOV EAX,tmp

		;CONVERTIR EAX A HEXA E IMPRIMIR LOS PRIMEROS CHAR DEL UUID
		CALL ConvertToHexa
		MOV BL, charactersAmount
		CALL gen_random

		RET
	gen_uuid ENDP
;---------------------------------------------------
	;Obtiene la hora actual
	get_time PROC NEAR

		;Interruption para obtener hora actual
		MOV AH,2Ch
		INT 21h

		XOR AX,AX

		RET
	get_time ENDP
;---------------------------------------------------
	;Divide EAX dentro de un random de 2-9, lo convierte a hexa y llama para imprimir
	gen_random PROC NEAR

		;Cantidad max de chars faltantes para el UUID
		MOV cnt,16h
			
		;Loop para dividir dentro de randoms el timespan original
		rand_loop:

		;Si el contador es cero salir del loop
		CMP cnt,00h
		je end_rand

		;Obtener hora actuAL
		CALL get_time

		XOR EAX,EAX
		XOR EBX,EBX

		;Obtener los segundos de la hora actual para generar num random de 0-9
		MOV AL,DL
		XOR EDX,EDX
		MOV BX,0Ah
		DIV BX

		;Mover temp a EAX para guardar su estado
		MOV EAX,tmp

		XOR EBX,EBX

		;Dividir aex dentro del num random generado
		MOV BX,DX
		CMP BX,01h
		JLE rand_loop			;Descartar el num random si es 0 o 1

		XOR EDX,EDX
		DIV EBX
		MOV tmp,EAX			;Actualizar valor de EAX

		;CONVERTIR EAX A HEXA E IMPRIMIR, TENER UN CONTADOR Y AUMENTAR 
		;CADA VEZ QUE SE IMPRIME UN CHAR PARA SABER CUANDO HAYA QUE PARAR
		CALL ConvertToHexa
		DEC cnt 			;Cont--

		JMP rand_loop

		end_rand:

		RET
	gen_random ENDP	
;--------------------------------------------------
	;Procedimiento para imprimir salto de linea
	newline PROC NEAR

		MOV DL, 0Ah		
		MOV AH, 02h
		INT 21h

		RET
	newline ENDP
;--------------------------------------------------
	;Procedimiento para convertir el valor actual de EAX a hexadecimal
	ConvertToHexa PROC NEAR
	
		GenerateActualHexa:
			
			XOR EDX, EDX										;Se limpia para que no corrompa la division que se dara en formato (EDX;EAX)/16
			
			CMP EAX, EDX										;Si son iguales, quiere decir que ya se vacio el registro EAX y debe salir del loop
			JE ReturnToRandom									;Sale del procedure para regresar a la generacion de random
			
			INC charactersAmount								;charactersAmount debe ser menor a 36 (32 digitos del UUID + Cantidad de guiones)
			
			CMP charactersAmount, 24h							
			JG FinishedUUID										;Ya se genero el UUID
			
			CMP charactersAmount, 09h							;Debe imprimir un guion
			JE PrintHyphen
			
			CMP charactersAmount, 0Eh							;Debe imprimir un guion
			JE PrintHyphen
			
			CMP charactersAmount, 0Fh							;Debe imprimir el 1 de la primera regla
			JE PrintNumber1
			
			CMP charactersAmount, 13h							;Debe imprimir un guion
			JE PrintHyphen
			
			CMP charactersAmount, 14h							;Debe imprimir un valor entre 8, 9, A o B
			JE PrintSecondRule
			
			CMP charactersAmount, 18h							;Debe imprimir un guion
			JE PrintHyphen
			
			MOV ECX, 10h										;Palabra doble para realizar la division (EDX;EAX)/ECX
			DIV ECX
			
			PrintValue:
			CMP DX, 09h											;Si es menor o igual que 9, se debe sumar 30h y mostrar la representacion en ASCII de la sumar
			JLE PrintNumbers
			JMP PrintLetters									;En caso sea mayor que 9, es una letra
			
		PrintNumbers:
		
			ADD DL, 30h											;Imprimir la representacion en ASCII Del numero actual en formato hexadecimal
			MOV ECX, EAX										;Guarda el cociente, si no se perderia al momento de alterar AH para la interrupcion
			CALL PrintCharacter
			MOV EAX, ECX										;Restaurar el cociente para que en la siguiente operacion siga realizando la division correctamente
			JMP GenerateActualHexa								;Para que regrese al ciclo y lo realice la n veces que sea necesario
			
		PrintLetters:
		
			ADD DL, 37h											;Imprimir la representacion en ASCII del numero actual en formato hexadecimal (Para las letras de este sistema)
			MOV ECX, EAX										;Guarda el cociente, si no se perderia al momento de alterar AH para la interrupcion
			CALL PrintCharacter
			MOV EAX, ECX										;Restaurar el cociente para que en la siguiente operacion siga realizando la division correctamente
			JMP GenerateActualHexa								;Para que regrese al ciclo y lo realice la n veces que sea necesario	
		
		PrintHyphen:
		
			MOV DL, 2Dh											;Representacion del guion en ASCII
			CALL PrintCharacter
			JMP GenerateActualHexa								;Para que regrese al ciclo y lo realice la n veces que sea necesario
			
		PrintNumber1:
		
			MOV DL, 31h											;Representacion del 1 en ASCII
			CALL PrintCharacter
			JMP GenerateActualHexa								;Para que regrese al ciclo y lo realice la n veces que sea necesario

		PrintSecondRule:
		
			MOV DL, 38h											;Representacion del 8 en ASCII
			CALL PrintCharacter
			JMP GenerateActualHexa								;Para que regrese al ciclo y lo realice la n veces que sea necesario
			
		FinishedUUID:
		
			CALL newline
			JMP InnitialIns
			
		ReturnToRandom:
		
		RET
	ConvertToHexa ENDP
;--------------------------------------------------
	;Procedimiento para imprimir un caracter
	PrintCharacter PROC NEAR
	
		MOV AH, 02h											;Parametro de la interrupcion
		INT 21h

		RET
	PrintCharacter ENDP	
;--------------------------------------------------
	;Procedimiento para imprimir mensajes
	printMessage PROC NEAR

		MOV AH, 09h
		INT 21h

		RET
	printMessage ENDP
;--------------------------------------------------
Finalize:
	MOV AH, 4Ch
	INT 21h

END Program