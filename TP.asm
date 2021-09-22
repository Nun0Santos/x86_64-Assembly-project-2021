.8086
.model small
.stack 2048
dseg segment para public 'data'
     ; VARIAVEIS...
    menu 			db 		"------Please select a choice------",13,10
    opc1 			db 		"1. Play",13,10
    opc2 			db 		"2. TOP 10",13,10
	opc3			db		"3. Help",13,10
    opc4			db 		"4. Exit",13,10,'$'
    msg1 			db  	"Enter your choice: $"
    Erro_Open       db      'Erro ao tentar abrir o ficheiro$'
    Erro_Ler_Msg    db      'Erro ao tentar ler do ficheiro$'
    Erro_Close      db      'Erro ao tentar fechar o ficheiro$'
    Fich          	db      'labi.TXT',0
	Fich1          	db      'top10.TXT',0
	Fich2          	db      'help.TXT',0
    HandleFich      dw      0
    car_fich        db      ?
    STR12	 		DB 		"            "	; String para 12 digitos
	DDMMAAAA 		db		"                     "
	Horas			dw		0				; Vai guardar a HORA actual
	Minutos			dw		0				; Vai guardar os minutos actuais
	Segundos		dw		0				; Vai guardar os segundos actuais
	Old_seg			dw		0				; Guarda os �ltimos segundos que foram lidos
	Tempo_init		dw		0				; Guarda O Tempo de inicio do jogo
	Tempo_j			dw		0				; Guarda O Tempo que decorre o  jogo
	Tempo_limite	dw		180				; tempo m�ximo de Jogo
    String_nome  	db	    "TAC $" 	
	String_nome2	db      "ISEC $"
	String_nome3 	db  	"ALUNO    $"
	String_nome4 	db  	"HACKER    $"
	String_nome5 	db  	"COIMBRA    $"
	Construir_nome	db	    "            $"	
	indice_nome		dw		0	; indice que aponta para Construir_nome
    Fim_Ganhou		db	    " Ganhou $"	
	Fim_Perdeu		db	    " Perdeu! Tente novamente $"	
    string			db		"Teste pr�tico de T.I",0
	Car				db	32	 		; Guarda um caracter do Ecran 
	;Carteste        db	32	 		; Guarda um caracter do Ecran 
	Cor				db	7	; Guarda os atributos de cor do caracter
	POSy			db	3	; a linha pode ir de [1 .. 25]
	POSx			db	3	; POSx pode ir [1..80]	
	POSya			db	3	; Posi��o anterior de y
	POSxa			db	3	; Posi��o anterior de x
	POSyn			db  3
	POSxn			db 	3
	CaracterTXT     db 	32
	;NUMERO			DB		"                    $" 	; String destinada a guardar o número lido	
	;NUM_SP			db		"                    $" 	; PAra apagar zona de ecran
	;NUMDIG			db	0	; controla o numero de digitos do numero lido
	;MAXDIG			db	4	; Constante que define o numero MAXIMO de digitos a ser aceite
	nivel1 			db "Nivel 1 $"
	nivel2 			db "Nivel 2 $"
	nivel3			db "Nivel 3 $"
	nivel4 			db "Nivel 4 $"
	nivel5 			db "Nivel 5 $"
	msgNome			db "Introduza o seu nome:$"
 	;TamNome   		db  10
	StrNome			db "         $"
	msgWinner       db "Parabens concluio todos os nives com sucesso!$"
	pontos 			db  "  $"
	ultimo_num_aleat dw 0
   	dseg ends
cseg segment para public 'code'
     assume cs:cseg, ds:dseg,
;############################ Posiciona-me o cursor no ecrã onde quero  ###########################################
     goto_xy	macro		POSx,POSy
		mov		ah,02h
		mov		bh,0		; numero da página
		mov		dl,POSx
		mov		dh,POSy
		int		10h

ENDM
;########################################################################

; MOSTRA - Faz o display de uma string terminada em $
MOSTRA MACRO STR    
		MOV AH,09H
		LEA DX,STR 
		INT 21H
ENDM
; FIM MACROS

Ler_TEMPO PROC	
 
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
	
		PUSHF
		
		MOV AH, 2CH             ; Buscar a hORAS
		INT 21H                 
		
		XOR AX,AX
		MOV AL, DH              ; segundos para al
		mov Segundos, AX		; guarda segundos na variavel correspondente
		
		XOR AX,AX
		MOV AL, CL              ; Minutos para al
		mov Minutos, AX         ; guarda MINUTOS na variavel correspondente
		
		XOR AX,AX
		MOV AL, CH              ; Horas para al
		mov Horas,AX			; guarda HORAS na variavel correspondente
 
		POPF
		POP DX
		POP CX
		POP BX
		POP AX
 		RET 
Ler_TEMPO   ENDP 
;********************************************************************************
; HORAS  - LE Hora DO SISTEMA E COLOCA em tres variaveis (Horas, Minutos, Segundos)
; CH - Horas, CL - Minutos, DH - Segundos
;********************************************************************************
HOJE PROC	

		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
		PUSH SI
		PUSHF
		
		MOV AH, 2AH             ; Buscar a data
		INT 21H                 
		PUSH CX                 ; Ano-> PILHA
		XOR CX,CX              	; limpa CX
		MOV CL, DH              ; Mes para CL
		PUSH CX                 ; Mes-> PILHA
		MOV CL, DL				; Dia para CL
		PUSH CX                 ; Dia -> PILHA
		XOR DH,DH                    
		XOR	SI,SI
; DIA ------------------ 
; DX=DX/AX --- RESTO DX   
		XOR DX,DX               ; Limpa DX
		POP AX                  ; Tira dia da pilha
		MOV CX, 0               ; CX = 0 
		MOV BX, 10              ; Divisor
		MOV	CX,2
DD_DIV:                         
		DIV BX                  ; Divide por 10
		PUSH DX                 ; Resto para pilha
		MOV DX, 0               ; Limpa resto
		loop dd_div
		MOV	CX,2
DD_RESTO:
		POP DX                  ; Resto da divisao
		ADD DL, 30h             ; ADD 30h (2) to DL
		MOV DDMMAAAA[SI],DL
		INC	SI
		LOOP DD_RESTO            
		MOV DL, '/'             ; Separador
		MOV DDMMAAAA[SI],DL
		INC SI
; MES -------------------
; DX=DX/AX --- RESTO DX
		MOV DX, 0               ; Limpar DX
		POP AX                  ; Tira mes da pilha
		XOR CX,CX               
		MOV BX, 10				; Divisor
		MOV CX,2
MM_DIV:                         
		DIV BX                  ; Divisao or 10
		PUSH DX                 ; Resto para pilha
		MOV DX, 0               ; Limpa resto
		LOOP MM_DIV
		MOV CX,2 
MM_RESTO:
		POP DX                  ; Resto
		ADD DL, 30h             ; SOMA 30h
		MOV DDMMAAAA[SI],DL
		INC SI		
		LOOP MM_RESTO
		
		MOV DL, '/'             ; Character to display goes in DL
		MOV DDMMAAAA[SI],DL
		INC SI
 
;  ANO ----------------------
		MOV DX, 0               
		POP AX                  ; mes para AX
		MOV CX, 0               ; 
		MOV BX, 10              ; 
AA_DIV:                         
		DIV BX                   
		PUSH DX                 ; Guarda resto
		ADD CX, 1               ; Soma 1 contador
		MOV DX, 0               ; Limpa resto
		CMP AX, 0               ; Compara quotient com zero
		JNE AA_DIV              ; Se nao zero
AA_RESTO:
		POP DX                  
		ADD DL, 30h             ; ADD 30h (2) to DL
		MOV DDMMAAAA[SI],DL
		INC SI
		LOOP AA_RESTO
		POPF
		POP SI
		POP DX
		POP CX
		POP BX
		POP AX
 		RET 
HOJE   ENDP 
; LEITURA DE UMA TECLA DO TECLADO 
; LE UMA TECLA	E DEVOLVE VALOR EM AH E AL
; SE ah=0 É UMA TECLA NORMAL
; SE ah=1 É UMA TECLA EXTENDIDA
; AL DEVOLVE O CÓDIGO DA TECLA PREMIDA
LE_TECLA	PROC
sem_tecla:
		call timer
		MOV	AH,0BH
		INT 21h
		cmp AL,0
		je	sem_tecla
		
	
		
		MOV	AH,08H
		INT	21H
		MOV	AH,0
		CMP	AL,0
		JNE	SAI_TECLA
		MOV	AH, 08H
		INT	21H
		MOV	AH,1
SAI_TECLA:	
		RET
LE_TECLA	ENDP

;Rotina para apagar ecrã
apaga_ecran	proc
			mov		ax,0B800h
			mov		es,ax   ;Escrever na mem video (es)
			xor		bx,bx
			mov		cx,25*80
			
apaga:		mov		byte ptr es:[bx],' '
			mov		byte ptr es:[bx+1],7
			inc		bx
			inc 	bx
			loop	apaga
			ret
apaga_ecran	endp

;Rotina para mostrar menu
display_menu proc
			mov  dx, offset menu
			mov  ah, 9
			int  21h
			ret
display_menu endp
;Rotina para ecrã usado só 1x no inicio da main
clear_screen proc
			mov  ah, 0
			mov  al, 3
			int  10H
			ret
clear_screen endp

cursorRandom proc

repetir2:        				  ;Inicio do ciclo
        call CalcAleat        	  ;chama o calcAleat
        pop ax  				  ;mov o resultado do calcaleat para ax
        cmp al,3                  ; cmp o al a 3
        jb repetir2               ; se al for menor que 1 faz a repetição toda
        cmp al,74                 ; cmp se al é 74
        ja repetir2               ; se o al for maior que 75 ele repete tudo
        mov ah,0                  ;chega até aqui se o numero em al for entre 1 e 75 e coloca o ah a 0 só para ficar melhor no print
        mov posx,al 			  ;gerar aleatório x
repetirY2:
        xor ax,ax
        call CalcAleat             ;chama o calcAleat
        pop ax    				   ;mov o resultado do calcaleat para ax
        cmp al,3               	   ; cmp o al a 3
        jb repetirY2               ; se al for menor que 1 faz a repetição toda
        cmp al,17                  ; cmp se al é 17
        ja repetirY2               ; se o al for maior que 75 ele repete tudo
        mov ah,0                   ;chega até aqui se o numero em al for entre 1 e 75 e coloca o ah a 0 só para ficar melhor no print
        mov posy,al                ;gerar aleatório y  falta implementar a função
        


		goto_xy POSx,POSy

		mov 	ah, 08h			   	; Guarda o Caracter que est� na posi��o do Cursor
		mov		bh,0				; numero da p�gina
		int		10h			
		mov		car, al				; Guarda o Caracter que est� na posi��o do Cursor
		

		cmp car,177
        je repetir2

		ret
cursorRandom endp

;##################### INICIO PLAY ################################
play proc
		call		apaga_ecran
		goto_xy		0,0
		call		IMP_FICH_Labi
		goto_xy 	10,20
		mostra string_nome
		call 		AVATAR
		goto_xy		0,2				
		ret
play endp

PROSSEGUIR PROC
			goto_xy 78,0
			mov ah,02h
			mov dl,Car
			int 21h
			goto_xy posx,posy
			IMPRIME:	mov		ah, 02h
			mov		dl, 2			; Coloca AVATAR
			int		21H	
			goto_xy	POSx,POSy		; Vai para posi��o do cursor
		
			mov		al, POSx		; Guarda a posi��o do cursor
			mov		POSxa, al
			mov		al, POSy		; Guarda a posi��o do cursor
			mov 	POSya, al
		
LER_SETA:	call 	LE_TECLA
			cmp		ah, 1
			je		ESTEND
			CMP 	AL, 27				; ESCAPE
			JE		FIM
			jmp		LER_SETA
		
ESTEND:		cmp 	al,48h
			jne		BAIXO
			call 	Verifica_cim	 	;cima
			ret

BAIXO:		cmp		al,50h
			jne		ESQUERDA
			call 	Verifica_baixo		;Baixo
			ret

ESQUERDA:
			cmp		al,4Bh
			jne		DIREITA
			call 	Verifica_esquerda	;Esquerda
			ret

DIREITA:
			cmp		al,4Dh
			jne		LER_SETA 
			call 	Verifica_direita	;Direita
			ret
MOVE:		mov dl,POSxa
			mov POSx, dl
			mov dl,POSya
			mov posy,dl
			jmp LER_SETA
			
FIM:
		ret
PROSSEGUIR ENDP
AVATAR	PROC
			mov		ax,0B800h
			mov		es,ax

			goto_xy	POSx,POSy		; Vai para nova possi��o
			mov 	ah, 08h			; Guarda o Caracter que est� na posi��o do Cursor
			mov		bh,0			; numero da p�gina
			int		10h			
			mov		Car, al			; Guarda o Caracter que est� na posi��o do Cursor
			mov		Cor, ah			; Guarda a cor que est� na posi��o do Cursor


;******************************************************
; _   _   _____  __      __  ______   _        __     *
;| \ | | |_   _| \ \    / / |  ____| | |      /_ |    *
;|  \| |   | |    \ \  / /  | |__    | |       | |    *
;| . ` |   | |     \ \/ /   |  __|   | |       | |    *
;| |\  |  _| |_     \  /    | |____  | |____   | |    *
;|_| \_| |_____|     \/     |______| |______|  |_|    *
;                                                     *
;******************************************************    
;-----------------------3LETRAS------------------------
nivel1_start:
			call cursorRandom
			;call play    
			call resetvars
			goto_xy 10,20
			mostra String_nome
			goto_xy 60,0
			MOV		STR12[3],'/'
			MOV		STR12[4],'1'
			MOV		STR12[5],'8'
			MOV		STR12[6],'0'
			MOV 	STR12[7],'$'
			goto_xy 2,0
			mostra nivel1
ciclo:
			goto_xy POSxa,POSya
			mov 	ah,02
			mov 	dl,Car
			int 	21h
			goto_xy	POSx,POSy		; Vai para nova possi��o
			mov 	ah, 08h
			mov		bh,0			; numero da p�gina
			int		10h	
			mov 	car, al			; Guarda o Caracter que est� na posi��o do Cursor
			mov		Cor, ah	

			xor 	si,si
			xor 	dx,dx
		

			mov 	DL, String_nome[si]
			cmp 	car, DL
			Je 		Encontra_N1POS1

			mov 	DL,String_nome[si+1]
			cmp 	car,dl
			Je 		Encontra_N1POS2

			mov 	DL, String_nome[si+2]
			cmp 	car,dl
			Je 		Encontra_N1POS3
			
nivel1_next:
				call PROSSEGUIR
				cmp ax,27 ;Esc
				Jne ciclo
				je fim
				
				
			
Encontra_N1POS1:
			mov Construir_nome[0],DL
			inc indice_nome
			goto_xy 10,21
			MOSTRA Construir_nome
			goto_xy POSxa, POSya
			mov car, " "
			cmp indice_nome,3
			je nivel2_start
			jmp nivel1_next
		
Encontra_N1POS2:
			mov Construir_nome[1],DL
			inc indice_nome
			goto_xy 10,21
			MOSTRA Construir_nome
			goto_xy POSxa, POSya
			mov car, " "
			cmp indice_nome,3
			je nivel2_start
			jmp nivel1_next
		
Encontra_N1POS3:
			mov Construir_nome[2],DL
			inc indice_nome
			goto_xy 10,21
			MOSTRA Construir_nome
			goto_xy POSxa, POSya
			mov car, " "
			cmp indice_nome,3
			je nivel2_start
			jmp nivel1_next
		
;******************************************************
 ; _   _   _____  __      __  ______   _        ___   *
 ;| \ | | |_   _| \ \    / / |  ____| | |      |__ \  *
 ;|  \| |   | |    \ \  / /  | |__    | |         ) | *
 ;| . ` |   | |     \ \/ /   |  __|   | |        / /  * 
 ;| |\  |  _| |_     \  /    | |____  | |____   / /_  *
 ;|_| \_| |_____|     \/     |______| |______| |____| *
 ; 													  *
;******************************************************	
;-----------------------4LETRAS------------------------	                                                                                                     
nivel2_start:
			call cursorRandom
			call resetvars
			goto_xy 10,20
			MOSTRA string_nome2
			goto_xy 10,21
			mov Tempo_limite,160
			goto_xy 60,0
			MOV		STR12[3],'/'
			MOV		STR12[4],'1'
			MOV		STR12[5],'6'
			MOV		STR12[6],'0'
			MOV 	STR12[7],'$'
			goto_xy 2,0
			mostra nivel2
			
		
nivel2_ciclo:
			goto_xy POSxa,POSya
			mov 	ah,02
			mov 	dl,Car
			int 	21h
			goto_xy	POSx,POSy		; Vai para nova possi��o
			mov 	ah, 08h
			mov		bh,0			; numero da p�gina
			int		10h	
			mov 	car, al			; Guarda o Caracter que est� na posi��o do Cursor
			mov		Cor, ah	

			xor 	si,si
			xor 	dx,dx

			mov 	DL,String_nome2[si]
			cmp 	car, Dl
			Je 		Encontra_N2POS1

			mov 	DL,String_nome2[si+1]
			cmp 	car, Dl
			Je 		Encontra_N2POS2

			mov 	DL,String_nome2[si+2]
			cmp 	car, Dl
			Je 		Encontra_N2POS3

			mov DL,String_nome2[si+3]
			cmp 	car, Dl
			Je Encontra_N2POS4
nivel2_next:
			call PROSSEGUIR
			cmp ax,27 ;Esc
			Jne nivel2_ciclo
			je fim	
Encontra_N2POS1:
			mov Construir_nome[0],DL ;I
			inc indice_nome
			goto_xy 10,21
			MOSTRA Construir_nome
			goto_xy POSxa, POSya
			mov car, " "
			cmp indice_nome,4
			je nivel3_start
			jmp nivel2_next
Encontra_N2POS2:
			mov Construir_nome[1],DL ;S
			inc indice_nome
			goto_xy 10,21
			MOSTRA Construir_nome
			goto_xy POSxa, POSya
			mov car, " "
			cmp indice_nome,4
			je nivel3_start
			jmp nivel2_next
Encontra_N2POS3:
			mov Construir_nome[2],DL ; 'E'
			inc indice_nome
			goto_xy 10,21
			MOSTRA Construir_nome
			goto_xy POSxa, POSya
			mov car, " "
			cmp indice_nome,4
			je nivel3_start
			jmp nivel2_next
Encontra_N2POS4:
			mov Construir_nome[3],DL ;'C'
			inc indice_nome
			goto_xy 10,21
			MOSTRA Construir_nome
			goto_xy POSxa, POSya
			mov car, " "
			cmp indice_nome,4
			je nivel3_start
			jmp nivel2_next
jogo_menu2:
			call apaga_ecran

;******************************************************
; _   _   _____  __      __  ______   _        ____   *
;| \ | | |_   _| \ \    / / |  ____| | |      |___ \  *
;|  \| |   | |    \ \  / /  | |__    | |        __) | *
;| . ` |   | |     \ \/ /   |  __|   | |       |__ <  *
;| |\  |  _| |_     \  /    | |____  | |____   ___) | *
;|_| \_| |_____|     \/     |______| |______| |____/  *
;******************************************************
;-----------------------5LETRAS------------------------
nivel3_start:
			call cursorRandom
			call resetvars
			goto_xy 10,20
			MOSTRA string_nome3
			goto_xy 10,21
			mov Tempo_limite,140
			goto_xy 60,0
			MOV		STR12[3],'/'
			MOV		STR12[4],'1'
			MOV		STR12[5],'4'
			MOV		STR12[6],'0'
			MOV 	STR12[7],'$'
			goto_xy 2,0
			mostra nivel3
		
nivel3_ciclo:
			goto_xy POSxa,POSya
			mov 	ah,02
			mov 	dl,Car
			int 	21h
			goto_xy	POSx,POSy		; Vai para nova possi��o
			mov 	ah, 08h
			mov		bh,0			; numero da p�gina
			int		10h	
			mov 	car, al			; Guarda o Caracter que est� na posi��o do Cursor
			mov		Cor, ah	

			xor 	si,si
			xor 	dx,dx

			mov 	DL,String_nome3[si]
			cmp 	car, DL
			Je 		Encontra_N3POS1

			mov 	DL,String_nome3[si+1]
			cmp 	car, DL
			Je 		Encontra_N3POS2

			mov 	DL,String_nome3[si+2]
			cmp 	car, DL
			Je 		Encontra_N3POS3

			mov 	DL,String_nome3[si+3]
			cmp 	car, DL
			Je 		Encontra_N3POS4

			mov 	DL,String_nome3[si+4]
			cmp 	car, DL
			Je 		Encontra_N3POS5
nivel3_next:
			call PROSSEGUIR
			cmp ax,27 ;Esc
			Jne nivel3_ciclo
			je fim	
Encontra_N3POS1:
			mov Construir_nome[0],DL ;'A'
			inc indice_nome
			goto_xy 10,21
			MOSTRA Construir_nome
			goto_xy POSxa, POSya
			mov car, " "
			cmp indice_nome,5
			je nivel4_start
			jmp nivel3_next
Encontra_N3POS2:
			mov Construir_nome[1],DL ;'L'
			inc indice_nome
			goto_xy 10,21
			MOSTRA Construir_nome
			goto_xy POSxa, POSya
			mov car, " "
			cmp indice_nome,5
			je nivel4_start
			jmp nivel3_next
Encontra_N3POS3:
			mov Construir_nome[2],DL ;'U'
			inc indice_nome
			goto_xy 10,21
			MOSTRA Construir_nome
			goto_xy POSxa, POSya
			mov car, " "
			cmp indice_nome,5
			je nivel4_start
			jmp nivel3_next
Encontra_N3POS4:
			mov Construir_nome[3],DL ;'N'
			inc indice_nome
			goto_xy 10,21
			MOSTRA Construir_nome
			goto_xy POSxa, POSya
			mov car, " "
			cmp indice_nome,5
			je nivel4_start
			jmp nivel3_next
Encontra_N3POS5:
			mov Construir_nome[4],DL ;'O'
			inc indice_nome
			goto_xy 10,21
			MOSTRA Construir_nome
			goto_xy POSxa, POSya
			mov car, " "
			cmp indice_nome,5
			je nivel4_start
			jmp nivel3_next
jogo_menu3:
			call apaga_ecran     

;********************************************************
;  _   _   _____  __      __  ______   _        _  _    * 
; | \ | | |_   _| \ \    / / |  ____| | |      | || |   * 
; |  \| |   | |    \ \  / /  | |__    | |      | || |_  * 
; | . ` |   | |     \ \/ /   |  __|   | |      |__   _| *
; | |\  |  _| |_     \  /    | |____  | |____     | |   *
; |_| \_| |_____|     \/     |______| |______|    |_|   *
;													    *
;********************************************************
;-----------------------6LETRAS--------------------------                                                      

nivel4_start:
			call cursorRandom
			call resetvars
			goto_xy 10,20
			MOSTRA string_nome4
			goto_xy 10,21
			mov Tempo_limite,120
			goto_xy 60,0
			MOV		STR12[3],'/'
			MOV		STR12[4],'1'
			MOV		STR12[5],'2'
			MOV		STR12[6],'0'
			MOV 	STR12[7],'$'
			goto_xy 2,0
			mostra nivel4
nivel4_ciclo:
			goto_xy POSxa,POSya
			mov 	ah,02
			mov 	dl,Car
			int 	21h
			goto_xy	POSx,POSy		; Vai para nova possi��o
			mov 	ah, 08h
			mov		bh,0			; numero da p�gina
			int		10h	
			mov 	car, al			; Guarda o Caracter que est� na posi��o do Cursor
			mov		Cor, ah	

			xor 	si,si
			xor 	dx,dx

			mov 	DL, String_nome4[si]
			cmp 	car, DL
			Je 		Encontra_N4POS1

			mov		DL,String_nome4[si+1]
			cmp 	car, DL
			Je 		Encontra_N4POS2

			mov		DL,String_nome4[si+2]
			cmp 	car, DL
			Je 		Encontra_N4POS3

			mov		DL,String_nome4[si+3]
			cmp 	car, DL
			Je 		Encontra_N4POS4

			mov		DL,String_nome4[si+4]
			cmp 	car, DL
			Je 		Encontra_N4POS5

			mov		DL,String_nome4[si+5]
			cmp 	car, DL
			Je 		Encontra_N4POS6
nivel4_next:
			call PROSSEGUIR
			cmp ax,27 ;Esc
			Jne nivel4_ciclo
			je fim	
Encontra_N4POS1:
			mov Construir_nome[0],DL 
			inc indice_nome
			goto_xy 10,21
			MOSTRA Construir_nome
			goto_xy POSxa, POSya
			mov car, " "
			cmp indice_nome,6
			je nivel5_start
			jmp nivel4_next
Encontra_N4POS2:
			mov Construir_nome[1],DL 
			inc indice_nome
			goto_xy 10,21
			MOSTRA Construir_nome
			goto_xy POSxa, POSya
			mov car, " "
			cmp indice_nome,6
			je nivel5_start
			jmp nivel4_next
Encontra_N4POS3:
			mov Construir_nome[2],DL 
			inc indice_nome
			goto_xy 10,21
			MOSTRA Construir_nome
			goto_xy POSxa, POSya
			mov car, " "
			cmp indice_nome,6
			je nivel5_start
			jmp nivel4_next
Encontra_N4POS4:
			mov Construir_nome[3],DL 
			inc indice_nome
			goto_xy 10,21
			MOSTRA Construir_nome
			goto_xy POSxa, POSya
			mov car, " "
			cmp indice_nome,6
			je nivel5_start
			jmp nivel4_next
Encontra_N4POS5:
			mov Construir_nome[4],DL 
			inc indice_nome
			goto_xy 10,21
			MOSTRA Construir_nome
			goto_xy POSxa, POSya
			mov car, " "
			cmp indice_nome,6
			je nivel5_start
			jmp nivel4_next
Encontra_N4POS6:
			mov Construir_nome[5],DL 
			inc indice_nome
			goto_xy 10,21
			MOSTRA Construir_nome
			goto_xy POSxa, POSya
			mov car, " "
			cmp indice_nome,6
			je nivel5_start
			jmp nivel4_next

jogo_menu4:
			call apaga_ecran     

;********************************************************
;  _   _   _____  __      __  ______   _        _____   *
; | \ | | |_   _| \ \    / / |  ____| | |      | ____|  *
; |  \| |   | |    \ \  / /  | |__    | |      | |__    *
; | . ` |   | |     \ \/ /   |  __|   | |      |___ \   *
; | |\  |  _| |_     \  /    | |____  | |____   ___) |  *
; |_| \_| |_____|     \/     |______| |______| |____/   *
;          												*
;********************************************************
;-----------------------7LETRAS--------------------------
                                                     
nivel5_start:
			call cursorRandom
			call resetvars
			goto_xy 10,20
			MOSTRA string_nome5
			goto_xy 10,21
			mov Tempo_limite,100
			goto_xy 60,0
			MOV		STR12[3],'/'
			MOV		STR12[4],'1'
			MOV		STR12[5],'0'
			MOV		STR12[6],'0'
			MOV 	STR12[7],'$'
			goto_xy 2,0
			mostra nivel5
		
nivel5_ciclo:
			goto_xy POSxa,POSya
			mov 	ah,02
			mov 	dl,Car
			int 	21h
			goto_xy	POSx,POSy		; Vai para nova possi��o
			mov 	ah, 08h
			mov		bh,0			; numero da p�gina
			int		10h	
			mov 	car, al			; Guarda o Caracter que est� na posi��o do Cursor
			mov		Cor, ah	

			xor 	si,si
			xor 	dx,dx
			
			mov 	DL,String_nome5[si]
			cmp 	car, DL
			Je 		Encontra_N5POS1

			mov 	DL,String_nome5[si+1]
			cmp 	car, DL 
			Je 		Encontra_N5POS2

			mov 	DL,String_nome5[si+2]
			cmp 	car, DL 
			Je 		Encontra_N5POS3

			mov 	DL,String_nome5[si+3]
			cmp 	car, DL
			Je 		Encontra_N5POS4

			mov 	DL,String_nome5[si+4]
			cmp 	car,DL
			Je 		Encontra_N5POS5

			mov 	DL,String_nome5[si+5]
			cmp 	car,DL
			Je 		Encontra_N5POS6

			mov 	DL,String_nome5[si+6]
			cmp 	car, DL
			Je 		Encontra_N5POS7
nivel5_next:
			call PROSSEGUIR
			cmp ax,27 ;Esc
			Jne nivel5_ciclo
			je fim
Encontra_N5POS1:
			mov Construir_nome[0],DL ;'C'
			inc indice_nome
			goto_xy 10,21
			MOSTRA Construir_nome
			goto_xy POSxa, POSya
			mov car, " "
			cmp indice_nome,7
			je fim_jogo
			jmp nivel5_next
Encontra_N5POS2:
			mov Construir_nome[1],DL ;'O'
			inc indice_nome
			goto_xy 10,21
			MOSTRA Construir_nome
			goto_xy POSxa, POSya
			mov car, " "
			cmp indice_nome,7
			je fim_jogo
			jmp nivel5_next
Encontra_N5POS3:
			mov Construir_nome[2],DL ;'I'
			inc indice_nome
			goto_xy 10,21
			MOSTRA Construir_nome
			goto_xy POSxa, POSya
			mov car, " "
			cmp indice_nome,7
			je fim_jogo
			jmp nivel5_next
Encontra_N5POS4:
			mov Construir_nome[3],DL ;'M'
			inc indice_nome
			goto_xy 10,21
			MOSTRA Construir_nome
			goto_xy POSxa, POSya
			mov car, " "
			cmp indice_nome,7
			je fim_jogo
			jmp nivel5_next
Encontra_N5POS5:
			mov Construir_nome[4],DL ;'B'
			inc indice_nome
			goto_xy 10,21
			MOSTRA Construir_nome
			goto_xy POSxa, POSya
			mov car, " "
			cmp indice_nome,7
			je fim_jogo
			jmp nivel5_next
Encontra_N5POS6:
			mov Construir_nome[5],DL ;'R'
			inc indice_nome
			goto_xy 10,21
			MOSTRA Construir_nome
			goto_xy POSxa, POSya
			mov car, " "
			cmp indice_nome,7
			je fim_jogo
			jmp nivel5_next
Encontra_N5POS7:
			mov Construir_nome[6],DL ;'A'
			inc indice_nome
			goto_xy 10,21
			MOSTRA Construir_nome
			goto_xy POSxa, POSya
			mov car, " "
			cmp indice_nome,7
			je fim_jogo
			jmp nivel5_next
jogo_menu5:
			call apaga_ecran 
                                                    
                                                    
fim:				
			RET
fim_jogo:	
			goto_xy 20,21
			MOSTRA msgWinner
			call LE_TECLA1
			cmp ax,13 ;enter
			je  top10
			jne fim_jogo
top10:
			call TOP10
			

AVATAR		endp

;############################ FIM PLAY ###########################
RESETVARS PROC
				call apaga_ecran
				mov indice_nome,0
				mov bx,0
				mov cx,12
res_vars:
				mov Construir_nome[bx],' '
				inc bx 
				loop res_vars

		
				goto_xy 0,0
				lea dx, Fich1
				call IMP_FICH_Labi
				

				goto_xy posx,POSy
				mov ah,08h
				mov bh,0
				int 10h
				mov cor,ah
				ret
RESETVARS ENDP
CalcAleat proc near
	sub    sp,2
    push    bp
    mov    bp,sp
    push    ax
    push    cx
    push    dx    
    mov    ax,[bp+4]
    mov    [bp+2],ax

    mov    ah,00h
    int    1ah

    add    dx,ultimo_num_aleat
    add    cx,dx    
    mov    ax,65521
    push   dx
    mul    cx
    pop    dx
    xchg    dl,dh
    add    dx,32749
    add    dx,ax

    mov    ultimo_num_aleat,dx

    mov    [BP+4],dx

    pop    dx
    pop    cx
    pop    ax
    pop    bp
    ret
CalcAleat endp


;********************************************************
;  _______    ____    _____    __    ___                *
; |__   __|  / __ \  |  __ \  /_ |  / _ \               *
;    | |    | |  | | | |__) |  | | | | | |              *
;    | |    | |  | | |  ___/   | | | | | |              *
;    | |    | |__| | | |       | | | |_| |              *
;    |_|     \____/  |_|       |_|  \___/               *
;                                                       *
;********************************************************                                         
                                                               
TOP10 proc
			xor 	AX,AX
			call 	apaga_ecran
			GOTO_XY 0,0
			call 	IMP_FICH_TOP10
			goto_xy 0,23
			MOSTRA 	msgNome
			mov 	cx,10
ler_string:
		
			mov		ah,01
			int 	21h
			cmp		al,32 ;space
			je		fim
			mov 	StrNome[si],al
			inc		si
			loop 	ler_string

fim:		
			goto_xy 8,2
			MOSTRA 	StrNome
			goto_xy 0,23
			ret
gestao_pontos:
			mov 	pontos,'0'
			goto_xy 17,2
			mostra 	pontos		

	
TOP10 endp


Help proc
		call 	apaga_ecran
		GOTO_XY 0,0
		call 	IMP_FICH_help
		ret
Help endp
;############################# IMPRIMIR LABIRINTO ##################
IMP_FICH_Labi	PROC
        mov     ah,3dh
        mov     al,0
        lea     dx,Fich
        int     21h
        jc      erro_abrir
        mov     HandleFich,ax
        jmp     ler_ciclo

erro_abrir:
        mov     ah,09h
        lea     dx,Erro_Open
        int     21h
        jmp     sai_f

ler_ciclo:
        mov     ah,3fh
        mov     bx,HandleFich
        mov     cx,1
        lea     dx,car_fich
        int     21h
		jc		erro_ler
		cmp		ax,0		;EOF?
		je		fecha_ficheiro
        mov     ah,02h
		mov		dl,car_fich
		int		21h
		jmp		ler_ciclo

erro_ler:
        mov     ah,09h
        lea     dx,Erro_Ler_Msg
        int     21h

fecha_ficheiro:
        mov     ah,3eh
        mov     bx,HandleFich
        int     21h
        jnc     sai_f

        mov     ah,09h
        lea     dx,Erro_Close
        Int     21h
sai_f:	
		RET		
IMP_FICH_Labi	endp	
;################################### FIM ##########################

;############################# IMPRIMIR TOP10 #####################
IMP_FICH_TOP10	PROC
        mov     ah,3dh
        mov     al,0
        lea     dx,Fich1
        int     21h
        jc      erro_abrir
        mov     HandleFich,ax
        jmp     ler_ciclo

erro_abrir:
        mov     ah,09h
        lea     dx,Erro_Open
        int     21h
        jmp     sai_f

ler_ciclo:
        mov     ah,3fh
        mov     bx,HandleFich
        mov     cx,1
        lea     dx,car_fich
        int     21h
		jc		erro_ler
		cmp		ax,0		;EOF?
		je		fecha_ficheiro
        mov     ah,02h
		mov		dl,car_fich
		int		21h
		jmp		ler_ciclo

erro_ler:
        mov     ah,09h
        lea     dx,Erro_Ler_Msg
        int     21h

fecha_ficheiro:
        mov     ah,3eh
        mov     bx,HandleFich
        int     21h
        jnc     sai_f

        mov     ah,09h
        lea     dx,Erro_Close
        Int     21h
sai_f:	
		RET		
IMP_FICH_TOP10	endp	
;################################### FIM ##########################

;############################# IMPRIMIR  help #####################
IMP_FICH_help	PROC
        mov     ah,3dh
        mov     al,0
        lea     dx,Fich2
        int     21h
        jc      erro_abrir
        mov     HandleFich,ax
        jmp     ler_ciclo

erro_abrir:
        mov     ah,09h
        lea     dx,Erro_Open
        int     21h
        jmp     sai_f

ler_ciclo:
        mov     ah,3fh
        mov     bx,HandleFich
        mov     cx,1
        lea     dx,car_fich
        int     21h
		jc		erro_ler
		cmp		ax,0		;EOF?
		je		fecha_ficheiro
        mov     ah,02h
		mov		dl,car_fich
		int		21h
		jmp		ler_ciclo

erro_ler:
        mov     ah,09h
        lea     dx,Erro_Ler_Msg
        int     21h

fecha_ficheiro:
        mov     ah,3eh
        mov     bx,HandleFich
        int     21h
        jnc     sai_f

        mov     ah,09h
        lea     dx,Erro_Close
        Int     21h
sai_f:	
		RET		
IMP_FICH_help	endp	

LE_TECLA1	PROC
		mov		ah,08h
		int		21h
		mov		ah,0
		cmp		al,0
		jne		SAI_TECLA
		mov		ah, 08h
		int		21h
		mov		ah,1
		
SAI_TECLA: RET
LE_TECLA1	endp

;###################### Detetar as paredes ##########################
Verifica_cim proc
			mov al,POSy
			mov POSyn,al
			dec POSyn
			goto_xy POSx,POSyn
			mov ah,08h
			mov bh,0
			int 10h
			mov CaracterTXT,al
			cmp CaracterTXT,177
			je return
			mov al,POSyn
			mov POSy,al
			jmp return
	return:
			ret
Verifica_cim endp
Verifica_baixo proc
			mov al,POSy
			mov POSyn,al
			Inc POSyn
			goto_xy POSx,POSyn
			mov ah,08h
			mov bh,0
			int 10h
			mov CaracterTXT,al
			cmp CaracterTXT,177
			je return
			mov al,POSyn
			mov POSy,al
			jmp return
	return:
				ret
Verifica_baixo endp
Verifica_direita proc

			mov al,POSx
			mov POSxn,al
			inc POSxn
			goto_xy POSxn,POSy
			mov ah,08h
			mov bh,0
			int 10h
			mov CaracterTXT,al
			cmp CaracterTXT,177
			je return
			mov al,POSxn
			mov POSx,al
			jmp return
			
	return:
				ret
Verifica_direita endp
Verifica_esquerda proc

			mov al,POSx
			mov POSxn,al
			DEC POSxn
			goto_xy POSxn,POSy
			mov ah,08h
			mov bh,0
			int 10h
			mov CaracterTXT,al
			cmp CaracterTXT,177
			je return
			mov al,POSxn
			mov POSx,al
			jmp return
			
	return:
				ret
Verifica_esquerda endp

;############################### FIM DETETA PAREDES ########################
Timer proc

		PUSHF
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX		

		CALL 	Ler_TEMPO				; Horas MINUTOS e segundos do Sistema
		
		MOV		AX, Segundos
		
		cmp		AX, Old_seg			; VErifica se os segundos mudaram desde a ultima leitura
		je		fim_horas			; Se a hora não mudou desde a última leitura sai.
		mov		Old_seg, AX			; Se segundos são diferentes actualiza informação do tempo 
		
		
		mov 	ax,Tempo_limite
		Dec 	Tempo_limite
		mov 	bl,100
		div	 	bl
		mov 	bh,al     ;AL Quociente
		add 	bh,30h
		
		mov 	al,ah 				;AH Resto
		xor	 	ah,ah
		MOV 	bl, 10     
		div 	bl
		add 	al, 30h				; Caracter Correspondente às dezenas
		add		ah,	30h				; Caracter Correspondente às unidades
		MOV 	STR12[0],bh			; 
		MOV 	STR12[1],al	
		MOV 	STR12[2],ah	;bh
		MOV		STR12[3],'/'
		GOTO_XY	60,0
		MOSTRA	STR12 
		cmp Tempo_limite,0
		je ciclo
		jne fim_horas

		
ciclo:
		goto_xy 20,21
		MOSTRA Fim_Perdeu
		call LE_TECLA1
		cmp ax, 27
		JE fim
fim_horas:		
		goto_xy	POSx,POSy			; Volta a colocar o cursor onde estava antes de actualizar as horas
		
		POPF
		POP DX		
		POP CX
		POP BX
		POP AX
		ret
fim:
		mov ah,0
   		mov ah,4ch
    	int 21h
		
	
Timer endp
main proc
		mov ax, dseg
		mov ds, ax
		; CODIGO...
		xor ah,ah
		xor si,si
		xor bh,bh
		
aqui:		
		call clear_screen
		call display_menu
		
		lea dx,msg1 		;---Espera que o utilizador introdduza o numero
		mov ah,09 			;Output string
		int 21h   
		
		call LE_TECLA1

		CMP al,'1'
		jne continua
		call Play
		call clear_screen
continua:
     
     CMP al,'2'
     jne continua2
     call TOP10  
continua2:
     
     CMP al,'3'
     jne continua3
     call help 
continua3:
          
     CMP al,'4'
     JE Exit
	loop aqui
	

     
Exit:
     mov ah,0
     mov ah,4ch
     int 21h

          
main endp
cseg ends
end main 
