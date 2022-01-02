;================================================= MACROS ======================================================= ;
PrintChar MACRO chara
	;draw X in the cursor position
	mov ah,0ah
	mov al,chara
	mov bh,0h
	mov bl,0fh
	mov cx,1
	int 10H
ENDM PrintChar
PrintChar_black MACRO chara
	;draw X in the cursor position
    mov ah,0ah
    mov al,chara
    mov bh,0h
    mov bl,0h
    mov cx,1
    int 10H
ENDM PrintChar_black
Set MACRO Yposition, Xposition
    mov cx,0
    ;set cursor position
    mov ah,2h
    mov bh,0h
    mov dh,Yposition
    mov dl,Xposition
    int 10h
ENDM Set
draw_obj MACRO colr
	;draw X in the cursor position
    mov ah,0ah
    mov al,'o'
    mov bh,0h
    mov bl,colr
    mov cx,1
    int 10H
ENDM draw_obj
;================================================================================================================
.MODEL HUGE
;----------------
.STACK 64
;================================================================================================================
.DATA
	; ----------------------------------------------- GUI Variables --------------------------------------------- ;
		; Define the variables
		X2position db 9
		Xposition db 8
		inputKey db ?
		Xbullet db 8
		Ybullet db 18
		X_Arr db 2,2,3,3,5,5,6,6
		; Y_Arr db 6 dup(?)
	
	; --------------------------------------------- Interface Variables ----------------------------------------- ;
		MESG3   DB     "Please, Enter Your Name: $"
		MESG4   DB     "Press Any Key to Start the Game...$"
		MESG6   DB     "Initial Points : $"
		MESG7   DB     "Level 1 OR 2 : $"
		MESG8   DB     "What is the forbidden Character? $"
		CHOICE2 DB     "Start Chatting$"
		CHOICE1 DB     "Start The Journey$"
		CHOICE3 DB     "Exit if you are afraid$"
		BORDER1  DB     10,13," ------------------------------------------------------------------------------"
				DB     10,13,"**                     #    WELCOME TO MP Project Game    #                  **"
				DB     10,13," ------------------------------------------------------------------------------$"
		BORDER2  DB     10,13," ------------------------------------------------------------------------------"
				DB     10,13,"**                           #  BE READY AND SMART  #                         **"
				DB        " ------------------------------------------------------------------------------$"
		BORDER3  DB     10,13,"------------------------------------------------------------------------------"
				DB     10,13,"**                          #  Notification Bar  #                           **"
				DB           " ------------------------------------------------------------------------------$"
		NAMEP1  DB     16 DUP('$')
		NAMEP1LEN   DW  0
		NAMEP2  DB     16 DUP('$')
		NAMEP2LEN   DW  0
		NAMELENGTH  DW  0
		InitialPoints DB 0
		InitialPointsP1 DB 0
		InitialPointsP2 DB 0
		CHOSEN  DB     1    ; CHOSEN CHOICE IN THE MAIN SCREEN 
		P1_SCORE    DB  0
		P2_SCORE    DB  0
	;------------------------------------------------ Chat Variables -------------------------------------------- ;
		invrecieve    db ?
		invsend    db ?
		firs_half   dw 0400h
		Xsend db ?
		Yrecieve db ?
		sec_half    dw 0f00h
		border    db    "--------------------------------------------------------------------------------"
				db    "*****                       BOTH PLAYERS ARE ONLINE                        *****"
				db    "--------------------------------------------------------------------------------$"
		Line	  db    "--------------------------------------------------------------------------------$"
	;----------------------------------------- Serial Communication VARIABLES ----------------------------------- ;
		Char_Send    DB   ? 
		Char_Recieve DB   ? 
		Exit_Chat    DB   0
		forbiddenCharP1 DB 0
		forbiddenCharP2 DB 0
		LEVEL           DB 0
;===============================================================================================================
.CODE
MAIN PROC FAR
    MOV AX,@DATA                     ; LOAD THE DATA VARIABLES
    MOV DS,AX     
    MOV ES,AX
    MAIN_MENU: 
	;---------------------------------------------------------------------------------------------------------------------------------------
    MOV AH,0                         ; CHOOSING VIDEO MODE "TEXT MODE"
    MOV AL,3                         ; 80 X 25 CHARS
    INT 10H   
    ;----------------------------------------------Taking PLAYERS' NAMES--------------------------------------------------------------------
	Call configuration               ; This procedure is used for initializing the UART (baud rate: The baud rate is the rate
                                     ; at which information is transferred in a communication channel, parity, data bits, stop bits,…)
	MOV DL, 1                        ; INITIALIZING THE COORDIANATES OF THE CURSOR 
	MOV DH, 1
	CALL MOVECURSOR                  
	MOV DX,OFFSET BORDER1
	CALL PRINTMESSAGE                ; DRAW THE BORDERS OF THE SCREEN
	MOV DL, 0                        ; INITIALIZING THE COORDIANATES OF THE CURSOR 
	MOV DH, 22
	CALL MOVECURSOR
	MOV DX,OFFSET BORDER2
	CALL PRINTMESSAGE                ; DRAW THE BORDERS OF THE SCREEN
	MOV BP, OFFSET  NAMEP1           ; SAVE THE NAME OF THE FIRST PLAYER IN NAMEP1
	CALL FIRSTSCREEN                 ; CALL THE FIRST SCREEN OF THE PROJECT       
	MOV DX, NAMELENGTH             
	MOV NAMEP1LEN, DX     
	MOV NAMELENGTH,0
	MOV DH , InitialPoints
	MOV InitialPointsP1, DH
	CALL CLEARSCREEN                 
	MOV DL, 1
	MOV DH, 1
	CALL MOVECURSOR
	MOV DX,OFFSET BORDER1
	CALL PRINTMESSAGE
	MOV DL, 0
	MOV DH, 22
	CALL MOVECURSOR
	MOV DX,OFFSET BORDER2
	CALL PRINTMESSAGE
	MOV BP, OFFSET   NAMEP2         ; SAVE THE NAEM OF THE SECOND PLAYER IN NAEMP2
	CALL FIRSTSCREEN
	MOV DX, NAMELENGTH
	MOV NAMEP2LEN, DX
	MOV NAMELENGTH,0
	MOV BH , InitialPoints
	MOV InitialPointsP2, BH
	CALL CLEARSCREEN
    ;---------------------------------------------------------------------------------------------------------------------------------------	
	BACK_TO_MAIN_SCREEN:
		MOV Exit_Chat , 0
		MOV firs_half , 0400h
		MOV sec_half , 0f00h
		CALL MAINSCREEN                              ; CALLING THE MAIN SCREEN MENU 
		MOV AH,1                                     ; GET KEY PRESSED WITHOUT WAITING 
		INT 16H
		JZ BACK_TO_MAIN_SCREEN                       ; JUMP TO MAIN SCREEN IF THERE IS NO KEY PRESSED 
		MOV AH,0									 ; CONSUME THE ENTERED KEY FROM THE KEYBOARD BUFFER
		INT 16H
		CMP AX,1C0DH                                 ; CHECK IF THE ENTERED KEY IS THE ENTER KEY 
		JE  NEXTSCREEN                               ; JUMP IF THE ENTERED KEY IS PRESSED 
		CALL CHECKCHOICE                             ; CALL CHECKCHOICE TO NAVIGATE THE CHOICES 
		JMP BACK_TO_MAIN_SCREEN
	NEXTSCREEN: 
		CMP  CHOSEN,1
		JNE CHECK_CHAT
	GAME_AGAIN:
		CALL GAME  
		MOV BH , InitialPointsP1
		MOV BL , InitialPointsP2
		CMP BL, BH
		JB TAKE_PLAYER2POINTS
		MOV P1_SCORE, BH
		MOV P2_SCORE, BH
		JMP NEXT_FORWARD
	TAKE_PLAYER2POINTS:
	;	MOV P1_SCORE, BL
	;	MOV P2_SCORE, BL
	NEXT_FORWARD:	                                  ; CALL GAME FUNCTION 
		JMP BACK_TO_MAIN_SCREEN
	CHECK_CHAT:  CMP CHOSEN,2
				JNE EXITP_ROGRAM
				CALL CHATMODE
				JMP BACK_TO_MAIN_SCREEN
	EXITP_ROGRAM:   MOV AH,0                        ; NORMAL TERMINATION OF THE GAME 
					MOV AL,12H 
					INT 10H
					MOV BL,2
					MOV AH,4CH
					INT 21H	
MAIN    ENDP
	
;---------------------------------------------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------------------------------------------
;*************************************************************** Proc Implementation ***************************************************;
;---------------------------------------------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------------------------------------------

;-----------------------------------------------------------MOVE CURSOR FUNCTION-------------------------------------------------------------	
MOVECURSOR    PROC   NEAR
        ; DL HOLDS THE X COORDINATE AND  DH HOLDS THE Y COORDINATE 
			  MOV AH,2
			  MOV AL,0
			  MOV BX,0
			  INT 10H
			  RET
MOVECURSOR	  ENDP
;----------------------------------------------------------PRINT MESSAGE FUNCTION------------------------------------------------------------
PRINTMESSAGE  PROC  NEAR
		; DX HOLDS THE OFFSET OF THE MESSAGE 
			  MOV AH,9
			  MOV AL,0
			  INT 21H
			  RET
PRINTMESSAGE  ENDP	
;--------------------------------------------------------------------------------------------------------------------------------------------
;----------------------------------------------------------------------FIRST SCREEN FUNCTION-------------------------------------------------
FIRSTSCREEN     PROC    NEAR
				MOV DL,25
				MOV DH,10
				CALL MOVECURSOR
				MOV DX, OFFSET MESG3           ; SHOW 'PLEASE, ENTER YOUR NAME' MASSEGE AT DL 'COLUMN' = 25 AND DH 'ROW' = 10
				CALL PRINTMESSAGE
				MOV BX,BP
				CALL READNAME                  ; TAKE THE USER NAME AND MAKE ANY REQUIRED VALIDATIONS 
				MOV DL,25
				MOV DH,12
				CALL MOVECURSOR
				MOV DX, OFFSET MESG6           ; SHOW 'Initial Points: ' AT DL 'COLUMN'= 25 AND DH 'ROW' = 14
				CALL PRINTMESSAGE
				CALL READINITIALPOINT
				MOV DL,25
				MOV DH,14
				CALL MOVECURSOR
				MOV DX, OFFSET MESG4
				CALL PRINTMESSAGE              ; SHOW 'PRESS ANY KEY TO CONTINUE' MASSEGE AT DL 'COLUMN' = 25 AND DH 'ROW' = 10
				MOV AH,0                       ; WAIT FOR A KEY TO PROCEED FOR THE NEXT SCREEN 
				INT 16H
				RET
FIRSTSCREEN     ENDP
;--------------------------------------------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------READ NAME FUNCTION---------------------------------------------------------------
READNAME     PROC     NEAR
             MOV CX,15                           ; LOOP TILL THE TOTAL VALID CHARACTERS INPUT ARE 15
             MOV SI,0                            ; INITIALIZE SI WITH 0 TO USE IT AS A POINTER 
CHECK_FIRST_CHARACTER: MOV AH,0                  ; WAIT FOR KEY TO BE PRESSED 
    		 INT 16H 
			 CMP AL,41H                          ; CHECK IF IT WITHIN THE ALPHABET LETTERS  'A' = 41H
			 JB CHECK_FIRST_CHARACTER                             
			 CMP AL,5AH                          ; IF IT WAS LESS THAN 'Z' = 5AH, SO IT IS A VALID FIRST CHARACTER 
			 JB VALID_FIRST_CHAR
			 CMP AL,61H
			 JB CHECK_FIRST_CHARACTER
			 CMP AL,7AH
			 JA CHECK_FIRST_CHARACTER
TAKE_ANOTHER_INPUT: MOV AH,0
    		 INT 16H
    		 CMP AX,1C0DH                        ; CHECK IF THE PRESSED KEY IS ENTER TO END ENTERING NAME 
    		 JZ END_TYPING 
			 CMP AX, 0E08H                       ; CHECK IF THE PRESSED KEY IS BACKSPACE
			 JZ  DELETE_CHAR
VALID_FIRST_CHAR: MOV [BX+SI],AL                 ; AFTER ALL VALIDATIONS ADD THE LETTER TO THE PLAYER NAME 
             INC SI
			 INC NAMELENGTH  
             MOV DL,AL                           ; PRINT THE VALID INPUT CHARACTER 
             MOV AH,2
             INT 21H
     		LOOP TAKE_ANOTHER_INPUT
			JMP END_TYPING
DELETE_CHAR: 
			DEC NAMELENGTH
			DEC SI
			INC CX
			MOV DL,08H                          ; IN ORDER TO REMOVE THE CHARACTER 
            MOV AH,2                            ; BACKSPACE WAS FIRST PRINTED 
            INT 21H
			MOV DL,' '                          ; THEN SPACE WAS PRINTED 
            MOV AH,2
            INT 21H
			MOV DL, "$"
			MOV [BX+SI],DL                      ; OVERRIDE THE DATA SAVED PREVIUOSY 
			MOV DL,08H                          ; THEN BACKSPACE AGAIN "NOTE: BACKSPACE ONLY BRING THE CURSOR OF TYPING ONE CHAR BACK WITHOUT DELETING" 
            MOV AH,2
            INT 21H
			CMP CX, 15
			JZ CHECK_FIRST_CHARACTER
			JMP TAKE_ANOTHER_INPUT
END_TYPING:	RET
READNAME	ENDP
;--------------------------------------------------------------------------------------------------------------------------------------------
;-------------------------------------------------------------CLEAR SCREEN FUNCTION----------------------------------------------------------
CLEARSCREEN  PROC  NEAR 
			  MOV AH,0
			  MOV AL,3
			  INT 10H
			  RET
CLEARSCREEN	 ENDP
;--------------------------------------------------------------------------------------------------------------------------------------------
READINITIALPOINT PROC NEAR
			  MOV CX , 0
 New_Num:     MOV AH,0                  ; WAIT FOR KEY TO BE PRESSED 
    		  INT 16H 
			  CMP CX, 0
			  JZ NEXT_CHECK	
			  CMP AX,1C0DH                        ; CHECK IF THE PRESSED KEY IS ENTER TO END ENTERING Points 
    		  JZ END_Point 
			  CMP AX, 0E08H                       ; CHECK IF THE PRESSED KEY IS BACKSPACE
			  JZ  DELETE_NUM
NEXT_CHECK:	  CMP AL,30H
			  JB New_Num
			  CMP AL,39H
			  JA New_Num
			  INC CX
			  MOV DL, AL
			  MOV AH,2
              INT 21H
			  MOV BL, 10D
			  MOV AL, InitialPoints
			  MUL BL
		      MOV InitialPoints, AL
			  ADD InitialPoints, DL
			  JMP New_Num		  
DELETE_NUM: 
		    DEC CX
			MOV DL,08H                          ; IN ORDER TO REMOVE THE CHARACTER 
            MOV AH,2                            ; BACKSPACE WAS FIRST PRINTED 
            INT 21H
			MOV DL,' '                          ; THEN SPACE WAS PRINTED 
            MOV AH,2
            INT 21H
			MOV DL,08H                          ; THEN BACKSPACE AGAIN "NOTE: BACKSPACE ONLY BRING THE CURSOR OF TYPING ONE CHAR BACK WITHOUT DELETING" 
            MOV AH,2
            INT 21H
			JMP New_Num
END_Point:  RET
READINITIALPOINT ENDP
;----------------------------------------------------------------MAINSCREEN FUNCTION---------------------------------------------------------
MAINSCREEN     PROC    NEAR
				XOR BH,BH                     ; BH = 0, PAGE NUMBER = 0
                LEA BP,CHOICE1                ; LOAD THE OFFSET THE FIRST CHOICE TO BE PRINTED AT THE SCREEN AT THE DESIRED COORDINATES 
				MOV DL,25                     
				MOV DH,10
				MOV AH,13h 
				MOV AL,0
				MOV Bl,0FH                    ; COLOR OF THE CHOICE " WHITE "
				MOV CX,11H
				CMP CHOSEN,1                  ; IF CHOSEN = 1 'CHOISE FROM THE USER', THEN COLOR IT BY GREEN 'BL = 02H'
				JNE OPTION_1_NOT_CHOSEN
				MOV Bl,02                    
OPTION_1_NOT_CHOSEN:  INT 10H                 ; PRINT THE CHOISE WITH THE INTENDED COLOR
				LEA BP,CHOICE2      
				MOV DL,25
				MOV DH,12
				MOV AH,13h
				MOV AL,0 
				MOV Bl,0FH 
				MOV CX,0EH
				CMP CHOSEN,2                  ; IF CHOSEN = 2 'CHOISE FROM THE USER', THEN COLOR IT BY GREEN 'BL = 02H'
				JNE OPTION_2_NOT_CHOSEN        
				MOV Bl,02        
OPTION_2_NOT_CHOSEN: INT 10H                  ; PRINT THE CHOISE WITH THE INTENDED COLOR
				LEA BP,CHOICE3      
				MOV DL,25
				MOV DH,14
				MOV AH,13h
				MOV AL,0 
				MOV Bl,0FH 
				MOV CX,16H
				CMP CHOSEN,3                  ; IF CHOSEN = 3 'CHOISE FROM THE USER', THEN COLOR IT BY GREEN 'BL = 02H'
				JNE OPTION_3_NOT_CHOSEN         
				MOV Bl,02        
OPTION_3_NOT_CHOSEN: INT 10H                  ; PRINT THE CHOISE WITH THE INTENDED COLOR
				MOV DL, 0                     ; PRINT THE NAVIGATION BAR HEADER BORDER AT THE GIVEN LOCATION  
				MOV DH, 17                    
				CALL MOVECURSOR
				MOV DX,OFFSET BORDER3
				CALL PRINTMESSAGE
				MOV DL,80                     ; MOVE TEH CURSOR TOP LEFT CORNER OF THE ENTIRE PAGE 
				MOV DH,0
				MOV AH,2
				INT 10H	
				RET
MAINSCREEN      ENDP
;--------------------------------------------------------------------------------------------------------------------------------------------
;------------------------------------------------------------CHECK CHOICES OF THE MAIN MENU SCREEN-------------------------------------------
CHECKCHOICE      PROC   NEAR
	            CMP AX,5000H              ;IF THE PRESSED KEY IS THE DOWN ARROW
				JNE OPTION2         
                INC [CHOSEN]              ;INCREMENT THE CHOSEN VARIABLE
				JMP CHECK1
OPTION2:	    CMP AX,4800H              ;IF NOT DOWN CHECK IF IT WAS UP ARROW
				JNE END_CHECKCHOICE
                DEC [CHOSEN]              ;DECREMENT THE CHOSEN VARIABLE
				JMP CHECK2
CHECK1:			CMP CHOSEN,4              ; IF THE NUMBER INCREASED TO 4 INITIALIZE IT TO 1 FOR THE FIRST CHOICE" WE HAVE ONLY THREE CHOICES"
				JNE END_CHECKCHOICE
				MOV CHOSEN,1
				JMP END_CHECKCHOICE
CHECK2:		    CMP CHOSEN,0              ; IF THE NUMBER DECREASE TO 0 INITIALIZE IT TO 3 FOR THE LAST(THIRD ONE) CHOICE" WE HAVE ONLY THREE CHOICES"
				JNE END_CHECKCHOICE
				MOV CHOSEN,3
END_CHECKCHOICE: RET
CHECKCHOICE	    ENDP
;--------------------------------------------------------------------------------------------------------------------------------------------
;--------------------------------------------------------CHAT MODULE FUNCTIONS-------------------------------------------------
CHATMODE            PROC  NEAR
	
	mov ax , @data
	mov ds , ax
	mov ah,2 ;cursor up 
    mov dx,0000h
	int 10h 
	MOV DX, OFFSET border
	CALL PRINTMESSAGE
	mov ah,2 ;cursor up 
    mov dx,0E00h
	int 10h 
	MOV DX, OFFSET LINE
	CALL PRINTMESSAGE
	
	mov ah,2 		    ;cursor up 
    mov dx,0400h
	int 10h 
	
	mov bl,0
	mov ax,0600h
	mov bh,00fh         ; font and screen colour
	mov cx,0400H        ;first half
	mov dx,0d4fh		
	int 10h	

	mov bl,0
	mov ax,0600h
	mov bh,00Fh       ;font and screen colour
	mov cx,0F00h      ;second half
	mov dx,184fh
	int 10h
	mov bh,0  
	; call configuration;first thing to do
IsSenT:
	mov dx , 3FDH    ; check Line Status Register 
	in al , dx 
  	and al , 1
  	JZ next          ; There is no recieved data
	call Receive     ;if ready read the value in received data register
	CMP Exit_Chat, 1
	JZ exitchat
	mov al,1 
	mov dx , 3FDH 
    out dx,al   
next:
	mov ah,1
	int 16h			 ;check if character available in buffer
    jz IsSenT        ; no char is written
    mov ah,0         ;lw buffer not empty asci in al,scan in ah
	int 16h          ;get key pressed
	call Send
	CMP Exit_Chat, 1
	JZ exitchat
	jmp IsSenT
  	
exitchat: CALL CLEARSCREEN 	
				ret  
							  
CHATMODE        ENDP
;-----------------------------------------------------------------------------------------------------------------------------					  
Send 				Proc near 
	mov Xsend,al;if esc was clicked so exit
	cmp al,27
    jnz continue
	mov dx ,3FDH		; Line Status Register, to send data check if THR empty or not
	AGAIN11:
  	In al,dx 			;Read Line Status
	and al , 00100000b
	jz AGAIN11

	mov dx , 3F8H		; (if empty)Transmit data register
    mov  al,Xsend
  	out dx , al 
	MOV Exit_Chat, 1
	RET
	
	CMP AX, 0E08H
	JNZ continue
	MOV Xsend, 08H
	JMP sDisplay
	
	
continue:	
	mov ah,79
	cmp byte ptr firs_half,ah
	jb snot_end_x

	mov ah,0Dh
	cmp byte ptr firs_half[1],ah
	jb sDisplay

	mov word ptr firs_half,0D00h
	mov ah,2
	mov dx,word ptr firs_half   ;setting cursor
	int 10h 
	mov bl,0
	mov ax,0601h
	mov bh,00Fh       ;scrolling one line
	mov cx,0400h
	mov dx,0D4fh
	int 10h
	jmp sDisplay

snot_end_x:

	mov ah,0Dh
	cmp byte ptr firs_half[1],ah 
	jb scheck_enter
	cmp al,0Dh
	jne sDisplay
	mov word ptr firs_half,0D00h
	mov bl,0
	mov ax,0601h
	mov bh,00Fh
	mov cx,0400h
	mov dx,0D4fh
	int 10h
	jmp sDisplay

scheck_enter:
	cmp al,0dh
	jne sDisplay
	mov byte ptr firs_half,00h	
	inc byte ptr firs_half[1]	
	jmp sDisplay
	
sDisplay:
	mov ah,2
	mov dx,word ptr firs_half
	int 10h 
	CMP Xsend, 08H
	JNZ PRINT_CHAR_MES
	MOV DL,08H                          ; IN ORDER TO REMOVE THE CHARACTER 
    MOV AH,2                            ; BACKSPACE WAS FIRST PRINTED 
    INT 21H
    MOV DL,' '                          ; THEN SPACE WAS PRINTED 
    MOV AH,2
    INT 21H
	MOV DL,08H                          ; IN ORDER TO REMOVE THE CHARACTER 
    MOV AH,2                            ; BACKSPACE WAS FIRST PRINTED 
    INT 21H
	JMP NEXT_STEP
PRINT_CHAR_MES:
	mov dl , Xsend;print char
	mov ah ,2 
  	int 21h
NEXT_STEP:
	mov ah,3h 
	mov bh,0h    ;getting cursor position
	int 10h
	mov word ptr firs_half,dx

	mov dx ,3FDH		; Line Status Register, to send data check if THR empty or not
	AGAIN1:
  	In al,dx 			;Read Line Status
	and al , 00100000b
	jz AGAIN1

	mov dx , 3F8H		; (if empty)Transmit data register
    mov  al,Xsend
  	out dx , al 
	ret
Send    			endp
;-----------------------------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------------------------
Receive 			proc near 
	mov dx , 03F8H
	in al , dx 
	mov Yrecieve , al
	cmp al,27               ; esc was clicked 
	jz buffer
	
	mov ah,79
	cmp byte ptr sec_half,ah
	jb rnot_end_x

	mov ah,18h
	cmp byte ptr sec_half[1],ah
	jb rDisplay

	mov word ptr sec_half,1800h
	mov ah,2
	mov dx,word ptr sec_half
	int 10h 

	mov bl,0
	mov ax,0601h
	mov bh,00Fh
	mov cx,0F00h      ;scrolling one line
	mov dx,184fh
	int 10h
	jmp rDisplay
buffer:
    MOV Exit_Chat, 1
	RET
rnot_end_x:

	mov ah,18h
	cmp byte ptr sec_half[1],ah
	jb rcheck_enter
	cmp al,0Dh
	jne rDisplay
	mov word ptr sec_half,1800h
	mov bl,0
	mov ax,0601h
	mov bh,00Fh
	mov cx,0F00h
	mov dx,184fh
	int 10h
	jmp rDisplay

rcheck_enter:
	cmp al,0Dh
	jne rDisplay
	mov byte ptr sec_half,00h	
	inc byte ptr sec_half[1]	
	jmp rDisplay
	
rDisplay:
	mov ah,2
	mov dx,word ptr sec_half
	int 10h 
	CMP Yrecieve, 08H
	JNZ PRINT_CHAR_2
	MOV DL,08H                          ; IN ORDER TO REMOVE THE CHARACTER 
    MOV AH,2                            ; BACKSPACE WAS FIRST PRINTED 
    INT 21H
    MOV DL,' '                          ; THEN SPACE WAS PRINTED 
    MOV AH,2
    INT 21H
	MOV DL,08H                          ; IN ORDER TO REMOVE THE CHARACTER 
    MOV AH,2                            ; BACKSPACE WAS FIRST PRINTED 
    INT 21H
	JMP NEXT_STEP_2
PRINT_CHAR_2:
 mov dl , Yrecieve
	mov ah ,2 
  	int 21h
NEXT_STEP_2:	
	mov ah,3h 
	mov bh,0h 
	int 10h
	mov word ptr sec_half,dx
	ret
Receive 			endp
;-----------------------------------------------------------------------------------------------------------------------------
configuration 		Proc near
					mov dx,3fbh 			; Line Control Register
					mov al,10000000b		;Set Divisor Latch Access Bit
					out dx,al			    ;Out it
				
					mov dx,3f8h	            ;set lsb byte of the baud rate devisor latch register	
					mov al,0ch		 	
					out dx,al
				
					mov dx,3f9h             ;set msb byte of the baud rate devisor latch register
					mov al,00h              ;to ensure no garbage in msb it should be setted
					out dx,al

					mov dx,3fbh             ;used for send and receive
					mov al,00011011b
					out dx,al
					ret
configuration 		endp
;-----------------------------------------------------------------------------------------------------------------------------
Sending_Char        PROC NEAR 
					mov dx , 3FDH            ; Line Status Register
CHECK_AGAIN:        IN  al , dx               ;Read Line Status
					TEST al , 00100000b
					JZ CHECK_AGAIN
					;If empty put the VALUE in Transmit data register
					mov dx , 3F8H ; Transmit data register
					mov al,Char_Send
					OUT dx , al
					RET
Sending_Char        ENDP 
;-----------------------------------------------------------------------------------------------------------------------------
Recieving_Char      PROC NEAR
					;Check that Data is Ready
					mov dx , 3FDH ; Line Status Register
CHK_AGAIN: 			IN al , dx
					TEST al , 1
					JZ CHK_AGAIN ;Not Ready 
					;If Ready read the VALUE in Receive data register
					mov dx , 3F8H
					IN al , dx
					mov Char_Recieve , al
					RET
Recieving_Char      ENDP					
;-----------------------------------------------------------------------------------------------------------------------------										
GAME PROC NEAR 
	GET_ANOTHER_INPUT:	
		MOV AH,0                      ; GO TO GRAPHIC MODE 
		MOV AL,3H
		INT 10H
		MOV DL,25
		MOV DH,10
		CALL MOVECURSOR
		MOV DX, OFFSET MESG7
		CALL PRINTMESSAGE
		MOV AH, 0
		INT 16H 
		CMP AL, 31H                   ; THE LEVEL CHOSEN IS 1
		JNZ LEVEL_2
		MOV LEVEL, 1
		JMP LEVEL_1
	LEVEL_2:
		CMP AL, 32H
		JNZ GET_ANOTHER_INPUT
		;-----------------------------------------------ADD THE NEW FEATURES HERE FOR LEVEL 2-----------------------------------------
		MOV LEVEL, 2
	LEVEL_1:
		MOV DH, 0
		MOV DL, LEVEL					; PRINT THE VALID INPUT CHARACTER 
		ADD DL,30H
		MOV AH,2
		INT 21H
		MOV DL,25
		MOV DH,14
		CALL MOVECURSOR
		MOV DX, OFFSET MESG4
		CALL PRINTMESSAGE				; SHOW 'PRESS ANY KEY TO CONTINUE' MASSEGE AT DL 'COLUMN' = 25 AND DH 'ROW' = 10
		; Wait for a key press to proceed
		MOV AH,0
		INT 16H
		CALL CLEARSCREEN
		CALL GETFORBIDDEN
		MOV forbiddenCharP1, BL
		CALL GETFORBIDDEN
		MOV forbiddenCharP2, BL
		MOV AH,0                      ; GO TO GRAPHICAL MODE 
		MOV AL,13H
		INT 10H
		MOV SI,320                         ; DRAW THE Command Line AT START ROW = 170 AND END ROW = 175
		MOV DI,175                         ; DI = END ROW , DX = START ROW 
		MOV CX,0                           ; CX =START COLUMN , SI = END COLUMN 
		MOV DX,170             
		MOV AL,7                           ; AL = COLOR OF THE GROUND 
		CALL GUI
	SHADI:
	    JMP SHADI
GAME ENDP
;-----------------------------------------------------------------------DRAW FUNCTION--------------------------------------------------------
Draw Proc NEAR
	;  CX = FINAL COLUMN , BX = START COLUMN , DX = FINAL ROW , BP = START ROW , DI = OFFSET IMAGE 
	MOV SI,CX           ; Save the value of CX for further calculations
	JMP StartX    	    ;Avoid drawing before the calculations
	Drawx:
		MOV AH,0Ch   	;set the configuration to writing a pixel
		MOV AL, [DI]     ; color of the current coordinates
		PUSH BX          ; TO SAVE THE VALUE OF BX FOR CALCULATIONS
		MOV BH,00h   	;set the page number
		INT 10h      	;execute the configuration
		POP BX           ; RETURN THE INITIAL VALUE OF BX 
	StartX: 
		INC DI
		DEC Cx       	;  loop iteration in x direction
		CMP CX,BX 
		JNZ	Drawx	    ;  check if we can draw c urrent x and y and excape the y iteration
		MOV CX, SI 	    ;  if loop iteration in y direction, then x should start over so that we sweep the grid
		DEC DX       	;  loop iteration in y direction
		CMP DX,BP      
		JZ  ENDINGx   	;  both x and y reached 00 so end program
		Jmp Drawx
	ENDINGx:
	    RET			
Draw ENDP

GETFORBIDDEN PROC NEAR
	MOV AH,0                      ; GO TO GRAPHICAL MODE 
	MOV AL,3H
	INT 10H
	MOV DL,25
	MOV DH,10
	CALL MOVECURSOR
	MOV DX, OFFSET MESG8          
	CALL PRINTMESSAGE
	MOV AH,0                       ; WAIT FOR A KEY TO PROCEED FOR THE NEXT SCREEN 
	INT 16H
	MOV DL,AL                           ; PRINT THE VALID INPUT CHARACTER 
	MOV BL,AL
	MOV AH,2
	INT 21H
	MOV DL,25
	MOV DH,14
	CALL MOVECURSOR
	MOV DX, OFFSET MESG4
	CALL PRINTMESSAGE              ; SHOW 'PRESS ANY KEY TO CONTINUE' MASSEGE AT DL 'COLUMN' = 25 AND DH 'ROW' = 10
	MOV AH,0                       ; WAIT FOR A KEY TO PROCEED FOR THE NEXT SCREEN 
	INT 16H
	RET
GETFORBIDDEN ENDP
;------------------------------------------------------------DRAW SOLID RECTANGLE IN THE SCREEN----------------------------------------------	
DrawRect PROC NEAR 
	PUSH SI          ; SAVE THE REGISTERS IN THE STACK FOR FURTHER CALCULATION 
	PUSH DI          ; CX HOLDS THE X0 "INITIAL X COORDINATES" , SI HOLDS THE XF " THE FINAL X COORDINATES"
	PUSH CX          ; DX HOLDS THE Y0 "INITIAL Y COORDINATES" , DI HOLDS THE YF " THE FINAL Y COORDINATES"
	PUSH DX          ; AL HOLDS THE COLOR
	MOV AH,0Ch 
	LOOP_1: int 10h  ; two loops one for the width and another one inside it for the hight
	mov BX,CX
	LOOP_2:
	INC CX
	INT 10H
	CMP CX,SI        
	JNE LOOP_2
	MOV CX,BX
	INC DX
	CMP DX,DI 
	JNE LOOP_1
	POP DX
	POP CX
	POP DI
	POP SI
	RET
DrawRect ENDP	 
;--------------------------------------------------------------------------------------------------------------------------------------------
CLEAR_SCREEN PROC FAR 
    MOV AH, 0H 
    MOV AL, 3H 
    INT 10H 
CLEAR_SCREEN ENDP 
GUI PROC FAR

	mov cx,22
	mov ax, 13h 
	int 10h   ;converting to graphics mode

	; Drawing the layout
	; draw the outer horzontal lines 
	mov cx,319
	Layout_horz:
		mov AH,0ch ; set for drawing a pixel
		mov AL,09h ; choose the blue color
		mov BH,0h  ; choose the page number
		mov DX,0ah ; choose the row position
		INT 10H
		mov DX,0a2h ; choose the row position
		INT 10H
		dec CX
		jnz Layout_horz

	; draw the outer vertical lines, and the middle line
	mov cx,152
	mov DX,0bh ; choose the row position
	Layout_vert:
		mov AH,0ch ; set for drawing a pixel
		mov AL,09h ; choose the blue color
		mov BH,0h  ; choose the page number
		push cx
		mov Cx,319 ; choose the column position (which is constant)
		INT 10H
		mov Cx,0  ; choose the column position (which is constant)
		INT 10H
		mov Cx,160  ; choose the column position (which is constant)
		INT 10H
		pop cx
		inc DX
		dec CX
		jnz Layout_vert

	;Draw the processors/////////////////////////////////////////////////////
	;Draw the left processor horizontal lines
	mov cx,130
	processor_1_horz:
		mov AH,0ch ; set for drawing a pixel
		mov AL,0dh ; choose the purble color
		mov BH,0h  ; choose the page number
		mov DX,0fh ; choose the row position
		INT 10H
		mov Dx,160 ; choose the row position
		INT 10H
		dec CX
		jnz processor_1_horz

	;Draw the horizontal lines for the right processor
	mov cx,130
	mov bx,190
	process_2_horz:
		mov AH,0ch ; set for drawing a pixel
		mov AL,0eh ; choose the yellow color
		push cx
		mov cx,bx
		mov DX,0fh ; choose the row position
		INT 10H
		mov DX,160 ; choose the row position
		INT 10H
		pop cx
		inc bx
		dec CX
		jnz process_2_horz

	;Draw the vertical lines for both processors
	mov cx,0
	mov DX,0fh ; choose the row position
	mov cx,145
	Process_1_2:
		mov AH,0ch ; set for drawing a pixel
		mov AL,0dh ; choose the purble color
		mov BH,0h  ; choose the page number
		push cx
		mov Cx,130  ; choose the column position (which is constant)
		INT 10H
		mov AL,0eh ; choose the yellow color
		mov Cx,190  ; choose the column position (which is constant)
		INT 10H
		pop cx
		inc DX
		dec CX
	jnz process_1_2

	; Draw the four registers in the two processors
	; draw the left ones horizontal lines
	mov bx,0
	mov cx,40
	mov bx,24  ; as this value will be passed to cx for columns positions 
	Registers_left:
		mov ah,0ch
		mov al,0dh ;choose purble color
		push cx  ; save the value of cx in stack
		mov cx,bx
		mov dx,1fh
		INT 10h
		mov cx,bx
		mov dx,2fh
		INT 10h
		mov cx,bx
		mov dx,3fh
		INT 10h
		mov dx,4fh
		INT 10h
		mov dx,5fh
		INT 10h
		pop cx  ; retrieve the value of cx
		inc bx
		dec cx
	jnz Registers_left

	; draw the right ones horizontal lines
	mov bx,0
	mov cx,40
	mov bx,257  ; as this value will be passed to cx for columns positions  
	Registers_right:
		mov ah,0ch
		mov al,0eh ;choose yellow color
		push cx  ; save the value of cx in stack
		mov cx,bx
		mov dx,1fh
		INT 10h
		mov cx,bx
		mov dx,2fh
		INT 10h
		mov cx,bx
		mov dx,3fh
		INT 10h
		mov dx,4fh
		INT 10h
		mov dx,5fh
		INT 10h
		pop cx  ; retrieve the value of cx
		inc bx
		dec cx
	jnz Registers_right

	;Draw the left, right, middle vertical lines for the first four registers
	mov cx,0
	mov DX,1fh ; choose the row position
	mov cx,65
	registers_vert:
		mov AH,0ch ; set for drawing a pixel
		mov AL,0dh ; choose the purble color
		mov BH,0h  ; choose the page number
		push cx
		mov Cx,24  ; choose the column position (which is constant)
		INT 10H
		mov Cx,64  ; choose the column position (which is constant)
		INT 10H
		mov al,0eh  ;choose yellow color
		mov Cx,257  ; choose the column position (which is constant)
		INT 10H
		mov Cx,296  ; choose the column position (which is constant)
		INT 10H
		pop cx
		inc DX
		dec CX
	jnz registers_vert

	;Drawing the segment registers////////////////////

	; draw the horizontal lines for the left ones 
	mov bx,0
	mov cx,38
	mov bx,70  ; as this value will be passed to cx for columns positions 
	segments_left:
		mov ah,0ch
		mov al,0dh ;choose purble color
		push cx  ; save the value of cx in stack
		mov cx,bx
		mov dx,1fh
		INT 10h
		mov cx,bx
		mov dx,2fh
		INT 10h
		mov cx,bx
		mov dx,3fh
		INT 10h
		mov dx,4fh
		INT 10h
		mov dx,5fh
		INT 10h
		pop cx  ; retrieve the value of cx
		inc bx
		dec cx
	jnz segments_left


	; draw the horizontal lines right ones 
	mov bx,0
	mov cx,38
	mov bx,211  ; as this value will be passed to cx for columns positions 
	segments_right:
		mov ah,0ch
		mov al,0eh ;choose yellow color
		push cx  ; save the value of cx in stack
		mov cx,bx
		mov dx,1fh
		INT 10h
		mov cx,bx
		mov dx,2fh
		INT 10h
		mov cx,bx
		mov dx,3fh
		INT 10h
		mov dx,4fh
		INT 10h
		mov dx,5fh
		INT 10h
		pop cx  ; retrieve the value of cx
		inc bx
		dec cx
	jnz segments_right


	;Draw the vertical lines for the segments
	mov cx,0
	mov DX,1fh ; choose the row position
	mov cx,65
	segments_vert:
		mov AH,0ch ; set for drawing a pixel
		mov AL,0dh ; choose the purble color
		mov BH,0h  ; choose the page number
		push cx
		mov Cx,70  ; choose the column position (which is constant)
		INT 10H
		mov Cx,108  ; choose the column position (which is constant)
		INT 10H
		mov al,0eh  ;choose yellow color
		mov Cx,211  ; choose the column position (which is constant)
		INT 10H
		mov Cx,249  ; choose the column position (which is constant)
		INT 10H
		pop cx
		inc DX
		dec CX
	jnz segments_vert

	; draw the boxes for users names

	;draw the horizontal line for first box 
	mov cx,130
	mov bx,0
	Squares_in1:
		mov AH,0ch ; set for drawing a pixel
		mov AL,0dh ; choose the purble color
		push cx
		mov cx,bx
		mov DX,97 ; choose the row position
		INT 10H
		pop cx
		inc bx
		dec CX
	jnz Squares_in1

	;draw the horizontal line for the second box
	mov cx,130
	mov bx,190
	Squares_in2:
		mov AH,0ch ; set for drawing a pixel
		mov AL,0eh ; choose the yellow color
		push cx
		mov cx,bx
		mov DX,97 ; choose the row position
		INT 10H
		pop cx
		inc bx
		dec CX
	jnz Squares_in2

	;Draw the memory////////////////////////
	mov cx,150
	mov DX,0bh ; choose the row position
	memory:
		mov AH,0ch ; set for drawing a pixel
		mov AL,0bh ; choose the blue color
		mov BH,0h  ; choose the page number
		push cx
		mov Cx,135 ; choose the column position (which is constant)
		INT 10H
		mov Cx,152  ; choose the column position (which is constant)
		INT 10H
		mov Cx,167 ; choose the column position (which is constant)
		INT 10H
		mov Cx,185  ; choose the column position (which is constant)
		INT 10H
		pop cx
		inc DX
		dec CX
	jnz memory

	;Set the names of the registers///////////////////////////////////////////////////////////////////////////
		;Disaplay the characters for the first processor
		Set 4 1
		PrintChar 'A'
		Set 4 2
		PrintChar 'X'

		Set 6 1
		PrintChar 'B'
		Set 6 2
		PrintChar 'X'

		Set 8 1
		PrintChar 'C'
		Set 8 2
		PrintChar 'X'

		Set 10 1
		PrintChar 'D'
		Set 10 2
		PrintChar 'X'

		;Disaplay the characters for the second processor
		Set 4 24
		PrintChar 'A'
		Set 4 25
		PrintChar 'X'

		Set 6 24
		PrintChar 'B'
		Set 6 25
		PrintChar 'X'

		Set 8 24
		PrintChar 'C'
		Set 8 25
		PrintChar 'X'

		Set 10 24
		PrintChar 'D'
		Set 10 25
		PrintChar 'X'

		;Display the characters of the segments registers of the left processor
		Set 4 14
		PrintChar 'S'
		Set 4 15
		PrintChar 'P'

		Set 6 14
		PrintChar 'B'
		Set 6 15
		PrintChar 'P'

		Set 8 14
		PrintChar 'S'
		Set 8 15
		PrintChar 'I'

		Set 10 14
		PrintChar 'D'
		Set 10 15
		PrintChar 'I'

		;Display the characters of the segments registers of the right processor 
		Set 4 37
		PrintChar 'S'
		Set 4 38
		PrintChar 'P'

		Set 6 37
		PrintChar 'B'
		Set 6 38
		PrintChar 'P'

		Set 8 37
		PrintChar 'S'
		Set 8 38
		PrintChar 'I'

		Set 10 37
		PrintChar 'D'
		Set 10 38
		PrintChar 'I'

	; Draw the Zeros in all their places/////////////////////////////////
		;Draw them for the left processor and its memory
		Set 10 49
		PrintChar '0'
		Set 10 50
		PrintChar '0'
		Set 10 51
		PrintChar '0'
		Set 10 52
		PrintChar '0' 
		Set 10 47
		PrintChar '0'
		Set 10 46
		PrintChar '0'
		Set 10 45
		PrintChar '0'
		Set 10 44
		PrintChar '0'
		Set 8 49
		PrintChar '0'
		Set 8 50
		PrintChar '0'
		Set 8 51
		PrintChar '0'
		Set 8 52
		PrintChar '0' 
		Set 8 47
		PrintChar '0'
		Set 8 46
		PrintChar '0'
		Set 8 45
		PrintChar '0'
		Set 8 44
		PrintChar '0'
		Set 6 49
		PrintChar '0'
		Set 6 50
		PrintChar '0'
		Set 6 51
		PrintChar '0'
		Set 6 52
		PrintChar '0' 
		Set 6 47
		PrintChar '0'
		Set 6 46
		PrintChar '0'
		Set 6 45
		PrintChar '0'
		Set 6 44
		PrintChar '0'
		Set 4 49
		PrintChar '0'
		Set 4 50
		PrintChar '0'
		Set 4 51
		PrintChar '0'
		Set 4 52
		PrintChar '0' 
		Set 4 47
		PrintChar '0'
		Set 4 46
		PrintChar '0'
		Set 4 45
		PrintChar '0'
		Set 4 44
		PrintChar '0'
		
		; left memory///////////
		Set 2 97
		PrintChar '0'
		Set 2 98
		PrintChar '0'
		Set 3 97
		PrintChar '0'
		Set 3 98
		PrintChar '0'
		Set 4 97
		PrintChar '0'
		Set 4 98
		PrintChar '0'
		Set 5 97
		PrintChar '0'
		Set 5 98
		PrintChar '0'
		Set 6 97
		PrintChar '0'
		Set 6 98
		PrintChar '0'
		Set 7 97
		PrintChar '0'
		Set 7 98
		PrintChar '0'
		Set 8 97
		PrintChar '0'
		Set 8 98
		PrintChar '0'
		Set 9 97
		PrintChar '0'
		Set 9 98
		PrintChar '0'
		Set 11 97
		PrintChar '0'
		Set 11 98
		PrintChar '0'
		Set 12 97
		PrintChar '0'
		Set 12 98
		PrintChar '0'
		Set 13 97
		PrintChar '0'
		Set 13 98
		PrintChar '0'
		Set 14 97
		PrintChar '0'
		Set 14 98
		PrintChar '0'
		Set 15 97
		PrintChar '0'
		Set 15 98
		PrintChar '0'
		Set 16 97
		PrintChar '0'
		Set 16 98
		PrintChar '0'
		Set 17 97
		PrintChar '0'
		Set 17 98
		PrintChar '0'
		Set 18 97
		PrintChar '0'
		Set 18 98
		PrintChar '0'

		;Draw them for the right processor and its memory
		Set 10 110
		PrintChar '0'
		Set 10 109
		PrintChar '0'
		Set 10 108
		PrintChar '0'
		Set 10 107
		PrintChar '0' 
		Set 8 110
		PrintChar '0'
		Set 8 109
		PrintChar '0'
		Set 8 108
		PrintChar '0'
		Set 8 107
		PrintChar '0'
		Set 6 110
		PrintChar '0'
		Set 6 109
		PrintChar '0'
		Set 6 108
		PrintChar '0'
		Set 6 107
		PrintChar '0' 
		Set 4 110
		PrintChar '0'
		Set 4 109
		PrintChar '0'
		Set 4 108
		PrintChar '0'
		Set 4 107
		PrintChar '0'

		Set 10 113
		PrintChar '0'
		Set 10 114
		PrintChar '0'
		Set 10 115
		PrintChar '0'
		Set 10 116
		PrintChar '0' 
		Set 8 113
		PrintChar '0'
		Set 8 114
		PrintChar '0'
		Set 8 115
		PrintChar '0'
		Set 8 116
		PrintChar '0' 
		Set 6 113
		PrintChar '0'
		Set 6 114
		PrintChar '0'
		Set 6 115
		PrintChar '0'
		Set 6 116
		PrintChar '0' 
		Set 4 113
		PrintChar '0'
		Set 4 114
		PrintChar '0'
		Set 4 115
		PrintChar '0'
		Set 4 116
		PrintChar '0' 

		; right memory///////////
		Set 2 101
		PrintChar '0'
		Set 2 102
		PrintChar '0'
		Set 3 101
		PrintChar '0'
		Set 3 102
		PrintChar '0'
		Set 4 101
		PrintChar '0'
		Set 4 102
		PrintChar '0'
		Set 5 101
		PrintChar '0'
		Set 5 102
		PrintChar '0'
		Set 6 102
		PrintChar '0'
		Set 6 101
		PrintChar '0'
		Set 7 101
		PrintChar '0'
		Set 7 102
		PrintChar '0'
		Set 8 101
		PrintChar '0'
		Set 8 102
		PrintChar '0'
		Set 9 101
		PrintChar '0'
		Set 9 102
		PrintChar '0'
		Set 11 101
		PrintChar '0'
		Set 11 102
		PrintChar '0'
		Set 12 101
		PrintChar '0'
		Set 12 102
		PrintChar '0'
		Set 13 101
		PrintChar '0'
		Set 13 102
		PrintChar '0'
		Set 14 101
		PrintChar '0'
		Set 14 102
		PrintChar '0'
		Set 15 101
		PrintChar '0'
		Set 15 102
		PrintChar '0'
		Set 16 101
		PrintChar '0'
		Set 16 102
		PrintChar '0'
		Set 17 101
		PrintChar '0'
		Set 17 102
		PrintChar '0'
		Set 18 101
		PrintChar '0'
		Set 18 102
		PrintChar '0'


	; Create the mini game (inside the big game!!!)/////////////////////////////////////////////////////////////////


	; Drawing the shoooter /////////////////////////////////////////////////////////////////////////////
		mov ax,0
	Draw_shooter:
		Set 19 Xposition
		PrintChar '^'
		Set 19 32
		PrintChar '^'
		
	check_scan:
		CALL DrawFlyingObj
		
		mov ah,1
		int 16h ; read the key pressed from the buffer
		jz check_scan

		mov inputKey,ah
		cmp inputKey,77  ; right arrow
		je Is_greater
		cmp inputKey,75  ; left arrow 
		je Is_smaller
		cmp inputKey,57  ; space arrow 
		je Draw_bullet

		JMP check_scan

		Is_greater:  ; check the right boundry
			mov ah,0
			int 16h
			cmp Xposition,14
			jg check_scan
			jle moveRight

		Is_smaller:  ; check the left boundry 
			mov ah,0
			int 16h
			cmp Xposition,2
			jl check_scan
			jge moveleft

		moveleft:
			;draw the shooter with the black color as im deleting it 
			Set 19 Xposition
			PrintChar_black '^'
			dec Xposition
			jmp Draw_shooter

		moveRight:
			;draw the shooter with the black color as im deleting it
			Set 19 Xposition
			PrintChar_black '^' 
			inc Xposition
			jmp Draw_shooter

	Draw_bullet:
		mov ah,0
		int 16h
		
		mov cl,Xposition
		mov  Xbullet,cl
		Set Ybullet Xbullet; move the bullet
		PrintChar '.'
	jmp update_bullet

	set_bullet:
		Set Ybullet Xbullet; move the bullet
		PrintChar '.'
		mov cx,5000
		delay1:
		dec cx
		jnz delay1
		mov cx,50000
		delay2:
		dec cx
		jnz delay2
		mov cx,50000
		delay3:
		dec cx
		jnz delay3
	jmp update_bullet

	update_bullet:
		Set Ybullet Xbullet ;clear the bullet
		PrintChar_black '.'
		dec Ybullet
		cmp Ybullet,13; compare with the boundry
		jg set_bullet
		Set Ybullet Xbullet ;clear the bullet
		PrintChar_black '.'
		mov cl,Xposition
		mov  Xbullet,cl
		mov cl,17
		mov Ybullet,cl
	jmp check_scan

GUI ENDP
; ------------------------------------------------------ GUI Procedures ------------------------------------------- ;
DrawFlyingObj PROC FAR

    ; Create the flying objects

    update_object: ; updating the position of the objects
        set 13 X_Arr[1]
        draw_obj 0ch
        inc X_Arr[1]

        set 14 X_Arr[3]
        draw_obj 0bh
        inc X_Arr[3]

        set 13 X_Arr[5]
        draw_obj 0eh
        inc X_Arr[5]

        set 14 X_Arr[7]
        draw_obj 0ah
        inc X_Arr[7]

        cmp X_Arr[7],15
        jle clear_old_pos
        jg dum2

        dum2:
        jmp set_object

        clear_old_pos:;clear the objects in the old positions
        mov bx,60000
        stop1:
        dec bx
        jnz stop1
        mov bx,60000
        stop2:
        dec bx
        jnz stop2
        set 13 X_Arr[0]
        PrintChar_black 'o'
        inc X_Arr[0] 

        set 14 X_Arr[2]
        PrintChar_black 'o'
        inc X_Arr[2]

        set 13 X_Arr[4]
        PrintChar_black 'o'
        inc X_Arr[4]

        set 14 X_Arr[6]
        PrintChar_black 'o'
        inc X_Arr[6]

        RET

        ;jmp update_object

    set_object: ; set the objects to be all cleared 
        set 13 X_Arr[0]
        PrintChar_black 'o' 
        mov X_Arr[0],2
        mov X_Arr[1],2

        set 14 X_Arr[2]
        PrintChar_black 'o' 
        mov X_Arr[2],3
        mov X_Arr[3],3

        set 13 X_Arr[4]
        PrintChar_black 'o' 
        mov X_Arr[4],5
        mov X_Arr[5],5

        set 14 X_Arr[6]
        PrintChar_black 'o' 
        mov X_Arr[6],6
        mov X_Arr[7],6
    

    RET
ENDP
 
 
END   MAIN