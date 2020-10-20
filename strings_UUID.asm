.model small
.data
	cont db 00h
	cont2 db 00h
	carry dw 00h

	seconds_string db 80 dup ('$')
	aux_string     db 80 dup ('$')


.stack
.code
Program:
	mov ax,@data
	mov ds,ax

	call time_to_string

	call print_seconds

	mov ah,4Ch
	int 21h

;---------------------------------------------------
	time_to_string proc near

	xor dx,dx
	xor ax,ax
	xor bx,bx

	call reset_seconds

	;Interruption para obtener fecha actual
	mov ah,2Ah
	int 21h
	xor ax,ax

	;Obtener el mes y multiplicarlo por 30
	mov al,dh
	sub al,01h
	mov bl,1Eh
	mul bl

	;Obtener los days y sumarlos
	xor bx,bx
	mov bl,dl
	add ax,bx
	sub ax,01h

	;Convertir ax a string
	call num2string

	;Convertir a horas multiplicando por 24
	mov al,18h
	mov cont,al
	call multiply_strings

	mov cont2,02h
	call convert2seconds

	call get_time

	;Obtener las horas
	mov al,ch

	call num2string

	mov cont2,02h
	call convert2seconds

	call get_time

	;Obtener los minutos
	mov al,cl

	call num2string

	mov cont2,01h
	call convert2seconds

	call get_time

	;Obtener los segundos
	mov al,dh

	call num2string

	call add_strings

	call reset_aux

	;Split units, tens and hundreds to put them
	;inside aux_string. Then multiply it by x24
	;x60x60 with the multiply_proc. Add that to
	;seconds_string and then create random mults
	;to fill uuid_string
	;Test if aux_string has a max and fill uuid
	;with zeros.
	;Create proc to reset seconds_string
	;Add current time in seconds


	ret
	time_to_string endp
;------------------------------------------------------------------
        num2string proc near

	mov cont,00h 		
	mov cont2,00h

	;Verificar si ax es menor a 9
	cmp ax,09h
	jle to_string

	;Restar centenas si existen
	subhundreds:

	cmp ax,64h
	jl subtens

	sub ax,64h

	inc cont

	cmp ax,09h
	jle to_string

	jmp subhundreds


	;Restar decenas si existen
	subtens:

	cmp ax,0Ah
	jl to_string

	sub ax,0Ah

	inc cont2

	jmp subtens

	;Retornar num separado
	to_string:

	xor bx,bx
	lea si,aux_string

	mov [si],al
	inc si

	mov bl,cont2
	mov [si],bl
	inc si

	mov bl,cont
	mov [si],bl

        ret
        num2string endp
;---------------------------------------------------
     	multiply_strings proc near

        lea si,aux_string
        mov carry,00h

        ;Loop principal de mult
        multiply_loop:

        xor ax,ax
        xor bx,bx

        ;Verificar si no se encuentra $
        mov al,[si]
        cmp al,24h
        je shift_string

        mov bl,cont
        mul bx
        add ax,carry

        xor bx,bx
        xor dx,dx
        mov bx,0Ah

        div bx
        mov carry,ax

        mov [si],dl

        inc si

        jmp multiply_loop

        ;Mover cadena si carry no es 0
        shift_string:

        xor ax,ax
        mov ax,carry
        cmp ax,00h
        ;cmp al,00h
        je end_mult

        xor bx,bx
        xor dx,dx
        xor ax,ax

        mov ax,carry

        mov bx,0Ah
        div bx

        mov carry,ax

        mov [si],dl

        inc si

        jmp shift_string

        end_mult:

        ret
        multiply_strings endp
;---------------------------------------------------
	add_strings proc near

        lea si,aux_string
	lea di,seconds_string
        mov carry,00h

        ;Loop principal de add
        add_loop:

        xor ax,ax
        xor bx,bx

        ;Verificar si no se encuentra $
        mov al,[si]
        cmp al,24h
        je add_rest

	mov bl,[di]

	add ax,bx
        add ax,carry

        xor bx,bx
	xor dx,dx
        mov bx,0Ah

        div bx
        mov carry,ax

        mov [di],dl

        inc si
	inc di

        jmp add_loop

        add_rest:

	xor ax,ax
	xor bx,bx

	mov al,[di]
	cmp al,24h
	je end_add

	add ax,carry

	xor bx,bx
	xor dx,dx
	mov bx,0Ah

	div bx
	mov carry,ax

	mov [di],dl

	inc di

	jmp add_rest

	end_add:

	ret
	add_strings endp
;---------------------------------------------------
	reset_seconds proc near

	xor ax,ax
	xor bx,bx
	lea si,seconds_string

	mov bl,00h
	mov [si],bl
	inc si

	mov bl,00h
	mov [si],bl
	inc si

	mov bl,00h
	mov [si],bl
	inc si

	mov bl,00h
	mov [si],bl
	inc si

	mov bl,00h
	mov [si],bl
	inc si

	mov bl,08h
	mov [si],bl
	inc si

	mov bl,06h
	mov [si],bl
	inc si

	mov bl,07h
	mov [si],bl
	inc si

	mov bl,05h
	mov [si],bl
	inc si

	mov bl,01h
	mov [si],bl

	ret
	reset_seconds endp
;---------------------------------------------------
	reset_aux proc near

	xor ax,ax
	xor bx,bx
	lea si,aux_string
	mov bl,00h

	traverse_aux:

	mov al,[si]
	cmp al,24h
	je end_traverse

	mov [si],bl

	inc si

	jmp traverse_aux

	end_traverse:

	ret
	reset_aux endp
;---------------------------------------------------
	convert2seconds proc near

	xor cx,cx

	mov cl,cont2

	convert_loop:

	;Multiplicar por 60
	mov al,3Ch
	mov cont,al
	call multiply_strings

	loop convert_loop
	
	;Sumar aux_string a seconds_string
	call add_strings

	;Resetear aux_string
	call reset_aux

	ret
	convert2seconds endp
;---------------------------------------------------
	print_seconds proc near

        ;call newline

        mov cont,00h
        lea si,seconds_string

        ;Go to last char of string
        traverse_string:

        xor ax,ax

        mov al,[si]
        cmp al,24h
        je print_loop

        inc si
        inc cont

        jmp traverse_string

        print_loop:

        xor bx,bx
        dec si

        print_reverse:

        xor ax,ax

        mov bl,cont
        cmp bl,00h
        je end_print

        mov ah,02h
        mov dl,[si]
        add dl,30h
        int 21h

        dec cont
        dec si

        jmp print_reverse

        end_print:

	call newline

        ret
        print_seconds endp
;---------------------------------------------------
	get_time proc near

	;Interruption para obtener hora actual
	mov ah,2Ch
	int 21h

	xor ax,ax

	ret
	get_time endp
;---------------------------------------------------
	newline proc near

	mov dl,0Ah
	mov ah,02h
	int 21h

	ret
	newline endp
;---------------------------------------------------
END Program
