.MODEL HUGE
;----------------
.STACK 64
;----------------
.DATA
;----------------
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
;---------------------------------------------------------Chat Variables------------------------------------------------------
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
;---------------------------------------------------------Serial Communication VARIABLES------------------------------------------------------
Char_Send    DB   ? 
Char_Recieve DB   ? 
Exit_Chat    DB   0
forbiddenCharP1 DB 0
forbiddenCharP2 DB 0
LEVEL           DB 0
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
CHECK1:			CMP CHOSEN,4              ; IF THE NUMBER INCREASED TO 4 INITIALIZE IT TO 1 FOR THE FIRST CHOICE" WE HAVE ONLT THREE CHOICES"
				JNE END_CHECKCHOICE
				MOV CHOSEN,1
				JMP END_CHECKCHOICE
CHECK2:		    CMP CHOSEN,0              ; IF THE NUMBER DECREASE TO 0 INITIALIZE IT TO 3 FOR THE LAST(THIRD ONE) CHOICE" WE HAVE ONLT THREE CHOICES"
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
LEVEL_2:	 CMP AL, 32H
			 JNZ GET_ANOTHER_INPUT
			 ;-----------------------------------------------ADD THE NEW FEATURES HERE FOR LEVEL 2-----------------------------------------
			 MOV LEVEL, 2
LEVEL_1:	 MOV DH, 0
			 MOV DL, LEVEL                           ; PRINT THE VALID INPUT CHARACTER 
			 ADD DL,30H
             MOV AH,2
             INT 21H
			 MOV DL,25
			 MOV DH,14
			 CALL MOVECURSOR
			 MOV DX, OFFSET MESG4
			 CALL PRINTMESSAGE              ; SHOW 'PRESS ANY KEY TO CONTINUE' MASSEGE AT DL 'COLUMN' = 25 AND DH 'ROW' = 10
			 MOV AH,0                       ; WAIT FOR A KEY TO PROCEED FOR THE NEXT SCREEN 
			 INT 16H
			 CALL CLEARSCREEN
			 CALL GETFORBIDDEN
			 MOV forbiddenCharP1, BL
			 CALL GETFORBIDDEN
			 MOV forbiddenCharP2, BL
			 MOV AH,0                      ; GO TO GRAPHIC MODE 
             MOV AL,13H
             INT 10H
			 MOV SI,320                         ; DRAW THE Command Line AT START ROW = 170 AND END ROW = 175
		     MOV DI,175                         ; DI = END ROW , DX = START ROW 
			 MOV CX,0                           ; CX =START COLUMN , SI = END COLUMN 
			 MOV DX,170             
			 MOV AL,7                           ; AL = COLOR OF THE GROUND 
			 CALL DrawRect
SHADI:       JMP SHADI
GAME ENDP
;-----------------------------------------------------------------------DRAW FUNCTION--------------------------------------------------------
Draw                    Proc    NEAR
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
ENDINGx:                   RET			
Draw                    ENDP

GETFORBIDDEN    PROC NEAR
				MOV AH,0                      ; GO TO GRAPHIC MODE 
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
GETFORBIDDEN    ENDP
;------------------------------------------------------------DRAW SOLID RECTANGLE IN THE SCREEN----------------------------------------------	
DrawRect                PROC NEAR 
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
DrawRect				   ENDP	 
;--------------------------------------------------------------------------------------------------------------------------------------------

  END   MAIN