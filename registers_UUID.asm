.model small
.386
.data
	cnt db 00h
	tmp dd 00h

.stack
.code
Program:
	MOV AX,@data
	MOV ds,AX

	CALL gen_uuid

	MOV AH,4Ch
	INT 21h

;---------------------------------------------------
	;Procedimiento principal para generar el uuid
	gen_uuid PROC NEAR

	XOR EDX,EDX
	XOR EAX,EAX
	XOR EBX,EBX

	;Interruption para obtener feCHa actuAL
	MOV AH,2Ah
	INT 21h
	XOR AX,AX

	;Obtener el mes y MULtiplicarlo por 30
	MOV AL,DH
	sub AL,01h
	MOV BL,1Eh
	MUL BL

	;Obtener los days y sumarlos
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
	
	;Shift a la derecha para colocar a AX como la parte alta
	shl EAX,CL
	
	;Colocar la parte baja EAX de nuevo en AX
	MOV AX,BX

	;Sumar years en segundos y MOVer EAX a tmp
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

	CALL gen_random

	RET
	gen_uuid ENDP
;---------------------------------------------------
	;Obtiene la hora actuAL
	get_time PROC NEAR

	;Interruption para obtener hora actuAL
	MOV AH,2Ch
	INT 21h

	XOR AX,AX

	RET
	get_time ENDP
;---------------------------------------------------
	;Divide EAX dentro de un random de 2-9, lo convierte a hexa y llama para imprimir
	gen_random PROC NEAR

	;Cantidad max de CHars fALtantes para el UUID
	MOV cnt,16h
					
	;Loop para DIVidir dentro de randoms el timespan originAL
	rand_loop:

	;Si el contador es cero sALir del loop
	CMP cnt,00h
	je end_rand

	;Obtener hora actuAL
	CALL get_time

	XOR EAX,EAX
	XOR EBX,EBX

	;Obtener los segundos de la hora actuAL para generar num random de 0-9
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
	MOV tmp,EAX			;ActuALizar vALor de EAX

	;CONVERTIR EAX A HEXA E IMPRIMIR, TENER UN CONTADOR Y AUMENTAR 
	;CADA VEZ QUE SE IMPRIME UN CHAR PARA SABER CUANDO HAYA QUE PARAR
	
	DEC cnt 			;Cont--

	JMP rand_loop

	end_rand:

	RET
	gen_random ENDP	
;--------------------------------------------------
	newline PROC NEAR

	MOV DL,0Ah
	MOV AH,02h
	INT 21h

	RET
	newline ENDP
;---------------------------------------------------
END Program
