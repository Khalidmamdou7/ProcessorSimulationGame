;================================================= MACROS ======================================================= ;
;; ------------------------------------------------ GUI MACROS --------------------------------------------------;;
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
    ; set cursor position
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
draw_point MACRO chr,clr
    mov ah,0ah
    mov al,chr
    mov bh,0h
    mov bl,clr
    mov cx,1
    int 10H
ENDM
;; ---------------------------------------------- Commands MACROS ---------------------------------------------;;
ExecPush MACRO Op
    mov bh, 0
    mov bl, ValStackPointer
    mov ax, Op
    lea di, ValStack
    mov [di][bx], ax
    ADD ValStackPointer,2
ENDM
ourExecPush MACRO Op
    mov bh, 0
    mov bl, ourValStackPointer
    mov ax, Op
    lea di, ourValStack
    mov [di][bx], ax
    ADD ourValStackPointer,2
ENDM
ExecPushMem MACRO Op
    mov bh, 0
    mov bl, ValStackPointer
    mov ax, word ptr Op
    lea di, ValStack
    mov [di][bx], ax
    ADD ValStackPointer,2
ENDM
ExecPop MACRO Op
    mov bh, 0
    mov bl, ValStackPointer
    lea di, ValStack
    mov ax, [di][bx]
    mov Op, ax
    SUB ValStackPointer,2
ENDM
ourExecPop MACRO Op
    mov bh, 0
    mov bl, ourValStackPointer
    lea di, ourValStack
    mov ax, [di][bx]
    mov Op, ax
    SUB ourValStackPointer,2
ENDM
ExecPopMem MACRO Op
    mov bh, 0
    mov bl, ValStackPointer
    lea di, ValStack
    mov ax, [di][bx]
    mov word ptr Op, ax
    SUB ValStackPointer,2
ENDM
ourExecPopMem MACRO Op
    mov bh, 0
    mov bl, ourValStackPointer
    lea di, ourValStack
    mov ax, [di][bx]
    mov word ptr Op, ax
    SUB ourValStackPointer,2
ENDM
ExecINC MACRO Op
    INC Op
ENDM
ExecDEC MACRO Op
    DEC Op
ENDM
ExecAndReg MACRO ValReg, CF
    CALL GetSrcOp
    AND ValReg, AX
    MOV CF, 0
    JMP Exit
ENDM
ExecAndReg_8Bit MACRO ValReg, CF
    CALL GetSrcOp_8Bit
    And BYTE PTR ValReg, AL
    MOV CF, 0
    JMP Exit
ENDM
ExecAndMem MACRO Op, CF
    Local AndOp1Mem_Op2_8Bit

    CMP selectedOp2Size, 8
    JZ AndOp1Mem_Op2_8Bit
    CALL GetSrcOp
    And WORD PTR Op, AX
    MOV CF, 0
    JMP Exit

    AndOp1Mem_Op2_8Bit:
        CALL GetSrcOp_8Bit
        And Op, AL
        MOV CF, 0
        JMP Exit
ENDM
ExecMovMem MACRO Mem
    Local MOVOp1Mem_Op2_8Bit

    CMP selectedOp2Size, 8
    JZ MOVOp1Mem_Op2_8Bit
    CALL GetSrcOp
    MOV WORD PTR Mem, AX
    JMP Exit

    MOVOp1Mem_Op2_8Bit:
        CALL GetSrcOp_8Bit
        MOV Mem, AL 
    JMP Exit
ENDM
ExecAddMem MACRO Mem
    LOCAL AddOp1Mem_Op2_8Bit

    CMP selectedOp2Size, 8
    JZ AddOp1Mem_Op2_8Bit
    CALL GetSrcOp
    CLC
    ADD WORD PTR Mem, AX
    CALL SetCF
    JMP Exit

    AddOp1Mem_Op2_8Bit:
        CALL GetSrcOp_8Bit
        CLC
        ADD Mem, AL 
        CALL SetCF
    JMP Exit
ENDM
ExecAdcMem MACRO Mem
    LOCAL AdcOp1Mem_Op2_8Bit

    CMP selectedOp2Size, 8
    JZ AdcOp1Mem_Op2_8Bit
    CALL GetSrcOp
    CLC
    CALL GetCF
    ADC WORD PTR Mem, AX
    CALL SetCF
    JMP Exit

    AdcOp1Mem_Op2_8Bit:
        CALL GetSrcOp_8Bit
        CLC
        CALL GetCF
        ADC Mem, AL 
        CALL SetCF
    JMP Exit
ENDM
ExecAndAddReg MACRO ValReg, Mem, CF
    Local AndOp1AddReg_Op2_8Bit

    MOV dx, ValReg
    CALL CheckAddress
    cmp bl, 1               ; Value is greater than 16
    JZ InValidCommand

    CMP selectedOp2Size, 8
    jz AndOp1AddReg_Op2_8Bit 
    CALL GetSrcOp
    MOV SI, ValReg
    And WORD PTR Mem[SI], AX
    MOV CF, 0
    JMP Exit

    AndOp1AddReg_Op2_8Bit:
        CALL GetSrcOp_8Bit
        MOV SI, ValReg
        And Mem[SI], AL
        MOV CF, 0
    JMP Exit
ENDM
ExecMovAddReg MACRO ValReg, Mem
    Local MOVOp1AddReg_Op2_8Bit 

    MOV dx, ValReg
    CALL CheckAddress
    cmp bl, 1               ; Value is greater than 16
    JZ InValidCommand

    CMP selectedOp2Size, 8
    jz MOVOp1AddReg_Op2_8Bit 
    CALL GetSrcOp
    MOV SI, ValReg
    MOV WORD PTR Mem[SI], AX
    JMP Exit
    MOVOp1AddReg_Op2_8Bit:
        CALL GetSrcOp_8Bit
        MOV SI, ValReg
        MOV Mem[SI], AL
    JMP Exit
ENDM
ExecAddAddReg MACRO ValReg, Mem
    LOCAL AddOp1AddReg_Op2_8Bit

    MOV dx, ValReg
    CALL CheckAddress
    cmp bl, 1               ; Value is greater than 16
    JZ InValidCommand

    CMP selectedOp2Size, 8
    jz AddOp1AddReg_Op2_8Bit 
    CALL GetSrcOp
    MOV SI, ValReg
    CLC
    ADD WORD PTR Mem[SI], AX
    CALL SetCF
    JMP Exit
    AddOp1AddReg_Op2_8Bit:
        CALL GetSrcOp_8Bit
        MOV SI, ValReg
        CLC
        ADD Mem[SI], AL
        CALL SetCF
    JMP Exit
ENDM
EexecAdcAddReg MACRO ValReg, Mem
    LOCAL AdcOp1Addreg_Op2_8Bit

    MOV dx, ValReg
    CALL CheckAddress
    cmp bl, 1               ; Value is greater than 16
    JZ InValidCommand

    CMP selectedOp2Size, 8
    jz AdcOp1Addreg_Op2_8Bit 
    CALL GetSrcOp
    MOV SI, ValReg
    CLC
    CALL GetCF
    ADC WORD PTR Mem[SI], AX
    CALL SetCF
    JMP Exit
    AdcOp1Addreg_Op2_8Bit:
        CALL GetSrcOp_8Bit
        MOV SI, ValReg
        CLC
        CALL GetCF
        ADC Mem[SI], AL
        CALL SetCF
    JMP Exit
ENDM
CheckForbidCharMacro MACRO comm
    mov di, comm
    Call CheckForbidChar
    CMP bl, 1
    jz InValidCommand
ENDM
;================================================================================================================
.MODEL HUGE
;----------------
.386
.STACK 64
;================================================================================================================
.DATA
        
    ;---------------------------------------RIGHT PROCESSOR----------------------------------------------:

        ; positions of X axis of the AX register in right processor
        p2_AX_X1 EQU 107
        p2_AX_X2 EQU 108
        p2_AX_X3 EQU 109
        p2_AX_X4 EQU 110
        
        p2_AX_Y EQU 4 ; the Y axis of the AX register of the left processor 


        ; positions of X axis of the BX register in right processor
        p2_BX_X1 EQU 107
        p2_BX_X2 EQU 108
        p2_BX_X3 EQU 109
        p2_BX_X4 EQU 110
        
        p2_BX_Y EQU 6 ; the Y axis of the AX register of the left processor 


        ; positions of X axis of the DX register in right processor
        p2_CX_X1 EQU 107
        p2_CX_X2 EQU 108
        p2_CX_X3 EQU 109
        p2_CX_X4 EQU 110
        
        p2_CX_Y EQU 8 ; the Y axis of the AX register of the left processor 


        ; positions of X axis of the DX register in right processor
        p2_DX_X1 EQU 107
        p2_DX_X2 EQU 108
        p2_DX_X3 EQU 109
        p2_DX_X4 EQU 110
        
        p2_DX_Y EQU 10 ; the Y axis of the AX register of the left processor 


        ; positions of X axis of SP register in right processor 
        p2_SP_X1 equ 113
        p2_SP_X2 equ 114
        p2_SP_X3 equ 115
        p2_SP_X4 equ 116

        p2_SP_Y equ 4 ; the Y position of SP register in the left processor 


        ; positions of X axis of BP register in right processor 
        p2_BP_X1 equ 113
        p2_BP_X2 equ 114
        p2_BP_X3 equ 115
        p2_BP_X4 equ 116

        p2_BP_Y equ 6 ; the Y position of BP register in the left processor 

        ; positions of X axis of SI register in right processor 
        p2_SI_X1 equ 113
        p2_SI_X2 equ 114
        p2_SI_X3 equ 115
        p2_SI_X4 equ 116

        p2_SI_Y equ 8 ; the Y position of SI register in the left processor 


        ; positions of X axis of DI register in right processor 
        p2_DI_X1 equ 113
        p2_DI_X2 equ 114
        p2_DI_X3 equ 115
        p2_DI_X4 equ 116

        p2_DI_Y equ 10 ; the Y position of SI register in the left processor 


    ;-----------------------------------------------------LEFT MEMORY-----------------------------------------------------
        ; X positions of values of left memory
        left_mem_X0 equ 97
        left_mem_X1 equ 98
        left_mem_X2 equ 97
        left_mem_X3 equ 98
        left_mem_X4 equ 97
        left_mem_X5 equ 98
        left_mem_X6 equ 97
        left_mem_X7 equ 98
        left_mem_X8 equ 97
        left_mem_X9 equ 98
        left_mem_X10 equ 97
        left_mem_X11 equ 98
        left_mem_X12 equ 97
        left_mem_X13 equ 98
        left_mem_X14 equ 97
        left_mem_X15 equ 98

        left_mem_X16 equ 97
        left_mem_X17 equ 98
        left_mem_X18 equ 97
        left_mem_X19 equ 98
        left_mem_X20 equ 97
        left_mem_X21 equ 98
        left_mem_X22 equ 97
        left_mem_X23 equ 98
        left_mem_X24 equ 97
        left_mem_X25 equ 98
        left_mem_X26 equ 97
        left_mem_X27 equ 98
        left_mem_X28 equ 97
        left_mem_X29 equ 98
        left_mem_X30 equ 97
        left_mem_X31 equ 98

        ; Y positions of values in left memory
        left_mem_Y0 equ 2
        left_mem_Y1 equ 2
        left_mem_Y2 equ 3
        left_mem_Y3 equ 3
        left_mem_Y4 equ 4
        left_mem_Y5 equ 4
        left_mem_Y6 equ 5
        left_mem_Y7 equ 5
        left_mem_Y8 equ 6
        left_mem_Y9 equ 6
        left_mem_Y10 equ 7
        left_mem_Y11 equ 7
        left_mem_Y12 equ 8
        left_mem_Y13 equ 8
        left_mem_Y14 equ 9
        left_mem_Y15 equ 9

        left_mem_Y16 equ 11
        left_mem_Y17 equ 11
        left_mem_Y18 equ 12
        left_mem_Y19 equ 12
        left_mem_Y20 equ 13
        left_mem_Y21 equ 13
        left_mem_Y22 equ 14
        left_mem_Y23 equ 14
        left_mem_Y24 equ 15
        left_mem_Y25 equ 15
        left_mem_Y26 equ 16
        left_mem_Y27 equ 16
        left_mem_Y28 equ 17
        left_mem_Y29 equ 17
        left_mem_Y30 equ 18
        left_mem_Y31 equ 18


    ;-----------------------------------------------------RIGHT MEMORY-----------------------------------------------------

        ; X positions of values of left memory
        right_mem_X0 equ 101
        right_mem_X1 equ 102
        right_mem_X2 equ 101
        right_mem_X3 equ 102
        right_mem_X4 equ 101
        right_mem_X5 equ 102
        right_mem_X6 equ 101
        right_mem_X7 equ 102
        right_mem_X8 equ 101
        right_mem_X9 equ 102
        right_mem_X10 equ 101
        right_mem_X11 equ 102
        right_mem_X12 equ 101
        right_mem_X13 equ 102
        right_mem_X14 equ 101
        right_mem_X15 equ 102

        right_mem_X16 equ 101
        right_mem_X17 equ 102
        right_mem_X18 equ 101
        right_mem_X19 equ 102
        right_mem_X20 equ 101
        right_mem_X21 equ 102
        right_mem_X22 equ 101
        right_mem_X23 equ 102
        right_mem_X24 equ 101
        right_mem_X25 equ 102
        right_mem_X26 equ 101
        right_mem_X27 equ 102
        right_mem_X28 equ 101
        right_mem_X29 equ 102
        right_mem_X30 equ 101
        right_mem_X31 equ 102

        ; Y positions of values in left memory
        right_mem_Y0 equ 2
        right_mem_Y1 equ 2
        right_mem_Y2 equ 3
        right_mem_Y3 equ 3
        right_mem_Y4 equ 4
        right_mem_Y5 equ 4
        right_mem_Y6 equ 5
        right_mem_Y7 equ 5
        right_mem_Y8 equ 6
        right_mem_Y9 equ 6
        right_mem_Y10 equ 7
        right_mem_Y11 equ 7
        right_mem_Y12 equ 8
        right_mem_Y13 equ 8
        right_mem_Y14 equ 9
        right_mem_Y15 equ 9

        right_mem_Y16 equ 11
        right_mem_Y17 equ 11
        right_mem_Y18 equ 12
        right_mem_Y19 equ 12
        right_mem_Y20 equ 13
        right_mem_Y21 equ 13
        right_mem_Y22 equ 14
        right_mem_Y23 equ 14
        right_mem_Y24 equ 15
        right_mem_Y25 equ 15
        right_mem_Y26 equ 16
        right_mem_Y27 equ 16
        right_mem_Y28 equ 17
        right_mem_Y29 equ 17
        right_mem_Y30 equ 18
        right_mem_Y31 equ 18


    ;----------------------object points----------------------;
        red_pt db '1'
    ; ----------------------------------------------- Keys Scan Codes ------------------------------------------- ;
        UpArrowScanCode EQU 72
        DownArrowScanCode EQU 80
        RightScanCode EQU 77
        LeftScanCode EQU 75
        EnterScanCode EQU 28
        EscScanCode EQU 1 
    ; ------------------------------------------------ Test Messages -------------------------------------------- ;
        mesSelCom db 10,'You have selected Command #', '$'
        mesSelOp1Type db 10,'You have selected Operand 1 of Type #', '$'
        mesSelReg db 10, 'You have selected Reg #', '$'
        mesSelMem db 10, 'You have selected Mem #', '$'
        mesEntVal db 10, 'You Entered value: ', '$'
        mesMem db 10, 'Values in memory as Ascii: ', 10, '$'
        mesStack db 10, 'Values in stack as Ascii: ', 10, '$'
        mesStackPointer db 10,  'Value of stack pointer: ', 10 ,  '$'
        mesRegAX db 10, 'Value of AX: ', '$'
        mesRegBX db 10, 'Value of BX: ', '$'
        mesRegCX db 10, 'Value of CX: ', '$'
        mesRegDX db 10, 'Value of DX: ', '$'
        mesRegSI db 10, 'Value of SI: ', '$'
        mesRegDI db 10, 'Value of DI: ', '$'
        mesRegBP db 10, 'Value of BP: ', '$'
        mesRegSP db 10, 'Value of SP: ', '$'
        mesRegCF db 10, 'Value of CF: ', '$'
        error db 13,10,"Error Input",'$'

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
	; ----------------------------------------------- GUI Variables --------------------------------------------- ;
		; Define the variables
		X2position db 9
		Xposition db 8
		inputKey db ?
		Xbullet db 8
		Ybullet db 18
		X_Arr db 2,2,3,3,5,5,6,6
		; Y_Arr db 6 dup(?)
        InstructionMsg db 10,'Use Up/Down Arrows to navigate between commands.', '$'
        ExecutionFailed db 10, 'Invalid Command. Press Enter to continue.', '$'
        ExecutedSuccesfully db 10, 'Command Executed Sucessfully. Press Enter to continue.', '$'
        PlayerTwoWaitRound db 10, 'Waiting for player two... Press Enter to skip', '$'
    ; ---------------------------------------------- Cursor Locations ------------------------------------------- ;
        MenmonicCursorLoc EQU 1500H
        Op1CursorLoc EQU 1506H
        CommaCursorLoc EQU 150BH
        Op2CursorLoc EQU 150CH
        PUPCursorLoc EQU 1511H
        ForbidPUPCursor EQU 1516H
	
    ; --------------------------------------------- Commands Variables -------------------------------------------;
        ; ------------------------------- Menu Commands Variables --------------------------- ;
            ; ---------- Menu Strings -------- ;
                CommStringSize EQU  6

                NOPcom db 'NOP  ','$'   
                CLCcom db 'CLC  ','$'   
                MOVcom db 'MOV  ','$'   
                ADDcom db 'ADD  ','$'  
                ADCcom db 'ADC  ','$' 
                ANDcom db 'AND  ','$'
                PUSHcom db 'PUSH ','$'
                POPcom db 'POP  ','$'
                INCcom db 'INC  ','$'
                DECcom db 'DEC  ','$'
                MULcom db 'MUL  ','$'
                DIVcom db 'DIV  ','$'
                IMULcom db 'IMUL ','$'
                IDIVcom db 'IDIV ','$'
                RORcom db 'ROR  ','$'
                ROLcom db 'ROL  ','$'
                RCRcom db 'RCR  ','$'
                RCLcom db 'RCL  ','$'
                SHLcom db 'SHL  ','$'
                SHRcom db 'SHR  ','$'

                Reg    db 'REG  ','$'
                AddReg db '[REG]', '$'
                Memory db 'MEM  ','$'
                Value  db 'VAL  ','$'
                RegIndex    EQU 0
                AddRegIndex EQU 1
                MemIndex    EQU 2
                ValIndex    EQU 3 
                


                RegAX db 'AX   ','$' ;0
                RegAL db 'AL   ','$' ;1
                RegAH db 'AH   ','$' ;2
                RegBX db 'BX   ','$' ;3
                RegBL db 'BL   ','$' ;4
                RegBH db 'BH   ','$' ;5
                RegCX db 'CX   ','$' ;6
                RegCL db 'CL   ','$' ;7
                RegCH db 'CH   ','$' ;8
                RegDX db 'DX   ','$' ;9
                RegDL db 'DL   ','$' ;10
                RegDH db 'DH   ','$' ;11
                RegSX db 'SX   ','$' ;12
                RegSL db 'SL   ','$' ;13
                RegSH db 'SH   ','$' ;14
                RegBP db 'BP   ','$' ;15
                RegSP db 'SP   ','$' ;16
                RegSI db 'SI   ','$' ;17
                RegDI db 'DI   ','$' ;18
                

                AddRegAX db '[AX] ','$'
                AddRegAL db '[AL] ','$'                
                AddRegBP db '[BP] ','$'  
                AddRegBX db '[BX] ','$'   
                AddRegBL db '[BL] ','$'    
                AddRegBH db '[BH] ','$'
                AddRegCX db '[CX] ','$'                
                AddRegCL db '[CL] ','$'  
                AddRegCH db '[CH] ','$'   
                AddRegDX db '[DX] ','$'
                AddRegDL db '[DL] ','$'
                AddRegDH db '[DH] ','$'                
                AddRegSX db '[SX] ','$'  
                AddRegSL db '[SL] ','$'   
                AddRegSH db '[SH] ','$'
                AddRegAH db '[AH] ','$'
                AddRegSP db '[SP] ','$'
                AddRegSI db '[SI] ','$'
                AddRegDI db '[DI] ','$'

                Mem0 db '[0]  ','$'
                Mem1 db '[1]  ','$'
                Mem2 db '[2]  ','$'
                Mem3 db '[3]  ','$'
                Mem4 db '[4]  ','$'
                Mem5 db '[5]  ','$'
                Mem6 db '[6]  ','$'
                Mem7 db '[7]  ','$'
                Mem8 db '[8]  ','$'
                Mem9 db '[9]  ','$'
                Mem10 db '[A]  ','$'
                Mem11 db '[B]  ','$'
                Mem12 db '[C]  ','$'
                Mem13 db '[D]  ','$'
                Mem14 db '[E]  ','$'
                Mem15 db '[F]  ','$'

                NoPUP db 'NoPo ','$'
                PUP1 db 'PUp1 ','$'
                PUP2 db 'PUp2 ','$'
                PUP3 db 'PUp3 ','$'
                PUP4 db 'PUp4 ','$'
                PUP5 db 'PUp5 ','$'
            
            ; ----- Selection Variables ------ ;
                selectedPUPType db -1, '$'
                selectedComm db -1, '$'

                selectedOp1Type db -1, '$'  
                selectedOp1Reg  db -1, '$'
                selectedOp1AddReg db -1, '$'
                selectedOp1Mem  db -1, '$'
                selectedOp1Size db 8, '$' 
                Op1Val dw 0
                Op1Valid db 1               ; 0 if Invalid 

                selectedOp2Type db -1, '$'
                selectedOp2Reg  db -1, '$'
                selectedOp2AddReg db -1, '$'
                selectedOp2Mem  db -1, '$'
                selectedOp2Size db 8, '$'
                Op2Val dw 0
                Op2Valid db 1               ; 0 if Invalid
            ; --- Operand Value Variables -----;
                ClearSpace db '     ', '$'
                num db 30,?,30 DUP(?)       
                StrSize db ?
                num2 db 30,?,30 DUP(?)       
                StrSize2 db ?
                a EQU 1000H
                B EQU 100H
                C EQU 10H
        ; ------------------------------------- Game Variables ------------------------------ ;
            ; ----------- Opponent Data ----------;
                ValRegAX dw 'AX'
                ValRegBX dw 'BX'
                ValRegCX dw 'CX'
                ValRegDX dw 'DX'
                ValRegBP dw 'BP'
                ValRegSP dw 'SP'
                ValRegSI dw 'SI'
                ValRegDI dw 'DI'

                ValMem db 16 dup('M'), '$'
                ValStack db 16 dup('S'), '$'
                ValStackPointer db 0
                ValCF db 1
            
            ; ------------ Player Data -----------;

                ourValRegAX dw 'AX'
                ourValRegBX dw 'BX'
                ourValRegCX dw 'CX'
                ourValRegDX dw 'DX'
                ourValRegBP dw 'BP'
                ourValRegSP dw 'SP'
                ourValRegSI dw 'SI'
                ourValRegDI dw 'DI' 
                
                ourValMem db 16 dup('M'), '$'
                ourValStack db 16 dup('S'), '$'
                ourValStackPointer db 0
                ourValCF db 0

            ; --------- Score and others --------;
                Player1_Points DB 0
                Player2_Points DB 0
                Player1_ForbidChar DB 0
		        Player2_ForbidChar DB 0
		        LEVEL           DB 0

            ; ------- Power Up Variables --------;
                UsedBeforeOrNot db 1    ;Chance to use forbiden power up
                PwrUpDataLineIndex db 0
                PwrUpStuckVal db 0
                PwrUpStuckEnabled db 1
            

        
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
;===============================================================================================================
.CODE
MAIN PROC FAR
    MOV AX,@DATA                     ; LOAD THE DATA VARIABLES
    MOV DS,AX     
    MOV ES,AX

    JMP TestSkip


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
	MOV Player1_Points, BH
	MOV Player2_Points, BH
	JMP NEXT_FORWARD
TAKE_PLAYER2POINTS:
;	MOV Player1_Points, BL
;	MOV Player2_Points, BL
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
			 MOV Player1_ForbidChar, BL
			 CALL GETFORBIDDEN
			 MOV Player2_ForbidChar, BL
			 MOV AH,0                      ; GO TO GRAPHICAL MODE 
             MOV AL,13H
             INT 10H
			 MOV SI,320                         ; DRAW THE Command Line AT START ROW = 170 AND END ROW = 175
		     MOV DI,175                         ; DI = END ROW , DX = START ROW 
			 MOV CX,0                           ; CX =START COLUMN , SI = END COLUMN 
			 MOV DX,170             
			 MOV AL,7                           ; AL = COLOR OF THE GROUND 
             TestSkip:
			 CALL PlayMode
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
GETFORBIDDEN    ENDP


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
DisplayGUIValues PROC FAR
    ; Draw the Zeros in all their places/////////////////////////////////
		;Draw them for the left processor and its memory

        ; DI 
		Set 10 49           ; LEFT-MOST
		PrintChar '1'
		Set 10 50
		PrintChar '2'
		Set 10 51
		PrintChar '3'
		Set 10 52
		PrintChar '4'

        ; DX
		Set 10 47
		PrintChar '5'       ; RIGHT-MOST
		Set 10 46
		PrintChar '6'
		Set 10 45
		PrintChar '7'
		Set 10 44
		PrintChar '8'

        ; SI
		Set 8 49
		PrintChar '9'       ; LEFT-MOST
		Set 8 50
		PrintChar '0'
		Set 8 51
		PrintChar 'A'
		Set 8 52
		PrintChar 'B' 

        ; CX
		Set 8 47            ; RIGHT-MOST
		PrintChar 'C'
		Set 8 46
		PrintChar 'D'
		Set 8 45
		PrintChar 'E'
		Set 8 44
		PrintChar 'F'

        ; BP
		Set 6 49
		PrintChar 'G'       ; LEFT-MOST
		Set 6 50
		PrintChar 'H'
		Set 6 51
		PrintChar 'I'
		Set 6 52
		PrintChar 'G' 

        ; BX
		Set 6 47            ; RIGHT-MOST
		PrintChar 'H'
		Set 6 46
		PrintChar 'K'
		Set 6 45
		PrintChar 'L'
		Set 6 44
		PrintChar 'M'

        ; SP
		Set 4 49
		PrintChar 'N'       ; LEFT- MOST 
		Set 4 50
		PrintChar 'O'
		Set 4 51
		PrintChar 'P'
		Set 4 52
		PrintChar 'Q'

        ; AX 
		Set 4 47
		PrintChar 'R'       ; RIGHT-MOST
		Set 4 46
		PrintChar 'S'
		Set 4 45
		PrintChar 'T'
		Set 4 44
		PrintChar 'F'
		
		; left memory///////////
        ; VAL MEM[0]
		Set 2 97
		PrintChar '1'       ; LEFT-MOST
		Set 2 98
		PrintChar '2'

        ; VAL MEM[1]
		Set 3 97
		PrintChar '3'       ; LEFT-MOST
		Set 3 98
		PrintChar '4'

        ; VAL MEM[2]
		Set 4 97
		PrintChar '5'       ; LEFT-MOST
		Set 4 98
		PrintChar '1'

        ; VAL MEM[3]
		Set 5 97
		PrintChar '2'       ; LEFT-MOST
		Set 5 98
		PrintChar '3'

        ; VAL MEM[4]
		Set 6 97
		PrintChar '5'
		Set 6 98
		PrintChar '6'

        ; VAL MEM[5]
		Set 7 97
		PrintChar '7'
		Set 7 98
		PrintChar '8'

        ; VAL MEM[6]
		Set 8 97
		PrintChar '9'
		Set 8 98
		PrintChar '0'

        ; VAL MEM[7]
		Set 9 97
		PrintChar 'A'
		Set 9 98
		PrintChar 'B'

        ; VAL MEM[8]
		Set 11 97
		PrintChar 'C'
		Set 11 98
		PrintChar 'D'

        ; VAL MEM[9]
		Set 12 97
		PrintChar 'E'
		Set 12 98
		PrintChar 'F'

        ; VAL MEM[10]
		Set 13 97
		PrintChar 'G'
		Set 13 98
		PrintChar 'H'

        ; VAL MEM[11]
		Set 14 97
		PrintChar 'I'
		Set 14 98
		PrintChar 'J'

        ; VAL MEM[12]
		Set 15 97
		PrintChar 'K'
		Set 15 98
		PrintChar 'L'

        ; VAL MEM[13]
		Set 16 97
		PrintChar 'M'
		Set 16 98
		PrintChar 'N'

        ; VAL MEM[14]
		Set 17 97
		PrintChar 'O'
		Set 17 98
		PrintChar 'P'

        ; VAL MEM[15]
		Set 18 97
		PrintChar 'Q'
		Set 18 98
		PrintChar 'R'

		;Draw them for the right processor and its memory
        
        ; DX 
		Set 10 110
		PrintChar 'S'       ; RIGHT-MOST
		Set 10 109
		PrintChar 'Q'
		Set 10 108
		PrintChar 'A'
		Set 10 107
		PrintChar 'B'

        ; CX 
		Set 8 110
		PrintChar 'C'
		Set 8 109
		PrintChar 'D'
		Set 8 108
		PrintChar 'E'
		Set 8 107
		PrintChar 'F'

        ; BX
		Set 6 110
		PrintChar 'G'
		Set 6 109
		PrintChar 'H'
		Set 6 108
		PrintChar 'I'
		Set 6 107
		PrintChar 'J' 

        ; AX
		Set 4 110
		PrintChar 'K'
		Set 4 109
		PrintChar 'L'
		Set 4 108
		PrintChar 'M'
		Set 4 107
		PrintChar 'N'

        ; Right Mem[0]
		Set 10 113
		PrintChar '1'
		Set 10 114
		PrintChar '2'

        ; Right Mem[1]
		Set 10 115
		PrintChar '3'
		Set 10 116
		PrintChar '4'

        ; Right Mem[2] 
		Set 8 113
		PrintChar '5'
		Set 8 114
		PrintChar '6'

        ; Right Mem[3]
		Set 8 115
		PrintChar '7'
		Set 8 116
		PrintChar '8'

        ; Right Mem[4]
		Set 6 113
		PrintChar '9'
		Set 6 114
		PrintChar '0'

        ; Right Mem[5]
		Set 6 115
		PrintChar 'A'
		Set 6 116
		PrintChar 'B'

        ; Right Mem[6] 
		Set 4 113
		PrintChar 'C'
		Set 4 114
		PrintChar 'D'

        ; Right Mem[7]
		Set 4 115
		PrintChar 'E'
		Set 4 116
		PrintChar 'F' 

		; right memory///////////

        ; DI
		Set 2 101
		PrintChar '1'          ; LEFT-MOST
		Set 2 102
		PrintChar '2'
		Set 3 101
		PrintChar '3'
		Set 3 102
		PrintChar '4'

        ; SI
		Set 4 101
		PrintChar '5'
		Set 4 102
		PrintChar '6'
		Set 5 101
		PrintChar '7'
		Set 5 102
		PrintChar '8'

        ; BP
		Set 6 102
		PrintChar '9'
		Set 6 101
		PrintChar '1'
		Set 7 101
		PrintChar 'A'
		Set 7 102
		PrintChar 'B'

        ; SP
		Set 8 101
		PrintChar 'C'
		Set 8 102
		PrintChar 'D'
		Set 9 101
		PrintChar 'E'
		Set 9 102
		PrintChar 'F'

        ; Right Mem[8]
		Set 11 101
		PrintChar 'G'
		Set 11 102
		PrintChar 'H'

        ; Right Mem[9]
		Set 12 101
		PrintChar 'I'
		Set 12 102
		PrintChar 'J'

        ; Right Mem[10]
		Set 13 101
		PrintChar 'K'
		Set 13 102
		PrintChar 'L'

        ; Right Mem[11]
		Set 14 101
		PrintChar 'M'
		Set 14 102
		PrintChar 'N'

        ; Right Mem[12]
		Set 15 101
		PrintChar 'O'
		Set 15 102
		PrintChar 'P'

        ; Right Mem[13]
		Set 16 101
		PrintChar 'Q'
		Set 16 102
		PrintChar 'R'

        ; Right Mem[14]
		Set 17 101
		PrintChar 'S'
		Set 17 102
		PrintChar 'T'

        ; Right Mem[15]
		Set 18 101
		PrintChar '1'
		Set 18 102
		PrintChar '2'

        ;shooter game points for red ball
        Set 0 8
        draw_point '0', 0ch
    
    RET
ENDP
DrawShooter PROC FAR
    ; Drawing the shoooter /////////////////////////////////////////////////////////////////////////////
		mov ax,0
	Draw_shooter:
		Set 19 Xposition
		PrintChar '^'
		Set 19 32
		PrintChar '^'

    RET
ENDP
DrawBullet PROC FAR
    Draw_bullet:
        push dx
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

    ; check if the bullet hits any flying object or the boundry
    chk_red:
        mov cl,X_Arr[0]
        cmp Ybullet,13
        je chk_red_col
        jg chk_bound
    chk_red_col:
        mov cl,X_Arr[0]
        cmp Xbullet,cl
        je increment_red

    chk_bound:
            cmp Ybullet,13; compare with the boundry
            jg set_bullet

    back_to_update:
            Set Ybullet Xbullet ;clear the bullet
            PrintChar_black '.'
            mov cl,Xposition
            mov  Xbullet,cl
            mov cl,17
            mov Ybullet,cl
        POP Dx
        RET

        
    increment_red:; increment the red points
    ; cmp red_pt,9
    ; jl do_red
    ; jge back_to_update
    ; do_red:
        inc red_pt
        Set 0 8
        draw_point red_pt, 0ch
        jmp back_to_update

    RET
ENDP
MoveShooterLeft PROC FAR
    Is_smaller:  ; check the left boundry 
        ;mov ah,0
        ;int 16h
        cmp Xposition,2
        jl RETURN_MoveShooterLeft
        jge moveleft

    moveleft:
        push dx
            ;draw the shooter with the black color as im deleting it 
            Set 19 Xposition
            PrintChar_black '^'
            dec Xposition
        pop dx

    RETURN_MoveShooterLeft:
        RET
ENDP
MoveShooterRight PROC FAR
    Is_greater:  ; check the right boundry
        cmp Xposition,14
        jg RETURN_MoveShooterRight
        jle moveRight

    moveRight:
        push dx
            ;draw the shooter with the black color as im deleting it
            Set 19 Xposition
            PrintChar_black '^' 
            inc Xposition
        pop dx
    
    RETURN_MoveShooterRight:
        RET
ENDP
PlayerTwoRound PROC FAR
    lea dx, PlayerTwoWaitRound
    CALL ShowMsg

    CheckKey_P2Round:
        CALL WaitKeyPress
    
    cmp ah, EnterScanCode
    jz CONT_P2Round
    cmp ah, RightScanCode
    jz MoveRight_P2Round
    cmp ah, LeftScanCode
    jz MoveLeft_P2Round
    cmp ah, 57
    jz DrawBullet_P2Round
    cmp ah, EscScanCode
    jz Exit_P2Round

    jmp CheckKey_P2Round

    DrawBullet_P2Round:
        Call DrawBullet
        JMP CheckKey_P2Round
    MoveLeft_P2Round:
        CALL MoveShooterLeft
        JMP CheckKey_P2Round
    MoveRight_P2Round:
        CALL MoveShooterRight
        JMP CheckKey_P2Round
    Exit_P2Round:
        Call Terminate
    CONT_P2Round:
        RET
    
    RET
ENDP

PlayMode PROC FAR

    mov cx,22
	mov ax, 13h 
	int 10h   ;converting to graphics mode

    GameLoop:
        CALL DrawGuiLayout
        CALL DisplayGUIValues
        CALL DrawFlyingObj
        CALL DrawShooter
        Set 21 0
        lea dx, InstructionMsg
        CALL DisplayString
        CALL PowerUpeMenu
        CALL ExecutePwrUp
        CALL CommMenu
        CALL PlayerTwoRound

    JMP GameLoop





    RET
ENDP

; ------------------------------------------- GUI Procedures ------------------------------------------- ;
DrawFlyingObj PROC FAR

    ; Create the flying objects

    update_object: ; updating the position of the objects
        set 13 X_Arr[1]
        draw_obj 0ch
        inc X_Arr[1]

        ; set 14 X_Arr[3]
        ; draw_obj 0bh
        ; inc X_Arr[3]

        ; set 13 X_Arr[5]
        ; draw_obj 0eh
        ; inc X_Arr[5]

        ; set 14 X_Arr[7]
        ; draw_obj 0ah
        ; inc X_Arr[7]

        cmp X_Arr[1],15
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

        ; set 14 X_Arr[2]
        ; PrintChar_black 'o'
        ; inc X_Arr[2]

        ; set 13 X_Arr[4]
        ; PrintChar_black 'o'
        ; inc X_Arr[4]

        ; set 14 X_Arr[6]
        ; PrintChar_black 'o'
        ; inc X_Arr[6]

        RET

        ;jmp update_object

    set_object: ; set the objects to be all cleared 
        set 13 X_Arr[0]
        PrintChar_black 'o' 
        mov X_Arr[0],2
        mov X_Arr[1],2

        ; set 14 X_Arr[2]
        ; PrintChar_black 'o' 
        ; mov X_Arr[2],3
        ; mov X_Arr[3],3

        ; set 13 X_Arr[4]
        ; PrintChar_black 'o' 
        ; mov X_Arr[4],5
        ; mov X_Arr[5],5

        ; set 14 X_Arr[6]
        ; PrintChar_black 'o' 
        ; mov X_Arr[6],6
        ; mov X_Arr[7],6
    

    RET
ENDP
DrawGuiLayout PROC FAR

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
	DrawMemory:
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
	jnz DrawMemory

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

    RET
DrawGuiLayout ENDP

; ================================================ COMMANDS PROCEDURE ===================================;
CommMenu proc far
    
    
    ; CALL ClearScreen

    Start:
    
    CALL MnemonicMenu
    ; SelectedMenmonic index is saved, Call operands according to each operation (Menmonic)

    CMP selectedComm, 0
    JZ NOP_Comm
    CMP selectedComm, 1
    JZ CLC_Comm
    CMP selectedComm, 2
    JZ MOV_Comm
    CMP selectedComm, 3
    JZ ADD_Comm
    CMP selectedComm, 4
    JZ ADC_Comm
    CMP selectedComm, 5
    JZ AND_Comm
    CMP selectedComm, 6
    JZ PUSH_Comm
    CMP selectedComm, 7
    JZ POP_Comm
    CMP selectedComm, 8
    JZ INC_Comm
    CMP selectedComm, 9
    JZ DEC_Comm
    CMP selectedComm, 10
    JZ MUL_Comm
    CMP selectedComm, 11
    JZ DIV_Comm
    CMP selectedComm, 12
    JZ IMul_Comm
    CMP selectedComm, 13
    JZ IDiv_Comm
    CMP selectedComm, 14
    JZ ROR_Comm
    cmp selectedComm, 15
    JZ ROL_Comm
    cmp selectedComm, 16
    JZ RCR_Comm
    cmp selectedComm, 17
    JZ RCL_Comm  
    cmp selectedComm, 18
    JZ SHL_Comm
    cmp selectedComm, 19
    JZ SHR_Comm

    JMP TODO_Comm
    ; Continue comparing for all operations

    ; Commands (operations) Labels
    NOP_Comm:
        CALL CheckForbidCharProc         
        call  PowerUpeMenu ; to choose power up
        cmp selectedPUPType,1 ;command on your own processor  
        jne notthispower1_nop   ;-5 points
        NOP      
        sub Player1_Points,5 
        jmp Exit
        notthispower1_nop:

        cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
        jne notthispower2_nop  ;-3 points
        NOP        
        sub Player1_Points,3
        jmp Exit
        notthispower2_nop:

        NOP

    

    JMP Exit
    
    CLC_Comm:
        CALL CheckForbidCharProc
        call  PowerUpeMenu ; to choose power up
        MOV ValCF, 0
        JMP Exit
    AND_Comm:

        CALL Op1Menu
        mov DX, CommaCursorLoc
        CALL SetCursor
        mov dl, ','
        CALL DisplayChar
        CALL Op2Menu

        call  PowerUpeMenu ; to choose power up
        CALL CheckForbidCharProc

        CMP selectedOp1Type, 0
        JZ AndOp1Reg
        CMP selectedOp1Type, 1
        JZ AndOp1AddReg
        CMP selectedOp1Type, 2
        JZ AndOp1Mem
        JMP InValidCommand

        AndOp1Reg:
            CMP selectedOp1Reg, 0
            JZ AndOp1RegAX
            CMP selectedOp1Reg, 1
            JZ AndOp1RegAL
            CMP selectedOp1Reg, 2
            JZ AndOp1RegAH
            CMP selectedOp1Reg, 3
            JZ AndOp1RegBX
            CMP selectedOp1Reg, 4
            JZ AndOp1RegBL
            CMP selectedOp1Reg, 5
            JZ AndOp1RegBH
            CMP selectedOp1Reg, 6
            JZ AndOp1RegCX
            CMP selectedOp1Reg, 7
            JZ AndOp1RegCL
            CMP selectedOp1Reg, 8
            JZ AndOp1RegCH
            CMP selectedOp1Reg, 9
            JZ AndOp1RegDX
            CMP selectedOp1Reg, 10
            JZ AndOp1RegDL
            CMP selectedOp1Reg, 11
            JZ AndOp1RegDH

            CMP selectedOp1Reg, 15
            JZ AndOp1RegBP
            CMP selectedOp1Reg, 16
            JZ AndOp1RegSP
            CMP selectedOp1Reg, 17
            JZ AndOp1RegSI
            CMP selectedOp1Reg, 18
            JZ AndOp1RegDI
            

            JMP InValidCommand

            AndOp1RegAX: ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ; TODO - ADD Pwr Up Check here
                ExecAndReg ValRegAX, ValCF
            AndOp1RegAL:
                ; TODO - ADD Pwr Up Check here
                ExecAndReg_8Bit ValRegAX, ValCF
            AndOp1RegAH:
                ; TODO - ADD Pwr Up Check here
                ExecAndReg_8Bit ValRegAX+1, ValCF
            AndOp1RegBX:
                ; TODO - ADD Pwr Up Check here
                ExecAndReg ValRegBX, ValCF
            AndOp1RegBL:
                ; TODO - ADD Pwr Up Check here
                ExecAndReg_8Bit ValRegBX, ValCF
            AndOp1RegBH:
                ; TODO - ADD Pwr Up Check here
                ExecAndReg_8Bit ValRegBX+1, ValCF
            AndOp1RegCX:
                ; TODO - ADD Pwr Up Check here
                ExecAndReg ValRegCX, ValCF
            AndOp1RegCL:
                ; TODO - ADD Pwr Up Check here
                ExecAndReg_8Bit ValRegCX, ValCF
            AndOp1RegCH:
                ; TODO - ADD Pwr Up Check here
                ExecAndReg_8Bit ValRegCX+1, ValCF
            AndOp1RegDX:
                ; TODO - ADD Pwr Up Check here
                ExecAndReg ValRegDX, ValCF
            AndOp1RegDL:
                ; TODO - ADD Pwr Up Check here
                ExecAndReg_8Bit ValRegDX, ValCF
            AndOp1RegDH:
                ; TODO - ADD Pwr Up Check here
                ExecAndReg_8Bit ValRegDX+1, ValCF
            AndOp1RegBP:
                ; TODO - ADD Pwr Up Check here
                ExecAndReg ValRegBP, ValCF
            AndOp1RegSP:
                ; TODO - ADD Pwr Up Check here
                ExecAndReg ValRegSP, ValCF
            AndOp1RegSI:
                ; TODO - ADD Pwr Up Check here
                ExecAndReg ValRegSI, ValCF
            AndOp1RegDI:
                ; TODO - ADD Pwr Up Check here
                ExecAndReg ValRegDI, ValCF

        AndOp1AddReg:

            ; Check Memory-to-Memory operations
            CMP selectedOp2Type, 1
            JZ InValidCommand
            CMP selectedOp2Type, 2
            jz InValidCommand

            CMP selectedOp1AddReg, 3
            JZ AndOp1AddRegBX
            CMP selectedOp1AddReg, 15
            JZ AndOp1AddRegBP
            CMP selectedOp1AddReg, 17
            JZ AndOp1AddRegSI
            CMP selectedOp1AddReg, 18
            JZ AndOp1AddRegDI
            JMP InValidCommand

            AndOp1AddRegBX:
                ; TODO - ADD Check Power Up here    
                ExecAndAddReg ValRegBX, ValMem, ValCF
            AndOp1AddRegBP:
                ; TODO - ADD Check Power Up here
                ExecAndAddReg ValRegBP, ValMem, ValCF
            AndOp1AddRegSI:
                ; TODO - ADD Check Power Up here
                ExecAndAddReg ValRegSI, ValMem, ValCF
            AndOp1AddRegDI:
                ; TODO - ADD Check Power Up here
                ExecAndAddReg ValRegDI, ValMem, ValCF

        AndOp1Mem:
            
            CMP selectedOp1Mem, 0
            JZ AndOp1Mem0
            CMP selectedOp1Mem, 1
            JZ AndOp1Mem1
            CMP selectedOp1Mem, 2
            JZ AndOp1Mem2
            CMP selectedOp1Mem, 3
            JZ AndOp1Mem3
            CMP selectedOp1Mem, 4
            JZ AndOp1Mem4
            CMP selectedOp1Mem, 5
            JZ AndOp1Mem5
            CMP selectedOp1Mem, 6
            JZ AndOp1Mem6
            CMP selectedOp1Mem, 7
            JZ AndOp1Mem7
            CMP selectedOp1Mem, 8
            JZ AndOp1Mem8
            CMP selectedOp1Mem, 9
            JZ AndOp1Mem9
            CMP selectedOp1Mem, 10
            JZ AndOp1Mem10
            CMP selectedOp1Mem, 11
            JZ AndOp1Mem11
            CMP selectedOp1Mem, 12
            JZ AndOp1Mem12
            CMP selectedOp1Mem, 13
            JZ AndOp1Mem13
            CMP selectedOp1Mem, 14
            JZ AndOp1Mem14
            CMP selectedOp1Mem, 15
            JZ AndOp1Mem15
            JMP InValidCommand
            
            AndOp1Mem0:
                ; TODO - Add Power Up here
                ExecAndMem ValMem+0, ValCF
            AndOp1Mem1:
                ; TODO - Add Power Up here
                ExecAndMem ValMem+1, ValCF
            AndOp1Mem2:
                ; TODO - Add Power Up here
                ExecAndMem ValMem+2, ValCF
            AndOp1Mem3:
                ; TODO - Add Power Up here
                ExecAndMem ValMem+3, ValCF
            AndOp1Mem4:
                ; TODO - Add Power Up here
                ExecAndMem ValMem+4, ValCF
            AndOp1Mem5:
                ; TODO - Add Power Up here
                ExecAndMem ValMem+5, ValCF
            AndOp1Mem6:
                ; TODO - Add Power Up here
                ExecAndMem ValMem+6, ValCF
            AndOp1Mem7:
                ; TODO - Add Power Up here
                ExecAndMem ValMem+7, ValCF
            AndOp1Mem8:
                ; TODO - Add Power Up here
                ExecAndMem ValMem+8, ValCF
            AndOp1Mem9:
                ; TODO - Add Power Up here
                ExecAndMem ValMem+9, ValCF
            AndOp1Mem10:
                ; TODO - Add Power Up here
                ExecAndMem ValMem+10, ValCF
            AndOp1Mem11:
                ; TODO - Add Power Up here
                ExecAndMem ValMem+11, ValCF
            AndOp1Mem12:
                ; TODO - Add Power Up here
                ExecAndMem ValMem+12, ValCF
            AndOp1Mem13:
                ; TODO - Add Power Up here
                ExecAndMem ValMem+13, ValCF
            AndOp1Mem14:
                ; TODO - Add Power Up here
                ExecAndMem ValMem+14, ValCF
            AndOp1Mem15:
                ; TODO - Add Power Up here
                ExecAndMem ValMem+15, ValCF

        
        JMP Exit
    MOV_Comm:

        CALL Op1Menu
        mov DX, CommaCursorLoc
        CALL SetCursor
        mov dl, ','
        CALL DisplayChar
        CALL Op2Menu

        CALL PowerUpeMenu ; to choose power up
        CALL CheckForbidCharProc

        CMP selectedOp1Type, 0
        JZ MOVOp1Reg
        CMP selectedOp1Type, 1
        JZ MOVOp1AddReg
        CMP selectedOp1Type, 2
        JZ MOVOp1Mem
        JMP InValidCommand

        MOVOp1Reg:
            CMP selectedOp1Reg, 0
            JZ MOVOp1RegAX
            CMP selectedOp1Reg, 1
            JZ MOVOp1RegAL
            CMP selectedOp1Reg, 2
            JZ MOVOp1RegAH
            CMP selectedOp1Reg, 3
            JZ MOVOp1RegBX
            CMP selectedOp1Reg, 4
            JZ MOVOp1RegBL
            CMP selectedOp1Reg, 5
            JZ MOVOp1RegBH
            CMP selectedOp1Reg, 6
            JZ MOVOp1RegCX
            CMP selectedOp1Reg, 7
            JZ MOVOp1RegCL
            CMP selectedOp1Reg, 8
            JZ MOVOp1RegCH
            CMP selectedOp1Reg, 9
            JZ MOVOp1RegDX
            CMP selectedOp1Reg, 10
            JZ MOVOp1RegDL
            CMP selectedOp1Reg, 11
            JZ MOVOp1RegDH

            CMP selectedOp1Reg, 15
            JZ MOVOp1RegBP
            CMP selectedOp1Reg, 16
            JZ MOVOp1RegSP
            CMP selectedOp1Reg, 17
            JZ MOVOp1RegSI
            CMP selectedOp1Reg, 18
            JZ MOVOp1RegDI
            

            JMP InValidCommand

            MOVOp1RegAX:
                ; Delete this lineAX
                CALL GetSrcOp
                MOV ValRegAX, AX
                JMP Exit
            MOVOp1RegAL:
                ; Delete this lineAL
                CALL GetSrcOp_8Bit
                MOV BYTE PTR ValRegAX, AL
                JMP Exit
            MOVOp1RegAH:
                ; Delete this lineAH
                CALL GetSrcOp_8Bit
                MOV BYTE PTR ValRegAX+1, AL
                JMP Exit
            MOVOp1RegBX:
                ; Delete this lineBX
                CALL GetSrcOp
                MOV ValRegBX, AX
                JMP Exit
            MOVOp1RegBL:
                ; Delete this lineBL
                CALL GetSrcOp_8Bit
                MOV BYTE PTR ValRegBX, AL
                JMP Exit
            MOVOp1RegBH:
                ; Delete this lineBH
                CALL GetSrcOp_8Bit
                MOV BYTE PTR ValRegBX+1, AL
                JMP Exit
            MOVOp1RegCX:
                ; Delete this lineCX
                CALL GetSrcOp
                MOV ValRegCX, AX
                JMP Exit
            MOVOp1RegCL:
                ; Delete this lineCL
                CALL GetSrcOp_8Bit
                MOV BYTE PTR ValRegCX, AL
                JMP Exit
            MOVOp1RegCH:
                ; Delete this lineCH
                CALL GetSrcOp_8Bit
                MOV BYTE PTR ValRegCX+1, AL
                JMP Exit
            MOVOp1RegDX:
                ; Delete this lineDX
                CALL GetSrcOp
                MOV ValRegDX, AX
                JMP Exit
            MOVOp1RegDL:
                ; Delete this lineDL
                CALL GetSrcOp_8Bit
                MOV BYTE PTR ValRegDX, AL
                JMP Exit
            MOVOp1RegDH:
                ; Delete this lineDH
                CALL GetSrcOp_8Bit
                MOV BYTE PTR ValRegDX+1, AL
                JMP Exit
            MOVOp1RegBP:
                ; Delete this lineBP
                CALL GetSrcOp
                MOV ValRegBP, AX
                JMP Exit
            MOVOp1RegSP:
                ; Delete this lineSP
                CALL GetSrcOp
                MOV ValRegSP, AX
                JMP Exit
            MOVOp1RegSI:
                ; Delete this lineSI
                CALL GetSrcOp
                MOV ValRegSI, AX
                JMP Exit
            MOVOp1RegDI:
                ; Delete this lineDI
                CALL GetSrcOp
                MOV ValRegDI, AX
                JMP Exit

        MOVOp1AddReg:

            ; Check Memory-to-Memory operations
            CMP selectedOp2Type, 1
            JZ InValidCommand
            CMP selectedOp2Type, 2
            jz InValidCommand

            CMP selectedOp1AddReg, 3
            JZ MOVOp1AddRegBX
            CMP selectedOp1AddReg, 15
            JZ MOVOp1AddRegBP
            CMP selectedOp1AddReg, 17
            JZ MOVOp1AddRegSI
            CMP selectedOp1AddReg, 18
            JZ MOVOp1AddRegDI
            JMP InValidCommand

            MOVOp1AddRegBX:
                ; TODO - Add Power up check here
                ExecMovAddReg ValRegBX, ValMem
            MOVOp1AddRegBP:
                ; TODO - Add Power up check here
                ExecMovAddReg ValRegBP, ValMem
            MOVOp1AddRegSI:
                ; TODO - Add Power up check here
                ExecMovAddReg ValRegSI, ValMem
            MOVOp1AddRegDI:
                ; TODO - Add Power up check here
                ExecMovAddReg ValRegDI, ValMem

        MOVOp1Mem:
            
            CMP selectedOp1Mem, 0
            JZ MOVOp1Mem0
            CMP selectedOp1Mem, 1
            JZ MOVOp1Mem1
            CMP selectedOp1Mem, 2
            JZ MOVOp1Mem2
            CMP selectedOp1Mem, 3
            JZ MOVOp1Mem3
            CMP selectedOp1Mem, 4
            JZ MOVOp1Mem4
            CMP selectedOp1Mem, 5
            JZ MOVOp1Mem5
            CMP selectedOp1Mem, 6
            JZ MOVOp1Mem6
            CMP selectedOp1Mem, 7
            JZ MOVOp1Mem7
            CMP selectedOp1Mem, 8
            JZ MOVOp1Mem8
            CMP selectedOp1Mem, 9
            JZ MOVOp1Mem9
            CMP selectedOp1Mem, 10
            JZ MOVOp1Mem10
            CMP selectedOp1Mem, 11
            JZ MOVOp1Mem11
            CMP selectedOp1Mem, 12
            JZ MOVOp1Mem12
            CMP selectedOp1Mem, 13
            JZ MOVOp1Mem13
            CMP selectedOp1Mem, 14
            JZ MOVOp1Mem14
            CMP selectedOp1Mem, 15
            JZ MOVOp1Mem15
            JMP InValidCommand
            
            MOVOp1Mem0:
                ; TODO - ADD PWR UP CHECK HERE
                ExecMovMem ValMem+0
            MOVOp1Mem1:                    
                ; TODO - ADD PWR UP CHECK HERE
                ExecMovMem ValMem+1
            MOVOp1Mem2:
                ; TODO - ADD PWR UP CHECK HERE
                ExecMovMem ValMem+2
            MOVOp1Mem3:                    
                ; TODO - ADD PWR UP CHECK HERE
                ExecMovMem ValMem+3
            MOVOp1Mem4:
                ; TODO - ADD PWR UP CHECK HERE
                ExecMovMem ValMem+4
            MOVOp1Mem5:
                ; TODO - ADD PWR UP CHECK HERE
                ExecMovMem ValMem+5
            MOVOp1Mem6:
                ; TODO - ADD PWR UP CHECK HERE
                ExecMovMem ValMem+6
            MOVOp1Mem7:
                ; TODO - ADD PWR UP CHECK HERE
                ExecMovMem ValMem+7
            MOVOp1Mem8:
                ; TODO - ADD PWR UP CHECK HERE
                ExecMovMem ValMem+8
            MOVOp1Mem9:
                ; TODO - ADD PWR UP CHECK HERE
                ExecMovMem ValMem+9
            MOVOp1Mem10:
                ; TODO - ADD PWR UP CHECK HERE
                ExecMovMem ValMem+10
            MOVOp1Mem11:
                ; TODO - ADD PWR UP CHECK HERE
                ExecMovMem ValMem+11
            MOVOp1Mem12:
                ; TODO - ADD PWR UP CHECK HERE
                ExecMovMem ValMem+12
            MOVOp1Mem13:
                ; TODO - ADD PWR UP CHECK HERE
                ExecMovMem ValMem+13
            MOVOp1Mem14:
                ; TODO - ADD PWR UP CHECK HERE
                ExecMovMem ValMem+14
            MOVOp1Mem15:
                ; TODO - ADD PWR UP CHECK HERE
                ExecMovMem ValMem+15

        
        JMP Exit
    

    ADD_Comm:

        CALL Op1Menu
        MOV DX, CommaCursorLoc
        CALL SetCursor
        mov dl, ','
        CALL DisplayChar
        CALL Op2Menu

        CALL CheckForbidCharProc

        call  PowerUpeMenu ; to choose power up

        CMP selectedOp1Type, 0
        JZ AddOp1Reg
        CMP selectedOp1Type, 1
        JZ AddOp1AddReg
        CMP selectedOp1Type, 2
        JZ AddOp1Mem
        JMP InValidCommand

        AddOp1Reg:
            CMP selectedOp1Reg, 0
            JZ AddOp1RegAX
            CMP selectedOp1Reg, 1
            JZ AddOp1RegAL
            CMP selectedOp1Reg, 2
            JZ AddOp1RegAH
            CMP selectedOp1Reg, 3
            JZ AddOp1RegBX
            CMP selectedOp1Reg, 4
            JZ AddOp1RegBL
            CMP selectedOp1Reg, 5
            JZ AddOp1RegBH
            CMP selectedOp1Reg, 6
            JZ AddOp1RegCX
            CMP selectedOp1Reg, 7
            JZ AddOp1RegCL
            CMP selectedOp1Reg, 8
            JZ AddOp1RegCH
            CMP selectedOp1Reg, 9
            JZ AddOp1RegDX
            CMP selectedOp1Reg, 10
            JZ AddOp1RegDL
            CMP selectedOp1Reg, 11
            JZ AddOp1RegDH

            CMP selectedOp1Reg, 15
            JZ AddOp1RegBP
            CMP selectedOp1Reg, 16
            JZ AddOp1RegSP
            CMP selectedOp1Reg, 17
            JZ AddOp1RegSI
            CMP selectedOp1Reg, 18
            JZ AddOp1RegDI
            

            JMP InValidCommand

            AddOp1RegAX:
                CALL GetSrcOp
                CLC
                ADD ValRegAX, AX
                CALL SetCF
                JMP Exit
            AddOp1RegAL:
                CALL GetSrcOp_8Bit
                CLC
                ADD BYTE PTR ValRegAX, AL
                CALL SetCF
                JMP Exit
            AddOp1RegAH:
                CALL GetSrcOp_8Bit
                CLC
                ADD BYTE PTR ValRegAX+1, AL
                CALL SetCF
                JMP Exit
            AddOp1RegBX:
                CALL GetSrcOp
                CLC
                ADD ValRegBX, AX
                CALL SetCF
                JMP Exit
            AddOp1RegBL:
                CALL GetSrcOp_8Bit
                CLC
                ADD BYTE PTR ValRegBX, AL
                CALL SetCF
                JMP Exit
            AddOp1RegBH:
                CALL GetSrcOp_8Bit
                CLC
                ADD BYTE PTR ValRegBX+1, AL
                CALL SetCF
                JMP Exit
            AddOp1RegCX:
                CALL GetSrcOp
                CLC
                ADD ValRegCX, AX
                CALL SetCF
                JMP Exit
            AddOp1RegCL:
                CALL GetSrcOp_8Bit
                CLC
                ADD BYTE PTR ValRegCX, AL
                CALL SetCF
                JMP Exit
            AddOp1RegCH:
                CALL GetSrcOp_8Bit
                CLC
                ADD BYTE PTR ValRegCX+1, AL
                CALL SetCF
                JMP Exit
            AddOp1RegDX:
                CALL GetSrcOp
                CLC
                ADD ValRegDX, AX
                CALL SetCF
                JMP Exit
            AddOp1RegDL:
                CALL GetSrcOp_8Bit
                CLC
                ADD BYTE PTR ValRegDX, AL
                CALL SetCF
                JMP Exit
            AddOp1RegDH:
                CALL GetSrcOp_8Bit
                CLC
                ADD BYTE PTR ValRegDX+1, AL
                CALL SetCF
                JMP Exit
            AddOp1RegBP:
                CALL GetSrcOp
                CLC
                ADD ValRegBP, AX
                CALL SetCF
                JMP Exit
            AddOp1RegSP:
                CALL GetSrcOp
                CLC
                ADD ValRegSP, AX
                CALL SetCF
                JMP Exit
            AddOp1RegSI:
                CALL GetSrcOp
                CLC
                ADD ValRegSI, AX
                CALL SetCF
                JMP Exit
            AddOp1RegDI:
                CALL GetSrcOp
                CLC
                ADD ValRegDI, AX
                CALL SetCF
                JMP Exit

        AddOp1AddReg:

            ; Check Memory-to-Memory operations
            CMP selectedOp2Type, 1
            JZ InValidCommand
            CMP selectedOp2Type, 2
            jz InValidCommand

            CMP selectedOp1AddReg, 3
            JZ AddOp1AddRegBX
            CMP selectedOp1AddReg, 15
            JZ AddOp1AddRegBP
            CMP selectedOp1AddReg, 17
            JZ AddOp1AddRegSI
            CMP selectedOp1AddReg, 18
            JZ AddOp1AddRegDI
            JMP InValidCommand

            AddOp1AddRegBX:
                ; TODO - ADD Pwr Up check here
                ExecAddAddReg ValRegBx, ValMem
            AddOp1AddRegBP:
                ; TODO - ADD Pwr Up check here
                ExecAddAddReg ValRegBP, ValMem
            AddOp1AddRegSI:
                ; TODO - ADD Pwr Up check here
                ExecAddAddReg ValRegSI, ValMem
            AddOp1AddRegDI:
                ; TODO - ADD Pwr Up check here
                ExecAddAddReg ValRegDI, ValMem

        AddOp1Mem:
            
            CMP selectedOp1Mem, 0
            JZ AddOp1Mem0
            CMP selectedOp1Mem, 1
            JZ AddOp1Mem1
            CMP selectedOp1Mem, 2
            JZ AddOp1Mem2
            CMP selectedOp1Mem, 3
            JZ AddOp1Mem3
            CMP selectedOp1Mem, 4
            JZ AddOp1Mem4
            CMP selectedOp1Mem, 5
            JZ AddOp1Mem5
            CMP selectedOp1Mem, 6
            JZ AddOp1Mem6
            CMP selectedOp1Mem, 7
            JZ AddOp1Mem7
            CMP selectedOp1Mem, 8
            JZ AddOp1Mem8
            CMP selectedOp1Mem, 9
            JZ AddOp1Mem9
            CMP selectedOp1Mem, 10
            JZ AddOp1Mem10
            CMP selectedOp1Mem, 11
            JZ AddOp1Mem11
            CMP selectedOp1Mem, 12
            JZ AddOp1Mem12
            CMP selectedOp1Mem, 13
            JZ AddOp1Mem13
            CMP selectedOp1Mem, 14
            JZ AddOp1Mem14
            CMP selectedOp1Mem, 15
            JZ AddOp1Mem15
            JMP InValidCommand
            
            AddOp1Mem0:
                ; TODO - ADD PWR UP CHECK HERE
                ExecAddMem ValMem+0
            AddOp1Mem1:
                ; TODO - ADD PWR UP CHECK HERE
                ExecAddMem ValMem+1
            AddOp1Mem2:
                ; TODO - ADD PWR UP CHECK HERE
                ExecAddMem ValMem+2
            AddOp1Mem3:
                ; TODO - ADD PWR UP CHECK HERE
                ExecAddMem ValMem+3
            AddOp1Mem4:
                ; TODO - ADD PWR UP CHECK HERE
                ExecAddMem ValMem+4
            AddOp1Mem5:
                ; TODO - ADD PWR UP CHECK HERE
                ExecAddMem ValMem+5
            AddOp1Mem6:
                ; TODO - ADD PWR UP CHECK HERE
                ExecAddMem ValMem+6
            AddOp1Mem7:
                ; TODO - ADD PWR UP CHECK HERE
                ExecAddMem ValMem+7
            AddOp1Mem8:
                ; TODO - ADD PWR UP CHECK HERE
                ExecAddMem ValMem+8
            AddOp1Mem9:
                ; TODO - ADD PWR UP CHECK HERE
                ExecAddMem ValMem+9
            AddOp1Mem10:
                ; TODO - ADD PWR UP CHECK HERE
                ExecAddMem ValMem+10
            AddOp1Mem11:
                ; TODO - ADD PWR UP CHECK HERE
                ExecAddMem ValMem+11
            AddOp1Mem12:
                ; TODO - ADD PWR UP CHECK HERE
                ExecAddMem ValMem+12
            AddOp1Mem13:
                ; TODO - ADD PWR UP CHECK HERE
                ExecAddMem ValMem+13
            AddOp1Mem14:
                ; TODO - ADD PWR UP CHECK HERE
                ExecAddMem ValMem+14
            AddOp1Mem15:
                ; TODO - ADD PWR UP CHECK HERE
                ExecAddMem ValMem+15

        
        JMP Exit

    ADC_Comm:
        
        CALL Op1Menu
        mov DX, CommaCursorLoc
        CALL SetCursor
        mov dl, ','
        CALL DisplayChar
        CALL Op2Menu

        CALL CheckForbidCharProc
        call  PowerUpeMenu ; to choose power up

        CMP selectedOp1Type, 0
        JZ AdcOp1Reg
        CMP selectedOp1Type, 1
        JZ AdcOp1Addreg
        CMP selectedOp1Type, 2
        JZ AdcOp1Mem
        JMP InValidCommand

        AdcOp1Reg:
            CMP selectedOp1Reg, 0
            JZ AdcOp1RegAX
            CMP selectedOp1Reg, 1
            JZ AdcOp1RegAL
            CMP selectedOp1Reg, 2
            JZ AdcOp1RegAH
            CMP selectedOp1Reg, 3
            JZ AdcOp1RegBX
            CMP selectedOp1Reg, 4
            JZ AdcOp1RegBL
            CMP selectedOp1Reg, 5
            JZ AdcOp1RegBH
            CMP selectedOp1Reg, 6
            JZ AdcOp1RegCX
            CMP selectedOp1Reg, 7
            JZ AdcOp1RegCL
            CMP selectedOp1Reg, 8
            JZ AdcOp1RegCH
            CMP selectedOp1Reg, 9
            JZ AdcOp1RegDX
            CMP selectedOp1Reg, 10
            JZ AdcOp1RegDL
            CMP selectedOp1Reg, 11
            JZ AdcOp1RegDH

            CMP selectedOp1Reg, 15
            JZ AdcOp1RegBP
            CMP selectedOp1Reg, 16
            JZ AdcOp1RegSP
            CMP selectedOp1Reg, 17
            JZ AdcOp1RegSI
            CMP selectedOp1Reg, 18
            JZ AdcOp1RegDI
            

            JMP InValidCommand

            AdcOp1RegAX:
                CALL GetSrcOp
                CLC
                CALL GetCF
                ADC ValRegAX, AX
                CALL SetCF
                JMP Exit
            AdcOp1RegAL:
                CALL GetSrcOp_8Bit
                CLC
                CALL GetCF
                ADC BYTE PTR ValRegAX, AL
                CALL SetCF
                JMP Exit
            AdcOp1RegAH:
                CALL GetSrcOp_8Bit
                CLC
                CALL GetCF
                ADC BYTE PTR ValRegAX+1, AL
                CALL SetCF
                JMP Exit
            AdcOp1RegBX:
                CALL GetSrcOp
                CLC
                CALL GetCF
                ADC ValRegBX, AX
                CALL SetCF
                JMP Exit
            AdcOp1RegBL:
                CALL GetSrcOp_8Bit
                CLC
                CALL GetCF
                ADC BYTE PTR ValRegBX, AL
                CALL SetCF
                JMP Exit
            AdcOp1RegBH:
                CALL GetSrcOp_8Bit
                CLC
                CALL GetCF
                ADC BYTE PTR ValRegBX+1, AL
                CALL SetCF
                JMP Exit
            AdcOp1RegCX:
                CALL GetSrcOp
                CLC
                CALL GetCF
                ADC ValRegCX, AX
                CALL SetCF
                JMP Exit
            AdcOp1RegCL:
                CALL GetSrcOp_8Bit
                CLC
                CALL GetCF
                ADC BYTE PTR ValRegCX, AL
                CALL SetCF
                JMP Exit
            AdcOp1RegCH:
                CALL GetSrcOp_8Bit
                CLC
                CALL GetCF
                ADC BYTE PTR ValRegCX+1, AL
                CALL SetCF
                JMP Exit
            AdcOp1RegDX:
                CALL GetSrcOp
                CLC
                CALL GetCF
                ADC ValRegDX, AX
                CALL SetCF
                JMP Exit
            AdcOp1RegDL:
                CALL GetSrcOp_8Bit
                CLC
                CALL GetCF
                ADC BYTE PTR ValRegDX, AL
                CALL SetCF
                JMP Exit
            AdcOp1RegDH:
                CALL GetSrcOp_8Bit
                CLC
                CALL GetCF
                ADC BYTE PTR ValRegDX+1, AL
                CALL SetCF
                JMP Exit
            AdcOp1RegBP:
                CALL GetSrcOp
                CLC
                CALL GetCF
                ADC ValRegBP, AX
                CALL SetCF
                JMP Exit
            AdcOp1RegSP:
                CALL GetSrcOp
                CLC
                CALL GetCF
                ADC ValRegSP, AX
                CALL SetCF
                JMP Exit
            AdcOp1RegSI:
                CALL GetSrcOp
                CLC
                CALL GetCF
                ADC ValRegSI, AX
                CALL SetCF
                JMP Exit
            AdcOp1RegDI:
                CALL GetSrcOp
                CLC
                CALL GetCF
                ADC ValRegDI, AX
                CALL SetCF
                JMP Exit

        AdcOp1AddReg:

            ; Check Memory-to-Memory operations
            CMP selectedOp2Type, 1
            JZ InValidCommand
            CMP selectedOp2Type, 2
            jz InValidCommand

            CMP selectedOp1AddReg, 3
            JZ AdcOp1AddRegBX
            CMP selectedOp1AddReg, 15
            JZ AdcOp1AddRegBP
            CMP selectedOp1AddReg, 17
            JZ AdcOp1AddRegSI
            CMP selectedOp1AddReg, 18
            JZ AdcOp1AddRegDI
            JMP InValidCommand

            AdcOp1AddregBX:
                ; TODO - ADD PWR UP CHECK HERE
                EexecAdcAddReg ValRegBX, ValMem
            AdcOp1AddregBP:
                ; TODO - ADD PWR UP CHECK HERE
                EexecAdcAddReg ValRegBP, ValMem
            AdcOp1AddregSI:
                ; TODO - ADD PWR UP CHECK HERE
                EexecAdcAddReg ValRegSI, ValMem
            AdcOp1AddregDI:
                ; TODO - ADD PWR UP CHECK HERE
                EexecAdcAddReg ValRegDI, ValMem
        AdcOp1Mem:

            CMP selectedOp1Mem, 0
            JZ AdcOp1Mem0
            CMP selectedOp1Mem, 1
            JZ AdcOp1Mem1
            CMP selectedOp1Mem, 2
            JZ AdcOp1Mem2
            CMP selectedOp1Mem, 3
            JZ AdcOp1Mem3
            CMP selectedOp1Mem, 4
            JZ AdcOp1Mem4
            CMP selectedOp1Mem, 5
            JZ AdcOp1Mem5
            CMP selectedOp1Mem, 6
            JZ AdcOp1Mem6
            CMP selectedOp1Mem, 7
            JZ AdcOp1Mem7
            CMP selectedOp1Mem, 8
            JZ AdcOp1Mem8
            CMP selectedOp1Mem, 9
            JZ AdcOp1Mem9
            CMP selectedOp1Mem, 10
            JZ AdcOp1Mem10
            CMP selectedOp1Mem, 11
            JZ AdcOp1Mem11
            CMP selectedOp1Mem, 12
            JZ AdcOp1Mem12
            CMP selectedOp1Mem, 13
            JZ AdcOp1Mem13
            CMP selectedOp1Mem, 14
            JZ AdcOp1Mem14
            CMP selectedOp1Mem, 15
            JZ AdcOp1Mem15
            JMP InValidCommand
            
            AdcOp1Mem0:
                ; TODO - ADD PWR UP CHECK HERE
                ExecAdcMem ValMem+0
            AdcOp1Mem1:
                ; TODO - ADD PWR UP CHECK HERE
                ExecAdcMem ValMem+1
            AdcOp1Mem2:
                ; TODO - ADD PWR UP CHECK HERE
                ExecAdcMem ValMem+2
            AdcOp1Mem3:
                ; TODO - ADD PWR UP CHECK HERE
                ExecAdcMem ValMem+3
            AdcOp1Mem4:
                ; TODO - ADD PWR UP CHECK HERE
                ExecAdcMem ValMem+4
            AdcOp1Mem5:
                ; TODO - ADD PWR UP CHECK HERE
                ExecAdcMem ValMem+5
            AdcOp1Mem6:
                ; TODO - ADD PWR UP CHECK HERE
                ExecAdcMem ValMem+6
            AdcOp1Mem7:
                ; TODO - ADD PWR UP CHECK HERE
                ExecAdcMem ValMem+7
            AdcOp1Mem8:
                ; TODO - ADD PWR UP CHECK HERE
                ExecAdcMem ValMem+8
            AdcOp1Mem9:
                ; TODO - ADD PWR UP CHECK HERE
                ExecAdcMem ValMem+9
            AdcOp1Mem10:
                ; TODO - ADD PWR UP CHECK HERE
                ExecAdcMem ValMem+10
            AdcOp1Mem11:
                ; TODO - ADD PWR UP CHECK HERE
                ExecAdcMem ValMem+11
            AdcOp1Mem12:
                ; TODO - ADD PWR UP CHECK HERE
                ExecAdcMem ValMem+12
            AdcOp1Mem13:
                ; TODO - ADD PWR UP CHECK HERE
                ExecAdcMem ValMem+13
            AdcOp1Mem14:
                ; TODO - ADD PWR UP CHECK HERE
                ExecAdcMem ValMem+14
            AdcOp1Mem15:
                ; TODO - ADD PWR UP CHECK HERE
                ExecAdcMem ValMem+15

        
        JMP Exit
    PUSH_Comm:

        CALL Op1Menu

        call  PowerUpeMenu ; to choose power up
        CALL CheckForbidCharProc

        ; Todo - CHECK VALIDATIONS
        CMP selectedOp1Size, 8
        JZ InValidCommand
        CMP selectedOp1Type, 0
        JZ PushOpReg
        CMP selectedOp1Type, 1
        JZ PushOpAddReg
        CMP selectedOp1Type, 2
        JZ PushOpMem
        CMP selectedOp1Type, 3
        JZ PushOpVal
        

        ; TODO - EXECUTE COMMAND WITH DIFFERENT OPERANDS
        ; Reg as operands
        PushOpReg:
            
            CMP selectedOp1Reg, 0
            JZ PushOpRegAX
            CMP selectedOp1Reg, 3
            JZ PushOpRegBX
            CMP selectedOp1Reg, 6
            JZ PushOpRegCX
            CMP selectedOp1Reg, 9
            JZ PushOpRegDX
            CMP selectedOp1Reg, 15
            JZ PushOpRegBP
            CMP selectedOp1Reg, 16
            JZ PushOpRegSP
            CMP selectedOp1Reg, 17
            JZ PushOpRegSI
            CMP selectedOp1Reg, 18
            JZ PushOpRegDI
            JMP InValidCommand


            
            PushOpRegAX:
                ; Delete this lineAX
                ExecPush ValRegAX
                JMP Exit
            PushOpRegBX:
                ; Delete this lineBX
                ExecPush ValRegBX
                JMP Exit
            PushOpRegCX:
                ; Delete this lineCX
                ExecPush ValRegCX
                JMP Exit
            PushOpRegDX:
                ; Delete this lineDX
                ExecPush ValRegDX
                JMP Exit
            PushOpRegBP:
                ; Delete this lineBP
                ExecPush ValRegBP
                JMP Exit
            PushOpRegSP:
                ; Delete this lineSP
                ExecPush ValRegSP
                JMP Exit
            PushOpRegSI:
                ; Delete this lineSI
                ExecPush ValRegSI
                JMP Exit
            PushOpRegDI:
                ; Delete this lineDI
                ExecPush ValRegDI
                JMP Exit

        ; Mem as operand
        PushOpMem:

            CMP selectedOp1Mem, 0
            JZ PushOpMem0
            CMP selectedOp1Mem, 1
            JZ PushOpMem1
            CMP selectedOp1Mem, 2
            JZ PushOpMem2
            CMP selectedOp1Mem, 3
            JZ PushOpMem3
            CMP selectedOp1Mem, 4
            JZ PushOpMem4
            CMP selectedOp1Mem, 5
            JZ PushOpMem5
            CMP selectedOp1Mem, 6
            JZ PushOpMem6
            CMP selectedOp1Mem, 7
            JZ PushOpMem7
            CMP selectedOp1Mem, 8
            JZ PushOpMem8
            CMP selectedOp1Mem, 9
            JZ PushOpMem9
            CMP selectedOp1Mem, 10
            JZ PushOpMem10
            CMP selectedOp1Mem, 11
            JZ PushOpMem11
            CMP selectedOp1Mem, 12
            JZ PushOpMem12
            CMP selectedOp1Mem, 13
            JZ PushOpMem13
            CMP selectedOp1Mem, 14
            JZ PushOpMem14
            CMP selectedOp1Mem, 15
            JZ PushOpMem15
            JMP InValidCommand
            
            PushOpMem0:
                ; Delete this line0
                ExecPushMem ValMem
                JMP Exit
            PushOpMem1:
                ; Delete this line1
                ExecPushMem ValMem+1
                JMP Exit
            PushOpMem2:
                ; Delete this line2
                ExecPushMem ValMem+2
                JMP Exit
            PushOpMem3:
                ; Delete this line3
                ExecPushMem ValMem+3
                JMP Exit
            PushOpMem4:
                ; Delete this line4
                ExecPushMem ValMem+4
                JMP Exit
            PushOpMem5:
                ; Delete this line5
                ExecPushMem ValMem+5
                JMP Exit
            PushOpMem6:
                ; Delete this line6
                ExecPushMem ValMem+6
                JMP Exit
            PushOpMem7:
                ; Delete this line7
                ExecPushMem ValMem+7
                JMP Exit
            PushOpMem8:
                ; Delete this line8
                ExecPushMem ValMem+8
                JMP Exit
            PushOpMem9:
                ; Delete this line9
                ExecPushMem ValMem+9
                JMP Exit
            PushOpMem10:
                ; Delete this line10
                ExecPushMem ValMem+10
                JMP Exit
            PushOpMem11:
                ; Delete this line11
                ExecPushMem ValMem+11
                JMP Exit
            PushOpMem12:
                ; Delete this line12
                ExecPushMem ValMem+12
                JMP Exit
            PushOpMem13:
                ; Delete this line13
                ExecPushMem ValMem+13
                JMP Exit
            PushOpMem14:
                ; Delete this line14
                ExecPushMem ValMem+14
                JMP Exit
            PushOpMem15:
                ; Delete this line15
                ExecPushMem ValMem+15
                JMP Exit

        
        ; Address reg as operands
        PushOpAddReg:

            CMP selectedOp1AddReg, 3
            JZ PushOpAddRegBX
            CMP selectedOp1AddReg, 15
            JZ PushOpAddRegBP
            CMP selectedOp1AddReg, 17
            JZ PushOpAddRegSI
            CMP selectedOp1AddReg, 18
            JZ PushOpAddRegDI
            JMP InValidCommand

            PushOpAddRegBX:
                ; Delete this lineRegBX

                mov dx, ValRegBX
                CALL CheckAddress
                cmp bl, 1               ; Value is greater than 16
                JZ InValidCommand
                mov SI, ValRegBX
                ExecPushMem ValMem[SI]
                JMP Exit
            PushOpAddRegBP:

                mov dx, ValRegBP
                CALL CheckAddress
                cmp bl, 1               ; Value is greater than 16
                JZ InValidCommand
                mov SI, ValRegBP
                ExecPushMem ValMem[SI]
                JMP Exit

            PushOpAddRegSI:
                mov dx, ValRegSI
                CALL CheckAddress
                cmp bl, 1               ; Value is greater than 16
                JZ InValidCommand
                mov SI, ValRegSI
                ExecPushMem ValMem[SI]
                JMP Exit
            
            PushOpAddRegDI:
                mov dx, ValRegDI
                CALL CheckAddress
                cmp bl, 1               ; Value is greater than 16
                JZ InValidCommand
                mov SI, ValRegDI
                ExecPushMem ValMem[SI]
                JMP Exit


        ; Value as operand
        PushOpVal:
            CMP Op1Valid, 0
            jz InValidCommand

            ExecPush Op1Val
            JMP Exit
        
        JMP Exit

    POP_Comm:
        CALL Op1Menu
        CALL CheckForbidCharProc

        call  PowerUpeMenu ; to choose power up

        ; Todo - CHECK VALIDATIONS
        CMP selectedOp1Type, 0
        JZ PopOpReg
        CMP selectedOp1Type, 1
        JZ PopOpAddReg
        CMP selectedOp1Type, 2
        JZ PopOpMem
        JMP InValidCommand
        

        ; TODO - EXECUTE COMMAND WITH DIFFERENT OPERANDS
        ; Reg as operands
        PopOpReg:
            
            CMP selectedOp1Reg, 0
            JZ PopOpRegAX
            CMP selectedOp1Reg, 3
            JZ PopOpRegBX
            CMP selectedOp1Reg, 6
            JZ PopOpRegCX
            CMP selectedOp1Reg, 9
            JZ PopOpRegDX
            CMP selectedOp1Reg, 15
            JZ PopOpRegBP
            CMP selectedOp1Reg, 16
            JZ PopOpRegSP
            CMP selectedOp1Reg, 17
            JZ PopOpRegSI
            CMP selectedOp1Reg, 18
            JZ PopOpRegDI
            JMP InValidCommand


            
            PopOpRegAX:
                ExecPop ValRegAX
                JMP Exit
            PopOpRegBX:
                ExecPop ValRegBX
                JMP Exit
            PopOpRegCX:
                ExecPop ValRegCX
                JMP Exit
            PopOpRegDX:
                ExecPop ValRegDX
                JMP Exit
            PopOpRegBP:
                ExecPop ValRegBP
                JMP Exit
            PopOpRegSP:
                ExecPop ValRegSP
                JMP Exit
            PopOpRegSI:
                ExecPop ValRegSI
                JMP Exit
            PopOpRegDI:
                ExecPop ValRegDI
                JMP Exit

        ; TODO - Mem as operand
        PopOpMem:

            CMP selectedOp1Mem, 0
            JZ PopOpMem0
            CMP selectedOp1Mem, 1
            JZ PopOpMem1
            CMP selectedOp1Mem, 2
            JZ PopOpMem2
            CMP selectedOp1Mem, 3
            JZ PopOpMem3
            CMP selectedOp1Mem, 4
            JZ PopOpMem4
            CMP selectedOp1Mem, 5
            JZ PopOpMem5
            CMP selectedOp1Mem, 6
            JZ PopOpMem6
            CMP selectedOp1Mem, 7
            JZ PopOpMem7
            CMP selectedOp1Mem, 8
            JZ PopOpMem8
            CMP selectedOp1Mem, 9
            JZ PopOpMem9
            CMP selectedOp1Mem, 10
            JZ PopOpMem10
            CMP selectedOp1Mem, 11
            JZ PopOpMem11
            CMP selectedOp1Mem, 12
            JZ PopOpMem12
            CMP selectedOp1Mem, 13
            JZ PopOpMem13
            CMP selectedOp1Mem, 14
            JZ PopOpMem14
            CMP selectedOp1Mem, 15
            JZ PopOpMem15
            JMP InValidCommand
            
            PopOpMem0:
                ExecPopMem ValMem
                JMP Exit
            PopOpMem1:
                ExecPopMem ValMem+1
                JMP Exit
            PopOpMem2:
                ExecPopMem ValMem+2
                JMP Exit
            PopOpMem3:
                ExecPopMem ValMem+3
                JMP Exit
            PopOpMem4:
                ExecPopMem ValMem+4
                JMP Exit
            PopOpMem5:
                ExecPopMem ValMem+5
                JMP Exit
            PopOpMem6:
                ExecPopMem ValMem+6
                JMP Exit
            PopOpMem7:
                ExecPopMem ValMem+7
                JMP Exit
            PopOpMem8:
                ExecPopMem ValMem+8
                JMP Exit
            PopOpMem9:
                ExecPopMem ValMem+9
                JMP Exit
            PopOpMem10:
                ExecPopMem ValMem+10
                JMP Exit
            PopOpMem11:
                ExecPopMem ValMem+11
                JMP Exit
            PopOpMem12:
                ExecPopMem ValMem+12
                JMP Exit
            PopOpMem13:
                ExecPopMem ValMem+13
                JMP Exit
            PopOpMem14:
                ExecPopMem ValMem+14
                JMP Exit
            PopOpMem15:
                ExecPopMem ValMem+15
                JMP Exit

        
        ; TODO - address reg as operands
        PopOpAddReg:

            CMP selectedOp1AddReg, 3
            JZ PopOpAddRegBX
            CMP selectedOp1AddReg, 15
            JZ PopOpAddRegBP
            CMP selectedOp1AddReg, 17
            JZ PopOpAddRegSI
            CMP selectedOp1AddReg, 18
            JZ PopOpAddRegDI
            JMP InValidCommand

            PopOpAddRegBX:
                mov dx, ValRegBX
                CALL CheckAddress
                cmp bl, 1               ; Value is greater than 16
                JZ InValidCommand
                mov SI, ValRegBX
                ExecPopMem ValMem[SI]
                JMP Exit
            PopOpAddRegBP:
                mov dx, ValRegBP
                CALL CheckAddress
                cmp bl, 1               ; Value is greater than 16
                JZ InValidCommand
                mov SI, ValRegBP
                ExecPopMem ValMem[SI]
                JMP Exit

            PopOpAddRegSI:
                mov dx, ValRegSI
                CALL CheckAddress
                cmp bl, 1               ; Value is greater than 16
                JZ InValidCommand
                mov SI, ValRegSI
                ExecPopMem ValMem[SI]
                JMP Exit
            
            PopOpAddRegDI:
                mov dx, ValRegDI
                CALL CheckAddress
                cmp bl, 1               ; Value is greater than 16
                JZ InValidCommand
                mov SI, ValRegDI
                ExecPopMem ValMem[SI]
                JMP Exit


        

        JMP Exit
    
    INC_Comm:
        CALL Op1Menu
        CALL CheckForbidCharProc
        
        call  PowerUpeMenu ; to choose power up

        CMP selectedOp1Type, 0
        JZ IncOpReg
        CMP selectedOp1Type, 1
        JZ IncOpAddReg
        CMP selectedOp1Type, 2
        JZ IncOpMem
        JMP InValidCommand

        IncOpReg:

            CMP selectedOp1Reg, 0
            JZ IncOpRegAX
            CMP selectedOp1Reg, 1
            JZ IncOpRegAL
            CMP selectedOp1Reg, 2
            JZ IncOpRegAH
            CMP selectedOp1Reg, 3
            JZ IncOpRegBX
            CMP selectedOp1Reg, 4
            JZ IncOpRegBL
            CMP selectedOp1Reg, 5
            JZ IncOpRegBH
            CMP selectedOp1Reg, 6
            JZ IncOpRegCX
            CMP selectedOp1Reg, 7
            JZ IncOpRegCL
            CMP selectedOp1Reg, 8
            JZ IncOpRegCH
            CMP selectedOp1Reg, 9
            JZ IncOpRegDX
            CMP selectedOp1Reg, 10
            JZ IncOpRegDL
            CMP selectedOp1Reg, 11
            JZ IncOpRegDH
            
            CMP selectedOp1Reg, 15
            JZ IncOpRegBP
            CMP selectedOp1Reg, 16
            JZ IncOpRegSP
            CMP selectedOp1Reg, 17
            JZ IncOpRegSI
            CMP selectedOp1Reg, 18
            JZ IncOpRegDI
            JMP InValidCommand


            
            IncOpRegAX:
                ExecINC ValRegAX
                JMP Exit
            IncOpRegAL:
                ExecINC ValRegAX
                JMP Exit
            IncOpRegAH:
                ExecINC ValRegAX+1
                JMP Exit
            IncOpRegBX:
                ExecINC ValRegBX
                JMP Exit
            IncOpRegBL:
                ExecINC ValRegBX
                JMP Exit
            IncOpRegBH:
                ExecINC ValRegBX+1
                JMP Exit
            IncOpRegCX:
                ExecINC ValRegCX
                JMP Exit
            IncOpRegCL:
                ExecINC ValRegCX
                JMP Exit
            IncOpRegCH:
                ExecINC ValRegCX+1
                JMP Exit
            IncOpRegDX:
                ExecINC ValRegDX
                JMP Exit
            IncOpRegDL:
                ExecINC ValRegDX
                JMP Exit
            IncOpRegDH:
                ExecINC ValRegDX+1
                JMP Exit
            IncOpRegBP:
                ExecINC ValRegBP
                JMP Exit
            IncOpRegSP:
                ExecINC ValRegSP
                JMP Exit
            IncOpRegSI:
                ExecINC ValRegSI
                JMP Exit
            IncOpRegDI:
                ExecINC ValRegDI
                JMP Exit

        IncOpAddReg:

            CMP selectedOp1Reg, 3
            JZ IncOpAddRegBX
            CMP selectedOp1Reg, 15
            JZ IncOpAddRegBP
            
            CMP selectedOp1Reg, 17
            JZ IncOpAddRegSI
            CMP selectedOp1Reg, 18
            JZ IncOpAddRegDI
            JMP InValidCommand


            
            
            IncOpAddRegBX:
                mov dx, ValRegBX
                CALL CheckAddress
                cmp bl, 1
                jz InValidCommand
                mov di, ValRegBX
                ExecINC ValMem[di]
                JMP Exit
            IncOpAddRegBP:
                mov dx, ValRegBP
                CALL CheckAddress
                cmp bl, 1
                jz InValidCommand
                mov di, ValRegBP
                ExecINC ValMem[di]
                JMP Exit
            IncOpAddRegSP:
                mov dx, ValRegSP
                CALL CheckAddress
                cmp bl, 1
                jz InValidCommand
                mov di, ValRegSP
                ExecINC ValMem[di]
                JMP Exit
            IncOpAddRegSI:
                mov dx, ValRegSI
                CALL CheckAddress
                cmp bl, 1
                jz InValidCommand
                mov di, ValRegSI
                ExecINC ValMem[di]
                JMP Exit
            IncOpAddRegDI:
                mov dx, ValRegDI
                CALL CheckAddress
                cmp bl, 1
                jz InValidCommand
                mov di, ValRegDI
                ExecINC ValMem[di]
                JMP Exit

        IncOpMem:

            CMP selectedOp1Mem, 0
            JZ IncOpMem0
            CMP selectedOp1Mem, 1
            JZ IncOpMem1
            CMP selectedOp1Mem, 2
            JZ IncOpMem2
            CMP selectedOp1Mem, 3
            JZ IncOpMem3
            CMP selectedOp1Mem, 4
            JZ IncOpMem4
            CMP selectedOp1Mem, 5
            JZ IncOpMem5
            CMP selectedOp1Mem, 6
            JZ IncOpMem6
            CMP selectedOp1Mem, 7
            JZ IncOpMem7
            CMP selectedOp1Mem, 8
            JZ IncOpMem8
            CMP selectedOp1Mem, 9
            JZ IncOpMem9
            CMP selectedOp1Mem, 10
            JZ IncOpMem10
            CMP selectedOp1Mem, 11
            JZ IncOpMem11
            CMP selectedOp1Mem, 12
            JZ IncOpMem12
            CMP selectedOp1Mem, 13
            JZ IncOpMem13
            CMP selectedOp1Mem, 14
            JZ IncOpMem14
            CMP selectedOp1Mem, 15
            JZ IncOpMem15
            JMP InValidCommand

            IncOpMem0:
                ExecINC ValMem
                JMP Exit
            IncOpMem1:
                ExecINC ValMem+1
                JMP Exit
            IncOpMem2:
                ExecINC ValMem+2
                JMP Exit
            IncOpMem3:
                ExecINC ValMem+3
                JMP Exit
            IncOpMem4:
                ExecINC ValMem+4
                JMP Exit
            IncOpMem5:
                ExecINC ValMem+5
                JMP Exit
            IncOpMem6:
                ExecINC ValMem+6
                JMP Exit
            IncOpMem7:
                ExecINC ValMem+7
                JMP Exit
            IncOpMem8:
                ExecINC ValMem+8
                JMP Exit
            IncOpMem9:
                ExecINC ValMem+9
                JMP Exit
            IncOpMem10:
                ExecINC ValMem+10
                JMP Exit
            IncOpMem11:
                ExecINC ValMem+11
                JMP Exit
            IncOpMem12:
                ExecINC ValMem+12
                JMP Exit
            IncOpMem13:
                ExecINC ValMem+13
                JMP Exit
            IncOpMem14:
                ExecINC ValMem+14
                JMP Exit
            IncOpMem15:
                ExecINC ValMem+15
                JMP Exit

        JMP Exit
    
    DEC_Comm:
        CALL Op1Menu
        CALL CheckForbidCharProc

        call  PowerUpeMenu ; to choose power up

        CMP selectedOp1Type, 0
        JZ DecOpReg
        CMP selectedOp1Type, 1
        JZ DecOpAddReg
        CMP selectedOp1Type, 2
        JZ DecOpMem
        JMP InValidCommand

        DecOpReg:

            CMP selectedOp1Reg, 0
            JZ DecOpRegAX
            CMP selectedOp1Reg, 1
            JZ DecOpRegAL
            CMP selectedOp1Reg, 2
            JZ DecOpRegAH
            CMP selectedOp1Reg, 3
            JZ DecOpRegBX
            CMP selectedOp1Reg, 4
            JZ DecOpRegBL
            CMP selectedOp1Reg, 5
            JZ DecOpRegBH
            CMP selectedOp1Reg, 6
            JZ DecOpRegCX
            CMP selectedOp1Reg, 7
            JZ DecOpRegCL
            CMP selectedOp1Reg, 8
            JZ DecOpRegCH
            CMP selectedOp1Reg, 9
            JZ DecOpRegDX
            CMP selectedOp1Reg, 10
            JZ DecOpRegDL
            CMP selectedOp1Reg, 11
            JZ DecOpRegDH
            
            CMP selectedOp1Reg, 15
            JZ DecOpRegBP
            CMP selectedOp1Reg, 16
            JZ DecOpRegSP
            CMP selectedOp1Reg, 17
            JZ DecOpRegSI
            CMP selectedOp1Reg, 18
            JZ DecOpRegDI
            JMP InValidCommand


            
            DecOpRegAX:
                ExecDec ValRegAX
                JMP Exit
            DecOpRegAL:
                ExecDec ValRegAX
                JMP Exit
            DecOpRegAH:
                ExecDec ValRegAX+1
                JMP Exit
            DecOpRegBX:
                ExecDec ValRegBX
                JMP Exit
            DecOpRegBL:
                ExecDec ValRegBX
                JMP Exit
            DecOpRegBH:
                ExecDec ValRegBX+1
                JMP Exit
            DecOpRegCX:
                ExecDec ValRegCX
                JMP Exit
            DecOpRegCL:
                ExecDec ValRegCX
                JMP Exit
            DecOpRegCH:
                ExecDec ValRegCX+1
                JMP Exit
            DecOpRegDX:
                ExecDec ValRegDX
                JMP Exit
            DecOpRegDL:
                ExecDec ValRegDX
                JMP Exit
            DecOpRegDH:
                ExecDec ValRegDX+1
                JMP Exit
            DecOpRegBP:
                ExecDec ValRegBP
                JMP Exit
            DecOpRegSP:
                ExecDec ValRegSP
                JMP Exit
            DecOpRegSI:
                ExecDec ValRegSI
                JMP Exit
            DecOpRegDI:
                ExecDec ValRegDI
                JMP Exit

        DecOpAddReg:

            CMP selectedOp1Reg, 3
            JZ DecOpAddRegBX
            CMP selectedOp1Reg, 15
            JZ DecOpAddRegBP
            
            CMP selectedOp1Reg, 17
            JZ DecOpAddRegSI
            CMP selectedOp1Reg, 18
            JZ DecOpAddRegDI
            JMP InValidCommand


            
            
            DecOpAddRegBX:
                mov dx, ValRegBX
                CALL CheckAddress
                cmp bl, 1
                jz InValidCommand
                mov di, ValRegBX
                ExecDec ValMem[di]
                JMP Exit
            DecOpAddRegBP:
                mov dx, ValRegBP
                CALL CheckAddress
                cmp bl, 1
                jz InValidCommand
                mov di, ValRegBP
                ExecDec ValMem[di]
                JMP Exit
            DecOpAddRegSP:
                mov dx, ValRegSP
                CALL CheckAddress
                cmp bl, 1
                jz InValidCommand
                mov di, ValRegSP
                ExecDec ValMem[di]
                JMP Exit
            DecOpAddRegSI:
                mov dx, ValRegSI
                CALL CheckAddress
                cmp bl, 1
                jz InValidCommand
                mov di, ValRegSI
                ExecDec ValMem[di]
                JMP Exit
            DecOpAddRegDI:
                mov dx, ValRegDI
                CALL CheckAddress
                cmp bl, 1
                jz InValidCommand
                mov di, ValRegDI
                ExecDec ValMem[di]
                JMP Exit

        DecOpMem:

            CMP selectedOp1Mem, 0
            JZ DecOpMem0
            CMP selectedOp1Mem, 1
            JZ DecOpMem1
            CMP selectedOp1Mem, 2
            JZ DecOpMem2
            CMP selectedOp1Mem, 3
            JZ DecOpMem3
            CMP selectedOp1Mem, 4
            JZ DecOpMem4
            CMP selectedOp1Mem, 5
            JZ DecOpMem5
            CMP selectedOp1Mem, 6
            JZ DecOpMem6
            CMP selectedOp1Mem, 7
            JZ DecOpMem7
            CMP selectedOp1Mem, 8
            JZ DecOpMem8
            CMP selectedOp1Mem, 9
            JZ DecOpMem9
            CMP selectedOp1Mem, 10
            JZ DecOpMem10
            CMP selectedOp1Mem, 11
            JZ DecOpMem11
            CMP selectedOp1Mem, 12
            JZ DecOpMem12
            CMP selectedOp1Mem, 13
            JZ DecOpMem13
            CMP selectedOp1Mem, 14
            JZ DecOpMem14
            CMP selectedOp1Mem, 15
            JZ DecOpMem15
            JMP InValidCommand

            DecOpMem0:
                ExecDec ValMem
                JMP Exit
            DecOpMem1:
                ExecDec ValMem+1
                JMP Exit
            DecOpMem2:
                ExecDec ValMem+2
                JMP Exit
            DecOpMem3:
                ExecDec ValMem+3
                JMP Exit
            DecOpMem4:
                ExecDec ValMem+4
                JMP Exit
            DecOpMem5:
                ExecDec ValMem+5
                JMP Exit
            DecOpMem6:
                ExecDec ValMem+6
                JMP Exit
            DecOpMem7:
                ExecDec ValMem+7
                JMP Exit
            DecOpMem8:
                ExecDec ValMem+8
                JMP Exit
            DecOpMem9:
                ExecDec ValMem+9
                JMP Exit
            DecOpMem10:
                ExecDec ValMem+10
                JMP Exit
            DecOpMem11:
                ExecDec ValMem+11
                JMP Exit
            DecOpMem12:
                ExecDec ValMem+12
                JMP Exit
            DecOpMem13:
                ExecDec ValMem+13
                JMP Exit
            DecOpMem14:
                ExecDec ValMem+14
                JMP Exit
            DecOpMem15:
                ExecDec ValMem+15
                JMP Exit

        JMP Exit
    
    MUL_Comm:
        CALL Op1Menu

        call  PowerUpeMenu ; to choose power up
        CALL CheckForbidCharProc

        cmp selectedOp1Type, 0
        je Mul_Reg
        cmp selectedOp1Type, 1
        je Mul_AddMem
        cmp selectedOp1Type, 2
        je Mul_Mem
        cmp selectedOp1Type, 3
        je Mul_invalid
        Mul_Reg:
            cmp selectedOp1Reg, 0
            je Mul_Ax
            cmp selectedOp1Reg, 1
            je Mul_Al
            cmp selectedOp1Reg, 2
            je Mul_Ah
            cmp selectedOp1Reg, 3
            je Mul_Bx
            cmp selectedOp1Reg, 4
            je Mul_Bl
            cmp selectedOp1Reg, 5
            je Mul_Bh
            cmp selectedOp1Reg, 6
            je Mul_Cx
            cmp selectedOp1Reg, 7
            je Mul_Cl
            cmp selectedOp1Reg, 8
            je Mul_Ch
            cmp selectedOp1Reg, 9
            je Mul_Dx
            cmp selectedOp1Reg, 10
            je Mul_Dl
            cmp selectedOp1Reg, 11
            je Mul_Dh
            cmp selectedOp1Reg, 15
            je Mul_Bp
            cmp selectedOp1Reg, 16
            je Mul_Sp
            cmp selectedOp1Reg, 17
            je Mul_Si
            cmp selectedOp1Reg, 18
            je Mul_Di
            jmp Mul_invalid
            Mul_Ax:
                mov ax,ValRegAX
                mov dx,ValRegDX
                Mul ax
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Mul_Al:
                mov ax,ValRegAX
                Mul al
                mov ValRegAX,ax
                jmp Exit
            Mul_Ah:
                mov ax,ValRegAX
                Mul ah
                mov ValRegAX,ax
                jmp Exit
            Mul_Bx:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov bx,ValRegBX
                Mul bx
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Mul_Bl:
                mov ax,ValRegAX
                mov bx,ValRegBX
                Mul bl
                mov ValRegAX,ax
                jmp Exit
            Mul_Bh:
                mov ax,ValRegAX
                mov bx,ValRegBX
                Mul bh
                mov ValRegAX,ax
                jmp Exit
            Mul_Cx:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov cx,ValRegBX
                Mul cx
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Mul_Cl:
                mov ax,ValRegAX
                mov cx,ValRegBX
                Mul cl
                mov ValRegAX,ax
                jmp Exit
            Mul_Ch:
                mov ax,ValRegAX
                mov cx,ValRegBX
                Mul ch
                mov ValRegAX,ax
                jmp Exit
            Mul_Dx:
                mov ax,ValRegAX
                mov dx,ValRegDX
                Mul dx
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Mul_Dl:
                mov ax,ValRegAX
                mov dx,ValRegBX
                Mul dl
                mov ValRegAX,ax
                jmp Exit
            Mul_Dh:
                mov ax,ValRegAX
                mov dx,ValRegBX
                Mul dh
                mov ValRegAX,ax
                jmp Exit
            Mul_Bp:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov bp,ValRegBX
                Mul bp
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Mul_Sp:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov SP,ValRegBX
                Mul SP
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Mul_Si:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov si,ValRegBX
                Mul si
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Mul_di:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov di,ValRegBX
                Mul di
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
        Mul_AddMem:
            cmp selectedOp1AddReg, 3
            je Mul_AddBx
            cmp selectedOp1AddReg, 15
            je Mul_AddBp
            cmp selectedOp1AddReg, 17
            je Mul_AddSi
            cmp selectedOp1AddReg, 18
            je Mul_AddDi
            jmp Mul_invalid
            Mul_AddBx:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov bx,ValRegBX
                cmp bx,15d
                ja Mul_invalid
                Mul ValMem[bx]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Mul_AddBp:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov bp,ValRegBP
                cmp bp,15d
                ja Mul_invalid
                Mul ValMem[bp]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Mul_AddSi:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov si,ValRegBX
                cmp si,15d
                ja Mul_invalid
                Mul ValMem[si]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Mul_AddDi:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov di,ValRegBX
                cmp di,15d
                ja Mul_invalid
                Mul ValMem[di]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
        Mul_Mem:
            cmp selectedOp1Mem,0
            je Mul_Mem0
            cmp selectedOp1Mem,1
            je Mul_Mem1
            cmp selectedOp1Mem,2
            je Mul_Mem2
            cmp selectedOp1Mem,3
            je Mul_Mem3
            cmp selectedOp1Mem,4
            je Mul_Mem4
            cmp selectedOp1Mem,5
            je Mul_Mem5
            cmp selectedOp1Mem,6
            je Mul_Mem6
            cmp selectedOp1Mem,7
            je Mul_Mem7
            cmp selectedOp1Mem,8
            je Mul_Mem8
            cmp selectedOp1Mem,9
            je Mul_Mem9
            cmp selectedOp1Mem,10
            je Mul_Mem10
            cmp selectedOp1Mem,11
            je Mul_Mem11
            cmp selectedOp1Mem,12
            je Mul_Mem12
            cmp selectedOp1Mem,13
            je Mul_Mem13
            cmp selectedOp1Mem,14
            je Mul_Mem14
            cmp selectedOp1Mem,15
            je Mul_Mem15
            Mul_Mem0:
                mov ax,ValRegAX
                mov dx,ValRegDX
                Mul ValMem[0]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Mul_Mem1:
                mov ax,ValRegAX
                mov dx,ValRegDX
                Mul ValMem[1]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Mul_Mem2:
                mov ax,ValRegAX
                mov dx,ValRegDX
                Mul ValMem[2]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Mul_Mem3:
                mov ax,ValRegAX
                mov dx,ValRegDX
                Mul ValMem[3]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Mul_Mem4:
                mov ax,ValRegAX
                mov dx,ValRegDX
                Mul ValMem[4]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Mul_Mem5:
                mov ax,ValRegAX
                mov dx,ValRegDX
                Mul ValMem[5]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Mul_Mem6:
                mov ax,ValRegAX
                mov dx,ValRegDX
                Mul ValMem[6]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Mul_Mem7:
                mov ax,ValRegAX
                mov dx,ValRegDX
                Mul ValMem[7]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Mul_Mem8:
                mov ax,ValRegAX
                mov dx,ValRegDX
                Mul ValMem[8]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Mul_Mem9:
                mov ax,ValRegAX
                mov dx,ValRegDX
                Mul ValMem[9]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Mul_Mem10:
                mov ax,ValRegAX
                mov dx,ValRegDX
                Mul ValMem[10]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Mul_Mem11:
                mov ax,ValRegAX
                mov dx,ValRegDX
                Mul ValMem[11]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Mul_Mem12:
                mov ax,ValRegAX
                mov dx,ValRegDX
                Mul ValMem[12]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Mul_Mem13:
                mov ax,ValRegAX
                mov dx,ValRegDX
                Mul ValMem[13]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Mul_Mem14:
                mov ax,ValRegAX
                mov dx,ValRegDX
                Mul ValMem[14]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Mul_Mem15:
                mov ax,ValRegAX
                mov dx,ValRegDX
                Mul ValMem[15]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
        Mul_invalid:
        jmp InValidCommand
        JMP Exit
    
    DIV_Comm:
        CALL Op1Menu

        call  PowerUpeMenu ; to choose power up
        CALL CheckForbidCharProc

        cmp selectedOp1Type, 0
        je Div_Reg
        cmp selectedOp1Type, 1
        je Div_AddMem
        cmp selectedOp1Type, 2
        je Div_Mem
        cmp selectedOp1Type, 3
        je Div_invalid
        Div_Reg:
            cmp selectedOp1Reg, 0
            je Div_Ax
            cmp selectedOp1Reg, 1
            je Div_Al
            cmp selectedOp1Reg, 2
            je Div_Ah
            cmp selectedOp1Reg, 3
            je Div_Bx
            cmp selectedOp1Reg, 4
            je Div_Bl
            cmp selectedOp1Reg, 5
            je Div_Bh
            cmp selectedOp1Reg, 6
            je Div_Cx
            cmp selectedOp1Reg, 7
            je Div_Cl
            cmp selectedOp1Reg, 8
            je Div_Ch
            cmp selectedOp1Reg, 9
            je Div_Dx
            cmp selectedOp1Reg, 10
            je Div_Dl
            cmp selectedOp1Reg, 11
            je Div_Dh
            cmp selectedOp1Reg, 15
            je Div_Bp
            cmp selectedOp1Reg, 16
            je Div_Sp
            cmp selectedOp1Reg, 17
            je Div_Si
            cmp selectedOp1Reg, 18
            je Div_Di
            jmp Div_invalid
            Div_Ax:
                mov ax,ValRegAX
                mov dx,ValRegDX
                div ax
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Div_Al:
                mov ax,ValRegAX
                div al
                mov ValRegAX,ax
                jmp Exit
            Div_Ah:
                mov ax,ValRegAX
                div ah
                mov ValRegAX,ax
                jmp Exit
            Div_Bx:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov bx,ValRegBX
                div bx
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Div_Bl:
                mov ax,ValRegAX
                mov bx,ValRegBX
                div bl
                mov ValRegAX,ax
                jmp Exit
            Div_Bh:
                mov ax,ValRegAX
                mov bx,ValRegBX
                div bh
                mov ValRegAX,ax
                jmp Exit
            Div_Cx:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov cx,ValRegBX
                div cx
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Div_Cl:
                mov ax,ValRegAX
                mov cx,ValRegBX
                div cl
                mov ValRegAX,ax
                jmp Exit
            Div_Ch:
                mov ax,ValRegAX
                mov cx,ValRegBX
                div ch
                mov ValRegAX,ax
                jmp Exit
            Div_Dx:
                mov ax,ValRegAX
                mov dx,ValRegDX
                div dx
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Div_Dl:
                mov ax,ValRegAX
                mov dx,ValRegBX
                div dl
                mov ValRegAX,ax
                jmp Exit
            Div_Dh:
                mov ax,ValRegAX
                mov dx,ValRegBX
                div dh
                mov ValRegAX,ax
                jmp Exit
            Div_Bp:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov bp,ValRegBX
                div bp
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Div_Sp:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov SP,ValRegBX
                div SP
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Div_Si:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov si,ValRegBX
                div si
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Div_di:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov di,ValRegBX
                div di
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
        Div_AddMem:
            cmp selectedOp1AddReg, 3
            je Div_AddBx
            cmp selectedOp1AddReg, 15
            je Div_AddBp
            cmp selectedOp1AddReg, 17
            je Div_AddSi
            cmp selectedOp1AddReg, 18
            je Div_AddDi
            jmp Div_invalid
            Div_AddBx:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov bx,ValRegBX
                cmp bx,15d
                ja Div_invalid
                div ValMem[bx]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Div_AddBp:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov bp,ValRegBP
                cmp bp,15d
                ja Div_invalid
                div ValMem[bp]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Div_AddSi:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov si,ValRegBX
                cmp si,15d
                ja Div_invalid
                div ValMem[si]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Div_AddDi:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov di,ValRegBX
                cmp di,15d
                ja Div_invalid
                div ValMem[di]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
        Div_Mem:
            cmp selectedOp1Mem,0
            je Div_Mem0
            cmp selectedOp1Mem,1
            je Div_Mem1
            cmp selectedOp1Mem,2
            je Div_Mem2
            cmp selectedOp1Mem,3
            je Div_Mem3
            cmp selectedOp1Mem,4
            je Div_Mem4
            cmp selectedOp1Mem,5
            je Div_Mem5
            cmp selectedOp1Mem,6
            je Div_Mem6
            cmp selectedOp1Mem,7
            je Div_Mem7
            cmp selectedOp1Mem,8
            je Div_Mem8
            cmp selectedOp1Mem,9
            je Div_Mem9
            cmp selectedOp1Mem,10
            je Div_Mem10
            cmp selectedOp1Mem,11
            je Div_Mem11
            cmp selectedOp1Mem,12
            je Div_Mem12
            cmp selectedOp1Mem,13
            je Div_Mem13
            cmp selectedOp1Mem,14
            je Div_Mem14
            cmp selectedOp1Mem,15
            je Div_Mem15
            Div_Mem0:
                mov ax,ValRegAX
                mov dx,ValRegDX
                div ValMem[0]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Div_Mem1:
                mov ax,ValRegAX
                mov dx,ValRegDX
                div ValMem[1]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Div_Mem2:
                mov ax,ValRegAX
                mov dx,ValRegDX
                div ValMem[2]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Div_Mem3:
                mov ax,ValRegAX
                mov dx,ValRegDX
                div ValMem[3]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Div_Mem4:
                mov ax,ValRegAX
                mov dx,ValRegDX
                div ValMem[4]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Div_Mem5:
                mov ax,ValRegAX
                mov dx,ValRegDX
                div ValMem[5]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Div_Mem6:
                mov ax,ValRegAX
                mov dx,ValRegDX
                div ValMem[6]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Div_Mem7:
                mov ax,ValRegAX
                mov dx,ValRegDX
                div ValMem[7]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Div_Mem8:
                mov ax,ValRegAX
                mov dx,ValRegDX
                div ValMem[8]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Div_Mem9:
                mov ax,ValRegAX
                mov dx,ValRegDX
                div ValMem[9]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Div_Mem10:
                mov ax,ValRegAX
                mov dx,ValRegDX
                div ValMem[10]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Div_Mem11:
                mov ax,ValRegAX
                mov dx,ValRegDX
                div ValMem[11]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Div_Mem12:
                mov ax,ValRegAX
                mov dx,ValRegDX
                div ValMem[12]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Div_Mem13:
                mov ax,ValRegAX
                mov dx,ValRegDX
                div ValMem[13]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Div_Mem14:
                mov ax,ValRegAX
                mov dx,ValRegDX
                div ValMem[14]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            Div_Mem15:
                mov ax,ValRegAX
                mov dx,ValRegDX
                div ValMem[15]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
        Div_invalid:
        jmp InValidCommand
        JMP Exit
    IMul_Comm:
        CALL Op1Menu

        call  PowerUpeMenu ; to choose power up
        CALL CheckForbidCharProc

        cmp selectedOp1Type, 0
        je IMul_Reg
        cmp selectedOp1Type, 1
        je IMul_AddMem
        cmp selectedOp1Type, 2
        je IMul_Mem
        cmp selectedOp1Type, 3
        je IMul_invalid
        IMul_Reg:
            cmp selectedOp1Reg, 0
            je IMul_Ax
            cmp selectedOp1Reg, 1
            je IMul_Al
            cmp selectedOp1Reg, 2
            je IMul_Ah
            cmp selectedOp1Reg, 3
            je IMul_Bx
            cmp selectedOp1Reg, 4
            je IMul_Bl
            cmp selectedOp1Reg, 5
            je IMul_Bh
            cmp selectedOp1Reg, 6
            je IMul_Cx
            cmp selectedOp1Reg, 7
            je IMul_Cl
            cmp selectedOp1Reg, 8
            je IMul_Ch
            cmp selectedOp1Reg, 9
            je IMul_Dx
            cmp selectedOp1Reg, 10
            je IMul_Dl
            cmp selectedOp1Reg, 11
            je IMul_Dh
            cmp selectedOp1Reg, 15
            je IMul_Bp
            cmp selectedOp1Reg, 16
            je IMul_Sp
            cmp selectedOp1Reg, 17
            je IMul_Si
            cmp selectedOp1Reg, 18
            je IMul_Di
            jmp IMul_invalid
            IMul_Ax:
                mov ax,ValRegAX
                mov dx,ValRegDX
                IMul ax
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IMul_Al:
                mov ax,ValRegAX
                IMul al
                mov ValRegAX,ax
                jmp Exit
            IMul_Ah:
                mov ax,ValRegAX
                IMul ah
                mov ValRegAX,ax
                jmp Exit
            IMul_Bx:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov bx,ValRegBX
                IMul bx
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IMul_Bl:
                mov ax,ValRegAX
                mov bx,ValRegBX
                IMul bl
                mov ValRegAX,ax
                jmp Exit
            IMul_Bh:
                mov ax,ValRegAX
                mov bx,ValRegBX
                IMul bh
                mov ValRegAX,ax
                jmp Exit
            IMul_Cx:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov cx,ValRegBX
                IMul cx
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IMul_Cl:
                mov ax,ValRegAX
                mov cx,ValRegBX
                IMul cl
                mov ValRegAX,ax
                jmp Exit
            IMul_Ch:
                mov ax,ValRegAX
                mov cx,ValRegBX
                IMul ch
                mov ValRegAX,ax
                jmp Exit
            IMul_Dx:
                mov ax,ValRegAX
                mov dx,ValRegDX
                IMul dx
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IMul_Dl:
                mov ax,ValRegAX
                mov dx,ValRegBX
                IMul dl
                mov ValRegAX,ax
                jmp Exit
            IMul_Dh:
                mov ax,ValRegAX
                mov dx,ValRegBX
                IMul dh
                mov ValRegAX,ax
                jmp Exit
            IMul_Bp:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov bp,ValRegBX
                IMul bp
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IMul_Sp:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov SP,ValRegBX
                IMul SP
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IMul_Si:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov si,ValRegBX
                IMul si
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IMul_di:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov di,ValRegBX
                IMul di
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
        IMul_AddMem:
            cmp selectedOp1AddReg, 3
            je IMul_AddBx
            cmp selectedOp1AddReg, 15
            je IMul_AddBp
            cmp selectedOp1AddReg, 17
            je IMul_AddSi
            cmp selectedOp1AddReg, 18
            je IMul_AddDi
            jmp IMul_invalid
            IMul_AddBx:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov bx,ValRegBX
                cmp bx,15d
                ja IMul_invalid
                IMul ValMem[bx]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IMul_AddBp:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov bp,ValRegBX
                cmp bp,15d
                ja IMul_invalid
                IMul ValMem[bp]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IMul_AddSi:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov si,ValRegBX
                cmp si,15d
                ja IMul_invalid
                IMul ValMem[si]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IMul_AddDi:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov di,ValRegBX
                cmp di,15d
                ja IMul_invalid
                IMul ValMem[di]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
        IMul_Mem:
            cmp selectedOp1Mem,0
            je IMul_Mem0
            cmp selectedOp1Mem,1
            je IMul_Mem1
            cmp selectedOp1Mem,2
            je IMul_Mem2
            cmp selectedOp1Mem,3
            je IMul_Mem3
            cmp selectedOp1Mem,4
            je IMul_Mem4
            cmp selectedOp1Mem,5
            je IMul_Mem5
            cmp selectedOp1Mem,6
            je IMul_Mem6
            cmp selectedOp1Mem,7
            je IMul_Mem7
            cmp selectedOp1Mem,8
            je IMul_Mem8
            cmp selectedOp1Mem,9
            je IMul_Mem9
            cmp selectedOp1Mem,10
            je IMul_Mem10
            cmp selectedOp1Mem,11
            je IMul_Mem11
            cmp selectedOp1Mem,12
            je IMul_Mem12
            cmp selectedOp1Mem,13
            je IMul_Mem13
            cmp selectedOp1Mem,14
            je IMul_Mem14
            cmp selectedOp1Mem,15
            je IMul_Mem15
            IMul_Mem0:
                mov ax,ValRegAX
                mov dx,ValRegDX
                IMul ValMem[0]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IMul_Mem1:
                mov ax,ValRegAX
                mov dx,ValRegDX
                IMul ValMem[1]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IMul_Mem2:
                mov ax,ValRegAX
                mov dx,ValRegDX
                IMul ValMem[2]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IMul_Mem3:
                mov ax,ValRegAX
                mov dx,ValRegDX
                IMul ValMem[3]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IMul_Mem4:
                mov ax,ValRegAX
                mov dx,ValRegDX
                IMul ValMem[4]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IMul_Mem5:
                mov ax,ValRegAX
                mov dx,ValRegDX
                IMul ValMem[5]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IMul_Mem6:
                mov ax,ValRegAX
                mov dx,ValRegDX
                IMul ValMem[6]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IMul_Mem7:
                mov ax,ValRegAX
                mov dx,ValRegDX
                IMul ValMem[7]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IMul_Mem8:
                mov ax,ValRegAX
                mov dx,ValRegDX
                IMul ValMem[8]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IMul_Mem9:
                mov ax,ValRegAX
                mov dx,ValRegDX
                IMul ValMem[9]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IMul_Mem10:
                mov ax,ValRegAX
                mov dx,ValRegDX
                IMul ValMem[10]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IMul_Mem11:
                mov ax,ValRegAX
                mov dx,ValRegDX
                IMul ValMem[11]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IMul_Mem12:
                mov ax,ValRegAX
                mov dx,ValRegDX
                IMul ValMem[12]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IMul_Mem13:
                mov ax,ValRegAX
                mov dx,ValRegDX
                IMul ValMem[13]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IMul_Mem14:
                mov ax,ValRegAX
                mov dx,ValRegDX
                IMul ValMem[14]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IMul_Mem15:
                mov ax,ValRegAX
                mov dx,ValRegDX
                IMul ValMem[15]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
        IMul_invalid:
        jmp InValidCommand
        JMP Exit
    
    IDiv_Comm:
        CALL Op1Menu

        call  PowerUpeMenu ; to choose power up
        CALL CheckForbidCharProc

        cmp selectedOp1Type, 0
        je IDiv_Reg
        cmp selectedOp1Type, 1
        je IDiv_AddMem
        cmp selectedOp1Type, 2
        je IDiv_Mem
        cmp selectedOp1Type, 3
        je IDiv_invalid
        IDiv_Reg:
            cmp selectedOp1Reg, 0
            je IDiv_Ax
            cmp selectedOp1Reg, 1
            je IDiv_Al
            cmp selectedOp1Reg, 2
            je IDiv_Ah
            cmp selectedOp1Reg, 3
            je IDiv_Bx
            cmp selectedOp1Reg, 4
            je IDiv_Bl
            cmp selectedOp1Reg, 5
            je IDiv_Bh
            cmp selectedOp1Reg, 6
            je IDiv_Cx
            cmp selectedOp1Reg, 7
            je IDiv_Cl
            cmp selectedOp1Reg, 8
            je IDiv_Ch
            cmp selectedOp1Reg, 9
            je IDiv_Dx
            cmp selectedOp1Reg, 10
            je IDiv_Dl
            cmp selectedOp1Reg, 11
            je IDiv_Dh
            cmp selectedOp1Reg, 15
            je IDiv_Bp
            cmp selectedOp1Reg, 16
            je IDiv_Sp
            cmp selectedOp1Reg, 17
            je IDiv_Si
            cmp selectedOp1Reg, 18
            je IDiv_Di
            jmp IDiv_invalid
            IDiv_Ax:
                mov ax,ValRegAX
                mov dx,ValRegDX
                IDiv ax
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IDiv_Al:
                mov ax,ValRegAX
                IDiv al
                mov ValRegAX,ax
                jmp Exit
            IDiv_Ah:
                mov ax,ValRegAX
                IDiv ah
                mov ValRegAX,ax
                jmp Exit
            IDiv_Bx:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov bx,ValRegBX
                IDiv bx
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IDiv_Bl:
                mov ax,ValRegAX
                mov bx,ValRegBX
                IDiv bl
                mov ValRegAX,ax
                jmp Exit
            IDiv_Bh:
                mov ax,ValRegAX
                mov bx,ValRegBX
                IDiv bh
                mov ValRegAX,ax
                jmp Exit
            IDiv_Cx:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov cx,ValRegBX
                IDiv cx
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IDiv_Cl:
                mov ax,ValRegAX
                mov cx,ValRegBX
                IDiv cl
                mov ValRegAX,ax
                jmp Exit
            IDiv_Ch:
                mov ax,ValRegAX
                mov cx,ValRegBX
                IDiv ch
                mov ValRegAX,ax
                jmp Exit
            IDiv_Dx:
                mov ax,ValRegAX
                mov dx,ValRegDX
                IDiv dx
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IDiv_Dl:
                mov ax,ValRegAX
                mov dx,ValRegBX
                IDiv dl
                mov ValRegAX,ax
                jmp Exit
            IDiv_Dh:
                mov ax,ValRegAX
                mov dx,ValRegBX
                IDiv dh
                mov ValRegAX,ax
                jmp Exit
            IDiv_Bp:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov bp,ValRegBX
                IDiv bp
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IDiv_Sp:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov SP,ValRegBX
                IDiv SP
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IDiv_Si:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov si,ValRegBX
                IDiv si
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IDiv_di:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov di,ValRegBX
                IDiv di
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
        IDiv_AddMem:
            cmp selectedOp1AddReg, 3
            je IDiv_AddBx
            cmp selectedOp1AddReg, 15
            je IDiv_AddBp
            cmp selectedOp1AddReg, 17
            je IDiv_AddSi
            cmp selectedOp1AddReg, 18
            je IDiv_AddDi
            jmp IDiv_invalid
            IDiv_AddBx:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov bx,ValRegBX
                cmp bx,15d
                ja IDiv_invalid
                IDiv ValMem[bx]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IDiv_AddBp:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov bp,ValRegBP
                cmp bp,15d
                ja IDiv_invalid
                IDiv ValMem[bp]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IDiv_AddSi:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov si,ValRegBX
                cmp si,15d
                ja IDiv_invalid
                IDiv ValMem[si]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IDiv_AddDi:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov di,ValRegBX
                cmp di,15d
                ja IDiv_invalid
                IDiv ValMem[di]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
        IDiv_Mem:
            cmp selectedOp1Mem,0
            je IDiv_Mem0
            cmp selectedOp1Mem,1
            je IDiv_Mem1
            cmp selectedOp1Mem,2
            je IDiv_Mem2
            cmp selectedOp1Mem,3
            je IDiv_Mem3
            cmp selectedOp1Mem,4
            je IDiv_Mem4
            cmp selectedOp1Mem,5
            je IDiv_Mem5
            cmp selectedOp1Mem,6
            je IDiv_Mem6
            cmp selectedOp1Mem,7
            je IDiv_Mem7
            cmp selectedOp1Mem,8
            je IDiv_Mem8
            cmp selectedOp1Mem,9
            je IDiv_Mem9
            cmp selectedOp1Mem,10
            je IDiv_Mem10
            cmp selectedOp1Mem,11
            je IDiv_Mem11
            cmp selectedOp1Mem,12
            je IDiv_Mem12
            cmp selectedOp1Mem,13
            je IDiv_Mem13
            cmp selectedOp1Mem,14
            je IDiv_Mem14
            cmp selectedOp1Mem,15
            je IDiv_Mem15
            IDiv_Mem0:
                mov ax,ValRegAX
                mov dx,ValRegDX
                IDiv ValMem[0]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IDiv_Mem1:
                mov ax,ValRegAX
                mov dx,ValRegDX
                IDiv ValMem[1]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IDiv_Mem2:
                mov ax,ValRegAX
                mov dx,ValRegDX
                IDiv ValMem[2]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IDiv_Mem3:
                mov ax,ValRegAX
                mov dx,ValRegDX
                IDiv ValMem[3]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IDiv_Mem4:
                mov ax,ValRegAX
                mov dx,ValRegDX
                IDiv ValMem[4]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IDiv_Mem5:
                mov ax,ValRegAX
                mov dx,ValRegDX
                IDiv ValMem[5]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IDiv_Mem6:
                mov ax,ValRegAX
                mov dx,ValRegDX
                IDiv ValMem[6]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IDiv_Mem7:
                mov ax,ValRegAX
                mov dx,ValRegDX
                IDiv ValMem[7]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IDiv_Mem8:
                mov ax,ValRegAX
                mov dx,ValRegDX
                IDiv ValMem[8]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IDiv_Mem9:
                mov ax,ValRegAX
                mov dx,ValRegDX
                IDiv ValMem[9]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IDiv_Mem10:
                mov ax,ValRegAX
                mov dx,ValRegDX
                IDiv ValMem[10]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IDiv_Mem11:
                mov ax,ValRegAX
                mov dx,ValRegDX
                IDiv ValMem[11]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IDiv_Mem12:
                mov ax,ValRegAX
                mov dx,ValRegDX
                IDiv ValMem[12]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IDiv_Mem13:
                mov ax,ValRegAX
                mov dx,ValRegDX
                IDiv ValMem[13]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IDiv_Mem14:
                mov ax,ValRegAX
                mov dx,ValRegDX
                IDiv ValMem[14]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
            IDiv_Mem15:
                mov ax,ValRegAX
                mov dx,ValRegDX
                IDiv ValMem[15]
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
        IDiv_invalid:
        jmp InValidCommand
        JMP Exit
    ROR_Comm:
        CALL Op1Menu
        MOV DX, CommaCursorLoc
        CALL SetCursor
        mov dl, ','
        CALL DisplayChar
        CALL Op2Menu

        call  PowerUpeMenu ; to choose power up
        CALL CheckForbidCharProc

        cmp selectedOp1Type,0
        je ROR_Reg
        cmp selectedOp1Type,1
        je ROR_AddReg
        cmp selectedOp1Type,2
        je ROR_Mem
        cmp selectedOp1Type,3
        je ROR_invalid

        ROR_Reg:
            cmp selectedOp1Reg,0
            je ROR_Ax
            cmp selectedOp1Reg,1
            je ROR_Al
            cmp selectedOp1Reg,2
            je ROR_Ah
            cmp selectedOp1Reg,3
            je ROR_bx
            cmp selectedOp1Reg,4
            je ROR_Bl
            cmp selectedOp1Reg,5
            je ROR_Bh
            cmp selectedOp1Reg,6
            je ROR_Cx
            cmp selectedOp1Reg,7
            je ROR_Cl
            cmp selectedOp1Reg,8
            je ROR_Ch
            cmp selectedOp1Reg,9
            je ROR_Dx
            cmp selectedOp1Reg,10
            je ROR_Dl
            cmp selectedOp1Reg,11
            je ROR_Dh
            cmp selectedOp1Reg,15
            je ROR_Bp
            cmp selectedOp1Reg,16
            je ROR_Sp
            cmp selectedOp1Reg,17
            je ROR_Si
            cmp selectedOp1Reg,18
            je ROR_Di
            jmp ROR_invalid
            ROR_Ax:
                cmp selectedOp2Type,0
                je ROR_Ax_Reg
                cmp selectedOp2Type,3
                je ROR_Ax_Val
                jmp ROR_invalid
                ROR_Ax_Reg:
                    cmp selectedOp2Reg,7
                    jne ROR_invalid
                    mov ax,ValRegAX
                    mov cx,ValRegCX
                    ror Ax,cl
                    mov ValRegAX,ax
                    jmp Exit
                ROR_Ax_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    mov ax,ValRegAX
                    mov cx,Op2Val
                    ror ax,cl
                    mov ValRegAX,ax
                    jmp Exit
            ROR_Al:
                cmp selectedOp2Type,0
                je ROR_Al_Reg
                cmp selectedOp2Type,3
                je ROR_Al_Val
                jmp ROR_invalid
                ROR_Al_Reg:
                    cmp selectedOp2Reg,7
                    jne ROR_invalid
                    mov ax,ValRegAX
                    mov cx,ValRegCX
                    ror Al,cl
                    mov ValRegAX,ax
                    jmp Exit
                ROR_Al_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    mov ax,ValRegAX
                    mov cx,Op2Val
                    ror al,cl
                    mov ValRegAX,ax
                    jmp Exit
            ROR_Ah:
                cmp selectedOp2Type,0
                je ROR_Ah_Reg
                cmp selectedOp2Type,3
                je ROR_Ah_Val
                jmp ROR_invalid
                ROR_Ah_Reg:
                    cmp selectedOp2Reg,7
                    jne ROR_invalid
                    mov ax,ValRegAX
                    mov cx,ValRegCX
                    ror Ah,cl
                    mov ValRegAX,ax
                    jmp Exit
                ROR_Ah_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    mov ax,ValRegAX
                    mov cx,Op2Val
                    ror ah,cl
                    mov ValRegAX,ax
                    jmp Exit
            ROR_Bx:
                cmp selectedOp2Type,0
                je ROR_Bx_Reg
                cmp selectedOp2Type,3
                je ROR_Bx_Val
                jmp ROR_invalid
                ROR_Bx_Reg:
                    cmp selectedOp2Reg,7
                    jne ROR_invalid
                    mov Bx,ValRegBX
                    mov cx,ValRegCX
                    ror Bx,cl
                    mov ValRegBX,Bx
                    jmp Exit
                ROR_Bx_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    mov Bx,ValRegBX
                    mov cx,Op2Val
                    ror Bx,cl
                    mov ValRegBX,Bx
                    jmp Exit
            ROR_Bl:
                cmp selectedOp2Type,0
                je ROR_Bl_Reg
                cmp selectedOp2Type,3
                je ROR_Bl_Val
                jmp ROR_invalid
                ROR_Bl_Reg:
                    cmp selectedOp2Reg,7
                    jne ROR_invalid
                    mov Bx,ValRegBX
                    mov cx,ValRegCX
                    ror Bl,cl
                    mov ValRegBX,Bx
                    jmp Exit
                ROR_Bl_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    mov Bx,ValRegBX
                    mov cx,Op2Val
                    ror Bl,cl
                    mov ValRegBX,Bx
                    jmp Exit
            ROR_Bh:
                cmp selectedOp2Type,0
                je ROR_Bh_Reg
                cmp selectedOp2Type,3
                je ROR_Bh_Val
                jmp ROR_invalid
                ROR_Bh_Reg:
                    cmp selectedOp2Reg,7
                    jne ROR_invalid
                    mov Bx,ValRegBX
                    mov cx,ValRegCX
                    ror Bh,cl
                    mov ValRegBX,Bx
                    jmp Exit
                ROR_Bh_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    mov Bx,ValRegBX
                    mov cx,Op2Val
                    ror Bh,cl
                    mov ValRegBX,Bx
                    jmp Exit
            ROR_Cx:
                cmp selectedOp2Type,0
                je ROR_Cx_Reg
                cmp selectedOp2Type,3
                je ROR_Cx_Val
                jmp ROR_invalid
                ROR_Cx_Reg:
                    cmp selectedOp2Reg,7
                    jne ROR_invalid
                    mov Cx,ValRegCx
                    mov cx,ValRegCX
                    ror Cx,cl
                    mov ValRegCx,Cx
                    jmp Exit
                ROR_Cx_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    mov bx,ValRegCx
                    mov cx,Op2Val
                    ror bx,cl
                    mov ValRegCx,bx
                    jmp Exit
            ROR_Cl:
                cmp selectedOp2Type,0
                je ROR_Cl_Reg
                cmp selectedOp2Type,3
                je ROR_Cl_Val
                jmp ROR_invalid
                ROR_Cl_Reg:
                    cmp selectedOp2Reg,7
                    jne ROR_invalid
                    mov cx,ValRegCX
                    ror Cl,cl
                    mov ValRegCX,Cx
                    jmp Exit
                ROR_Cl_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    mov Bx,ValRegCX
                    mov cx,Op2Val
                    ror Bl,cl
                    mov ValRegCX,Bx
                    jmp Exit
            ROR_Ch:
                cmp selectedOp2Type,0
                je ROR_Ch_Reg
                cmp selectedOp2Type,3
                je ROR_Ch_Val
                jmp ROR_invalid
                ROR_Ch_Reg:
                    cmp selectedOp2Reg,7
                    jne ROR_invalid
                    mov cx,ValRegCX
                    ror Ch,cl
                    mov ValRegCX,Cx
                    jmp Exit
                ROR_Ch_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    mov Bx,ValRegCX
                    mov cx,Op2Val
                    ror bh,cl
                    mov ValRegCX,Bx
                    jmp Exit
            ROR_Dx:
                cmp selectedOp2Type,0
                je ROR_Dx_Reg
                cmp selectedOp2Type,3
                je ROR_Dx_Val
                jmp ROR_invalid
                ROR_Dx_Reg:
                    cmp selectedOp2Reg,7
                    jne ROR_invalid
                    mov Dx,ValRegDX
                    mov cx,ValRegCX
                    ror Dx,cl
                    mov ValRegDX,Dx
                    jmp Exit
                ROR_Dx_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    mov Dx,ValRegDX
                    mov cx,Op2Val
                    ror Dx,cl
                    mov ValRegDX,Dx
                    jmp Exit
            ROR_Dl:
                cmp selectedOp2Type,0
                je ROR_Dl_Reg
                cmp selectedOp2Type,3
                je ROR_Dl_Val
                jmp ROR_invalid
                ROR_Dl_Reg:
                    cmp selectedOp2Reg,7
                    jne ROR_invalid
                    mov Dx,ValRegDX
                    mov cx,ValRegCX
                    ror Dl,cl
                    mov ValRegDX,Dx
                    jmp Exit
                ROR_Dl_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    mov Dx,ValRegDX
                    mov cx,Op2Val
                    ror Dl,cl
                    mov ValRegDX,Dx
                    jmp Exit
            ROR_Dh:
                cmp selectedOp2Type,0
                je ROR_Dh_Reg
                cmp selectedOp2Type,3
                je ROR_Dh_Val
                jmp ROR_invalid
                ROR_Dh_Reg:
                    cmp selectedOp2Reg,7
                    jne ROR_invalid
                    mov Dx,ValRegDX
                    mov cx,ValRegCX
                    ror Dh,cl
                    mov ValRegDX,Dx
                    jmp Exit
                ROR_Dh_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    mov Dx,ValRegDX
                    mov cx,Op2Val
                    ror Dh,cl
                    mov ValRegDX,Dx
                    jmp Exit
            ROR_Bp:
                cmp selectedOp2Type,0
                je ROR_Bp_Reg
                cmp selectedOp2Type,3
                je ROR_Bp_Val
                jmp ROR_invalid
                ROR_Bp_Reg:
                    cmp selectedOp2Reg,7
                    jne ROR_invalid
                    mov Bp,ValRegBP
                    mov cx,ValRegCX
                    ror BP,cl
                    mov ValRegBP,BP
                    jmp Exit
                ROR_BP_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    mov BP,ValRegBP
                    mov cx,Op2Val
                    ror BP,cl
                    mov ValRegBP,BP
                    jmp Exit
            ROR_Sp:
                cmp selectedOp2Type,0
                je ROR_SP_Reg
                cmp selectedOp2Type,3
                je ROR_SP_Val
                jmp ROR_invalid
                ROR_SP_Reg:
                    cmp selectedOp2Reg,7
                    jne ROR_invalid
                    mov SP,ValRegSP
                    mov cx,ValRegCX
                    ror SP,cl
                    mov ValRegSP,SP
                    jmp Exit
                ROR_SP_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    mov SP,ValRegSP
                    mov cx,Op2Val
                    ror SP,cl
                    mov ValRegSP,SP
                    jmp Exit
            ROR_Si:
                cmp selectedOp2Type,0
                je ROR_SI_Reg
                cmp selectedOp2Type,3
                je ROR_SI_Val
                jmp ROR_invalid
                ROR_SI_Reg:
                    cmp selectedOp2Reg,7
                    jne ROR_invalid
                    mov SI,ValRegSI
                    mov cx,ValRegCX
                    ror SI,cl
                    mov ValRegSI,SI
                    jmp Exit
                ROR_SI_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    mov SI,ValRegSI
                    mov cx,Op2Val
                    ror SI,cl
                    mov ValRegSI,SI
                    jmp Exit
            ROR_Di:
                cmp selectedOp2Type,0
                je ROR_DI_Reg
                cmp selectedOp2Type,3
                je ROR_DI_Val
                jmp ROR_invalid
                ROR_DI_Reg:
                    cmp selectedOp2Reg,7
                    jne ROR_invalid
                    mov DI,ValRegDI
                    mov cx,ValRegCX
                    ror DI,cl
                    mov ValRegDI,DI
                    jmp Exit
                ROR_DI_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    mov DI,ValRegDI
                    mov cx,Op2Val
                    ror DI,cl
                    mov ValRegDI,DI
                    jmp Exit
        ROR_AddReg:
            cmp selectedOp1AddReg,3
            je ROR_AddBx
            cmp selectedOp1AddReg,15
            je ROR_AddBp
            cmp selectedOp1AddReg,17
            je ROR_AddSi
            cmp selectedOp1AddReg,18
            je ROR_AddDi
            jmp ROR_invalid
            ROR_AddBx:
                cmp selectedOp2Type,0
                je ROR_AddBx_Reg
                cmp selectedOp2Type,3
                je ROR_AddBx_Val
                jmp ROR_invalid
                ROR_AddBx_Reg:
                    cmp selectedOp2Reg,7
                    jne ROR_invalid
                    mov Bx,ValRegBX
                    cmp Bx,15d
                    ja ROR_invalid
                    mov cx,ValRegCX
                    ror ValMem[Bx],cl
                    mov ValRegBX,Bx
                    jmp Exit
                ROR_AddBx_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    mov Bx,ValRegBX
                    cmp Bx,15d
                    ja ROR_invalid
                    mov cx,Op2Val
                    ror ValMem[Bx],cl
                    mov ValRegBX,Bx
                    jmp Exit
            ROR_AddBp:
                cmp selectedOp2Type,0
                je ROR_AddBP_Reg
                cmp selectedOp2Type,3
                je ROR_AddBP_Val
                jmp ROR_invalid
                ROR_AddBP_Reg:
                    cmp selectedOp2Reg,7
                    jne ROR_invalid
                    mov BP,ValRegBP
                    cmp BP,15d
                    ja ROR_invalid
                    mov cx,ValRegCX
                    ror ValMem[BP],cl
                    mov ValRegBP,BP
                    jmp Exit
                ROR_AddBP_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    mov BP,ValRegBP
                    cmp BP,15d
                    ja ROR_invalid
                    mov cx,Op2Val
                    ror ValMem[BP],cl
                    mov ValRegBP,BP
                    jmp Exit
            ROR_AddSi:
                cmp selectedOp2Type,0
                je ROR_AddSi_Reg
                cmp selectedOp2Type,3
                je ROR_AddSi_Val
                jmp ROR_invalid
                ROR_AddSi_Reg:
                    cmp selectedOp2Reg,7
                    jne ROR_invalid
                    mov Si,ValRegSI
                    cmp Si,15d
                    ja ROR_invalid
                    mov cx,ValRegCX
                    ror ValMem[Si],cl
                    mov ValRegSI,Si
                    jmp Exit
                ROR_AddSi_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    mov Si,ValRegSI
                    cmp Si,15d
                    ja ROR_invalid
                    mov cx,Op2Val
                    ror ValMem[Si],cl
                    mov ValRegSI,Si
                    jmp Exit
            ROR_AddDi:
                cmp selectedOp2Type,0
                je ROR_AddDI_Reg
                cmp selectedOp2Type,3
                je ROR_AddDI_Val
                jmp ROR_invalid
                ROR_AddDI_Reg:
                    cmp selectedOp2Reg,7
                    jne ROR_invalid
                    mov DI,ValRegDI
                    cmp DI,15d
                    ja ROR_invalid
                    mov cx,ValRegCX
                    ror ValMem[DI],cl
                    mov ValRegDI,DI
                    jmp Exit
                ROR_AddDI_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    mov DI,ValRegDI
                    cmp DI,15d
                    ja ROR_invalid
                    mov cx,Op2Val
                    ror ValMem[DI],cl
                    mov ValRegDI,DI
                    jmp Exit
        ROR_Mem:
            cmp selectedOp1Mem,0
            je ROR_Mem0
            cmp selectedOp1Mem,1
            je ROR_Mem1
            cmp selectedOp1Mem,2
            je ROR_Mem2
            cmp selectedOp1Mem,3
            je ROR_Mem3
            cmp selectedOp1Mem,4
            je ROR_Mem4
            cmp selectedOp1Mem,5
            je ROR_Mem5
            cmp selectedOp1Mem,6
            je ROR_Mem6
            cmp selectedOp1Mem,7
            je ROR_Mem7
            cmp selectedOp1Mem,8
            je ROR_Mem8
            cmp selectedOp1Mem,9
            je ROR_Mem9
            cmp selectedOp1Mem,10
            je ROR_Mem10
            cmp selectedOp1Mem,11
            je ROR_Mem11
            cmp selectedOp1Mem,12
            je ROR_Mem12
            cmp selectedOp1Mem,13
            je ROR_Mem13
            cmp selectedOp1Mem,14
            je ROR_Mem14
            cmp selectedOp1Mem,15
            je ROR_Mem15
            jmp ROR_invalid
            ROR_Mem0:
                cmp selectedOp2Type,0
                je ROR_Mem0_Reg
                cmp selectedOp2Type,3
                je ROR_Mem0_Val
                jmp ROR_invalid
                ROR_Mem0_Reg:
                    cmp selectedOp2Reg,7
                    jne ROR_invalid
                    mov cx,ValRegCX
                    Ror ValMem[0],cl
                    jmp Exit
                ROR_Mem0_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    mov cx,Op2Val
                    ror ValMem[0],cl
                    jmp Exit
            ROR_Mem1:
                cmp selectedOp2Type,0
                je ROR_Mem1_Reg
                cmp selectedOp2Type,3
                je ROR_Mem1_Val
                jmp ROR_invalid
                ROR_Mem1_Reg:
                    cmp selectedOp2Reg,7
                    jne ROR_invalid
                    mov cx,ValRegCX
                    Ror ValMem[1],cl
                    jmp Exit
                ROR_Mem1_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    mov cx,Op2Val
                    ror ValMem[1],cl
                    jmp Exit
            ROR_Mem2:
                cmp selectedOp2Type,0
                je ROR_Mem2_Reg
                cmp selectedOp2Type,3
                je ROR_Mem2_Val
                jmp ROR_invalid
                ROR_Mem2_Reg:
                    cmp selectedOp2Reg,7
                    jne ROR_invalid
                    mov cx,ValRegCX
                    Ror ValMem[2],cl
                    jmp Exit
                ROR_Mem2_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    mov cx,Op2Val
                    ror ValMem[2],cl
                    jmp Exit
            ROR_Mem3:
                cmp selectedOp2Type,0
                je ROR_Mem3_Reg
                cmp selectedOp2Type,3
                je ROR_Mem3_Val
                jmp ROR_invalid
                ROR_Mem3_Reg:
                    cmp selectedOp2Reg,7
                    jne ROR_invalid
                    mov cx,ValRegCX
                    Ror ValMem[3],cl
                    jmp Exit
                ROR_Mem3_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    mov cx,Op2Val
                    ror ValMem[3],cl
                    jmp Exit
            ROR_Mem4:
                cmp selectedOp2Type,0
                je ROR_Mem4_Reg
                cmp selectedOp2Type,3
                je ROR_Mem4_Val
                jmp ROR_invalid
                ROR_Mem4_Reg:
                    cmp selectedOp2Reg,7
                    jne ROR_invalid
                    mov cx,ValRegCX
                    Ror ValMem[4],cl
                    jmp Exit
                ROR_Mem4_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    mov cx,Op2Val
                    ror ValMem[4],cl
                    jmp Exit
            ROR_Mem5:
                cmp selectedOp2Type,0
                je ROR_Mem5_Reg
                cmp selectedOp2Type,3
                je ROR_Mem5_Val
                jmp ROR_invalid
                ROR_Mem5_Reg:
                    cmp selectedOp2Reg,7
                    jne ROR_invalid
                    mov cx,ValRegCX
                    Ror ValMem[5],cl
                    jmp Exit
                ROR_Mem5_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    mov cx,Op2Val
                    ror ValMem[5],cl
                    jmp Exit
            ROR_Mem6:
                cmp selectedOp2Type,0
                je ROR_Mem6_Reg
                cmp selectedOp2Type,3
                je ROR_Mem6_Val
                jmp ROR_invalid
                ROR_Mem6_Reg:
                    cmp selectedOp2Reg,7
                    jne ROR_invalid
                    mov cx,ValRegCX
                    Ror ValMem[6],cl
                    jmp Exit
                ROR_Mem6_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    mov cx,Op2Val
                    ror ValMem[6],cl
                    jmp Exit
            ROR_Mem7:
                cmp selectedOp2Type,0
                je ROR_Mem7_Reg
                cmp selectedOp2Type,3
                je ROR_Mem7_Val
                jmp ROR_invalid
                ROR_Mem7_Reg:
                    cmp selectedOp2Reg,7
                    jne ROR_invalid
                    mov cx,ValRegCX
                    Ror ValMem[7],cl
                    jmp Exit
                ROR_Mem7_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    mov cx,Op2Val
                    ror ValMem[7],cl
                    jmp Exit
            ROR_Mem8:
                cmp selectedOp2Type,0
                je ROR_Mem8_Reg
                cmp selectedOp2Type,3
                je ROR_Mem8_Val
                jmp ROR_invalid
                ROR_Mem8_Reg:
                    cmp selectedOp2Reg,7
                    jne ROR_invalid
                    mov cx,ValRegCX
                    Ror ValMem[8],cl
                    jmp Exit
                ROR_Mem8_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    mov cx,Op2Val
                    ror ValMem[8],cl
                    jmp Exit
            ROR_Mem9:
                cmp selectedOp2Type,0
                je ROR_Mem9_Reg
                cmp selectedOp2Type,3
                je ROR_Mem9_Val
                jmp ROR_invalid
                ROR_Mem9_Reg:
                    cmp selectedOp2Reg,7
                    jne ROR_invalid
                    mov cx,ValRegCX
                    Ror ValMem[9],cl
                    jmp Exit
                ROR_Mem9_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    mov cx,Op2Val
                    ror ValMem[9],cl
                    jmp Exit
            ROR_Mem10:
                cmp selectedOp2Type,0
                je ROR_Mem10_Reg
                cmp selectedOp2Type,3
                je ROR_Mem10_Val
                jmp ROR_invalid
                ROR_Mem10_Reg:
                    cmp selectedOp2Reg,7
                    jne ROR_invalid
                    mov cx,ValRegCX
                    Ror ValMem[10],cl
                    jmp Exit
                ROR_Mem10_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    mov cx,Op2Val
                    ror ValMem[10],cl
                    jmp Exit
            ROR_Mem11:
                cmp selectedOp2Type,0
                je ROR_Mem11_Reg
                cmp selectedOp2Type,3
                je ROR_Mem11_Val
                jmp ROR_invalid
                ROR_Mem11_Reg:
                    cmp selectedOp2Reg,7
                    jne ROR_invalid
                    mov cx,ValRegCX
                    Ror ValMem[11],cl
                    jmp Exit
                ROR_Mem11_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    mov cx,Op2Val
                    ror ValMem[11],cl
                    jmp Exit
            ROR_Mem12:
                cmp selectedOp2Type,0
                je ROR_Mem12_Reg
                cmp selectedOp2Type,3
                je ROR_Mem12_Val
                jmp ROR_invalid
                ROR_Mem12_Reg:
                    cmp selectedOp2Reg,7
                    jne ROR_invalid
                    mov cx,ValRegCX
                    Ror ValMem[12],cl
                    jmp Exit
                ROR_Mem12_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    mov cx,Op2Val
                    ror ValMem[12],cl
                    jmp Exit
            ROR_Mem13:
                cmp selectedOp2Type,0
                je ROR_Mem13_Reg
                cmp selectedOp2Type,3
                je ROR_Mem13_Val
                jmp ROR_invalid
                ROR_Mem13_Reg:
                    cmp selectedOp2Reg,7
                    jne ROR_invalid
                    mov cx,ValRegCX
                    Ror ValMem[13],cl
                    jmp Exit
                ROR_Mem13_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    mov cx,Op2Val
                    ror ValMem[13],cl
                    jmp Exit
            ROR_Mem14:
                cmp selectedOp2Type,0
                je ROR_Mem14_Reg
                cmp selectedOp2Type,3
                je ROR_Mem14_Val
                jmp ROR_invalid
                ROR_Mem14_Reg:
                    cmp selectedOp2Reg,7
                    jne ROR_invalid
                    mov cx,ValRegCX
                    Ror ValMem[14],cl
                    jmp Exit
                ROR_Mem14_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    mov cx,Op2Val
                    ror ValMem[14],cl
                    jmp Exit
            ROR_Mem15:
                cmp selectedOp2Type,0
                je ROR_Mem15_Reg
                cmp selectedOp2Type,3
                je ROR_Mem15_Val
                jmp ROR_invalid
                ROR_Mem15_Reg:
                    cmp selectedOp2Reg,7
                    jne ROR_invalid
                    mov cx,ValRegCX
                    Ror ValMem[15],cl
                    jmp Exit
                ROR_Mem15_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    mov cx,Op2Val
                    ror ValMem[15],cl
                    jmp Exit
        ROR_invalid:
        jmp InValidCommand
        JMP Exit
    
    ROL_Comm:
        CALL Op1Menu
        MOV DX, CommaCursorLoc
        CALL SetCursor
        mov dl, ','
        CALL DisplayChar
        CALL Op2Menu

        call  PowerUpeMenu ; to choose power up
        CALL CheckForbidCharProc

        cmp selectedOp1Type,0
        je ROL_Reg
        cmp selectedOp1Type,1
        je ROL_AddReg
        cmp selectedOp1Type,2
        je ROL_Mem
        cmp selectedOp1Type,3
        je ROL_invalid

        ROL_Reg:
            cmp selectedOp1Reg,0
            je ROL_Ax
            cmp selectedOp1Reg,1
            je ROL_Al
            cmp selectedOp1Reg,2
            je ROL_Ah
            cmp selectedOp1Reg,3
            je ROL_bx
            cmp selectedOp1Reg,4
            je ROL_Bl
            cmp selectedOp1Reg,5
            je ROL_Bh
            cmp selectedOp1Reg,6
            je ROL_Cx
            cmp selectedOp1Reg,7
            je ROL_Cl
            cmp selectedOp1Reg,8
            je ROL_Ch
            cmp selectedOp1Reg,9
            je ROL_Dx
            cmp selectedOp1Reg,10
            je ROL_Dl
            cmp selectedOp1Reg,11
            je ROL_Dh
            cmp selectedOp1Reg,15
            je ROL_Bp
            cmp selectedOp1Reg,16
            je ROL_Sp
            cmp selectedOp1Reg,17
            je ROL_Si
            cmp selectedOp1Reg,18
            je ROL_Di
            jmp ROL_invalid
            ROL_Ax:
                cmp selectedOp2Type,0
                je ROL_Ax_Reg
                cmp selectedOp2Type,3
                je ROL_Ax_Val
                jmp ROL_invalid
                ROL_Ax_Reg:
                    cmp selectedOp2Reg,7
                    jne ROL_invalid
                    mov ax,ValRegAX
                    mov cx,ValRegCX
                    ROL Ax,cl
                    mov ValRegAX,ax
                    jmp Exit
                ROL_Ax_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    mov ax,ValRegAX
                    mov cx,Op2Val
                    ROL ax,cl
                    mov ValRegAX,ax
                    jmp Exit
            ROL_Al:
                cmp selectedOp2Type,0
                je ROL_Al_Reg
                cmp selectedOp2Type,3
                je ROL_Al_Val
                jmp ROL_invalid
                ROL_Al_Reg:
                    cmp selectedOp2Reg,7
                    jne ROL_invalid
                    mov ax,ValRegAX
                    mov cx,ValRegCX
                    ROL Al,cl
                    mov ValRegAX,ax
                    jmp Exit
                ROL_Al_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    mov ax,ValRegAX
                    mov cx,Op2Val
                    ROL al,cl
                    mov ValRegAX,ax
                    jmp Exit
            ROL_Ah:
                cmp selectedOp2Type,0
                je ROL_Ah_Reg
                cmp selectedOp2Type,3
                je ROL_Ah_Val
                jmp ROL_invalid
                ROL_Ah_Reg:
                    cmp selectedOp2Reg,7
                    jne ROL_invalid
                    mov ax,ValRegAX
                    mov cx,ValRegCX
                    ROL Ah,cl
                    mov ValRegAX,ax
                    jmp Exit
                ROL_Ah_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    mov ax,ValRegAX
                    mov cx,Op2Val
                    ROL ah,cl
                    mov ValRegAX,ax
                    jmp Exit
            ROL_Bx:
                cmp selectedOp2Type,0
                je ROL_Bx_Reg
                cmp selectedOp2Type,3
                je ROL_Bx_Val
                jmp ROL_invalid
                ROL_Bx_Reg:
                    cmp selectedOp2Reg,7
                    jne ROL_invalid
                    mov Bx,ValRegBX
                    mov cx,ValRegCX
                    ROL Bx,cl
                    mov ValRegBX,Bx
                    jmp Exit
                ROL_Bx_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    mov Bx,ValRegBX
                    mov cx,Op2Val
                    ROL Bx,cl
                    mov ValRegBX,Bx
                    jmp Exit
            ROL_Bl:
                cmp selectedOp2Type,0
                je ROL_Bl_Reg
                cmp selectedOp2Type,3
                je ROL_Bl_Val
                jmp ROL_invalid
                ROL_Bl_Reg:
                    cmp selectedOp2Reg,7
                    jne ROL_invalid
                    mov Bx,ValRegBX
                    mov cx,ValRegCX
                    ROL Bl,cl
                    mov ValRegBX,Bx
                    jmp Exit
                ROL_Bl_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    mov Bx,ValRegBX
                    mov cx,Op2Val
                    ROL Bl,cl
                    mov ValRegBX,Bx
                    jmp Exit
            ROL_Bh:
                cmp selectedOp2Type,0
                je ROL_Bh_Reg
                cmp selectedOp2Type,3
                je ROL_Bh_Val
                jmp ROL_invalid
                ROL_Bh_Reg:
                    cmp selectedOp2Reg,7
                    jne ROL_invalid
                    mov Bx,ValRegBX
                    mov cx,ValRegCX
                    ROL Bh,cl
                    mov ValRegBX,Bx
                    jmp Exit
                ROL_Bh_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    mov Bx,ValRegBX
                    mov cx,Op2Val
                    ROL Bh,cl
                    mov ValRegBX,Bx
                    jmp Exit
            ROL_Cx:
                cmp selectedOp2Type,0
                je ROL_Cx_Reg
                cmp selectedOp2Type,3
                je ROL_Cx_Val
                jmp ROL_invalid
                ROL_Cx_Reg:
                    cmp selectedOp2Reg,7
                    jne ROL_invalid
                    mov Cx,ValRegCx
                    mov cx,ValRegCX
                    ROL Cx,cl
                    mov ValRegCx,Cx
                    jmp Exit
                ROL_Cx_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    mov bx,ValRegCx
                    mov cx,Op2Val
                    ROL bx,cl
                    mov ValRegCx,bx
                    jmp Exit
            ROL_Cl:
                cmp selectedOp2Type,0
                je ROL_Cl_Reg
                cmp selectedOp2Type,3
                je ROL_Cl_Val
                jmp ROL_invalid
                ROL_Cl_Reg:
                    cmp selectedOp2Reg,7
                    jne ROL_invalid
                    mov cx,ValRegCX
                    ROL Cl,cl
                    mov ValRegCX,Cx
                    jmp Exit
                ROL_Cl_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    mov Bx,ValRegCX
                    mov cx,Op2Val
                    ROL Bl,cl
                    mov ValRegCX,Bx
                    jmp Exit
            ROL_Ch:
                cmp selectedOp2Type,0
                je ROL_Ch_Reg
                cmp selectedOp2Type,3
                je ROL_Ch_Val
                jmp ROL_invalid
                ROL_Ch_Reg:
                    cmp selectedOp2Reg,7
                    jne ROL_invalid
                    mov cx,ValRegCX
                    ROL Ch,cl
                    mov ValRegCX,Cx
                    jmp Exit
                ROL_Ch_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    mov Bx,ValRegCX
                    mov cx,Op2Val
                    ROL bh,cl
                    mov ValRegCX,Bx
                    jmp Exit
            ROL_Dx:
                cmp selectedOp2Type,0
                je ROL_Dx_Reg
                cmp selectedOp2Type,3
                je ROL_Dx_Val
                jmp ROL_invalid
                ROL_Dx_Reg:
                    cmp selectedOp2Reg,7
                    jne ROL_invalid
                    mov Dx,ValRegDX
                    mov cx,ValRegCX
                    ROL Dx,cl
                    mov ValRegDX,Dx
                    jmp Exit
                ROL_Dx_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    mov Dx,ValRegDX
                    mov cx,Op2Val
                    ROL Dx,cl
                    mov ValRegDX,Dx
                    jmp Exit
            ROL_Dl:
                cmp selectedOp2Type,0
                je ROL_Dl_Reg
                cmp selectedOp2Type,3
                je ROL_Dl_Val
                jmp ROL_invalid
                ROL_Dl_Reg:
                    cmp selectedOp2Reg,7
                    jne ROL_invalid
                    mov Dx,ValRegDX
                    mov cx,ValRegCX
                    ROL Dl,cl
                    mov ValRegDX,Dx
                    jmp Exit
                ROL_Dl_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    mov Dx,ValRegDX
                    mov cx,Op2Val
                    ROL Dl,cl
                    mov ValRegDX,Dx
                    jmp Exit
            ROL_Dh:
                cmp selectedOp2Type,0
                je ROL_Dh_Reg
                cmp selectedOp2Type,3
                je ROL_Dh_Val
                jmp ROL_invalid
                ROL_Dh_Reg:
                    cmp selectedOp2Reg,7
                    jne ROL_invalid
                    mov Dx,ValRegDX
                    mov cx,ValRegCX
                    ROL Dh,cl
                    mov ValRegDX,Dx
                    jmp Exit
                ROL_Dh_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    mov Dx,ValRegDX
                    mov cx,Op2Val
                    ROL Dh,cl
                    mov ValRegDX,Dx
                    jmp Exit
            ROL_Bp:
                cmp selectedOp2Type,0
                je ROL_Bp_Reg
                cmp selectedOp2Type,3
                je ROL_Bp_Val
                jmp ROL_invalid
                ROL_Bp_Reg:
                    cmp selectedOp2Reg,7
                    jne ROL_invalid
                    mov Bp,ValRegBP
                    mov cx,ValRegCX
                    ROL BP,cl
                    mov ValRegBP,BP
                    jmp Exit
                ROL_BP_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    mov BP,ValRegBP
                    mov cx,Op2Val
                    ROL BP,cl
                    mov ValRegBP,BP
                    jmp Exit
            ROL_Sp:
                cmp selectedOp2Type,0
                je ROL_SP_Reg
                cmp selectedOp2Type,3
                je ROL_SP_Val
                jmp ROL_invalid
                ROL_SP_Reg:
                    cmp selectedOp2Reg,7
                    jne ROL_invalid
                    mov SP,ValRegSP
                    mov cx,ValRegCX
                    ROL SP,cl
                    mov ValRegSP,SP
                    jmp Exit
                ROL_SP_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    mov SP,ValRegSP
                    mov cx,Op2Val
                    ROL SP,cl
                    mov ValRegSP,SP
                    jmp Exit
            ROL_Si:
                cmp selectedOp2Type,0
                je ROL_SI_Reg
                cmp selectedOp2Type,3
                je ROL_SI_Val
                jmp ROL_invalid
                ROL_SI_Reg:
                    cmp selectedOp2Reg,7
                    jne ROL_invalid
                    mov SI,ValRegSI
                    mov cx,ValRegCX
                    ROL SI,cl
                    mov ValRegSI,SI
                    jmp Exit
                ROL_SI_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    mov SI,ValRegSI
                    mov cx,Op2Val
                    ROL SI,cl
                    mov ValRegSI,SI
                    jmp Exit
            ROL_Di:
                cmp selectedOp2Type,0
                je ROL_DI_Reg
                cmp selectedOp2Type,3
                je ROL_DI_Val
                jmp ROL_invalid
                ROL_DI_Reg:
                    cmp selectedOp2Reg,7
                    jne ROL_invalid
                    mov DI,ValRegDI
                    mov cx,ValRegCX
                    ROL DI,cl
                    mov ValRegDI,DI
                    jmp Exit
                ROL_DI_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    mov DI,ValRegDI
                    mov cx,Op2Val
                    ROL DI,cl
                    mov ValRegDI,DI
                    jmp Exit
        ROL_AddReg:
            cmp selectedOp1AddReg,3
            je ROL_AddBx
            cmp selectedOp1AddReg,15
            je ROL_AddBp
            cmp selectedOp1AddReg,17
            je ROL_AddSi
            cmp selectedOp1AddReg,18
            je ROL_AddDi
            jmp ROL_invalid
            ROL_AddBx:
                cmp selectedOp2Type,0
                je ROL_AddBx_Reg
                cmp selectedOp2Type,3
                je ROL_AddBx_Val
                jmp ROL_invalid
                ROL_AddBx_Reg:
                    cmp selectedOp2Reg,7
                    jne ROL_invalid
                    mov Bx,ValRegBX
                    cmp Bx,15d
                    ja ROL_invalid
                    mov cx,ValRegCX
                    ROL ValMem[Bx],cl
                    mov ValRegBX,Bx
                    jmp Exit
                ROL_AddBx_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    mov Bx,ValRegBX
                    cmp Bx,15d
                    ja ROL_invalid
                    mov cx,Op2Val
                    ROL ValMem[Bx],cl
                    mov ValRegBX,Bx
                    jmp Exit
            ROL_AddBp:
                cmp selectedOp2Type,0
                je ROL_AddBP_Reg
                cmp selectedOp2Type,3
                je ROL_AddBP_Val
                jmp ROL_invalid
                ROL_AddBP_Reg:
                    cmp selectedOp2Reg,7
                    jne ROL_invalid
                    mov BP,ValRegBP
                    cmp BP,15d
                    ja ROL_invalid
                    mov cx,ValRegCX
                    ROL ValMem[BP],cl
                    mov ValRegBP,BP
                    jmp Exit
                ROL_AddBP_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    mov BP,ValRegBP
                    cmp BP,15d
                    ja ROL_invalid
                    mov cx,Op2Val
                    ROL ValMem[BP],cl
                    mov ValRegBP,BP
                    jmp Exit
            ROL_AddSi:
                cmp selectedOp2Type,0
                je ROL_AddSi_Reg
                cmp selectedOp2Type,3
                je ROL_AddSi_Val
                jmp ROL_invalid
                ROL_AddSi_Reg:
                    cmp selectedOp2Reg,7
                    jne ROL_invalid
                    mov Si,ValRegSI
                    cmp Si,15d
                    ja ROL_invalid
                    mov cx,ValRegCX
                    ROL ValMem[Si],cl
                    mov ValRegSI,Si
                    jmp Exit
                ROL_AddSi_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    mov Si,ValRegSI
                    cmp Si,15d
                    ja ROL_invalid
                    mov cx,Op2Val
                    ROL ValMem[Si],cl
                    mov ValRegSI,Si
                    jmp Exit
            ROL_AddDi:
                cmp selectedOp2Type,0
                je ROL_AddDI_Reg
                cmp selectedOp2Type,3
                je ROL_AddDI_Val
                jmp ROL_invalid
                ROL_AddDI_Reg:
                    cmp selectedOp2Reg,7
                    jne ROL_invalid
                    mov DI,ValRegDI
                    cmp DI,15d
                    ja ROL_invalid
                    mov cx,ValRegCX
                    ROL ValMem[DI],cl
                    mov ValRegDI,DI
                    jmp Exit
                ROL_AddDI_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    mov DI,ValRegDI
                    cmp DI,15d
                    ja ROL_invalid
                    mov cx,Op2Val
                    ROL ValMem[DI],cl
                    mov ValRegDI,DI
                    jmp Exit
        ROL_Mem:
            cmp selectedOp1Mem,0
            je ROL_Mem0
            cmp selectedOp1Mem,1
            je ROL_Mem1
            cmp selectedOp1Mem,2
            je ROL_Mem2
            cmp selectedOp1Mem,3
            je ROL_Mem3
            cmp selectedOp1Mem,4
            je ROL_Mem4
            cmp selectedOp1Mem,5
            je ROL_Mem5
            cmp selectedOp1Mem,6
            je ROL_Mem6
            cmp selectedOp1Mem,7
            je ROL_Mem7
            cmp selectedOp1Mem,8
            je ROL_Mem8
            cmp selectedOp1Mem,9
            je ROL_Mem9
            cmp selectedOp1Mem,10
            je ROL_Mem10
            cmp selectedOp1Mem,11
            je ROL_Mem11
            cmp selectedOp1Mem,12
            je ROL_Mem12
            cmp selectedOp1Mem,13
            je ROL_Mem13
            cmp selectedOp1Mem,14
            je ROL_Mem14
            cmp selectedOp1Mem,15
            je ROL_Mem15
            jmp ROL_invalid
            ROL_Mem0:
                cmp selectedOp2Type,0
                je ROL_Mem0_Reg
                cmp selectedOp2Type,3
                je ROL_Mem0_Val
                jmp ROL_invalid
                ROL_Mem0_Reg:
                    cmp selectedOp2Reg,7
                    jne ROL_invalid
                    mov cx,ValRegCX
                    ROL ValMem[0],cl
                    jmp Exit
                ROL_Mem0_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    mov cx,Op2Val
                    ROL ValMem[0],cl
                    jmp Exit
            ROL_Mem1:
                cmp selectedOp2Type,0
                je ROL_Mem1_Reg
                cmp selectedOp2Type,3
                je ROL_Mem1_Val
                jmp ROL_invalid
                ROL_Mem1_Reg:
                    cmp selectedOp2Reg,7
                    jne ROL_invalid
                    mov cx,ValRegCX
                    ROL ValMem[1],cl
                    jmp Exit
                ROL_Mem1_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    mov cx,Op2Val
                    ROL ValMem[1],cl
                    jmp Exit
            ROL_Mem2:
                cmp selectedOp2Type,0
                je ROL_Mem2_Reg
                cmp selectedOp2Type,3
                je ROL_Mem2_Val
                jmp ROL_invalid
                ROL_Mem2_Reg:
                    cmp selectedOp2Reg,7
                    jne ROL_invalid
                    mov cx,ValRegCX
                    ROL ValMem[2],cl
                    jmp Exit
                ROL_Mem2_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    mov cx,Op2Val
                    ROL ValMem[2],cl
                    jmp Exit
            ROL_Mem3:
                cmp selectedOp2Type,0
                je ROL_Mem3_Reg
                cmp selectedOp2Type,3
                je ROL_Mem3_Val
                jmp ROL_invalid
                ROL_Mem3_Reg:
                    cmp selectedOp2Reg,7
                    jne ROL_invalid
                    mov cx,ValRegCX
                    ROL ValMem[3],cl
                    jmp Exit
                ROL_Mem3_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    mov cx,Op2Val
                    ROL ValMem[3],cl
                    jmp Exit
            ROL_Mem4:
                cmp selectedOp2Type,0
                je ROL_Mem4_Reg
                cmp selectedOp2Type,3
                je ROL_Mem4_Val
                jmp ROL_invalid
                ROL_Mem4_Reg:
                    cmp selectedOp2Reg,7
                    jne ROL_invalid
                    mov cx,ValRegCX
                    ROL ValMem[4],cl
                    jmp Exit
                ROL_Mem4_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    mov cx,Op2Val
                    ROL ValMem[4],cl
                    jmp Exit
            ROL_Mem5:
                cmp selectedOp2Type,0
                je ROL_Mem5_Reg
                cmp selectedOp2Type,3
                je ROL_Mem5_Val
                jmp ROL_invalid
                ROL_Mem5_Reg:
                    cmp selectedOp2Reg,7
                    jne ROL_invalid
                    mov cx,ValRegCX
                    ROL ValMem[5],cl
                    jmp Exit
                ROL_Mem5_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    mov cx,Op2Val
                    ROL ValMem[5],cl
                    jmp Exit
            ROL_Mem6:
                cmp selectedOp2Type,0
                je ROL_Mem6_Reg
                cmp selectedOp2Type,3
                je ROL_Mem6_Val
                jmp ROL_invalid
                ROL_Mem6_Reg:
                    cmp selectedOp2Reg,7
                    jne ROL_invalid
                    mov cx,ValRegCX
                    ROL ValMem[6],cl
                    jmp Exit
                ROL_Mem6_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    mov cx,Op2Val
                    ROL ValMem[6],cl
                    jmp Exit
            ROL_Mem7:
                cmp selectedOp2Type,0
                je ROL_Mem7_Reg
                cmp selectedOp2Type,3
                je ROL_Mem7_Val
                jmp ROL_invalid
                ROL_Mem7_Reg:
                    cmp selectedOp2Reg,7
                    jne ROL_invalid
                    mov cx,ValRegCX
                    ROL ValMem[7],cl
                    jmp Exit
                ROL_Mem7_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    mov cx,Op2Val
                    ROL ValMem[7],cl
                    jmp Exit
            ROL_Mem8:
                cmp selectedOp2Type,0
                je ROL_Mem8_Reg
                cmp selectedOp2Type,3
                je ROL_Mem8_Val
                jmp ROL_invalid
                ROL_Mem8_Reg:
                    cmp selectedOp2Reg,7
                    jne ROL_invalid
                    mov cx,ValRegCX
                    ROL ValMem[8],cl
                    jmp Exit
                ROL_Mem8_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    mov cx,Op2Val
                    ROL ValMem[8],cl
                    jmp Exit
            ROL_Mem9:
                cmp selectedOp2Type,0
                je ROL_Mem9_Reg
                cmp selectedOp2Type,3
                je ROL_Mem9_Val
                jmp ROL_invalid
                ROL_Mem9_Reg:
                    cmp selectedOp2Reg,7
                    jne ROL_invalid
                    mov cx,ValRegCX
                    ROL ValMem[9],cl
                    jmp Exit
                ROL_Mem9_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    mov cx,Op2Val
                    ROL ValMem[9],cl
                    jmp Exit
            ROL_Mem10:
                cmp selectedOp2Type,0
                je ROL_Mem10_Reg
                cmp selectedOp2Type,3
                je ROL_Mem10_Val
                jmp ROL_invalid
                ROL_Mem10_Reg:
                    cmp selectedOp2Reg,7
                    jne ROL_invalid
                    mov cx,ValRegCX
                    ROL ValMem[10],cl
                    jmp Exit
                ROL_Mem10_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    mov cx,Op2Val
                    ROL ValMem[10],cl
                    jmp Exit
            ROL_Mem11:
                cmp selectedOp2Type,0
                je ROL_Mem11_Reg
                cmp selectedOp2Type,3
                je ROL_Mem11_Val
                jmp ROL_invalid
                ROL_Mem11_Reg:
                    cmp selectedOp2Reg,7
                    jne ROL_invalid
                    mov cx,ValRegCX
                    ROL ValMem[11],cl
                    jmp Exit
                ROL_Mem11_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    mov cx,Op2Val
                    ROL ValMem[11],cl
                    jmp Exit
            ROL_Mem12:
                cmp selectedOp2Type,0
                je ROL_Mem12_Reg
                cmp selectedOp2Type,3
                je ROL_Mem12_Val
                jmp ROL_invalid
                ROL_Mem12_Reg:
                    cmp selectedOp2Reg,7
                    jne ROL_invalid
                    mov cx,ValRegCX
                    ROL ValMem[12],cl
                    jmp Exit
                ROL_Mem12_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    mov cx,Op2Val
                    ROL ValMem[12],cl
                    jmp Exit
            ROL_Mem13:
                cmp selectedOp2Type,0
                je ROL_Mem13_Reg
                cmp selectedOp2Type,3
                je ROL_Mem13_Val
                jmp ROL_invalid
                ROL_Mem13_Reg:
                    cmp selectedOp2Reg,7
                    jne ROL_invalid
                    mov cx,ValRegCX
                    ROL ValMem[13],cl
                    jmp Exit
                ROL_Mem13_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    mov cx,Op2Val
                    ROL ValMem[13],cl
                    jmp Exit
            ROL_Mem14:
                cmp selectedOp2Type,0
                je ROL_Mem14_Reg
                cmp selectedOp2Type,3
                je ROL_Mem14_Val
                jmp ROL_invalid
                ROL_Mem14_Reg:
                    cmp selectedOp2Reg,7
                    jne ROL_invalid
                    mov cx,ValRegCX
                    ROL ValMem[14],cl
                    jmp Exit
                ROL_Mem14_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    mov cx,Op2Val
                    ROL ValMem[14],cl
                    jmp Exit
            ROL_Mem15:
                cmp selectedOp2Type,0
                je ROL_Mem15_Reg
                cmp selectedOp2Type,3
                je ROL_Mem15_Val
                jmp ROL_invalid
                ROL_Mem15_Reg:
                    cmp selectedOp2Reg,7
                    jne ROL_invalid
                    mov cx,ValRegCX
                    ROL ValMem[15],cl
                    jmp Exit
                ROL_Mem15_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    mov cx,Op2Val
                    ROL ValMem[15],cl
                    jmp Exit
        ROL_invalid:
        jmp InValidCommand
        JMP Exit
    
    RCR_Comm:
        CALL Op1Menu
        MOV DX, CommaCursorLoc
        CALL SetCursor
        mov dl, ','
        CALL DisplayChar
        CALL Op2Menu

        call  PowerUpeMenu ; to choose power up
        CALL CheckForbidCharProc

        cmp selectedOp1Type,0
        je RCR_Reg
        cmp selectedOp1Type,1
        je RCR_AddReg
        cmp selectedOp1Type,2
        je RCR_Mem
        cmp selectedOp1Type,3
        je RCR_invalid

        RCR_Reg:
            cmp selectedOp1Reg,0
            je RCR_Ax
            cmp selectedOp1Reg,1
            je RCR_Al
            cmp selectedOp1Reg,2
            je RCR_Ah
            cmp selectedOp1Reg,3
            je RCR_bx
            cmp selectedOp1Reg,4
            je RCR_Bl
            cmp selectedOp1Reg,5
            je RCR_Bh
            cmp selectedOp1Reg,6
            je RCR_Cx
            cmp selectedOp1Reg,7
            je RCR_Cl
            cmp selectedOp1Reg,8
            je RCR_Ch
            cmp selectedOp1Reg,9
            je RCR_Dx
            cmp selectedOp1Reg,10
            je RCR_Dl
            cmp selectedOp1Reg,11
            je RCR_Dh
            cmp selectedOp1Reg,15
            je RCR_Bp
            cmp selectedOp1Reg,16
            je RCR_Sp
            cmp selectedOp1Reg,17
            je RCR_Si
            cmp selectedOp1Reg,18
            je RCR_Di
            jmp RCR_invalid
            RCR_Ax:
                cmp selectedOp2Type,0
                je RCR_Ax_Reg
                cmp selectedOp2Type,3
                je RCR_Ax_Val
                jmp RCR_invalid
                RCR_Ax_Reg:
                    cmp selectedOp2Reg,7
                    jne RCR_invalid
                    mov ax,ValRegAX
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR Ax,cl
                    mov ValRegAX,ax
                    call SetCarryFlag
                    jmp Exit
                RCR_Ax_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    mov ax,ValRegAX
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCR ax,cl
                    mov ValRegAX,ax
                    call SetCarryFlag
                    jmp Exit
            RCR_Al:
                cmp selectedOp2Type,0
                je RCR_Al_Reg
                cmp selectedOp2Type,3
                je RCR_Al_Val
                jmp RCR_invalid
                RCR_Al_Reg:
                    cmp selectedOp2Reg,7
                    jne RCR_invalid
                    mov ax,ValRegAX
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR Al,cl
                    mov ValRegAX,ax
                    call SetCarryFlag
                    jmp Exit
                RCR_Al_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    mov ax,ValRegAX
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCR al,cl
                    mov ValRegAX,ax
                    call SetCarryFlag
                    jmp Exit
            RCR_Ah:
                cmp selectedOp2Type,0
                je RCR_Ah_Reg
                cmp selectedOp2Type,3
                je RCR_Ah_Val
                jmp RCR_invalid
                RCR_Ah_Reg:
                    cmp selectedOp2Reg,7
                    jne RCR_invalid
                    mov ax,ValRegAX
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR Ah,cl
                    mov ValRegAX,ax
                    call SetCarryFlag
                    jmp Exit
                RCR_Ah_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    mov ax,ValRegAX
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCR ah,cl
                    mov ValRegAX,ax
                    call SetCarryFlag
                    jmp Exit
            RCR_Bx:
                cmp selectedOp2Type,0
                je RCR_Bx_Reg
                cmp selectedOp2Type,3
                je RCR_Bx_Val
                jmp RCR_invalid
                RCR_Bx_Reg:
                    cmp selectedOp2Reg,7
                    jne RCR_invalid
                    mov Bx,ValRegBX
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR Bx,cl
                    mov ValRegBX,Bx
                    call SetCarryFlag
                    jmp Exit
                RCR_Bx_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    mov Bx,ValRegBX
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCR Bx,cl
                    mov ValRegBX,Bx
                    call SetCarryFlag
                    jmp Exit
            RCR_Bl:
                cmp selectedOp2Type,0
                je RCR_Bl_Reg
                cmp selectedOp2Type,3
                je RCR_Bl_Val
                jmp RCR_invalid
                RCR_Bl_Reg:
                    cmp selectedOp2Reg,7
                    jne RCR_invalid
                    mov Bx,ValRegBX
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR Bl,cl
                    mov ValRegBX,Bx
                    call SetCarryFlag
                    jmp Exit
                RCR_Bl_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    mov Bx,ValRegBX
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCR Bl,cl
                    mov ValRegBX,Bx
                    call SetCarryFlag
                    jmp Exit
            RCR_Bh:
                cmp selectedOp2Type,0
                je RCR_Bh_Reg
                cmp selectedOp2Type,3
                je RCR_Bh_Val
                jmp RCR_invalid
                RCR_Bh_Reg:
                    cmp selectedOp2Reg,7
                    jne RCR_invalid
                    mov Bx,ValRegBX
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR Bh,cl
                    mov ValRegBX,Bx
                    call SetCarryFlag
                    jmp Exit
                RCR_Bh_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    mov Bx,ValRegBX
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCR Bh,cl
                    mov ValRegBX,Bx
                    call SetCarryFlag
                    jmp Exit
            RCR_Cx:
                cmp selectedOp2Type,0
                je RCR_Cx_Reg
                cmp selectedOp2Type,3
                je RCR_Cx_Val
                jmp RCR_invalid
                RCR_Cx_Reg:
                    cmp selectedOp2Reg,7
                    jne RCR_invalid
                    mov Cx,ValRegCx
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR Cx,cl
                    mov ValRegCx,Cx
                    call SetCarryFlag
                    jmp Exit
                RCR_Cx_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    mov bx,ValRegCx
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCR bx,cl
                    mov ValRegCx,bx
                    call SetCarryFlag
                    jmp Exit
            RCR_Cl:
                cmp selectedOp2Type,0
                je RCR_Cl_Reg
                cmp selectedOp2Type,3
                je RCR_Cl_Val
                jmp RCR_invalid
                RCR_Cl_Reg:
                    cmp selectedOp2Reg,7
                    jne RCR_invalid
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR Cl,cl
                    mov ValRegCX,Cx
                    call SetCarryFlag
                    jmp Exit
                RCR_Cl_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    mov Bx,ValRegCX
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCR Bl,cl
                    mov ValRegCX,Bx
                    call SetCarryFlag
                    jmp Exit
            RCR_Ch:
                cmp selectedOp2Type,0
                je RCR_Ch_Reg
                cmp selectedOp2Type,3
                je RCR_Ch_Val
                jmp RCR_invalid
                RCR_Ch_Reg:
                    cmp selectedOp2Reg,7
                    jne RCR_invalid
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR Ch,cl
                    mov ValRegCX,Cx
                    call SetCarryFlag
                    jmp Exit
                RCR_Ch_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    mov Bx,ValRegCX
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCR bh,cl
                    mov ValRegCX,Bx
                    call SetCarryFlag
                    jmp Exit
            RCR_Dx:
                cmp selectedOp2Type,0
                je RCR_Dx_Reg
                cmp selectedOp2Type,3
                je RCR_Dx_Val
                jmp RCR_invalid
                RCR_Dx_Reg:
                    cmp selectedOp2Reg,7
                    jne RCR_invalid
                    mov Dx,ValRegDX
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR Dx,cl
                    mov ValRegDX,Dx
                    call SetCarryFlag
                    jmp Exit
                RCR_Dx_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    mov Dx,ValRegDX
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCR Dx,cl
                    mov ValRegDX,Dx
                    call SetCarryFlag
                    jmp Exit
            RCR_Dl:
                cmp selectedOp2Type,0
                je RCR_Dl_Reg
                cmp selectedOp2Type,3
                je RCR_Dl_Val
                jmp RCR_invalid
                RCR_Dl_Reg:
                    cmp selectedOp2Reg,7
                    jne RCR_invalid
                    mov Dx,ValRegDX
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR Dl,cl
                    mov ValRegDX,Dx
                    call SetCarryFlag
                    jmp Exit
                RCR_Dl_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    mov Dx,ValRegDX
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCR Dl,cl
                    mov ValRegDX,Dx
                    call SetCarryFlag
                    jmp Exit
            RCR_Dh:
                cmp selectedOp2Type,0
                je RCR_Dh_Reg
                cmp selectedOp2Type,3
                je RCR_Dh_Val
                jmp RCR_invalid
                RCR_Dh_Reg:
                    cmp selectedOp2Reg,7
                    jne RCR_invalid
                    mov Dx,ValRegDX
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR Dh,cl
                    mov ValRegDX,Dx
                    call SetCarryFlag
                    jmp Exit
                RCR_Dh_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    mov Dx,ValRegDX
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCR Dh,cl
                    mov ValRegDX,Dx
                    call SetCarryFlag
                    jmp Exit
            RCR_Bp:
                cmp selectedOp2Type,0
                je RCR_Bp_Reg
                cmp selectedOp2Type,3
                je RCR_Bp_Val
                jmp RCR_invalid
                RCR_Bp_Reg:
                    cmp selectedOp2Reg,7
                    jne RCR_invalid
                    mov Bp,ValRegBP
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR BP,cl
                    mov ValRegBP,BP
                    call SetCarryFlag
                    jmp Exit
                RCR_BP_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    mov BP,ValRegBP
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCR BP,cl
                    mov ValRegBP,BP
                    call SetCarryFlag
                    jmp Exit
            RCR_Sp:
                cmp selectedOp2Type,0
                je RCR_SP_Reg
                cmp selectedOp2Type,3
                je RCR_SP_Val
                jmp RCR_invalid
                RCR_SP_Reg:
                    cmp selectedOp2Reg,7
                    jne RCR_invalid
                    mov SP,ValRegSP
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR SP,cl
                    mov ValRegSP,SP
                    call SetCarryFlag
                    jmp Exit
                RCR_SP_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    mov SP,ValRegSP
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCR SP,cl
                    mov ValRegSP,SP
                    call SetCarryFlag
                    jmp Exit
            RCR_Si:
                cmp selectedOp2Type,0
                je RCR_SI_Reg
                cmp selectedOp2Type,3
                je RCR_SI_Val
                jmp RCR_invalid
                RCR_SI_Reg:
                    cmp selectedOp2Reg,7
                    jne RCR_invalid
                    mov SI,ValRegSI
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR SI,cl
                    mov ValRegSI,SI
                    call SetCarryFlag
                    jmp Exit
                RCR_SI_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    mov SI,ValRegSI
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCR SI,cl
                    mov ValRegSI,SI
                    call SetCarryFlag
                    jmp Exit
            RCR_Di:
                cmp selectedOp2Type,0
                je RCR_DI_Reg
                cmp selectedOp2Type,3
                je RCR_DI_Val
                jmp RCR_invalid
                RCR_DI_Reg:
                    cmp selectedOp2Reg,7
                    jne RCR_invalid
                    mov DI,ValRegDI
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR DI,cl
                    mov ValRegDI,DI
                    call SetCarryFlag
                    jmp Exit
                RCR_DI_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    mov DI,ValRegDI
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCR DI,cl
                    mov ValRegDI,DI
                    call SetCarryFlag
                    jmp Exit
        RCR_AddReg:
            cmp selectedOp1AddReg,3
            je RCR_AddBx
            cmp selectedOp1AddReg,15
            je RCR_AddBp
            cmp selectedOp1AddReg,17
            je RCR_AddSi
            cmp selectedOp1AddReg,18
            je RCR_AddDi
            jmp RCR_invalid
            RCR_AddBx:
                cmp selectedOp2Type,0
                je RCR_AddBx_Reg
                cmp selectedOp2Type,3
                je RCR_AddBx_Val
                jmp RCR_invalid
                RCR_AddBx_Reg:
                    cmp selectedOp2Reg,7
                    jne RCR_invalid
                    mov Bx,ValRegBX
                    cmp Bx,15d
                    ja RCR_invalid
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR ValMem[Bx],cl
                    mov ValRegBX,Bx
                    call SetCarryFlag
                    jmp Exit
                RCR_AddBx_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    mov Bx,ValRegBX
                    cmp Bx,15d
                    ja RCR_invalid
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCR ValMem[Bx],cl
                    mov ValRegBX,Bx
                    call SetCarryFlag
                    jmp Exit
            RCR_AddBp:
                cmp selectedOp2Type,0
                je RCR_AddBP_Reg
                cmp selectedOp2Type,3
                je RCR_AddBP_Val
                jmp RCR_invalid
                RCR_AddBP_Reg:
                    cmp selectedOp2Reg,7
                    jne RCR_invalid
                    mov BP,ValRegBP
                    cmp BP,15d
                    ja RCR_invalid
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR ValMem[BP],cl
                    mov ValRegBP,BP
                    call SetCarryFlag
                    jmp Exit
                RCR_AddBP_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    mov BP,ValRegBP
                    cmp BP,15d
                    ja RCR_invalid
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCR ValMem[BP],cl
                    mov ValRegBP,BP
                    call SetCarryFlag
                    jmp Exit
            RCR_AddSi:
                cmp selectedOp2Type,0
                je RCR_AddSi_Reg
                cmp selectedOp2Type,3
                je RCR_AddSi_Val
                jmp RCR_invalid
                RCR_AddSi_Reg:
                    cmp selectedOp2Reg,7
                    jne RCR_invalid
                    mov Si,ValRegSI
                    cmp Si,15d
                    ja RCR_invalid
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR ValMem[Si],cl
                    mov ValRegSI,Si
                    call SetCarryFlag
                    jmp Exit
                RCR_AddSi_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    mov Si,ValRegSI
                    cmp Si,15d
                    ja RCR_invalid
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCR ValMem[Si],cl
                    mov ValRegSI,Si
                    call SetCarryFlag
                    jmp Exit
            RCR_AddDi:
                cmp selectedOp2Type,0
                je RCR_AddDI_Reg
                cmp selectedOp2Type,3
                je RCR_AddDI_Val
                jmp RCR_invalid
                RCR_AddDI_Reg:
                    cmp selectedOp2Reg,7
                    jne RCR_invalid
                    mov DI,ValRegDI
                    cmp DI,15d
                    ja RCR_invalid
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR ValMem[DI],cl
                    mov ValRegDI,DI
                    call SetCarryFlag
                    jmp Exit
                RCR_AddDI_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    mov DI,ValRegDI
                    cmp DI,15d
                    ja RCR_invalid
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCR ValMem[DI],cl
                    mov ValRegDI,DI
                    call SetCarryFlag
                    jmp Exit
        RCR_Mem:
            cmp selectedOp1Mem,0
            je RCR_Mem0
            cmp selectedOp1Mem,1
            je RCR_Mem1
            cmp selectedOp1Mem,2
            je RCR_Mem2
            cmp selectedOp1Mem,3
            je RCR_Mem3
            cmp selectedOp1Mem,4
            je RCR_Mem4
            cmp selectedOp1Mem,5
            je RCR_Mem5
            cmp selectedOp1Mem,6
            je RCR_Mem6
            cmp selectedOp1Mem,7
            je RCR_Mem7
            cmp selectedOp1Mem,8
            je RCR_Mem8
            cmp selectedOp1Mem,9
            je RCR_Mem9
            cmp selectedOp1Mem,10
            je RCR_Mem10
            cmp selectedOp1Mem,11
            je RCR_Mem11
            cmp selectedOp1Mem,12
            je RCR_Mem12
            cmp selectedOp1Mem,13
            je RCR_Mem13
            cmp selectedOp1Mem,14
            je RCR_Mem14
            cmp selectedOp1Mem,15
            je RCR_Mem15
            jmp RCR_invalid
            RCR_Mem0:
                cmp selectedOp2Type,0
                je RCR_Mem0_Reg
                cmp selectedOp2Type,3
                je RCR_Mem0_Val
                jmp RCR_invalid
                RCR_Mem0_Reg:
                    cmp selectedOp2Reg,7
                    jne RCR_invalid
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR ValMem[0],cl
                    call SetCarryFlag
                    jmp Exit
                RCR_Mem0_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCR ValMem[0],cl
                    call SetCarryFlag
                    jmp Exit
            RCR_Mem1:
                cmp selectedOp2Type,0
                je RCR_Mem1_Reg
                cmp selectedOp2Type,3
                je RCR_Mem1_Val
                jmp RCR_invalid
                RCR_Mem1_Reg:
                    cmp selectedOp2Reg,7
                    jne RCR_invalid
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR ValMem[1],cl
                    call SetCarryFlag
                    jmp Exit
                RCR_Mem1_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCR ValMem[1],cl
                    call SetCarryFlag
                    jmp Exit
            RCR_Mem2:
                cmp selectedOp2Type,0
                je RCR_Mem2_Reg
                cmp selectedOp2Type,3
                je RCR_Mem2_Val
                jmp RCR_invalid
                RCR_Mem2_Reg:
                    cmp selectedOp2Reg,7
                    jne RCR_invalid
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR ValMem[2],cl
                    call SetCarryFlag
                    jmp Exit
                RCR_Mem2_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCR ValMem[2],cl
                    call SetCarryFlag
                    jmp Exit
            RCR_Mem3:
                cmp selectedOp2Type,0
                je RCR_Mem3_Reg
                cmp selectedOp2Type,3
                je RCR_Mem3_Val
                jmp RCR_invalid
                RCR_Mem3_Reg:
                    cmp selectedOp2Reg,7
                    jne RCR_invalid
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR ValMem[3],cl
                    call SetCarryFlag
                    jmp Exit
                RCR_Mem3_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCR ValMem[3],cl
                    call SetCarryFlag
                    jmp Exit
            RCR_Mem4:
                cmp selectedOp2Type,0
                je RCR_Mem4_Reg
                cmp selectedOp2Type,3
                je RCR_Mem4_Val
                jmp RCR_invalid
                RCR_Mem4_Reg:
                    cmp selectedOp2Reg,7
                    jne RCR_invalid
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR ValMem[4],cl
                    call SetCarryFlag
                    jmp Exit
                RCR_Mem4_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCR ValMem[4],cl
                    call SetCarryFlag
                    jmp Exit
            RCR_Mem5:
                cmp selectedOp2Type,0
                je RCR_Mem5_Reg
                cmp selectedOp2Type,3
                je RCR_Mem5_Val
                jmp RCR_invalid
                RCR_Mem5_Reg:
                    cmp selectedOp2Reg,7
                    jne RCR_invalid
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR ValMem[5],cl
                    call SetCarryFlag
                    jmp Exit
                RCR_Mem5_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCR ValMem[5],cl
                    call SetCarryFlag
                    jmp Exit
            RCR_Mem6:
                cmp selectedOp2Type,0
                je RCR_Mem6_Reg
                cmp selectedOp2Type,3
                je RCR_Mem6_Val
                jmp RCR_invalid
                RCR_Mem6_Reg:
                    cmp selectedOp2Reg,7
                    jne RCR_invalid
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR ValMem[6],cl
                    call SetCarryFlag
                    jmp Exit
                RCR_Mem6_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCR ValMem[6],cl
                    call SetCarryFlag
                    jmp Exit
            RCR_Mem7:
                cmp selectedOp2Type,0
                je RCR_Mem7_Reg
                cmp selectedOp2Type,3
                je RCR_Mem7_Val
                jmp RCR_invalid
                RCR_Mem7_Reg:
                    cmp selectedOp2Reg,7
                    jne RCR_invalid
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR ValMem[7],cl
                    call SetCarryFlag
                    jmp Exit
                RCR_Mem7_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCR ValMem[7],cl
                    call SetCarryFlag
                    jmp Exit
            RCR_Mem8:
                cmp selectedOp2Type,0
                je RCR_Mem8_Reg
                cmp selectedOp2Type,3
                je RCR_Mem8_Val
                jmp RCR_invalid
                RCR_Mem8_Reg:
                    cmp selectedOp2Reg,7
                    jne RCR_invalid
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR ValMem[8],cl
                    call SetCarryFlag
                    jmp Exit
                RCR_Mem8_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCR ValMem[8],cl
                    call SetCarryFlag
                    jmp Exit
            RCR_Mem9:
                cmp selectedOp2Type,0
                je RCR_Mem9_Reg
                cmp selectedOp2Type,3
                je RCR_Mem9_Val
                jmp RCR_invalid
                RCR_Mem9_Reg:
                    cmp selectedOp2Reg,7
                    jne RCR_invalid
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR ValMem[9],cl
                    call SetCarryFlag
                    jmp Exit
                RCR_Mem9_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCR ValMem[9],cl
                    call SetCarryFlag
                    jmp Exit
            RCR_Mem10:
                cmp selectedOp2Type,0
                je RCR_Mem10_Reg
                cmp selectedOp2Type,3
                je RCR_Mem10_Val
                jmp RCR_invalid
                RCR_Mem10_Reg:
                    cmp selectedOp2Reg,7
                    jne RCR_invalid
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR ValMem[10],cl
                    call SetCarryFlag
                    jmp Exit
                RCR_Mem10_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCR ValMem[10],cl
                    call SetCarryFlag
                    jmp Exit
            RCR_Mem11:
                cmp selectedOp2Type,0
                je RCR_Mem11_Reg
                cmp selectedOp2Type,3
                je RCR_Mem11_Val
                jmp RCR_invalid
                RCR_Mem11_Reg:
                    cmp selectedOp2Reg,7
                    jne RCR_invalid
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR ValMem[11],cl
                    call SetCarryFlag
                    jmp Exit
                RCR_Mem11_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCR ValMem[11],cl
                    call SetCarryFlag
                    jmp Exit
            RCR_Mem12:
                cmp selectedOp2Type,0
                je RCR_Mem12_Reg
                cmp selectedOp2Type,3
                je RCR_Mem12_Val
                jmp RCR_invalid
                RCR_Mem12_Reg:
                    cmp selectedOp2Reg,7
                    jne RCR_invalid
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR ValMem[12],cl
                    call SetCarryFlag
                    jmp Exit
                RCR_Mem12_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCR ValMem[12],cl
                    call SetCarryFlag
                    jmp Exit
            RCR_Mem13:
                cmp selectedOp2Type,0
                je RCR_Mem13_Reg
                cmp selectedOp2Type,3
                je RCR_Mem13_Val
                jmp RCR_invalid
                RCR_Mem13_Reg:
                    cmp selectedOp2Reg,7
                    jne RCR_invalid
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR ValMem[13],cl
                    call SetCarryFlag
                    jmp Exit
                RCR_Mem13_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCR ValMem[13],cl
                    call SetCarryFlag
                    jmp Exit
            RCR_Mem14:
                cmp selectedOp2Type,0
                je RCR_Mem14_Reg
                cmp selectedOp2Type,3
                je RCR_Mem14_Val
                jmp RCR_invalid
                RCR_Mem14_Reg:
                    cmp selectedOp2Reg,7
                    jne RCR_invalid
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR ValMem[14],cl
                    call SetCarryFlag
                    jmp Exit
                RCR_Mem14_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCR ValMem[14],cl
                    call SetCarryFlag
                    jmp Exit
            RCR_Mem15:
                cmp selectedOp2Type,0
                je RCR_Mem15_Reg
                cmp selectedOp2Type,3
                je RCR_Mem15_Val
                jmp RCR_invalid
                RCR_Mem15_Reg:
                    cmp selectedOp2Reg,7
                    jne RCR_invalid
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR ValMem[15],cl
                    call SetCarryFlag
                    jmp Exit
                RCR_Mem15_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCR ValMem[15],cl
                    call SetCarryFlag
                    jmp Exit
        RCR_invalid:
        jmp InValidCommand
        JMP Exit
    
    RCL_Comm:
        CALL Op1Menu
        MOV DX, CommaCursorLoc
        CALL SetCursor
        mov dl, ','
        CALL DisplayChar
        CALL Op2Menu

        call  PowerUpeMenu ; to choose power up
        CALL CheckForbidCharProc

        cmp selectedOp1Type,0
        je RCL_Reg
        cmp selectedOp1Type,1
        je RCL_AddReg
        cmp selectedOp1Type,2
        je RCL_Mem
        cmp selectedOp1Type,3
        je RCL_invalid

        RCL_Reg:
            cmp selectedOp1Reg,0
            je RCL_Ax
            cmp selectedOp1Reg,1
            je RCL_Al
            cmp selectedOp1Reg,2
            je RCL_Ah
            cmp selectedOp1Reg,3
            je RCL_bx
            cmp selectedOp1Reg,4
            je RCL_Bl
            cmp selectedOp1Reg,5
            je RCL_Bh
            cmp selectedOp1Reg,6
            je RCL_Cx
            cmp selectedOp1Reg,7
            je RCL_Cl
            cmp selectedOp1Reg,8
            je RCL_Ch
            cmp selectedOp1Reg,9
            je RCL_Dx
            cmp selectedOp1Reg,10
            je RCL_Dl
            cmp selectedOp1Reg,11
            je RCL_Dh
            cmp selectedOp1Reg,15
            je RCL_Bp
            cmp selectedOp1Reg,16
            je RCL_Sp
            cmp selectedOp1Reg,17
            je RCL_Si
            cmp selectedOp1Reg,18
            je RCL_Di
            jmp RCL_invalid
            RCL_Ax:
                cmp selectedOp2Type,0
                je RCL_Ax_Reg
                cmp selectedOp2Type,3
                je RCL_Ax_Val
                jmp RCL_invalid
                RCL_Ax_Reg:
                    cmp selectedOp2Reg,7
                    jne RCL_invalid
                    mov ax,ValRegAX
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL Ax,cl
                    mov ValRegAX,ax
                    call SetCarryFlag
                    jmp Exit
                RCL_Ax_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    mov ax,ValRegAX
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCL ax,cl
                    mov ValRegAX,ax
                    call SetCarryFlag
                    jmp Exit
            RCL_Al:
                cmp selectedOp2Type,0
                je RCL_Al_Reg
                cmp selectedOp2Type,3
                je RCL_Al_Val
                jmp RCL_invalid
                RCL_Al_Reg:
                    cmp selectedOp2Reg,7
                    jne RCL_invalid
                    mov ax,ValRegAX
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL Al,cl
                    mov ValRegAX,ax
                    call SetCarryFlag
                    jmp Exit
                RCL_Al_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    mov ax,ValRegAX
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCL al,cl
                    mov ValRegAX,ax
                    call SetCarryFlag
                    jmp Exit
            RCL_Ah:
                cmp selectedOp2Type,0
                je RCL_Ah_Reg
                cmp selectedOp2Type,3
                je RCL_Ah_Val
                jmp RCL_invalid
                RCL_Ah_Reg:
                    cmp selectedOp2Reg,7
                    jne RCL_invalid
                    mov ax,ValRegAX
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL Ah,cl
                    mov ValRegAX,ax
                    call SetCarryFlag
                    jmp Exit
                RCL_Ah_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    mov ax,ValRegAX
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCL ah,cl
                    mov ValRegAX,ax
                    call SetCarryFlag
                    jmp Exit
            RCL_Bx:
                cmp selectedOp2Type,0
                je RCL_Bx_Reg
                cmp selectedOp2Type,3
                je RCL_Bx_Val
                jmp RCL_invalid
                RCL_Bx_Reg:
                    cmp selectedOp2Reg,7
                    jne RCL_invalid
                    mov Bx,ValRegBX
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL Bx,cl
                    mov ValRegBX,Bx
                    call SetCarryFlag
                    jmp Exit
                RCL_Bx_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    mov Bx,ValRegBX
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCL Bx,cl
                    mov ValRegBX,Bx
                    call SetCarryFlag
                    jmp Exit
            RCL_Bl:
                cmp selectedOp2Type,0
                je RCL_Bl_Reg
                cmp selectedOp2Type,3
                je RCL_Bl_Val
                jmp RCL_invalid
                RCL_Bl_Reg:
                    cmp selectedOp2Reg,7
                    jne RCL_invalid
                    mov Bx,ValRegBX
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL Bl,cl
                    mov ValRegBX,Bx
                    call SetCarryFlag
                    jmp Exit
                RCL_Bl_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    mov Bx,ValRegBX
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCL Bl,cl
                    mov ValRegBX,Bx
                    call SetCarryFlag
                    jmp Exit
            RCL_Bh:
                cmp selectedOp2Type,0
                je RCL_Bh_Reg
                cmp selectedOp2Type,3
                je RCL_Bh_Val
                jmp RCL_invalid
                RCL_Bh_Reg:
                    cmp selectedOp2Reg,7
                    jne RCL_invalid
                    mov Bx,ValRegBX
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL Bh,cl
                    mov ValRegBX,Bx
                    call SetCarryFlag
                    jmp Exit
                RCL_Bh_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    mov Bx,ValRegBX
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCL Bh,cl
                    mov ValRegBX,Bx
                    call SetCarryFlag
                    jmp Exit
            RCL_Cx:
                cmp selectedOp2Type,0
                je RCL_Cx_Reg
                cmp selectedOp2Type,3
                je RCL_Cx_Val
                jmp RCL_invalid
                RCL_Cx_Reg:
                    cmp selectedOp2Reg,7
                    jne RCL_invalid
                    mov Cx,ValRegCx
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL Cx,cl
                    mov ValRegCx,Cx
                    call SetCarryFlag
                    jmp Exit
                RCL_Cx_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    mov bx,ValRegCx
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCL bx,cl
                    mov ValRegCx,bx
                    call SetCarryFlag
                    jmp Exit
            RCL_Cl:
                cmp selectedOp2Type,0
                je RCL_Cl_Reg
                cmp selectedOp2Type,3
                je RCL_Cl_Val
                jmp RCL_invalid
                RCL_Cl_Reg:
                    cmp selectedOp2Reg,7
                    jne RCL_invalid
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL Cl,cl
                    mov ValRegCX,Cx
                    call SetCarryFlag
                    jmp Exit
                RCL_Cl_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    mov Bx,ValRegCX
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCL Bl,cl
                    mov ValRegCX,Bx
                    call SetCarryFlag
                    jmp Exit
            RCL_Ch:
                cmp selectedOp2Type,0
                je RCL_Ch_Reg
                cmp selectedOp2Type,3
                je RCL_Ch_Val
                jmp RCL_invalid
                RCL_Ch_Reg:
                    cmp selectedOp2Reg,7
                    jne RCL_invalid
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL Ch,cl
                    mov ValRegCX,Cx
                    call SetCarryFlag
                    jmp Exit
                RCL_Ch_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    mov Bx,ValRegCX
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCL bh,cl
                    mov ValRegCX,Bx
                    call SetCarryFlag
                    jmp Exit
            RCL_Dx:
                cmp selectedOp2Type,0
                je RCL_Dx_Reg
                cmp selectedOp2Type,3
                je RCL_Dx_Val
                jmp RCL_invalid
                RCL_Dx_Reg:
                    cmp selectedOp2Reg,7
                    jne RCL_invalid
                    mov Dx,ValRegDX
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL Dx,cl
                    mov ValRegDX,Dx
                    call SetCarryFlag
                    jmp Exit
                RCL_Dx_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    mov Dx,ValRegDX
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCL Dx,cl
                    mov ValRegDX,Dx
                    call SetCarryFlag
                    jmp Exit
            RCL_Dl:
                cmp selectedOp2Type,0
                je RCL_Dl_Reg
                cmp selectedOp2Type,3
                je RCL_Dl_Val
                jmp RCL_invalid
                RCL_Dl_Reg:
                    cmp selectedOp2Reg,7
                    jne RCL_invalid
                    mov Dx,ValRegDX
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL Dl,cl
                    mov ValRegDX,Dx
                    call SetCarryFlag
                    jmp Exit
                RCL_Dl_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    mov Dx,ValRegDX
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCL Dl,cl
                    mov ValRegDX,Dx
                    call SetCarryFlag
                    jmp Exit
            RCL_Dh:
                cmp selectedOp2Type,0
                je RCL_Dh_Reg
                cmp selectedOp2Type,3
                je RCL_Dh_Val
                jmp RCL_invalid
                RCL_Dh_Reg:
                    cmp selectedOp2Reg,7
                    jne RCL_invalid
                    mov Dx,ValRegDX
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL Dh,cl
                    mov ValRegDX,Dx
                    call SetCarryFlag
                    jmp Exit
                RCL_Dh_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    mov Dx,ValRegDX
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCL Dh,cl
                    mov ValRegDX,Dx
                    call SetCarryFlag
                    jmp Exit
            RCL_Bp:
                cmp selectedOp2Type,0
                je RCL_Bp_Reg
                cmp selectedOp2Type,3
                je RCL_Bp_Val
                jmp RCL_invalid
                RCL_Bp_Reg:
                    cmp selectedOp2Reg,7
                    jne RCL_invalid
                    mov Bp,ValRegBP
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL BP,cl
                    mov ValRegBP,BP
                    call SetCarryFlag
                    jmp Exit
                RCL_BP_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    mov BP,ValRegBP
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCL BP,cl
                    mov ValRegBP,BP
                    call SetCarryFlag
                    jmp Exit
            RCL_Sp:
                cmp selectedOp2Type,0
                je RCL_SP_Reg
                cmp selectedOp2Type,3
                je RCL_SP_Val
                jmp RCL_invalid
                RCL_SP_Reg:
                    cmp selectedOp2Reg,7
                    jne RCL_invalid
                    mov SP,ValRegSP
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL SP,cl
                    mov ValRegSP,SP
                    call SetCarryFlag
                    jmp Exit
                RCL_SP_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    mov SP,ValRegSP
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCL SP,cl
                    mov ValRegSP,SP
                    call SetCarryFlag
                    jmp Exit
            RCL_Si:
                cmp selectedOp2Type,0
                je RCL_SI_Reg
                cmp selectedOp2Type,3
                je RCL_SI_Val
                jmp RCL_invalid
                RCL_SI_Reg:
                    cmp selectedOp2Reg,7
                    jne RCL_invalid
                    mov SI,ValRegSI
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL SI,cl
                    mov ValRegSI,SI
                    call SetCarryFlag
                    jmp Exit
                RCL_SI_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    mov SI,ValRegSI
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCL SI,cl
                    mov ValRegSI,SI
                    call SetCarryFlag
                    jmp Exit
            RCL_Di:
                cmp selectedOp2Type,0
                je RCL_DI_Reg
                cmp selectedOp2Type,3
                je RCL_DI_Val
                jmp RCL_invalid
                RCL_DI_Reg:
                    cmp selectedOp2Reg,7
                    jne RCL_invalid
                    mov DI,ValRegDI
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL DI,cl
                    mov ValRegDI,DI
                    call SetCarryFlag
                    jmp Exit
                RCL_DI_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    mov DI,ValRegDI
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCL DI,cl
                    mov ValRegDI,DI
                    call SetCarryFlag
                    jmp Exit
        RCL_AddReg:
            cmp selectedOp1AddReg,3
            je RCL_AddBx
            cmp selectedOp1AddReg,15
            je RCL_AddBp
            cmp selectedOp1AddReg,17
            je RCL_AddSi
            cmp selectedOp1AddReg,18
            je RCL_AddDi
            jmp RCL_invalid
            RCL_AddBx:
                cmp selectedOp2Type,0
                je RCL_AddBx_Reg
                cmp selectedOp2Type,3
                je RCL_AddBx_Val
                jmp RCL_invalid
                RCL_AddBx_Reg:
                    cmp selectedOp2Reg,7
                    jne RCL_invalid
                    mov Bx,ValRegBX
                    cmp Bx,15d
                    ja RCL_invalid
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL ValMem[Bx],cl
                    mov ValRegBX,Bx
                    call SetCarryFlag
                    jmp Exit
                RCL_AddBx_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    mov Bx,ValRegBX
                    cmp Bx,15d
                    ja RCL_invalid
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCL ValMem[Bx],cl
                    mov ValRegBX,Bx
                    call SetCarryFlag
                    jmp Exit
            RCL_AddBp:
                cmp selectedOp2Type,0
                je RCL_AddBP_Reg
                cmp selectedOp2Type,3
                je RCL_AddBP_Val
                jmp RCL_invalid
                RCL_AddBP_Reg:
                    cmp selectedOp2Reg,7
                    jne RCL_invalid
                    mov BP,ValRegBP
                    cmp BP,15d
                    ja RCL_invalid
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL ValMem[BP],cl
                    mov ValRegBP,BP
                    call SetCarryFlag
                    jmp Exit
                RCL_AddBP_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    mov BP,ValRegBP
                    cmp BP,15d
                    ja RCL_invalid
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCL ValMem[BP],cl
                    mov ValRegBP,BP
                    call SetCarryFlag
                    jmp Exit
            RCL_AddSi:
                cmp selectedOp2Type,0
                je RCL_AddSi_Reg
                cmp selectedOp2Type,3
                je RCL_AddSi_Val
                jmp RCL_invalid
                RCL_AddSi_Reg:
                    cmp selectedOp2Reg,7
                    jne RCL_invalid
                    mov Si,ValRegSI
                    cmp Si,15d
                    ja RCL_invalid
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL ValMem[Si],cl
                    mov ValRegSI,Si
                    call SetCarryFlag
                    jmp Exit
                RCL_AddSi_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    mov Si,ValRegSI
                    cmp Si,15d
                    ja RCL_invalid
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCL ValMem[Si],cl
                    mov ValRegSI,Si
                    call SetCarryFlag
                    jmp Exit
            RCL_AddDi:
                cmp selectedOp2Type,0
                je RCL_AddDI_Reg
                cmp selectedOp2Type,3
                je RCL_AddDI_Val
                jmp RCL_invalid
                RCL_AddDI_Reg:
                    cmp selectedOp2Reg,7
                    jne RCL_invalid
                    mov DI,ValRegDI
                    cmp DI,15d
                    ja RCL_invalid
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL ValMem[DI],cl
                    mov ValRegDI,DI
                    call SetCarryFlag
                    jmp Exit
                RCL_AddDI_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    mov DI,ValRegDI
                    cmp DI,15d
                    ja RCL_invalid
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCL ValMem[DI],cl
                    mov ValRegDI,DI
                    call SetCarryFlag
                    jmp Exit
        RCL_Mem:
            cmp selectedOp1Mem,0
            je RCL_Mem0
            cmp selectedOp1Mem,1
            je RCL_Mem1
            cmp selectedOp1Mem,2
            je RCL_Mem2
            cmp selectedOp1Mem,3
            je RCL_Mem3
            cmp selectedOp1Mem,4
            je RCL_Mem4
            cmp selectedOp1Mem,5
            je RCL_Mem5
            cmp selectedOp1Mem,6
            je RCL_Mem6
            cmp selectedOp1Mem,7
            je RCL_Mem7
            cmp selectedOp1Mem,8
            je RCL_Mem8
            cmp selectedOp1Mem,9
            je RCL_Mem9
            cmp selectedOp1Mem,10
            je RCL_Mem10
            cmp selectedOp1Mem,11
            je RCL_Mem11
            cmp selectedOp1Mem,12
            je RCL_Mem12
            cmp selectedOp1Mem,13
            je RCL_Mem13
            cmp selectedOp1Mem,14
            je RCL_Mem14
            cmp selectedOp1Mem,15
            je RCL_Mem15
            jmp RCL_invalid
            RCL_Mem0:
                cmp selectedOp2Type,0
                je RCL_Mem0_Reg
                cmp selectedOp2Type,3
                je RCL_Mem0_Val
                jmp RCL_invalid
                RCL_Mem0_Reg:
                    cmp selectedOp2Reg,7
                    jne RCL_invalid
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL ValMem[0],cl
                    call SetCarryFlag
                    jmp Exit
                RCL_Mem0_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCL ValMem[0],cl
                    call SetCarryFlag
                    jmp Exit
            RCL_Mem1:
                cmp selectedOp2Type,0
                je RCL_Mem1_Reg
                cmp selectedOp2Type,3
                je RCL_Mem1_Val
                jmp RCL_invalid
                RCL_Mem1_Reg:
                    cmp selectedOp2Reg,7
                    jne RCL_invalid
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL ValMem[1],cl
                    call SetCarryFlag
                    jmp Exit
                RCL_Mem1_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCL ValMem[1],cl
                    call SetCarryFlag
                    jmp Exit
            RCL_Mem2:
                cmp selectedOp2Type,0
                je RCL_Mem2_Reg
                cmp selectedOp2Type,3
                je RCL_Mem2_Val
                jmp RCL_invalid
                RCL_Mem2_Reg:
                    cmp selectedOp2Reg,7
                    jne RCL_invalid
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL ValMem[2],cl
                    call SetCarryFlag
                    jmp Exit
                RCL_Mem2_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCL ValMem[2],cl
                    call SetCarryFlag
                    jmp Exit
            RCL_Mem3:
                cmp selectedOp2Type,0
                je RCL_Mem3_Reg
                cmp selectedOp2Type,3
                je RCL_Mem3_Val
                jmp RCL_invalid
                RCL_Mem3_Reg:
                    cmp selectedOp2Reg,7
                    jne RCL_invalid
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL ValMem[3],cl
                    call SetCarryFlag
                    jmp Exit
                RCL_Mem3_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCL ValMem[3],cl
                    call SetCarryFlag
                    jmp Exit
            RCL_Mem4:
                cmp selectedOp2Type,0
                je RCL_Mem4_Reg
                cmp selectedOp2Type,3
                je RCL_Mem4_Val
                jmp RCL_invalid
                RCL_Mem4_Reg:
                    cmp selectedOp2Reg,7
                    jne RCL_invalid
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL ValMem[4],cl
                    call SetCarryFlag
                    jmp Exit
                RCL_Mem4_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCL ValMem[4],cl
                    call SetCarryFlag
                    jmp Exit
            RCL_Mem5:
                cmp selectedOp2Type,0
                je RCL_Mem5_Reg
                cmp selectedOp2Type,3
                je RCL_Mem5_Val
                jmp RCL_invalid
                RCL_Mem5_Reg:
                    cmp selectedOp2Reg,7
                    jne RCL_invalid
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL ValMem[5],cl
                    call SetCarryFlag
                    jmp Exit
                RCL_Mem5_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCL ValMem[5],cl
                    call SetCarryFlag
                    jmp Exit
            RCL_Mem6:
                cmp selectedOp2Type,0
                je RCL_Mem6_Reg
                cmp selectedOp2Type,3
                je RCL_Mem6_Val
                jmp RCL_invalid
                RCL_Mem6_Reg:
                    cmp selectedOp2Reg,7
                    jne RCL_invalid
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL ValMem[6],cl
                    call SetCarryFlag
                    jmp Exit
                RCL_Mem6_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCL ValMem[6],cl
                    call SetCarryFlag
                    jmp Exit
            RCL_Mem7:
                cmp selectedOp2Type,0
                je RCL_Mem7_Reg
                cmp selectedOp2Type,3
                je RCL_Mem7_Val
                jmp RCL_invalid
                RCL_Mem7_Reg:
                    cmp selectedOp2Reg,7
                    jne RCL_invalid
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL ValMem[7],cl
                    call SetCarryFlag
                    jmp Exit
                RCL_Mem7_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCL ValMem[7],cl
                    call SetCarryFlag
                    jmp Exit
            RCL_Mem8:
                cmp selectedOp2Type,0
                je RCL_Mem8_Reg
                cmp selectedOp2Type,3
                je RCL_Mem8_Val
                jmp RCL_invalid
                RCL_Mem8_Reg:
                    cmp selectedOp2Reg,7
                    jne RCL_invalid
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL ValMem[8],cl
                    call SetCarryFlag
                    jmp Exit
                RCL_Mem8_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCL ValMem[8],cl
                    call SetCarryFlag
                    jmp Exit
            RCL_Mem9:
                cmp selectedOp2Type,0
                je RCL_Mem9_Reg
                cmp selectedOp2Type,3
                je RCL_Mem9_Val
                jmp RCL_invalid
                RCL_Mem9_Reg:
                    cmp selectedOp2Reg,7
                    jne RCL_invalid
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL ValMem[9],cl
                    call SetCarryFlag
                    jmp Exit
                RCL_Mem9_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCL ValMem[9],cl
                    call SetCarryFlag
                    jmp Exit
            RCL_Mem10:
                cmp selectedOp2Type,0
                je RCL_Mem10_Reg
                cmp selectedOp2Type,3
                je RCL_Mem10_Val
                jmp RCL_invalid
                RCL_Mem10_Reg:
                    cmp selectedOp2Reg,7
                    jne RCL_invalid
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL ValMem[10],cl
                    call SetCarryFlag
                    jmp Exit
                RCL_Mem10_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCL ValMem[10],cl
                    call SetCarryFlag
                    jmp Exit
            RCL_Mem11:
                cmp selectedOp2Type,0
                je RCL_Mem11_Reg
                cmp selectedOp2Type,3
                je RCL_Mem11_Val
                jmp RCL_invalid
                RCL_Mem11_Reg:
                    cmp selectedOp2Reg,7
                    jne RCL_invalid
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL ValMem[11],cl
                    call SetCarryFlag
                    jmp Exit
                RCL_Mem11_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCL ValMem[11],cl
                    call SetCarryFlag
                    jmp Exit
            RCL_Mem12:
                cmp selectedOp2Type,0
                je RCL_Mem12_Reg
                cmp selectedOp2Type,3
                je RCL_Mem12_Val
                jmp RCL_invalid
                RCL_Mem12_Reg:
                    cmp selectedOp2Reg,7
                    jne RCL_invalid
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL ValMem[12],cl
                    call SetCarryFlag
                    jmp Exit
                RCL_Mem12_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCL ValMem[12],cl
                    call SetCarryFlag
                    jmp Exit
            RCL_Mem13:
                cmp selectedOp2Type,0
                je RCL_Mem13_Reg
                cmp selectedOp2Type,3
                je RCL_Mem13_Val
                jmp RCL_invalid
                RCL_Mem13_Reg:
                    cmp selectedOp2Reg,7
                    jne RCL_invalid
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL ValMem[13],cl
                    call SetCarryFlag
                    jmp Exit
                RCL_Mem13_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCL ValMem[13],cl
                    call SetCarryFlag
                    jmp Exit
            RCL_Mem14:
                cmp selectedOp2Type,0
                je RCL_Mem14_Reg
                cmp selectedOp2Type,3
                je RCL_Mem14_Val
                jmp RCL_invalid
                RCL_Mem14_Reg:
                    cmp selectedOp2Reg,7
                    jne RCL_invalid
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL ValMem[14],cl
                    call SetCarryFlag
                    jmp Exit
                RCL_Mem14_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCL ValMem[14],cl
                    call SetCarryFlag
                    jmp Exit
            RCL_Mem15:
                cmp selectedOp2Type,0
                je RCL_Mem15_Reg
                cmp selectedOp2Type,3
                je RCL_Mem15_Val
                jmp RCL_invalid
                RCL_Mem15_Reg:
                    cmp selectedOp2Reg,7
                    jne RCL_invalid
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL ValMem[15],cl
                    call SetCarryFlag
                    jmp Exit
                RCL_Mem15_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    mov cx,Op2Val
                    call GetCarryFlag
                    RCL ValMem[15],cl
                    call SetCarryFlag
                    jmp Exit
        RCL_invalid:
        jmp InValidCommand
        JMP Exit
    
    SHL_Comm:
        CALL Op1Menu
        MOV DX, CommaCursorLoc
        CALL SetCursor
        mov dl, ','
        CALL DisplayChar
        CALL Op2Menu

        call  PowerUpeMenu ; to choose power up
        CALL CheckForbidCharProc
        
        cmp selectedOp1Type,0
        je SHL_Reg
        cmp selectedOp1Type,1
        je SHL_AddReg
        cmp selectedOp1Type,2
        je SHL_Mem
        cmp selectedOp1Type,3
        je SHL_invalid

        SHL_Reg:
            cmp selectedOp1Reg,0
            je SHL_Ax
            cmp selectedOp1Reg,1
            je SHL_Al
            cmp selectedOp1Reg,2
            je SHL_Ah
            cmp selectedOp1Reg,3
            je SHL_bx
            cmp selectedOp1Reg,4
            je SHL_Bl
            cmp selectedOp1Reg,5
            je SHL_Bh
            cmp selectedOp1Reg,6
            je SHL_Cx
            cmp selectedOp1Reg,7
            je SHL_Cl
            cmp selectedOp1Reg,8
            je SHL_Ch
            cmp selectedOp1Reg,9
            je SHL_Dx
            cmp selectedOp1Reg,10
            je SHL_Dl
            cmp selectedOp1Reg,11
            je SHL_Dh
            cmp selectedOp1Reg,15
            je SHL_Bp
            cmp selectedOp1Reg,16
            je SHL_Sp
            cmp selectedOp1Reg,17
            je SHL_Si
            cmp selectedOp1Reg,18
            je SHL_Di
            jmp SHL_invalid
            SHL_Ax:
                cmp selectedOp2Type,0
                je SHL_Ax_Reg
                cmp selectedOp2Type,3
                je SHL_Ax_Val
                jmp SHL_invalid
                SHL_Ax_Reg:
                    cmp selectedOp2Reg,7
                    jne SHL_invalid
                    mov ax,ValRegAX
                    mov cx,ValRegCX
                    clc
                    SHL Ax,cl
                    mov ValRegAX,ax
                    call SetCarryFlag
                    jmp Exit
                SHL_Ax_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    mov ax,ValRegAX
                    mov cx,Op2Val
                    clc
                    SHL ax,cl
                    mov ValRegAX,ax
                    call SetCarryFlag
                    jmp Exit
            SHL_Al:
                cmp selectedOp2Type,0
                je SHL_Al_Reg
                cmp selectedOp2Type,3
                je SHL_Al_Val
                jmp SHL_invalid
                SHL_Al_Reg:
                    cmp selectedOp2Reg,7
                    jne SHL_invalid
                    mov ax,ValRegAX
                    mov cx,ValRegCX
                    clc
                    SHL Al,cl
                    mov ValRegAX,ax
                    call SetCarryFlag
                    jmp Exit
                SHL_Al_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    mov ax,ValRegAX
                    mov cx,Op2Val
                    clc
                    SHL al,cl
                    mov ValRegAX,ax
                    call SetCarryFlag
                    jmp Exit
            SHL_Ah:
                cmp selectedOp2Type,0
                je SHL_Ah_Reg
                cmp selectedOp2Type,3
                je SHL_Ah_Val
                jmp SHL_invalid
                SHL_Ah_Reg:
                    cmp selectedOp2Reg,7
                    jne SHL_invalid
                    mov ax,ValRegAX
                    mov cx,ValRegCX
                    clc
                    SHL Ah,cl
                    mov ValRegAX,ax
                    call SetCarryFlag
                    jmp Exit
                SHL_Ah_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    mov ax,ValRegAX
                    mov cx,Op2Val
                    clc
                    SHL ah,cl
                    mov ValRegAX,ax
                    call SetCarryFlag
                    jmp Exit
            SHL_Bx:
                cmp selectedOp2Type,0
                je SHL_Bx_Reg
                cmp selectedOp2Type,3
                je SHL_Bx_Val
                jmp SHL_invalid
                SHL_Bx_Reg:
                    cmp selectedOp2Reg,7
                    jne SHL_invalid
                    mov Bx,ValRegBX
                    mov cx,ValRegCX
                    clc
                    SHL Bx,cl
                    mov ValRegBX,Bx
                    call SetCarryFlag
                    jmp Exit
                SHL_Bx_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    mov Bx,ValRegBX
                    mov cx,Op2Val
                    clc
                    SHL Bx,cl
                    mov ValRegBX,Bx
                    call SetCarryFlag
                    jmp Exit
            SHL_Bl:
                cmp selectedOp2Type,0
                je SHL_Bl_Reg
                cmp selectedOp2Type,3
                je SHL_Bl_Val
                jmp SHL_invalid
                SHL_Bl_Reg:
                    cmp selectedOp2Reg,7
                    jne SHL_invalid
                    mov Bx,ValRegBX
                    mov cx,ValRegCX
                    clc
                    SHL Bl,cl
                    mov ValRegBX,Bx
                    call SetCarryFlag
                    jmp Exit
                SHL_Bl_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    mov Bx,ValRegBX
                    mov cx,Op2Val
                    clc
                    SHL Bl,cl
                    mov ValRegBX,Bx
                    call SetCarryFlag
                    jmp Exit
            SHL_Bh:
                cmp selectedOp2Type,0
                je SHL_Bh_Reg
                cmp selectedOp2Type,3
                je SHL_Bh_Val
                jmp SHL_invalid
                SHL_Bh_Reg:
                    cmp selectedOp2Reg,7
                    jne SHL_invalid
                    mov Bx,ValRegBX
                    mov cx,ValRegCX
                    clc
                    SHL Bh,cl
                    mov ValRegBX,Bx
                    call SetCarryFlag
                    jmp Exit
                SHL_Bh_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    mov Bx,ValRegBX
                    mov cx,Op2Val
                    clc
                    SHL Bh,cl
                    mov ValRegBX,Bx
                    call SetCarryFlag
                    jmp Exit
            SHL_Cx:
                cmp selectedOp2Type,0
                je SHL_Cx_Reg
                cmp selectedOp2Type,3
                je SHL_Cx_Val
                jmp SHL_invalid
                SHL_Cx_Reg:
                    cmp selectedOp2Reg,7
                    jne SHL_invalid
                    mov Cx,ValRegCx
                    mov cx,ValRegCX
                    clc
                    SHL Cx,cl
                    mov ValRegCx,Cx
                    call SetCarryFlag
                    jmp Exit
                SHL_Cx_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    mov bx,ValRegCx
                    mov cx,Op2Val
                    clc
                    SHL bx,cl
                    mov ValRegCx,bx
                    call SetCarryFlag
                    jmp Exit
            SHL_Cl:
                cmp selectedOp2Type,0
                je SHL_Cl_Reg
                cmp selectedOp2Type,3
                je SHL_Cl_Val
                jmp SHL_invalid
                SHL_Cl_Reg:
                    cmp selectedOp2Reg,7
                    jne SHL_invalid
                    mov cx,ValRegCX
                    clc
                    SHL Cl,cl
                    mov ValRegCX,Cx
                    call SetCarryFlag
                    jmp Exit
                SHL_Cl_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    mov Bx,ValRegCX
                    mov cx,Op2Val
                    clc
                    SHL Bl,cl
                    mov ValRegCX,Bx
                    call SetCarryFlag
                    jmp Exit
            SHL_Ch:
                cmp selectedOp2Type,0
                je SHL_Ch_Reg
                cmp selectedOp2Type,3
                je SHL_Ch_Val
                jmp SHL_invalid
                SHL_Ch_Reg:
                    cmp selectedOp2Reg,7
                    jne SHL_invalid
                    mov cx,ValRegCX
                    clc
                    SHL Ch,cl
                    mov ValRegCX,Cx
                    call SetCarryFlag
                    jmp Exit
                SHL_Ch_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    mov Bx,ValRegCX
                    mov cx,Op2Val
                    clc
                    SHL bh,cl
                    mov ValRegCX,Bx
                    call SetCarryFlag
                    jmp Exit
            SHL_Dx:
                cmp selectedOp2Type,0
                je SHL_Dx_Reg
                cmp selectedOp2Type,3
                je SHL_Dx_Val
                jmp SHL_invalid
                SHL_Dx_Reg:
                    cmp selectedOp2Reg,7
                    jne SHL_invalid
                    mov Dx,ValRegDX
                    mov cx,ValRegCX
                    clc
                    SHL Dx,cl
                    mov ValRegDX,Dx
                    call SetCarryFlag
                    jmp Exit
                SHL_Dx_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    mov Dx,ValRegDX
                    mov cx,Op2Val
                    clc
                    SHL Dx,cl
                    mov ValRegDX,Dx
                    call SetCarryFlag
                    jmp Exit
            SHL_Dl:
                cmp selectedOp2Type,0
                je SHL_Dl_Reg
                cmp selectedOp2Type,3
                je SHL_Dl_Val
                jmp SHL_invalid
                SHL_Dl_Reg:
                    cmp selectedOp2Reg,7
                    jne SHL_invalid
                    mov Dx,ValRegDX
                    mov cx,ValRegCX
                    clc
                    SHL Dl,cl
                    mov ValRegDX,Dx
                    call SetCarryFlag
                    jmp Exit
                SHL_Dl_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    mov Dx,ValRegDX
                    mov cx,Op2Val
                    clc
                    SHL Dl,cl
                    mov ValRegDX,Dx
                    call SetCarryFlag
                    jmp Exit
            SHL_Dh:
                cmp selectedOp2Type,0
                je SHL_Dh_Reg
                cmp selectedOp2Type,3
                je SHL_Dh_Val
                jmp SHL_invalid
                SHL_Dh_Reg:
                    cmp selectedOp2Reg,7
                    jne SHL_invalid
                    mov Dx,ValRegDX
                    mov cx,ValRegCX
                    clc
                    SHL Dh,cl
                    mov ValRegDX,Dx
                    call SetCarryFlag
                    jmp Exit
                SHL_Dh_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    mov Dx,ValRegDX
                    mov cx,Op2Val
                    clc
                    SHL Dh,cl
                    mov ValRegDX,Dx
                    call SetCarryFlag
                    jmp Exit
            SHL_Bp:
                cmp selectedOp2Type,0
                je SHL_Bp_Reg
                cmp selectedOp2Type,3
                je SHL_Bp_Val
                jmp SHL_invalid
                SHL_Bp_Reg:
                    cmp selectedOp2Reg,7
                    jne SHL_invalid
                    mov Bp,ValRegBP
                    mov cx,ValRegCX
                    clc
                    SHL BP,cl
                    mov ValRegBP,BP
                    call SetCarryFlag
                    jmp Exit
                SHL_BP_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    mov BP,ValRegBP
                    mov cx,Op2Val
                    clc
                    SHL BP,cl
                    mov ValRegBP,BP
                    call SetCarryFlag
                    jmp Exit
            SHL_Sp:
                cmp selectedOp2Type,0
                je SHL_SP_Reg
                cmp selectedOp2Type,3
                je SHL_SP_Val
                jmp SHL_invalid
                SHL_SP_Reg:
                    cmp selectedOp2Reg,7
                    jne SHL_invalid
                    mov SP,ValRegSP
                    mov cx,ValRegCX
                    clc
                    SHL SP,cl
                    mov ValRegSP,SP
                    call SetCarryFlag
                    jmp Exit
                SHL_SP_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    mov SP,ValRegSP
                    mov cx,Op2Val
                    clc
                    SHL SP,cl
                    mov ValRegSP,SP
                    call SetCarryFlag
                    jmp Exit
            SHL_Si:
                cmp selectedOp2Type,0
                je SHL_SI_Reg
                cmp selectedOp2Type,3
                je SHL_SI_Val
                jmp SHL_invalid
                SHL_SI_Reg:
                    cmp selectedOp2Reg,7
                    jne SHL_invalid
                    mov SI,ValRegSI
                    mov cx,ValRegCX
                    clc
                    SHL SI,cl
                    mov ValRegSI,SI
                    call SetCarryFlag
                    jmp Exit
                SHL_SI_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    mov SI,ValRegSI
                    mov cx,Op2Val
                    clc
                    SHL SI,cl
                    mov ValRegSI,SI
                    call SetCarryFlag
                    jmp Exit
            SHL_Di:
                cmp selectedOp2Type,0
                je SHL_DI_Reg
                cmp selectedOp2Type,3
                je SHL_DI_Val
                jmp SHL_invalid
                SHL_DI_Reg:
                    cmp selectedOp2Reg,7
                    jne SHL_invalid
                    mov DI,ValRegDI
                    mov cx,ValRegCX
                    clc
                    SHL DI,cl
                    mov ValRegDI,DI
                    call SetCarryFlag
                    jmp Exit
                SHL_DI_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    mov DI,ValRegDI
                    mov cx,Op2Val
                    clc
                    SHL DI,cl
                    mov ValRegDI,DI
                    call SetCarryFlag
                    jmp Exit
        SHL_AddReg:
            cmp selectedOp1AddReg,3
            je SHL_AddBx
            cmp selectedOp1AddReg,15
            je SHL_AddBp
            cmp selectedOp1AddReg,17
            je SHL_AddSi
            cmp selectedOp1AddReg,18
            je SHL_AddDi
            jmp SHL_invalid
            SHL_AddBx:
                cmp selectedOp2Type,0
                je SHL_AddBx_Reg
                cmp selectedOp2Type,3
                je SHL_AddBx_Val
                jmp SHL_invalid
                SHL_AddBx_Reg:
                    cmp selectedOp2Reg,7
                    jne SHL_invalid
                    mov Bx,ValRegBX
                    cmp Bx,15d
                    ja SHL_invalid
                    mov cx,ValRegCX
                    clc
                    SHL ValMem[Bx],cl
                    mov ValRegBX,Bx
                    call SetCarryFlag
                    jmp Exit
                SHL_AddBx_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    mov Bx,ValRegBX
                    cmp Bx,15d
                    ja SHL_invalid
                    mov cx,Op2Val
                    clc
                    SHL ValMem[Bx],cl
                    mov ValRegBX,Bx
                    call SetCarryFlag
                    jmp Exit
            SHL_AddBp:
                cmp selectedOp2Type,0
                je SHL_AddBP_Reg
                cmp selectedOp2Type,3
                je SHL_AddBP_Val
                jmp SHL_invalid
                SHL_AddBP_Reg:
                    cmp selectedOp2Reg,7
                    jne SHL_invalid
                    mov BP,ValRegBP
                    cmp BP,15d
                    ja SHL_invalid
                    mov cx,ValRegCX
                    clc
                    SHL ValMem[BP],cl
                    mov ValRegBP,BP
                    call SetCarryFlag
                    jmp Exit
                SHL_AddBP_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    mov BP,ValRegBP
                    cmp BP,15d
                    ja SHL_invalid
                    mov cx,Op2Val
                    clc
                    SHL ValMem[BP],cl
                    mov ValRegBP,BP
                    call SetCarryFlag
                    jmp Exit
            SHL_AddSi:
                cmp selectedOp2Type,0
                je SHL_AddSi_Reg
                cmp selectedOp2Type,3
                je SHL_AddSi_Val
                jmp SHL_invalid
                SHL_AddSi_Reg:
                    cmp selectedOp2Reg,7
                    jne SHL_invalid
                    mov Si,ValRegSI
                    cmp Si,15d
                    ja SHL_invalid
                    mov cx,ValRegCX
                    clc
                    SHL ValMem[Si],cl
                    mov ValRegSI,Si
                    call SetCarryFlag
                    jmp Exit
                SHL_AddSi_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    mov Si,ValRegSI
                    cmp Si,15d
                    ja SHL_invalid
                    mov cx,Op2Val
                    clc
                    SHL ValMem[Si],cl
                    mov ValRegSI,Si
                    call SetCarryFlag
                    jmp Exit
            SHL_AddDi:
                cmp selectedOp2Type,0
                je SHL_AddDI_Reg
                cmp selectedOp2Type,3
                je SHL_AddDI_Val
                jmp SHL_invalid
                SHL_AddDI_Reg:
                    cmp selectedOp2Reg,7
                    jne SHL_invalid
                    mov DI,ValRegDI
                    cmp DI,15d
                    ja SHL_invalid
                    mov cx,ValRegCX
                    clc
                    SHL ValMem[DI],cl
                    mov ValRegDI,DI
                    call SetCarryFlag
                    jmp Exit
                SHL_AddDI_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    mov DI,ValRegDI
                    cmp DI,15d
                    ja SHL_invalid
                    mov cx,Op2Val
                    clc
                    SHL ValMem[DI],cl
                    mov ValRegDI,DI
                    call SetCarryFlag
                    jmp Exit
        SHL_Mem:
            cmp selectedOp1Mem,0
            je SHL_Mem0
            cmp selectedOp1Mem,1
            je SHL_Mem1
            cmp selectedOp1Mem,2
            je SHL_Mem2
            cmp selectedOp1Mem,3
            je SHL_Mem3
            cmp selectedOp1Mem,4
            je SHL_Mem4
            cmp selectedOp1Mem,5
            je SHL_Mem5
            cmp selectedOp1Mem,6
            je SHL_Mem6
            cmp selectedOp1Mem,7
            je SHL_Mem7
            cmp selectedOp1Mem,8
            je SHL_Mem8
            cmp selectedOp1Mem,9
            je SHL_Mem9
            cmp selectedOp1Mem,10
            je SHL_Mem10
            cmp selectedOp1Mem,11
            je SHL_Mem11
            cmp selectedOp1Mem,12
            je SHL_Mem12
            cmp selectedOp1Mem,13
            je SHL_Mem13
            cmp selectedOp1Mem,14
            je SHL_Mem14
            cmp selectedOp1Mem,15
            je SHL_Mem15
            jmp SHL_invalid
            SHL_Mem0:
                cmp selectedOp2Type,0
                je SHL_Mem0_Reg
                cmp selectedOp2Type,3
                je SHL_Mem0_Val
                jmp SHL_invalid
                SHL_Mem0_Reg:
                    cmp selectedOp2Reg,7
                    jne SHL_invalid
                    mov cx,ValRegCX
                    clc
                    SHL ValMem[0],cl
                    call SetCarryFlag
                    jmp Exit
                SHL_Mem0_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    mov cx,Op2Val
                    clc
                    SHL ValMem[0],cl
                    call SetCarryFlag
                    jmp Exit
            SHL_Mem1:
                cmp selectedOp2Type,0
                je SHL_Mem1_Reg
                cmp selectedOp2Type,3
                je SHL_Mem1_Val
                jmp SHL_invalid
                SHL_Mem1_Reg:
                    cmp selectedOp2Reg,7
                    jne SHL_invalid
                    mov cx,ValRegCX
                    clc
                    SHL ValMem[1],cl
                    call SetCarryFlag
                    jmp Exit
                SHL_Mem1_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    mov cx,Op2Val
                    clc
                    SHL ValMem[1],cl
                    call SetCarryFlag
                    jmp Exit
            SHL_Mem2:
                cmp selectedOp2Type,0
                je SHL_Mem2_Reg
                cmp selectedOp2Type,3
                je SHL_Mem2_Val
                jmp SHL_invalid
                SHL_Mem2_Reg:
                    cmp selectedOp2Reg,7
                    jne SHL_invalid
                    mov cx,ValRegCX
                    clc
                    SHL ValMem[2],cl
                    call SetCarryFlag
                    jmp Exit
                SHL_Mem2_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    mov cx,Op2Val
                    clc
                    SHL ValMem[2],cl
                    call SetCarryFlag
                    jmp Exit
            SHL_Mem3:
                cmp selectedOp2Type,0
                je SHL_Mem3_Reg
                cmp selectedOp2Type,3
                je SHL_Mem3_Val
                jmp SHL_invalid
                SHL_Mem3_Reg:
                    cmp selectedOp2Reg,7
                    jne SHL_invalid
                    mov cx,ValRegCX
                    clc
                    SHL ValMem[3],cl
                    call SetCarryFlag
                    jmp Exit
                SHL_Mem3_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    mov cx,Op2Val
                    clc
                    SHL ValMem[3],cl
                    call SetCarryFlag
                    jmp Exit
            SHL_Mem4:
                cmp selectedOp2Type,0
                je SHL_Mem4_Reg
                cmp selectedOp2Type,3
                je SHL_Mem4_Val
                jmp SHL_invalid
                SHL_Mem4_Reg:
                    cmp selectedOp2Reg,7
                    jne SHL_invalid
                    mov cx,ValRegCX
                    clc
                    SHL ValMem[4],cl
                    call SetCarryFlag
                    jmp Exit
                SHL_Mem4_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    mov cx,Op2Val
                    clc
                    SHL ValMem[4],cl
                    call SetCarryFlag
                    jmp Exit
            SHL_Mem5:
                cmp selectedOp2Type,0
                je SHL_Mem5_Reg
                cmp selectedOp2Type,3
                je SHL_Mem5_Val
                jmp SHL_invalid
                SHL_Mem5_Reg:
                    cmp selectedOp2Reg,7
                    jne SHL_invalid
                    mov cx,ValRegCX
                    clc
                    SHL ValMem[5],cl
                    call SetCarryFlag
                    jmp Exit
                SHL_Mem5_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    mov cx,Op2Val
                    clc
                    SHL ValMem[5],cl
                    call SetCarryFlag
                    jmp Exit
            SHL_Mem6:
                cmp selectedOp2Type,0
                je SHL_Mem6_Reg
                cmp selectedOp2Type,3
                je SHL_Mem6_Val
                jmp SHL_invalid
                SHL_Mem6_Reg:
                    cmp selectedOp2Reg,7
                    jne SHL_invalid
                    mov cx,ValRegCX
                    clc
                    SHL ValMem[6],cl
                    call SetCarryFlag
                    jmp Exit
                SHL_Mem6_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    mov cx,Op2Val
                    clc
                    SHL ValMem[6],cl
                    call SetCarryFlag
                    jmp Exit
            SHL_Mem7:
                cmp selectedOp2Type,0
                je SHL_Mem7_Reg
                cmp selectedOp2Type,3
                je SHL_Mem7_Val
                jmp SHL_invalid
                SHL_Mem7_Reg:
                    cmp selectedOp2Reg,7
                    jne SHL_invalid
                    mov cx,ValRegCX
                    clc
                    SHL ValMem[7],cl
                    call SetCarryFlag
                    jmp Exit
                SHL_Mem7_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    mov cx,Op2Val
                    clc
                    SHL ValMem[7],cl
                    call SetCarryFlag
                    jmp Exit
            SHL_Mem8:
                cmp selectedOp2Type,0
                je SHL_Mem8_Reg
                cmp selectedOp2Type,3
                je SHL_Mem8_Val
                jmp SHL_invalid
                SHL_Mem8_Reg:
                    cmp selectedOp2Reg,7
                    jne SHL_invalid
                    mov cx,ValRegCX
                    clc
                    SHL ValMem[8],cl
                    call SetCarryFlag
                    jmp Exit
                SHL_Mem8_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    mov cx,Op2Val
                    clc
                    SHL ValMem[8],cl
                    call SetCarryFlag
                    jmp Exit
            SHL_Mem9:
                cmp selectedOp2Type,0
                je SHL_Mem9_Reg
                cmp selectedOp2Type,3
                je SHL_Mem9_Val
                jmp SHL_invalid
                SHL_Mem9_Reg:
                    cmp selectedOp2Reg,7
                    jne SHL_invalid
                    mov cx,ValRegCX
                    clc
                    SHL ValMem[9],cl
                    call SetCarryFlag
                    jmp Exit
                SHL_Mem9_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    mov cx,Op2Val
                    clc
                    SHL ValMem[9],cl
                    call SetCarryFlag
                    jmp Exit
            SHL_Mem10:
                cmp selectedOp2Type,0
                je SHL_Mem10_Reg
                cmp selectedOp2Type,3
                je SHL_Mem10_Val
                jmp SHL_invalid
                SHL_Mem10_Reg:
                    cmp selectedOp2Reg,7
                    jne SHL_invalid
                    mov cx,ValRegCX
                    clc
                    SHL ValMem[10],cl
                    call SetCarryFlag
                    jmp Exit
                SHL_Mem10_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    mov cx,Op2Val
                    clc
                    SHL ValMem[10],cl
                    call SetCarryFlag
                    jmp Exit
            SHL_Mem11:
                cmp selectedOp2Type,0
                je SHL_Mem11_Reg
                cmp selectedOp2Type,3
                je SHL_Mem11_Val
                jmp SHL_invalid
                SHL_Mem11_Reg:
                    cmp selectedOp2Reg,7
                    jne SHL_invalid
                    mov cx,ValRegCX
                    clc
                    SHL ValMem[11],cl
                    call SetCarryFlag
                    jmp Exit
                SHL_Mem11_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    mov cx,Op2Val
                    clc
                    SHL ValMem[11],cl
                    call SetCarryFlag
                    jmp Exit
            SHL_Mem12:
                cmp selectedOp2Type,0
                je SHL_Mem12_Reg
                cmp selectedOp2Type,3
                je SHL_Mem12_Val
                jmp SHL_invalid
                SHL_Mem12_Reg:
                    cmp selectedOp2Reg,7
                    jne SHL_invalid
                    mov cx,ValRegCX
                    clc
                    SHL ValMem[12],cl
                    call SetCarryFlag
                    jmp Exit
                SHL_Mem12_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    mov cx,Op2Val
                    clc
                    SHL ValMem[12],cl
                    call SetCarryFlag
                    jmp Exit
            SHL_Mem13:
                cmp selectedOp2Type,0
                je SHL_Mem13_Reg
                cmp selectedOp2Type,3
                je SHL_Mem13_Val
                jmp SHL_invalid
                SHL_Mem13_Reg:
                    cmp selectedOp2Reg,7
                    jne SHL_invalid
                    mov cx,ValRegCX
                    clc
                    SHL ValMem[13],cl
                    call SetCarryFlag
                    jmp Exit
                SHL_Mem13_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    mov cx,Op2Val
                    clc
                    SHL ValMem[13],cl
                    call SetCarryFlag
                    jmp Exit
            SHL_Mem14:
                cmp selectedOp2Type,0
                je SHL_Mem14_Reg
                cmp selectedOp2Type,3
                je SHL_Mem14_Val
                jmp SHL_invalid
                SHL_Mem14_Reg:
                    cmp selectedOp2Reg,7
                    jne SHL_invalid
                    mov cx,ValRegCX
                    clc
                    SHL ValMem[14],cl
                    call SetCarryFlag
                    jmp Exit
                SHL_Mem14_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    mov cx,Op2Val
                    clc
                    SHL ValMem[14],cl
                    call SetCarryFlag
                    jmp Exit
            SHL_Mem15:
                cmp selectedOp2Type,0
                je SHL_Mem15_Reg
                cmp selectedOp2Type,3
                je SHL_Mem15_Val
                jmp SHL_invalid
                SHL_Mem15_Reg:
                    cmp selectedOp2Reg,7
                    jne SHL_invalid
                    mov cx,ValRegCX
                    clc
                    SHL ValMem[15],cl
                    call SetCarryFlag
                    jmp Exit
                SHL_Mem15_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    mov cx,Op2Val
                    clc
                    SHL ValMem[15],cl
                    call SetCarryFlag
                    jmp Exit
        SHL_invalid:
        jmp InValidCommand
        JMP Exit
    
    SHR_Comm:
        CALL Op1Menu
        MOV DX, CommaCursorLoc
        CALL SetCursor
        mov dl, ','
        CALL DisplayChar
        CALL Op2Menu

        call  PowerUpeMenu ; to choose power up
        CALL CheckForbidCharProc

        cmp selectedOp1Type,0
        je SHR_Reg
        cmp selectedOp1Type,1
        je SHR_AddReg
        cmp selectedOp1Type,2
        je SHR_Mem
        cmp selectedOp1Type,3
        je SHR_invalid

        SHR_Reg:
            cmp selectedOp1Reg,0
            je SHR_Ax
            cmp selectedOp1Reg,1
            je SHR_Al
            cmp selectedOp1Reg,2
            je SHR_Ah
            cmp selectedOp1Reg,3
            je SHR_bx
            cmp selectedOp1Reg,4
            je SHR_Bl
            cmp selectedOp1Reg,5
            je SHR_Bh
            cmp selectedOp1Reg,6
            je SHR_Cx
            cmp selectedOp1Reg,7
            je SHR_Cl
            cmp selectedOp1Reg,8
            je SHR_Ch
            cmp selectedOp1Reg,9
            je SHR_Dx
            cmp selectedOp1Reg,10
            je SHR_Dl
            cmp selectedOp1Reg,11
            je SHR_Dh
            cmp selectedOp1Reg,15
            je SHR_Bp
            cmp selectedOp1Reg,16
            je SHR_Sp
            cmp selectedOp1Reg,17
            je SHR_Si
            cmp selectedOp1Reg,18
            je SHR_Di
            jmp SHR_invalid
            SHR_Ax:
                cmp selectedOp2Type,0
                je SHR_Ax_Reg
                cmp selectedOp2Type,3
                je SHR_Ax_Val
                jmp SHR_invalid
                SHR_Ax_Reg:
                    cmp selectedOp2Reg,7
                    jne SHR_invalid
                    mov ax,ValRegAX
                    mov cx,ValRegCX
                    clc
                    SHR Ax,cl
                    mov ValRegAX,ax
                    call SetCarryFlag
                    jmp Exit
                SHR_Ax_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    mov ax,ValRegAX
                    mov cx,Op2Val
                    clc
                    SHR ax,cl
                    mov ValRegAX,ax
                    call SetCarryFlag
                    jmp Exit
            SHR_Al:
                cmp selectedOp2Type,0
                je SHR_Al_Reg
                cmp selectedOp2Type,3
                je SHR_Al_Val
                jmp SHR_invalid
                SHR_Al_Reg:
                    cmp selectedOp2Reg,7
                    jne SHR_invalid
                    mov ax,ValRegAX
                    mov cx,ValRegCX
                    clc
                    SHR Al,cl
                    mov ValRegAX,ax
                    call SetCarryFlag
                    jmp Exit
                SHR_Al_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    mov ax,ValRegAX
                    mov cx,Op2Val
                    clc
                    SHR al,cl
                    mov ValRegAX,ax
                    call SetCarryFlag
                    jmp Exit
            SHR_Ah:
                cmp selectedOp2Type,0
                je SHR_Ah_Reg
                cmp selectedOp2Type,3
                je SHR_Ah_Val
                jmp SHR_invalid
                SHR_Ah_Reg:
                    cmp selectedOp2Reg,7
                    jne SHR_invalid
                    mov ax,ValRegAX
                    mov cx,ValRegCX
                    clc
                    SHR Ah,cl
                    mov ValRegAX,ax
                    call SetCarryFlag
                    jmp Exit
                SHR_Ah_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    mov ax,ValRegAX
                    mov cx,Op2Val
                    clc
                    SHR ah,cl
                    mov ValRegAX,ax
                    call SetCarryFlag
                    jmp Exit
            SHR_Bx:
                cmp selectedOp2Type,0
                je SHR_Bx_Reg
                cmp selectedOp2Type,3
                je SHR_Bx_Val
                jmp SHR_invalid
                SHR_Bx_Reg:
                    cmp selectedOp2Reg,7
                    jne SHR_invalid
                    mov Bx,ValRegBX
                    mov cx,ValRegCX
                    clc
                    SHR Bx,cl
                    mov ValRegBX,Bx
                    call SetCarryFlag
                    jmp Exit
                SHR_Bx_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    mov Bx,ValRegBX
                    mov cx,Op2Val
                    clc
                    SHR Bx,cl
                    mov ValRegBX,Bx
                    call SetCarryFlag
                    jmp Exit
            SHR_Bl:
                cmp selectedOp2Type,0
                je SHR_Bl_Reg
                cmp selectedOp2Type,3
                je SHR_Bl_Val
                jmp SHR_invalid
                SHR_Bl_Reg:
                    cmp selectedOp2Reg,7
                    jne SHR_invalid
                    mov Bx,ValRegBX
                    mov cx,ValRegCX
                    clc
                    SHR Bl,cl
                    mov ValRegBX,Bx
                    call SetCarryFlag
                    jmp Exit
                SHR_Bl_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    mov Bx,ValRegBX
                    mov cx,Op2Val
                    clc
                    SHR Bl,cl
                    mov ValRegBX,Bx
                    call SetCarryFlag
                    jmp Exit
            SHR_Bh:
                cmp selectedOp2Type,0
                je SHR_Bh_Reg
                cmp selectedOp2Type,3
                je SHR_Bh_Val
                jmp SHR_invalid
                SHR_Bh_Reg:
                    cmp selectedOp2Reg,7
                    jne SHR_invalid
                    mov Bx,ValRegBX
                    mov cx,ValRegCX
                    clc
                    SHR Bh,cl
                    mov ValRegBX,Bx
                    call SetCarryFlag
                    jmp Exit
                SHR_Bh_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    mov Bx,ValRegBX
                    mov cx,Op2Val
                    clc
                    SHR Bh,cl
                    mov ValRegBX,Bx
                    call SetCarryFlag
                    jmp Exit
            SHR_Cx:
                cmp selectedOp2Type,0
                je SHR_Cx_Reg
                cmp selectedOp2Type,3
                je SHR_Cx_Val
                jmp SHR_invalid
                SHR_Cx_Reg:
                    cmp selectedOp2Reg,7
                    jne SHR_invalid
                    mov Cx,ValRegCx
                    mov cx,ValRegCX
                    clc
                    SHR Cx,cl
                    mov ValRegCx,Cx
                    call SetCarryFlag
                    jmp Exit
                SHR_Cx_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    mov bx,ValRegCx
                    mov cx,Op2Val
                    clc
                    SHR bx,cl
                    mov ValRegCx,bx
                    call SetCarryFlag
                    jmp Exit
            SHR_Cl:
                cmp selectedOp2Type,0
                je SHR_Cl_Reg
                cmp selectedOp2Type,3
                je SHR_Cl_Val
                jmp SHR_invalid
                SHR_Cl_Reg:
                    cmp selectedOp2Reg,7
                    jne SHR_invalid
                    mov cx,ValRegCX
                    clc
                    SHR Cl,cl
                    mov ValRegCX,Cx
                    call SetCarryFlag
                    jmp Exit
                SHR_Cl_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    mov Bx,ValRegCX
                    mov cx,Op2Val
                    clc
                    SHR Bl,cl
                    mov ValRegCX,Bx
                    call SetCarryFlag
                    jmp Exit
            SHR_Ch:
                cmp selectedOp2Type,0
                je SHR_Ch_Reg
                cmp selectedOp2Type,3
                je SHR_Ch_Val
                jmp SHR_invalid
                SHR_Ch_Reg:
                    cmp selectedOp2Reg,7
                    jne SHR_invalid
                    mov cx,ValRegCX
                    clc
                    SHR Ch,cl
                    mov ValRegCX,Cx
                    call SetCarryFlag
                    jmp Exit
                SHR_Ch_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    mov Bx,ValRegCX
                    mov cx,Op2Val
                    clc
                    SHR bh,cl
                    mov ValRegCX,Bx
                    call SetCarryFlag
                    jmp Exit
            SHR_Dx:
                cmp selectedOp2Type,0
                je SHR_Dx_Reg
                cmp selectedOp2Type,3
                je SHR_Dx_Val
                jmp SHR_invalid
                SHR_Dx_Reg:
                    cmp selectedOp2Reg,7
                    jne SHR_invalid
                    mov Dx,ValRegDX
                    mov cx,ValRegCX
                    clc
                    SHR Dx,cl
                    mov ValRegDX,Dx
                    call SetCarryFlag
                    jmp Exit
                SHR_Dx_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    mov Dx,ValRegDX
                    mov cx,Op2Val
                    clc
                    SHR Dx,cl
                    mov ValRegDX,Dx
                    call SetCarryFlag
                    jmp Exit
            SHR_Dl:
                cmp selectedOp2Type,0
                je SHR_Dl_Reg
                cmp selectedOp2Type,3
                je SHR_Dl_Val
                jmp SHR_invalid
                SHR_Dl_Reg:
                    cmp selectedOp2Reg,7
                    jne SHR_invalid
                    mov Dx,ValRegDX
                    mov cx,ValRegCX
                    clc
                    SHR Dl,cl
                    mov ValRegDX,Dx
                    call SetCarryFlag
                    jmp Exit
                SHR_Dl_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    mov Dx,ValRegDX
                    mov cx,Op2Val
                    clc
                    SHR Dl,cl
                    mov ValRegDX,Dx
                    call SetCarryFlag
                    jmp Exit
            SHR_Dh:
                cmp selectedOp2Type,0
                je SHR_Dh_Reg
                cmp selectedOp2Type,3
                je SHR_Dh_Val
                jmp SHR_invalid
                SHR_Dh_Reg:
                    cmp selectedOp2Reg,7
                    jne SHR_invalid
                    mov Dx,ValRegDX
                    mov cx,ValRegCX
                    clc
                    SHR Dh,cl
                    mov ValRegDX,Dx
                    call SetCarryFlag
                    jmp Exit
                SHR_Dh_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    mov Dx,ValRegDX
                    mov cx,Op2Val
                    clc
                    SHR Dh,cl
                    mov ValRegDX,Dx
                    call SetCarryFlag
                    jmp Exit
            SHR_Bp:
                cmp selectedOp2Type,0
                je SHR_Bp_Reg
                cmp selectedOp2Type,3
                je SHR_Bp_Val
                jmp SHR_invalid
                SHR_Bp_Reg:
                    cmp selectedOp2Reg,7
                    jne SHR_invalid
                    mov Bp,ValRegBP
                    mov cx,ValRegCX
                    clc
                    SHR BP,cl
                    mov ValRegBP,BP
                    call SetCarryFlag
                    jmp Exit
                SHR_BP_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    mov BP,ValRegBP
                    mov cx,Op2Val
                    clc
                    SHR BP,cl
                    mov ValRegBP,BP
                    call SetCarryFlag
                    jmp Exit
            SHR_Sp:
                cmp selectedOp2Type,0
                je SHR_SP_Reg
                cmp selectedOp2Type,3
                je SHR_SP_Val
                jmp SHR_invalid
                SHR_SP_Reg:
                    cmp selectedOp2Reg,7
                    jne SHR_invalid
                    mov SP,ValRegSP
                    mov cx,ValRegCX
                    clc
                    SHR SP,cl
                    mov ValRegSP,SP
                    call SetCarryFlag
                    jmp Exit
                SHR_SP_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    mov SP,ValRegSP
                    mov cx,Op2Val
                    clc
                    SHR SP,cl
                    mov ValRegSP,SP
                    call SetCarryFlag
                    jmp Exit
            SHR_Si:
                cmp selectedOp2Type,0
                je SHR_SI_Reg
                cmp selectedOp2Type,3
                je SHR_SI_Val
                jmp SHR_invalid
                SHR_SI_Reg:
                    cmp selectedOp2Reg,7
                    jne SHR_invalid
                    mov SI,ValRegSI
                    mov cx,ValRegCX
                    clc
                    SHR SI,cl
                    mov ValRegSI,SI
                    call SetCarryFlag
                    jmp Exit
                SHR_SI_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    mov SI,ValRegSI
                    mov cx,Op2Val
                    clc
                    SHR SI,cl
                    mov ValRegSI,SI
                    call SetCarryFlag
                    jmp Exit
            SHR_Di:
                cmp selectedOp2Type,0
                je SHR_DI_Reg
                cmp selectedOp2Type,3
                je SHR_DI_Val
                jmp SHR_invalid
                SHR_DI_Reg:
                    cmp selectedOp2Reg,7
                    jne SHR_invalid
                    mov DI,ValRegDI
                    mov cx,ValRegCX
                    clc
                    SHR DI,cl
                    mov ValRegDI,DI
                    call SetCarryFlag
                    jmp Exit
                SHR_DI_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    mov DI,ValRegDI
                    mov cx,Op2Val
                    clc
                    SHR DI,cl
                    mov ValRegDI,DI
                    call SetCarryFlag
                    jmp Exit
        SHR_AddReg:
            cmp selectedOp1AddReg,3
            je SHR_AddBx
            cmp selectedOp1AddReg,15
            je SHR_AddBp
            cmp selectedOp1AddReg,17
            je SHR_AddSi
            cmp selectedOp1AddReg,18
            je SHR_AddDi
            jmp SHR_invalid
            SHR_AddBx:
                cmp selectedOp2Type,0
                je SHR_AddBx_Reg
                cmp selectedOp2Type,3
                je SHR_AddBx_Val
                jmp SHR_invalid
                SHR_AddBx_Reg:
                    cmp selectedOp2Reg,7
                    jne SHR_invalid
                    mov Bx,ValRegBX
                    cmp Bx,15d
                    ja SHR_invalid
                    mov cx,ValRegCX
                    clc
                    SHR ValMem[Bx],cl
                    mov ValRegBX,Bx
                    call SetCarryFlag
                    jmp Exit
                SHR_AddBx_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    mov Bx,ValRegBX
                    cmp Bx,15d
                    ja SHR_invalid
                    mov cx,Op2Val
                    clc
                    SHR ValMem[Bx],cl
                    mov ValRegBX,Bx
                    call SetCarryFlag
                    jmp Exit
            SHR_AddBp:
                cmp selectedOp2Type,0
                je SHR_AddBP_Reg
                cmp selectedOp2Type,3
                je SHR_AddBP_Val
                jmp SHR_invalid
                SHR_AddBP_Reg:
                    cmp selectedOp2Reg,7
                    jne SHR_invalid
                    mov BP,ValRegBP
                    cmp BP,15d
                    ja SHR_invalid
                    mov cx,ValRegCX
                    clc
                    SHR ValMem[BP],cl
                    mov ValRegBP,BP
                    call SetCarryFlag
                    jmp Exit
                SHR_AddBP_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    mov BP,ValRegBP
                    cmp BP,15d
                    ja SHR_invalid
                    mov cx,Op2Val
                    clc
                    SHR ValMem[BP],cl
                    mov ValRegBP,BP
                    call SetCarryFlag
                    jmp Exit
            SHR_AddSi:
                cmp selectedOp2Type,0
                je SHR_AddSi_Reg
                cmp selectedOp2Type,3
                je SHR_AddSi_Val
                jmp SHR_invalid
                SHR_AddSi_Reg:
                    cmp selectedOp2Reg,7
                    jne SHR_invalid
                    mov Si,ValRegSI
                    cmp Si,15d
                    ja SHR_invalid
                    mov cx,ValRegCX
                    clc
                    SHR ValMem[Si],cl
                    mov ValRegSI,Si
                    call SetCarryFlag
                    jmp Exit
                SHR_AddSi_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    mov Si,ValRegSI
                    cmp Si,15d
                    ja SHR_invalid
                    mov cx,Op2Val
                    clc
                    SHR ValMem[Si],cl
                    mov ValRegSI,Si
                    call SetCarryFlag
                    jmp Exit
            SHR_AddDi:
                cmp selectedOp2Type,0
                je SHR_AddDI_Reg
                cmp selectedOp2Type,3
                je SHR_AddDI_Val
                jmp SHR_invalid
                SHR_AddDI_Reg:
                    cmp selectedOp2Reg,7
                    jne SHR_invalid
                    mov DI,ValRegDI
                    cmp DI,15d
                    ja SHR_invalid
                    mov cx,ValRegCX
                    clc
                    SHR ValMem[DI],cl
                    mov ValRegDI,DI
                    call SetCarryFlag
                    jmp Exit
                SHR_AddDI_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    mov DI,ValRegDI
                    cmp DI,15d
                    ja SHR_invalid
                    mov cx,Op2Val
                    clc
                    SHR ValMem[DI],cl
                    mov ValRegDI,DI
                    call SetCarryFlag
                    jmp Exit
        SHR_Mem:
            cmp selectedOp1Mem,0
            je SHR_Mem0
            cmp selectedOp1Mem,1
            je SHR_Mem1
            cmp selectedOp1Mem,2
            je SHR_Mem2
            cmp selectedOp1Mem,3
            je SHR_Mem3
            cmp selectedOp1Mem,4
            je SHR_Mem4
            cmp selectedOp1Mem,5
            je SHR_Mem5
            cmp selectedOp1Mem,6
            je SHR_Mem6
            cmp selectedOp1Mem,7
            je SHR_Mem7
            cmp selectedOp1Mem,8
            je SHR_Mem8
            cmp selectedOp1Mem,9
            je SHR_Mem9
            cmp selectedOp1Mem,10
            je SHR_Mem10
            cmp selectedOp1Mem,11
            je SHR_Mem11
            cmp selectedOp1Mem,12
            je SHR_Mem12
            cmp selectedOp1Mem,13
            je SHR_Mem13
            cmp selectedOp1Mem,14
            je SHR_Mem14
            cmp selectedOp1Mem,15
            je SHR_Mem15
            jmp SHR_invalid
            SHR_Mem0:
                cmp selectedOp2Type,0
                je SHR_Mem0_Reg
                cmp selectedOp2Type,3
                je SHR_Mem0_Val
                jmp SHR_invalid
                SHR_Mem0_Reg:
                    cmp selectedOp2Reg,7
                    jne SHR_invalid
                    mov cx,ValRegCX
                    clc
                    SHR ValMem[0],cl
                    call SetCarryFlag
                    jmp Exit
                SHR_Mem0_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    mov cx,Op2Val
                    clc
                    SHR ValMem[0],cl
                    call SetCarryFlag
                    jmp Exit
            SHR_Mem1:
                cmp selectedOp2Type,0
                je SHR_Mem1_Reg
                cmp selectedOp2Type,3
                je SHR_Mem1_Val
                jmp SHR_invalid
                SHR_Mem1_Reg:
                    cmp selectedOp2Reg,7
                    jne SHR_invalid
                    mov cx,ValRegCX
                    clc
                    SHR ValMem[1],cl
                    call SetCarryFlag
                    jmp Exit
                SHR_Mem1_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    mov cx,Op2Val
                    clc
                    SHR ValMem[1],cl
                    call SetCarryFlag
                    jmp Exit
            SHR_Mem2:
                cmp selectedOp2Type,0
                je SHR_Mem2_Reg
                cmp selectedOp2Type,3
                je SHR_Mem2_Val
                jmp SHR_invalid
                SHR_Mem2_Reg:
                    cmp selectedOp2Reg,7
                    jne SHR_invalid
                    mov cx,ValRegCX
                    clc
                    SHR ValMem[2],cl
                    call SetCarryFlag
                    jmp Exit
                SHR_Mem2_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    mov cx,Op2Val
                    clc
                    SHR ValMem[2],cl
                    call SetCarryFlag
                    jmp Exit
            SHR_Mem3:
                cmp selectedOp2Type,0
                je SHR_Mem3_Reg
                cmp selectedOp2Type,3
                je SHR_Mem3_Val
                jmp SHR_invalid
                SHR_Mem3_Reg:
                    cmp selectedOp2Reg,7
                    jne SHR_invalid
                    mov cx,ValRegCX
                    clc
                    SHR ValMem[3],cl
                    call SetCarryFlag
                    jmp Exit
                SHR_Mem3_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    mov cx,Op2Val
                    clc
                    SHR ValMem[3],cl
                    call SetCarryFlag
                    jmp Exit
            SHR_Mem4:
                cmp selectedOp2Type,0
                je SHR_Mem4_Reg
                cmp selectedOp2Type,3
                je SHR_Mem4_Val
                jmp SHR_invalid
                SHR_Mem4_Reg:
                    cmp selectedOp2Reg,7
                    jne SHR_invalid
                    mov cx,ValRegCX
                    clc
                    SHR ValMem[4],cl
                    call SetCarryFlag
                    jmp Exit
                SHR_Mem4_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    mov cx,Op2Val
                    clc
                    SHR ValMem[4],cl
                    call SetCarryFlag
                    jmp Exit
            SHR_Mem5:
                cmp selectedOp2Type,0
                je SHR_Mem5_Reg
                cmp selectedOp2Type,3
                je SHR_Mem5_Val
                jmp SHR_invalid
                SHR_Mem5_Reg:
                    cmp selectedOp2Reg,7
                    jne SHR_invalid
                    mov cx,ValRegCX
                    clc
                    SHR ValMem[5],cl
                    call SetCarryFlag
                    jmp Exit
                SHR_Mem5_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    mov cx,Op2Val
                    clc
                    SHR ValMem[5],cl
                    call SetCarryFlag
                    jmp Exit
            SHR_Mem6:
                cmp selectedOp2Type,0
                je SHR_Mem6_Reg
                cmp selectedOp2Type,3
                je SHR_Mem6_Val
                jmp SHR_invalid
                SHR_Mem6_Reg:
                    cmp selectedOp2Reg,7
                    jne SHR_invalid
                    mov cx,ValRegCX
                    clc
                    SHR ValMem[6],cl
                    call SetCarryFlag
                    jmp Exit
                SHR_Mem6_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    mov cx,Op2Val
                    clc
                    SHR ValMem[6],cl
                    call SetCarryFlag
                    jmp Exit
            SHR_Mem7:
                cmp selectedOp2Type,0
                je SHR_Mem7_Reg
                cmp selectedOp2Type,3
                je SHR_Mem7_Val
                jmp SHR_invalid
                SHR_Mem7_Reg:
                    cmp selectedOp2Reg,7
                    jne SHR_invalid
                    mov cx,ValRegCX
                    clc
                    SHR ValMem[7],cl
                    call SetCarryFlag
                    jmp Exit
                SHR_Mem7_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    mov cx,Op2Val
                    clc
                    SHR ValMem[7],cl
                    call SetCarryFlag
                    jmp Exit
            SHR_Mem8:
                cmp selectedOp2Type,0
                je SHR_Mem8_Reg
                cmp selectedOp2Type,3
                je SHR_Mem8_Val
                jmp SHR_invalid
                SHR_Mem8_Reg:
                    cmp selectedOp2Reg,7
                    jne SHR_invalid
                    mov cx,ValRegCX
                    clc
                    SHR ValMem[8],cl
                    call SetCarryFlag
                    jmp Exit
                SHR_Mem8_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    mov cx,Op2Val
                    clc
                    SHR ValMem[8],cl
                    call SetCarryFlag
                    jmp Exit
            SHR_Mem9:
                cmp selectedOp2Type,0
                je SHR_Mem9_Reg
                cmp selectedOp2Type,3
                je SHR_Mem9_Val
                jmp SHR_invalid
                SHR_Mem9_Reg:
                    cmp selectedOp2Reg,7
                    jne SHR_invalid
                    mov cx,ValRegCX
                    clc
                    SHR ValMem[9],cl
                    call SetCarryFlag
                    jmp Exit
                SHR_Mem9_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    mov cx,Op2Val
                    clc
                    SHR ValMem[9],cl
                    call SetCarryFlag
                    jmp Exit
            SHR_Mem10:
                cmp selectedOp2Type,0
                je SHR_Mem10_Reg
                cmp selectedOp2Type,3
                je SHR_Mem10_Val
                jmp SHR_invalid
                SHR_Mem10_Reg:
                    cmp selectedOp2Reg,7
                    jne SHR_invalid
                    mov cx,ValRegCX
                    clc
                    SHR ValMem[10],cl
                    call SetCarryFlag
                    jmp Exit
                SHR_Mem10_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    mov cx,Op2Val
                    clc
                    SHR ValMem[10],cl
                    call SetCarryFlag
                    jmp Exit
            SHR_Mem11:
                cmp selectedOp2Type,0
                je SHR_Mem11_Reg
                cmp selectedOp2Type,3
                je SHR_Mem11_Val
                jmp SHR_invalid
                SHR_Mem11_Reg:
                    cmp selectedOp2Reg,7
                    jne SHR_invalid
                    mov cx,ValRegCX
                    clc
                    SHR ValMem[11],cl
                    call SetCarryFlag
                    jmp Exit
                SHR_Mem11_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    mov cx,Op2Val
                    clc
                    SHR ValMem[11],cl
                    call SetCarryFlag
                    jmp Exit
            SHR_Mem12:
                cmp selectedOp2Type,0
                je SHR_Mem12_Reg
                cmp selectedOp2Type,3
                je SHR_Mem12_Val
                jmp SHR_invalid
                SHR_Mem12_Reg:
                    cmp selectedOp2Reg,7
                    jne SHR_invalid
                    mov cx,ValRegCX
                    clc
                    SHR ValMem[12],cl
                    call SetCarryFlag
                    jmp Exit
                SHR_Mem12_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    mov cx,Op2Val
                    clc
                    SHR ValMem[12],cl
                    call SetCarryFlag
                    jmp Exit
            SHR_Mem13:
                cmp selectedOp2Type,0
                je SHR_Mem13_Reg
                cmp selectedOp2Type,3
                je SHR_Mem13_Val
                jmp SHR_invalid
                SHR_Mem13_Reg:
                    cmp selectedOp2Reg,7
                    jne SHR_invalid
                    mov cx,ValRegCX
                    clc
                    SHR ValMem[13],cl
                    call SetCarryFlag
                    jmp Exit
                SHR_Mem13_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    mov cx,Op2Val
                    clc
                    SHR ValMem[13],cl
                    call SetCarryFlag
                    jmp Exit
            SHR_Mem14:
                cmp selectedOp2Type,0
                je SHR_Mem14_Reg
                cmp selectedOp2Type,3
                je SHR_Mem14_Val
                jmp SHR_invalid
                SHR_Mem14_Reg:
                    cmp selectedOp2Reg,7
                    jne SHR_invalid
                    mov cx,ValRegCX
                    clc
                    SHR ValMem[14],cl
                    call SetCarryFlag
                    jmp Exit
                SHR_Mem14_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    mov cx,Op2Val
                    clc
                    SHR ValMem[14],cl
                    call SetCarryFlag
                    jmp Exit
            SHR_Mem15:
                cmp selectedOp2Type,0
                je SHR_Mem15_Reg
                cmp selectedOp2Type,3
                je SHR_Mem15_Val
                jmp SHR_invalid
                SHR_Mem15_Reg:
                    cmp selectedOp2Reg,7
                    jne SHR_invalid
                    mov cx,ValRegCX
                    clc
                    SHR ValMem[15],cl
                    call SetCarryFlag
                    jmp Exit
                SHR_Mem15_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    mov cx,Op2Val
                    clc
                    SHR ValMem[15],cl
                    call SetCarryFlag
                    jmp Exit
        SHR_invalid:
        jmp InValidCommand
        JMP Exit
    
    TODO_Comm:
        mov dx, offset error
        CALL DisplayString
        JMP Exit
    
    InValidCommand:
        lea dx, ExecutionFailed
        CALL ShowMsg

        CheckKey_Invalid:
            CALL WaitKeyPress
        
        cmp ah, EnterScanCode
        jz CONT_INVALID
        cmp ah, RightScanCode
        jz MoveRight_Invalid
        cmp ah, LeftScanCode
        jz MoveLeft_Invalid
        cmp ah, 57
        jz DrawBullet_Invalid
        cmp ah, EscScanCode
        jz Exit_Invalid

        jmp CheckKey_Invalid

        DrawBullet_Invalid:
            Call DrawBullet
            JMP CheckKey_Invalid
        MoveLeft_Invalid:
            CALL MoveShooterLeft
            JMP CheckKey_Invalid
        MoveRight_Invalid:
            CALL MoveShooterRight
            JMP CheckKey_Invalid
        Exit_Invalid:
            Call Terminate
        CONT_INVALID:
            RET
        

        

    Exit:

            

        ; ----
        lea dx, ExecutedSuccesfully
        CALL ShowMsg

        CheckKey_Exit:
            CALL WaitKeyPress
        
        cmp ah, EnterScanCode
        jz CONT__Exit
        cmp ah, RightScanCode
        jz MoveRight__Exit
        cmp ah, LeftScanCode
        jz MoveLeft__Exit
        cmp ah, 57
        jz DrawBullet__Exit
        cmp ah, EscScanCode
        jz Exit__Exit

        jmp CheckKey_Exit

        DrawBullet__Exit:
            Call DrawBullet
            JMP CheckKey_Exit
        MoveLeft__Exit:
            CALL MoveShooterLeft
            JMP CheckKey_Exit
        MoveRight__Exit:
            CALL MoveShooterRight
            JMP CheckKey_Exit
        Exit__Exit:
            Call Terminate
        CONT__Exit:
            RET
        
        RET


CommMenu ENDP
;================================================================================================================
Terminate PROC FAR
    ; Return to dos
    mov ah,4ch
    int 21h

    ret
ENDP
SetCarryFlag PROC far
    ;This is used to set the carry flag of our processor
    push dx
    mov dx,0h
    adc dx,0h
    mov ValCF,dl
    pop dx
    ret
SetCarryFlag ENDP
GetCarryFlag PROC far
    ;This is used to get the carry flag of our processor
    push dx
    push bx
    mov dx,65535d
    mov bx,0h
    mov bl,ValCF
    add dx,bx
    pop bx
    pop dx
    ret
GetCarryFlag ENDP
ShowMsg PROC FAR
    push dx
        Set 21 0
    pop dx
    CALL DisplayString
    
    RET
ENDP
DisplayString PROC ; string offset saved in DX
    mov ah, 9
    int 21h

    RET
DisplayString ENDP
DisplayChar PROC    ; char is saved in dl
    mov ah,2
    int 21h

    RET
DisplayChar ENDP
SetCursor PROC ; position is saved in dx   
    mov ah,2
    int 10h

    ret
SetCursor ENDP
MnemonicMenu PROC

    ; Reset Cursor
        mov ah,2
        mov dx, MenmonicCursorLoc
        int 10h
    ; Display Command
    DisplayComm:
        mov ah, 9
        mov dx, offset MOVcom
        int 21h

    CheckKeyComType:
        CALL WaitKeyPress

    Push ax
    PUSH dx 
        ; Clear buffer
        mov ah,07
        int 21h
        ; Reset Cursor
        mov ah,2
        mov dx, MenmonicCursorLoc
        int 10h
    pop dx 
    pop ax

    ; Check if pressed is Up or down or Enter
    cmp ah, UpArrowScanCode                          
    jz CommUp 
    cmp ah, DownArrowScanCode
    jz CommDown
    cmp ah, EnterScanCode
    jz Selected
    cmp ah, RightScanCode
    jz MoveRight_MnemonicMenu
    cmp ah, LeftScanCode
    jz MoveLeft_MnemonicMenu
    cmp ah, 57
    jz DrawBullet_MnemonicMenu
    cmp ah, EscScanCode
    jz Exit__MnemonicMenu

    jmp CheckKeyComType

    DrawBullet_MnemonicMenu:
        Call DrawBullet
        JMP CheckKeyComType
    MoveLeft_MnemonicMenu:
        CALL MoveShooterLeft
        JMP CheckKeyComType
    MoveRight_MnemonicMenu:
        CALL MoveShooterRight
        JMP CheckKeyComType
    Exit__MnemonicMenu:
        Call Terminate


    CommUp:
        mov ah, 9
        ; Check overflow
            cmp dx, offset NOPcom            ; MenmonicFirstChoice
            jnz NotOverflow
            mov dx, offset SHRcom             ; MnemonicLastChoiceLoc
            add dx, CommStringSize
        NotOverflow:
            sub dx, CommStringSize
            int 21h
            jmp CheckKeyComType
    
    CommDown:
        mov ah, 9
        ; Check End of file
            cmp dx, offset SHRcom             ; MnemonicLastChoiceLoc
            jnz NotEOF
            mov dx, offset NOPcom            ; MenmonicFirstChoice
            sub dx, CommStringSize
        NotEOF:
            add dx, CommStringSize
            int 21h
            jmp CheckKeyComType
    
    Selected:
        ; Detecting index of selected command
        mov ax, dx
        sub ax, offset NOPcom            ; MenmonicFirstChoice
        mov bl, CommStringSize
        div bl                                      ; Op=byte: AL:=AX / Op
        mov selectedComm, al
        
        


    ret
MnemonicMenu ENDP
WaitKeyPress PROC ; AH:scancode,AL:ASCII
    ; Wait for a key pressed
    CHECK:
        push dx
            CALL DrawGuiLayout
            CALL DisplayGUIValues
            CALL DrawFlyingObj
            CALL DrawShooter
            
        pop dx

        mov ah,1
        int 16h
    jz CHECK

    ret
WaitKeyPress ENDP
CheckAddress proc     ; Value of register supposed to be in dx before calling the proc, if greater bl = 1 else bl = 0
    cmp dx, 16
    jg InValid
    mov bl, 0
    ret
    Invalid: 
    mov bl, 1
    ret
CheckAddress ENDP
CheckForbidChar PROC   ;offset of string checked is in di, bl = 1 if found
    mov al, Player1_ForbidChar
    MOV CX, CommStringSize
    REPNE SCASB
    CMP CX,0
    JZ NotFound
    mov bl, 1
    RET
    NotFound:
        mov bl,0 
    RET
ENDP
CheckForbidCharProc PROC            ; NEEDS TO Reset selectedOperands after each instruction execution
    ; Check in instruction
    mov Ah, 0
    mov AL, selectedComm
    mov BX, CommStringSize
    MUL BX
    add ax, offset NOPcom       ; First Choice in command
    CheckForbidCharMacro ax

    ; Check op1
    CheckForbidCharOp1:
        cmp selectedOp1Type, 0
        jz ForbidCharOp1Reg
        cmp selectedOp1Type, 1
        jz ForbidCharOp1AddReg
        cmp selectedOp1Type, 2
        jz ForbidCharOp1Mem
        cmp selectedOp1Type, 3
        jz ForbidCharOp1Val
        ret

        ForbidCharOp1Reg:
            mov Ah, 0
            mov AL, selectedOp1Reg
            mov bx, CommStringSize
            MUL bx
            add ax, offset RegAX
            CheckForbidCharMacro ax
            JMP CheckForbidCharOp2
        
        ForbidCharOp1AddReg:
            mov Ah, 0
            mov AL, selectedOp1AddReg
            mov bx, CommStringSize
            MUL bx
            add ax, offset AddRegAX
            CheckForbidCharMacro ax
            JMP CheckForbidCharOp2
        
        ForbidCharOp1Mem:
            MOV AH, 0
            mov AL, selectedOp1Mem
            mov bx, CommStringSize
            MUL bx
            add ax, offset Mem0
            CheckForbidCharMacro ax
            JMP CheckForbidCharOp2
        
        ForbidCharOp1Val:
            MOV AX, offset num 
            JMP CheckForbidCharOp2 

    CheckForbidCharOp2:
        cmp selectedOp2Type, 0
        jz ForbidCharOp2Reg
        cmp selectedOp2Type, 1
        jz ForbidCharOp2AddReg
        cmp selectedOp2Type, 2
        jz ForbidCharOp2Mem
        cmp selectedOp2Type, 3
        jz ForbidCharOp2Val
        ret

        ForbidCharOp2Reg:
            MOV AH, 0
            mov AL, selectedOp2Reg
            mov bx, CommStringSize
            MUL bx
            add ax, offset RegAX
            CheckForbidCharMacro ax
            RET
        
        ForbidCharOp2AddReg:
            MOV AH, 0
            mov AL, selectedOp2AddReg
            mov bx, CommStringSize
            MUL bx
            add ax, offset AddRegAX
            CheckForbidCharMacro ax
            RET
        
        ForbidCharOp2Mem:
            MOV AH, 0
            mov AL, selectedOp2Mem
            mov bx, CommStringSize
            MUL bx
            add ax, offset Mem0
            CheckForbidCharMacro ax
            RET
        
        ForbidCharOp2Val:
            MOV AX, offset num2
            RET


ENDP
Op1TypeMenu PROC

    mov ah, 9
    mov dx, offset Reg
    int 21h

    CheckKeyOp1Type:
        ; Clear buffer
        mov ah,07
        int 21h
        CALL WaitKeyPress

    Push ax
    PUSH dx 
        ; Clear buffer
        mov ah,07
        int 21h
        ; Reset Cursor
        mov ah,2
        mov dx, Op1CursorLoc
        int 10h
    pop dx 
    pop ax

    ; Check if pressed is Up or down or Enter
    cmp ah, UpArrowScanCode                          
    jz CommUp_1 
    cmp ah, DownArrowScanCode
    jz CommDown_1
    cmp ah, EnterScanCode
    jz Selected_1
    cmp ah, RightScanCode
    jz MoveRight_Op1TypeMenu
    cmp ah, LeftScanCode
    jz MoveLeft_Op1TypeMenu
    cmp ah, 57
    jz DrawBullet_Op1TypeMenu
    cmp ah, EscScanCode
    jz Exit_Op1TypeMenu

    jmp CheckKeyOp1Type

    DrawBullet_Op1TypeMenu:
        Call DrawBullet
        JMP CheckKeyOp1Type
    MoveLeft_Op1TypeMenu:
        CALL MoveShooterLeft
        JMP CheckKeyOp1Type
    MoveRight_Op1TypeMenu:
        CALL MoveShooterRight
        JMP CheckKeyOp1Type
    Exit_Op1TypeMenu:
        CALL Terminate
    


    CommUp_1:
        mov ah, 9
        ; Check overflow
            cmp dx, offset Reg
            jnz NotOverflow_1
            mov dx, offset Value           ; Op1TypeLastChoiceLoc
            add dx, CommStringSize
        NotOverflow_1:
            sub dx, CommStringSize
            int 21h
            jmp CheckKeyOp1Type
    
    CommDown_1:
        mov ah, 9
        ; Check End of file
            cmp dx, offset Value           ; Op1TypeLastChoiceLoc
            jnz NotEOF_1
            mov dx, offset Reg
            sub dx, CommStringSize
        NotEOF_1:
            add dx, CommStringSize
            int 21h
            jmp CheckKeyOp1Type
    
    Selected_1:
        ; Detecting index of selected command
        mov ax, dx
        sub ax, offset Reg         ; Op1FirstChoiceLoc
        mov bl, CommStringSize
        div bl                                      ; Op=byte: AL:=AX / Op 
        mov selectedOp1Type, al
        
    ret
Op1TypeMenu ENDP
PowerUpeMenu PROC
    ; Reset Cursor
        mov ah,2
        mov dx, PUPCursorLoc
        int 10h
        
    mov ah, 9
    mov dx, offset NOPUP
    int 21h

    CheckKeyOp1Type2:
        ; Clear buffer
        mov ah,07
        int 21h
        CALL WaitKeyPress

    Push ax
    PUSH dx 
        ; Clear buffer
        mov ah,07
        int 21h
        ; Reset Cursor
        mov ah,2
        mov dx, PUPCursorLoc
        int 10h
    pop dx 
    pop ax

    ; Check if pressed is Up or down or Enter
    cmp ah, UpArrowScanCode                          
    jz CommUp_2 
    cmp ah, DownArrowScanCode
    jz CommDown_2
    cmp ah, EnterScanCode
    jz Selected_2
    JMP CheckKeyOp1Type


    CommUp_2:
        mov ah, 9
        ; Check overflow
            cmp dx, offset NOPUP          ;Power Up firstChoiceLoc
            jnz NotOverflow_2
            mov dx, offset PUp5           ; Power Up LastChoiceLoc
            add dx, CommStringSize
        NotOverflow_2:
            sub dx, CommStringSize
            int 21h
            jmp CheckKeyOp1Type2
    
    CommDown_2:
        mov ah, 9
        ; Check End of file
            cmp dx, offset PUp5          ; Power Up LastChoiceLoc
            jnz NotEOF_2
            mov dx, offset NOPUP
            sub dx, CommStringSize
        NotEOF_2:
            add dx, CommStringSize
            int 21h
            jmp CheckKeyOp1Type2
    
    Selected_2:
        ; Detecting index of selected command
        mov ax, dx
        sub ax, offset NOPUP         ; Op1FirstChoiceLoc
        mov bl, CommStringSize
        div bl                                      ; Op=byte: AL:=AX / Op 
        mov selectedPUPType, al
        
    ret
PowerUpeMenu ENDP
ExecutePwrUp PROC FAR
    ForPwrUp:
                cmp selectedPUPType,3 ;Changing the forbidden character only once 
                jne notthispower3  ;-8 points 
                
                cmp UsedBeforeOrNot,1
                jne notthispower3
                dec UsedBeforeOrNot

                ; Reset Cursor
                mov ah,2
                mov dx, ForbidPUPCursor
                int 10h

                mov ah,1 ; set forbidchar
                int 21h
                mov Player1_ForbidChar,al 

                sub Player1_Points,8
                    notthispower3:
                    cmp selectedPUPType,5 ;Making one of the data lines stuck at 0 or 1
                    jne notthispower5
                    mov ValRegAX,0
                    mov ValRegBX,0
                    mov ValRegCX,0
                    mov ValRegDX,0 
                
                    mov ValRegBP,0
                    mov ValRegSP,0
                    mov ValRegSI,0
                    mov ValRegDI,0
                
                    mov ourValRegAX,0
                    mov ourValRegBX,0
                    mov ourValRegCX,0
                    mov ourValRegDX,0
                
                    mov ourValRegBP,0
                    mov ourValRegSP,0
                    mov ourValRegSI,0
                    mov ourValRegDI,0

                    sub Player1_Points,30
                    notthispower5:

    RET
ENDP
LineStuckPwrUp PROC     ; Value to be stucked is saved in AX/AL
    PUSH BX
    
    CMP PwrUpStuckVal, 0
    JZ PwrUpZero
    CMP PwrUpStuckVal, 1
    JZ PwrupOne
    JMP Return_LineStuckPwrUp

    PwrUpZero:
        MOV BX, 0FFFEH
        MOV CL, PwrUpDataLineIndex
        ROL BX, CL
        AND AX, BX
        JMP Return_LineStuckPwrUp
    PwrupOne:
        MOV BX, 1
        MOV CL, PwrUpDataLineIndex
        ROL BX, CL
        OR AX, BX

    Return_LineStuckPwrUp:
        POP BX
        RET
ENDP
Op2TypeMenu PROC

    
    mov ah, 9
    mov dx, offset Reg
    int 21h

    CheckKey_Op2Type:
        ; Clear buffer
        mov ah,07
        int 21h
        CALL WaitKeyPress

    Push ax
    PUSH dx 
        ; Clear buffer
        mov ah,07
        int 21h
        ; Reset Cursor
        mov ah,2
        mov dx, Op2CursorLoc
        int 10h
    pop dx 
    pop ax

    ; Check if pressed is Up or down or Enter
    cmp ah, UpArrowScanCode                          
    jz CommUp_Op2Type
    cmp ah, DownArrowScanCode
    jz CommDown_Op2Type
    cmp ah, EnterScanCode
    jz Selected_Op2Type
    cmp ah, RightScanCode
    jz MoveRight_Op2Type
    cmp ah, LeftScanCode
    jz MoveLeft_Op2Type
    cmp ah, 57
    jz DrawBullet_Op2Type
    cmp ah, EscScanCode
    jz Exit_Op2Type

    jmp CheckKey_Op2Type

    DrawBullet_Op2Type:
        Call DrawBullet
        JMP CheckKey_Op2Type
    MoveLeft_Op2Type:
        CALL MoveShooterLeft
        JMP CheckKey_Op2Type
    MoveRight_Op2Type:
        CALL MoveShooterRight
        JMP CheckKey_Op2Type
    Exit_Op2Type:
        CALL Terminate

    CommUp_Op2Type:
        mov ah, 9
        ; Check overflow
            cmp dx, offset Reg
            jnz NotOverflow_Op2Type
            mov dx, offset Value           ; OpTypeLastChoiceLoc
            add dx, CommStringSize
        NotOverflow_Op2Type:
            sub dx, CommStringSize
            int 21h
            jmp CheckKey_Op2Type
    
    CommDown_Op2Type:
        mov ah, 9
        ; Check End of file
            cmp dx, offset Value           ; OpTypeLastChoiceLoc
            jnz NotEOF_Op2Type
            mov dx, offset Reg
            sub dx, CommStringSize
        NotEOF_Op2Type:
            add dx, CommStringSize
            int 21h
            jmp CheckKey_Op2Type
    
    Selected_Op2Type:
        ; Detecting index of selected command
        mov ax, dx
        sub ax, offset Reg         ; OpTypeFirstChoiceLoc
        mov bl, CommStringSize
        div bl                                      ; Op=byte: AL:=AX / Op 
        mov selectedOp2Type, al
        
    ret
Op2TypeMenu ENDP
Op1Menu PROC

    ; Set Cursor
    mov ah,2
    mov dx, Op1CursorLoc 
    int 10h

    CALL Op1TypeMenu

    ; Set Cursor
    mov ah,2
    mov dx, Op1CursorLoc 
    int 10h


    CMP selectedOp1Type, RegIndex     
    JZ ChooseReg
    CMP selectedOp1Type, AddRegIndex
    JZ ChooseAddReg
    CMP selectedOp1Type, MemIndex
    JZ ChooseMem
    CMP selectedOp1Type, ValIndex
    JZ EnterVal
    
    jmp InvalidOp1Type

    ChooseReg: 

        ; Display Command
        mov ah, 9
        mov dx, offset RegAX
        int 21h

        CheckKeyRegType:
            ; Clear buffer
            mov ah,07
            int 21h
            CALL WaitKeyPress


        Push ax
        PUSH dx 
            ; Clear buffer
            mov ah,07
            int 21h
            ; Reset Cursor
            mov ah,2
            mov dx, Op1CursorLoc
            int 10h
        pop dx 
        pop ax

        ; Check if pressed is Up or down or Enter
        cmp ah, UpArrowScanCode                          
        jz CommUp2 
        cmp ah, DownArrowScanCode
        jz CommDown2
        cmp ah, EnterScanCode
        jz Selected2
        cmp ah, RightScanCode
        jz MoveRight_Op1RegType
        cmp ah, LeftScanCode
        jz MoveLeft_Op1RegType
        cmp ah, 57
        jz DrawBullet_Op1RegType
        CMP AH, EscScanCode
        JZ Exit_Op1RegType

        jmp CheckKeyRegType

        DrawBullet_Op1RegType:
            Call DrawBullet
            jmp CheckKeyRegType
        MoveLeft_Op1RegType:
            CALL MoveShooterLeft
            jmp CheckKeyRegType
        MoveRight_Op1RegType:
            CALL MoveShooterRight
            jmp CheckKeyRegType
        Exit_Op1RegType:
            CALL Terminate


        CommUp2:
            mov ah, 9
            ; Check overflow
                cmp dx, offset RegAX              ; RegFirstChoiceLocation ; the start of combobox
                jnz NotOverflow2
                mov dx, offset RegDI              ; RegLastChoiceLocation ; last one to overcome overflow
                add dx, CommStringSize
            NotOverflow2:
                sub dx, CommStringSize
                int 21h
                jmp CheckKeyRegType
        
        CommDown2:
            mov ah, 9
            ; Check End of file
                cmp dx, offset RegDI              ; RegLastChoiceLocation
                jnz NotEOF2
                mov dx, offset RegAX              ; RegFirstChoiceLocation
                sub dx, CommStringSize
            NotEOF2:
                add dx, CommStringSize
                int 21h
                jmp CheckKeyRegType
        
        Selected2:
            ; Detecting index of selected command
            mov ax, dx
            SUB AX, offset RegAX              ; RegFirstChoiceLocation
            mov bl, CommStringSize
            div bl                                      ; Op=byte: AL:=AX / Op 
            mov selectedOp1Reg, al
            ; NEEDS TO ADD A RETURN OR ENDING JUMP HERE
            JMP RETURN

    ChooseAddReg:

        ; Display Command
        mov ah, 9
        mov dx, offset AddRegAX
        int 21h

        CheckKey_AddReg:
            ; Clear buffer
            mov ah,07
            int 21h
            CALL WaitKeyPress


        Push ax
        PUSH dx 
            ; Clear buffer
            mov ah,07
            int 21h
            ; Reset Cursor
            mov ah,2
            mov dx, Op1CursorLoc
            int 10h
        pop dx 
        pop ax

        ; Check if pressed is Up or down or Enter
        cmp ah, UpArrowScanCode                          
        jz CommUp_AddReg 
        cmp ah, DownArrowScanCode
        jz CommDown_AddReg
        cmp ah, EnterScanCode
        jz Selected_AddReg
        cmp ah, RightScanCode
        jz MoveRight_Op1AddReg
        cmp ah, LeftScanCode
        jz MoveLeft_Op1AddReg
        cmp ah, 57
        jz DrawBullet_Op1AddReg
        CMP AH, EscScanCode
        JZ Exit_Op1AddReg

        jmp CheckKey_AddReg

        DrawBullet_Op1AddReg:
            Call DrawBullet
            jmp CheckKey_AddReg
        MoveLeft_Op1AddReg:
            CALL MoveShooterLeft
            jmp CheckKey_AddReg
        MoveRight_Op1AddReg:
            CALL MoveShooterRight
            jmp CheckKey_AddReg
        Exit_Op1AddReg:
            CALL Terminate



        CommUp_AddReg:
            mov ah, 9
            ; Check overflow
                cmp dx, offset AddRegAX              ; RegFirstChoiceLocation ; the start of combobox
                jnz NotOverflow_AddReg
                mov dx, offset AddRegDI              ; RegLastChoiceLocation ; last one to overcome overflow
                add dx, CommStringSize
            NotOverflow_AddReg:
                sub dx, CommStringSize
                int 21h
                jmp CheckKey_AddReg
        
        CommDown_AddReg:
            mov ah, 9
            ; Check End of file
                cmp dx, offset AddRegDI              ; RegLastChoiceLocation
                jnz NotEOF_AddReg
                mov dx, offset AddRegAX              ; RegFirstChoiceLocation
                sub dx, CommStringSize
            NotEOF_AddReg:
                add dx, CommStringSize
                int 21h
                jmp CheckKey_AddReg
        
        Selected_AddReg:
            ; Detecting index of selected command
            mov ax, dx
            SUB AX, offset AddRegAX              ; RegFirstChoiceLocation
            mov bl, CommStringSize
            div bl                                      ; Op=byte: AL:=AX / Op 
            mov selectedOp1AddReg, al
            ; NEEDS TO ADD A RETURN OR ENDING JUMP HERE
            JMP RETURN
    
    ChooseMem:
    
        ; Display memory
        
        mov ah, 9
        mov dx, offset Mem0
        int 21h

        CheckKeyMemType:
            ; Clear buffer
            mov ah,07
            int 21h
            CALL WaitKeyPress


        Push ax
        PUSH dx 
            ; Clear buffer
            mov ah,07
            int 21h
            ; Reset Cursor
            mov ah,2
            mov dx, Op1CursorLoc
            int 10h
        pop dx 
        pop ax

        ; Check if pressed is Up or down or Enter
        cmp ah, UpArrowScanCode                          
        jz CommUp3 
        cmp ah, DownArrowScanCode
        jz CommDown3
        cmp ah, EnterScanCode
        jz Selected3
        cmp ah, RightScanCode
        jz MoveRight_Op1Mem
        cmp ah, LeftScanCode
        jz MoveLeft_Op1Mem
        cmp ah, 57
        jz DrawBullet_Op1Mem
        CMP AH, EscScanCode
        JZ Exit_Op1Mem

        jmp CheckKeyMemType

        DrawBullet_Op1Mem:
            Call DrawBullet
            jmp CheckKeyMemType
        MoveLeft_Op1Mem:
            CALL MoveShooterLeft
            jmp CheckKeyMemType
        MoveRight_Op1Mem:
            CALL MoveShooterRight
            jmp CheckKeyMemType
        Exit_Op1Mem:
            CALL Terminate

        CommUp3:
            mov ah, 9
            ; Check overflow
                cmp dx, offset Mem0         ; the start of combobox
                jnz NotOverflow3
                mov dx, offset Mem15 ; last one to overcome overflow
                add dx, CommStringSize
            NotOverflow3:
                sub dx, CommStringSize
                int 21h
                jmp CheckKeyMemType
        
        CommDown3:
            mov ah, 9
            ; Check End of file
                cmp dx, offset Mem15
                jnz NotEOF3
                mov dx, offset Mem0
                sub dx, CommStringSize
            NotEOF3:
                add dx, CommStringSize
                int 21h
                jmp CheckKeyMemType
        
        Selected3:
            ; Detecting index of selected command
            mov ax, dx
            SUB AX, offset Mem0
            mov bl, CommStringSize
            div bl                                      ; Op=byte: AL:=AX / Op 
            mov selectedOp1Mem, al

            JMP RETURN

    EnterVal:

        ; Clear the space which the user should enter the value into
        mov dx, offset ClearSpace
        CALL DisplayString

        ; Reset Cursor
        mov dx, Op1CursorLoc
        CALL SetCursor

        ; Clear buffer
        mov ah,07
        int 21h
        

        ; Take value as a String from User
        mov ah,0Ah                   
        mov dx,offset num
        int 21h    
        

        mov cl,num+1                 ;save string size
        mov StrSize,cl

        mov ch,0
        mov si,2                     ;si to get first number from string that is not zero
        mov di,2  
        
        cmp StrSize,1
        jz hoop1
        hoop2:
            mov dl,num[di]               ; this loop to check zero in the first string
            sub dl,30h
            cmp dl,0 
            jne hoop1
            inc si
            mov cl, StrSize
            dec cl
            mov StrSize,cl 
            inc di
            cmp cl,1
        jnz hoop2
        
        hoop1:
            cmp cl,4         ;check that value is hexa or Get error    
            jng sk 
            JMP InValidVal

        sk:
        
        mov Bl,StrSize              ; loops to check num from 1 to 9 and A to F
        numloop:
            mov al,num[si] 
            cmp al,30H
            jnge notnum 
            cmp al,39h
            jnle notnum
            sub al,30h  
            jmp done   
        
        notnum: 
            cmp al,41H
            jnge notcharnum
            cmp al,46h
            jnle notcharnum
            sub al,37h
            jmp done  
            
        notcharnum:
            cmp al,61H
            jnge InValidVal
            cmp al,66h
            jnle InValidVal
            sub al,57h
            jmp done
            
                
        
        done:  
            inc si       
            cmp bl,4                   ; first digit
            jne ha1
            mov cl,al 
            mov ax,a 
            mov ch,0
            mul cx
        ha1:  
            cmp bl,3                   ;second digit
            jne ha2
            mov cl,al 
            mov ax,b
            mov ch,0
            mul cx
        
        ha2:  
            cmp bl,2                   ;third digit
            jne ha3
            mov cl,al 
            mov ax,c
            mov ch,0
            mul cx
        
        ha3:
            cmp bl,1                  ;fourth digit
            jne ha4
            mov ah,0
        
        ha4:
            add Op1Val,ax  
        
        dec Bl                    ; check to exit 
        cmp Bl,0   
        je RETURN 
        
        jmp numloop

        InValidVal:
            MOV Op1Valid, 0
            JMP RETURN    

    InvalidOp1Type:
        ; TODO

    RETURN:
        CALL CheckOp2Size
        RET
Op1Menu ENDP
CheckOp1Size PROC
    CMP selectedOp1Type, RegIndex
    jz Reg_CheckOp1Size
    CMP selectedOp1Type, ValIndex
    jz Val_CheckOp1Size
    
    ; Memory is 16-bit addressable
    MOV selectedOp1Size, 16
    
    Reg_CheckOp1Size:
        CMP selectedOp1Reg, 0
        JZ CheckOp1Size_RegAX
        CMP selectedOp1Reg, 1
        JZ CheckOp1Size_RegAL
        CMP selectedOp1Reg, 2
        JZ CheckOp1Size_RegAH
        CMP selectedOp1Reg, 3
        JZ CheckOp1Size_RegBX
        CMP selectedOp1Reg, 4
        JZ CheckOp1Size_RegBL
        CMP selectedOp1Reg, 5
        JZ CheckOp1Size_RegBH
        CMP selectedOp1Reg, 6
        JZ CheckOp1Size_RegCX
        CMP selectedOp1Reg, 7
        JZ CheckOp1Size_RegCL
        CMP selectedOp1Reg, 8
        JZ CheckOp1Size_RegCH
        CMP selectedOp1Reg, 9
        JZ CheckOp1Size_RegDX
        CMP selectedOp1Reg, 10
        JZ CheckOp1Size_RegDL
        CMP selectedOp1Reg, 11
        JZ CheckOp1Size_RegDH

        CMP selectedOp1Reg, 15
        JZ CheckOp1Size_RegBP
        CMP selectedOp1Reg, 16
        JZ CheckOp1Size_RegSP
        CMP selectedOp1Reg, 17
        JZ CheckOp1Size_RegSI
        CMP selectedOp1Reg, 18
        JZ CheckOp1Size_RegDI
        

        ret

        CheckOp1Size_RegAX:
            MOV selectedOp1Size, 16
            ret
        CheckOp1Size_RegAL:
            MOV selectedOp1Size, 8
            ret
        CheckOp1Size_RegAH:
            MOV selectedOp1Size, 8
            ret
        CheckOp1Size_RegBX:
            MOV selectedOp1Size, 16
            ret
        CheckOp1Size_RegBL:
            MOV selectedOp1Size, 8
            ret
        CheckOp1Size_RegBH:
            MOV selectedOp1Size, 8
            ret
        CheckOp1Size_RegCX:
            MOV selectedOp1Size, 16
            ret
        CheckOp1Size_RegCL:
            MOV selectedOp1Size, 8
            ret
        CheckOp1Size_RegCH:
            MOV selectedOp1Size, 8
            ret
        CheckOp1Size_RegDX:
            MOV selectedOp1Size, 16
            ret
        CheckOp1Size_RegDL:
            MOV selectedOp1Size, 8
            ret
        CheckOp1Size_RegDH:
            MOV selectedOp1Size, 8
            ret
        CheckOp1Size_RegBP:
            MOV selectedOp1Size, 16
            ret
        CheckOp1Size_RegSP:
            MOV selectedOp1Size, 16
            ret
        CheckOp1Size_RegSI:
            MOV selectedOp1Size, 16
            ret
        CheckOp1Size_RegDI:
            MOV selectedOp1Size, 16
            ret

    Val_CheckOp1Size:
        CMP Op1Val, 0FFH
        ja Op1Val_16Bit
        mov selectedOp1Size, 8
        RET
        Op1Val_16Bit:
            mov selectedOp1Size, 16


    RET
ENDP
Op2Menu PROC

    ; Set Cursor
    mov ah,2
    mov dx, Op2CursorLoc 
    int 10h

    CALL Op2TypeMenu

    ; Set Cursor
    mov ah,2
    mov dx, Op2CursorLoc 
    int 10h


    CMP selectedOp2Type, RegIndex     
    JZ ChooseReg_Op2Menu
    CMP selectedOp2Type, AddRegIndex
    JZ ChooseAddReg_Op2Menu
    CMP selectedOp2Type, MemIndex
    JZ ChooseMem_Op2Menu
    CMP selectedOp2Type, ValIndex
    JZ EnterVal_Op2Menu
    
    jmp InvalidOp2Type

    ChooseReg_Op2Menu: 

        ; Display Command
        mov ah, 9
        mov dx, offset RegAX
        int 21h

        CheckKey_RegType_Op2Menu:
            ; Clear buffer
            mov ah,07
            int 21h
            CALL WaitKeyPress


        Push ax
        PUSH dx 
            ; Clear buffer
            mov ah,07
            int 21h
            ; Reset Cursor
            mov ah,2
            mov dx, Op2CursorLoc
            int 10h
        pop dx 
        pop ax

        ; Check if pressed is Up or down or Enter
        cmp ah, UpArrowScanCode                          
        jz CommUp_RegType_Op2Menu
        cmp ah, DownArrowScanCode
        jz CommDown_RegType_Op2Menu
        cmp ah, EnterScanCode
        jz Selected_RegType_Op2Menu
        
        cmp ah, RightScanCode
        jz MoveRight_RegType_Op2Menu
        cmp ah, LeftScanCode
        jz MoveLeft_RegType_Op2Menu
        cmp ah, 57
        jz DrawBullet_RegType_Op2Menu
        CMP AH, EscScanCode
        JZ EXIT_RegType_Op2Menu

        jmp CheckKey_RegType_Op2Menu

        DrawBullet_RegType_Op2Menu:
            Call DrawBullet
            jmp CheckKey_RegType_Op2Menu
        MoveLeft_RegType_Op2Menu:
            CALL MoveShooterLeft
            jmp CheckKey_RegType_Op2Menu
        MoveRight_RegType_Op2Menu:
            CALL MoveShooterRight
            jmp CheckKey_RegType_Op2Menu
        EXIT_RegType_Op2Menu:
            CALL Terminate

        CommUp_RegType_Op2Menu:
            mov ah, 9
            ; Check overflow
                cmp dx, offset RegAX              ; RegFirstChoiceLocation ; the start of combobox
                jnz NotOverflow_RegType_Op2Menu
                mov dx, offset RegDI              ; RegLastChoiceLocation ; last one to overcome overflow
                add dx, CommStringSize
            NotOverflow_RegType_Op2Menu:
                sub dx, CommStringSize
                int 21h
                jmp CheckKey_RegType_Op2Menu
        
        CommDown_RegType_Op2Menu:
            mov ah, 9
            ; Check End of file
                cmp dx, offset RegDI              ; RegLastChoiceLocation
                jnz NotEOF_RegType_Op2Menu
                mov dx, offset RegAX              ; RegFirstChoiceLocation
                sub dx, CommStringSize
            NotEOF_RegType_Op2Menu:
                add dx, CommStringSize
                int 21h
                jmp CheckKey_RegType_Op2Menu
        
        Selected_RegType_Op2Menu:
            ; Detecting index of selected command
            mov ax, dx
            SUB AX, offset RegAX              ; RegFirstChoiceLocation
            mov bl, CommStringSize
            div bl                                      ; Op=byte: AL:=AX / Op 
            mov selectedOp2Reg, al
            ; NEEDS TO ADD A RETURN OR ENDING JUMP HERE
            JMP RETURN_Op2Menu

    ChooseAddReg_Op2Menu:

        ; Display Command
        mov ah, 9
        mov dx, offset AddRegAX
        int 21h

        CheckKey_AddReg_Op2Menu:
            ; Clear buffer
            mov ah,07
            int 21h
            CALL WaitKeyPress


        Push ax
        PUSH dx 
            ; Clear buffer
            mov ah,07
            int 21h
            ; Reset Cursor
            mov ah,2
            mov dx, Op2CursorLoc
            int 10h
        pop dx 
        pop ax

        ; Check if pressed is Up or down or Enter
        cmp ah, UpArrowScanCode                          
        jz CommUp_AddReg_Op2Menu
        cmp ah, DownArrowScanCode
        jz CommDown_AddReg_Op2Menu
        cmp ah, EnterScanCode
        jz Selected_AddReg

        cmp ah, RightScanCode
        jz MoveRight_AddReg_Op2Menu
        cmp ah, LeftScanCode
        jz MoveLeft_AddReg_Op2Menu
        cmp ah, 57
        jz DrawBullet_AddReg_Op2Menu
        CMP AH, EscScanCode
        JZ EXIT__AddReg_Op2Menu

        jmp CheckKey_AddReg_Op2Menu

        DrawBullet_AddReg_Op2Menu:
            Call DrawBullet
            jmp CheckKey_AddReg_Op2Menu
        MoveLeft_AddReg_Op2Menu:
            CALL MoveShooterLeft
            jmp CheckKey_AddReg_Op2Menu
        MoveRight_AddReg_Op2Menu:
            CALL MoveShooterRight
            jmp CheckKey_AddReg_Op2Menu
        EXIT__AddReg_Op2Menu:
            CALL Terminate
        


        CommUp_AddReg_Op2Menu:
            mov ah, 9
            ; Check overflow
                cmp dx, offset AddRegAX              ; RegFirstChoiceLocation ; the start of combobox
                jnz NotOverflow_AddReg_Op2Menu
                mov dx, offset AddRegDI              ; RegLastChoiceLocation ; last one to overcome overflow
                add dx, CommStringSize
            NotOverflow_AddReg_Op2Menu:
                sub dx, CommStringSize
                int 21h
                jmp CheckKey_AddReg_Op2Menu
        
        CommDown_AddReg_Op2Menu:
            mov ah, 9
            ; Check End of file
                cmp dx, offset AddRegDI              ; RegLastChoiceLocation
                jnz NotEOF_AddReg_Op2Menu
                mov dx, offset AddRegAX              ; RegFirstChoiceLocation
                sub dx, CommStringSize
            NotEOF_AddReg_Op2Menu:
                add dx, CommStringSize
                int 21h
                jmp CheckKey_AddReg_Op2Menu
        
        Selected_AddReg_Op2Menu:
            ; Detecting index of selected command
            mov ax, dx
            SUB AX, offset AddRegAX              ; RegFirstChoiceLocation
            mov bl, CommStringSize
            div bl                                      ; Op=byte: AL:=AX / Op 
            mov selectedOp2AddReg, al
            ; NEEDS TO ADD A RETURN OR ENDING JUMP HERE
            JMP RETURN_Op2Menu
    
    ChooseMem_Op2Menu:
    
        ; Display memory
        
        mov ah, 9
        mov dx, offset Mem0
        int 21h

        CheckKey_MemType_Op2Menu:
            ; Clear buffer
            mov ah,07
            int 21h
            CALL WaitKeyPress


        Push ax
        PUSH dx 
            ; Clear buffer
            mov ah,07
            int 21h
            ; Reset Cursor
            mov ah,2
            mov dx, Op2CursorLoc
            int 10h
        pop dx 
        pop ax

        ; Check if pressed is Up or down or Enter
        cmp ah, UpArrowScanCode                          
        jz CommUp_Op2Menu 
        cmp ah, DownArrowScanCode
        jz CommDown_Op2Menu
        cmp ah, EnterScanCode
        jz Selected_Op2Menu
        cmp ah, RightScanCode
        jz MoveRight_Op2MenuMem
        cmp ah, LeftScanCode
        jz MoveLeft_Op2MenuMem 
        cmp ah, 57
        jz DrawBullet_Op2MenuMem
        CMP AH, EscScanCode
        JZ EXIT_Op2MenuMem

        jmp CheckKey_MemType_Op2Menu

        DrawBullet_Op2MenuMem:
            Call DrawBullet
            jmp CheckKey_MemType_Op2Menu
        MoveLeft_Op2MenuMem:
            CALL MoveShooterLeft
            jmp CheckKey_MemType_Op2Menu
        MoveRight_Op2MenuMem:
            CALL MoveShooterRight
            jmp CheckKey_MemType_Op2Menu
        EXIT_Op2MenuMem:
            CALL Terminate


        CommUp_Op2Menu:
            mov ah, 9
            ; Check overflow
                cmp dx, offset Mem0         ; the start of combobox
                jnz NotOverflow_Op2Menu
                mov dx, offset Mem15 ; last one to overcome overflow
                add dx, CommStringSize
            NotOverflow_Op2Menu:
                sub dx, CommStringSize
                int 21h
                jmp CheckKey_MemType_Op2Menu
        
        CommDown_Op2Menu:
            mov ah, 9
            ; Check End of file
                cmp dx, offset Mem15
                jnz NotEOF_Op2Menu
                mov dx, offset Mem0
                sub dx, CommStringSize
            NotEOF_Op2Menu:
                add dx, CommStringSize
                int 21h
                jmp CheckKey_MemType_Op2Menu
        
        Selected_Op2Menu:
            ; Detecting index of selected command
            mov ax, dx
            SUB AX, offset Mem0
            mov bl, CommStringSize
            div bl                                      ; Op=byte: AL:=AX / Op 
            mov selectedOp2Mem, al

            JMP RETURN_Op2Menu

    EnterVal_Op2Menu:

        ; Clear the space which the user should enter the value into
        mov dx, offset ClearSpace
        CALL DisplayString

        ; Reset Cursor
        mov dx, Op2CursorLoc
        CALL SetCursor
        ; Clear buffer
            mov ah,07
            int 21h

        ; Take value as a String from User
        mov ah,0Ah                   
        mov dx,offset num2
        int 21h    
        

        mov cl,num2+1                 ;save string size
        mov StrSize2,cl

        mov ch,0
        mov si,2                     ;si to get first number from string that is not zero
        mov di,2  
        
        cmp StrSize2,1
        jz hoop1_Op2Menu
        hoop2_Op2Menu:
            mov dl,num2[di]               ; this loop to check zero in the first string
            sub dl,30h
            cmp dl,0 
            jne hoop1_Op2Menu
            inc si
            mov cl, StrSize2
            dec cl
            mov StrSize2,cl 
            inc di
            cmp cl,1 
        jnz hoop2_Op2Menu
        
        hoop1_Op2Menu:
            cmp cl,4         ;check that value is hexa or Get error    
            jng sk_Op2Menu 
            JMP InValidVal_Op2Menu

        sk_Op2Menu:
        
        mov Bl,StrSize2              ; loops to check num from 1 to 9 and A to F
        numloop_Op2Menu:
            mov al,num2[si] 
            cmp al,30H
            jnge notnum_Op2Menu 
            cmp al,39h
            jnle notnum_Op2Menu
            sub al,30h  
            jmp done_Op2Menu   
        
        notnum_Op2Menu: 
            cmp al,41H
            jnge notcharnum_Op2Menu
            cmp al,46h
            jnle notcharnum_Op2Menu
            sub al,37h
            jmp done_Op2Menu  
            
        notcharnum_Op2Menu:
            cmp al,61H
            jnge InValidVal_Op2Menu
            cmp al,66h
            jnle InValidVal_Op2Menu
            sub al,57h
            jmp done_Op2Menu
            
                
        
        done_Op2Menu:  
            inc si       
            cmp bl,4                   ; first digit
            jne ha1_Op2Menu
            mov cl,al 
            mov ax,a 
            mov ch,0
            mul cx
        ha1_Op2Menu:  
            cmp bl,3                   ;second digit
            jne ha2_Op2Menu
            mov cl,al 
            mov ax,b
            mov ch,0
            mul cx
        
        ha2_Op2Menu:  
            cmp bl,2                   ;third digit
            jne ha3_Op2Menu
            mov cl,al 
            mov ax,c
            mov ch,0
            mul cx
        
        ha3_Op2Menu:
            cmp bl,1                  ;fourth digit
            jne ha4_Op2Menu
            mov ah,0
        
        ha4_Op2Menu:
            add Op2Val,ax  
        
        dec Bl                    ; check to exit 
        cmp Bl,0   
        je RETURN_Op2Menu 
        
        jmp numloop_Op2Menu

        InValidVal_Op2Menu:
            MOV Op2Valid, 0
            JMP RETURN_Op2Menu   

    InvalidOp2Type:
        ; TODO
        mov ah, 9               ; display error message and exit
        mov dx, offset error
        int 21h

    RETURN_Op2Menu:
        CALL CheckOp2Size
        RET
Op2Menu ENDP
CheckOp2Size PROC
    CMP selectedOp2Type, 0
    jz Reg_CheckOp2Size
    CMP selectedOp2Type, ValIndex
    jz Val_CheckOp2Size
    
    ; Memory is 16-bit addressable
    MOV selectedOp2Size, 16
    
    Reg_CheckOp2Size:
        CMP selectedOp2Reg, 0
        JZ CheckOp2Size_RegAX
        CMP selectedOp2Reg, 1
        JZ CheckOp2Size_RegAL
        CMP selectedOp2Reg, 2
        JZ CheckOp2Size_RegAH
        CMP selectedOp2Reg, 3
        JZ CheckOp2Size_RegBX
        CMP selectedOp2Reg, 4
        JZ CheckOp2Size_RegBL
        CMP selectedOp2Reg, 5
        JZ CheckOp2Size_RegBH
        CMP selectedOp2Reg, 6
        JZ CheckOp2Size_RegCX
        CMP selectedOp2Reg, 7
        JZ CheckOp2Size_RegCL
        CMP selectedOp2Reg, 8
        JZ CheckOp2Size_RegCH
        CMP selectedOp2Reg, 9
        JZ CheckOp2Size_RegDX
        CMP selectedOp2Reg, 10
        JZ CheckOp2Size_RegDL
        CMP selectedOp2Reg, 11
        JZ CheckOp2Size_RegDH

        CMP selectedOp2Reg, 15
        JZ CheckOp2Size_RegBP
        CMP selectedOp2Reg, 16
        JZ CheckOp2Size_RegSP
        CMP selectedOp2Reg, 17
        JZ CheckOp2Size_RegSI
        CMP selectedOp2Reg, 18
        JZ CheckOp2Size_RegDI
        

        ret

        CheckOp2Size_RegAX:
            MOV selectedOp2Size, 16
            ret
        CheckOp2Size_RegAL:
            MOV selectedOp2Size, 8
            ret
        CheckOp2Size_RegAH:
            MOV selectedOp2Size, 8
            ret
        CheckOp2Size_RegBX:
            MOV selectedOp2Size, 16
            ret
        CheckOp2Size_RegBL:
            MOV selectedOp2Size, 8
            ret
        CheckOp2Size_RegBH:
            MOV selectedOp2Size, 8
            ret
        CheckOp2Size_RegCX:
            MOV selectedOp2Size, 16
            ret
        CheckOp2Size_RegCL:
            MOV selectedOp2Size, 8
            ret
        CheckOp2Size_RegCH:
            MOV selectedOp2Size, 8
            ret
        CheckOp2Size_RegDX:
            MOV selectedOp2Size, 16
            ret
        CheckOp2Size_RegDL:
            MOV selectedOp2Size, 8
            ret
        CheckOp2Size_RegDH:
            MOV selectedOp2Size, 8
            ret
        CheckOp2Size_RegBP:
            MOV selectedOp2Size, 16
            ret
        CheckOp2Size_RegSP:
            MOV selectedOp2Size, 16
            ret
        CheckOp2Size_RegSI:
            MOV selectedOp2Size, 16
            ret
        CheckOp2Size_RegDI:
            MOV selectedOp2Size, 16
            ret

    Val_CheckOp2Size:
        CMP Op2Val, 0FFH
        ja Op2Val_16Bit
        mov selectedOp2Size, 8
        RET
        Op2Val_16Bit:
            mov selectedOp2Size, 16
            RET
ENDP
ourGetSrcOp_8Bit PROC    ; Returned Value is saved in AL

    MOV AL, selectedOp1Size
    CMP AL, selectedOp2Size
    jnz InValidCommand

    CMP selectedOp2Type, 0
    JZ SrcOp2Reg_8Bit2
    CMP selectedOp2Type, 1
    JZ SrcOp2AddReg_8Bit2
    CMP selectedOp2Type, 2
    JZ SrcOp2Mem_8Bit2
    CMP selectedOp2Type, 3
    JZ SrcOp2Val_8Bit2
    JMP InValidCommand

    SrcOp2Reg_8Bit2:
        CMP selectedOp2Reg, 1
        JZ SrcOp2RegAL_8Bit2
        CMP selectedOp2Reg, 2
        JZ SrcOp2RegAH_8Bit2

        CMP selectedOp2Reg, 4
        JZ SrcOp2RegBL_8Bit2
        CMP selectedOp2Reg, 5
        JZ SrcOp2RegBH_8Bit2

        CMP selectedOp2Reg, 7
        JZ SrcOp2RegCL_8Bit2
        CMP selectedOp2Reg, 8
        JZ SrcOp2RegCH_8Bit2

        CMP selectedOp2Reg, 10
        JZ SrcOp2RegDL_8Bit2
        CMP selectedOp2Reg, 11
        JZ SrcOp2RegDH_8Bit2

        JMP InValidCommand

        SrcOp2RegAL_8Bit2:
            mov al, BYTE PTR ourValRegAX
            RET
        SrcOp2RegAH_8Bit2:
            mov al, BYTE PTR ourValRegAX+1
            RET
        SrcOp2RegBL_8Bit2:
            mov al, BYTE PTR ourValRegBX
            RET
        SrcOp2RegBH_8Bit2:
            mov al, BYTE PTR ourValRegBX+1
            RET
        SrcOp2RegCL_8Bit2:
            mov al, BYTE PTR ourValRegCX
            RET
        SrcOp2RegCH_8Bit2:
            mov al, BYTE PTR ourValRegCX+1
            RET
        SrcOp2RegDL_8Bit2:
            mov al, BYTE PTR ourValRegDX
            RET
        SrcOp2RegDH_8Bit2:
            mov al, BYTE PTR ourValRegDX+1
            RET
        


    SrcOp2AddReg_8Bit2:

        CMP selectedOp2AddReg, 3
        JZ SrcOp2AddRegBX_8Bit2
        CMP selectedOp2AddReg, 15
        JZ SrcOp2AddRegBP_8Bit2
        CMP selectedOp2AddReg, 17
        JZ SrcOp2AddRegSI_8Bit2
        CMP selectedOp2AddReg, 18
        JZ SrcOp2AddRegDI_8Bit2

        JMP InValidCommand

        SrcOp2AddRegBX_8Bit2:
            MOV DX, ourValRegBX
            CALL CheckAddress
            CMP BL, 1
            JZ InValidCommand
            MOV SI, ourValRegBX
            MOV AL, [SI]
            RET
        SrcOp2AddRegBP_8Bit2:
            MOV DX, ourValRegBP
            CALL CheckAddress
            CMP BL, 1
            JZ InValidCommand
            MOV SI, ourValRegBP
            MOV AL, [SI]
            RET
        SrcOp2AddRegSI_8Bit2:
            MOV DX, ourValRegSI
            CALL CheckAddress
            CMP BL, 1
            JZ InValidCommand
            MOV SI, ourValRegSI
            MOV AL, [SI]
            RET
        SrcOp2AddRegDI_8Bit2:
            MOV DX, ourValRegDI
            CALL CheckAddress
            CMP BL, 1
            JZ InValidCommand
            MOV SI, ourValRegDI
            MOV AL, [SI]
            RET

    SrcOp2Mem_8Bit2:

        CMP selectedOp2Mem, 0
        JZ SrcOp2Mem0_8Bit2
        CMP selectedOp2Mem, 1
        JZ SrcOp2Mem1_8Bit2
        CMP selectedOp2Mem, 2
        JZ SrcOp2Mem2_8Bit2
        CMP selectedOp2Mem, 3
        JZ SrcOp2Mem3_8Bit2
        CMP selectedOp2Mem, 4
        JZ SrcOp2Mem4_8Bit2
        CMP selectedOp2Mem, 5
        JZ SrcOp2Mem5_8Bit2
        CMP selectedOp2Mem, 6
        JZ SrcOp2Mem6_8Bit2
        CMP selectedOp2Mem, 7
        JZ SrcOp2Mem7_8Bit2
        CMP selectedOp2Mem, 8
        JZ SrcOp2Mem8_8Bit2
        CMP selectedOp2Mem, 9
        JZ SrcOp2Mem9_8Bit2
        CMP selectedOp2Mem, 10
        JZ SrcOp2Mem10_8Bit2
        CMP selectedOp2Mem, 11
        JZ SrcOp2Mem11_8Bit2
        CMP selectedOp2Mem, 12
        JZ SrcOp2Mem12_8Bit2
        CMP selectedOp2Mem, 13
        JZ SrcOp2Mem13_8Bit2
        CMP selectedOp2Mem, 14
        JZ SrcOp2Mem14_8Bit2
        CMP selectedOp2Mem, 15
        JZ SrcOp2Mem15_8Bit2
        JMP InValidCommand
        
        SrcOp2Mem0_8Bit2:
            MOV AL, ourValMem
            RET
        SrcOp2Mem1_8Bit2:
            MOV AL, ourValMem+1
            RET
        SrcOp2Mem2_8Bit2:
            MOV AL, ourValMem+2
            RET
        SrcOp2Mem3_8Bit2:
            MOV AL, ourValMem+3
            RET
        SrcOp2Mem4_8Bit2:
            MOV AL, ourValMem+4
            RET
        SrcOp2Mem5_8Bit2:
            MOV AL, ourValMem+5
            RET
        SrcOp2Mem6_8Bit2:
            MOV AL, ourValMem+6
            RET
        SrcOp2Mem7_8Bit2:
            MOV AL, ourValMem+7
            RET
        SrcOp2Mem8_8Bit2:
            MOV AL, ourValMem+8
            RET
        SrcOp2Mem9_8Bit2:
            MOV AL, ourValMem+9
            RET
        SrcOp2Mem10_8Bit2:
            MOV AL, ourValMem+10
            RET
        SrcOp2Mem11_8Bit2:
            MOV AL, ourValMem+11
            RET
        SrcOp2Mem12_8Bit2:
            MOV AL, ourValMem+12
            RET
        SrcOp2Mem13_8Bit2:
            MOV AL, ourValMem+13
            RET
        SrcOp2Mem14_8Bit2:
            MOV AL, ourValMem+14
            RET
        SrcOp2Mem15_8Bit2:
            MOV AL, ourValMem+15
            RET
    SrcOp2Val_8Bit2:
        CMP Op2Valid, 0
        jz InValidCommand
        MOV AL, BYTE PTR Op2Val
        RET
ourGetSrcOp_8Bit ENDP    
GetSrcOp_8Bit PROC    ; Returned Value is saved in AL

    MOV AL, selectedOp1Size
    CMP AL, selectedOp2Size
    jnz InValidCommand

    CMP selectedOp2Type, 0
    JZ SrcOp2Reg_8Bit
    CMP selectedOp2Type, 1
    JZ SrcOp2AddReg_8Bit
    CMP selectedOp2Type, 2
    JZ SrcOp2Mem_8Bit
    CMP selectedOp2Type, 3
    JZ SrcOp2Val_8Bit
    JMP InValidCommand

    SrcOp2Reg_8Bit:
        CMP selectedOp2Reg, 1
        JZ SrcOp2RegAL_8Bit
        CMP selectedOp2Reg, 2
        JZ SrcOp2RegAH_8Bit

        CMP selectedOp2Reg, 4
        JZ SrcOp2RegBL_8Bit
        CMP selectedOp2Reg, 5
        JZ SrcOp2RegBH_8Bit

        CMP selectedOp2Reg, 7
        JZ SrcOp2RegCL_8Bit
        CMP selectedOp2Reg, 8
        JZ SrcOp2RegCH_8Bit

        CMP selectedOp2Reg, 10
        JZ SrcOp2RegDL_8Bit
        CMP selectedOp2Reg, 11
        JZ SrcOp2RegDH_8Bit

        JMP InValidCommand

        SrcOp2RegAL_8Bit:
            mov al, BYTE PTR ValRegAX
            RET
        SrcOp2RegAH_8Bit:
            mov al, BYTE PTR ValRegAX+1
            RET
        SrcOp2RegBL_8Bit:
            mov al, BYTE PTR ValRegBX
            RET
        SrcOp2RegBH_8Bit:
            mov al, BYTE PTR ValRegBX+1
            RET
        SrcOp2RegCL_8Bit:
            mov al, BYTE PTR ValRegCX
            RET
        SrcOp2RegCH_8Bit:
            mov al, BYTE PTR ValRegCX+1
            RET
        SrcOp2RegDL_8Bit:
            mov al, BYTE PTR ValRegDX
            RET
        SrcOp2RegDH_8Bit:
            mov al, BYTE PTR ValRegDX+1
            RET
        


    SrcOp2AddReg_8Bit:

        CMP selectedOp2AddReg, 3
        JZ SrcOp2AddRegBX_8Bit
        CMP selectedOp2AddReg, 15
        JZ SrcOp2AddRegBP_8Bit
        CMP selectedOp2AddReg, 17
        JZ SrcOp2AddRegSI_8Bit
        CMP selectedOp2AddReg, 18
        JZ SrcOp2AddRegDI_8Bit

        JMP InValidCommand

        SrcOp2AddRegBX_8Bit:
            MOV DX, ValRegBX
            CALL CheckAddress
            CMP BL, 1
            JZ InValidCommand
            MOV SI, ValRegBX
            MOV AL, [SI]
            RET
        SrcOp2AddRegBP_8Bit:
            MOV DX, ValRegBP
            CALL CheckAddress
            CMP BL, 1
            JZ InValidCommand
            MOV SI, ValRegBP
            MOV AL, [SI]
            RET
        SrcOp2AddRegSI_8Bit:
            MOV DX, ValRegSI
            CALL CheckAddress
            CMP BL, 1
            JZ InValidCommand
            MOV SI, ValRegSI
            MOV AL, [SI]
            RET
        SrcOp2AddRegDI_8Bit:
            MOV DX, ValRegDI
            CALL CheckAddress
            CMP BL, 1
            JZ InValidCommand
            MOV SI, ValRegDI
            MOV AL, [SI]
            RET

    SrcOp2Mem_8Bit:

        CMP selectedOp2Mem, 0
        JZ SrcOp2Mem0_8Bit
        CMP selectedOp2Mem, 1
        JZ SrcOp2Mem1_8Bit
        CMP selectedOp2Mem, 2
        JZ SrcOp2Mem2_8Bit
        CMP selectedOp2Mem, 3
        JZ SrcOp2Mem3_8Bit
        CMP selectedOp2Mem, 4
        JZ SrcOp2Mem4_8Bit
        CMP selectedOp2Mem, 5
        JZ SrcOp2Mem5_8Bit
        CMP selectedOp2Mem, 6
        JZ SrcOp2Mem6_8Bit
        CMP selectedOp2Mem, 7
        JZ SrcOp2Mem7_8Bit
        CMP selectedOp2Mem, 8
        JZ SrcOp2Mem8_8Bit
        CMP selectedOp2Mem, 9
        JZ SrcOp2Mem9_8Bit
        CMP selectedOp2Mem, 10
        JZ SrcOp2Mem10_8Bit
        CMP selectedOp2Mem, 11
        JZ SrcOp2Mem11_8Bit
        CMP selectedOp2Mem, 12
        JZ SrcOp2Mem12_8Bit
        CMP selectedOp2Mem, 13
        JZ SrcOp2Mem13_8Bit
        CMP selectedOp2Mem, 14
        JZ SrcOp2Mem14_8Bit
        CMP selectedOp2Mem, 15
        JZ SrcOp2Mem15_8Bit
        JMP InValidCommand
        
        SrcOp2Mem0_8Bit:
            MOV AL, ValMem
            RET
        SrcOp2Mem1_8Bit:
            MOV AL, ValMem+1
            RET
        SrcOp2Mem2_8Bit:
            MOV AL, ValMem+2
            RET
        SrcOp2Mem3_8Bit:
            MOV AL, ValMem+3
            RET
        SrcOp2Mem4_8Bit:
            MOV AL, ValMem+4
            RET
        SrcOp2Mem5_8Bit:
            MOV AL, ValMem+5
            RET
        SrcOp2Mem6_8Bit:
            MOV AL, ValMem+6
            RET
        SrcOp2Mem7_8Bit:
            MOV AL, ValMem+7
            RET
        SrcOp2Mem8_8Bit:
            MOV AL, ValMem+8
            RET
        SrcOp2Mem9_8Bit:
            MOV AL, ValMem+9
            RET
        SrcOp2Mem10_8Bit:
            MOV AL, ValMem+10
            RET
        SrcOp2Mem11_8Bit:
            MOV AL, ValMem+11
            RET
        SrcOp2Mem12_8Bit:
            MOV AL, ValMem+12
            RET
        SrcOp2Mem13_8Bit:
            MOV AL, ValMem+13
            RET
        SrcOp2Mem14_8Bit:
            MOV AL, ValMem+14
            RET
        SrcOp2Mem15_8Bit:
            MOV AL, ValMem+15
            RET
    SrcOp2Val_8Bit:
        CMP Op2Valid, 0
        jz InValidCommand
        MOV AL, BYTE PTR Op2Val
        RET


    RET
GetSrcOp_8Bit ENDP
DisPlayNumber PROC ;display number from Registers   
    POP BP

    pop ax
    mov bx,ax

    mov cx,a
    div cx

    mov ah,2     ; display first digit
    mov dl,al
    add dl,30h

    int 21h        

    mov ah,0
    mov cx,a
    mul cx

    sub bx,ax     

    mov cx,b   
    mov ax,bx
    div cx      

    mov cl,ah   

    mov ah,2     ; display second digit
    mov dl,al
    add dl,30h
    int 21h   

    mov dl,c
    mov al,bl
    mov ah,0

    div dl 

    mov ah,2     ; display third digit
    mov dl,al
    add dl,30h
    int 21h 

    mov cl,c 
    mov al,bl
    mov ah,0
    div cl
    mov al,ah
    mov ah,2     ; display fourth digit
    mov dl,al
    add dl,30h
    int 21h 

    PUSH BP
                    
    RET

DisPlayNumber ENDP
GetSrcOp PROC    ; Returned Value is saved in AX
    CMP selectedOp2Type, 0
    JZ SrcOp2Reg
    CMP selectedOp2Type, 1
    JZ SrcOp2AddReg
    CMP selectedOp2Type, 2
    JZ SrcOp2Mem
    CMP selectedOp2Type, 3
    JZ SrcOp2Val
    JMP InValidCommand

    SrcOp2Reg:

        CMP selectedOp2Reg, 0
        JZ SrcOp2RegAX

        CMP selectedOp2Reg, 3
        JZ SrcOp2RegBX

        CMP selectedOp2Reg, 6
        JZ SrcOp2RegCX

        CMP selectedOp2Reg, 9
        JZ SrcOp2pRegDX

        CMP selectedOp2Reg, 15
        JZ SrcOp2RegBP
        CMP selectedOp2Reg, 16
        JZ SrcOp2RegSP
        CMP selectedOp2Reg, 17
        JZ SrcOp2RegSI
        CMP selectedOp2Reg, 18
        JZ SrcOp2RegDI

        JMP InValidCommand

        SrcOp2RegAX:
            MOV AX, ValRegAX
            RET
        SrcOp2RegBX:
            MOV AX, ValRegBX
            RET
        SrcOp2RegCX:
            MOV AX, ValRegCX
            RET
        SrcOp2pRegDX:
            MOV AX, ValRegDX
            RET
        SrcOp2RegBP:
            MOV AX, ValRegBP
            RET
        SrcOp2RegSP:
            MOV AX, ValRegSP
            RET
        SrcOp2RegSI:
            MOV AX, ValRegSI
            RET
        SrcOp2RegDI:
            MOV AX, ValRegDI
            RET
        


    SrcOp2AddReg:

        CMP selectedOp2AddReg, 3
        JZ SrcOp2AddRegBX
        CMP selectedOp2AddReg, 15
        JZ SrcOp2AddRegBP
        CMP selectedOp2AddReg, 17
        JZ SrcOp2AddRegSI
        CMP selectedOp2AddReg, 18
        JZ SrcOp2AddRegDI

        JMP InValidCommand

        SrcOp2AddRegBX:
            MOV DX, ValRegBX
            CALL CheckAddress
            CMP BL, 1
            JZ InValidCommand
            MOV SI, ValRegBX
            MOV AX, [SI]
            RET
        SrcOp2AddRegBP:
            MOV DX, ValRegBP
            CALL CheckAddress
            CMP BL, 1
            JZ InValidCommand
            MOV SI, ValRegBP
            MOV AX, [SI]
            RET
        SrcOp2AddRegSI:
            MOV DX, ValRegSI
            CALL CheckAddress
            CMP BL, 1
            JZ InValidCommand
            MOV SI, ValRegSI
            MOV AX, [SI]
            RET
        SrcOp2AddRegDI:
            MOV DX, ValRegDI
            CALL CheckAddress
            CMP BL, 1
            JZ InValidCommand
            MOV SI, ValRegDI
            MOV AX, [SI]
            RET

    SrcOp2Mem:

        CMP selectedOp2Mem, 0
        JZ SrcOp2Mem0
        CMP selectedOp2Mem, 1
        JZ SrcOp2Mem1
        CMP selectedOp2Mem, 2
        JZ SrcOp2Mem2
        CMP selectedOp2Mem, 3
        JZ SrcOp2Mem3
        CMP selectedOp2Mem, 4
        JZ SrcOp2Mem4
        CMP selectedOp2Mem, 5
        JZ SrcOp2Mem5
        CMP selectedOp2Mem, 6
        JZ SrcOp2Mem6
        CMP selectedOp2Mem, 7
        JZ SrcOp2Mem7
        CMP selectedOp2Mem, 8
        JZ SrcOp2Mem8
        CMP selectedOp2Mem, 9
        JZ SrcOp2Mem9
        CMP selectedOp2Mem, 10
        JZ SrcOp2Mem10
        CMP selectedOp2Mem, 11
        JZ SrcOp2Mem11
        CMP selectedOp2Mem, 12
        JZ SrcOp2Mem12
        CMP selectedOp2Mem, 13
        JZ SrcOp2Mem13
        CMP selectedOp2Mem, 14
        JZ SrcOp2Mem14
        CMP selectedOp2Mem, 15
        JZ SrcOp2Mem15
        JMP InValidCommand
        
        SrcOp2Mem0:
            MOV AX, WORD PTR ValMem
            RET
        SrcOp2Mem1:
            MOV AX, WORD PTR ValMem+1
            RET
        SrcOp2Mem2:
            MOV AX, WORD PTR ValMem+2
            RET
        SrcOp2Mem3:
            MOV AX, WORD PTR ValMem+3
            RET
        SrcOp2Mem4:
            MOV AX, WORD PTR ValMem+4
            RET
        SrcOp2Mem5:
            MOV AX, WORD PTR ValMem+5
            RET
        SrcOp2Mem6:
            MOV AX, WORD PTR ValMem+6
            RET
        SrcOp2Mem7:
            MOV AX, WORD PTR ValMem+7
            RET
        SrcOp2Mem8:
            MOV AX, WORD PTR ValMem+8
            RET
        SrcOp2Mem9:
            MOV AX, WORD PTR ValMem+9
            RET
        SrcOp2Mem10:
            MOV AX, WORD PTR ValMem+10
            RET
        SrcOp2Mem11:
            MOV AX, WORD PTR ValMem+11
            RET
        SrcOp2Mem12:
            MOV AX, WORD PTR ValMem+12
            RET
        SrcOp2Mem13:
            MOV AX, WORD PTR ValMem+13
            RET
        SrcOp2Mem14:
            MOV AX, WORD PTR ValMem+14
            RET
        SrcOp2Mem15:
            MOV AX, WORD PTR ValMem+15
            RET
    SrcOp2Val:
        CMP Op2Valid, 0
        jz InValidCommand
        MOV AX, Op2Val
        RET


    RET
GetSrcOp ENDP
ourGetSrcOp PROC    ; Returned Value is saved in AX
    CMP selectedOp2Type, 0
    JZ SrcOp2Rega
    CMP selectedOp2Type, 1
    JZ SrcOp2AddRega
    CMP selectedOp2Type, 2
    JZ SrcOp2Mema
    CMP selectedOp2Type, 3
    JZ SrcOp2Vala
    JMP InValidCommand

    SrcOp2Rega:

        CMP selectedOp2Reg, 0
        JZ SrcOp2RegAXa

        CMP selectedOp2Reg, 3
        JZ SrcOp2RegBXa

        CMP selectedOp2Reg, 6
        JZ SrcOp2RegCXa

        CMP selectedOp2Reg, 9
        JZ SrcOp2pRegDXa

        CMP selectedOp2Reg, 15
        JZ SrcOp2RegBPa
        CMP selectedOp2Reg, 16
        JZ SrcOp2RegSPa
        CMP selectedOp2Reg, 17
        JZ SrcOp2RegSIa
        CMP selectedOp2Reg, 18
        JZ SrcOp2RegDIa

        JMP InValidCommand

        SrcOp2RegAXa:
            MOV AX, ourValRegAX
            RET
        SrcOp2RegBXa:
            MOV AX, ourValRegBX
            RET
        SrcOp2RegCXa:
            MOV AX, ourValRegCX
            RET
        SrcOp2pRegDXa:
            MOV AX, ourValRegDX
            RET
        SrcOp2RegBPa:
            MOV AX, ourValRegBP
            RET
        SrcOp2RegSPa:
            MOV AX, ourValRegSP
            RET
        SrcOp2RegSIa:
            MOV AX, ourValRegSI
            RET
        SrcOp2RegDIa:
            MOV AX, ourValRegDI
            RET
        


    SrcOp2AddRega:

        CMP selectedOp2AddReg, 3
        JZ SrcOp2AddRegBXa
        CMP selectedOp2AddReg, 15
        JZ SrcOp2AddRegBPa
        CMP selectedOp2AddReg, 17
        JZ SrcOp2AddRegSIa
        CMP selectedOp2AddReg, 18
        JZ SrcOp2AddRegDIa

        JMP InValidCommand

        SrcOp2AddRegBXa:
            MOV DX, ourValRegBX
            CALL CheckAddress
            CMP BL, 1
            JZ InValidCommand
            MOV SI, ourValRegBX
            MOV AX, [SI]
            RET
        SrcOp2AddRegBPa:
            MOV DX, ourValRegBP
            CALL CheckAddress
            CMP BL, 1
            JZ InValidCommand
            MOV SI, ourValRegBP
            MOV AX, [SI]
            RET
        SrcOp2AddRegSIa:
            MOV DX, ourValRegSI
            CALL CheckAddress
            CMP BL, 1
            JZ InValidCommand
            MOV SI, ourValRegSI
            MOV AX, [SI]
            RET
        SrcOp2AddRegDIa:
            MOV DX, ourValRegDI
            CALL CheckAddress
            CMP BL, 1
            JZ InValidCommand
            MOV SI, ourValRegDI
            MOV AX, [SI]
            RET

    SrcOp2Mema:

        CMP selectedOp2Mem, 0
        JZ SrcOp2Mem0a
        CMP selectedOp2Mem, 1
        JZ SrcOp2Mem1a
        CMP selectedOp2Mem, 2
        JZ SrcOp2Mem2a
        CMP selectedOp2Mem, 3
        JZ SrcOp2Mem3a
        CMP selectedOp2Mem, 4
        JZ SrcOp2Mem4a
        CMP selectedOp2Mem, 5
        JZ SrcOp2Mem5a
        CMP selectedOp2Mem, 6
        JZ SrcOp2Mem6a
        CMP selectedOp2Mem, 7
        JZ SrcOp2Mem7a
        CMP selectedOp2Mem, 8
        JZ SrcOp2Mem8a
        CMP selectedOp2Mem, 9
        JZ SrcOp2Mem9a
        CMP selectedOp2Mem, 10
        JZ SrcOp2Mem10a
        CMP selectedOp2Mem, 11
        JZ SrcOp2Mem11a
        CMP selectedOp2Mem, 12
        JZ SrcOp2Mem12a
        CMP selectedOp2Mem, 13
        JZ SrcOp2Mem13a
        CMP selectedOp2Mem, 14
        JZ SrcOp2Mem14a
        CMP selectedOp2Mem, 15
        JZ SrcOp2Mem15a
        JMP InValidCommand
        
        SrcOp2Mem0a:
            MOV AX, WORD PTR ourValMem
            RET
        SrcOp2Mem1a:
            MOV AX, WORD PTR ourValMem+1
            RET
        SrcOp2Mem2a:
            MOV AX, WORD PTR ourValMem+2
            RET
        SrcOp2Mem3a:
            MOV AX, WORD PTR ourValMem+3
            RET
        SrcOp2Mem4a:
            MOV AX, WORD PTR ourValMem+4
            RET
        SrcOp2Mem5a:
            MOV AX, WORD PTR ourValMem+5
            RET
        SrcOp2Mem6a:
            MOV AX, WORD PTR ourValMem+6
            RET
        SrcOp2Mem7a:
            MOV AX, WORD PTR ourValMem+7
            RET
        SrcOp2Mem8a:
            MOV AX, WORD PTR ourValMem+8
            RET
        SrcOp2Mem9a:
            MOV AX, WORD PTR ourValMem+9
            RET
        SrcOp2Mem10a:
            MOV AX, WORD PTR ourValMem+10
            RET
        SrcOp2Mem11a:
            MOV AX, WORD PTR ourValMem+11
            RET
        SrcOp2Mem12a:
            MOV AX, WORD PTR ourValMem+12
            RET
        SrcOp2Mem13a:
            MOV AX, WORD PTR ourValMem+13
            RET
        SrcOp2Mem14a:
            MOV AX, WORD PTR ourValMem+14
            RET
        SrcOp2Mem15a:
            MOV AX, WORD PTR ourValMem+15
            RET
    SrcOp2Vala:
        CMP Op2Valid, 0
        jz InValidCommand
        MOV AX, Op2Val
        RET


    RET
ourGetSrcOp ENDP
SetCF PROC
    PUSH BX
        MOV BL, 0
        ADC BL, 0
        MOV BL, ValCF
    POP BX

    RET
ENDP
GetCF PROC
    PUSH BX
        MOV BL, ValCF
        ADD BL, 0FFH
    POP BX

    RET
ENDP

END   MAIN