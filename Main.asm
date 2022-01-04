;================================================= MACROS ======================================================= ;
;; ------------------------------------------------ GUI MACROS --------------------------------------------------;;
PrintChar MACRO chara
    PUSHA
        ;draw X in the cursor position
        mov ah,0ah
        mov al,chara
        mov bh,0h
        mov bl,0fh
        mov cx,1
        int 10H
    POPA
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
    PUSHA
        mov cx,0
        ; set cursor position
        mov ah,2h
        mov bh,0h
        mov dh,Yposition
        mov dl,Xposition
        int 10h
    POPA
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
ourExecPushMem MACRO Op
    mov bh, 0
    mov bl, ourValStackPointer
    mov ax, word ptr Op
    lea di, ValStack
    mov [di][bx], ax
    ADD ourValStackPointer,2
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
        p2_AX_X1 db 107
        p2_AX_X2 EQU 108
        p2_AX_X3 EQU 109
        p2_AX_X4 EQU 110
        
        p2_AX_Y EQU 4 ; the Y axis of the AX register of the left processor 

        ; positions of X axis of the BX register in right processor
        p2_BX_X1 db 107
        p2_BX_X2 EQU 108
        p2_BX_X3 EQU 109
        p2_BX_X4 EQU 110
        
        p2_BX_Y EQU 6 ; the Y axis of the AX register of the left processor 


        ; positions of X axis of the DX register in right processor
        p2_CX_X1 db 107
        p2_CX_X2 EQU 108
        p2_CX_X3 EQU 109
        p2_CX_X4 EQU 110
        
        p2_CX_Y EQU 8 ; the Y axis of the AX register of the left processor 


        ; positions of X axis of the DX register in right processor
        p2_DX_X1 db 107
        p2_DX_X2 EQU 108
        p2_DX_X3 EQU 109
        p2_DX_X4 EQU 110
        
        p2_DX_Y EQU 10 ; the Y axis of the AX register of the left processor 


        ; positions of X axis of SP register in right processor 
        p2_SP_X1 db 113
        p2_SP_X2 equ 114
        p2_SP_X3 equ 115
        p2_SP_X4 equ 116

        p2_SP_Y equ 4 ; the Y position of SP register in the left processor 


        ; positions of X axis of BP register in right processor 
        p2_BP_X1 db 113
        p2_BP_X2 equ 114
        p2_BP_X3 equ 115
        p2_BP_X4 equ 116

        p2_BP_Y equ 6 ; the Y position of BP register in the left processor 

        ; positions of X axis of SI register in right processor 
        p2_SI_X1 db 113
        p2_SI_X2 equ 114
        p2_SI_X3 equ 115
        p2_SI_X4 equ 116

        p2_SI_Y equ 8 ; the Y position of SI register in the left processor 


        ; positions of X axis of DI register in right processor 
        p2_DI_X1 db 113
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
        PUPCursorLoc EQU 1500H
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
                ValRegDI dw 5677H

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
; ===============================================================================================================
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

;--------------------------------------------------------------------------------------------------------------------------------------------
CLEAR_SCREEN PROC FAR 
    MOV AH, 0H 
    MOV AL, 3H 
    INT 10H 
CLEAR_SCREEN ENDP
DisplayGUIValues PROC FAR
    ; Draw the Zeros in all their places/////////////////////////////////
		;Draw them for the left processor and its memory


    mov ax, ValRegAX
    mov bx, ax

    mov cx,a
    div cx
    
    SET p2_AX_Y p2_AX_X1
    add AL,30h
    PrintChar AL

    
    mov ah,0
    mov cx,a
    mul cx

    sub bx,ax     

    mov cx,b   
    mov ax,bx
    div cx      

    mov cl,ah
       
    SET p2_AX_Y p2_AX_X1+1
    add AL,30h
    PrintChar AL
       

    mov dl,c
    mov al,bl
    mov ah,0

    div dl 
    
    SET p2_AX_Y p2_AX_X1+2
    add AL,30h
    PrintChar AL  

    mov cl,c 
    mov al,bl
    mov ah,0
    div cl
    mov al,ah
    
    SET p2_AX_Y p2_AX_X1+3
    add AL,30h
    PrintChar AL


        ; DI 
		;Set 10 49           ; LEFT-MOST
		;PrintChar '1'
		;Set 10 50
		;PrintChar '2'
		;Set 10 51
		;PrintChar '3'
		;Set 10 52
		;PrintChar '4'

        ; DX
		Set 10 47
		PrintChar '3'       ; RIGHT-MOST
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
		;Set 4 110
		;PrintChar 'K'
		;Set 4 109
		;PrintChar 'L'
		;Set 4 108
		;PrintChar 'M'
		;Set 4 107
		;PrintChar 'N'

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
    
    Push ax
        CALL ClearBuffer
    pop ax
    
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
        CALL PowerUpMenu
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

        cmp selectedPUPType,1 ;command on your own processor  
        jne notthispower1_nop  
        NOP      
        jmp Exit
        notthispower1_nop:
        cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
        jne notthispower2_nop  
        NOP        
        notthispower2_nop:
        NOP
        JMP Exit
    
    CLC_Comm:
        CALL CheckForbidCharProc
         
        cmp selectedPUPType,1 ;command on your own processor  
        jne notthispower1_clc   
        MOV ourValCF, 0      ;command
        jmp Exit
        notthispower1_clc:
        cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
        jne notthispower2_clc  
        MOV ourValCF, 0       ;coomand
        notthispower2_clc:
        MOV ValCF, 0  ;command
        JMP Exit
    AND_Comm:
        CALL AND_Comm_PROC
    MOV_Comm:
        CALL MOV_Comm_PROC
    ADD_Comm:
        CALL ADD_Comm_PROC
    ADC_Comm:
        CALL ADC_Comm_PROC
    PUSH_Comm:
        CALL PUSH_Comm_PROC
    POP_Comm:
        CALL Op1Menu
        CALL CheckForbidCharProc

         

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
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_popax  
                ourExecPop ourValRegAX      
                jmp Exit
                notthispower1_popax:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_popax  
                ourExecPop ourValRegAX        
                notthispower2_popax:
                ExecPop ValRegAX
                JMP Exit
            PopOpRegBX:
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_popbx  
                ourExecPop ourValRegBX      
                jmp Exit
                notthispower1_popbx:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_popbx  
                ourExecPop ourValRegBX        
                notthispower2_popbx:
                ExecPop ValRegBX
                JMP Exit
            PopOpRegCX:
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_popcx  
                ourExecPop ourValRegCX      
                jmp Exit
                notthispower1_popcx:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_popcx  
                ourExecPop ourValRegCX        
                notthispower2_popcx:
                ExecPop ValRegCX
                JMP Exit
            PopOpRegDX:
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_popdx  
                ourExecPop ourValRegDX      
                jmp Exit
                notthispower1_popdx:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_popdx  
                ourExecPop ourValRegDX        
                notthispower2_popdx:
                ExecPop ValRegDX
                JMP Exit
            PopOpRegBP:
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_popbp  
                ourExecPop ourValRegBP      
                jmp Exit
                notthispower1_popbp:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_popbp  
                ourExecPop ourValRegBP        
                notthispower2_popbp:
                ExecPop ValRegBP
                JMP Exit
            PopOpRegSP:
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_popsp  
                ourExecPop ourValRegSP      
                jmp Exit
                notthispower1_popsp:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_popsp  
                ourExecPop ourValRegSP        
                notthispower2_popsp:
                ExecPop ValRegSP
                JMP Exit
            PopOpRegSI:
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_popsi  
                ourExecPop ourValRegSI     
                jmp Exit
                notthispower1_popsi:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_popsi  
                ourExecPop ourValRegSI        
                notthispower2_popsi:
                ExecPop ValRegSI
                JMP Exit
            PopOpRegDI:
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_popdi  
                ourExecPop ourValRegDI      
                jmp Exit
                notthispower1_popdi:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_popdi  
                ourExecPop ourValRegDI        
                notthispower2_popdi:
                ExecPop ValRegDI
                JMP Exit

        ; TODO - Mem as operand
        PopOpMem:
            mov si,0
                SearchForMempop:
                mov cx,si 
                cmp selectedOp2Mem,cl
                JNE Nextpop
                cmp selectedPUPType,1 ; our command
                jne notthispower1_popmem
                ourExecPopMem ourValMem[si] ; command
                jmp Exit
                notthispower1_popmem:  
                cmp selectedPUPType,2 ;his/her and our command 
                jne notthispower2_popmem 
                ourExecPopMem ourValMem[si] ;command
                notthispower2_popmem: 
                ExecPopMem ValMem[si]
                JMP Exit 
                Nextpop:
                inc si 
                jmp SearchForMempop

        
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
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_popaddbx  
                mov dx, ourValRegBX
                CALL CheckAddress
                cmp bl, 1               ; Value is greater than 16
                JZ InValidCommand
                mov SI, ourValRegBX
                ourExecPopMem ourValMem[SI]      
                jmp Exit
                notthispower1_popaddbx:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_popaddbx  
                mov dx, ourValRegBX
                CALL CheckAddress
                cmp bl, 1               ; Value is greater than 16
                JZ InValidCommand
                mov SI, ourValRegBX
                ourExecPopMem ourValMem[SI]       
                notthispower2_popaddbx:

                mov dx, ValRegBX
                CALL CheckAddress
                cmp bl, 1               ; Value is greater than 16
                JZ InValidCommand
                mov SI, ValRegBX
                ExecPopMem ValMem[SI]
                JMP Exit
            PopOpAddRegBP:
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_popaddbp  
                mov dx, ourValRegBP
                CALL CheckAddress
                cmp bl, 1               ; Value is greater than 16
                JZ InValidCommand
                mov SI, ourValRegBP
                ourExecPopMem ourValMem[SI]      
                jmp Exit
                notthispower1_popaddbp:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_popaddbp  
                mov dx, ourValRegBP
                CALL CheckAddress
                cmp bl, 1               ; Value is greater than 16
                JZ InValidCommand
                mov SI, ourValRegBP
                ourExecPopMem ourValMem[SI]       
                notthispower2_popaddbp:

                mov dx, ValRegBP
                CALL CheckAddress
                cmp bl, 1               ; Value is greater than 16
                JZ InValidCommand
                mov SI, ValRegBP
                ExecPopMem ValMem[SI]
                JMP Exit

            PopOpAddRegSI:
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_popaddsi  
                mov dx, ourValRegSI
                CALL CheckAddress
                cmp bl, 1               ; Value is greater than 16
                JZ InValidCommand
                mov SI, ourValRegSI
                ourExecPopMem ourValMem[SI]      
                jmp Exit
                notthispower1_popaddsi:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_popaddsi  
                mov dx, ourValRegSI
                CALL CheckAddress
                cmp bl, 1               ; Value is greater than 16
                JZ InValidCommand
                mov SI, ourValRegSI
                ourExecPopMem ourValMem[SI]       
                notthispower2_popaddsi:

                mov dx, ValRegSI
                CALL CheckAddress
                cmp bl, 1               ; Value is greater than 16
                JZ InValidCommand
                mov SI, ValRegSI
                ExecPopMem ValMem[SI]
                JMP Exit
            
            PopOpAddRegDI:
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_popadddi  
                mov dx, ourValRegDI
                CALL CheckAddress
                cmp bl, 1               ; Value is greater than 16
                JZ InValidCommand
                mov SI, ourValRegDI
                ourExecPopMem ourValMem[SI]      
                jmp Exit
                notthispower1_popadddi:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_popadddi  
                mov dx, ourValRegDI
                CALL CheckAddress
                cmp bl, 1               ; Value is greater than 16
                JZ InValidCommand
                mov SI, ourValRegDI
                ourExecPopMem ourValMem[SI]       
                notthispower2_popadddi:

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
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_incax  
                ExecINC ourValRegAX      
                jmp Exit
                notthispower1_incax:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_incax 
                ExecINC ourValRegAX       
                notthispower2_incax:
                ExecINC ValRegAX
                JMP Exit
            IncOpRegAL:
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_incal  
                ExecINC ourValRegAX      
                jmp Exit
                notthispower1_incal:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_incal 
                ExecINC ourValRegAX       
                notthispower2_incal:
                ExecINC ValRegAX
                JMP Exit
            IncOpRegAH:
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_incah  
                ExecINC ourValRegAX+1      
                jmp Exit
                notthispower1_incah:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_incah 
                ExecINC ourValRegAX+1       
                notthispower2_incah:
                ExecINC ValRegAX+1
                JMP Exit
            IncOpRegBX:
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_incbx  
                ExecINC ourValRegBX      
                jmp Exit
                notthispower1_incbx:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_incbx 
                ExecINC ourValRegBX       
                notthispower2_incbx:
                ExecINC ValRegBX
                JMP Exit
            IncOpRegBL:
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_incbl  
                ExecINC ourValRegBX      
                jmp Exit
                notthispower1_incbl:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_incbl 
                ExecINC ourValRegBX       
                notthispower2_incbl:
                ExecINC ValRegBX
                JMP Exit
            IncOpRegBH:
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_incbh  
                ExecINC ourValRegBX+1      
                jmp Exit
                notthispower1_incbh:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_incbh 
                ExecINC ourValRegBX+1       
                notthispower2_incbh:
                ExecINC ValRegBX+1
                JMP Exit
            IncOpRegCX:
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_inccx  
                ExecINC ourValRegCX      
                jmp Exit
                notthispower1_inccx:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_inccx 
                ExecINC ourValRegCX       
                notthispower2_inccx:
                ExecINC ValRegCX
                JMP Exit
            IncOpRegCL:
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_inccl  
                ExecINC ourValRegCX      
                jmp Exit
                notthispower1_inccl:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_inccl 
                ExecINC ourValRegCX       
                notthispower2_inccl:
                ExecINC ValRegCX
                JMP Exit
            IncOpRegCH:
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_incch  
                ExecINC ourValRegCX+1      
                jmp Exit
                notthispower1_incch:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_incch 
                ExecINC ourValRegCX+1       
                notthispower2_incch:
                ExecINC ValRegCX+1
                JMP Exit
            IncOpRegDX:  
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_incdx  
                ExecINC ourValRegDX      
                jmp Exit
                notthispower1_incdx:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_incdx 
                ExecINC ourValRegDX       
                notthispower2_incdx:
                ExecINC ValRegDX
                JMP Exit
            IncOpRegDL:
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_incdl  
                ExecINC ourValRegDX      
                jmp Exit
                notthispower1_incdl:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_incdl 
                ExecINC ourValRegDX       
                notthispower2_incdl:
                ExecINC ValRegDX
                JMP Exit
            IncOpRegDH:
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_incdh  
                ExecINC ourValRegDX+1      
                jmp Exit
                notthispower1_incdh:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_incdh 
                ExecINC ourValRegDX+1       
                notthispower2_incdh:
                ExecINC ValRegDX+1
                JMP Exit
            IncOpRegBP:
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_incbp  
                ExecINC ourValRegBP      
                jmp Exit
                notthispower1_incbp:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_incbp 
                ExecINC ourValRegBP       
                notthispower2_incbp:
                ExecINC ValRegBP
                JMP Exit
            IncOpRegSP:
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_incsp  
                ExecINC ourValRegSP      
                jmp Exit
                notthispower1_incsp:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_incsp 
                ExecINC ourValRegSP       
                notthispower2_incsp:
                ExecINC ValRegSP
                JMP Exit
            IncOpRegSI:
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_incsi  
                ExecINC ourValRegSI      
                jmp Exit
                notthispower1_incsi:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_incsi 
                ExecINC ourValRegSI       
                notthispower2_incsi:
                ExecINC ValRegSI
                JMP Exit
            IncOpRegDI:
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_incdi  
                ExecINC ourValRegDI      
                jmp Exit
                notthispower1_incdi:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_incdi 
                ExecINC ourValRegDI       
                notthispower2_incdi:
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
                
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_incaddbx  
                mov dx, ourValRegBX
                CALL CheckAddress
                cmp bl, 1
                jz InValidCommand
                mov di, ourValRegBX
                ExecINC ourValMem[di]      
                jmp Exit
                notthispower1_incaddbx:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_incaddbx  
                mov dx, ourValRegBX
                CALL CheckAddress
                cmp bl, 1
                jz InValidCommand
                mov di, ourValRegBX
                ExecINC ourValMem[di]  
                notthispower2_incaddbx:

                mov dx, ValRegBX
                CALL CheckAddress
                cmp bl, 1
                jz InValidCommand
                mov di, ValRegBX
                ExecINC ValMem[di]
                JMP Exit
            IncOpAddRegBP:
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_incaddbp  
                mov dx, ourValRegBP
                CALL CheckAddress
                cmp bl, 1
                jz InValidCommand
                mov di, ourValRegBP
                ExecINC ourValMem[di]      
                jmp Exit
                notthispower1_incaddbp:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_incaddbp  
                mov dx, ourValRegBP
                CALL CheckAddress
                cmp bl, 1
                jz InValidCommand
                mov di, ourValRegBP
                ExecINC ourValMem[di]  
                notthispower2_incaddbp:

                mov dx, ValRegBP
                CALL CheckAddress
                cmp bl, 1
                jz InValidCommand
                mov di, ValRegBP
                ExecINC ValMem[di]
                JMP Exit
            IncOpAddRegSP:
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_incaddsp  
                mov dx, ourValRegSP
                CALL CheckAddress
                cmp bl, 1
                jz InValidCommand
                mov di, ourValRegSP
                ExecINC ourValMem[di]      
                jmp Exit
                notthispower1_incaddsp:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_incaddsp  
                mov dx, ourValRegSP
                CALL CheckAddress
                cmp bl, 1
                jz InValidCommand
                mov di, ourValRegSP
                ExecINC ourValMem[di]  
                notthispower2_incaddsp:

                mov dx, ValRegSP
                CALL CheckAddress
                cmp bl, 1
                jz InValidCommand
                mov di, ValRegSP
                ExecINC ValMem[di]
                JMP Exit
            IncOpAddRegSI:
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_incaddsi  
                mov dx, ourValRegSI
                CALL CheckAddress
                cmp bl, 1
                jz InValidCommand
                mov di, ourValRegSI
                ExecINC ourValMem[di]      
                jmp Exit
                notthispower1_incaddsi:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_incaddsi 
                mov dx, ourValRegSI
                CALL CheckAddress
                cmp bl, 1
                jz InValidCommand
                mov di, ourValRegSI
                ExecINC ourValMem[di]  
                notthispower2_incaddsi:

                mov dx, ValRegSI
                CALL CheckAddress
                cmp bl, 1
                jz InValidCommand
                mov di, ValRegSI
                ExecINC ValMem[di]
                JMP Exit
            IncOpAddRegDI:
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_incadddi  
                mov dx, ourValRegDI
                CALL CheckAddress
                cmp bl, 1
                jz InValidCommand
                mov di, ourValRegDI
                ExecINC ourValMem[di]      
                jmp Exit
                notthispower1_incadddi:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_incadddi 
                mov dx, ourValRegDI
                CALL CheckAddress
                cmp bl, 1
                jz InValidCommand
                mov di, ourValRegDI
                ExecINC ourValMem[di]  
                notthispower2_incadddi:

                mov dx, ValRegDI
                CALL CheckAddress
                cmp bl, 1
                jz InValidCommand
                mov di, ValRegDI
                ExecINC ValMem[di]
                JMP Exit

        IncOpMem:

                mov si,0
                SearchForMeminc:
                mov cx,si 
                cmp selectedOp2Mem,cl
                JNE Nextinc
                cmp selectedPUPType,1 ; our command
                jne notthispower1_incmem
                ExecINC ourValMem[si] ; command
                jmp Exit
                notthispower1_incmem:  
                cmp selectedPUPType,2 ;his/her and our command 
                jne notthispower2_incmem 
                ExecINC ourValMem[si] ;command
                notthispower2_incmem: 
                ExecINC ValMem[si]
                JMP Exit 
                Nextinc:
                inc si 
                jmp SearchForMeminc

        JMP Exit
    
    DEC_Comm:
        DEC_Comm:
        CALL Op1Menu
        CALL CheckForbidCharProc
        
         

        CMP selectedOp1Type, 0
        JZ decOpReg
        CMP selectedOp1Type, 1
        JZ decOpAddReg
        CMP selectedOp1Type, 2
        JZ decOpMem
        JMP InValidCommand

        decOpReg:

            CMP selectedOp1Reg, 0
            JZ decOpRegAX
            CMP selectedOp1Reg, 1
            JZ decOpRegAL
            CMP selectedOp1Reg, 2
            JZ decOpRegAH
            CMP selectedOp1Reg, 3
            JZ decOpRegBX
            CMP selectedOp1Reg, 4
            JZ decOpRegBL
            CMP selectedOp1Reg, 5
            JZ decOpRegBH
            CMP selectedOp1Reg, 6
            JZ decOpRegCX
            CMP selectedOp1Reg, 7
            JZ decOpRegCL
            CMP selectedOp1Reg, 8
            JZ decOpRegCH
            CMP selectedOp1Reg, 9
            JZ decOpRegDX
            CMP selectedOp1Reg, 10
            JZ decOpRegDL
            CMP selectedOp1Reg, 11
            JZ decOpRegDH
            
            CMP selectedOp1Reg, 15
            JZ decOpRegBP
            CMP selectedOp1Reg, 16
            JZ decOpRegSP
            CMP selectedOp1Reg, 17
            JZ decOpRegSI
            CMP selectedOp1Reg, 18
            JZ decOpRegDI
            JMP InValidCommand


            
            decOpRegAX:
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_decax  
                Execdec ourValRegAX      
                jmp Exit
                notthispower1_decax:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_decax 
                Execdec ourValRegAX       
                notthispower2_decax:
                Execdec ValRegAX
                JMP Exit
            decOpRegAL:
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_decal  
                Execdec ourValRegAX      
                jmp Exit
                notthispower1_decal:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_decal 
                Execdec ourValRegAX       
                notthispower2_decal:
                Execdec ValRegAX
                JMP Exit
            decOpRegAH:
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_decah  
                Execdec ourValRegAX+1      
                jmp Exit
                notthispower1_decah:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_decah 
                Execdec ourValRegAX+1       
                notthispower2_decah:
                Execdec ValRegAX+1
                JMP Exit
            decOpRegBX:
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_decbx  
                Execdec ourValRegBX      
                jmp Exit
                notthispower1_decbx:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_decbx 
                Execdec ourValRegBX       
                notthispower2_decbx:
                Execdec ValRegBX
                JMP Exit
            decOpRegBL:
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_decbl  
                Execdec ourValRegBX      
                jmp Exit
                notthispower1_decbl:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_decbl 
                Execdec ourValRegBX       
                notthispower2_decbl:
                Execdec ValRegBX
                JMP Exit
            decOpRegBH:
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_decbh  
                Execdec ourValRegBX+1      
                jmp Exit
                notthispower1_decbh:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_decbh 
                Execdec ourValRegBX+1       
                notthispower2_decbh:
                Execdec ValRegBX+1
                JMP Exit
            decOpRegCX:
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_deccx  
                Execdec ourValRegCX      
                jmp Exit
                notthispower1_deccx:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_deccx 
                Execdec ourValRegCX       
                notthispower2_deccx:
                Execdec ValRegCX
                JMP Exit
            decOpRegCL:
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_deccl  
                Execdec ourValRegCX      
                jmp Exit
                notthispower1_deccl:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_deccl 
                Execdec ourValRegCX       
                notthispower2_deccl:
                Execdec ValRegCX
                JMP Exit
            decOpRegCH:
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_decch  
                Execdec ourValRegCX+1      
                jmp Exit
                notthispower1_decch:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_decch 
                Execdec ourValRegCX+1       
                notthispower2_decch:
                Execdec ValRegCX+1
                JMP Exit
            decOpRegDX:  
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_decdx  
                Execdec ourValRegDX      
                jmp Exit
                notthispower1_decdx:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_decdx 
                Execdec ourValRegDX       
                notthispower2_decdx:
                Execdec ValRegDX
                JMP Exit
            decOpRegDL:
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_decdl  
                Execdec ourValRegDX      
                jmp Exit
                notthispower1_decdl:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_decdl 
                Execdec ourValRegDX       
                notthispower2_decdl:
                Execdec ValRegDX
                JMP Exit
            decOpRegDH:
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_decdh  
                Execdec ourValRegDX+1      
                jmp Exit
                notthispower1_decdh:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_decdh 
                Execdec ourValRegDX+1       
                notthispower2_decdh:
                Execdec ValRegDX+1
                JMP Exit
            decOpRegBP:
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_decbp  
                Execdec ourValRegBP      
                jmp Exit
                notthispower1_decbp:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_decbp 
                Execdec ourValRegBP       
                notthispower2_decbp:
                Execdec ValRegBP
                JMP Exit
            decOpRegSP:
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_decsp  
                Execdec ourValRegSP      
                jmp Exit
                notthispower1_decsp:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_decsp 
                Execdec ourValRegSP       
                notthispower2_decsp:
                Execdec ValRegSP
                JMP Exit
            decOpRegSI:
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_decsi  
                Execdec ourValRegSI      
                jmp Exit
                notthispower1_decsi:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_decsi 
                Execdec ourValRegSI       
                notthispower2_decsi:
                Execdec ValRegSI
                JMP Exit
            decOpRegDI:
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_decdi  
                Execdec ourValRegDI      
                jmp Exit
                notthispower1_decdi:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_decdi 
                Execdec ourValRegDI       
                notthispower2_decdi:
                Execdec ValRegDI
                JMP Exit

        decOpAddReg:

            CMP selectedOp1Reg, 3
            JZ decOpAddRegBX
            CMP selectedOp1Reg, 15
            JZ decOpAddRegBP
            
            CMP selectedOp1Reg, 17
            JZ decOpAddRegSI
            CMP selectedOp1Reg, 18
            JZ decOpAddRegDI
            JMP InValidCommand


            
            
            decOpAddRegBX:
                
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_decaddbx  
                mov dx, ourValRegBX
                CALL CheckAddress
                cmp bl, 1
                jz InValidCommand
                mov di, ourValRegBX
                Execdec ourValMem[di]      
                jmp Exit
                notthispower1_decaddbx:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_decaddbx  
                mov dx, ourValRegBX
                CALL CheckAddress
                cmp bl, 1
                jz InValidCommand
                mov di, ourValRegBX
                Execdec ourValMem[di]  
                notthispower2_decaddbx:

                mov dx, ValRegBX
                CALL CheckAddress
                cmp bl, 1
                jz InValidCommand
                mov di, ValRegBX
                Execdec ValMem[di]
                JMP Exit
            decOpAddRegBP:
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_decaddbp  
                mov dx, ourValRegBP
                CALL CheckAddress
                cmp bl, 1
                jz InValidCommand
                mov di, ourValRegBP
                Execdec ourValMem[di]      
                jmp Exit
                notthispower1_decaddbp:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_decaddbp  
                mov dx, ourValRegBP
                CALL CheckAddress
                cmp bl, 1
                jz InValidCommand
                mov di, ourValRegBP
                Execdec ourValMem[di]  
                notthispower2_decaddbp:

                mov dx, ValRegBP
                CALL CheckAddress
                cmp bl, 1
                jz InValidCommand
                mov di, ValRegBP
                Execdec ValMem[di]
                JMP Exit
            decOpAddRegSP:
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_decaddsp  
                mov dx, ourValRegSP
                CALL CheckAddress
                cmp bl, 1
                jz InValidCommand
                mov di, ourValRegSP
                Execdec ourValMem[di]      
                jmp Exit
                notthispower1_decaddsp:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_decaddsp  
                mov dx, ourValRegSP
                CALL CheckAddress
                cmp bl, 1
                jz InValidCommand
                mov di, ourValRegSP
                Execdec ourValMem[di]  
                notthispower2_decaddsp:

                mov dx, ValRegSP
                CALL CheckAddress
                cmp bl, 1
                jz InValidCommand
                mov di, ValRegSP
                Execdec ValMem[di]
                JMP Exit
            decOpAddRegSI:
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_decaddsi  
                mov dx, ourValRegSI
                CALL CheckAddress
                cmp bl, 1
                jz InValidCommand
                mov di, ourValRegSI
                Execdec ourValMem[di]      
                jmp Exit
                notthispower1_decaddsi:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_decaddsi 
                mov dx, ourValRegSI
                CALL CheckAddress
                cmp bl, 1
                jz InValidCommand
                mov di, ourValRegSI
                Execdec ourValMem[di]  
                notthispower2_decaddsi:

                mov dx, ValRegSI
                CALL CheckAddress
                cmp bl, 1
                jz InValidCommand
                mov di, ValRegSI
                Execdec ValMem[di]
                JMP Exit
            decOpAddRegDI:
                cmp selectedPUPType,1 ;command on your own processor  
                jne notthispower1_decadddi  
                mov dx, ourValRegDI
                CALL CheckAddress
                cmp bl, 1
                jz InValidCommand
                mov di, ourValRegDI
                Execdec ourValMem[di]      
                jmp Exit
                notthispower1_decadddi:
                cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                jne notthispower2_decadddi 
                mov dx, ourValRegDI
                CALL CheckAddress
                cmp bl, 1
                jz InValidCommand
                mov di, ourValRegDI
                Execdec ourValMem[di]  
                notthispower2_decadddi:

                mov dx, ValRegDI
                CALL CheckAddress
                cmp bl, 1
                jz InValidCommand
                mov di, ValRegDI
                Execdec ValMem[di]
                JMP Exit

        decOpMem:
        
                mov si,0
                SearchForMemdec:
                mov cx,si 
                cmp selectedOp2Mem,cl
                JNE Nextdec
                cmp selectedPUPType,1 ; our command
                jne notthispower1_decmem
                Execdec ourValMem[si] ; command
                jmp Exit
                notthispower1_decmem:  
                cmp selectedPUPType,2 ;his/her and our command 
                jne notthispower2_decmem 
                Execdec ourValMem[si] ;command
                notthispower2_decmem: 
                Execdec ValMem[si]
                JMP Exit 
                Nextdec:
                dec si 
                jmp SearchForMemdec

        JMP Exit
    MUL_Comm:
        CALL Op1Menu

         
        CALL CheckForbidCharProc

        cmp selectedOp1Type, 0
        je MUL_Reg
        cmp selectedOp1Type, 1
        je MUL_AddMem
        cmp selectedOp1Type, 2
        je MUL_Mem
        cmp selectedOp1Type, 3
        je MUL_invalid
        MUL_Reg:
            cmp selectedOp1Reg, 0
            je MUL_Ax
            cmp selectedOp1Reg, 1
            je MUL_Al
            cmp selectedOp1Reg, 2
            je MUL_Ah
            cmp selectedOp1Reg, 3
            je MUL_Bx
            cmp selectedOp1Reg, 4
            je MUL_Bl
            cmp selectedOp1Reg, 5
            je MUL_Bh
            cmp selectedOp1Reg, 6
            je MUL_Cx
            cmp selectedOp1Reg, 7
            je MUL_Cl
            cmp selectedOp1Reg, 8
            je MUL_Ch
            cmp selectedOp1Reg, 9
            je MUL_Dx
            cmp selectedOp1Reg, 10
            je MUL_Dl
            cmp selectedOp1Reg, 11
            je MUL_Dh
            cmp selectedOp1Reg, 15
            je MUL_Bp
            cmp selectedOp1Reg, 16
            je MUL_Sp
            cmp selectedOp1Reg, 17
            je MUL_Si
            cmp selectedOp1Reg, 18
            je MUL_Di
            jmp MUL_invalid
            MUL_Ax:
                cmp selectedPUPType,1
                jne MUL_Ax_his
                MUL_Ax_our:
                mov ax,ourValRegAX
                mov dx,ourValRegDX
                MUL ax
                mov ourValRegAX,ax
                mov ourValRegDX,dx
                jmp Exit
                MUL_Ax_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                call LineStuckPwrUp
                MUL ax
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je MUL_Ax_our
                jmp Exit
            MUL_Al:
                cmp selectedPUPType,1
                jne MUL_Al_his
                MUL_Al_our:
                mov ax,ourValRegAX
                MUL al
                mov ourValRegAX,ax
                jmp Exit
                MUL_Al_his:
                mov ax,ValRegAX
                call LineStuckPwrUp
                MUL al
                mov ValRegAX,ax
                cmp selectedPUPType,2
                je MUL_Al_our
                jmp Exit
            MUL_Ah:
                cmp selectedPUPType,1
                jne MUL_Ah_his
                MUL_Ah_our:
                mov ax,ourValRegAX
                MUL ah
                mov ourValRegAX,ax
                jmp Exit
                MUL_Ah_his:
                mov ax,ValRegAX
                mov al,ah
                call LineStuckPwrUp
                MUL al
                mov ValRegAX,ax
                cmp selectedPUPType,2
                je MUL_Ah_our
                jmp Exit
            MUL_Bx:
                cmp selectedPUPType,1
                jne MUL_Bx_his
                MUL_Bx_our:
                mov ax,ourValRegAX
                mov dx,ourValRegDX
                mov bx,ourValRegBX
                MUL bx
                mov ourValRegAX,ax
                mov ourValRegDX,dx
                jmp Exit
                MUL_Bx_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov bx,ValRegBX
                push ax
                mov ax,bx
                call LineStuckPwrUp
                mov bx,ax
                pop ax
                MUL bx
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je MUL_Bx_our
                jmp Exit
            MUL_Bl:
                cmp selectedPUPType,1
                jne MUL_Bl_his
                MUL_Bl_our:
                mov ax,ourValRegAX
                mov bx,ourValRegBX
                MUL bl
                mov ourValRegAX,ax
                jmp Exit
                MUL_Bl_his:
                mov ax,ValRegAX
                mov bx,ValRegBX
                push ax
                mov ax,bx
                call LineStuckPwrUp
                mov bx,ax
                pop ax
                MUL bl
                mov ValRegAX,ax
                cmp selectedPUPType,2
                je MUL_Bl_our
                jmp Exit
            MUL_Bh:
                cmp selectedPUPType,1
                jne MUL_Bh_his
                MUL_Bh_our:
                mov ax,ourValRegAX
                mov bx,ourValRegBX
                MUL Bh
                mov ourValRegAX,ax
                jmp Exit
                MUL_Bh_his:
                mov ax,ValRegAX
                mov bx,ValRegBX
                push ax
                mov ax,bx
                call LineStuckPwrUp
                mov bx,ax
                pop ax
                MUL Bh
                mov ValRegAX,ax
                cmp selectedPUPType,2
                je MUL_Bh_our
                jmp Exit
            MUL_Cx:
                cmp selectedPUPType,1
                jne MUL_Cx_his
                MUL_Cx_our:
                mov ax,ourValRegAX
                mov dx,ourValRegDX
                mov Cx,ourValRegCx
                MUL Cx
                mov ourValRegAX,ax
                mov ourValRegDX,dx
                jmp Exit
                MUL_Cx_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov Cx,ValRegCx
                push ax
                mov ax,cx
                call LineStuckPwrUp
                mov cx,ax
                pop ax
                MUL Cx
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je MUL_Cx_our
                jmp Exit
            MUL_Cl:
                cmp selectedPUPType,1
                jne MUL_Cl_his
                MUL_Cl_our:
                mov ax,ourValRegAX
                mov Cx,ourValRegCx
                MUL Cl
                mov ourValRegAX,ax
                jmp Exit
                MUL_Cl_his:
                mov ax,ValRegAX
                mov Cx,ValRegCx
                push ax
                mov ax,cx
                call LineStuckPwrUp
                mov cx,ax
                pop ax
                MUL Cl
                mov ValRegAX,ax
                cmp selectedPUPType,2
                je MUL_Cl_our
                jmp Exit
            MUL_Ch:
                cmp selectedPUPType,1
                jne MUL_Ch_his
                MUL_Ch_our:
                mov ax,ourValRegAX
                mov Cx,ourValRegCx
                MUL Ch
                mov ourValRegAX,ax
                jmp Exit
                MUL_Ch_his:
                mov ax,ValRegAX
                mov Cx,ValRegCx
                push ax
                mov ax,cx
                call LineStuckPwrUp
                mov cx,ax
                pop ax
                MUL Ch
                mov ValRegAX,ax
                cmp selectedPUPType,2
                je MUL_Ch_our
                jmp Exit
            MUL_Dx:
                cmp selectedPUPType,1
                jne MUL_Dx_his
                MUL_Dx_our:
                mov ax,ValRegAX
                mov dx,ValRegDX
                MUL dx
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
                MUL_Dx_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                push ax
                mov ax,dx
                call LineStuckPwrUp
                mov dx,ax
                pop ax
                MUL dx
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je MUL_Dx_our
                jmp Exit
            MUL_Dl:
                cmp selectedPUPType,1
                jne MUL_Dl_his
                MUL_Dl_our:
                mov ax,ourValRegAX
                mov dx,ourValRegBX
                MUL dl
                mov ourValRegAX,ax
                jmp Exit
                MUL_Dl_his:
                mov ax,ValRegAX
                mov dx,ValRegBX
                push ax
                mov ax,dx
                call LineStuckPwrUp
                mov dx,ax
                pop ax
                MUL dl
                mov ValRegAX,ax
                cmp selectedPUPType,2
                je MUL_Dl_our
                jmp Exit
            MUL_Dh:
                cmp selectedPUPType,1
                jne MUL_Dh_his
                MUL_Dh_our:
                mov ax,ourValRegAX
                mov dx,ourValRegBX
                MUL Dh
                mov ourValRegAX,ax
                jmp Exit
                MUL_Dh_his:
                mov ax,ValRegAX
                mov dx,ValRegBX
                push ax
                mov ax,dx
                call LineStuckPwrUp
                mov dx,ax
                pop ax
                MUL Dh
                mov ValRegAX,ax
                cmp selectedPUPType,2
                je MUL_Dh_our
                jmp Exit
            MUL_Bp:
                cmp selectedPUPType,1
                jne MUL_Bp_his
                MUL_Bp_our:
                mov ax,ourValRegAX
                mov dx,ourValRegDX
                mov Bp,ourValRegBp
                MUL Bp
                mov ourValRegAX,ax
                mov ourValRegDX,dx
                jmp Exit
                MUL_Bp_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov Bp,ValRegBp
                push ax
                mov ax,bp
                call LineStuckPwrUp
                mov bp,ax
                pop ax
                MUL Bp
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je MUL_Bp_our
                jmp Exit
            MUL_Sp:
                cmp selectedPUPType,1
                jne MUL_Sp_his
                MUL_Sp_our:
                mov ax,ourValRegAX
                mov dx,ourValRegDX
                mov Sp,ourValRegSp
                MUL Sp
                mov ourValRegAX,ax
                mov ourValRegDX,dx
                jmp Exit
                MUL_Sp_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov Sp,ValRegSp
                push ax
                mov ax,sp
                call LineStuckPwrUp
                mov sp,ax
                pop ax
                MUL Sp
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je MUL_Sp_our
                jmp Exit
            MUL_Si:
                cmp selectedPUPType,1
                jne MUL_Si_his
                MUL_Si_our:
                mov ax,ourValRegAX
                mov dx,ourValRegDX
                mov Si,ourValRegSi
                MUL Si
                mov ourValRegAX,ax
                mov ourValRegDX,dx
                jmp Exit
                MUL_Si_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov Si,ValRegSi
                push ax
                mov ax,si
                call LineStuckPwrUp
                mov si,ax
                pop ax
                MUL Si
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je MUL_Si_our
                jmp Exit
            MUL_di:
                MUL_Di:
                cmp selectedPUPType,1
                jne MUL_Di_his
                MUL_Di_our:
                mov ax,ourValRegAX
                mov dx,ourValRegDX
                mov Di,ourValRegDi
                MUL Di
                mov ourValRegAX,ax
                mov ourValRegDX,dx
                jmp Exit
                MUL_Di_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov Di,ValRegDi
                push ax
                mov ax,di
                call LineStuckPwrUp
                mov di,ax
                pop ax
                MUL Di
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je MUL_Di_our
                jmp Exit
        MUL_AddMem:
            cmp selectedOp1AddReg, 3
            je MUL_AddBx
            cmp selectedOp1AddReg, 15
            je MUL_AddBp
            cmp selectedOp1AddReg, 17
            je MUL_AddSi
            cmp selectedOp1AddReg, 18
            je MUL_AddDi
            jmp MUL_invalid
            MUL_AddBx:
                cmp selectedPUPType,1
                jne MUL_AddBx_his
                MUL_AddBx_our:
                mov ax,ourValRegAX
                mov dx,ourValRegDX
                mov bx,ourValRegBX
                cmp bx,15d
                ja MUL_invalid
                MUL ourValMem[bx]
                mov ourValRegAX,ax
                mov ourValRegDX,dx
                jmp Exit
                MUL_AddBx_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov bx,ValRegBX
                cmp bx,15d
                ja MUL_invalid
                push ax
                mov al,ValMem[bx]
                call LineStuckPwrUp
                mov cl,al
                pop ax
                MUL cl
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je MUL_AddBx_our
                jmp Exit
            MUL_AddBp:
                cmp selectedPUPType,1
                jne MUL_AddBp_his
                MUL_AddBp_our:
                mov ax,ourValRegAX
                mov dx,ourValRegDX
                mov Bp,ourValRegBp
                cmp Bp,15d
                ja MUL_invalid
                MUL ourValMem[bp]
                mov ourValRegAX,ax
                mov ourValRegDX,dx
                jmp Exit
                MUL_AddBp_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov Bp,ValRegBp
                cmp Bp,15d
                ja MUL_invalid
                push ax
                mov al,ValMem[bp]
                call LineStuckPwrUp
                mov cl,al
                pop ax
                MUL cl
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je MUL_AddBp_our
                jmp Exit
            MUL_AddSi:
                cmp selectedPUPType,1
                jne MUL_AddSi_his
                MUL_AddSi_our:
                mov ax,ourValRegAX
                mov dx,ourValRegDX
                mov Si,ourValRegSi
                cmp Si,15d
                ja MUL_invalid
                MUL ourValMem[si]
                mov ourValRegAX,ax
                mov ourValRegDX,dx
                jmp Exit
                MUL_AddSi_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov Si,ValRegSi
                cmp Si,15d
                ja MUL_invalid
                push ax
                mov al,ValMem[si]
                call LineStuckPwrUp
                mov cl,al
                pop ax
                MUL cl
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je MUL_AddSi_our
                jmp Exit
            MUL_AddDi:
                cmp selectedPUPType,1
                jne MUL_AddDi_his
                MUL_AddDi_our:
                mov ax,ourValRegAX
                mov dx,ourValRegDX
                mov Di,ourValRegDi
                cmp Di,15d
                ja MUL_invalid
                MUL ourValMem[di]
                mov ourValRegAX,ax
                mov ourValRegDX,dx
                jmp Exit
                MUL_AddDi_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov Di,ValRegDi
                cmp Di,15d
                ja MUL_invalid
                push ax
                mov al,ValMem[di]
                call LineStuckPwrUp
                mov cl,al
                pop ax
                MUL cl
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je MUL_AddDi_our
                jmp Exit
        mov si,0
        MUL_Mem:
            mov bx,si
            cmp selectedOp2Mem,bl
            jne MUL_NotIt
                cmp selectedPUPType,1
                jne MUL_Mem_his
                MUL_Mem_our:
                mov ax,ourValRegAX
                mov dx,ourValRegDX
                MUL ourValMem[si]
                mov ourValRegAX,ax
                mov ourValRegDX,dx
                jmp Exit
                MUL_Mem_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                push ax
                mov al,ValMem[si]
                call LineStuckPwrUp
                mov cl,al
                pop ax
                MUL cl
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je MUL_Mem_our
                jmp Exit
            MUL_NotIt:
            inc si
            jmp MUL_Mem
        MUL_invalid:
        jmp InValidCommand
        JMP Exit
    DIV_Comm:
        CALL Op1Menu

         
        CALL CheckForbidCharProc

        cmp selectedOp1Type, 0
        je DIV_Reg
        cmp selectedOp1Type, 1
        je DIV_AddMem
        cmp selectedOp1Type, 2
        je DIV_Mem
        cmp selectedOp1Type, 3
        je DIV_invalid
        DIV_Reg:
            cmp selectedOp1Reg, 0
            je DIV_Ax
            cmp selectedOp1Reg, 1
            je DIV_Al
            cmp selectedOp1Reg, 2
            je DIV_Ah
            cmp selectedOp1Reg, 3
            je DIV_Bx
            cmp selectedOp1Reg, 4
            je DIV_Bl
            cmp selectedOp1Reg, 5
            je DIV_Bh
            cmp selectedOp1Reg, 6
            je DIV_Cx
            cmp selectedOp1Reg, 7
            je DIV_Cl
            cmp selectedOp1Reg, 8
            je DIV_Ch
            cmp selectedOp1Reg, 9
            je DIV_Dx
            cmp selectedOp1Reg, 10
            je DIV_Dl
            cmp selectedOp1Reg, 11
            je DIV_Dh
            cmp selectedOp1Reg, 15
            je DIV_Bp
            cmp selectedOp1Reg, 16
            je DIV_Sp
            cmp selectedOp1Reg, 17
            je DIV_Si
            cmp selectedOp1Reg, 18
            je DIV_Di
            jmp DIV_invalid
            DIV_Ax:
                cmp selectedPUPType,1
                jne DIV_Ax_his
                DIV_Ax_our:
                mov ax,ourValRegAX
                mov dx,ourValRegDX
                DIV ax
                mov ourValRegAX,ax
                mov ourValRegDX,dx
                jmp Exit
                DIV_Ax_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                call LineStuckPwrUp
                DIV ax
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je DIV_Ax_our
                jmp Exit
            DIV_Al:
                cmp selectedPUPType,1
                jne DIV_Al_his
                DIV_Al_our:
                mov ax,ourValRegAX
                DIV al
                mov ourValRegAX,ax
                jmp Exit
                DIV_Al_his:
                mov ax,ValRegAX
                call LineStuckPwrUp
                DIV al
                mov ValRegAX,ax
                cmp selectedPUPType,2
                je DIV_Al_our
                jmp Exit
            DIV_Ah:
                cmp selectedPUPType,1
                jne DIV_Ah_his
                DIV_Ah_our:
                mov ax,ourValRegAX
                DIV ah
                mov ourValRegAX,ax
                jmp Exit
                DIV_Ah_his:
                mov ax,ValRegAX
                mov al,ah
                call LineStuckPwrUp
                DIV al
                mov ValRegAX,ax
                cmp selectedPUPType,2
                je DIV_Ah_our
                jmp Exit
            DIV_Bx:
                cmp selectedPUPType,1
                jne DIV_Bx_his
                DIV_Bx_our:
                mov ax,ourValRegAX
                mov dx,ourValRegDX
                mov bx,ourValRegBX
                DIV bx
                mov ourValRegAX,ax
                mov ourValRegDX,dx
                jmp Exit
                DIV_Bx_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov bx,ValRegBX
                push ax
                mov ax,bx
                call LineStuckPwrUp
                mov bx,ax
                pop ax
                DIV bx
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je DIV_Bx_our
                jmp Exit
            DIV_Bl:
                cmp selectedPUPType,1
                jne DIV_Bl_his
                DIV_Bl_our:
                mov ax,ourValRegAX
                mov bx,ourValRegBX
                DIV bl
                mov ourValRegAX,ax
                jmp Exit
                DIV_Bl_his:
                mov ax,ValRegAX
                mov bx,ValRegBX
                push ax
                mov ax,bx
                call LineStuckPwrUp
                mov bx,ax
                pop ax
                DIV bl
                mov ValRegAX,ax
                cmp selectedPUPType,2
                je DIV_Bl_our
                jmp Exit
            DIV_Bh:
                cmp selectedPUPType,1
                jne DIV_Bh_his
                DIV_Bh_our:
                mov ax,ourValRegAX
                mov bx,ourValRegBX
                DIV Bh
                mov ourValRegAX,ax
                jmp Exit
                DIV_Bh_his:
                mov ax,ValRegAX
                mov bx,ValRegBX
                push ax
                mov ax,bx
                call LineStuckPwrUp
                mov bx,ax
                pop ax
                DIV Bh
                mov ValRegAX,ax
                cmp selectedPUPType,2
                je DIV_Bh_our
                jmp Exit
            DIV_Cx:
                cmp selectedPUPType,1
                jne DIV_Cx_his
                DIV_Cx_our:
                mov ax,ourValRegAX
                mov dx,ourValRegDX
                mov Cx,ourValRegCx
                DIV Cx
                mov ourValRegAX,ax
                mov ourValRegDX,dx
                jmp Exit
                DIV_Cx_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov Cx,ValRegCx
                push ax
                mov ax,cx
                call LineStuckPwrUp
                mov cx,ax
                pop ax
                DIV Cx
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je DIV_Cx_our
                jmp Exit
            DIV_Cl:
                cmp selectedPUPType,1
                jne DIV_Cl_his
                DIV_Cl_our:
                mov ax,ourValRegAX
                mov Cx,ourValRegCx
                DIV Cl
                mov ourValRegAX,ax
                jmp Exit
                DIV_Cl_his:
                mov ax,ValRegAX
                mov Cx,ValRegCx
                push ax
                mov ax,cx
                call LineStuckPwrUp
                mov cx,ax
                pop ax
                DIV Cl
                mov ValRegAX,ax
                cmp selectedPUPType,2
                je DIV_Cl_our
                jmp Exit
            DIV_Ch:
                cmp selectedPUPType,1
                jne DIV_Ch_his
                DIV_Ch_our:
                mov ax,ourValRegAX
                mov Cx,ourValRegCx
                DIV Ch
                mov ourValRegAX,ax
                jmp Exit
                DIV_Ch_his:
                mov ax,ValRegAX
                mov Cx,ValRegCx
                push ax
                mov ax,cx
                call LineStuckPwrUp
                mov cx,ax
                pop ax
                DIV Ch
                mov ValRegAX,ax
                cmp selectedPUPType,2
                je DIV_Ch_our
                jmp Exit
            DIV_Dx:
                cmp selectedPUPType,1
                jne DIV_Dx_his
                DIV_Dx_our:
                mov ax,ValRegAX
                mov dx,ValRegDX
                DIV dx
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
                DIV_Dx_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                push ax
                mov ax,dx
                call LineStuckPwrUp
                mov dx,ax
                pop ax
                DIV dx
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je DIV_Dx_our
                jmp Exit
            DIV_Dl:
                cmp selectedPUPType,1
                jne DIV_Dl_his
                DIV_Dl_our:
                mov ax,ourValRegAX
                mov dx,ourValRegBX
                DIV dl
                mov ourValRegAX,ax
                jmp Exit
                DIV_Dl_his:
                mov ax,ValRegAX
                mov dx,ValRegBX
                push ax
                mov ax,dx
                call LineStuckPwrUp
                mov dx,ax
                pop ax
                DIV dl
                mov ValRegAX,ax
                cmp selectedPUPType,2
                je DIV_Dl_our
                jmp Exit
            DIV_Dh:
                cmp selectedPUPType,1
                jne DIV_Dh_his
                DIV_Dh_our:
                mov ax,ourValRegAX
                mov dx,ourValRegBX
                DIV Dh
                mov ourValRegAX,ax
                jmp Exit
                DIV_Dh_his:
                mov ax,ValRegAX
                mov dx,ValRegBX
                push ax
                mov ax,dx
                call LineStuckPwrUp
                mov dx,ax
                pop ax
                DIV Dh
                mov ValRegAX,ax
                cmp selectedPUPType,2
                je DIV_Dh_our
                jmp Exit
            DIV_Bp:
                cmp selectedPUPType,1
                jne DIV_Bp_his
                DIV_Bp_our:
                mov ax,ourValRegAX
                mov dx,ourValRegDX
                mov Bp,ourValRegBp
                DIV Bp
                mov ourValRegAX,ax
                mov ourValRegDX,dx
                jmp Exit
                DIV_Bp_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov Bp,ValRegBp
                push ax
                mov ax,bp
                call LineStuckPwrUp
                mov bp,ax
                pop ax
                DIV Bp
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je DIV_Bp_our
                jmp Exit
            DIV_Sp:
                cmp selectedPUPType,1
                jne DIV_Sp_his
                DIV_Sp_our:
                mov ax,ourValRegAX
                mov dx,ourValRegDX
                mov Sp,ourValRegSp
                DIV Sp
                mov ourValRegAX,ax
                mov ourValRegDX,dx
                jmp Exit
                DIV_Sp_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov Sp,ValRegSp
                push ax
                mov ax,sp
                call LineStuckPwrUp
                mov sp,ax
                pop ax
                DIV Sp
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je DIV_Sp_our
                jmp Exit
            DIV_Si:
                cmp selectedPUPType,1
                jne DIV_Si_his
                DIV_Si_our:
                mov ax,ourValRegAX
                mov dx,ourValRegDX
                mov Si,ourValRegSi
                DIV Si
                mov ourValRegAX,ax
                mov ourValRegDX,dx
                jmp Exit
                DIV_Si_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov Si,ValRegSi
                push ax
                mov ax,si
                call LineStuckPwrUp
                mov si,ax
                pop ax
                DIV Si
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je DIV_Si_our
                jmp Exit
            DIV_di:
                DIV_Di:
                cmp selectedPUPType,1
                jne DIV_Di_his
                DIV_Di_our:
                mov ax,ourValRegAX
                mov dx,ourValRegDX
                mov Di,ourValRegDi
                DIV Di
                mov ourValRegAX,ax
                mov ourValRegDX,dx
                jmp Exit
                DIV_Di_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov Di,ValRegDi
                push ax
                mov ax,di
                call LineStuckPwrUp
                mov di,ax
                pop ax
                DIV Di
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je DIV_Di_our
                jmp Exit
        DIV_AddMem:
            cmp selectedOp1AddReg, 3
            je DIV_AddBx
            cmp selectedOp1AddReg, 15
            je DIV_AddBp
            cmp selectedOp1AddReg, 17
            je DIV_AddSi
            cmp selectedOp1AddReg, 18
            je DIV_AddDi
            jmp DIV_invalid
            DIV_AddBx:
                cmp selectedPUPType,1
                jne DIV_AddBx_his
                DIV_AddBx_our:
                mov ax,ourValRegAX
                mov dx,ourValRegDX
                mov bx,ourValRegBX
                cmp bx,15d
                ja DIV_invalid
                DIV ourValMem[bx]
                mov ourValRegAX,ax
                mov ourValRegDX,dx
                jmp Exit
                DIV_AddBx_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov bx,ValRegBX
                cmp bx,15d
                ja DIV_invalid
                push ax
                mov al,ValMem[bx]
                call LineStuckPwrUp
                mov cl,al
                pop ax
                DIV cl
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je DIV_AddBx_our
                jmp Exit
            DIV_AddBp:
                cmp selectedPUPType,1
                jne DIV_AddBp_his
                DIV_AddBp_our:
                mov ax,ourValRegAX
                mov dx,ourValRegDX
                mov Bp,ourValRegBp
                cmp Bp,15d
                ja DIV_invalid
                DIV ourValMem[bp]
                mov ourValRegAX,ax
                mov ourValRegDX,dx
                jmp Exit
                DIV_AddBp_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov Bp,ValRegBp
                cmp Bp,15d
                ja DIV_invalid
                push ax
                mov al,ValMem[bp]
                call LineStuckPwrUp
                mov cl,al
                pop ax
                DIV cl
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je DIV_AddBp_our
                jmp Exit
            DIV_AddSi:
                cmp selectedPUPType,1
                jne DIV_AddSi_his
                DIV_AddSi_our:
                mov ax,ourValRegAX
                mov dx,ourValRegDX
                mov Si,ourValRegSi
                cmp Si,15d
                ja DIV_invalid
                DIV ourValMem[si]
                mov ourValRegAX,ax
                mov ourValRegDX,dx
                jmp Exit
                DIV_AddSi_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov Si,ValRegSi
                cmp Si,15d
                ja DIV_invalid
                push ax
                mov al,ValMem[si]
                call LineStuckPwrUp
                mov cl,al
                pop ax
                DIV cl
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je DIV_AddSi_our
                jmp Exit
            DIV_AddDi:
                cmp selectedPUPType,1
                jne DIV_AddDi_his
                DIV_AddDi_our:
                mov ax,ourValRegAX
                mov dx,ourValRegDX
                mov Di,ourValRegDi
                cmp Di,15d
                ja DIV_invalid
                DIV ourValMem[di]
                mov ourValRegAX,ax
                mov ourValRegDX,dx
                jmp Exit
                DIV_AddDi_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov Di,ValRegDi
                cmp Di,15d
                ja DIV_invalid
                push ax
                mov al,ValMem[di]
                call LineStuckPwrUp
                mov cl,al
                pop ax
                DIV cl
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je DIV_AddDi_our
                jmp Exit
        mov si,0
        DIV_Mem:
            mov bx,si
            cmp selectedOp2Mem,bl
            jne DIV_NotIt
                cmp selectedPUPType,1
                jne DIV_Mem_his
                DIV_Mem_our:
                mov ax,ourValRegAX
                mov dx,ourValRegDX
                DIV ourValMem[si]
                mov ourValRegAX,ax
                mov ourValRegDX,dx
                jmp Exit
                DIV_Mem_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                push ax
                mov al,ValMem[si]
                call LineStuckPwrUp
                mov cl,al
                pop ax
                DIV cl
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je DIV_Mem_our
                jmp Exit
            DIV_NotIt:
            inc si
            jmp DIV_Mem
        DIV_invalid:
        jmp InValidCommand
        JMP Exit
    IMul_Comm:
        CALL Op1Menu

         
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
                cmp selectedPUPType,1
                jne IMul_Ax_his
                IMul_Ax_our:
                mov ax,ourValRegAX
                mov dx,ourValRegDX
                IMul ax
                mov ourValRegAX,ax
                mov ourValRegDX,dx
                jmp Exit
                IMul_Ax_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                call LineStuckPwrUp
                IMul ax
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je IMul_Ax_our
                jmp Exit
            IMul_Al:
                cmp selectedPUPType,1
                jne IMul_Al_his
                IMul_Al_our:
                mov ax,ourValRegAX
                IMul al
                mov ourValRegAX,ax
                jmp Exit
                IMul_Al_his:
                mov ax,ValRegAX
                call LineStuckPwrUp
                IMul al
                mov ValRegAX,ax
                cmp selectedPUPType,2
                je IMul_Al_our
                jmp Exit
            IMul_Ah:
                cmp selectedPUPType,1
                jne IMul_Ah_his
                IMul_Ah_our:
                mov ax,ourValRegAX
                IMul ah
                mov ourValRegAX,ax
                jmp Exit
                IMul_Ah_his:
                mov ax,ValRegAX
                mov al,ah
                call LineStuckPwrUp
                IMul al
                mov ValRegAX,ax
                cmp selectedPUPType,2
                je IMul_Ah_our
                jmp Exit
            IMul_Bx:
                cmp selectedPUPType,1
                jne IMul_Bx_his
                IMul_Bx_our:
                mov ax,ourValRegAX
                mov dx,ourValRegDX
                mov bx,ourValRegBX
                IMul bx
                mov ourValRegAX,ax
                mov ourValRegDX,dx
                jmp Exit
                IMul_Bx_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov bx,ValRegBX
                push ax
                mov ax,bx
                call LineStuckPwrUp
                mov bx,ax
                pop ax
                IMul bx
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je IMul_Bx_our
                jmp Exit
            IMul_Bl:
                cmp selectedPUPType,1
                jne IMul_Bl_his
                IMul_Bl_our:
                mov ax,ourValRegAX
                mov bx,ourValRegBX
                IMul bl
                mov ourValRegAX,ax
                jmp Exit
                IMul_Bl_his:
                mov ax,ValRegAX
                mov bx,ValRegBX
                push ax
                mov ax,bx
                call LineStuckPwrUp
                mov bx,ax
                pop ax
                IMul bl
                mov ValRegAX,ax
                cmp selectedPUPType,2
                je IMul_Bl_our
                jmp Exit
            IMul_Bh:
                cmp selectedPUPType,1
                jne IMul_Bh_his
                IMul_Bh_our:
                mov ax,ourValRegAX
                mov bx,ourValRegBX
                IMul Bh
                mov ourValRegAX,ax
                jmp Exit
                IMul_Bh_his:
                mov ax,ValRegAX
                mov bx,ValRegBX
                push ax
                mov ax,bx
                call LineStuckPwrUp
                mov bx,ax
                pop ax
                IMul Bh
                mov ValRegAX,ax
                cmp selectedPUPType,2
                je IMul_Bh_our
                jmp Exit
            IMul_Cx:
                cmp selectedPUPType,1
                jne IMul_Cx_his
                IMul_Cx_our:
                mov ax,ourValRegAX
                mov dx,ourValRegDX
                mov Cx,ourValRegCx
                IMul Cx
                mov ourValRegAX,ax
                mov ourValRegDX,dx
                jmp Exit
                IMul_Cx_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov Cx,ValRegCx
                push ax
                mov ax,cx
                call LineStuckPwrUp
                mov cx,ax
                pop ax
                IMul Cx
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je IMul_Cx_our
                jmp Exit
            IMul_Cl:
                cmp selectedPUPType,1
                jne IMul_Cl_his
                IMul_Cl_our:
                mov ax,ourValRegAX
                mov Cx,ourValRegCx
                IMul Cl
                mov ourValRegAX,ax
                jmp Exit
                IMul_Cl_his:
                mov ax,ValRegAX
                mov Cx,ValRegCx
                push ax
                mov ax,cx
                call LineStuckPwrUp
                mov cx,ax
                pop ax
                IMul Cl
                mov ValRegAX,ax
                cmp selectedPUPType,2
                je IMul_Cl_our
                jmp Exit
            IMul_Ch:
                cmp selectedPUPType,1
                jne IMul_Ch_his
                IMul_Ch_our:
                mov ax,ourValRegAX
                mov Cx,ourValRegCx
                IMul Ch
                mov ourValRegAX,ax
                jmp Exit
                IMul_Ch_his:
                mov ax,ValRegAX
                mov Cx,ValRegCx
                push ax
                mov ax,cx
                call LineStuckPwrUp
                mov cx,ax
                pop ax
                IMul Ch
                mov ValRegAX,ax
                cmp selectedPUPType,2
                je IMul_Ch_our
                jmp Exit
            IMul_Dx:
                cmp selectedPUPType,1
                jne IMul_Dx_his
                IMul_Dx_our:
                mov ax,ValRegAX
                mov dx,ValRegDX
                IMul dx
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
                IMul_Dx_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                push ax
                mov ax,dx
                call LineStuckPwrUp
                mov dx,ax
                pop ax
                IMul dx
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je IMul_Dx_our
                jmp Exit
            IMul_Dl:
                cmp selectedPUPType,1
                jne IMul_Dl_his
                IMul_Dl_our:
                mov ax,ourValRegAX
                mov dx,ourValRegBX
                IMul dl
                mov ourValRegAX,ax
                jmp Exit
                IMul_Dl_his:
                mov ax,ValRegAX
                mov dx,ValRegBX
                push ax
                mov ax,dx
                call LineStuckPwrUp
                mov dx,ax
                pop ax
                IMul dl
                mov ValRegAX,ax
                cmp selectedPUPType,2
                je IMul_Dl_our
                jmp Exit
            IMul_Dh:
                cmp selectedPUPType,1
                jne IMul_Dh_his
                IMul_Dh_our:
                mov ax,ourValRegAX
                mov dx,ourValRegBX
                IMul Dh
                mov ourValRegAX,ax
                jmp Exit
                IMul_Dh_his:
                mov ax,ValRegAX
                mov dx,ValRegBX
                push ax
                mov ax,dx
                call LineStuckPwrUp
                mov dx,ax
                pop ax
                IMul Dh
                mov ValRegAX,ax
                cmp selectedPUPType,2
                je IMul_Dh_our
                jmp Exit
            IMul_Bp:
                cmp selectedPUPType,1
                jne IMul_Bp_his
                IMul_Bp_our:
                mov ax,ourValRegAX
                mov dx,ourValRegDX
                mov Bp,ourValRegBp
                IMul Bp
                mov ourValRegAX,ax
                mov ourValRegDX,dx
                jmp Exit
                IMul_Bp_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov Bp,ValRegBp
                push ax
                mov ax,bp
                call LineStuckPwrUp
                mov bp,ax
                pop ax
                IMul Bp
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je IMul_Bp_our
                jmp Exit
            IMul_Sp:
                cmp selectedPUPType,1
                jne IMul_Sp_his
                IMul_Sp_our:
                mov ax,ourValRegAX
                mov dx,ourValRegDX
                mov Sp,ourValRegSp
                IMul Sp
                mov ourValRegAX,ax
                mov ourValRegDX,dx
                jmp Exit
                IMul_Sp_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov Sp,ValRegSp
                push ax
                mov ax,sp
                call LineStuckPwrUp
                mov sp,ax
                pop ax
                IMul Sp
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je IMul_Sp_our
                jmp Exit
            IMul_Si:
                cmp selectedPUPType,1
                jne IMul_Si_his
                IMul_Si_our:
                mov ax,ourValRegAX
                mov dx,ourValRegDX
                mov Si,ourValRegSi
                IMul Si
                mov ourValRegAX,ax
                mov ourValRegDX,dx
                jmp Exit
                IMul_Si_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov Si,ValRegSi
                push ax
                mov ax,si
                call LineStuckPwrUp
                mov si,ax
                pop ax
                IMul Si
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je IMul_Si_our
                jmp Exit
            IMul_di:
                IMul_Di:
                cmp selectedPUPType,1
                jne IMul_Di_his
                IMul_Di_our:
                mov ax,ourValRegAX
                mov dx,ourValRegDX
                mov Di,ourValRegDi
                IMul Di
                mov ourValRegAX,ax
                mov ourValRegDX,dx
                jmp Exit
                IMul_Di_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov Di,ValRegDi
                push ax
                mov ax,di
                call LineStuckPwrUp
                mov di,ax
                pop ax
                IMul Di
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je IMul_Di_our
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
                cmp selectedPUPType,1
                jne IMul_AddBx_his
                IMul_AddBx_our:
                mov ax,ourValRegAX
                mov dx,ourValRegDX
                mov bx,ourValRegBX
                cmp bx,15d
                ja IMul_invalid
                IMul ourValMem[bx]
                mov ourValRegAX,ax
                mov ourValRegDX,dx
                jmp Exit
                IMul_AddBx_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov bx,ValRegBX
                cmp bx,15d
                ja IMul_invalid
                push ax
                mov al,ValMem[bx]
                call LineStuckPwrUp
                mov cl,al
                pop ax
                IMul cl
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je IMul_AddBx_our
                jmp Exit
            IMul_AddBp:
                cmp selectedPUPType,1
                jne IMul_AddBp_his
                IMul_AddBp_our:
                mov ax,ourValRegAX
                mov dx,ourValRegDX
                mov Bp,ourValRegBp
                cmp Bp,15d
                ja IMul_invalid
                IMul ourValMem[bp]
                mov ourValRegAX,ax
                mov ourValRegDX,dx
                jmp Exit
                IMul_AddBp_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov Bp,ValRegBp
                cmp Bp,15d
                ja IMul_invalid
                push ax
                mov al,ValMem[bp]
                call LineStuckPwrUp
                mov cl,al
                pop ax
                IMul cl
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je IMul_AddBp_our
                jmp Exit
            IMul_AddSi:
                cmp selectedPUPType,1
                jne IMul_AddSi_his
                IMul_AddSi_our:
                mov ax,ourValRegAX
                mov dx,ourValRegDX
                mov Si,ourValRegSi
                cmp Si,15d
                ja IMul_invalid
                IMul ourValMem[si]
                mov ourValRegAX,ax
                mov ourValRegDX,dx
                jmp Exit
                IMul_AddSi_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov Si,ValRegSi
                cmp Si,15d
                ja IMul_invalid
                push ax
                mov al,ValMem[si]
                call LineStuckPwrUp
                mov cl,al
                pop ax
                IMul cl
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je IMul_AddSi_our
                jmp Exit
            IMul_AddDi:
                cmp selectedPUPType,1
                jne IMul_AddDi_his
                IMul_AddDi_our:
                mov ax,ourValRegAX
                mov dx,ourValRegDX
                mov Di,ourValRegDi
                cmp Di,15d
                ja IMul_invalid
                IMul ourValMem[di]
                mov ourValRegAX,ax
                mov ourValRegDX,dx
                jmp Exit
                IMul_AddDi_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov Di,ValRegDi
                cmp Di,15d
                ja IMul_invalid
                push ax
                mov al,ValMem[di]
                call LineStuckPwrUp
                mov cl,al
                pop ax
                IMul cl
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je IMul_AddDi_our
                jmp Exit
        mov si,0
        IMul_Mem:
            mov bx,si
            cmp selectedOp2Mem,bl
            jne IMul_NotIt
                cmp selectedPUPType,1
                jne IMul_Mem_his
                IMul_Mem_our:
                mov ax,ourValRegAX
                mov dx,ourValRegDX
                IMul ourValMem[si]
                mov ourValRegAX,ax
                mov ourValRegDX,dx
                jmp Exit
                IMul_Mem_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                push ax
                mov al,ValMem[si]
                call LineStuckPwrUp
                mov cl,al
                pop ax
                IMul cl
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je IMul_Mem_our
                jmp Exit
            IMul_NotIt:
            inc si
            jmp IMul_Mem
        IMul_invalid:
        jmp InValidCommand
        JMP Exit
    IDiv_Comm:
        CALL Op1Menu

         
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
                cmp selectedPUPType,1
                jne IDiv_Ax_his
                IDiv_Ax_our:
                mov ax,ourValRegAX
                mov dx,ourValRegDX
                IDiv ax
                mov ourValRegAX,ax
                mov ourValRegDX,dx
                jmp Exit
                IDiv_Ax_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                call LineStuckPwrUp
                IDiv ax
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je IDiv_Ax_our
                jmp Exit
            IDiv_Al:
                cmp selectedPUPType,1
                jne IDiv_Al_his
                IDiv_Al_our:
                mov ax,ourValRegAX
                IDiv al
                mov ourValRegAX,ax
                jmp Exit
                IDiv_Al_his:
                mov ax,ValRegAX
                call LineStuckPwrUp
                IDiv al
                mov ValRegAX,ax
                cmp selectedPUPType,2
                je IDiv_Al_our
                jmp Exit
            IDiv_Ah:
                cmp selectedPUPType,1
                jne IDiv_Ah_his
                IDiv_Ah_our:
                mov ax,ourValRegAX
                IDiv ah
                mov ourValRegAX,ax
                jmp Exit
                IDiv_Ah_his:
                mov ax,ValRegAX
                mov al,ah
                call LineStuckPwrUp
                IDiv al
                mov ValRegAX,ax
                cmp selectedPUPType,2
                je IDiv_Ah_our
                jmp Exit
            IDiv_Bx:
                cmp selectedPUPType,1
                jne IDiv_Bx_his
                IDiv_Bx_our:
                mov ax,ourValRegAX
                mov dx,ourValRegDX
                mov bx,ourValRegBX
                IDiv bx
                mov ourValRegAX,ax
                mov ourValRegDX,dx
                jmp Exit
                IDiv_Bx_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov bx,ValRegBX
                push ax
                mov ax,bx
                call LineStuckPwrUp
                mov bx,ax
                pop ax
                IDiv bx
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je IDiv_Bx_our
                jmp Exit
            IDiv_Bl:
                cmp selectedPUPType,1
                jne IDiv_Bl_his
                IDiv_Bl_our:
                mov ax,ourValRegAX
                mov bx,ourValRegBX
                IDiv bl
                mov ourValRegAX,ax
                jmp Exit
                IDiv_Bl_his:
                mov ax,ValRegAX
                mov bx,ValRegBX
                push ax
                mov ax,bx
                call LineStuckPwrUp
                mov bx,ax
                pop ax
                IDiv bl
                mov ValRegAX,ax
                cmp selectedPUPType,2
                je IDiv_Bl_our
                jmp Exit
            IDiv_Bh:
                cmp selectedPUPType,1
                jne IDiv_Bh_his
                IDiv_Bh_our:
                mov ax,ourValRegAX
                mov bx,ourValRegBX
                IDiv Bh
                mov ourValRegAX,ax
                jmp Exit
                IDiv_Bh_his:
                mov ax,ValRegAX
                mov bx,ValRegBX
                push ax
                mov ax,bx
                call LineStuckPwrUp
                mov bx,ax
                pop ax
                IDiv Bh
                mov ValRegAX,ax
                cmp selectedPUPType,2
                je IDiv_Bh_our
                jmp Exit
            IDiv_Cx:
                cmp selectedPUPType,1
                jne IDiv_Cx_his
                IDiv_Cx_our:
                mov ax,ourValRegAX
                mov dx,ourValRegDX
                mov Cx,ourValRegCx
                IDiv Cx
                mov ourValRegAX,ax
                mov ourValRegDX,dx
                jmp Exit
                IDiv_Cx_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov Cx,ValRegCx
                push ax
                mov ax,cx
                call LineStuckPwrUp
                mov cx,ax
                pop ax
                IDiv Cx
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je IDiv_Cx_our
                jmp Exit
            IDiv_Cl:
                cmp selectedPUPType,1
                jne IDiv_Cl_his
                IDiv_Cl_our:
                mov ax,ourValRegAX
                mov Cx,ourValRegCx
                IDiv Cl
                mov ourValRegAX,ax
                jmp Exit
                IDiv_Cl_his:
                mov ax,ValRegAX
                mov Cx,ValRegCx
                push ax
                mov ax,cx
                call LineStuckPwrUp
                mov cx,ax
                pop ax
                IDiv Cl
                mov ValRegAX,ax
                cmp selectedPUPType,2
                je IDiv_Cl_our
                jmp Exit
            IDiv_Ch:
                cmp selectedPUPType,1
                jne IDiv_Ch_his
                IDiv_Ch_our:
                mov ax,ourValRegAX
                mov Cx,ourValRegCx
                IDiv Ch
                mov ourValRegAX,ax
                jmp Exit
                IDiv_Ch_his:
                mov ax,ValRegAX
                mov Cx,ValRegCx
                push ax
                mov ax,cx
                call LineStuckPwrUp
                mov cx,ax
                pop ax
                IDiv Ch
                mov ValRegAX,ax
                cmp selectedPUPType,2
                je IDiv_Ch_our
                jmp Exit
            IDiv_Dx:
                cmp selectedPUPType,1
                jne IDiv_Dx_his
                IDiv_Dx_our:
                mov ax,ValRegAX
                mov dx,ValRegDX
                IDiv dx
                mov ValRegAX,ax
                mov ValRegDX,dx
                jmp Exit
                IDiv_Dx_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                push ax
                mov ax,dx
                call LineStuckPwrUp
                mov dx,ax
                pop ax
                IDiv dx
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je IDiv_Dx_our
                jmp Exit
            IDiv_Dl:
                cmp selectedPUPType,1
                jne IDiv_Dl_his
                IDiv_Dl_our:
                mov ax,ourValRegAX
                mov dx,ourValRegBX
                IDiv dl
                mov ourValRegAX,ax
                jmp Exit
                IDiv_Dl_his:
                mov ax,ValRegAX
                mov dx,ValRegBX
                push ax
                mov ax,dx
                call LineStuckPwrUp
                mov dx,ax
                pop ax
                IDiv dl
                mov ValRegAX,ax
                cmp selectedPUPType,2
                je IDiv_Dl_our
                jmp Exit
            IDiv_Dh:
                cmp selectedPUPType,1
                jne IDiv_Dh_his
                IDiv_Dh_our:
                mov ax,ourValRegAX
                mov dx,ourValRegBX
                IDiv Dh
                mov ourValRegAX,ax
                jmp Exit
                IDiv_Dh_his:
                mov ax,ValRegAX
                mov dx,ValRegBX
                push ax
                mov ax,dx
                call LineStuckPwrUp
                mov dx,ax
                pop ax
                IDiv Dh
                mov ValRegAX,ax
                cmp selectedPUPType,2
                je IDiv_Dh_our
                jmp Exit
            IDiv_Bp:
                cmp selectedPUPType,1
                jne IDiv_Bp_his
                IDiv_Bp_our:
                mov ax,ourValRegAX
                mov dx,ourValRegDX
                mov Bp,ourValRegBp
                IDiv Bp
                mov ourValRegAX,ax
                mov ourValRegDX,dx
                jmp Exit
                IDiv_Bp_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov Bp,ValRegBp
                push ax
                mov ax,bp
                call LineStuckPwrUp
                mov bp,ax
                pop ax
                IDiv Bp
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je IDiv_Bp_our
                jmp Exit
            IDiv_Sp:
                cmp selectedPUPType,1
                jne IDiv_Sp_his
                IDiv_Sp_our:
                mov ax,ourValRegAX
                mov dx,ourValRegDX
                mov Sp,ourValRegSp
                IDiv Sp
                mov ourValRegAX,ax
                mov ourValRegDX,dx
                jmp Exit
                IDiv_Sp_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov Sp,ValRegSp
                push ax
                mov ax,sp
                call LineStuckPwrUp
                mov sp,ax
                pop ax
                IDiv Sp
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je IDiv_Sp_our
                jmp Exit
            IDiv_Si:
                cmp selectedPUPType,1
                jne IDiv_Si_his
                IDiv_Si_our:
                mov ax,ourValRegAX
                mov dx,ourValRegDX
                mov Si,ourValRegSi
                IDiv Si
                mov ourValRegAX,ax
                mov ourValRegDX,dx
                jmp Exit
                IDiv_Si_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov Si,ValRegSi
                push ax
                mov ax,si
                call LineStuckPwrUp
                mov si,ax
                pop ax
                IDiv Si
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je IDiv_Si_our
                jmp Exit
            IDiv_di:
                IDiv_Di:
                cmp selectedPUPType,1
                jne IDiv_Di_his
                IDiv_Di_our:
                mov ax,ourValRegAX
                mov dx,ourValRegDX
                mov Di,ourValRegDi
                IDiv Di
                mov ourValRegAX,ax
                mov ourValRegDX,dx
                jmp Exit
                IDiv_Di_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov Di,ValRegDi
                push ax
                mov ax,di
                call LineStuckPwrUp
                mov di,ax
                pop ax
                IDiv Di
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je IDiv_Di_our
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
                cmp selectedPUPType,1
                jne IDiv_AddBx_his
                IDiv_AddBx_our:
                mov ax,ourValRegAX
                mov dx,ourValRegDX
                mov bx,ourValRegBX
                cmp bx,15d
                ja IDiv_invalid
                IDiv ourValMem[bx]
                mov ourValRegAX,ax
                mov ourValRegDX,dx
                jmp Exit
                IDiv_AddBx_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov bx,ValRegBX
                cmp bx,15d
                ja IDiv_invalid
                push ax
                mov al,ValMem[bx]
                call LineStuckPwrUp
                mov cl,al
                pop ax
                IDiv cl
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je IDiv_AddBx_our
                jmp Exit
            IDiv_AddBp:
                cmp selectedPUPType,1
                jne IDiv_AddBp_his
                IDiv_AddBp_our:
                mov ax,ourValRegAX
                mov dx,ourValRegDX
                mov Bp,ourValRegBp
                cmp Bp,15d
                ja IDiv_invalid
                IDiv ourValMem[bp]
                mov ourValRegAX,ax
                mov ourValRegDX,dx
                jmp Exit
                IDiv_AddBp_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov Bp,ValRegBp
                cmp Bp,15d
                ja IDiv_invalid
                push ax
                mov al,ValMem[bp]
                call LineStuckPwrUp
                mov cl,al
                pop ax
                IDiv cl
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je IDiv_AddBp_our
                jmp Exit
            IDiv_AddSi:
                cmp selectedPUPType,1
                jne IDiv_AddSi_his
                IDiv_AddSi_our:
                mov ax,ourValRegAX
                mov dx,ourValRegDX
                mov Si,ourValRegSi
                cmp Si,15d
                ja IDiv_invalid
                IDiv ourValMem[si]
                mov ourValRegAX,ax
                mov ourValRegDX,dx
                jmp Exit
                IDiv_AddSi_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov Si,ValRegSi
                cmp Si,15d
                ja IDiv_invalid
                push ax
                mov al,ValMem[si]
                call LineStuckPwrUp
                mov cl,al
                pop ax
                IDiv cl
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je IDiv_AddSi_our
                jmp Exit
            IDiv_AddDi:
                cmp selectedPUPType,1
                jne IDiv_AddDi_his
                IDiv_AddDi_our:
                mov ax,ourValRegAX
                mov dx,ourValRegDX
                mov Di,ourValRegDi
                cmp Di,15d
                ja IDiv_invalid
                IDiv ourValMem[di]
                mov ourValRegAX,ax
                mov ourValRegDX,dx
                jmp Exit
                IDiv_AddDi_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                mov Di,ValRegDi
                cmp Di,15d
                ja IDiv_invalid
                push ax
                mov al,ValMem[di]
                call LineStuckPwrUp
                mov cl,al
                pop ax
                IDiv cl
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je IDiv_AddDi_our
                jmp Exit
        mov si,0
        IDiv_Mem:
            mov bx,si
            cmp selectedOp2Mem,bl
            jne IDiv_NotIt
                cmp selectedPUPType,1
                jne IDiv_Mem_his
                IDiv_Mem_our:
                mov ax,ourValRegAX
                mov dx,ourValRegDX
                IDiv ourValMem[si]
                mov ourValRegAX,ax
                mov ourValRegDX,dx
                jmp Exit
                IDiv_Mem_his:
                mov ax,ValRegAX
                mov dx,ValRegDX
                push ax
                mov al,ValMem[si]
                call LineStuckPwrUp
                mov cl,al
                pop ax
                IDiv cl
                mov ValRegAX,ax
                mov ValRegDX,dx
                cmp selectedPUPType,2
                je IDiv_Mem_our
                jmp Exit
            IDiv_NotIt:
            inc si
            jmp IDiv_Mem
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
                    cmp selectedPUPType,1
                    jne ROR_Ax_Reg_his
                    ROR_Ax_Reg_our:
                    mov ax,ourValRegAX
                    mov cx,ourValRegCX
                    ror Ax,cl
                    call ourSetCF
                    mov ourValRegAX,ax
                    jmp Exit
                    ROR_Ax_Reg_his:
                    mov ax,ValRegAX
                    mov cx,ValRegCX
                    ror Ax,cl
                    call SetCarryFlag
                    mov ValRegAX,ax
                    cmp selectedPUPType,2
                    je ROR_Ax_Reg_our
                    jmp Exit
                ROR_Ax_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    cmp selectedPUPType,1
                    jne ROR_Ax_Val_his
                    ROR_Ax_Val_our:
                    mov ax,ourValRegAX
                    mov cx,Op2Val
                    ror ax,cl
                    call ourSetCF
                    mov ourValRegAX,ax
                    jmp Exit
                    ROR_Ax_Val_his:
                    mov ax,ValRegAX
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    ror ax,cl
                    call SetCarryFlag
                    mov ValRegAX,ax
                    cmp selectedPUPType,2
                    je ROR_Ax_Val_our
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
                    cmp selectedPUPType,1
                    jne ROR_Al_Reg_his
                    ROR_Al_Reg_our:
                    mov ax,ourValRegAX
                    mov cx,ourValRegCX
                    ror Al,cl
                    call ourSetCF
                    mov ourValRegAX,ax
                    jmp Exit
                    ROR_Al_Reg_his:
                    mov ax,ValRegAX
                    mov cx,ValRegCX
                    ror Al,cl
                    call SetCarryFlag
                    mov ValRegAX,ax
                    cmp selectedPUPType,2
                    je ROR_Al_Reg_our
                    jmp Exit
                ROR_Al_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    cmp selectedPUPType,1
                    jne ROR_Al_Val_his
                    ROR_Al_Val_our:
                    mov ax,ourValRegAX
                    mov cx,Op2Val
                    ror al,cl
                    call ourSetCF
                    mov ourValRegAX,ax
                    jmp Exit
                    ROR_Al_Val_his:
                    mov ax,ValRegAX
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    ror al,cl
                    call SetCarryFlag
                    mov ValRegAX,ax
                    cmp selectedPUPType,2
                    je ROR_Al_Val_our
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
                    cmp selectedPUPType,1
                    jne ROR_Ah_Reg_his
                    ROR_Ah_Reg_our:
                    mov ax,ourValRegAX
                    mov cx,ourValRegCX
                    ror Ah,cl
                    call ourSetCF
                    mov ourValRegAX,ax
                    jmp Exit
                    ROR_Ah_Reg_his:
                    mov ax,ValRegAX
                    mov cx,ValRegCX
                    ror Ah,cl
                    call SetCarryFlag
                    mov ValRegAX,ax
                    cmp selectedPUPType,2
                    je ROR_Ah_Reg_our
                    jmp Exit
                ROR_Ah_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    cmp selectedPUPType,1
                    jne ROR_Ah_Val_his
                    ROR_Ah_Val_our:
                    mov ax,ourValRegAX
                    mov cx,Op2Val
                    ror ah,cl
                    call ourSetCF
                    mov ourValRegAX,ax
                    jmp Exit
                    ROR_Ah_Val_his:
                    mov ax,ValRegAX
                    mov cx,Op2Val
                    ;;;;;;;;;;
                        mov bx,ax
                        mov al,ah
                        call LineStuckPwrUp
                        mov ah,al
                        mov al,bl
                    ror ah,cl
                    call SetCarryFlag
                    mov ValRegAX,ax
                    cmp selectedPUPType,2
                    je ROR_Ah_Val_our
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
                    cmp selectedPUPType,1
                    jne ROR_Bx_Reg_his
                    ROR_Bx_Reg_our:
                    mov Bx,ourValRegBx
                    mov cx,ourValRegCX
                    ror Bx,cl
                    call ourSetCF
                    mov ourValRegBx,Bx
                    jmp Exit
                    ROR_Bx_Reg_his:
                    mov Bx,ValRegBx
                    mov cx,ValRegCX
                    ror Bx,cl
                    call SetCarryFlag
                    mov ValRegBx,Bx
                    cmp selectedPUPType,2
                    je ROR_Bx_Reg_our
                    jmp Exit
                ROR_Bx_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    cmp selectedPUPType,1
                    jne ROR_Bx_Val_his
                    ROR_Bx_Val_our:
                    mov Bx,ourValRegBx
                    mov cx,Op2Val
                    ror Bx,cl
                    call ourSetCF
                    mov ourValRegBx,Bx
                    jmp Exit
                    ROR_Bx_Val_his:
                    mov Bx,ValRegBx
                    mov cx,Op2Val
                    mov ax,bx
                    call LineStuckPwrUp
                    mov bx,ax
                    ror Bx,cl
                    call SetCarryFlag
                    mov ValRegBx,Bx
                    cmp selectedPUPType,2
                    je ROR_Bx_Val_our
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
                    cmp selectedPUPType,1
                    jne ROR_Bl_Reg_his
                    ROR_Bl_Reg_our:
                    mov Bx,ourValRegBX
                    mov cx,ourValRegCX
                    ror Bl,cl
                    call ourSetCF
                    mov ourValRegBX,Bx
                    jmp Exit
                    ROR_Bl_Reg_his:
                    mov Bx,ValRegBX
                    mov cx,ValRegCX
                    ror Bl,cl
                    call SetCarryFlag
                    mov ValRegBX,Bx
                    cmp selectedPUPType,2
                    je ROR_Bl_Reg_our
                    jmp Exit
                ROR_Bl_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    cmp selectedPUPType,1
                    ROR_Bl_Val_our:
                    mov Bx,ourValRegBX
                    mov cx,Op2Val
                    ror Bl,cl
                    call ourSetCF
                    mov ourValRegBX,Bx
                    jmp Exit
                    ROR_Bl_Val_his:
                    mov Bx,ValRegBX
                    mov cx,Op2Val
                    mov al,Bl
                    call LineStuckPwrUp
                    mov Bl,al
                    ror Bl,cl
                    call SetCarryFlag
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
                    cmp selectedPUPType,1
                    jne ROR_Bh_Reg_his
                    ROR_Bh_Reg_our:
                    mov Bx,ourValRegBX
                    mov cx,ourValRegCX
                    ror Bh,cl
                    call ourSetCF
                    mov ourValRegBX,Bx
                    jmp Exit
                    ROR_Bh_Reg_his:
                    mov Bx,ValRegBX
                    mov cx,ValRegCX
                    ror Bh,cl
                    call SetCarryFlag
                    mov ValRegBX,Bx
                    cmp selectedPUPType,2
                    je ROR_Bh_Reg_our
                    jmp Exit
                ROR_Bh_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    cmp selectedPUPType,1
                    ROR_Bh_Val_our:
                    mov Bx,ourValRegBX
                    mov cx,Op2Val
                    ror Bh,cl
                    call ourSetCF
                    mov ourValRegBX,Bx
                    jmp Exit
                    ROR_Bh_Val_his:
                    mov Bx,ValRegBX
                    mov cx,Op2Val
                    mov al,Bh
                    call LineStuckPwrUp
                    mov Bh,al
                    ror Bh,cl
                    call SetCarryFlag
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
                    cmp selectedPUPType,1
                    jne ROR_Cx_Reg_his
                    ROR_Cx_Reg_our:
                    mov Cx,ourValRegCx
                    mov ax,cx
                    mov cx,ax
                    ror Cx,cl
                    call ourSetCF
                    mov ourValRegCx,Cx
                    jmp Exit
                    ROR_Cx_Reg_his:
                    cmp selectedOp2Reg,7
                    jne ROR_invalid
                    mov Cx,ValRegCx
                    mov ax,cx
                    mov cx,ax
                    ror Cx,cl
                    call SetCarryFlag
                    mov ValRegCx,Cx
                    cmp selectedPUPType,2
                    je ROR_Cx_Reg_our
                    jmp Exit
                ROR_Cx_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    cmp selectedPUPType,1
                    jne ROR_Cx_Val_his
                    ROR_Cx_Val_our:
                    mov bx,ourValRegCx
                    mov cx,Op2Val
                    ror bx,cl
                    call ourSetCF
                    mov ourValRegCx,bx
                    jmp Exit
                    ROR_Cx_Val_his:
                    mov bx,ValRegCx
                    mov cx,Op2Val
                    mov ax,bx
                    call LineStuckPwrUp
                    mov bx,ax
                    ror bx,cl
                    call SetCarryFlag
                    mov ValRegCx,bx
                    cmp selectedPUPType,2
                    je ROR_Cx_Val_our
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
                    cmp selectedPUPType,1
                    jne ROR_Cl_Reg_his
                    ROR_Cl_Reg_our:
                    mov ax,ourValRegCX
                    mov cx,ourValRegCX
                    ror Al,cl
                    call ourSetCF
                    mov ourValRegCX,ax
                    jmp Exit
                    ROR_Cl_Reg_his:
                    mov ax,ValRegCX
                    mov cx,ValRegCX
                    ror Al,cl
                    call SetCarryFlag
                    mov ValRegCX,ax
                    cmp selectedPUPType,2
                    je ROR_Cl_Reg_our
                    jmp Exit
                ROR_Cl_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    cmp selectedPUPType,1
                    jne ROR_Cl_Val_his
                    ROR_Cl_Val_our:
                    mov ax,ourValRegCX
                    mov cx,Op2Val
                    ror al,cl
                    call ourSetCF
                    mov ourValRegCX,ax
                    jmp Exit
                    ROR_Cl_Val_his:
                    mov ax,ValRegCX
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    ror al,cl
                    call SetCarryFlag
                    mov ValRegCX,ax
                    cmp selectedPUPType,2
                    je ROR_Cl_Val_our
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
                    cmp selectedPUPType,1
                    jne ROR_Ch_Reg_his
                    ROR_Ch_Reg_our:
                    mov cx,ourValRegCX
                    ror Ch,cl
                    call ourSetCF
                    mov ourValRegCX,Cx
                    jmp Exit
                    ROR_Ch_Reg_his:
                    mov cx,ValRegCX
                    ror Ch,cl
                    call SetCarryFlag
                    mov ValRegCX,Cx
                    cmp selectedPUPType,2
                    je ROR_Ch_Reg_our
                    jmp Exit
                ROR_Ch_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    cmp selectedPUPType,1
                    jne ROR_Ch_Val_his
                    ROR_Ch_Val_our:
                    mov ax,ourValRegCX
                    mov cx,Op2Val
                    ror ah,cl
                    call ourSetCF
                    mov ourValRegCX,ax
                    jmp Exit
                    ROR_Ch_Val_his:
                    mov ax,ValRegCX
                    mov cx,Op2Val
                    ;;;;;;;;;;
                        mov bx,ax
                        mov al,ah
                        call LineStuckPwrUp
                        mov ah,al
                        mov al,bl
                    ror ah,cl
                    call SetCarryFlag
                    mov ValRegCX,ax
                    cmp selectedPUPType,2
                    je ROR_Ch_Val_our
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
                    cmp selectedPUPType,1
                    jne ROR_Dx_Reg_his
                    ROR_Dx_Reg_our:
                    mov Dx,ourValRegDx
                    mov cx,ourValRegCX
                    ror Dx,cl
                    call ourSetCF
                    mov ourValRegDx,Dx
                    jmp Exit
                    ROR_Dx_Reg_his:
                    mov Dx,ValRegDx
                    mov cx,ValRegCX
                    ror Dx,cl
                    call SetCarryFlag
                    mov ValRegDx,Dx
                    cmp selectedPUPType,2
                    je ROR_Dx_Reg_our
                    jmp Exit
                ROR_Dx_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    cmp selectedPUPType,1
                    jne ROR_Dx_Val_his
                    ROR_Dx_Val_our:
                    mov ax,ourValRegDx
                    mov cx,Op2Val
                    ror ax,cl
                    call ourSetCF
                    mov ourValRegDx,ax
                    jmp Exit
                    ROR_Dx_Val_his:
                    mov ax,ValRegDx
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    ror ax,cl
                    call SetCarryFlag
                    mov ValRegDx,ax
                    cmp selectedPUPType,2
                    je ROR_Dx_Val_our
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
                    cmp selectedPUPType,1
                    jne ROR_Dl_Reg_his
                    ROR_Dl_Reg_our:
                    mov Dx,ourValRegDX
                    mov cx,ourValRegCX
                    ror Dl,cl
                    call ourSetCF
                    mov ourValRegDX,Dx
                    jmp Exit
                    ROR_Dl_Reg_his:
                    mov Dx,ValRegDX
                    mov cx,ValRegCX
                    ror Dl,cl
                    call SetCarryFlag
                    mov ValRegDX,Dx
                    cmp selectedPUPType,2
                    je ROR_Dl_Reg_our
                    jmp Exit
                ROR_Dl_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    cmp selectedPUPType,1
                    jne ROR_Dl_Val_his
                    ROR_Dl_Val_our:
                    mov Dx,ourValRegDX
                    mov cx,Op2Val
                    ror Dl,cl
                    call ourSetCF
                    mov ourValRegDX,Dx
                    jmp Exit
                    ROR_Dl_Val_his:
                    mov ax,ValRegDX
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    ror al,cl
                    call SetCarryFlag
                    mov ValRegDX,ax
                    cmp selectedPUPType,2
                    je ROR_Dl_Val_our
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
                    cmp selectedPUPType,1
                    jne ROR_Dh_Reg_his
                    ROR_Dh_Reg_our:
                    mov Dx,ourValRegDX
                    mov cx,ourValRegCX
                    ror dh,cl
                    call ourSetCF
                    mov ourValRegDX,Dx
                    jmp Exit
                    ROR_Dh_Reg_his:
                    mov Dx,ValRegDX
                    mov cx,ValRegCX
                    ror dh,cl
                    call SetCarryFlag
                    mov ValRegDX,Dx
                    cmp selectedPUPType,2
                    je ROR_Dh_Reg_our
                    jmp Exit
                ROR_Dh_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    cmp selectedPUPType,1
                    jne ROR_Dh_Val_his
                    ROR_Dh_Val_our:
                    mov Dx,ourValRegDX
                    mov cx,Op2Val
                    ror dh,cl
                    call ourSetCF
                    mov ourValRegDX,Dx
                    jmp Exit
                    ROR_Dh_Val_his:
                    mov ax,ValRegDX
                    mov cx,Op2Val
                    ;;;;;;;;;;
                        mov bx,ax
                        mov al,ah
                        call LineStuckPwrUp
                        mov ah,al
                        mov al,bl
                    ror ah,cl
                    call SetCarryFlag
                    mov ValRegDX,ax
                    cmp selectedPUPType,2
                    je ROR_Dh_Val_our
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
                    cmp selectedPUPType,1
                    jne ROR_Bp_Reg_his
                    ROR_Bp_Reg_our:
                    mov Bp,ourValRegBp
                    mov cx,ourValRegCX
                    ror Bp,cl
                    call ourSetCF
                    mov ourValRegBp,Bp
                    jmp Exit
                    ROR_Bp_Reg_his:
                    mov Bp,ValRegBp
                    mov cx,ValRegCX
                    ror Bp,cl
                    call SetCarryFlag
                    mov ValRegBp,Bp
                    cmp selectedPUPType,2
                    je ROR_Bp_Reg_our
                    jmp Exit
                ROR_Bp_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    cmp selectedPUPType,1
                    jne ROR_Bp_Val_his
                    ROR_Bp_Val_our:
                    mov Bp,ourValRegBp
                    mov cx,Op2Val
                    ror Bp,cl
                    call ourSetCF
                    mov ourValRegBp,Bp
                    jmp Exit
                    ROR_Bp_Val_his:
                    mov ax,ValRegBp
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    ror ax,cl
                    call SetCarryFlag
                    mov ValRegBp,ax
                    cmp selectedPUPType,2
                    je ROR_Bp_Val_our
                    jmp Exit
            ROR_Sp:
                cmp selectedOp2Type,0
                je ROR_Sp_Reg
                cmp selectedOp2Type,3
                je ROR_Sp_Val
                jmp ROR_invalid
                ROR_Sp_Reg:
                    cmp selectedOp2Reg,7
                    jne ROR_invalid
                    cmp selectedPUPType,1
                    jne ROR_Sp_Reg_his
                    ROR_Sp_Reg_our:
                    mov Sp,ourValRegSp
                    mov cx,ourValRegCX
                    ror Sp,cl
                    call ourSetCF
                    mov ourValRegSp,Sp
                    jmp Exit
                    ROR_Sp_Reg_his:
                    mov Sp,ValRegSp
                    mov cx,ValRegCX
                    ror Sp,cl
                    call SetCarryFlag
                    mov ValRegSp,Sp
                    cmp selectedPUPType,2
                    je ROR_Sp_Reg_our
                    jmp Exit
                ROR_Sp_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    cmp selectedPUPType,1
                    jne ROR_Sp_Val_his
                    ROR_Sp_Val_our:
                    mov Sp,ourValRegSp
                    mov cx,Op2Val
                    ror Sp,cl
                    call ourSetCF
                    mov ourValRegSp,Sp
                    jmp Exit
                    ROR_Sp_Val_his:
                    mov ax,ValRegSp
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    ror ax,cl
                    call SetCarryFlag
                    mov ValRegSp,ax
                    cmp selectedPUPType,2
                    je ROR_Sp_Val_our
                    jmp Exit
            ROR_Si:
                cmp selectedOp2Type,0
                je ROR_Si_Reg
                cmp selectedOp2Type,3
                je ROR_Si_Val
                jmp ROR_invalid
                ROR_Si_Reg:
                    cmp selectedOp2Reg,7
                    jne ROR_invalid
                    cmp selectedPUPType,1
                    jne ROR_Si_Reg_his
                    ROR_Si_Reg_our:
                    mov Si,ourValRegSi
                    mov cx,ourValRegCX
                    ror Si,cl
                    call ourSetCF
                    mov ourValRegSi,Si
                    jmp Exit
                    ROR_Si_Reg_his:
                    mov Si,ValRegSi
                    mov cx,ValRegCX
                    ror Si,cl
                    call SetCarryFlag
                    mov ValRegSi,Si
                    cmp selectedPUPType,2
                    je ROR_Si_Reg_our
                    jmp Exit
                ROR_Si_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    cmp selectedPUPType,1
                    jne ROR_Si_Val_his
                    ROR_Si_Val_our:
                    mov Si,ourValRegSi
                    mov cx,Op2Val
                    ror Si,cl
                    call ourSetCF
                    mov ourValRegSi,Si
                    jmp Exit
                    ROR_Si_Val_his:
                    mov ax,ValRegSi
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    ror ax,cl
                    call SetCarryFlag
                    mov ValRegSi,ax
                    cmp selectedPUPType,2
                    je ROR_Si_Val_our
                    jmp Exit
            ROR_Di:
                cmp selectedOp2Type,0
                je ROR_Di_Reg
                cmp selectedOp2Type,3
                je ROR_Di_Val
                jmp ROR_invalid
                ROR_Di_Reg:
                    cmp selectedOp2Reg,7
                    jne ROR_invalid
                    cmp selectedPUPType,1
                    jne ROR_Di_Reg_his
                    ROR_Di_Reg_our:
                    mov Di,ourValRegDi
                    mov cx,ourValRegCX
                    ror Di,cl
                    call ourSetCF
                    mov ourValRegDi,Di
                    jmp Exit
                    ROR_Di_Reg_his:
                    mov Di,ValRegDi
                    mov cx,ValRegCX
                    ror Di,cl
                    call SetCarryFlag
                    mov ValRegDi,Di
                    cmp selectedPUPType,2
                    je ROR_Di_Reg_our
                    jmp Exit
                ROR_Di_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    cmp selectedPUPType,1
                    jne ROR_Di_Val_his
                    ROR_Di_Val_our:
                    mov Di,ourValRegDi
                    mov cx,Op2Val
                    ror Di,cl
                    call ourSetCF
                    mov ourValRegDi,Di
                    jmp Exit
                    ROR_Di_Val_his:
                    mov ax,ValRegDi
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    ror ax,cl
                    call SetCarryFlag
                    mov ValRegDi,ax
                    cmp selectedPUPType,2
                    je ROR_Di_Val_our
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
                    cmp selectedPUPType,1
                    jne ROR_AddBx_Reg_his
                    ROR_AddBx_Reg_our:
                    mov Bx,ourValRegBX
                    cmp Bx,15d
                    ja ROR_invalid
                    mov cx,ourValRegCX
                    ror ourValMem[Bx],cl
                    call ourSetCF
                    mov ourValRegBX,Bx
                    jmp Exit
                    ROR_AddBx_Reg_his:
                    mov Bx,ValRegBX
                    cmp Bx,15d
                    ja ROR_invalid
                    mov cx,ValRegCX
                    ;;;;;;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[Bx]
                        call LineStuckPwrUp
                        mov ValMem[Bx],al
                    ror ValMem[Bx],cl
                    call SetCarryFlag
                    mov ValRegBX,Bx
                    cmp selectedPUPType,2
                    je ROR_AddBx_Reg_our
                    jmp Exit
                ROR_AddBx_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    cmp selectedPUPType,1
                    jne ROR_AddBx_Val_his
                    ROR_AddBx_Val_our:
                    mov Bx,ourValRegBX
                    cmp Bx,15d
                    ja ROR_invalid
                    mov cx,Op2Val
                    ror ourValMem[Bx],cl
                    call ourSetCF
                    mov ourValRegBX,Bx
                    jmp Exit
                    ROR_AddBx_Val_his:
                    mov Bx,ValRegBX
                    cmp Bx,15d
                    ja ROR_invalid
                    mov cx,Op2Val
                    ;;;;;;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[Bx]
                        call LineStuckPwrUp
                        mov ValMem[Bx],al
                    ror ValMem[Bx],cl
                    call SetCarryFlag
                    mov ValRegBX,Bx
                    cmp selectedPUPType,2
                    je ROR_AddBx_Val_our
                    jmp Exit
            ROR_AddBp:
                cmp selectedOp2Type,0
                je ROR_AddBp_Reg
                cmp selectedOp2Type,3
                je ROR_AddBp_Val
                jmp ROR_invalid
                ROR_AddBp_Reg:
                    cmp selectedOp2Reg,7
                    jne ROR_invalid
                    cmp selectedPUPType,1
                    jne ROR_AddBp_Reg_his
                    ROR_AddBp_Reg_our:
                    mov Bp,ourValRegBp
                    cmp Bp,15d
                    ja ROR_invalid
                    mov cx,ourValRegCX
                    ror ourValMem[Bp],cl
                    call ourSetCF
                    mov ourValRegBp,Bp
                    jmp Exit
                    ROR_AddBp_Reg_his:
                    mov Bp,ValRegBp
                    cmp Bp,15d
                    ja ROR_invalid
                    mov cx,ValRegCX
                    ;;;;;;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[Bp]
                        call LineStuckPwrUp
                        mov ValMem[Bp],al
                    ror ValMem[Bp],cl
                    call SetCarryFlag
                    mov ValRegBp,Bp
                    cmp selectedPUPType,2
                    je ROR_AddBp_Reg_our
                    jmp Exit
                ROR_AddBp_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    cmp selectedPUPType,1
                    jne ROR_AddBp_Val_his
                    ROR_AddBp_Val_our:
                    mov Bp,ourValRegBp
                    cmp Bp,15d
                    ja ROR_invalid
                    mov cx,Op2Val
                    ror ourValMem[Bp],cl
                    call ourSetCF
                    mov ourValRegBp,Bp
                    jmp Exit
                    ROR_AddBp_Val_his:
                    mov Bp,ValRegBp
                    cmp Bp,15d
                    ja ROR_invalid
                    mov cx,Op2Val
                    ;;;;;;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[Bp]
                        call LineStuckPwrUp
                        mov ValMem[Bp],al
                    ror ValMem[Bp],cl
                    call SetCarryFlag
                    mov ValRegBp,Bp
                    cmp selectedPUPType,2
                    je ROR_AddBp_Val_our
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
                    cmp selectedPUPType,1
                    jne ROR_AddSi_Reg_his
                    ROR_AddSi_Reg_our:
                    mov Si,ourValRegSi
                    cmp Si,15d
                    ja ROR_invalid
                    mov cx,ourValRegCX
                    ror ourValMem[Si],cl
                    call ourSetCF
                    mov ourValRegSi,Si
                    jmp Exit
                    ROR_AddSi_Reg_his:
                    mov Si,ValRegSi
                    cmp Si,15d
                    ja ROR_invalid
                    mov cx,ValRegCX
                    ;;;;;;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[Si]
                        call LineStuckPwrUp
                        mov ValMem[Si],al
                    ror ValMem[Si],cl
                    call SetCarryFlag
                    mov ValRegSi,Si
                    cmp selectedPUPType,2
                    je ROR_AddSi_Reg_our
                    jmp Exit
                ROR_AddSi_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    cmp selectedPUPType,1
                    jne ROR_AddSi_Val_his
                    ROR_AddSi_Val_our:
                    mov Si,ourValRegSi
                    cmp Si,15d
                    ja ROR_invalid
                    mov cx,Op2Val
                    ror ourValMem[Si],cl
                    call ourSetCF
                    mov ourValRegSi,Si
                    jmp Exit
                    ROR_AddSi_Val_his:
                    mov Si,ValRegSi
                    cmp Si,15d
                    ja ROR_invalid
                    mov cx,Op2Val
                    ;;;;;;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[Si]
                        call LineStuckPwrUp
                        mov ValMem[Si],al
                    ror ValMem[Si],cl
                    call SetCarryFlag
                    mov ValRegSi,Si
                    cmp selectedPUPType,2
                    je ROR_AddSi_Val_our
                    jmp Exit
            ROR_AddDi:
                cmp selectedOp2Type,0
                je ROR_AddDi_Reg
                cmp selectedOp2Type,3
                je ROR_AddDi_Val
                jmp ROR_invalid
                ROR_AddDi_Reg:
                    cmp selectedOp2Reg,7
                    jne ROR_invalid
                    cmp selectedPUPType,1
                    jne ROR_AddDi_Reg_his
                    ROR_AddDi_Reg_our:
                    mov Di,ourValRegDi
                    cmp Di,15d
                    ja ROR_invalid
                    mov cx,ourValRegCX
                    ror ourValMem[Di],cl
                    call ourSetCF
                    mov ourValRegDi,Di
                    jmp Exit
                    ROR_AddDi_Reg_his:
                    mov Di,ValRegDi
                    cmp Di,15d
                    ja ROR_invalid
                    mov cx,ValRegCX
                    ;;;;;;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[Di]
                        call LineStuckPwrUp
                        mov ValMem[Di],al
                    ror ValMem[Di],cl
                    call SetCarryFlag
                    mov ValRegDi,Di
                    cmp selectedPUPType,2
                    je ROR_AddDi_Reg_our
                    jmp Exit
                ROR_AddDi_Val:
                    cmp Op2Val,255d
                    ja ROR_invalid
                    cmp selectedPUPType,1
                    jne ROR_AddDi_Val_his
                    ROR_AddDi_Val_our:
                    mov Di,ourValRegDi
                    cmp Di,15d
                    ja ROR_invalid
                    mov cx,Op2Val
                    ror ourValMem[Di],cl
                    call ourSetCF
                    mov ourValRegDi,Di
                    jmp Exit
                    ROR_AddDi_Val_his:
                    mov Di,ValRegDi
                    cmp Di,15d
                    ja ROR_invalid
                    mov cx,Op2Val
                    ;;;;;;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[Di]
                        call LineStuckPwrUp
                        mov ValMem[Di],al
                    ror ValMem[Di],cl
                    call SetCarryFlag
                    mov ValRegDi,Di
                    cmp selectedPUPType,2
                    je ROR_AddDi_Val_our
                    jmp Exit
        mov si,0
        ROR_Mem:
            mov bx,si
            cmp selectedOp2Mem,bl
            jne ROR_NotIt
            cmp selectedOp2Type,0
            je ROR_Mem_Reg
            cmp selectedOp2Type,3
            je ROR_Mem_Val
            jmp ROR_invalid
            ROR_Mem_Reg:
                cmp selectedOp2Reg,7
                jne ROR_invalid
                cmp selectedPUPType,1
                jne ROR_Mem_Reg_his
                ROR_Mem_Reg_our:
                mov cx,ourValRegCX
                Ror ourValMem[si],cl
                call ourSetCF
                jmp Exit
                ROR_Mem_Reg_his:
                mov cx,ValRegCX
                ;;;;;;;;;;;;;;;;;;
                    mov al,ValMem[si]
                    call LineStuckPwrUp
                    mov ValMem[si],al
                Ror ValMem[si],cl
                call SetCarryFlag
                cmp selectedPUPType,2
                je ROR_Mem_Reg_our
                jmp Exit
            ROR_Mem_Val:
                cmp Op2Val,255d
                ja ROR_invalid
                cmp selectedPUPType,1
                jne ROR_Mem_Val_his
                ROR_Mem_Val_our:
                mov cx,Op2Val
                ror ourValMem[si],cl
                call ourSetCF
                jmp Exit
                ROR_Mem_Val_his:
                mov cx,Op2Val
                ;;;;;;;;;;;;;;;;;;
                    mov al,ValMem[si]
                    call LineStuckPwrUp
                    mov ValMem[si],al
                ror ValMem[si],cl
                call SetCarryFlag
                cmp selectedPUPType,2
                je ROR_Mem_Val_our
                jmp Exit
            ROR_NotIt:
            inc si
            jmp ROR_Mem
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
                    cmp selectedPUPType,1
                    jne ROL_Ax_Reg_his
                    ROL_Ax_Reg_our:
                    mov ax,ourValRegAX
                    mov cx,ourValRegCX
                    ROL Ax,cl
                    call ourSetCF
                    mov ourValRegAX,ax
                    jmp Exit
                    ROL_Ax_Reg_his:
                    mov ax,ValRegAX
                    mov cx,ValRegCX
                    ROL Ax,cl
                    call SetCarryFlag
                    mov ValRegAX,ax
                    cmp selectedPUPType,2
                    je ROL_Ax_Reg_our
                    jmp Exit
                ROL_Ax_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    cmp selectedPUPType,1
                    jne ROL_Ax_Val_his
                    ROL_Ax_Val_our:
                    mov ax,ourValRegAX
                    mov cx,Op2Val
                    ROL ax,cl
                    call ourSetCF
                    mov ourValRegAX,ax
                    jmp Exit
                    ROL_Ax_Val_his:
                    mov ax,ValRegAX
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    ROL ax,cl
                    call SetCarryFlag
                    mov ValRegAX,ax
                    cmp selectedPUPType,2
                    je ROL_Ax_Val_our
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
                    cmp selectedPUPType,1
                    jne ROL_Al_Reg_his
                    ROL_Al_Reg_our:
                    mov ax,ourValRegAX
                    mov cx,ourValRegCX
                    ROL Al,cl
                    call ourSetCF
                    mov ourValRegAX,ax
                    jmp Exit
                    ROL_Al_Reg_his:
                    mov ax,ValRegAX
                    mov cx,ValRegCX
                    ROL Al,cl
                    call SetCarryFlag
                    mov ValRegAX,ax
                    cmp selectedPUPType,2
                    je ROL_Al_Reg_our
                    jmp Exit
                ROL_Al_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    cmp selectedPUPType,1
                    jne ROL_Al_Val_his
                    ROL_Al_Val_our:
                    mov ax,ourValRegAX
                    mov cx,Op2Val
                    ROL al,cl
                    call ourSetCF
                    mov ourValRegAX,ax
                    jmp Exit
                    ROL_Al_Val_his:
                    mov ax,ValRegAX
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    ROL al,cl
                    call SetCarryFlag
                    mov ValRegAX,ax
                    cmp selectedPUPType,2
                    je ROL_Al_Val_our
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
                    cmp selectedPUPType,1
                    jne ROL_Ah_Reg_his
                    ROL_Ah_Reg_our:
                    mov ax,ourValRegAX
                    mov cx,ourValRegCX
                    ROL Ah,cl
                    call ourSetCF
                    mov ourValRegAX,ax
                    jmp Exit
                    ROL_Ah_Reg_his:
                    mov ax,ValRegAX
                    mov cx,ValRegCX
                    ROL Ah,cl
                    call SetCarryFlag
                    mov ValRegAX,ax
                    cmp selectedPUPType,2
                    je ROL_Ah_Reg_our
                    jmp Exit
                ROL_Ah_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    cmp selectedPUPType,1
                    jne ROL_Ah_Val_his
                    ROL_Ah_Val_our:
                    mov ax,ourValRegAX
                    mov cx,Op2Val
                    ROL ah,cl
                    call ourSetCF
                    mov ourValRegAX,ax
                    jmp Exit
                    ROL_Ah_Val_his:
                    mov ax,ValRegAX
                    mov cx,Op2Val
                    ;;;;;;;;;;
                        mov bx,ax
                        mov al,ah
                        call LineStuckPwrUp
                        mov ah,al
                        mov al,bl
                    ROL ah,cl
                    call SetCarryFlag
                    mov ValRegAX,ax
                    cmp selectedPUPType,2
                    je ROL_Ah_Val_our
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
                    cmp selectedPUPType,1
                    jne ROL_Bx_Reg_his
                    ROL_Bx_Reg_our:
                    mov Bx,ourValRegBx
                    mov cx,ourValRegCX
                    ROL Bx,cl
                    call ourSetCF
                    mov ourValRegBx,Bx
                    jmp Exit
                    ROL_Bx_Reg_his:
                    mov Bx,ValRegBx
                    mov cx,ValRegCX
                    ROL Bx,cl
                    call SetCarryFlag
                    mov ValRegBx,Bx
                    cmp selectedPUPType,2
                    je ROL_Bx_Reg_our
                    jmp Exit
                ROL_Bx_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    cmp selectedPUPType,1
                    jne ROL_Bx_Val_his
                    ROL_Bx_Val_our:
                    mov Bx,ourValRegBx
                    mov cx,Op2Val
                    ROL Bx,cl
                    call ourSetCF
                    mov ourValRegBx,Bx
                    jmp Exit
                    ROL_Bx_Val_his:
                    mov Bx,ValRegBx
                    mov cx,Op2Val
                    mov ax,bx
                    call LineStuckPwrUp
                    mov bx,ax
                    ROL Bx,cl
                    call SetCarryFlag
                    mov ValRegBx,Bx
                    cmp selectedPUPType,2
                    je ROL_Bx_Val_our
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
                    cmp selectedPUPType,1
                    jne ROL_Bl_Reg_his
                    ROL_Bl_Reg_our:
                    mov Bx,ourValRegBX
                    mov cx,ourValRegCX
                    ROL Bl,cl
                    call ourSetCF
                    mov ourValRegBX,Bx
                    jmp Exit
                    ROL_Bl_Reg_his:
                    mov Bx,ValRegBX
                    mov cx,ValRegCX
                    ROL Bl,cl
                    call SetCarryFlag
                    mov ValRegBX,Bx
                    cmp selectedPUPType,2
                    je ROL_Bl_Reg_our
                    jmp Exit
                ROL_Bl_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    cmp selectedPUPType,1
                    ROL_Bl_Val_our:
                    mov Bx,ourValRegBX
                    mov cx,Op2Val
                    ROL Bl,cl
                    call ourSetCF
                    mov ourValRegBX,Bx
                    jmp Exit
                    ROL_Bl_Val_his:
                    mov Bx,ValRegBX
                    mov cx,Op2Val
                    mov al,Bl
                    call LineStuckPwrUp
                    mov Bl,al
                    ROL Bl,cl
                    call SetCarryFlag
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
                    cmp selectedPUPType,1
                    jne ROL_Bh_Reg_his
                    ROL_Bh_Reg_our:
                    mov Bx,ourValRegBX
                    mov cx,ourValRegCX
                    ROL Bh,cl
                    call ourSetCF
                    mov ourValRegBX,Bx
                    jmp Exit
                    ROL_Bh_Reg_his:
                    mov Bx,ValRegBX
                    mov cx,ValRegCX
                    ROL Bh,cl
                    call SetCarryFlag
                    mov ValRegBX,Bx
                    cmp selectedPUPType,2
                    je ROL_Bh_Reg_our
                    jmp Exit
                ROL_Bh_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    cmp selectedPUPType,1
                    ROL_Bh_Val_our:
                    mov Bx,ourValRegBX
                    mov cx,Op2Val
                    ROL Bh,cl
                    call ourSetCF
                    mov ourValRegBX,Bx
                    jmp Exit
                    ROL_Bh_Val_his:
                    mov Bx,ValRegBX
                    mov cx,Op2Val
                    mov al,Bh
                    call LineStuckPwrUp
                    mov Bh,al
                    ROL Bh,cl
                    call SetCarryFlag
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
                    cmp selectedPUPType,1
                    jne ROL_Cx_Reg_his
                    ROL_Cx_Reg_our:
                    mov Cx,ourValRegCx
                    mov ax,cx
                    mov cx,ax
                    ROL Cx,cl
                    call ourSetCF
                    mov ourValRegCx,Cx
                    jmp Exit
                    ROL_Cx_Reg_his:
                    cmp selectedOp2Reg,7
                    jne ROL_invalid
                    mov Cx,ValRegCx
                    mov ax,cx
                    mov cx,ax
                    ROL Cx,cl
                    call SetCarryFlag
                    mov ValRegCx,Cx
                    cmp selectedPUPType,2
                    je ROL_Cx_Reg_our
                    jmp Exit
                ROL_Cx_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    cmp selectedPUPType,1
                    jne ROL_Cx_Val_his
                    ROL_Cx_Val_our:
                    mov bx,ourValRegCx
                    mov cx,Op2Val
                    ROL bx,cl
                    call ourSetCF
                    mov ourValRegCx,bx
                    jmp Exit
                    ROL_Cx_Val_his:
                    mov bx,ValRegCx
                    mov cx,Op2Val
                    mov ax,bx
                    call LineStuckPwrUp
                    mov bx,ax
                    ROL bx,cl
                    call SetCarryFlag
                    mov ValRegCx,bx
                    cmp selectedPUPType,2
                    je ROL_Cx_Val_our
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
                    cmp selectedPUPType,1
                    jne ROL_Cl_Reg_his
                    ROL_Cl_Reg_our:
                    mov ax,ourValRegCX
                    mov cx,ourValRegCX
                    ROL Al,cl
                    call ourSetCF
                    mov ourValRegCX,ax
                    jmp Exit
                    ROL_Cl_Reg_his:
                    mov ax,ValRegCX
                    mov cx,ValRegCX
                    ROL Al,cl
                    call SetCarryFlag
                    mov ValRegCX,ax
                    cmp selectedPUPType,2
                    je ROL_Cl_Reg_our
                    jmp Exit
                ROL_Cl_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    cmp selectedPUPType,1
                    jne ROL_Cl_Val_his
                    ROL_Cl_Val_our:
                    mov ax,ourValRegCX
                    mov cx,Op2Val
                    ROL al,cl
                    call ourSetCF
                    mov ourValRegCX,ax
                    jmp Exit
                    ROL_Cl_Val_his:
                    mov ax,ValRegCX
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    ROL al,cl
                    call SetCarryFlag
                    mov ValRegCX,ax
                    cmp selectedPUPType,2
                    je ROL_Cl_Val_our
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
                    cmp selectedPUPType,1
                    jne ROL_Ch_Reg_his
                    ROL_Ch_Reg_our:
                    mov cx,ourValRegCX
                    ROL Ch,cl
                    call ourSetCF
                    mov ourValRegCX,Cx
                    jmp Exit
                    ROL_Ch_Reg_his:
                    mov cx,ValRegCX
                    ROL Ch,cl
                    call SetCarryFlag
                    mov ValRegCX,Cx
                    cmp selectedPUPType,2
                    je ROL_Ch_Reg_our
                    jmp Exit
                ROL_Ch_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    cmp selectedPUPType,1
                    jne ROL_Ch_Val_his
                    ROL_Ch_Val_our:
                    mov ax,ourValRegCX
                    mov cx,Op2Val
                    ROL ah,cl
                    call ourSetCF
                    mov ourValRegCX,ax
                    jmp Exit
                    ROL_Ch_Val_his:
                    mov ax,ValRegCX
                    mov cx,Op2Val
                    ;;;;;;;;;;
                        mov bx,ax
                        mov al,ah
                        call LineStuckPwrUp
                        mov ah,al
                        mov al,bl
                    ROL ah,cl
                    call SetCarryFlag
                    mov ValRegCX,ax
                    cmp selectedPUPType,2
                    je ROL_Ch_Val_our
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
                    cmp selectedPUPType,1
                    jne ROL_Dx_Reg_his
                    ROL_Dx_Reg_our:
                    mov Dx,ourValRegDx
                    mov cx,ourValRegCX
                    ROL Dx,cl
                    call ourSetCF
                    mov ourValRegDx,Dx
                    jmp Exit
                    ROL_Dx_Reg_his:
                    mov Dx,ValRegDx
                    mov cx,ValRegCX
                    ROL Dx,cl
                    call SetCarryFlag
                    mov ValRegDx,Dx
                    cmp selectedPUPType,2
                    je ROL_Dx_Reg_our
                    jmp Exit
                ROL_Dx_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    cmp selectedPUPType,1
                    jne ROL_Dx_Val_his
                    ROL_Dx_Val_our:
                    mov ax,ourValRegDx
                    mov cx,Op2Val
                    ROL ax,cl
                    call ourSetCF
                    mov ourValRegDx,ax
                    jmp Exit
                    ROL_Dx_Val_his:
                    mov ax,ValRegDx
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    ROL ax,cl
                    call SetCarryFlag
                    mov ValRegDx,ax
                    cmp selectedPUPType,2
                    je ROL_Dx_Val_our
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
                    cmp selectedPUPType,1
                    jne ROL_Dl_Reg_his
                    ROL_Dl_Reg_our:
                    mov Dx,ourValRegDX
                    mov cx,ourValRegCX
                    ROL Dl,cl
                    call ourSetCF
                    mov ourValRegDX,Dx
                    jmp Exit
                    ROL_Dl_Reg_his:
                    mov Dx,ValRegDX
                    mov cx,ValRegCX
                    ROL Dl,cl
                    call SetCarryFlag
                    mov ValRegDX,Dx
                    cmp selectedPUPType,2
                    je ROL_Dl_Reg_our
                    jmp Exit
                ROL_Dl_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    cmp selectedPUPType,1
                    jne ROL_Dl_Val_his
                    ROL_Dl_Val_our:
                    mov Dx,ourValRegDX
                    mov cx,Op2Val
                    ROL Dl,cl
                    call ourSetCF
                    mov ourValRegDX,Dx
                    jmp Exit
                    ROL_Dl_Val_his:
                    mov ax,ValRegDX
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    ROL al,cl
                    call SetCarryFlag
                    mov ValRegDX,ax
                    cmp selectedPUPType,2
                    je ROL_Dl_Val_our
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
                    cmp selectedPUPType,1
                    jne ROL_Dh_Reg_his
                    ROL_Dh_Reg_our:
                    mov Dx,ourValRegDX
                    mov cx,ourValRegCX
                    ROL dh,cl
                    call ourSetCF
                    mov ourValRegDX,Dx
                    jmp Exit
                    ROL_Dh_Reg_his:
                    mov Dx,ValRegDX
                    mov cx,ValRegCX
                    ROL dh,cl
                    call SetCarryFlag
                    mov ValRegDX,Dx
                    cmp selectedPUPType,2
                    je ROL_Dh_Reg_our
                    jmp Exit
                ROL_Dh_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    cmp selectedPUPType,1
                    jne ROL_Dh_Val_his
                    ROL_Dh_Val_our:
                    mov Dx,ourValRegDX
                    mov cx,Op2Val
                    ROL dh,cl
                    call ourSetCF
                    mov ourValRegDX,Dx
                    jmp Exit
                    ROL_Dh_Val_his:
                    mov ax,ValRegDX
                    mov cx,Op2Val
                    ;;;;;;;;;;
                        mov bx,ax
                        mov al,ah
                        call LineStuckPwrUp
                        mov ah,al
                        mov al,bl
                    ROL ah,cl
                    call SetCarryFlag
                    mov ValRegDX,ax
                    cmp selectedPUPType,2
                    je ROL_Dh_Val_our
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
                    cmp selectedPUPType,1
                    jne ROL_Bp_Reg_his
                    ROL_Bp_Reg_our:
                    mov Bp,ourValRegBp
                    mov cx,ourValRegCX
                    ROL Bp,cl
                    call ourSetCF
                    mov ourValRegBp,Bp
                    jmp Exit
                    ROL_Bp_Reg_his:
                    mov Bp,ValRegBp
                    mov cx,ValRegCX
                    ROL Bp,cl
                    call SetCarryFlag
                    mov ValRegBp,Bp
                    cmp selectedPUPType,2
                    je ROL_Bp_Reg_our
                    jmp Exit
                ROL_Bp_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    cmp selectedPUPType,1
                    jne ROL_Bp_Val_his
                    ROL_Bp_Val_our:
                    mov Bp,ourValRegBp
                    mov cx,Op2Val
                    ROL Bp,cl
                    call ourSetCF
                    mov ourValRegBp,Bp
                    jmp Exit
                    ROL_Bp_Val_his:
                    mov ax,ValRegBp
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    ROL ax,cl
                    call SetCarryFlag
                    mov ValRegBp,ax
                    cmp selectedPUPType,2
                    je ROL_Bp_Val_our
                    jmp Exit
            ROL_Sp:
                cmp selectedOp2Type,0
                je ROL_Sp_Reg
                cmp selectedOp2Type,3
                je ROL_Sp_Val
                jmp ROL_invalid
                ROL_Sp_Reg:
                    cmp selectedOp2Reg,7
                    jne ROL_invalid
                    cmp selectedPUPType,1
                    jne ROL_Sp_Reg_his
                    ROL_Sp_Reg_our:
                    mov Sp,ourValRegSp
                    mov cx,ourValRegCX
                    ROL Sp,cl
                    call ourSetCF
                    mov ourValRegSp,Sp
                    jmp Exit
                    ROL_Sp_Reg_his:
                    mov Sp,ValRegSp
                    mov cx,ValRegCX
                    ROL Sp,cl
                    call SetCarryFlag
                    mov ValRegSp,Sp
                    cmp selectedPUPType,2
                    je ROL_Sp_Reg_our
                    jmp Exit
                ROL_Sp_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    cmp selectedPUPType,1
                    jne ROL_Sp_Val_his
                    ROL_Sp_Val_our:
                    mov Sp,ourValRegSp
                    mov cx,Op2Val
                    ROL Sp,cl
                    call ourSetCF
                    mov ourValRegSp,Sp
                    jmp Exit
                    ROL_Sp_Val_his:
                    mov ax,ValRegSp
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    ROL ax,cl
                    call SetCarryFlag
                    mov ValRegSp,ax
                    cmp selectedPUPType,2
                    je ROL_Sp_Val_our
                    jmp Exit
            ROL_Si:
                cmp selectedOp2Type,0
                je ROL_Si_Reg
                cmp selectedOp2Type,3
                je ROL_Si_Val
                jmp ROL_invalid
                ROL_Si_Reg:
                    cmp selectedOp2Reg,7
                    jne ROL_invalid
                    cmp selectedPUPType,1
                    jne ROL_Si_Reg_his
                    ROL_Si_Reg_our:
                    mov Si,ourValRegSi
                    mov cx,ourValRegCX
                    ROL Si,cl
                    call ourSetCF
                    mov ourValRegSi,Si
                    jmp Exit
                    ROL_Si_Reg_his:
                    mov Si,ValRegSi
                    mov cx,ValRegCX
                    ROL Si,cl
                    call SetCarryFlag
                    mov ValRegSi,Si
                    cmp selectedPUPType,2
                    je ROL_Si_Reg_our
                    jmp Exit
                ROL_Si_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    cmp selectedPUPType,1
                    jne ROL_Si_Val_his
                    ROL_Si_Val_our:
                    mov Si,ourValRegSi
                    mov cx,Op2Val
                    ROL Si,cl
                    call ourSetCF
                    mov ourValRegSi,Si
                    jmp Exit
                    ROL_Si_Val_his:
                    mov ax,ValRegSi
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    ROL ax,cl
                    call SetCarryFlag
                    mov ValRegSi,ax
                    cmp selectedPUPType,2
                    je ROL_Si_Val_our
                    jmp Exit
            ROL_Di:
                cmp selectedOp2Type,0
                je ROL_Di_Reg
                cmp selectedOp2Type,3
                je ROL_Di_Val
                jmp ROL_invalid
                ROL_Di_Reg:
                    cmp selectedOp2Reg,7
                    jne ROL_invalid
                    cmp selectedPUPType,1
                    jne ROL_Di_Reg_his
                    ROL_Di_Reg_our:
                    mov Di,ourValRegDi
                    mov cx,ourValRegCX
                    ROL Di,cl
                    call ourSetCF
                    mov ourValRegDi,Di
                    jmp Exit
                    ROL_Di_Reg_his:
                    mov Di,ValRegDi
                    mov cx,ValRegCX
                    ROL Di,cl
                    call SetCarryFlag
                    mov ValRegDi,Di
                    cmp selectedPUPType,2
                    je ROL_Di_Reg_our
                    jmp Exit
                ROL_Di_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    cmp selectedPUPType,1
                    jne ROL_Di_Val_his
                    ROL_Di_Val_our:
                    mov Di,ourValRegDi
                    mov cx,Op2Val
                    ROL Di,cl
                    call ourSetCF
                    mov ourValRegDi,Di
                    jmp Exit
                    ROL_Di_Val_his:
                    mov ax,ValRegDi
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    ROL ax,cl
                    call SetCarryFlag
                    mov ValRegDi,ax
                    cmp selectedPUPType,2
                    je ROL_Di_Val_our
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
                    cmp selectedPUPType,1
                    jne ROL_AddBx_Reg_his
                    ROL_AddBx_Reg_our:
                    mov Bx,ourValRegBX
                    cmp Bx,15d
                    ja ROL_invalid
                    mov cx,ourValRegCX
                    ROL ourValMem[Bx],cl
                    call ourSetCF
                    mov ourValRegBX,Bx
                    jmp Exit
                    ROL_AddBx_Reg_his:
                    mov Bx,ValRegBX
                    cmp Bx,15d
                    ja ROL_invalid
                    mov cx,ValRegCX
                    ;;;;;;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[Bx]
                        call LineStuckPwrUp
                        mov ValMem[Bx],al
                    ROL ValMem[Bx],cl
                    call SetCarryFlag
                    mov ValRegBX,Bx
                    cmp selectedPUPType,2
                    je ROL_AddBx_Reg_our
                    jmp Exit
                ROL_AddBx_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    cmp selectedPUPType,1
                    jne ROL_AddBx_Val_his
                    ROL_AddBx_Val_our:
                    mov Bx,ourValRegBX
                    cmp Bx,15d
                    ja ROL_invalid
                    mov cx,Op2Val
                    ROL ourValMem[Bx],cl
                    call ourSetCF
                    mov ourValRegBX,Bx
                    jmp Exit
                    ROL_AddBx_Val_his:
                    mov Bx,ValRegBX
                    cmp Bx,15d
                    ja ROL_invalid
                    mov cx,Op2Val
                    ;;;;;;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[Bx]
                        call LineStuckPwrUp
                        mov ValMem[Bx],al
                    ROL ValMem[Bx],cl
                    call SetCarryFlag
                    mov ValRegBX,Bx
                    cmp selectedPUPType,2
                    je ROL_AddBx_Val_our
                    jmp Exit
            ROL_AddBp:
                cmp selectedOp2Type,0
                je ROL_AddBp_Reg
                cmp selectedOp2Type,3
                je ROL_AddBp_Val
                jmp ROL_invalid
                ROL_AddBp_Reg:
                    cmp selectedOp2Reg,7
                    jne ROL_invalid
                    cmp selectedPUPType,1
                    jne ROL_AddBp_Reg_his
                    ROL_AddBp_Reg_our:
                    mov Bp,ourValRegBp
                    cmp Bp,15d
                    ja ROL_invalid
                    mov cx,ourValRegCX
                    ROL ourValMem[Bp],cl
                    call ourSetCF
                    mov ourValRegBp,Bp
                    jmp Exit
                    ROL_AddBp_Reg_his:
                    mov Bp,ValRegBp
                    cmp Bp,15d
                    ja ROL_invalid
                    mov cx,ValRegCX
                    ;;;;;;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[Bp]
                        call LineStuckPwrUp
                        mov ValMem[Bp],al
                    ROL ValMem[Bp],cl
                    call SetCarryFlag
                    mov ValRegBp,Bp
                    cmp selectedPUPType,2
                    je ROL_AddBp_Reg_our
                    jmp Exit
                ROL_AddBp_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    cmp selectedPUPType,1
                    jne ROL_AddBp_Val_his
                    ROL_AddBp_Val_our:
                    mov Bp,ourValRegBp
                    cmp Bp,15d
                    ja ROL_invalid
                    mov cx,Op2Val
                    ROL ourValMem[Bp],cl
                    call ourSetCF
                    mov ourValRegBp,Bp
                    jmp Exit
                    ROL_AddBp_Val_his:
                    mov Bp,ValRegBp
                    cmp Bp,15d
                    ja ROL_invalid
                    mov cx,Op2Val
                    ;;;;;;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[Bp]
                        call LineStuckPwrUp
                        mov ValMem[Bp],al
                    ROL ValMem[Bp],cl
                    call SetCarryFlag
                    mov ValRegBp,Bp
                    cmp selectedPUPType,2
                    je ROL_AddBp_Val_our
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
                    cmp selectedPUPType,1
                    jne ROL_AddSi_Reg_his
                    ROL_AddSi_Reg_our:
                    mov Si,ourValRegSi
                    cmp Si,15d
                    ja ROL_invalid
                    mov cx,ourValRegCX
                    ROL ourValMem[Si],cl
                    call ourSetCF
                    mov ourValRegSi,Si
                    jmp Exit
                    ROL_AddSi_Reg_his:
                    mov Si,ValRegSi
                    cmp Si,15d
                    ja ROL_invalid
                    mov cx,ValRegCX
                    ;;;;;;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[Si]
                        call LineStuckPwrUp
                        mov ValMem[Si],al
                    ROL ValMem[Si],cl
                    call SetCarryFlag
                    mov ValRegSi,Si
                    cmp selectedPUPType,2
                    je ROL_AddSi_Reg_our
                    jmp Exit
                ROL_AddSi_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    cmp selectedPUPType,1
                    jne ROL_AddSi_Val_his
                    ROL_AddSi_Val_our:
                    mov Si,ourValRegSi
                    cmp Si,15d
                    ja ROL_invalid
                    mov cx,Op2Val
                    ROL ourValMem[Si],cl
                    call ourSetCF
                    mov ourValRegSi,Si
                    jmp Exit
                    ROL_AddSi_Val_his:
                    mov Si,ValRegSi
                    cmp Si,15d
                    ja ROL_invalid
                    mov cx,Op2Val
                    ;;;;;;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[Si]
                        call LineStuckPwrUp
                        mov ValMem[Si],al
                    ROL ValMem[Si],cl
                    call SetCarryFlag
                    mov ValRegSi,Si
                    cmp selectedPUPType,2
                    je ROL_AddSi_Val_our
                    jmp Exit
            ROL_AddDi:
                cmp selectedOp2Type,0
                je ROL_AddDi_Reg
                cmp selectedOp2Type,3
                je ROL_AddDi_Val
                jmp ROL_invalid
                ROL_AddDi_Reg:
                    cmp selectedOp2Reg,7
                    jne ROL_invalid
                    cmp selectedPUPType,1
                    jne ROL_AddDi_Reg_his
                    ROL_AddDi_Reg_our:
                    mov Di,ourValRegDi
                    cmp Di,15d
                    ja ROL_invalid
                    mov cx,ourValRegCX
                    ROL ourValMem[Di],cl
                    call ourSetCF
                    mov ourValRegDi,Di
                    jmp Exit
                    ROL_AddDi_Reg_his:
                    mov Di,ValRegDi
                    cmp Di,15d
                    ja ROL_invalid
                    mov cx,ValRegCX
                    ;;;;;;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[Di]
                        call LineStuckPwrUp
                        mov ValMem[Di],al
                    ROL ValMem[Di],cl
                    call SetCarryFlag
                    mov ValRegDi,Di
                    cmp selectedPUPType,2
                    je ROL_AddDi_Reg_our
                    jmp Exit
                ROL_AddDi_Val:
                    cmp Op2Val,255d
                    ja ROL_invalid
                    cmp selectedPUPType,1
                    jne ROL_AddDi_Val_his
                    ROL_AddDi_Val_our:
                    mov Di,ourValRegDi
                    cmp Di,15d
                    ja ROL_invalid
                    mov cx,Op2Val
                    ROL ourValMem[Di],cl
                    call ourSetCF
                    mov ourValRegDi,Di
                    jmp Exit
                    ROL_AddDi_Val_his:
                    mov Di,ValRegDi
                    cmp Di,15d
                    ja ROL_invalid
                    mov cx,Op2Val
                    ;;;;;;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[Di]
                        call LineStuckPwrUp
                        mov ValMem[Di],al
                    ROL ValMem[Di],cl
                    call SetCarryFlag
                    mov ValRegDi,Di
                    cmp selectedPUPType,2
                    je ROL_AddDi_Val_our
                    jmp Exit
        mov si,0
        ROL_Mem:
            mov bx,si
            cmp selectedOp2Mem,bl
            jne ROL_NotIt
            cmp selectedOp2Type,0
            je ROL_Mem_Reg
            cmp selectedOp2Type,3
            je ROL_Mem_Val
            jmp ROL_invalid
            ROL_Mem_Reg:
                cmp selectedOp2Reg,7
                jne ROL_invalid
                cmp selectedPUPType,1
                jne ROL_Mem_Reg_his
                ROL_Mem_Reg_our:
                mov cx,ourValRegCX
                ROL ourValMem[si],cl
                call ourSetCF
                jmp Exit
                ROL_Mem_Reg_his:
                mov cx,ValRegCX
                ;;;;;;;;;;;;;;;;;;
                    mov al,ValMem[si]
                    call LineStuckPwrUp
                    mov ValMem[si],al
                ROL ValMem[si],cl
                call SetCarryFlag
                cmp selectedPUPType,2
                je ROL_Mem_Reg_our
                jmp Exit
            ROL_Mem_Val:
                cmp Op2Val,255d
                ja ROL_invalid
                cmp selectedPUPType,1
                jne ROL_Mem_Val_his
                ROL_Mem_Val_our:
                mov cx,Op2Val
                ROL ourValMem[si],cl
                call ourSetCF
                jmp Exit
                ROL_Mem_Val_his:
                mov cx,Op2Val
                ;;;;;;;;;;;;;;;;;;
                    mov al,ValMem[si]
                    call LineStuckPwrUp
                    mov ValMem[si],al
                ROL ValMem[si],cl
                call SetCarryFlag
                cmp selectedPUPType,2
                je ROL_Mem_Val_our
                jmp Exit
            ROL_NotIt:
            inc si
            jmp ROL_Mem
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
                    cmp selectedPUPType,1
                    jne RCR_Ax_Reg_his
                    RCR_Ax_Reg_our:
                    mov ax,ourValRegAX
                    mov cx,ourValRegCX
                    call ourGetCF
                    RCR Ax,cl
                    call ourSetCF
                    mov ourValRegAX,ax
                    jmp Exit
                    RCR_Ax_Reg_his:
                    mov ax,ValRegAX
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR Ax,cl
                    call SetCarryFlag
                    mov ValRegAX,ax
                    cmp selectedPUPType,2
                    je RCR_Ax_Reg_our
                    jmp Exit
                RCR_Ax_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    cmp selectedPUPType,1
                    jne RCR_Ax_Val_his
                    RCR_Ax_Val_our:
                    mov ax,ourValRegAX
                    mov cx,Op2Val
                    call ourGetCF
                    RCR ax,cl
                    call ourSetCF
                    mov ourValRegAX,ax
                    jmp Exit
                    RCR_Ax_Val_his:
                    mov ax,ValRegAX
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    call GetCarryFlag
                    RCR ax,cl
                    call SetCarryFlag
                    mov ValRegAX,ax
                    cmp selectedPUPType,2
                    je RCR_Ax_Val_our
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
                    cmp selectedPUPType,1
                    jne RCR_Al_Reg_his
                    RCR_Al_Reg_our:
                    mov ax,ourValRegAX
                    mov cx,ourValRegCX
                    call ourGetCF
                    RCR Al,cl
                    call ourSetCF
                    mov ourValRegAX,ax
                    jmp Exit
                    RCR_Al_Reg_his:
                    mov ax,ValRegAX
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR Al,cl
                    call SetCarryFlag
                    mov ValRegAX,ax
                    cmp selectedPUPType,2
                    je RCR_Al_Reg_our
                    jmp Exit
                RCR_Al_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    cmp selectedPUPType,1
                    jne RCR_Al_Val_his
                    RCR_Al_Val_our:
                    mov ax,ourValRegAX
                    mov cx,Op2Val
                    call ourGetCF
                    RCR al,cl
                    call ourSetCF
                    mov ourValRegAX,ax
                    jmp Exit
                    RCR_Al_Val_his:
                    mov ax,ValRegAX
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    call GetCarryFlag
                    RCR al,cl
                    call SetCarryFlag
                    mov ValRegAX,ax
                    cmp selectedPUPType,2
                    je RCR_Al_Val_our
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
                    cmp selectedPUPType,1
                    jne RCR_Ah_Reg_his
                    RCR_Ah_Reg_our:
                    mov ax,ourValRegAX
                    mov cx,ourValRegCX
                    call ourGetCF
                    RCR Ah,cl
                    call ourSetCF
                    mov ourValRegAX,ax
                    jmp Exit
                    RCR_Ah_Reg_his:
                    mov ax,ValRegAX
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR Ah,cl
                    call SetCarryFlag
                    mov ValRegAX,ax
                    cmp selectedPUPType,2
                    je RCR_Ah_Reg_our
                    jmp Exit
                RCR_Ah_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    cmp selectedPUPType,1
                    jne RCR_Ah_Val_his
                    RCR_Ah_Val_our:
                    mov ax,ourValRegAX
                    mov cx,Op2Val
                    call ourGetCF
                    RCR ah,cl
                    call ourSetCF
                    mov ourValRegAX,ax
                    jmp Exit
                    RCR_Ah_Val_his:
                    mov ax,ValRegAX
                    mov cx,Op2Val
                    ;;;;;;;;;;
                        mov bx,ax
                        mov al,ah
                        call LineStuckPwrUp
                        mov ah,al
                        mov al,bl
                    call GetCarryFlag
                    RCR ah,cl
                    call SetCarryFlag
                    mov ValRegAX,ax
                    cmp selectedPUPType,2
                    je RCR_Ah_Val_our
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
                    cmp selectedPUPType,1
                    jne RCR_Bx_Reg_his
                    RCR_Bx_Reg_our:
                    mov Bx,ourValRegBx
                    mov cx,ourValRegCX
                    call ourGetCF
                    RCR Bx,cl
                    call ourSetCF
                    mov ourValRegBx,Bx
                    jmp Exit
                    RCR_Bx_Reg_his:
                    mov Bx,ValRegBx
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR Bx,cl
                    call SetCarryFlag
                    mov ValRegBx,Bx
                    cmp selectedPUPType,2
                    je RCR_Bx_Reg_our
                    jmp Exit
                RCR_Bx_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    cmp selectedPUPType,1
                    jne RCR_Bx_Val_his
                    RCR_Bx_Val_our:
                    mov Bx,ourValRegBx
                    mov cx,Op2Val
                    call ourGetCF
                    RCR Bx,cl
                    call ourSetCF
                    mov ourValRegBx,Bx
                    jmp Exit
                    RCR_Bx_Val_his:
                    mov Bx,ValRegBx
                    mov cx,Op2Val
                    mov ax,bx
                    call LineStuckPwrUp
                    mov bx,ax
                    call GetCarryFlag
                    RCR Bx,cl
                    call SetCarryFlag
                    mov ValRegBx,Bx
                    cmp selectedPUPType,2
                    je RCR_Bx_Val_our
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
                    cmp selectedPUPType,1
                    jne RCR_Bl_Reg_his
                    RCR_Bl_Reg_our:
                    mov Bx,ourValRegBX
                    mov cx,ourValRegCX
                    call ourGetCF
                    RCR Bl,cl
                    call ourSetCF
                    mov ourValRegBX,Bx
                    jmp Exit
                    RCR_Bl_Reg_his:
                    mov Bx,ValRegBX
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR Bl,cl
                    call SetCarryFlag
                    mov ValRegBX,Bx
                    cmp selectedPUPType,2
                    je RCR_Bl_Reg_our
                    jmp Exit
                RCR_Bl_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    cmp selectedPUPType,1
                    RCR_Bl_Val_our:
                    mov Bx,ourValRegBX
                    mov cx,Op2Val
                    call ourGetCF
                    RCR Bl,cl
                    call ourSetCF
                    mov ourValRegBX,Bx
                    jmp Exit
                    RCR_Bl_Val_his:
                    mov Bx,ValRegBX
                    mov cx,Op2Val
                    mov al,Bl
                    call LineStuckPwrUp
                    mov Bl,al
                    call GetCarryFlag
                    RCR Bl,cl
                    call SetCarryFlag
                    mov ValRegBX,Bx
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
                    cmp selectedPUPType,1
                    jne RCR_Bh_Reg_his
                    RCR_Bh_Reg_our:
                    mov Bx,ourValRegBX
                    mov cx,ourValRegCX
                    call ourGetCF
                    RCR Bh,cl
                    call ourSetCF
                    mov ourValRegBX,Bx
                    jmp Exit
                    RCR_Bh_Reg_his:
                    mov Bx,ValRegBX
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR Bh,cl
                    call SetCarryFlag
                    mov ValRegBX,Bx
                    cmp selectedPUPType,2
                    je RCR_Bh_Reg_our
                    jmp Exit
                RCR_Bh_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    cmp selectedPUPType,1
                    RCR_Bh_Val_our:
                    mov Bx,ourValRegBX
                    mov cx,Op2Val
                    call ourGetCF
                    RCR Bh,cl
                    call ourSetCF
                    mov ourValRegBX,Bx
                    jmp Exit
                    RCR_Bh_Val_his:
                    mov Bx,ValRegBX
                    mov cx,Op2Val
                    mov al,Bh
                    call LineStuckPwrUp
                    mov Bh,al
                    call GetCarryFlag
                    RCR Bh,cl
                    call SetCarryFlag
                    mov ValRegBX,Bx
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
                    cmp selectedPUPType,1
                    jne RCR_Cx_Reg_his
                    RCR_Cx_Reg_our:
                    mov Cx,ourValRegCx
                    mov ax,cx
                    mov cx,ax
                    call ourGetCF
                    RCR Cx,cl
                    call ourSetCF
                    mov ourValRegCx,Cx
                    jmp Exit
                    RCR_Cx_Reg_his:
                    cmp selectedOp2Reg,7
                    jne RCR_invalid
                    mov Cx,ValRegCx
                    mov ax,cx
                    mov cx,ax
                    call GetCarryFlag
                    RCR Cx,cl
                    call SetCarryFlag
                    mov ValRegCx,Cx
                    cmp selectedPUPType,2
                    je RCR_Cx_Reg_our
                    jmp Exit
                RCR_Cx_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    cmp selectedPUPType,1
                    jne RCR_Cx_Val_his
                    RCR_Cx_Val_our:
                    mov bx,ourValRegCx
                    mov cx,Op2Val
                    call ourGetCF
                    RCR bx,cl
                    call ourSetCF
                    mov ourValRegCx,bx
                    jmp Exit
                    RCR_Cx_Val_his:
                    mov bx,ValRegCx
                    mov cx,Op2Val
                    mov ax,bx
                    call LineStuckPwrUp
                    mov bx,ax
                    call GetCarryFlag
                    RCR bx,cl
                    call SetCarryFlag
                    mov ValRegCx,bx
                    cmp selectedPUPType,2
                    je RCR_Cx_Val_our
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
                    cmp selectedPUPType,1
                    jne RCR_Cl_Reg_his
                    RCR_Cl_Reg_our:
                    mov ax,ourValRegCX
                    mov cx,ourValRegCX
                    call ourGetCF
                    RCR Al,cl
                    call ourSetCF
                    mov ourValRegCX,ax
                    jmp Exit
                    RCR_Cl_Reg_his:
                    mov ax,ValRegCX
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR Al,cl
                    call SetCarryFlag
                    mov ValRegCX,ax
                    cmp selectedPUPType,2
                    je RCR_Cl_Reg_our
                    jmp Exit
                RCR_Cl_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    cmp selectedPUPType,1
                    jne RCR_Cl_Val_his
                    RCR_Cl_Val_our:
                    mov ax,ourValRegCX
                    mov cx,Op2Val
                    call ourGetCF
                    RCR al,cl
                    call ourSetCF
                    mov ourValRegCX,ax
                    jmp Exit
                    RCR_Cl_Val_his:
                    mov ax,ValRegCX
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    call GetCarryFlag
                    RCR al,cl
                    call SetCarryFlag
                    mov ValRegCX,ax
                    cmp selectedPUPType,2
                    je RCR_Cl_Val_our
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
                    cmp selectedPUPType,1
                    jne RCR_Ch_Reg_his
                    RCR_Ch_Reg_our:
                    mov cx,ourValRegCX
                    call ourGetCF
                    RCR Ch,cl
                    call ourSetCF
                    mov ourValRegCX,Cx
                    jmp Exit
                    RCR_Ch_Reg_his:
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR Ch,cl
                    call SetCarryFlag
                    mov ValRegCX,Cx
                    cmp selectedPUPType,2
                    je RCR_Ch_Reg_our
                    jmp Exit
                RCR_Ch_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    cmp selectedPUPType,1
                    jne RCR_Ch_Val_his
                    RCR_Ch_Val_our:
                    mov ax,ourValRegCX
                    mov cx,Op2Val
                    call ourGetCF
                    RCR ah,cl
                    call ourSetCF
                    mov ourValRegCX,ax
                    jmp Exit
                    RCR_Ch_Val_his:
                    mov ax,ValRegCX
                    mov cx,Op2Val
                    ;;;;;;;;;;
                        mov bx,ax
                        mov al,ah
                        call LineStuckPwrUp
                        mov ah,al
                        mov al,bl
                    call GetCarryFlag
                    RCR ah,cl
                    call SetCarryFlag
                    mov ValRegCX,ax
                    cmp selectedPUPType,2
                    je RCR_Ch_Val_our
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
                    cmp selectedPUPType,1
                    jne RCR_Dx_Reg_his
                    RCR_Dx_Reg_our:
                    mov Dx,ourValRegDx
                    mov cx,ourValRegCX
                    call ourGetCF
                    RCR Dx,cl
                    call ourSetCF
                    mov ourValRegDx,Dx
                    jmp Exit
                    RCR_Dx_Reg_his:
                    mov Dx,ValRegDx
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR Dx,cl
                    call SetCarryFlag
                    mov ValRegDx,Dx
                    cmp selectedPUPType,2
                    je RCR_Dx_Reg_our
                    jmp Exit
                RCR_Dx_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    cmp selectedPUPType,1
                    jne RCR_Dx_Val_his
                    RCR_Dx_Val_our:
                    mov ax,ourValRegDx
                    mov cx,Op2Val
                    call ourGetCF
                    RCR ax,cl
                    call ourSetCF
                    mov ourValRegDx,ax
                    jmp Exit
                    RCR_Dx_Val_his:
                    mov ax,ValRegDx
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    call GetCarryFlag
                    RCR ax,cl
                    call SetCarryFlag
                    mov ValRegDx,ax
                    cmp selectedPUPType,2
                    je RCR_Dx_Val_our
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
                    cmp selectedPUPType,1
                    jne RCR_Dl_Reg_his
                    RCR_Dl_Reg_our:
                    mov Dx,ourValRegDX
                    mov cx,ourValRegCX
                    call ourGetCF
                    RCR Dl,cl
                    call ourSetCF
                    mov ourValRegDX,Dx
                    jmp Exit
                    RCR_Dl_Reg_his:
                    mov Dx,ValRegDX
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR Dl,cl
                    call SetCarryFlag
                    mov ValRegDX,Dx
                    cmp selectedPUPType,2
                    je RCR_Dl_Reg_our
                    jmp Exit
                RCR_Dl_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    cmp selectedPUPType,1
                    jne RCR_Dl_Val_his
                    RCR_Dl_Val_our:
                    mov Dx,ourValRegDX
                    mov cx,Op2Val
                    call ourGetCF
                    RCR Dl,cl
                    call ourSetCF
                    mov ourValRegDX,Dx
                    jmp Exit
                    RCR_Dl_Val_his:
                    mov ax,ValRegDX
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    call GetCarryFlag
                    RCR al,cl
                    call SetCarryFlag
                    mov ValRegDX,ax
                    cmp selectedPUPType,2
                    je RCR_Dl_Val_our
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
                    cmp selectedPUPType,1
                    jne RCR_Dh_Reg_his
                    RCR_Dh_Reg_our:
                    mov Dx,ourValRegDX
                    mov cx,ourValRegCX
                    call ourGetCF
                    RCR dh,cl
                    call ourSetCF
                    mov ourValRegDX,Dx
                    jmp Exit
                    RCR_Dh_Reg_his:
                    mov Dx,ValRegDX
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR dh,cl
                    call SetCarryFlag
                    mov ValRegDX,Dx
                    cmp selectedPUPType,2
                    je RCR_Dh_Reg_our
                    jmp Exit
                RCR_Dh_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    cmp selectedPUPType,1
                    jne RCR_Dh_Val_his
                    RCR_Dh_Val_our:
                    mov Dx,ourValRegDX
                    mov cx,Op2Val
                    call ourGetCF
                    RCR dh,cl
                    call ourSetCF
                    mov ourValRegDX,Dx
                    jmp Exit
                    RCR_Dh_Val_his:
                    mov ax,ValRegDX
                    mov cx,Op2Val
                    ;;;;;;;;;;
                        mov bx,ax
                        mov al,ah
                        call LineStuckPwrUp
                        mov ah,al
                        mov al,bl
                    call GetCarryFlag
                    RCR ah,cl
                    call SetCarryFlag
                    mov ValRegDX,ax
                    cmp selectedPUPType,2
                    je RCR_Dh_Val_our
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
                    cmp selectedPUPType,1
                    jne RCR_Bp_Reg_his
                    RCR_Bp_Reg_our:
                    mov Bp,ourValRegBp
                    mov cx,ourValRegCX
                    call ourGetCF
                    RCR Bp,cl
                    call ourSetCF
                    mov ourValRegBp,Bp
                    jmp Exit
                    RCR_Bp_Reg_his:
                    mov Bp,ValRegBp
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR Bp,cl
                    call SetCarryFlag
                    mov ValRegBp,Bp
                    cmp selectedPUPType,2
                    je RCR_Bp_Reg_our
                    jmp Exit
                RCR_Bp_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    cmp selectedPUPType,1
                    jne RCR_Bp_Val_his
                    RCR_Bp_Val_our:
                    mov Bp,ourValRegBp
                    mov cx,Op2Val
                    call ourGetCF
                    RCR Bp,cl
                    call ourSetCF
                    mov ourValRegBp,Bp
                    jmp Exit
                    RCR_Bp_Val_his:
                    mov ax,ValRegBp
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    call GetCarryFlag
                    RCR ax,cl
                    call SetCarryFlag
                    mov ValRegBp,ax
                    cmp selectedPUPType,2
                    je RCR_Bp_Val_our
                    jmp Exit
            RCR_Sp:
                cmp selectedOp2Type,0
                je RCR_Sp_Reg
                cmp selectedOp2Type,3
                je RCR_Sp_Val
                jmp RCR_invalid
                RCR_Sp_Reg:
                    cmp selectedOp2Reg,7
                    jne RCR_invalid
                    cmp selectedPUPType,1
                    jne RCR_Sp_Reg_his
                    RCR_Sp_Reg_our:
                    mov Sp,ourValRegSp
                    mov cx,ourValRegCX
                    call ourGetCF
                    RCR Sp,cl
                    call ourSetCF
                    mov ourValRegSp,Sp
                    jmp Exit
                    RCR_Sp_Reg_his:
                    mov Sp,ValRegSp
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR Sp,cl
                    call SetCarryFlag
                    mov ValRegSp,Sp
                    cmp selectedPUPType,2
                    je RCR_Sp_Reg_our
                    jmp Exit
                RCR_Sp_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    cmp selectedPUPType,1
                    jne RCR_Sp_Val_his
                    RCR_Sp_Val_our:
                    mov Sp,ourValRegSp
                    mov cx,Op2Val
                    call ourGetCF
                    RCR Sp,cl
                    call ourSetCF
                    mov ourValRegSp,Sp
                    jmp Exit
                    RCR_Sp_Val_his:
                    mov ax,ValRegSp
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    call GetCarryFlag
                    RCR ax,cl
                    call SetCarryFlag
                    mov ValRegSp,ax
                    cmp selectedPUPType,2
                    je RCR_Sp_Val_our
                    jmp Exit
            RCR_Si:
                cmp selectedOp2Type,0
                je RCR_Si_Reg
                cmp selectedOp2Type,3
                je RCR_Si_Val
                jmp RCR_invalid
                RCR_Si_Reg:
                    cmp selectedOp2Reg,7
                    jne RCR_invalid
                    cmp selectedPUPType,1
                    jne RCR_Si_Reg_his
                    RCR_Si_Reg_our:
                    mov Si,ourValRegSi
                    mov cx,ourValRegCX
                    call ourGetCF
                    RCR Si,cl
                    call ourSetCF
                    mov ourValRegSi,Si
                    jmp Exit
                    RCR_Si_Reg_his:
                    mov Si,ValRegSi
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR Si,cl
                    call SetCarryFlag
                    mov ValRegSi,Si
                    cmp selectedPUPType,2
                    je RCR_Si_Reg_our
                    jmp Exit
                RCR_Si_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    cmp selectedPUPType,1
                    jne RCR_Si_Val_his
                    RCR_Si_Val_our:
                    mov Si,ourValRegSi
                    mov cx,Op2Val
                    call ourGetCF
                    RCR Si,cl
                    call ourSetCF
                    mov ourValRegSi,Si
                    jmp Exit
                    RCR_Si_Val_his:
                    mov ax,ValRegSi
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    call GetCarryFlag
                    RCR ax,cl
                    call SetCarryFlag
                    mov ValRegSi,ax
                    cmp selectedPUPType,2
                    je RCR_Si_Val_our
                    jmp Exit
            RCR_Di:
                cmp selectedOp2Type,0
                je RCR_Di_Reg
                cmp selectedOp2Type,3
                je RCR_Di_Val
                jmp RCR_invalid
                RCR_Di_Reg:
                    cmp selectedOp2Reg,7
                    jne RCR_invalid
                    cmp selectedPUPType,1
                    jne RCR_Di_Reg_his
                    RCR_Di_Reg_our:
                    mov Di,ourValRegDi
                    mov cx,ourValRegCX
                    call ourGetCF
                    RCR Di,cl
                    call ourSetCF
                    mov ourValRegDi,Di
                    jmp Exit
                    RCR_Di_Reg_his:
                    mov Di,ValRegDi
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCR Di,cl
                    call SetCarryFlag
                    mov ValRegDi,Di
                    cmp selectedPUPType,2
                    je RCR_Di_Reg_our
                    jmp Exit
                RCR_Di_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    cmp selectedPUPType,1
                    jne RCR_Di_Val_his
                    RCR_Di_Val_our:
                    mov Di,ourValRegDi
                    mov cx,Op2Val
                    call ourGetCF
                    RCR Di,cl
                    call ourSetCF
                    mov ourValRegDi,Di
                    jmp Exit
                    RCR_Di_Val_his:
                    mov ax,ValRegDi
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    call GetCarryFlag
                    RCR ax,cl
                    call SetCarryFlag
                    mov ValRegDi,ax
                    cmp selectedPUPType,2
                    je RCR_Di_Val_our
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
                    cmp selectedPUPType,1
                    jne RCR_AddBx_Reg_his
                    RCR_AddBx_Reg_our:
                    mov Bx,ourValRegBX
                    cmp Bx,15d
                    ja RCR_invalid
                    mov cx,ourValRegCX
                    call ourGetCF
                    RCR ourValMem[Bx],cl
                    call ourSetCF
                    mov ourValRegBX,Bx
                    jmp Exit
                    RCR_AddBx_Reg_his:
                    mov Bx,ValRegBX
                    cmp Bx,15d
                    ja RCR_invalid
                    mov cx,ValRegCX
                    ;;;;;;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[Bx]
                        call LineStuckPwrUp
                        mov ValMem[Bx],al
                    call GetCarryFlag
                    RCR ValMem[Bx],cl
                    call SetCarryFlag
                    mov ValRegBX,Bx
                    cmp selectedPUPType,2
                    je RCR_AddBx_Reg_our
                    jmp Exit
                RCR_AddBx_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    cmp selectedPUPType,1
                    jne RCR_AddBx_Val_his
                    RCR_AddBx_Val_our:
                    mov Bx,ourValRegBX
                    cmp Bx,15d
                    ja RCR_invalid
                    mov cx,Op2Val
                    call ourGetCF
                    RCR ourValMem[Bx],cl
                    call ourSetCF
                    mov ourValRegBX,Bx
                    jmp Exit
                    RCR_AddBx_Val_his:
                    mov Bx,ValRegBX
                    cmp Bx,15d
                    ja RCR_invalid
                    mov cx,Op2Val
                    ;;;;;;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[Bx]
                        call LineStuckPwrUp
                        mov ValMem[Bx],al
                    call GetCarryFlag
                    RCR ValMem[Bx],cl
                    call SetCarryFlag
                    mov ValRegBX,Bx
                    cmp selectedPUPType,2
                    je RCR_AddBx_Val_our
                    jmp Exit
            RCR_AddBp:
                cmp selectedOp2Type,0
                je RCR_AddBp_Reg
                cmp selectedOp2Type,3
                je RCR_AddBp_Val
                jmp RCR_invalid
                RCR_AddBp_Reg:
                    cmp selectedOp2Reg,7
                    jne RCR_invalid
                    cmp selectedPUPType,1
                    jne RCR_AddBp_Reg_his
                    RCR_AddBp_Reg_our:
                    mov Bp,ourValRegBp
                    cmp Bp,15d
                    ja RCR_invalid
                    mov cx,ourValRegCX
                    call ourGetCF
                    RCR ourValMem[Bp],cl
                    call ourSetCF
                    mov ourValRegBp,Bp
                    jmp Exit
                    RCR_AddBp_Reg_his:
                    mov Bp,ValRegBp
                    cmp Bp,15d
                    ja RCR_invalid
                    mov cx,ValRegCX
                    ;;;;;;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[Bp]
                        call LineStuckPwrUp
                        mov ValMem[Bp],al
                    call GetCarryFlag
                    RCR ValMem[Bp],cl
                    call SetCarryFlag
                    mov ValRegBp,Bp
                    cmp selectedPUPType,2
                    je RCR_AddBp_Reg_our
                    jmp Exit
                RCR_AddBp_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    cmp selectedPUPType,1
                    jne RCR_AddBp_Val_his
                    RCR_AddBp_Val_our:
                    mov Bp,ourValRegBp
                    cmp Bp,15d
                    ja RCR_invalid
                    mov cx,Op2Val
                    call ourGetCF
                    RCR ourValMem[Bp],cl
                    call ourSetCF
                    mov ourValRegBp,Bp
                    jmp Exit
                    RCR_AddBp_Val_his:
                    mov Bp,ValRegBp
                    cmp Bp,15d
                    ja RCR_invalid
                    mov cx,Op2Val
                    ;;;;;;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[Bp]
                        call LineStuckPwrUp
                        mov ValMem[Bp],al
                    call GetCarryFlag
                    RCR ValMem[Bp],cl
                    call SetCarryFlag
                    mov ValRegBp,Bp
                    cmp selectedPUPType,2
                    je RCR_AddBp_Val_our
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
                    cmp selectedPUPType,1
                    jne RCR_AddSi_Reg_his
                    RCR_AddSi_Reg_our:
                    mov Si,ourValRegSi
                    cmp Si,15d
                    ja RCR_invalid
                    mov cx,ourValRegCX
                    call ourGetCF
                    RCR ourValMem[Si],cl
                    call ourSetCF
                    mov ourValRegSi,Si
                    jmp Exit
                    RCR_AddSi_Reg_his:
                    mov Si,ValRegSi
                    cmp Si,15d
                    ja RCR_invalid
                    mov cx,ValRegCX
                    ;;;;;;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[Si]
                        call LineStuckPwrUp
                        mov ValMem[Si],al
                    call GetCarryFlag
                    RCR ValMem[Si],cl
                    call SetCarryFlag
                    mov ValRegSi,Si
                    cmp selectedPUPType,2
                    je RCR_AddSi_Reg_our
                    jmp Exit
                RCR_AddSi_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    cmp selectedPUPType,1
                    jne RCR_AddSi_Val_his
                    RCR_AddSi_Val_our:
                    mov Si,ourValRegSi
                    cmp Si,15d
                    ja RCR_invalid
                    mov cx,Op2Val
                    call ourGetCF
                    RCR ourValMem[Si],cl
                    call ourSetCF
                    mov ourValRegSi,Si
                    jmp Exit
                    RCR_AddSi_Val_his:
                    mov Si,ValRegSi
                    cmp Si,15d
                    ja RCR_invalid
                    mov cx,Op2Val
                    ;;;;;;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[Si]
                        call LineStuckPwrUp
                        mov ValMem[Si],al
                    call GetCarryFlag
                    RCR ValMem[Si],cl
                    call SetCarryFlag
                    mov ValRegSi,Si
                    cmp selectedPUPType,2
                    je RCR_AddSi_Val_our
                    jmp Exit
            RCR_AddDi:
                cmp selectedOp2Type,0
                je RCR_AddDi_Reg
                cmp selectedOp2Type,3
                je RCR_AddDi_Val
                jmp RCR_invalid
                RCR_AddDi_Reg:
                    cmp selectedOp2Reg,7
                    jne RCR_invalid
                    cmp selectedPUPType,1
                    jne RCR_AddDi_Reg_his
                    RCR_AddDi_Reg_our:
                    mov Di,ourValRegDi
                    cmp Di,15d
                    ja RCR_invalid
                    mov cx,ourValRegCX
                    call ourGetCF
                    RCR ourValMem[Di],cl
                    call ourSetCF
                    mov ourValRegDi,Di
                    jmp Exit
                    RCR_AddDi_Reg_his:
                    mov Di,ValRegDi
                    cmp Di,15d
                    ja RCR_invalid
                    mov cx,ValRegCX
                    ;;;;;;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[Di]
                        call LineStuckPwrUp
                        mov ValMem[Di],al
                    call GetCarryFlag
                    RCR ValMem[Di],cl
                    call SetCarryFlag
                    mov ValRegDi,Di
                    cmp selectedPUPType,2
                    je RCR_AddDi_Reg_our
                    jmp Exit
                RCR_AddDi_Val:
                    cmp Op2Val,255d
                    ja RCR_invalid
                    cmp selectedPUPType,1
                    jne RCR_AddDi_Val_his
                    RCR_AddDi_Val_our:
                    mov Di,ourValRegDi
                    cmp Di,15d
                    ja RCR_invalid
                    mov cx,Op2Val
                    call ourGetCF
                    RCR ourValMem[Di],cl
                    call ourSetCF
                    mov ourValRegDi,Di
                    jmp Exit
                    RCR_AddDi_Val_his:
                    mov Di,ValRegDi
                    cmp Di,15d
                    ja RCR_invalid
                    mov cx,Op2Val
                    ;;;;;;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[Di]
                        call LineStuckPwrUp
                        mov ValMem[Di],al
                    call GetCarryFlag
                    RCR ValMem[Di],cl
                    call SetCarryFlag
                    mov ValRegDi,Di
                    cmp selectedPUPType,2
                    je RCR_AddDi_Val_our
                    jmp Exit
        mov si,0
        RCR_Mem:
            mov bx,si
            cmp selectedOp2Mem,bl
            jne RCR_NotIt
            cmp selectedOp2Type,0
            je RCR_Mem_Reg
            cmp selectedOp2Type,3
            je RCR_Mem_Val
            jmp RCR_invalid
            RCR_Mem_Reg:
                cmp selectedOp2Reg,7
                jne RCR_invalid
                cmp selectedPUPType,1
                jne RCR_Mem_Reg_his
                RCR_Mem_Reg_our:
                mov cx,ourValRegCX
                call ourGetCF
                RCR ourValMem[si],cl
                call ourSetCF
                jmp Exit
                RCR_Mem_Reg_his:
                mov cx,ValRegCX
                ;;;;;;;;;;;;;;;;;;
                    mov al,ValMem[si]
                    call LineStuckPwrUp
                    mov ValMem[si],al
                call GetCarryFlag
                RCR ValMem[si],cl
                call SetCarryFlag
                cmp selectedPUPType,2
                je RCR_Mem_Reg_our
                jmp Exit
            RCR_Mem_Val:
                cmp Op2Val,255d
                ja RCR_invalid
                cmp selectedPUPType,1
                jne RCR_Mem_Val_his
                RCR_Mem_Val_our:
                mov cx,Op2Val
                call ourGetCF
                RCR ourValMem[si],cl
                call ourSetCF
                jmp Exit
                RCR_Mem_Val_his:
                mov cx,Op2Val
                ;;;;;;;;;;;;;;;;;;
                    mov al,ValMem[si]
                    call LineStuckPwrUp
                    mov ValMem[si],al
                call GetCarryFlag
                RCR ValMem[si],cl
                call SetCarryFlag
                cmp selectedPUPType,2
                je RCR_Mem_Val_our
                jmp Exit
            RCR_NotIt:
            inc si
            jmp RCR_Mem
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
                    cmp selectedPUPType,1
                    jne RCL_Ax_Reg_his
                    RCL_Ax_Reg_our:
                    mov ax,ourValRegAX
                    mov cx,ourValRegCX
                    call ourGetCF
                    RCL Ax,cl
                    call ourSetCF
                    mov ourValRegAX,ax
                    jmp Exit
                    RCL_Ax_Reg_his:
                    mov ax,ValRegAX
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL Ax,cl
                    call SetCarryFlag
                    mov ValRegAX,ax
                    cmp selectedPUPType,2
                    je RCL_Ax_Reg_our
                    jmp Exit
                RCL_Ax_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    cmp selectedPUPType,1
                    jne RCL_Ax_Val_his
                    RCL_Ax_Val_our:
                    mov ax,ourValRegAX
                    mov cx,Op2Val
                    call ourGetCF
                    RCL ax,cl
                    call ourSetCF
                    mov ourValRegAX,ax
                    jmp Exit
                    RCL_Ax_Val_his:
                    mov ax,ValRegAX
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    call GetCarryFlag
                    RCL ax,cl
                    call SetCarryFlag
                    mov ValRegAX,ax
                    cmp selectedPUPType,2
                    je RCL_Ax_Val_our
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
                    cmp selectedPUPType,1
                    jne RCL_Al_Reg_his
                    RCL_Al_Reg_our:
                    mov ax,ourValRegAX
                    mov cx,ourValRegCX
                    call ourGetCF
                    RCL Al,cl
                    call ourSetCF
                    mov ourValRegAX,ax
                    jmp Exit
                    RCL_Al_Reg_his:
                    mov ax,ValRegAX
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL Al,cl
                    call SetCarryFlag
                    mov ValRegAX,ax
                    cmp selectedPUPType,2
                    je RCL_Al_Reg_our
                    jmp Exit
                RCL_Al_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    cmp selectedPUPType,1
                    jne RCL_Al_Val_his
                    RCL_Al_Val_our:
                    mov ax,ourValRegAX
                    mov cx,Op2Val
                    call ourGetCF
                    RCL al,cl
                    call ourSetCF
                    mov ourValRegAX,ax
                    jmp Exit
                    RCL_Al_Val_his:
                    mov ax,ValRegAX
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    call GetCarryFlag
                    RCL al,cl
                    call SetCarryFlag
                    mov ValRegAX,ax
                    cmp selectedPUPType,2
                    je RCL_Al_Val_our
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
                    cmp selectedPUPType,1
                    jne RCL_Ah_Reg_his
                    RCL_Ah_Reg_our:
                    mov ax,ourValRegAX
                    mov cx,ourValRegCX
                    call ourGetCF
                    RCL Ah,cl
                    call ourSetCF
                    mov ourValRegAX,ax
                    jmp Exit
                    RCL_Ah_Reg_his:
                    mov ax,ValRegAX
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL Ah,cl
                    call SetCarryFlag
                    mov ValRegAX,ax
                    cmp selectedPUPType,2
                    je RCL_Ah_Reg_our
                    jmp Exit
                RCL_Ah_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    cmp selectedPUPType,1
                    jne RCL_Ah_Val_his
                    RCL_Ah_Val_our:
                    mov ax,ourValRegAX
                    mov cx,Op2Val
                    call ourGetCF
                    RCL ah,cl
                    call ourSetCF
                    mov ourValRegAX,ax
                    jmp Exit
                    RCL_Ah_Val_his:
                    mov ax,ValRegAX
                    mov cx,Op2Val
                    ;;;;;;;;;;
                        mov bx,ax
                        mov al,ah
                        call LineStuckPwrUp
                        mov ah,al
                        mov al,bl
                    call GetCarryFlag
                    RCL ah,cl
                    call SetCarryFlag
                    mov ValRegAX,ax
                    cmp selectedPUPType,2
                    je RCL_Ah_Val_our
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
                    cmp selectedPUPType,1
                    jne RCL_Bx_Reg_his
                    RCL_Bx_Reg_our:
                    mov Bx,ourValRegBx
                    mov cx,ourValRegCX
                    call ourGetCF
                    RCL Bx,cl
                    call ourSetCF
                    mov ourValRegBx,Bx
                    jmp Exit
                    RCL_Bx_Reg_his:
                    mov Bx,ValRegBx
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL Bx,cl
                    call SetCarryFlag
                    mov ValRegBx,Bx
                    cmp selectedPUPType,2
                    je RCL_Bx_Reg_our
                    jmp Exit
                RCL_Bx_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    cmp selectedPUPType,1
                    jne RCL_Bx_Val_his
                    RCL_Bx_Val_our:
                    mov Bx,ourValRegBx
                    mov cx,Op2Val
                    call ourGetCF
                    RCL Bx,cl
                    call ourSetCF
                    mov ourValRegBx,Bx
                    jmp Exit
                    RCL_Bx_Val_his:
                    mov Bx,ValRegBx
                    mov cx,Op2Val
                    mov ax,bx
                    call LineStuckPwrUp
                    mov bx,ax
                    call GetCarryFlag
                    RCL Bx,cl
                    call SetCarryFlag
                    mov ValRegBx,Bx
                    cmp selectedPUPType,2
                    je RCL_Bx_Val_our
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
                    cmp selectedPUPType,1
                    jne RCL_Bl_Reg_his
                    RCL_Bl_Reg_our:
                    mov Bx,ourValRegBX
                    mov cx,ourValRegCX
                    call ourGetCF
                    RCL Bl,cl
                    call ourSetCF
                    mov ourValRegBX,Bx
                    jmp Exit
                    RCL_Bl_Reg_his:
                    mov Bx,ValRegBX
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL Bl,cl
                    call SetCarryFlag
                    mov ValRegBX,Bx
                    cmp selectedPUPType,2
                    je RCL_Bl_Reg_our
                    jmp Exit
                RCL_Bl_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    cmp selectedPUPType,1
                    RCL_Bl_Val_our:
                    mov Bx,ourValRegBX
                    mov cx,Op2Val
                    call ourGetCF
                    RCL Bl,cl
                    call ourSetCF
                    mov ourValRegBX,Bx
                    jmp Exit
                    RCL_Bl_Val_his:
                    mov Bx,ValRegBX
                    mov cx,Op2Val
                    mov al,Bl
                    call LineStuckPwrUp
                    mov Bl,al
                    call GetCarryFlag
                    RCL Bl,cl
                    call SetCarryFlag
                    mov ValRegBX,Bx
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
                    cmp selectedPUPType,1
                    jne RCL_Bh_Reg_his
                    RCL_Bh_Reg_our:
                    mov Bx,ourValRegBX
                    mov cx,ourValRegCX
                    call ourGetCF
                    RCL Bh,cl
                    call ourSetCF
                    mov ourValRegBX,Bx
                    jmp Exit
                    RCL_Bh_Reg_his:
                    mov Bx,ValRegBX
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL Bh,cl
                    call SetCarryFlag
                    mov ValRegBX,Bx
                    cmp selectedPUPType,2
                    je RCL_Bh_Reg_our
                    jmp Exit
                RCL_Bh_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    cmp selectedPUPType,1
                    RCL_Bh_Val_our:
                    mov Bx,ourValRegBX
                    mov cx,Op2Val
                    call ourGetCF
                    RCL Bh,cl
                    call ourSetCF
                    mov ourValRegBX,Bx
                    jmp Exit
                    RCL_Bh_Val_his:
                    mov Bx,ValRegBX
                    mov cx,Op2Val
                    mov al,Bh
                    call LineStuckPwrUp
                    mov Bh,al
                    call GetCarryFlag
                    RCL Bh,cl
                    call SetCarryFlag
                    mov ValRegBX,Bx
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
                    cmp selectedPUPType,1
                    jne RCL_Cx_Reg_his
                    RCL_Cx_Reg_our:
                    mov Cx,ourValRegCx
                    mov ax,cx
                    mov cx,ax
                    call ourGetCF
                    RCL Cx,cl
                    call ourSetCF
                    mov ourValRegCx,Cx
                    jmp Exit
                    RCL_Cx_Reg_his:
                    cmp selectedOp2Reg,7
                    jne RCL_invalid
                    mov Cx,ValRegCx
                    mov ax,cx
                    mov cx,ax
                    call GetCarryFlag
                    RCL Cx,cl
                    call SetCarryFlag
                    mov ValRegCx,Cx
                    cmp selectedPUPType,2
                    je RCL_Cx_Reg_our
                    jmp Exit
                RCL_Cx_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    cmp selectedPUPType,1
                    jne RCL_Cx_Val_his
                    RCL_Cx_Val_our:
                    mov bx,ourValRegCx
                    mov cx,Op2Val
                    call ourGetCF
                    RCL bx,cl
                    call ourSetCF
                    mov ourValRegCx,bx
                    jmp Exit
                    RCL_Cx_Val_his:
                    mov bx,ValRegCx
                    mov cx,Op2Val
                    mov ax,bx
                    call LineStuckPwrUp
                    mov bx,ax
                    call GetCarryFlag
                    RCL bx,cl
                    call SetCarryFlag
                    mov ValRegCx,bx
                    cmp selectedPUPType,2
                    je RCL_Cx_Val_our
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
                    cmp selectedPUPType,1
                    jne RCL_Cl_Reg_his
                    RCL_Cl_Reg_our:
                    mov ax,ourValRegCX
                    mov cx,ourValRegCX
                    call ourGetCF
                    RCL Al,cl
                    call ourSetCF
                    mov ourValRegCX,ax
                    jmp Exit
                    RCL_Cl_Reg_his:
                    mov ax,ValRegCX
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL Al,cl
                    call SetCarryFlag
                    mov ValRegCX,ax
                    cmp selectedPUPType,2
                    je RCL_Cl_Reg_our
                    jmp Exit
                RCL_Cl_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    cmp selectedPUPType,1
                    jne RCL_Cl_Val_his
                    RCL_Cl_Val_our:
                    mov ax,ourValRegCX
                    mov cx,Op2Val
                    call ourGetCF
                    RCL al,cl
                    call ourSetCF
                    mov ourValRegCX,ax
                    jmp Exit
                    RCL_Cl_Val_his:
                    mov ax,ValRegCX
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    call GetCarryFlag
                    RCL al,cl
                    call SetCarryFlag
                    mov ValRegCX,ax
                    cmp selectedPUPType,2
                    je RCL_Cl_Val_our
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
                    cmp selectedPUPType,1
                    jne RCL_Ch_Reg_his
                    RCL_Ch_Reg_our:
                    mov cx,ourValRegCX
                    call ourGetCF
                    RCL Ch,cl
                    call ourSetCF
                    mov ourValRegCX,Cx
                    jmp Exit
                    RCL_Ch_Reg_his:
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL Ch,cl
                    call SetCarryFlag
                    mov ValRegCX,Cx
                    cmp selectedPUPType,2
                    je RCL_Ch_Reg_our
                    jmp Exit
                RCL_Ch_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    cmp selectedPUPType,1
                    jne RCL_Ch_Val_his
                    RCL_Ch_Val_our:
                    mov ax,ourValRegCX
                    mov cx,Op2Val
                    call ourGetCF
                    RCL ah,cl
                    call ourSetCF
                    mov ourValRegCX,ax
                    jmp Exit
                    RCL_Ch_Val_his:
                    mov ax,ValRegCX
                    mov cx,Op2Val
                    ;;;;;;;;;;
                        mov bx,ax
                        mov al,ah
                        call LineStuckPwrUp
                        mov ah,al
                        mov al,bl
                    call GetCarryFlag
                    RCL ah,cl
                    call SetCarryFlag
                    mov ValRegCX,ax
                    cmp selectedPUPType,2
                    je RCL_Ch_Val_our
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
                    cmp selectedPUPType,1
                    jne RCL_Dx_Reg_his
                    RCL_Dx_Reg_our:
                    mov Dx,ourValRegDx
                    mov cx,ourValRegCX
                    call ourGetCF
                    RCL Dx,cl
                    call ourSetCF
                    mov ourValRegDx,Dx
                    jmp Exit
                    RCL_Dx_Reg_his:
                    mov Dx,ValRegDx
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL Dx,cl
                    call SetCarryFlag
                    mov ValRegDx,Dx
                    cmp selectedPUPType,2
                    je RCL_Dx_Reg_our
                    jmp Exit
                RCL_Dx_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    cmp selectedPUPType,1
                    jne RCL_Dx_Val_his
                    RCL_Dx_Val_our:
                    mov ax,ourValRegDx
                    mov cx,Op2Val
                    call ourGetCF
                    RCL ax,cl
                    call ourSetCF
                    mov ourValRegDx,ax
                    jmp Exit
                    RCL_Dx_Val_his:
                    mov ax,ValRegDx
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    call GetCarryFlag
                    RCL ax,cl
                    call SetCarryFlag
                    mov ValRegDx,ax
                    cmp selectedPUPType,2
                    je RCL_Dx_Val_our
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
                    cmp selectedPUPType,1
                    jne RCL_Dl_Reg_his
                    RCL_Dl_Reg_our:
                    mov Dx,ourValRegDX
                    mov cx,ourValRegCX
                    call ourGetCF
                    RCL Dl,cl
                    call ourSetCF
                    mov ourValRegDX,Dx
                    jmp Exit
                    RCL_Dl_Reg_his:
                    mov Dx,ValRegDX
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL Dl,cl
                    call SetCarryFlag
                    mov ValRegDX,Dx
                    cmp selectedPUPType,2
                    je RCL_Dl_Reg_our
                    jmp Exit
                RCL_Dl_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    cmp selectedPUPType,1
                    jne RCL_Dl_Val_his
                    RCL_Dl_Val_our:
                    mov Dx,ourValRegDX
                    mov cx,Op2Val
                    call ourGetCF
                    RCL Dl,cl
                    call ourSetCF
                    mov ourValRegDX,Dx
                    jmp Exit
                    RCL_Dl_Val_his:
                    mov ax,ValRegDX
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    call GetCarryFlag
                    RCL al,cl
                    call SetCarryFlag
                    mov ValRegDX,ax
                    cmp selectedPUPType,2
                    je RCL_Dl_Val_our
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
                    cmp selectedPUPType,1
                    jne RCL_Dh_Reg_his
                    RCL_Dh_Reg_our:
                    mov Dx,ourValRegDX
                    mov cx,ourValRegCX
                    call ourGetCF
                    RCL dh,cl
                    call ourSetCF
                    mov ourValRegDX,Dx
                    jmp Exit
                    RCL_Dh_Reg_his:
                    mov Dx,ValRegDX
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL dh,cl
                    call SetCarryFlag
                    mov ValRegDX,Dx
                    cmp selectedPUPType,2
                    je RCL_Dh_Reg_our
                    jmp Exit
                RCL_Dh_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    cmp selectedPUPType,1
                    jne RCL_Dh_Val_his
                    RCL_Dh_Val_our:
                    mov Dx,ourValRegDX
                    mov cx,Op2Val
                    call ourGetCF
                    RCL dh,cl
                    call ourSetCF
                    mov ourValRegDX,Dx
                    jmp Exit
                    RCL_Dh_Val_his:
                    mov ax,ValRegDX
                    mov cx,Op2Val
                    ;;;;;;;;;;
                        mov bx,ax
                        mov al,ah
                        call LineStuckPwrUp
                        mov ah,al
                        mov al,bl
                    call GetCarryFlag
                    RCL ah,cl
                    call SetCarryFlag
                    mov ValRegDX,ax
                    cmp selectedPUPType,2
                    je RCL_Dh_Val_our
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
                    cmp selectedPUPType,1
                    jne RCL_Bp_Reg_his
                    RCL_Bp_Reg_our:
                    mov Bp,ourValRegBp
                    mov cx,ourValRegCX
                    call ourGetCF
                    RCL Bp,cl
                    call ourSetCF
                    mov ourValRegBp,Bp
                    jmp Exit
                    RCL_Bp_Reg_his:
                    mov Bp,ValRegBp
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL Bp,cl
                    call SetCarryFlag
                    mov ValRegBp,Bp
                    cmp selectedPUPType,2
                    je RCL_Bp_Reg_our
                    jmp Exit
                RCL_Bp_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    cmp selectedPUPType,1
                    jne RCL_Bp_Val_his
                    RCL_Bp_Val_our:
                    mov Bp,ourValRegBp
                    mov cx,Op2Val
                    call ourGetCF
                    RCL Bp,cl
                    call ourSetCF
                    mov ourValRegBp,Bp
                    jmp Exit
                    RCL_Bp_Val_his:
                    mov ax,ValRegBp
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    call GetCarryFlag
                    RCL ax,cl
                    call SetCarryFlag
                    mov ValRegBp,ax
                    cmp selectedPUPType,2
                    je RCL_Bp_Val_our
                    jmp Exit
            RCL_Sp:
                cmp selectedOp2Type,0
                je RCL_Sp_Reg
                cmp selectedOp2Type,3
                je RCL_Sp_Val
                jmp RCL_invalid
                RCL_Sp_Reg:
                    cmp selectedOp2Reg,7
                    jne RCL_invalid
                    cmp selectedPUPType,1
                    jne RCL_Sp_Reg_his
                    RCL_Sp_Reg_our:
                    mov Sp,ourValRegSp
                    mov cx,ourValRegCX
                    call ourGetCF
                    RCL Sp,cl
                    call ourSetCF
                    mov ourValRegSp,Sp
                    jmp Exit
                    RCL_Sp_Reg_his:
                    mov Sp,ValRegSp
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL Sp,cl
                    call SetCarryFlag
                    mov ValRegSp,Sp
                    cmp selectedPUPType,2
                    je RCL_Sp_Reg_our
                    jmp Exit
                RCL_Sp_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    cmp selectedPUPType,1
                    jne RCL_Sp_Val_his
                    RCL_Sp_Val_our:
                    mov Sp,ourValRegSp
                    mov cx,Op2Val
                    call ourGetCF
                    RCL Sp,cl
                    call ourSetCF
                    mov ourValRegSp,Sp
                    jmp Exit
                    RCL_Sp_Val_his:
                    mov ax,ValRegSp
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    call GetCarryFlag
                    RCL ax,cl
                    call SetCarryFlag
                    mov ValRegSp,ax
                    cmp selectedPUPType,2
                    je RCL_Sp_Val_our
                    jmp Exit
            RCL_Si:
                cmp selectedOp2Type,0
                je RCL_Si_Reg
                cmp selectedOp2Type,3
                je RCL_Si_Val
                jmp RCL_invalid
                RCL_Si_Reg:
                    cmp selectedOp2Reg,7
                    jne RCL_invalid
                    cmp selectedPUPType,1
                    jne RCL_Si_Reg_his
                    RCL_Si_Reg_our:
                    mov Si,ourValRegSi
                    mov cx,ourValRegCX
                    call ourGetCF
                    RCL Si,cl
                    call ourSetCF
                    mov ourValRegSi,Si
                    jmp Exit
                    RCL_Si_Reg_his:
                    mov Si,ValRegSi
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL Si,cl
                    call SetCarryFlag
                    mov ValRegSi,Si
                    cmp selectedPUPType,2
                    je RCL_Si_Reg_our
                    jmp Exit
                RCL_Si_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    cmp selectedPUPType,1
                    jne RCL_Si_Val_his
                    RCL_Si_Val_our:
                    mov Si,ourValRegSi
                    mov cx,Op2Val
                    call ourGetCF
                    RCL Si,cl
                    call ourSetCF
                    mov ourValRegSi,Si
                    jmp Exit
                    RCL_Si_Val_his:
                    mov ax,ValRegSi
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    call GetCarryFlag
                    RCL ax,cl
                    call SetCarryFlag
                    mov ValRegSi,ax
                    cmp selectedPUPType,2
                    je RCL_Si_Val_our
                    jmp Exit
            RCL_Di:
                cmp selectedOp2Type,0
                je RCL_Di_Reg
                cmp selectedOp2Type,3
                je RCL_Di_Val
                jmp RCL_invalid
                RCL_Di_Reg:
                    cmp selectedOp2Reg,7
                    jne RCL_invalid
                    cmp selectedPUPType,1
                    jne RCL_Di_Reg_his
                    RCL_Di_Reg_our:
                    mov Di,ourValRegDi
                    mov cx,ourValRegCX
                    call ourGetCF
                    RCL Di,cl
                    call ourSetCF
                    mov ourValRegDi,Di
                    jmp Exit
                    RCL_Di_Reg_his:
                    mov Di,ValRegDi
                    mov cx,ValRegCX
                    call GetCarryFlag
                    RCL Di,cl
                    call SetCarryFlag
                    mov ValRegDi,Di
                    cmp selectedPUPType,2
                    je RCL_Di_Reg_our
                    jmp Exit
                RCL_Di_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    cmp selectedPUPType,1
                    jne RCL_Di_Val_his
                    RCL_Di_Val_our:
                    mov Di,ourValRegDi
                    mov cx,Op2Val
                    call ourGetCF
                    RCL Di,cl
                    call ourSetCF
                    mov ourValRegDi,Di
                    jmp Exit
                    RCL_Di_Val_his:
                    mov ax,ValRegDi
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    call GetCarryFlag
                    RCL ax,cl
                    call SetCarryFlag
                    mov ValRegDi,ax
                    cmp selectedPUPType,2
                    je RCL_Di_Val_our
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
                    cmp selectedPUPType,1
                    jne RCL_AddBx_Reg_his
                    RCL_AddBx_Reg_our:
                    mov Bx,ourValRegBX
                    cmp Bx,15d
                    ja RCL_invalid
                    mov cx,ourValRegCX
                    call ourGetCF
                    RCL ourValMem[Bx],cl
                    call ourSetCF
                    mov ourValRegBX,Bx
                    jmp Exit
                    RCL_AddBx_Reg_his:
                    mov Bx,ValRegBX
                    cmp Bx,15d
                    ja RCL_invalid
                    mov cx,ValRegCX
                    ;;;;;;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[Bx]
                        call LineStuckPwrUp
                        mov ValMem[Bx],al
                    call GetCarryFlag
                    RCL ValMem[Bx],cl
                    call SetCarryFlag
                    mov ValRegBX,Bx
                    cmp selectedPUPType,2
                    je RCL_AddBx_Reg_our
                    jmp Exit
                RCL_AddBx_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    cmp selectedPUPType,1
                    jne RCL_AddBx_Val_his
                    RCL_AddBx_Val_our:
                    mov Bx,ourValRegBX
                    cmp Bx,15d
                    ja RCL_invalid
                    mov cx,Op2Val
                    call ourGetCF
                    RCL ourValMem[Bx],cl
                    call ourSetCF
                    mov ourValRegBX,Bx
                    jmp Exit
                    RCL_AddBx_Val_his:
                    mov Bx,ValRegBX
                    cmp Bx,15d
                    ja RCL_invalid
                    mov cx,Op2Val
                    ;;;;;;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[Bx]
                        call LineStuckPwrUp
                        mov ValMem[Bx],al
                    call GetCarryFlag
                    RCL ValMem[Bx],cl
                    call SetCarryFlag
                    mov ValRegBX,Bx
                    cmp selectedPUPType,2
                    je RCL_AddBx_Val_our
                    jmp Exit
            RCL_AddBp:
                cmp selectedOp2Type,0
                je RCL_AddBp_Reg
                cmp selectedOp2Type,3
                je RCL_AddBp_Val
                jmp RCL_invalid
                RCL_AddBp_Reg:
                    cmp selectedOp2Reg,7
                    jne RCL_invalid
                    cmp selectedPUPType,1
                    jne RCL_AddBp_Reg_his
                    RCL_AddBp_Reg_our:
                    mov Bp,ourValRegBp
                    cmp Bp,15d
                    ja RCL_invalid
                    mov cx,ourValRegCX
                    call ourGetCF
                    RCL ourValMem[Bp],cl
                    call ourSetCF
                    mov ourValRegBp,Bp
                    jmp Exit
                    RCL_AddBp_Reg_his:
                    mov Bp,ValRegBp
                    cmp Bp,15d
                    ja RCL_invalid
                    mov cx,ValRegCX
                    ;;;;;;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[Bp]
                        call LineStuckPwrUp
                        mov ValMem[Bp],al
                    call GetCarryFlag
                    RCL ValMem[Bp],cl
                    call SetCarryFlag
                    mov ValRegBp,Bp
                    cmp selectedPUPType,2
                    je RCL_AddBp_Reg_our
                    jmp Exit
                RCL_AddBp_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    cmp selectedPUPType,1
                    jne RCL_AddBp_Val_his
                    RCL_AddBp_Val_our:
                    mov Bp,ourValRegBp
                    cmp Bp,15d
                    ja RCL_invalid
                    mov cx,Op2Val
                    call ourGetCF
                    RCL ourValMem[Bp],cl
                    call ourSetCF
                    mov ourValRegBp,Bp
                    jmp Exit
                    RCL_AddBp_Val_his:
                    mov Bp,ValRegBp
                    cmp Bp,15d
                    ja RCL_invalid
                    mov cx,Op2Val
                    ;;;;;;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[Bp]
                        call LineStuckPwrUp
                        mov ValMem[Bp],al
                    call GetCarryFlag
                    RCL ValMem[Bp],cl
                    call SetCarryFlag
                    mov ValRegBp,Bp
                    cmp selectedPUPType,2
                    je RCL_AddBp_Val_our
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
                    cmp selectedPUPType,1
                    jne RCL_AddSi_Reg_his
                    RCL_AddSi_Reg_our:
                    mov Si,ourValRegSi
                    cmp Si,15d
                    ja RCL_invalid
                    mov cx,ourValRegCX
                    call ourGetCF
                    RCL ourValMem[Si],cl
                    call ourSetCF
                    mov ourValRegSi,Si
                    jmp Exit
                    RCL_AddSi_Reg_his:
                    mov Si,ValRegSi
                    cmp Si,15d
                    ja RCL_invalid
                    mov cx,ValRegCX
                    ;;;;;;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[Si]
                        call LineStuckPwrUp
                        mov ValMem[Si],al
                    call GetCarryFlag
                    RCL ValMem[Si],cl
                    call SetCarryFlag
                    mov ValRegSi,Si
                    cmp selectedPUPType,2
                    je RCL_AddSi_Reg_our
                    jmp Exit
                RCL_AddSi_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    cmp selectedPUPType,1
                    jne RCL_AddSi_Val_his
                    RCL_AddSi_Val_our:
                    mov Si,ourValRegSi
                    cmp Si,15d
                    ja RCL_invalid
                    mov cx,Op2Val
                    call ourGetCF
                    RCL ourValMem[Si],cl
                    call ourSetCF
                    mov ourValRegSi,Si
                    jmp Exit
                    RCL_AddSi_Val_his:
                    mov Si,ValRegSi
                    cmp Si,15d
                    ja RCL_invalid
                    mov cx,Op2Val
                    ;;;;;;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[Si]
                        call LineStuckPwrUp
                        mov ValMem[Si],al
                    call GetCarryFlag
                    RCL ValMem[Si],cl
                    call SetCarryFlag
                    mov ValRegSi,Si
                    cmp selectedPUPType,2
                    je RCL_AddSi_Val_our
                    jmp Exit
            RCL_AddDi:
                cmp selectedOp2Type,0
                je RCL_AddDi_Reg
                cmp selectedOp2Type,3
                je RCL_AddDi_Val
                jmp RCL_invalid
                RCL_AddDi_Reg:
                    cmp selectedOp2Reg,7
                    jne RCL_invalid
                    cmp selectedPUPType,1
                    jne RCL_AddDi_Reg_his
                    RCL_AddDi_Reg_our:
                    mov Di,ourValRegDi
                    cmp Di,15d
                    ja RCL_invalid
                    mov cx,ourValRegCX
                    call ourGetCF
                    RCL ourValMem[Di],cl
                    call ourSetCF
                    mov ourValRegDi,Di
                    jmp Exit
                    RCL_AddDi_Reg_his:
                    mov Di,ValRegDi
                    cmp Di,15d
                    ja RCL_invalid
                    mov cx,ValRegCX
                    ;;;;;;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[Di]
                        call LineStuckPwrUp
                        mov ValMem[Di],al
                    call GetCarryFlag
                    RCL ValMem[Di],cl
                    call SetCarryFlag
                    mov ValRegDi,Di
                    cmp selectedPUPType,2
                    je RCL_AddDi_Reg_our
                    jmp Exit
                RCL_AddDi_Val:
                    cmp Op2Val,255d
                    ja RCL_invalid
                    cmp selectedPUPType,1
                    jne RCL_AddDi_Val_his
                    RCL_AddDi_Val_our:
                    mov Di,ourValRegDi
                    cmp Di,15d
                    ja RCL_invalid
                    mov cx,Op2Val
                    call ourGetCF
                    RCL ourValMem[Di],cl
                    call ourSetCF
                    mov ourValRegDi,Di
                    jmp Exit
                    RCL_AddDi_Val_his:
                    mov Di,ValRegDi
                    cmp Di,15d
                    ja RCL_invalid
                    mov cx,Op2Val
                    ;;;;;;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[Di]
                        call LineStuckPwrUp
                        mov ValMem[Di],al
                    call GetCarryFlag
                    RCL ValMem[Di],cl
                    call SetCarryFlag
                    mov ValRegDi,Di
                    cmp selectedPUPType,2
                    je RCL_AddDi_Val_our
                    jmp Exit
        mov si,0
        RCL_Mem:
            mov bx,si
            cmp selectedOp2Mem,bl
            jne RCL_NotIt
            cmp selectedOp2Type,0
            je RCL_Mem_Reg
            cmp selectedOp2Type,3
            je RCL_Mem_Val
            jmp RCL_invalid
            RCL_Mem_Reg:
                cmp selectedOp2Reg,7
                jne RCL_invalid
                cmp selectedPUPType,1
                jne RCL_Mem_Reg_his
                RCL_Mem_Reg_our:
                mov cx,ourValRegCX
                call ourGetCF
                RCL ourValMem[si],cl
                call ourSetCF
                jmp Exit
                RCL_Mem_Reg_his:
                mov cx,ValRegCX
                ;;;;;;;;;;;;;;;;;;
                    mov al,ValMem[si]
                    call LineStuckPwrUp
                    mov ValMem[si],al
                call GetCarryFlag
                RCL ValMem[si],cl
                call SetCarryFlag
                cmp selectedPUPType,2
                je RCL_Mem_Reg_our
                jmp Exit
            RCL_Mem_Val:
                cmp Op2Val,255d
                ja RCL_invalid
                cmp selectedPUPType,1
                jne RCL_Mem_Val_his
                RCL_Mem_Val_our:
                mov cx,Op2Val
                call ourGetCF
                RCL ourValMem[si],cl
                call ourSetCF
                jmp Exit
                RCL_Mem_Val_his:
                mov cx,Op2Val
                ;;;;;;;;;;;;;;;;;;
                    mov al,ValMem[si]
                    call LineStuckPwrUp
                    mov ValMem[si],al
                call GetCarryFlag
                RCL ValMem[si],cl
                call SetCarryFlag
                cmp selectedPUPType,2
                je RCL_Mem_Val_our
                jmp Exit
            RCL_NotIt:
            inc si
            jmp RCL_Mem
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
                    cmp selectedPUPType,1
                    jne SHL_Ax_Reg_his
                    SHL_Ax_Reg_our:
                    mov ax,ourValRegAX
                    mov cx,ourValRegCX
                    SHL Ax,cl
                    call ourSetCF
                    mov ourValRegAX,ax
                    jmp Exit
                    SHL_Ax_Reg_his:
                    mov ax,ValRegAX
                    mov cx,ValRegCX
                    SHL Ax,cl
                    call SetCarryFlag
                    mov ValRegAX,ax
                    cmp selectedPUPType,2
                    je SHL_Ax_Reg_our
                    jmp Exit
                SHL_Ax_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    cmp selectedPUPType,1
                    jne SHL_Ax_Val_his
                    SHL_Ax_Val_our:
                    mov ax,ourValRegAX
                    mov cx,Op2Val
                    SHL ax,cl
                    call ourSetCF
                    mov ourValRegAX,ax
                    jmp Exit
                    SHL_Ax_Val_his:
                    mov ax,ValRegAX
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    SHL ax,cl
                    call SetCarryFlag
                    mov ValRegAX,ax
                    cmp selectedPUPType,2
                    je SHL_Ax_Val_our
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
                    cmp selectedPUPType,1
                    jne SHL_Al_Reg_his
                    SHL_Al_Reg_our:
                    mov ax,ourValRegAX
                    mov cx,ourValRegCX
                    SHL Al,cl
                    call ourSetCF
                    mov ourValRegAX,ax
                    jmp Exit
                    SHL_Al_Reg_his:
                    mov ax,ValRegAX
                    mov cx,ValRegCX
                    SHL Al,cl
                    call SetCarryFlag
                    mov ValRegAX,ax
                    cmp selectedPUPType,2
                    je SHL_Al_Reg_our
                    jmp Exit
                SHL_Al_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    cmp selectedPUPType,1
                    jne SHL_Al_Val_his
                    SHL_Al_Val_our:
                    mov ax,ourValRegAX
                    mov cx,Op2Val
                    SHL al,cl
                    call ourSetCF
                    mov ourValRegAX,ax
                    jmp Exit
                    SHL_Al_Val_his:
                    mov ax,ValRegAX
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    SHL al,cl
                    call SetCarryFlag
                    mov ValRegAX,ax
                    cmp selectedPUPType,2
                    je SHL_Al_Val_our
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
                    cmp selectedPUPType,1
                    jne SHL_Ah_Reg_his
                    SHL_Ah_Reg_our:
                    mov ax,ourValRegAX
                    mov cx,ourValRegCX
                    SHL Ah,cl
                    call ourSetCF
                    mov ourValRegAX,ax
                    jmp Exit
                    SHL_Ah_Reg_his:
                    mov ax,ValRegAX
                    mov cx,ValRegCX
                    SHL Ah,cl
                    call SetCarryFlag
                    mov ValRegAX,ax
                    cmp selectedPUPType,2
                    je SHL_Ah_Reg_our
                    jmp Exit
                SHL_Ah_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    cmp selectedPUPType,1
                    jne SHL_Ah_Val_his
                    SHL_Ah_Val_our:
                    mov ax,ourValRegAX
                    mov cx,Op2Val
                    SHL ah,cl
                    call ourSetCF
                    mov ourValRegAX,ax
                    jmp Exit
                    SHL_Ah_Val_his:
                    mov ax,ValRegAX
                    mov cx,Op2Val
                    ;;;;;;;;;;
                        mov bx,ax
                        mov al,ah
                        call LineStuckPwrUp
                        mov ah,al
                        mov al,bl
                    SHL ah,cl
                    call SetCarryFlag
                    mov ValRegAX,ax
                    cmp selectedPUPType,2
                    je SHL_Ah_Val_our
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
                    cmp selectedPUPType,1
                    jne SHL_Bx_Reg_his
                    SHL_Bx_Reg_our:
                    mov Bx,ourValRegBx
                    mov cx,ourValRegCX
                    SHL Bx,cl
                    call ourSetCF
                    mov ourValRegBx,Bx
                    jmp Exit
                    SHL_Bx_Reg_his:
                    mov Bx,ValRegBx
                    mov cx,ValRegCX
                    SHL Bx,cl
                    call SetCarryFlag
                    mov ValRegBx,Bx
                    cmp selectedPUPType,2
                    je SHL_Bx_Reg_our
                    jmp Exit
                SHL_Bx_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    cmp selectedPUPType,1
                    jne SHL_Bx_Val_his
                    SHL_Bx_Val_our:
                    mov Bx,ourValRegBx
                    mov cx,Op2Val
                    SHL Bx,cl
                    call ourSetCF
                    mov ourValRegBx,Bx
                    jmp Exit
                    SHL_Bx_Val_his:
                    mov Bx,ValRegBx
                    mov cx,Op2Val
                    mov ax,bx
                    call LineStuckPwrUp
                    mov bx,ax
                    SHL Bx,cl
                    call SetCarryFlag
                    mov ValRegBx,Bx
                    cmp selectedPUPType,2
                    je SHL_Bx_Val_our
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
                    cmp selectedPUPType,1
                    jne SHL_Bl_Reg_his
                    SHL_Bl_Reg_our:
                    mov Bx,ourValRegBX
                    mov cx,ourValRegCX
                    SHL Bl,cl
                    call ourSetCF
                    mov ourValRegBX,Bx
                    jmp Exit
                    SHL_Bl_Reg_his:
                    mov Bx,ValRegBX
                    mov cx,ValRegCX
                    SHL Bl,cl
                    call SetCarryFlag
                    mov ValRegBX,Bx
                    cmp selectedPUPType,2
                    je SHL_Bl_Reg_our
                    jmp Exit
                SHL_Bl_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    cmp selectedPUPType,1
                    SHL_Bl_Val_our:
                    mov Bx,ourValRegBX
                    mov cx,Op2Val
                    SHL Bl,cl
                    call ourSetCF
                    mov ourValRegBX,Bx
                    jmp Exit
                    SHL_Bl_Val_his:
                    mov Bx,ValRegBX
                    mov cx,Op2Val
                    mov al,Bl
                    call LineStuckPwrUp
                    mov Bl,al
                    SHL Bl,cl
                    call SetCarryFlag
                    mov ValRegBX,Bx
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
                    cmp selectedPUPType,1
                    jne SHL_Bh_Reg_his
                    SHL_Bh_Reg_our:
                    mov Bx,ourValRegBX
                    mov cx,ourValRegCX
                    SHL Bh,cl
                    call ourSetCF
                    mov ourValRegBX,Bx
                    jmp Exit
                    SHL_Bh_Reg_his:
                    mov Bx,ValRegBX
                    mov cx,ValRegCX
                    SHL Bh,cl
                    call SetCarryFlag
                    mov ValRegBX,Bx
                    cmp selectedPUPType,2
                    je SHL_Bh_Reg_our
                    jmp Exit
                SHL_Bh_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    cmp selectedPUPType,1
                    SHL_Bh_Val_our:
                    mov Bx,ourValRegBX
                    mov cx,Op2Val
                    SHL Bh,cl
                    call ourSetCF
                    mov ourValRegBX,Bx
                    jmp Exit
                    SHL_Bh_Val_his:
                    mov Bx,ValRegBX
                    mov cx,Op2Val
                    mov al,Bh
                    call LineStuckPwrUp
                    mov Bh,al
                    SHL Bh,cl
                    call SetCarryFlag
                    mov ValRegBX,Bx
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
                    cmp selectedPUPType,1
                    jne SHL_Cx_Reg_his
                    SHL_Cx_Reg_our:
                    mov Cx,ourValRegCx
                    mov ax,cx
                    mov cx,ax
                    SHL Cx,cl
                    call ourSetCF
                    mov ourValRegCx,Cx
                    jmp Exit
                    SHL_Cx_Reg_his:
                    cmp selectedOp2Reg,7
                    jne SHL_invalid
                    mov Cx,ValRegCx
                    mov ax,cx
                    mov cx,ax
                    SHL Cx,cl
                    call SetCarryFlag
                    mov ValRegCx,Cx
                    cmp selectedPUPType,2
                    je SHL_Cx_Reg_our
                    jmp Exit
                SHL_Cx_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    cmp selectedPUPType,1
                    jne SHL_Cx_Val_his
                    SHL_Cx_Val_our:
                    mov bx,ourValRegCx
                    mov cx,Op2Val
                    SHL bx,cl
                    call ourSetCF
                    mov ourValRegCx,bx
                    jmp Exit
                    SHL_Cx_Val_his:
                    mov bx,ValRegCx
                    mov cx,Op2Val
                    mov ax,bx
                    call LineStuckPwrUp
                    mov bx,ax
                    SHL bx,cl
                    call SetCarryFlag
                    mov ValRegCx,bx
                    cmp selectedPUPType,2
                    je SHL_Cx_Val_our
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
                    cmp selectedPUPType,1
                    jne SHL_Cl_Reg_his
                    SHL_Cl_Reg_our:
                    mov ax,ourValRegCX
                    mov cx,ourValRegCX
                    SHL Al,cl
                    call ourSetCF
                    mov ourValRegCX,ax
                    jmp Exit
                    SHL_Cl_Reg_his:
                    mov ax,ValRegCX
                    mov cx,ValRegCX
                    SHL Al,cl
                    call SetCarryFlag
                    mov ValRegCX,ax
                    cmp selectedPUPType,2
                    je SHL_Cl_Reg_our
                    jmp Exit
                SHL_Cl_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    cmp selectedPUPType,1
                    jne SHL_Cl_Val_his
                    SHL_Cl_Val_our:
                    mov ax,ourValRegCX
                    mov cx,Op2Val
                    SHL al,cl
                    call ourSetCF
                    mov ourValRegCX,ax
                    jmp Exit
                    SHL_Cl_Val_his:
                    mov ax,ValRegCX
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    SHL al,cl
                    call SetCarryFlag
                    mov ValRegCX,ax
                    cmp selectedPUPType,2
                    je SHL_Cl_Val_our
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
                    cmp selectedPUPType,1
                    jne SHL_Ch_Reg_his
                    SHL_Ch_Reg_our:
                    mov cx,ourValRegCX
                    SHL Ch,cl
                    call ourSetCF
                    mov ourValRegCX,Cx
                    jmp Exit
                    SHL_Ch_Reg_his:
                    mov cx,ValRegCX
                    SHL Ch,cl
                    call SetCarryFlag
                    mov ValRegCX,Cx
                    cmp selectedPUPType,2
                    je SHL_Ch_Reg_our
                    jmp Exit
                SHL_Ch_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    cmp selectedPUPType,1
                    jne SHL_Ch_Val_his
                    SHL_Ch_Val_our:
                    mov ax,ourValRegCX
                    mov cx,Op2Val
                    SHL ah,cl
                    call ourSetCF
                    mov ourValRegCX,ax
                    jmp Exit
                    SHL_Ch_Val_his:
                    mov ax,ValRegCX
                    mov cx,Op2Val
                    ;;;;;;;;;;
                        mov bx,ax
                        mov al,ah
                        call LineStuckPwrUp
                        mov ah,al
                        mov al,bl
                    SHL ah,cl
                    call SetCarryFlag
                    mov ValRegCX,ax
                    cmp selectedPUPType,2
                    je SHL_Ch_Val_our
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
                    cmp selectedPUPType,1
                    jne SHL_Dx_Reg_his
                    SHL_Dx_Reg_our:
                    mov Dx,ourValRegDx
                    mov cx,ourValRegCX
                    SHL Dx,cl
                    call ourSetCF
                    mov ourValRegDx,Dx
                    jmp Exit
                    SHL_Dx_Reg_his:
                    mov Dx,ValRegDx
                    mov cx,ValRegCX
                    SHL Dx,cl
                    call SetCarryFlag
                    mov ValRegDx,Dx
                    cmp selectedPUPType,2
                    je SHL_Dx_Reg_our
                    jmp Exit
                SHL_Dx_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    cmp selectedPUPType,1
                    jne SHL_Dx_Val_his
                    SHL_Dx_Val_our:
                    mov ax,ourValRegDx
                    mov cx,Op2Val
                    SHL ax,cl
                    call ourSetCF
                    mov ourValRegDx,ax
                    jmp Exit
                    SHL_Dx_Val_his:
                    mov ax,ValRegDx
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    SHL ax,cl
                    call SetCarryFlag
                    mov ValRegDx,ax
                    cmp selectedPUPType,2
                    je SHL_Dx_Val_our
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
                    cmp selectedPUPType,1
                    jne SHL_Dl_Reg_his
                    SHL_Dl_Reg_our:
                    mov Dx,ourValRegDX
                    mov cx,ourValRegCX
                    SHL Dl,cl
                    call ourSetCF
                    mov ourValRegDX,Dx
                    jmp Exit
                    SHL_Dl_Reg_his:
                    mov Dx,ValRegDX
                    mov cx,ValRegCX
                    SHL Dl,cl
                    call SetCarryFlag
                    mov ValRegDX,Dx
                    cmp selectedPUPType,2
                    je SHL_Dl_Reg_our
                    jmp Exit
                SHL_Dl_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    cmp selectedPUPType,1
                    jne SHL_Dl_Val_his
                    SHL_Dl_Val_our:
                    mov Dx,ourValRegDX
                    mov cx,Op2Val
                    SHL Dl,cl
                    call ourSetCF
                    mov ourValRegDX,Dx
                    jmp Exit
                    SHL_Dl_Val_his:
                    mov ax,ValRegDX
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    SHL al,cl
                    call SetCarryFlag
                    mov ValRegDX,ax
                    cmp selectedPUPType,2
                    je SHL_Dl_Val_our
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
                    cmp selectedPUPType,1
                    jne SHL_Dh_Reg_his
                    SHL_Dh_Reg_our:
                    mov Dx,ourValRegDX
                    mov cx,ourValRegCX
                    SHL dh,cl
                    call ourSetCF
                    mov ourValRegDX,Dx
                    jmp Exit
                    SHL_Dh_Reg_his:
                    mov Dx,ValRegDX
                    mov cx,ValRegCX
                    SHL dh,cl
                    call SetCarryFlag
                    mov ValRegDX,Dx
                    cmp selectedPUPType,2
                    je SHL_Dh_Reg_our
                    jmp Exit
                SHL_Dh_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    cmp selectedPUPType,1
                    jne SHL_Dh_Val_his
                    SHL_Dh_Val_our:
                    mov Dx,ourValRegDX
                    mov cx,Op2Val
                    SHL dh,cl
                    call ourSetCF
                    mov ourValRegDX,Dx
                    jmp Exit
                    SHL_Dh_Val_his:
                    mov ax,ValRegDX
                    mov cx,Op2Val
                    ;;;;;;;;;;
                        mov bx,ax
                        mov al,ah
                        call LineStuckPwrUp
                        mov ah,al
                        mov al,bl
                    SHL ah,cl
                    call SetCarryFlag
                    mov ValRegDX,ax
                    cmp selectedPUPType,2
                    je SHL_Dh_Val_our
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
                    cmp selectedPUPType,1
                    jne SHL_Bp_Reg_his
                    SHL_Bp_Reg_our:
                    mov Bp,ourValRegBp
                    mov cx,ourValRegCX
                    SHL Bp,cl
                    call ourSetCF
                    mov ourValRegBp,Bp
                    jmp Exit
                    SHL_Bp_Reg_his:
                    mov Bp,ValRegBp
                    mov cx,ValRegCX
                    SHL Bp,cl
                    call SetCarryFlag
                    mov ValRegBp,Bp
                    cmp selectedPUPType,2
                    je SHL_Bp_Reg_our
                    jmp Exit
                SHL_Bp_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    cmp selectedPUPType,1
                    jne SHL_Bp_Val_his
                    SHL_Bp_Val_our:
                    mov Bp,ourValRegBp
                    mov cx,Op2Val
                    SHL Bp,cl
                    call ourSetCF
                    mov ourValRegBp,Bp
                    jmp Exit
                    SHL_Bp_Val_his:
                    mov ax,ValRegBp
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    SHL ax,cl
                    call SetCarryFlag
                    mov ValRegBp,ax
                    cmp selectedPUPType,2
                    je SHL_Bp_Val_our
                    jmp Exit
            SHL_Sp:
                cmp selectedOp2Type,0
                je SHL_Sp_Reg
                cmp selectedOp2Type,3
                je SHL_Sp_Val
                jmp SHL_invalid
                SHL_Sp_Reg:
                    cmp selectedOp2Reg,7
                    jne SHL_invalid
                    cmp selectedPUPType,1
                    jne SHL_Sp_Reg_his
                    SHL_Sp_Reg_our:
                    mov Sp,ourValRegSp
                    mov cx,ourValRegCX
                    SHL Sp,cl
                    call ourSetCF
                    mov ourValRegSp,Sp
                    jmp Exit
                    SHL_Sp_Reg_his:
                    mov Sp,ValRegSp
                    mov cx,ValRegCX
                    SHL Sp,cl
                    call SetCarryFlag
                    mov ValRegSp,Sp
                    cmp selectedPUPType,2
                    je SHL_Sp_Reg_our
                    jmp Exit
                SHL_Sp_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    cmp selectedPUPType,1
                    jne SHL_Sp_Val_his
                    SHL_Sp_Val_our:
                    mov Sp,ourValRegSp
                    mov cx,Op2Val
                    SHL Sp,cl
                    call ourSetCF
                    mov ourValRegSp,Sp
                    jmp Exit
                    SHL_Sp_Val_his:
                    mov ax,ValRegSp
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    SHL ax,cl
                    call SetCarryFlag
                    mov ValRegSp,ax
                    cmp selectedPUPType,2
                    je SHL_Sp_Val_our
                    jmp Exit
            SHL_Si:
                cmp selectedOp2Type,0
                je SHL_Si_Reg
                cmp selectedOp2Type,3
                je SHL_Si_Val
                jmp SHL_invalid
                SHL_Si_Reg:
                    cmp selectedOp2Reg,7
                    jne SHL_invalid
                    cmp selectedPUPType,1
                    jne SHL_Si_Reg_his
                    SHL_Si_Reg_our:
                    mov Si,ourValRegSi
                    mov cx,ourValRegCX
                    SHL Si,cl
                    call ourSetCF
                    mov ourValRegSi,Si
                    jmp Exit
                    SHL_Si_Reg_his:
                    mov Si,ValRegSi
                    mov cx,ValRegCX
                    SHL Si,cl
                    call SetCarryFlag
                    mov ValRegSi,Si
                    cmp selectedPUPType,2
                    je SHL_Si_Reg_our
                    jmp Exit
                SHL_Si_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    cmp selectedPUPType,1
                    jne SHL_Si_Val_his
                    SHL_Si_Val_our:
                    mov Si,ourValRegSi
                    mov cx,Op2Val
                    SHL Si,cl
                    call ourSetCF
                    mov ourValRegSi,Si
                    jmp Exit
                    SHL_Si_Val_his:
                    mov ax,ValRegSi
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    SHL ax,cl
                    call SetCarryFlag
                    mov ValRegSi,ax
                    cmp selectedPUPType,2
                    je SHL_Si_Val_our
                    jmp Exit
            SHL_Di:
                cmp selectedOp2Type,0
                je SHL_Di_Reg
                cmp selectedOp2Type,3
                je SHL_Di_Val
                jmp SHL_invalid
                SHL_Di_Reg:
                    cmp selectedOp2Reg,7
                    jne SHL_invalid
                    cmp selectedPUPType,1
                    jne SHL_Di_Reg_his
                    SHL_Di_Reg_our:
                    mov Di,ourValRegDi
                    mov cx,ourValRegCX
                    SHL Di,cl
                    call ourSetCF
                    mov ourValRegDi,Di
                    jmp Exit
                    SHL_Di_Reg_his:
                    mov Di,ValRegDi
                    mov cx,ValRegCX
                    SHL Di,cl
                    call SetCarryFlag
                    mov ValRegDi,Di
                    cmp selectedPUPType,2
                    je SHL_Di_Reg_our
                    jmp Exit
                SHL_Di_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    cmp selectedPUPType,1
                    jne SHL_Di_Val_his
                    SHL_Di_Val_our:
                    mov Di,ourValRegDi
                    mov cx,Op2Val
                    SHL Di,cl
                    call ourSetCF
                    mov ourValRegDi,Di
                    jmp Exit
                    SHL_Di_Val_his:
                    mov ax,ValRegDi
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    SHL ax,cl
                    call SetCarryFlag
                    mov ValRegDi,ax
                    cmp selectedPUPType,2
                    je SHL_Di_Val_our
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
                    cmp selectedPUPType,1
                    jne SHL_AddBx_Reg_his
                    SHL_AddBx_Reg_our:
                    mov Bx,ourValRegBX
                    cmp Bx,15d
                    ja SHL_invalid
                    mov cx,ourValRegCX
                    SHL ourValMem[Bx],cl
                    call ourSetCF
                    mov ourValRegBX,Bx
                    jmp Exit
                    SHL_AddBx_Reg_his:
                    mov Bx,ValRegBX
                    cmp Bx,15d
                    ja SHL_invalid
                    mov cx,ValRegCX
                    ;;;;;;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[Bx]
                        call LineStuckPwrUp
                        mov ValMem[Bx],al
                    SHL ValMem[Bx],cl
                    call SetCarryFlag
                    mov ValRegBX,Bx
                    cmp selectedPUPType,2
                    je SHL_AddBx_Reg_our
                    jmp Exit
                SHL_AddBx_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    cmp selectedPUPType,1
                    jne SHL_AddBx_Val_his
                    SHL_AddBx_Val_our:
                    mov Bx,ourValRegBX
                    cmp Bx,15d
                    ja SHL_invalid
                    mov cx,Op2Val
                    SHL ourValMem[Bx],cl
                    call ourSetCF
                    mov ourValRegBX,Bx
                    jmp Exit
                    SHL_AddBx_Val_his:
                    mov Bx,ValRegBX
                    cmp Bx,15d
                    ja SHL_invalid
                    mov cx,Op2Val
                    ;;;;;;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[Bx]
                        call LineStuckPwrUp
                        mov ValMem[Bx],al
                    SHL ValMem[Bx],cl
                    call SetCarryFlag
                    mov ValRegBX,Bx
                    cmp selectedPUPType,2
                    je SHL_AddBx_Val_our
                    jmp Exit
            SHL_AddBp:
                cmp selectedOp2Type,0
                je SHL_AddBp_Reg
                cmp selectedOp2Type,3
                je SHL_AddBp_Val
                jmp SHL_invalid
                SHL_AddBp_Reg:
                    cmp selectedOp2Reg,7
                    jne SHL_invalid
                    cmp selectedPUPType,1
                    jne SHL_AddBp_Reg_his
                    SHL_AddBp_Reg_our:
                    mov Bp,ourValRegBp
                    cmp Bp,15d
                    ja SHL_invalid
                    mov cx,ourValRegCX
                    SHL ourValMem[Bp],cl
                    call ourSetCF
                    mov ourValRegBp,Bp
                    jmp Exit
                    SHL_AddBp_Reg_his:
                    mov Bp,ValRegBp
                    cmp Bp,15d
                    ja SHL_invalid
                    mov cx,ValRegCX
                    ;;;;;;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[Bp]
                        call LineStuckPwrUp
                        mov ValMem[Bp],al
                    SHL ValMem[Bp],cl
                    call SetCarryFlag
                    mov ValRegBp,Bp
                    cmp selectedPUPType,2
                    je SHL_AddBp_Reg_our
                    jmp Exit
                SHL_AddBp_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    cmp selectedPUPType,1
                    jne SHL_AddBp_Val_his
                    SHL_AddBp_Val_our:
                    mov Bp,ourValRegBp
                    cmp Bp,15d
                    ja SHL_invalid
                    mov cx,Op2Val
                    SHL ourValMem[Bp],cl
                    call ourSetCF
                    mov ourValRegBp,Bp
                    jmp Exit
                    SHL_AddBp_Val_his:
                    mov Bp,ValRegBp
                    cmp Bp,15d
                    ja SHL_invalid
                    mov cx,Op2Val
                    ;;;;;;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[Bp]
                        call LineStuckPwrUp
                        mov ValMem[Bp],al
                    SHL ValMem[Bp],cl
                    call SetCarryFlag
                    mov ValRegBp,Bp
                    cmp selectedPUPType,2
                    je SHL_AddBp_Val_our
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
                    cmp selectedPUPType,1
                    jne SHL_AddSi_Reg_his
                    SHL_AddSi_Reg_our:
                    mov Si,ourValRegSi
                    cmp Si,15d
                    ja SHL_invalid
                    mov cx,ourValRegCX
                    SHL ourValMem[Si],cl
                    call ourSetCF
                    mov ourValRegSi,Si
                    jmp Exit
                    SHL_AddSi_Reg_his:
                    mov Si,ValRegSi
                    cmp Si,15d
                    ja SHL_invalid
                    mov cx,ValRegCX
                    ;;;;;;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[Si]
                        call LineStuckPwrUp
                        mov ValMem[Si],al
                    SHL ValMem[Si],cl
                    call SetCarryFlag
                    mov ValRegSi,Si
                    cmp selectedPUPType,2
                    je SHL_AddSi_Reg_our
                    jmp Exit
                SHL_AddSi_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    cmp selectedPUPType,1
                    jne SHL_AddSi_Val_his
                    SHL_AddSi_Val_our:
                    mov Si,ourValRegSi
                    cmp Si,15d
                    ja SHL_invalid
                    mov cx,Op2Val
                    SHL ourValMem[Si],cl
                    call ourSetCF
                    mov ourValRegSi,Si
                    jmp Exit
                    SHL_AddSi_Val_his:
                    mov Si,ValRegSi
                    cmp Si,15d
                    ja SHL_invalid
                    mov cx,Op2Val
                    ;;;;;;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[Si]
                        call LineStuckPwrUp
                        mov ValMem[Si],al
                    SHL ValMem[Si],cl
                    call SetCarryFlag
                    mov ValRegSi,Si
                    cmp selectedPUPType,2
                    je SHL_AddSi_Val_our
                    jmp Exit
            SHL_AddDi:
                cmp selectedOp2Type,0
                je SHL_AddDi_Reg
                cmp selectedOp2Type,3
                je SHL_AddDi_Val
                jmp SHL_invalid
                SHL_AddDi_Reg:
                    cmp selectedOp2Reg,7
                    jne SHL_invalid
                    cmp selectedPUPType,1
                    jne SHL_AddDi_Reg_his
                    SHL_AddDi_Reg_our:
                    mov Di,ourValRegDi
                    cmp Di,15d
                    ja SHL_invalid
                    mov cx,ourValRegCX
                    SHL ourValMem[Di],cl
                    call ourSetCF
                    mov ourValRegDi,Di
                    jmp Exit
                    SHL_AddDi_Reg_his:
                    mov Di,ValRegDi
                    cmp Di,15d
                    ja SHL_invalid
                    mov cx,ValRegCX
                    ;;;;;;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[Di]
                        call LineStuckPwrUp
                        mov ValMem[Di],al
                    SHL ValMem[Di],cl
                    call SetCarryFlag
                    mov ValRegDi,Di
                    cmp selectedPUPType,2
                    je SHL_AddDi_Reg_our
                    jmp Exit
                SHL_AddDi_Val:
                    cmp Op2Val,255d
                    ja SHL_invalid
                    cmp selectedPUPType,1
                    jne SHL_AddDi_Val_his
                    SHL_AddDi_Val_our:
                    mov Di,ourValRegDi
                    cmp Di,15d
                    ja SHL_invalid
                    mov cx,Op2Val
                    SHL ourValMem[Di],cl
                    call ourSetCF
                    mov ourValRegDi,Di
                    jmp Exit
                    SHL_AddDi_Val_his:
                    mov Di,ValRegDi
                    cmp Di,15d
                    ja SHL_invalid
                    mov cx,Op2Val
                    ;;;;;;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[Di]
                        call LineStuckPwrUp
                        mov ValMem[Di],al
                    SHL ValMem[Di],cl
                    call SetCarryFlag
                    mov ValRegDi,Di
                    cmp selectedPUPType,2
                    je SHL_AddDi_Val_our
                    jmp Exit
        mov si,0
        SHL_Mem:
            mov bx,si
            cmp selectedOp2Mem,bl
            jne SHL_NotIt
            cmp selectedOp2Type,0
            je SHL_Mem_Reg
            cmp selectedOp2Type,3
            je SHL_Mem_Val
            jmp SHL_invalid
            SHL_Mem_Reg:
                cmp selectedOp2Reg,7
                jne SHL_invalid
                cmp selectedPUPType,1
                jne SHL_Mem_Reg_his
                SHL_Mem_Reg_our:
                mov cx,ourValRegCX
                SHL ourValMem[si],cl
                call ourSetCF
                jmp Exit
                SHL_Mem_Reg_his:
                mov cx,ValRegCX
                ;;;;;;;;;;;;;;;;;;
                    mov al,ValMem[si]
                    call LineStuckPwrUp
                    mov ValMem[si],al
                SHL ValMem[si],cl
                call SetCarryFlag
                cmp selectedPUPType,2
                je SHL_Mem_Reg_our
                jmp Exit
            SHL_Mem_Val:
                cmp Op2Val,255d
                ja SHL_invalid
                cmp selectedPUPType,1
                jne SHL_Mem_Val_his
                SHL_Mem_Val_our:
                mov cx,Op2Val
                SHL ourValMem[si],cl
                call ourSetCF
                jmp Exit
                SHL_Mem_Val_his:
                mov cx,Op2Val
                ;;;;;;;;;;;;;;;;;;
                    mov al,ValMem[si]
                    call LineStuckPwrUp
                    mov ValMem[si],al
                SHL ValMem[si],cl
                call SetCarryFlag
                cmp selectedPUPType,2
                je SHL_Mem_Val_our
                jmp Exit
            SHL_NotIt:
            inc si
            jmp SHL_Mem
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
                    cmp selectedPUPType,1
                    jne SHR_Ax_Reg_his
                    SHR_Ax_Reg_our:
                    mov ax,ourValRegAX
                    mov cx,ourValRegCX
                    SHR Ax,cl
                    call ourSetCF
                    mov ourValRegAX,ax
                    jmp Exit
                    SHR_Ax_Reg_his:
                    mov ax,ValRegAX
                    mov cx,ValRegCX
                    SHR Ax,cl
                    call SetCarryFlag
                    mov ValRegAX,ax
                    cmp selectedPUPType,2
                    je SHR_Ax_Reg_our
                    jmp Exit
                SHR_Ax_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    cmp selectedPUPType,1
                    jne SHR_Ax_Val_his
                    SHR_Ax_Val_our:
                    mov ax,ourValRegAX
                    mov cx,Op2Val
                    SHR ax,cl
                    call ourSetCF
                    mov ourValRegAX,ax
                    jmp Exit
                    SHR_Ax_Val_his:
                    mov ax,ValRegAX
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    SHR ax,cl
                    call SetCarryFlag
                    mov ValRegAX,ax
                    cmp selectedPUPType,2
                    je SHR_Ax_Val_our
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
                    cmp selectedPUPType,1
                    jne SHR_Al_Reg_his
                    SHR_Al_Reg_our:
                    mov ax,ourValRegAX
                    mov cx,ourValRegCX
                    SHR Al,cl
                    call ourSetCF
                    mov ourValRegAX,ax
                    jmp Exit
                    SHR_Al_Reg_his:
                    mov ax,ValRegAX
                    mov cx,ValRegCX
                    SHR Al,cl
                    call SetCarryFlag
                    mov ValRegAX,ax
                    cmp selectedPUPType,2
                    je SHR_Al_Reg_our
                    jmp Exit
                SHR_Al_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    cmp selectedPUPType,1
                    jne SHR_Al_Val_his
                    SHR_Al_Val_our:
                    mov ax,ourValRegAX
                    mov cx,Op2Val
                    SHR al,cl
                    call ourSetCF
                    mov ourValRegAX,ax
                    jmp Exit
                    SHR_Al_Val_his:
                    mov ax,ValRegAX
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    SHR al,cl
                    call SetCarryFlag
                    mov ValRegAX,ax
                    cmp selectedPUPType,2
                    je SHR_Al_Val_our
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
                    cmp selectedPUPType,1
                    jne SHR_Ah_Reg_his
                    SHR_Ah_Reg_our:
                    mov ax,ourValRegAX
                    mov cx,ourValRegCX
                    SHR Ah,cl
                    call ourSetCF
                    mov ourValRegAX,ax
                    jmp Exit
                    SHR_Ah_Reg_his:
                    mov ax,ValRegAX
                    mov cx,ValRegCX
                    SHR Ah,cl
                    call SetCarryFlag
                    mov ValRegAX,ax
                    cmp selectedPUPType,2
                    je SHR_Ah_Reg_our
                    jmp Exit
                SHR_Ah_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    cmp selectedPUPType,1
                    jne SHR_Ah_Val_his
                    SHR_Ah_Val_our:
                    mov ax,ourValRegAX
                    mov cx,Op2Val
                    SHR ah,cl
                    call ourSetCF
                    mov ourValRegAX,ax
                    jmp Exit
                    SHR_Ah_Val_his:
                    mov ax,ValRegAX
                    mov cx,Op2Val
                    ;;;;;;;;;;
                        mov bx,ax
                        mov al,ah
                        call LineStuckPwrUp
                        mov ah,al
                        mov al,bl
                    SHR ah,cl
                    call SetCarryFlag
                    mov ValRegAX,ax
                    cmp selectedPUPType,2
                    je SHR_Ah_Val_our
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
                    cmp selectedPUPType,1
                    jne SHR_Bx_Reg_his
                    SHR_Bx_Reg_our:
                    mov Bx,ourValRegBx
                    mov cx,ourValRegCX
                    SHR Bx,cl
                    call ourSetCF
                    mov ourValRegBx,Bx
                    jmp Exit
                    SHR_Bx_Reg_his:
                    mov Bx,ValRegBx
                    mov cx,ValRegCX
                    SHR Bx,cl
                    call SetCarryFlag
                    mov ValRegBx,Bx
                    cmp selectedPUPType,2
                    je SHR_Bx_Reg_our
                    jmp Exit
                SHR_Bx_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    cmp selectedPUPType,1
                    jne SHR_Bx_Val_his
                    SHR_Bx_Val_our:
                    mov Bx,ourValRegBx
                    mov cx,Op2Val
                    SHR Bx,cl
                    call ourSetCF
                    mov ourValRegBx,Bx
                    jmp Exit
                    SHR_Bx_Val_his:
                    mov Bx,ValRegBx
                    mov cx,Op2Val
                    mov ax,bx
                    call LineStuckPwrUp
                    mov bx,ax
                    SHR Bx,cl
                    call SetCarryFlag
                    mov ValRegBx,Bx
                    cmp selectedPUPType,2
                    je SHR_Bx_Val_our
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
                    cmp selectedPUPType,1
                    jne SHR_Bl_Reg_his
                    SHR_Bl_Reg_our:
                    mov Bx,ourValRegBX
                    mov cx,ourValRegCX
                    SHR Bl,cl
                    call ourSetCF
                    mov ourValRegBX,Bx
                    jmp Exit
                    SHR_Bl_Reg_his:
                    mov Bx,ValRegBX
                    mov cx,ValRegCX
                    SHR Bl,cl
                    call SetCarryFlag
                    mov ValRegBX,Bx
                    cmp selectedPUPType,2
                    je SHR_Bl_Reg_our
                    jmp Exit
                SHR_Bl_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    cmp selectedPUPType,1
                    SHR_Bl_Val_our:
                    mov Bx,ourValRegBX
                    mov cx,Op2Val
                    SHR Bl,cl
                    call ourSetCF
                    mov ourValRegBX,Bx
                    jmp Exit
                    SHR_Bl_Val_his:
                    mov Bx,ValRegBX
                    mov cx,Op2Val
                    mov al,Bl
                    call LineStuckPwrUp
                    mov Bl,al
                    SHR Bl,cl
                    call SetCarryFlag
                    mov ValRegBX,Bx
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
                    cmp selectedPUPType,1
                    jne SHR_Bh_Reg_his
                    SHR_Bh_Reg_our:
                    mov Bx,ourValRegBX
                    mov cx,ourValRegCX
                    SHR Bh,cl
                    call ourSetCF
                    mov ourValRegBX,Bx
                    jmp Exit
                    SHR_Bh_Reg_his:
                    mov Bx,ValRegBX
                    mov cx,ValRegCX
                    SHR Bh,cl
                    call SetCarryFlag
                    mov ValRegBX,Bx
                    cmp selectedPUPType,2
                    je SHR_Bh_Reg_our
                    jmp Exit
                SHR_Bh_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    cmp selectedPUPType,1
                    SHR_Bh_Val_our:
                    mov Bx,ourValRegBX
                    mov cx,Op2Val
                    SHR Bh,cl
                    call ourSetCF
                    mov ourValRegBX,Bx
                    jmp Exit
                    SHR_Bh_Val_his:
                    mov Bx,ValRegBX
                    mov cx,Op2Val
                    mov al,Bh
                    call LineStuckPwrUp
                    mov Bh,al
                    SHR Bh,cl
                    call SetCarryFlag
                    mov ValRegBX,Bx
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
                    cmp selectedPUPType,1
                    jne SHR_Cx_Reg_his
                    SHR_Cx_Reg_our:
                    mov Cx,ourValRegCx
                    mov ax,cx
                    mov cx,ax
                    SHR Cx,cl
                    call ourSetCF
                    mov ourValRegCx,Cx
                    jmp Exit
                    SHR_Cx_Reg_his:
                    cmp selectedOp2Reg,7
                    jne SHR_invalid
                    mov Cx,ValRegCx
                    mov ax,cx
                    mov cx,ax
                    SHR Cx,cl
                    call SetCarryFlag
                    mov ValRegCx,Cx
                    cmp selectedPUPType,2
                    je SHR_Cx_Reg_our
                    jmp Exit
                SHR_Cx_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    cmp selectedPUPType,1
                    jne SHR_Cx_Val_his
                    SHR_Cx_Val_our:
                    mov bx,ourValRegCx
                    mov cx,Op2Val
                    SHR bx,cl
                    call ourSetCF
                    mov ourValRegCx,bx
                    jmp Exit
                    SHR_Cx_Val_his:
                    mov bx,ValRegCx
                    mov cx,Op2Val
                    mov ax,bx
                    call LineStuckPwrUp
                    mov bx,ax
                    SHR bx,cl
                    call SetCarryFlag
                    mov ValRegCx,bx
                    cmp selectedPUPType,2
                    je SHR_Cx_Val_our
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
                    cmp selectedPUPType,1
                    jne SHR_Cl_Reg_his
                    SHR_Cl_Reg_our:
                    mov ax,ourValRegCX
                    mov cx,ourValRegCX
                    SHR Al,cl
                    call ourSetCF
                    mov ourValRegCX,ax
                    jmp Exit
                    SHR_Cl_Reg_his:
                    mov ax,ValRegCX
                    mov cx,ValRegCX
                    SHR Al,cl
                    call SetCarryFlag
                    mov ValRegCX,ax
                    cmp selectedPUPType,2
                    je SHR_Cl_Reg_our
                    jmp Exit
                SHR_Cl_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    cmp selectedPUPType,1
                    jne SHR_Cl_Val_his
                    SHR_Cl_Val_our:
                    mov ax,ourValRegCX
                    mov cx,Op2Val
                    SHR al,cl
                    call ourSetCF
                    mov ourValRegCX,ax
                    jmp Exit
                    SHR_Cl_Val_his:
                    mov ax,ValRegCX
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    SHR al,cl
                    call SetCarryFlag
                    mov ValRegCX,ax
                    cmp selectedPUPType,2
                    je SHR_Cl_Val_our
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
                    cmp selectedPUPType,1
                    jne SHR_Ch_Reg_his
                    SHR_Ch_Reg_our:
                    mov cx,ourValRegCX
                    SHR Ch,cl
                    call ourSetCF
                    mov ourValRegCX,Cx
                    jmp Exit
                    SHR_Ch_Reg_his:
                    mov cx,ValRegCX
                    SHR Ch,cl
                    call SetCarryFlag
                    mov ValRegCX,Cx
                    cmp selectedPUPType,2
                    je SHR_Ch_Reg_our
                    jmp Exit
                SHR_Ch_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    cmp selectedPUPType,1
                    jne SHR_Ch_Val_his
                    SHR_Ch_Val_our:
                    mov ax,ourValRegCX
                    mov cx,Op2Val
                    SHR ah,cl
                    call ourSetCF
                    mov ourValRegCX,ax
                    jmp Exit
                    SHR_Ch_Val_his:
                    mov ax,ValRegCX
                    mov cx,Op2Val
                    ;;;;;;;;;;
                        mov bx,ax
                        mov al,ah
                        call LineStuckPwrUp
                        mov ah,al
                        mov al,bl
                    SHR ah,cl
                    call SetCarryFlag
                    mov ValRegCX,ax
                    cmp selectedPUPType,2
                    je SHR_Ch_Val_our
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
                    cmp selectedPUPType,1
                    jne SHR_Dx_Reg_his
                    SHR_Dx_Reg_our:
                    mov Dx,ourValRegDx
                    mov cx,ourValRegCX
                    SHR Dx,cl
                    call ourSetCF
                    mov ourValRegDx,Dx
                    jmp Exit
                    SHR_Dx_Reg_his:
                    mov Dx,ValRegDx
                    mov cx,ValRegCX
                    SHR Dx,cl
                    call SetCarryFlag
                    mov ValRegDx,Dx
                    cmp selectedPUPType,2
                    je SHR_Dx_Reg_our
                    jmp Exit
                SHR_Dx_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    cmp selectedPUPType,1
                    jne SHR_Dx_Val_his
                    SHR_Dx_Val_our:
                    mov ax,ourValRegDx
                    mov cx,Op2Val
                    SHR ax,cl
                    call ourSetCF
                    mov ourValRegDx,ax
                    jmp Exit
                    SHR_Dx_Val_his:
                    mov ax,ValRegDx
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    SHR ax,cl
                    call SetCarryFlag
                    mov ValRegDx,ax
                    cmp selectedPUPType,2
                    je SHR_Dx_Val_our
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
                    cmp selectedPUPType,1
                    jne SHR_Dl_Reg_his
                    SHR_Dl_Reg_our:
                    mov Dx,ourValRegDX
                    mov cx,ourValRegCX
                    SHR Dl,cl
                    call ourSetCF
                    mov ourValRegDX,Dx
                    jmp Exit
                    SHR_Dl_Reg_his:
                    mov Dx,ValRegDX
                    mov cx,ValRegCX
                    SHR Dl,cl
                    call SetCarryFlag
                    mov ValRegDX,Dx
                    cmp selectedPUPType,2
                    je SHR_Dl_Reg_our
                    jmp Exit
                SHR_Dl_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    cmp selectedPUPType,1
                    jne SHR_Dl_Val_his
                    SHR_Dl_Val_our:
                    mov Dx,ourValRegDX
                    mov cx,Op2Val
                    SHR Dl,cl
                    call ourSetCF
                    mov ourValRegDX,Dx
                    jmp Exit
                    SHR_Dl_Val_his:
                    mov ax,ValRegDX
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    SHR al,cl
                    call SetCarryFlag
                    mov ValRegDX,ax
                    cmp selectedPUPType,2
                    je SHR_Dl_Val_our
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
                    cmp selectedPUPType,1
                    jne SHR_Dh_Reg_his
                    SHR_Dh_Reg_our:
                    mov Dx,ourValRegDX
                    mov cx,ourValRegCX
                    SHR dh,cl
                    call ourSetCF
                    mov ourValRegDX,Dx
                    jmp Exit
                    SHR_Dh_Reg_his:
                    mov Dx,ValRegDX
                    mov cx,ValRegCX
                    SHR dh,cl
                    call SetCarryFlag
                    mov ValRegDX,Dx
                    cmp selectedPUPType,2
                    je SHR_Dh_Reg_our
                    jmp Exit
                SHR_Dh_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    cmp selectedPUPType,1
                    jne SHR_Dh_Val_his
                    SHR_Dh_Val_our:
                    mov Dx,ourValRegDX
                    mov cx,Op2Val
                    SHR dh,cl
                    call ourSetCF
                    mov ourValRegDX,Dx
                    jmp Exit
                    SHR_Dh_Val_his:
                    mov ax,ValRegDX
                    mov cx,Op2Val
                    ;;;;;;;;;;
                        mov bx,ax
                        mov al,ah
                        call LineStuckPwrUp
                        mov ah,al
                        mov al,bl
                    SHR ah,cl
                    call SetCarryFlag
                    mov ValRegDX,ax
                    cmp selectedPUPType,2
                    je SHR_Dh_Val_our
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
                    cmp selectedPUPType,1
                    jne SHR_Bp_Reg_his
                    SHR_Bp_Reg_our:
                    mov Bp,ourValRegBp
                    mov cx,ourValRegCX
                    SHR Bp,cl
                    call ourSetCF
                    mov ourValRegBp,Bp
                    jmp Exit
                    SHR_Bp_Reg_his:
                    mov Bp,ValRegBp
                    mov cx,ValRegCX
                    SHR Bp,cl
                    call SetCarryFlag
                    mov ValRegBp,Bp
                    cmp selectedPUPType,2
                    je SHR_Bp_Reg_our
                    jmp Exit
                SHR_Bp_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    cmp selectedPUPType,1
                    jne SHR_Bp_Val_his
                    SHR_Bp_Val_our:
                    mov Bp,ourValRegBp
                    mov cx,Op2Val
                    SHR Bp,cl
                    call ourSetCF
                    mov ourValRegBp,Bp
                    jmp Exit
                    SHR_Bp_Val_his:
                    mov ax,ValRegBp
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    SHR ax,cl
                    call SetCarryFlag
                    mov ValRegBp,ax
                    cmp selectedPUPType,2
                    je SHR_Bp_Val_our
                    jmp Exit
            SHR_Sp:
                cmp selectedOp2Type,0
                je SHR_Sp_Reg
                cmp selectedOp2Type,3
                je SHR_Sp_Val
                jmp SHR_invalid
                SHR_Sp_Reg:
                    cmp selectedOp2Reg,7
                    jne SHR_invalid
                    cmp selectedPUPType,1
                    jne SHR_Sp_Reg_his
                    SHR_Sp_Reg_our:
                    mov Sp,ourValRegSp
                    mov cx,ourValRegCX
                    SHR Sp,cl
                    call ourSetCF
                    mov ourValRegSp,Sp
                    jmp Exit
                    SHR_Sp_Reg_his:
                    mov Sp,ValRegSp
                    mov cx,ValRegCX
                    SHR Sp,cl
                    call SetCarryFlag
                    mov ValRegSp,Sp
                    cmp selectedPUPType,2
                    je SHR_Sp_Reg_our
                    jmp Exit
                SHR_Sp_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    cmp selectedPUPType,1
                    jne SHR_Sp_Val_his
                    SHR_Sp_Val_our:
                    mov Sp,ourValRegSp
                    mov cx,Op2Val
                    SHR Sp,cl
                    call ourSetCF
                    mov ourValRegSp,Sp
                    jmp Exit
                    SHR_Sp_Val_his:
                    mov ax,ValRegSp
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    SHR ax,cl
                    call SetCarryFlag
                    mov ValRegSp,ax
                    cmp selectedPUPType,2
                    je SHR_Sp_Val_our
                    jmp Exit
            SHR_Si:
                cmp selectedOp2Type,0
                je SHR_Si_Reg
                cmp selectedOp2Type,3
                je SHR_Si_Val
                jmp SHR_invalid
                SHR_Si_Reg:
                    cmp selectedOp2Reg,7
                    jne SHR_invalid
                    cmp selectedPUPType,1
                    jne SHR_Si_Reg_his
                    SHR_Si_Reg_our:
                    mov Si,ourValRegSi
                    mov cx,ourValRegCX
                    SHR Si,cl
                    call ourSetCF
                    mov ourValRegSi,Si
                    jmp Exit
                    SHR_Si_Reg_his:
                    mov Si,ValRegSi
                    mov cx,ValRegCX
                    SHR Si,cl
                    call SetCarryFlag
                    mov ValRegSi,Si
                    cmp selectedPUPType,2
                    je SHR_Si_Reg_our
                    jmp Exit
                SHR_Si_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    cmp selectedPUPType,1
                    jne SHR_Si_Val_his
                    SHR_Si_Val_our:
                    mov Si,ourValRegSi
                    mov cx,Op2Val
                    SHR Si,cl
                    call ourSetCF
                    mov ourValRegSi,Si
                    jmp Exit
                    SHR_Si_Val_his:
                    mov ax,ValRegSi
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    SHR ax,cl
                    call SetCarryFlag
                    mov ValRegSi,ax
                    cmp selectedPUPType,2
                    je SHR_Si_Val_our
                    jmp Exit
            SHR_Di:
                cmp selectedOp2Type,0
                je SHR_Di_Reg
                cmp selectedOp2Type,3
                je SHR_Di_Val
                jmp SHR_invalid
                SHR_Di_Reg:
                    cmp selectedOp2Reg,7
                    jne SHR_invalid
                    cmp selectedPUPType,1
                    jne SHR_Di_Reg_his
                    SHR_Di_Reg_our:
                    mov Di,ourValRegDi
                    mov cx,ourValRegCX
                    SHR Di,cl
                    call ourSetCF
                    mov ourValRegDi,Di
                    jmp Exit
                    SHR_Di_Reg_his:
                    mov Di,ValRegDi
                    mov cx,ValRegCX
                    SHR Di,cl
                    call SetCarryFlag
                    mov ValRegDi,Di
                    cmp selectedPUPType,2
                    je SHR_Di_Reg_our
                    jmp Exit
                SHR_Di_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    cmp selectedPUPType,1
                    jne SHR_Di_Val_his
                    SHR_Di_Val_our:
                    mov Di,ourValRegDi
                    mov cx,Op2Val
                    SHR Di,cl
                    call ourSetCF
                    mov ourValRegDi,Di
                    jmp Exit
                    SHR_Di_Val_his:
                    mov ax,ValRegDi
                    mov cx,Op2Val
                    call LineStuckPwrUp
                    SHR ax,cl
                    call SetCarryFlag
                    mov ValRegDi,ax
                    cmp selectedPUPType,2
                    je SHR_Di_Val_our
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
                    cmp selectedPUPType,1
                    jne SHR_AddBx_Reg_his
                    SHR_AddBx_Reg_our:
                    mov Bx,ourValRegBX
                    cmp Bx,15d
                    ja SHR_invalid
                    mov cx,ourValRegCX
                    SHR ourValMem[Bx],cl
                    call ourSetCF
                    mov ourValRegBX,Bx
                    jmp Exit
                    SHR_AddBx_Reg_his:
                    mov Bx,ValRegBX
                    cmp Bx,15d
                    ja SHR_invalid
                    mov cx,ValRegCX
                    ;;;;;;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[Bx]
                        call LineStuckPwrUp
                        mov ValMem[Bx],al
                    SHR ValMem[Bx],cl
                    call SetCarryFlag
                    mov ValRegBX,Bx
                    cmp selectedPUPType,2
                    je SHR_AddBx_Reg_our
                    jmp Exit
                SHR_AddBx_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    cmp selectedPUPType,1
                    jne SHR_AddBx_Val_his
                    SHR_AddBx_Val_our:
                    mov Bx,ourValRegBX
                    cmp Bx,15d
                    ja SHR_invalid
                    mov cx,Op2Val
                    SHR ourValMem[Bx],cl
                    call ourSetCF
                    mov ourValRegBX,Bx
                    jmp Exit
                    SHR_AddBx_Val_his:
                    mov Bx,ValRegBX
                    cmp Bx,15d
                    ja SHR_invalid
                    mov cx,Op2Val
                    ;;;;;;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[Bx]
                        call LineStuckPwrUp
                        mov ValMem[Bx],al
                    SHR ValMem[Bx],cl
                    call SetCarryFlag
                    mov ValRegBX,Bx
                    cmp selectedPUPType,2
                    je SHR_AddBx_Val_our
                    jmp Exit
            SHR_AddBp:
                cmp selectedOp2Type,0
                je SHR_AddBp_Reg
                cmp selectedOp2Type,3
                je SHR_AddBp_Val
                jmp SHR_invalid
                SHR_AddBp_Reg:
                    cmp selectedOp2Reg,7
                    jne SHR_invalid
                    cmp selectedPUPType,1
                    jne SHR_AddBp_Reg_his
                    SHR_AddBp_Reg_our:
                    mov Bp,ourValRegBp
                    cmp Bp,15d
                    ja SHR_invalid
                    mov cx,ourValRegCX
                    SHR ourValMem[Bp],cl
                    call ourSetCF
                    mov ourValRegBp,Bp
                    jmp Exit
                    SHR_AddBp_Reg_his:
                    mov Bp,ValRegBp
                    cmp Bp,15d
                    ja SHR_invalid
                    mov cx,ValRegCX
                    ;;;;;;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[Bp]
                        call LineStuckPwrUp
                        mov ValMem[Bp],al
                    SHR ValMem[Bp],cl
                    call SetCarryFlag
                    mov ValRegBp,Bp
                    cmp selectedPUPType,2
                    je SHR_AddBp_Reg_our
                    jmp Exit
                SHR_AddBp_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    cmp selectedPUPType,1
                    jne SHR_AddBp_Val_his
                    SHR_AddBp_Val_our:
                    mov Bp,ourValRegBp
                    cmp Bp,15d
                    ja SHR_invalid
                    mov cx,Op2Val
                    SHR ourValMem[Bp],cl
                    call ourSetCF
                    mov ourValRegBp,Bp
                    jmp Exit
                    SHR_AddBp_Val_his:
                    mov Bp,ValRegBp
                    cmp Bp,15d
                    ja SHR_invalid
                    mov cx,Op2Val
                    ;;;;;;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[Bp]
                        call LineStuckPwrUp
                        mov ValMem[Bp],al
                    SHR ValMem[Bp],cl
                    call SetCarryFlag
                    mov ValRegBp,Bp
                    cmp selectedPUPType,2
                    je SHR_AddBp_Val_our
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
                    cmp selectedPUPType,1
                    jne SHR_AddSi_Reg_his
                    SHR_AddSi_Reg_our:
                    mov Si,ourValRegSi
                    cmp Si,15d
                    ja SHR_invalid
                    mov cx,ourValRegCX
                    SHR ourValMem[Si],cl
                    call ourSetCF
                    mov ourValRegSi,Si
                    jmp Exit
                    SHR_AddSi_Reg_his:
                    mov Si,ValRegSi
                    cmp Si,15d
                    ja SHR_invalid
                    mov cx,ValRegCX
                    ;;;;;;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[Si]
                        call LineStuckPwrUp
                        mov ValMem[Si],al
                    SHR ValMem[Si],cl
                    call SetCarryFlag
                    mov ValRegSi,Si
                    cmp selectedPUPType,2
                    je SHR_AddSi_Reg_our
                    jmp Exit
                SHR_AddSi_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    cmp selectedPUPType,1
                    jne SHR_AddSi_Val_his
                    SHR_AddSi_Val_our:
                    mov Si,ourValRegSi
                    cmp Si,15d
                    ja SHR_invalid
                    mov cx,Op2Val
                    SHR ourValMem[Si],cl
                    call ourSetCF
                    mov ourValRegSi,Si
                    jmp Exit
                    SHR_AddSi_Val_his:
                    mov Si,ValRegSi
                    cmp Si,15d
                    ja SHR_invalid
                    mov cx,Op2Val
                    ;;;;;;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[Si]
                        call LineStuckPwrUp
                        mov ValMem[Si],al
                    SHR ValMem[Si],cl
                    call SetCarryFlag
                    mov ValRegSi,Si
                    cmp selectedPUPType,2
                    je SHR_AddSi_Val_our
                    jmp Exit
            SHR_AddDi:
                cmp selectedOp2Type,0
                je SHR_AddDi_Reg
                cmp selectedOp2Type,3
                je SHR_AddDi_Val
                jmp SHR_invalid
                SHR_AddDi_Reg:
                    cmp selectedOp2Reg,7
                    jne SHR_invalid
                    cmp selectedPUPType,1
                    jne SHR_AddDi_Reg_his
                    SHR_AddDi_Reg_our:
                    mov Di,ourValRegDi
                    cmp Di,15d
                    ja SHR_invalid
                    mov cx,ourValRegCX
                    SHR ourValMem[Di],cl
                    call ourSetCF
                    mov ourValRegDi,Di
                    jmp Exit
                    SHR_AddDi_Reg_his:
                    mov Di,ValRegDi
                    cmp Di,15d
                    ja SHR_invalid
                    mov cx,ValRegCX
                    ;;;;;;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[Di]
                        call LineStuckPwrUp
                        mov ValMem[Di],al
                    SHR ValMem[Di],cl
                    call SetCarryFlag
                    mov ValRegDi,Di
                    cmp selectedPUPType,2
                    je SHR_AddDi_Reg_our
                    jmp Exit
                SHR_AddDi_Val:
                    cmp Op2Val,255d
                    ja SHR_invalid
                    cmp selectedPUPType,1
                    jne SHR_AddDi_Val_his
                    SHR_AddDi_Val_our:
                    mov Di,ourValRegDi
                    cmp Di,15d
                    ja SHR_invalid
                    mov cx,Op2Val
                    SHR ourValMem[Di],cl
                    call ourSetCF
                    mov ourValRegDi,Di
                    jmp Exit
                    SHR_AddDi_Val_his:
                    mov Di,ValRegDi
                    cmp Di,15d
                    ja SHR_invalid
                    mov cx,Op2Val
                    ;;;;;;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[Di]
                        call LineStuckPwrUp
                        mov ValMem[Di],al
                    SHR ValMem[Di],cl
                    call SetCarryFlag
                    mov ValRegDi,Di
                    cmp selectedPUPType,2
                    je SHR_AddDi_Val_our
                    jmp Exit
        mov si,0
        SHR_Mem:
            mov bx,si
            cmp selectedOp2Mem,bl
            jne SHR_NotIt
            cmp selectedOp2Type,0
            je SHR_Mem_Reg
            cmp selectedOp2Type,3
            je SHR_Mem_Val
            jmp SHR_invalid
            SHR_Mem_Reg:
                cmp selectedOp2Reg,7
                jne SHR_invalid
                cmp selectedPUPType,1
                jne SHR_Mem_Reg_his
                SHR_Mem_Reg_our:
                mov cx,ourValRegCX
                SHR ourValMem[si],cl
                call ourSetCF
                jmp Exit
                SHR_Mem_Reg_his:
                mov cx,ValRegCX
                ;;;;;;;;;;;;;;;;;;
                    mov al,ValMem[si]
                    call LineStuckPwrUp
                    mov ValMem[si],al
                SHR ValMem[si],cl
                call SetCarryFlag
                cmp selectedPUPType,2
                je SHR_Mem_Reg_our
                jmp Exit
            SHR_Mem_Val:
                cmp Op2Val,255d
                ja SHR_invalid
                cmp selectedPUPType,1
                jne SHR_Mem_Val_his
                SHR_Mem_Val_our:
                mov cx,Op2Val
                SHR ourValMem[si],cl
                call ourSetCF
                jmp Exit
                SHR_Mem_Val_his:
                mov cx,Op2Val
                ;;;;;;;;;;;;;;;;;;
                    mov al,ValMem[si]
                    call LineStuckPwrUp
                    mov ValMem[si],al
                SHR ValMem[si],cl
                call SetCarryFlag
                cmp selectedPUPType,2
                je SHR_Mem_Val_our
                jmp Exit
            SHR_NotIt:
            inc si
            jmp SHR_Mem
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

        ; 5ra m4 48ala m3rf4 leh
        CheckKey_Invalid:
            CALL WaitKeyPress

        Push ax
            CALL ClearBuffer
        pop ax
        
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

        lea dx, ExecutedSuccesfully
        CALL ShowMsg

        CheckKey_Exit:
            CALL WaitKeyPress
        
        Push ax
            CALL ClearBuffer
        pop ax
        
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
AND_Comm_PROC PROC FAR
    CALL Op1Menu
    mov DX, CommaCursorLoc
    CALL SetCursor
    mov dl, ','
    CALL DisplayChar
    CALL Op2Menu

     
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

        AndOp1RegAX: 
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_andax   
            ExecAndReg ourValRegAX, ourValCF      ;command
            jmp Exit
            notthispower1_andax:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_andax  
            ExecAndReg ourValRegAX, ourValCF       ;coomand
            notthispower2_andax:
            ExecAndReg ValRegAX, ValCF
        AndOp1RegAL:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_andal   
            ExecAndReg_8Bit ourValRegAX, ourValCF      ;command
            jmp Exit
            notthispower1_andal:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_andal  
            ExecAndReg_8Bit ourValRegAX, ourValCF       ;coomand
            notthispower2_andal:
            ExecAndReg_8Bit ValRegAX, ValCF
        AndOp1RegAH:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_andah    
            ExecAndReg_8Bit ourValRegAX+1, ourValCF      ;command
            jmp Exit
            notthispower1_andah:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_andah  
            ExecAndReg_8Bit ourValRegAX+1, ourValCF       ;coomand
            notthispower2_andah:
            ExecAndReg_8Bit ValRegAX+1, ValCF
        AndOp1RegBX:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_andbx   
            ExecAndReg ourValRegBX, ourValCF      ;command
            jmp Exit
            notthispower1_andbx:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_andbx  
            ExecAndReg ourValRegBX, ourValCF       ;coomand
            notthispower2_andbx:
            ExecAndReg ValRegBX, ValCF
        AndOp1RegBL:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_andbl    
            ExecAndReg_8Bit ourValRegBX, ourValCF      ;command
            jmp Exit
            notthispower1_andbl:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_andbl 
            ExecAndReg_8Bit ourValRegBX, ourValCF       ;coomand
            notthispower2_andbl:
            ExecAndReg_8Bit ValRegBX, ValCF
        AndOp1RegBH:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_andbh    
            ExecAndReg_8Bit ourValRegBX+1, ourValCF      ;command
            jmp Exit
            notthispower1_andbh:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_andbh  
            ExecAndReg_8Bit ourValRegBX+1, ourValCF       ;coomand
            notthispower2_andbh:
            ExecAndReg_8Bit ValRegBX+1, ValCF
        AndOp1RegCX:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_andcx    
            ExecAndReg ourValRegCX, ourValCF      ;command
            jmp Exit
            notthispower1_andcx:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_andcx  
            ExecAndReg ourValRegCX, ourValCF       ;coomand
            notthispower2_andcx:
            ExecAndReg ValRegCX, ValCF
        AndOp1RegCL:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_andcl    
            ExecAndReg_8Bit ourValRegCX, ourValCF      ;command
            jmp Exit
            notthispower1_andcl:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_andcl  
            ExecAndReg_8Bit ourValRegCX, ourValCF       ;coomand
            notthispower2_andcl:
            ExecAndReg_8Bit ValRegCX, ValCF
        AndOp1RegCH:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_andch    
            ExecAndReg_8Bit ourValRegCX+1, ourValCF      ;command
            jmp Exit
            notthispower1_andch:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_andch  
            ExecAndReg_8Bit ourValRegCX+1, ourValCF       ;coomand
            notthispower2_andch:
            ExecAndReg_8Bit ValRegCX+1, ValCF
        AndOp1RegDX:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_anddx    
            ExecAndReg ourValRegDX, ourValCF      ;command
            jmp Exit
            notthispower1_anddx:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_anddx  
            ExecAndReg ourValRegDX, ourValCF       ;coomand
            notthispower2_anddx:
            ExecAndReg ValRegDX, ValCF
        AndOp1RegDL:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_anddl    
            ExecAndReg_8Bit ourValRegDX, ourValCF      ;command
            jmp Exit
            notthispower1_anddl:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_anddl  
            ExecAndReg_8Bit ourValRegDX, ourValCF       ;coomand
            notthispower2_anddl:
            ExecAndReg_8Bit ValRegDX, ValCF
        AndOp1RegDH:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_anddh    
            ExecAndReg_8Bit ourValRegDX+1, ourValCF      ;command
            jmp Exit
            notthispower1_anddh:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_anddh  
            ExecAndReg_8Bit ourValRegDX+1, ourValCF       ;coomand
            notthispower2_anddh:
            ExecAndReg_8Bit ValRegDX+1, ValCF
        AndOp1RegBP: 
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_andbp    
            ExecAndReg ourValRegBP, ourValCF      ;command
            jmp Exit
            notthispower1_andbp:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_andbp  
            ExecAndReg ourValRegBP, ourValCF       ;coomand
            notthispower2_andbp:
            ExecAndReg ValRegBP, ValCF
        AndOp1RegSP:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_andsp    
            ExecAndReg ourValRegSP, ourValCF      ;command
            jmp Exit
            notthispower1_andsp:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_andsp  
            ExecAndReg ourValRegSP, ourValCF       ;coomand
            notthispower2_andsp:
            ExecAndReg ValRegSP, ValCF
        AndOp1RegSI:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_andsi    
            ExecAndReg ourValRegSI, ourValCF      ;command
            jmp Exit
            notthispower1_andsi:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_andsi  
            ExecAndReg ourValRegSI, ourValCF       ;coomand
            notthispower2_andsi:
            ExecAndReg ValRegSI, ValCF
        AndOp1RegDI:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_anddi    
            ExecAndReg ourValRegDI, ourValCF      ;command
            jmp Exit
            notthispower1_anddi:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_anddi  
            ExecAndReg ourValRegDI, ourValCF       ;coomand
            notthispower2_anddi:
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
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_andaddbx    
            ExecAndAddReg ourValRegBX, ourValMem, ourValCF      ;command
            jmp Exit
            notthispower1_andaddbx:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_andaddbx  
            ExecAndAddReg ourValRegBX, ourValMem, ourValCF       ;coomand
            notthispower2_andaddbx:   
            ExecAndAddReg ValRegBX, ValMem, ValCF
        AndOp1AddRegBP:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_andaddbp    
            ExecAndAddReg ourValRegBP, ourValMem, ourValCF      ;command
            jmp Exit
            notthispower1_andaddbp:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_andaddbp  
            ExecAndAddReg ourValRegBP, ourValMem, ourValCF       ;coomand
            notthispower2_andaddbp:
            ExecAndAddReg ValRegBP, ValMem, ValCF
        AndOp1AddRegSI:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_andaddsi    
            ExecAndAddReg ourValRegSI, ourValMem, ourValCF      ;command
            jmp Exit
            notthispower1_andaddsi:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_andaddsi 
            ExecAndAddReg ourValRegSI, ourValMem, ourValCF       ;coomand
            notthispower2_andaddsi:
            ExecAndAddReg ValRegSI, ValMem, ValCF
        AndOp1AddRegDI:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_andadddi    
            ExecAndAddReg ourValRegDI, ourValMem, ourValCF      ;command
            jmp Exit
            notthispower1_andadddi:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_andadddi 
            ExecAndAddReg ourValRegDI, ourValMem, ourValCF       ;coomand
            notthispower2_andadddi:
            ExecAndAddReg ValRegDI, ValMem, ValCF
    AndOp1Mem:
                
                    mov si,0
                    SearchForMemand:
                    mov cx,si 
                    cmp selectedOp2Mem,cl
                    JNE Nextand
                    cmp selectedPUPType,1 ;command on your own processor  
                    jne notthispower1_andmem   
                    ExecAndMem ourValMem[si], ourValCF      ;command
                    jmp Exit
                    notthispower1_andmem:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_andmem 
                    ExecAndMem ourValMem[si], ourValCF       ;coomand
                    notthispower2_andmem:
                    ExecAndMem ValMem[si], ValCF
                    JMP Exit 
                    Nextand:
                    inc si 
                    jmp SearchForMemand
    RET
ENDP
MOV_Comm_PROC PROC FAR
    CALL Op1Menu
    mov DX, CommaCursorLoc
    CALL SetCursor
    mov dl, ','
    CALL DisplayChar
    CALL Op2Menu

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
            CALL ourGetSrcOp
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_movax   
            MOV ourValRegAX, AX     ;command
            jmp Exit
            notthispower1_movax:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_movax 
            MOV ourValRegAX, AX      ;coomand
            notthispower2_movax:
            CALL GetSrcOp
            MOV ValRegAX, AX
            JMP Exit
        MOVOp1RegAL:
            CALL ourGetSrcOp_8Bit
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_moval  
            MOV BYTE PTR ourValRegAX, AL    ;command
            jmp Exit
            notthispower1_moval:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_moval 
            MOV BYTE PTR ourValRegAX, AL      ;coomand
            notthispower2_moval:
            CALL GetSrcOp_8Bit
            MOV BYTE PTR ValRegAX, AL
            JMP Exit
        MOVOp1RegAH:
            ; Delete this lineAH
            CALL ourGetSrcOp_8Bit
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_movah 
            MOV BYTE PTR ourValRegAX+1, AL    ;command
            jmp Exit
            notthispower1_movah:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_movah 
            MOV BYTE PTR ourValRegAX+1, AL      ;coomand
            notthispower2_movah:
            CALL GetSrcOp_8Bit
            MOV BYTE PTR ValRegAX+1, AL
            JMP Exit
        MOVOp1RegBX:
            CALL ourGetSrcOp
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_movbx   
            MOV ourValRegBX, AX    ;command
            jmp Exit
            notthispower1_movbx:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_movbx 
            MOV ourValRegBX, AX      ;coomand
            notthispower2_movbx:
            CALL GetSrcOp
            MOV ValRegBX, AX
            JMP Exit
        MOVOp1RegBL:
            CALL ourGetSrcOp_8Bit
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_movbl 
            MOV BYTE PTR ourValRegBX, AL    ;command
            jmp Exit
            notthispower1_movbl:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_movbl
            MOV BYTE PTR ourValRegBX, AL      ;coomand
            notthispower2_movbl:
            CALL GetSrcOp_8Bit
            MOV BYTE PTR ValRegBX, AL
            JMP Exit
        MOVOp1RegBH:
            CALL ourGetSrcOp_8Bit
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_movbh
            MOV BYTE PTR ourValRegBX+1, AL    ;command
            jmp Exit
            notthispower1_movbh:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_movbh
            MOV BYTE PTR ourValRegBX+1, AL     ;coomand
            notthispower2_movbh:
            CALL GetSrcOp_8Bit
            MOV BYTE PTR ValRegBX+1, AL
            JMP Exit
        MOVOp1RegCX:
            CALL ourGetSrcOp
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_movcx   
            MOV ourValRegCX, AX    ;command
            jmp Exit
            notthispower1_movcx:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_movcx 
            MOV ourValRegCX, AX      ;coomand
            notthispower2_movcx:
            CALL GetSrcOp
            MOV ValRegCX, AX
            JMP Exit
        MOVOp1RegCL:
            CALL ourGetSrcOp_8Bit
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_movcl
            MOV BYTE PTR ourValRegCX, AL    ;command
            jmp Exit
            notthispower1_movcl:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_movcl
            MOV BYTE PTR ourValRegCX, AL     ;coomand
            notthispower2_movcl:
            CALL GetSrcOp_8Bit
            MOV BYTE PTR ValRegCX, AL
            JMP Exit
        MOVOp1RegCH:
            CALL ourGetSrcOp_8Bit
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_movch
            MOV BYTE PTR ourValRegCX+1, AL    ;command
            jmp Exit
            notthispower1_movch:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_movch
            MOV BYTE PTR ourValRegCX+1, AL     ;coomand
            notthispower2_movch:
            CALL GetSrcOp_8Bit
            MOV BYTE PTR ValRegCX+1, AL
            JMP Exit
        MOVOp1RegDX:
            CALL ourGetSrcOp
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_movdx   
            MOV ourValRegDX, AX    ;command
            jmp Exit
            notthispower1_movdx:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_movdx 
            MOV ourValRegDX, AX      ;coomand
            notthispower2_movdx:
            CALL GetSrcOp
            MOV ValRegDX, AX
            JMP Exit
        MOVOp1RegDL:
            CALL ourGetSrcOp_8Bit
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_movdl
            MOV BYTE PTR ourValRegDX, AL    ;command
            jmp Exit
            notthispower1_movdl:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_movdl
            MOV BYTE PTR ourValRegDX, AL     ;coomand
            notthispower2_movdl:
            CALL GetSrcOp_8Bit
            MOV BYTE PTR ValRegDX, AL
            JMP Exit
        MOVOp1RegDH:
            CALL ourGetSrcOp_8Bit
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_movdh
            MOV BYTE PTR ourValRegDX+1, AL    ;command
            jmp Exit
            notthispower1_movdh:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_movdh
            MOV BYTE PTR ourValRegDX+1, AL     ;coomand
            notthispower2_movdh:
            CALL GetSrcOp_8Bit
            MOV BYTE PTR ValRegDX+1, AL
            JMP Exit
        MOVOp1RegBP:
            CALL ourGetSrcOp
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_movbp   
            MOV ourValRegBP, AX    ;command
            jmp Exit
            notthispower1_movbp:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_movbp 
            MOV ourValRegBP, AX      ;coomand
            notthispower2_movbp:
            CALL GetSrcOp
            MOV ValRegBP, AX
            JMP Exit
        MOVOp1RegSP:
            CALL ourGetSrcOp
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_movsp   
            MOV ourValRegSP, AX    ;command
            jmp Exit
            notthispower1_movsp:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_movsp 
            MOV ourValRegSP, AX      ;coomand
            notthispower2_movsp:
            CALL GetSrcOp
            MOV ValRegSP, AX
            JMP Exit
        MOVOp1RegSI:
            CALL ourGetSrcOp
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_movsi   
            MOV ourValRegSI, AX    ;command
            jmp Exit
            notthispower1_movsi:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_movsi 
            MOV ourValRegSI, AX      ;coomand
            notthispower2_movsi:
            CALL GetSrcOp
            MOV ValRegSI, AX
            JMP Exit
        MOVOp1RegDI:
            CALL ourGetSrcOp
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_movdi   
            MOV ourValRegDI, AX    ;command
            jmp Exit
            notthispower1_movdi:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_movdi 
            MOV ourValRegDI, AX      ;coomand
            notthispower2_movdi:
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
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_movaddbx   
            ExecMovAddReg ourValRegBX, ourValMem    ;command
            jmp Exit
            notthispower1_movaddbx:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_movaddbx 
            ExecMovAddReg ourValRegBX, ourValMem      ;coomand
            notthispower2_movaddbx:
            ExecMovAddReg ValRegBX, ValMem
        MOVOp1AddRegBP:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_movaddbp   
            ExecMovAddReg ourValRegBP, ourValMem    ;command
            jmp Exit
            notthispower1_movaddbp:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_movaddbp
            ExecMovAddReg ourValRegBP, ourValMem      ;coomand
            notthispower2_movaddbp:
            ExecMovAddReg ValRegBP, ValMem
        MOVOp1AddRegSI:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_movaddsi 
            ExecMovAddReg ourValRegSI, ourValMem    ;command
            jmp Exit
            notthispower1_movaddsi:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_movaddsi 
            ExecMovAddReg ourValRegSI, ourValMem      ;coomand
            notthispower2_movaddsi:
            ExecMovAddReg ValRegSI, ValMem
        MOVOp1AddRegDI:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_movadddi 
            ExecMovAddReg ourValRegDI, ourValMem    ;command
            jmp Exit
            notthispower1_movadddi:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_movadddi 
            ExecMovAddReg ourValRegDI, ourValMem      ;coomand
            notthispower2_movadddi:
            ExecMovAddReg ValRegDI, ValMem
    MOVOp1Mem:
        
            mov si,0
            SearchForMemmov:
            mov cx,si 
            cmp selectedOp2Mem,cl
            JNE Nextmov
            cmp selectedPUPType,1 ; our command
            jne notthispower1_movmem
            ExecMovMem ourValMem[si] ; command
            jmp Exit
            notthispower1_movmem:  
            cmp selectedPUPType,2 ;his/her and our command 
            jne notthispower2_movmem 
            ExecMovMem ourValMem[si] ;command
            notthispower2_movmem: 
            ExecMovMem ValMem[si]
            JMP Exit 
            Nextmov:
            inc si 
            jmp SearchForMemmov

    
    JMP Exit
    RET
ENDP
ADD_Comm_PROC PROC FAR
    CALL Op1Menu
    MOV DX, CommaCursorLoc
    CALL SetCursor
    mov dl, ','
    CALL DisplayChar
    CALL Op2Menu

    CALL CheckForbidCharProc

     

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
            CALL ourGetSrcOp
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_addax 
            CLC
            ADD ourValRegAX, AX ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_addax:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_addax  
            CLC
            ADD ourValRegAX, AX ;command
            CALL ourSetCF        
            notthispower2_addax:
            CALL GetSrcOp
            CLC
            ADD ValRegAX, AX ;command
            CALL SetCF
            JMP Exit
        AddOp1RegAL:
            CALL ourGetSrcOp_8Bit
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_addal  
            CLC
            ADD BYTE PTR ourValRegAX, AL
            CALL ourSetCF      
            jmp Exit
            notthispower1_addal:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_addal 
            CLC
            ADD BYTE PTR ourValRegAX, AL
            CALL ourSetCF        
            notthispower2_addal:
            CALL GetSrcOp_8Bit
            CLC
            ADD BYTE PTR ValRegAX, AL
            CALL SetCF
            JMP Exit
        AddOp1RegAH:
            CALL ourGetSrcOp_8Bit
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_addah  
            CLC
            ADD BYTE PTR ourValRegAX+1, AL ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_addah:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_addah 
            CLC
            ADD BYTE PTR ourValRegAX+1, AL ;command
            CALL ourSetCF        
            notthispower2_addah:
            CALL GetSrcOp_8Bit
            CLC
            ADD BYTE PTR ValRegAX+1, AL ;command
            CALL SetCF
            JMP Exit
        AddOp1RegBX:
            CALL ourGetSrcOp
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_addbx 
            CLC
            ADD ourValRegBX, AX ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_addbx:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_addbx  
            CLC
            ADD ourValRegBX, AX ;command
            CALL ourSetCF        
            notthispower2_addbx:
            CALL GetSrcOp
            CLC
            ADD ValRegBX, AX
            CALL SetCF
            JMP Exit
        AddOp1RegBL:
            CALL ourGetSrcOp_8Bit
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_addbl  
            CLC
            ADD BYTE PTR ourValRegBX, AL
            CALL ourSetCF      
            jmp Exit
            notthispower1_addbl:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_addbl 
            CLC
            ADD BYTE PTR ourValRegBX, AL
            CALL ourSetCF        
            notthispower2_addbl:
            CALL GetSrcOp_8Bit
            CLC
            ADD BYTE PTR ValRegBX, AL
            CALL SetCF
            JMP Exit
        AddOp1RegBH:
            CALL ourGetSrcOp_8Bit
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_addbh  
            CLC
            ADD BYTE PTR ourValRegBX+1, AL
            CALL ourSetCF      
            jmp Exit
            notthispower1_addbh:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_addbh 
            CLC
            ADD BYTE PTR ourValRegBX+1, AL
            CALL ourSetCF        
            notthispower2_addbh:
            CALL GetSrcOp_8Bit
            CLC
            ADD BYTE PTR ValRegBX+1, AL
            CALL SetCF
            JMP Exit
        AddOp1RegCX:
            CALL ourGetSrcOp
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_addcx 
            CLC
            ADD ourValRegCX, AX ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_addcx:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_addcx  
            CLC
            ADD ourValRegCX, AX ;command
            CALL ourSetCF        
            notthispower2_addcx:
            CALL GetSrcOp
            CLC
            ADD ValRegCX, AX
            CALL SetCF
            JMP Exit
        AddOp1RegCL:
            CALL ourGetSrcOp_8Bit
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_addcl 
            CLC
            ADD BYTE PTR ourValRegCX, AL
            CALL ourSetCF      
            jmp Exit
            notthispower1_addcl:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_addcl 
            CLC
            ADD BYTE PTR ourValRegCX, AL
            CALL ourSetCF        
            notthispower2_addcl:
            CALL GetSrcOp_8Bit
            CLC
            ADD BYTE PTR ValRegCX, AL
            CALL SetCF
            JMP Exit
        AddOp1RegCH:
            CALL ourGetSrcOp_8Bit
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_addch 
            CLC
            ADD BYTE PTR ourValRegCX+1, AL
            CALL ourSetCF      
            jmp Exit
            notthispower1_addch:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_addch 
            CLC
            ADD BYTE PTR ourValRegCX+1, AL
            CALL ourSetCF        
            notthispower2_addch:
            CALL GetSrcOp_8Bit
            CLC
            ADD BYTE PTR ValRegCX+1, AL
            CALL SetCF
            JMP Exit
        AddOp1RegDX:
            CALL ourGetSrcOp
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_adddx 
            CLC
            ADD ourValRegDX, AX ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_adddx:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_adddx  
            CLC
            ADD ourValRegDX, AX ;command
            CALL ourSetCF        
            notthispower2_adddx:
            CALL GetSrcOp
            CLC
            ADD ValRegDX, AX
            CALL SetCF
            JMP Exit
        AddOp1RegDL:
            CALL ourGetSrcOp_8Bit
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_adddl 
            CLC
            ADD BYTE PTR ourValRegDX, AL
            CALL ourSetCF      
            jmp Exit
            notthispower1_adddl:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_adddl 
            CLC
            ADD BYTE PTR ourValRegDX, AL
            CALL ourSetCF        
            notthispower2_adddl:
            CALL GetSrcOp_8Bit
            CLC
            ADD BYTE PTR ValRegDX, AL
            CALL SetCF
            JMP Exit
        AddOp1RegDH:
            CALL ourGetSrcOp_8Bit
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_adddh 
            CLC
            ADD BYTE PTR ourValRegDX+1, AL
            CALL ourSetCF      
            jmp Exit
            notthispower1_adddh:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_adddh
            CLC
            ADD BYTE PTR ourValRegDX+1, AL
            CALL ourSetCF        
            notthispower2_adddh:
            CALL GetSrcOp_8Bit
            CLC
            ADD BYTE PTR ValRegDX+1, AL
            CALL SetCF
            JMP Exit
        AddOp1RegBP:
            CALL ourGetSrcOp
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_addbp 
            CLC
            ADD ourValRegBP, AX ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_addbp:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_addbp  
            CLC
            ADD ourValRegBP, AX ;command
            CALL ourSetCF        
            notthispower2_addbp:
            CALL GetSrcOp
            CLC
            ADD ValRegBP, AX
            CALL SetCF
            JMP Exit
        AddOp1RegSP:
            CALL ourGetSrcOp
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_addsp 
            CLC
            ADD ourValRegSP, AX ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_addsp:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_addsp  
            CLC
            ADD ourValRegSP, AX ;command
            CALL ourSetCF        
            notthispower2_addsp:
            CALL GetSrcOp
            CLC
            ADD ValRegSP, AX
            CALL SetCF
            JMP Exit
        AddOp1RegSI:
            CALL ourGetSrcOp
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_addsi 
            CLC
            ADD ourValRegSI, AX ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_addsi:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_addsi 
            CLC
            ADD ourValRegSI, AX ;command
            CALL ourSetCF        
            notthispower2_addsi:
            CALL GetSrcOp
            CLC
            ADD ValRegSI, AX
            CALL SetCF
            JMP Exit
        AddOp1RegDI:
            CALL ourGetSrcOp
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_adddi 
            CLC
            ADD ourValRegDI, AX ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_adddi:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_adddi  
            CLC
            ADD ourValRegDI, AX ;command
            CALL ourSetCF        
            notthispower2_adddi:
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
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_addaddbx 
            ExecAddAddReg ourValRegBx, ourValMem ;command      
            jmp Exit
            notthispower1_addaddbx:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_addaddbx   
            ExecAddAddReg ourValRegBx, ourValMem ;command       
            notthispower2_addaddbx:
            ExecAddAddReg ValRegBx, ValMem
        AddOp1AddRegBP:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_addaddbp 
            ExecAddAddReg ourValRegBP, ourValMem ;command      
            jmp Exit
            notthispower1_addaddbp:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_addaddbp   
            ExecAddAddReg ourValRegBP, ourValMem ;command       
            notthispower2_addaddbp:
            ExecAddAddReg ValRegBP, ValMem
        AddOp1AddRegSI:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_addaddsi 
            ExecAddAddReg ourValRegSI, ourValMem ;command      
            jmp Exit
            notthispower1_addaddsi:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_addaddsi   
            ExecAddAddReg ourValRegSI, ourValMem ;command       
            notthispower2_addaddsi:
            ExecAddAddReg ValRegSI, ValMem
        AddOp1AddRegDI:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_addadddi 
            ExecAddAddReg ourValRegDI, ourValMem ;command      
            jmp Exit
            notthispower1_addadddi:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_addadddi   
            ExecAddAddReg ourValRegDI, ourValMem ;command       
            notthispower2_addadddi:
            ExecAddAddReg ValRegDI, ValMem

    AddOp1Mem:
        
            mov si,0
            SearchForMemadd:
            mov cx,si 
            cmp selectedOp2Mem,cl
            JNE Nextadd
            cmp selectedPUPType,1 ; our command
            jne notthispower1_addmem
            ExecAddMem ourValMem[si] ; command
            jmp Exit
            notthispower1_addmem:  
            cmp selectedPUPType,2 ;his/her and our command 
            jne notthispower2_addmem 
            ExecAddMem ourValMem[si] ;command
            notthispower2_addmem: 
            ExecAddMem ValMem[si]
            JMP Exit 
            Nextadd:
            inc si 
            jmp SearchForMemadd

    
    JMP Exit
    RET
ENDP
ADC_Comm_PROC PROC FAR

    CALL Op1Menu
    mov DX, CommaCursorLoc
    CALL SetCursor
    mov dl, ','
    CALL DisplayChar
    CALL Op2Menu

    CALL CheckForbidCharProc
     

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
            CALL ourGetSrcOp 
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_adcax 
            CLC
            CALL ourGetCF
            ADC ourValRegAX, AX ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_adcax:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_adcax  
            CLC
            CALL ourGetCF
            ADC ourValRegAX, AX ;command
            CALL ourSetCF        
            notthispower2_adcax:
            CALL GetSrcOp 
            CLC
            CALL GetCF
            ADC ValRegAX, AX
            CALL SetCF
            JMP Exit
        AdcOp1RegAL:
            CALL ourGetSrcOp_8Bit 
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_adcal 
            CLC
            CALL ourGetCF
            ADC BYTE PTR ourValRegAX, AL ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_adcal:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_adcal  
            CLC
            CALL ourGetCF
            ADC BYTE PTR ourValRegAX, AL ;command
            CALL ourSetCF        
            notthispower2_adcal:
            CALL GetSrcOp_8Bit
            CLC
            CALL GetCF
            ADC BYTE PTR ValRegAX, AL
            CALL SetCF
            JMP Exit
        AdcOp1RegAH:
            CALL ourGetSrcOp_8Bit 
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_adcah 
            CLC
            CALL ourGetCF
            ADC BYTE PTR ourValRegAX+1, AL ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_adcah:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_adcah  
            CLC
            CALL ourGetCF
            ADC BYTE PTR ourValRegAX+1, AL ;command
            CALL ourSetCF        
            notthispower2_adcah:
            CALL GetSrcOp_8Bit
            CLC
            CALL GetCF
            ADC BYTE PTR ValRegAX+1, AL
            CALL SetCF
            JMP Exit
        AdcOp1RegBX:
            CALL ourGetSrcOp 
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_adcbx 
            CLC
            CALL ourGetCF
            ADC ourValRegBX, AX ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_adcbx:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_adcbx  
            CLC
            CALL ourGetCF
            ADC ourValRegBX, AX ;command
            CALL ourSetCF        
            notthispower2_adcbx:
            CALL GetSrcOp
            CLC
            CALL GetCF
            ADC ValRegBX, AX
            CALL SetCF
            JMP Exit
        AdcOp1RegBL:
            CALL ourGetSrcOp_8Bit 
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_adcbl 
            CLC
            CALL ourGetCF
            ADC BYTE PTR ourValRegBX, AL ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_adcbl:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_adcbl  
            CLC
            CALL ourGetCF
            ADC BYTE PTR ourValRegBX, AL ;command
            CALL ourSetCF        
            notthispower2_adcbl:
            CALL GetSrcOp_8Bit
            CLC
            CALL GetCF
            ADC BYTE PTR ValRegBX, AL
            CALL SetCF
            JMP Exit
        AdcOp1RegBH:
            CALL ourGetSrcOp_8Bit 
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_adcbh 
            CLC
            CALL ourGetCF
            ADC BYTE PTR ourValRegBX+1, AL ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_adcbh:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_adcbh  
            CLC
            CALL ourGetCF
            ADC BYTE PTR ourValRegBX+1, AL ;command
            CALL ourSetCF        
            notthispower2_adcbh:
            CALL GetSrcOp_8Bit
            CLC
            CALL GetCF
            ADC BYTE PTR ValRegBX+1, AL
            CALL SetCF
            JMP Exit
        AdcOp1RegCX:
            CALL ourGetSrcOp 
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_adccx 
            CLC
            CALL ourGetCF
            ADC ourValRegCX, AX ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_adccx:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_adccx  
            CLC
            CALL ourGetCF
            ADC ourValRegCX, AX ;command
            CALL ourSetCF        
            notthispower2_adccx:
            CALL GetSrcOp
            CLC
            CALL GetCF
            ADC ValRegCX, AX
            CALL SetCF
            JMP Exit
        AdcOp1RegCL:
            CALL ourGetSrcOp_8Bit 
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_adccl 
            CLC
            CALL ourGetCF
            ADC BYTE PTR ourValRegCX, AL ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_adccl:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_adccl  
            CLC
            CALL ourGetCF
            ADC BYTE PTR ourValRegCX, AL ;command
            CALL ourSetCF        
            notthispower2_adccl:
            CALL GetSrcOp_8Bit
            CLC
            CALL GetCF
            ADC BYTE PTR ValRegCX, AL
            CALL SetCF
            JMP Exit
        AdcOp1RegCH:
            CALL ourGetSrcOp_8Bit 
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_adcch 
            CLC
            CALL ourGetCF
            ADC BYTE PTR ourValRegCX+1, AL ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_adcch:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_adcch 
            CLC
            CALL ourGetCF
            ADC BYTE PTR ourValRegCX+1, AL ;command
            CALL ourSetCF        
            notthispower2_adcch:
            CALL GetSrcOp_8Bit
            CLC
            CALL GetCF
            ADC BYTE PTR ValRegCX+1, AL
            CALL SetCF
            JMP Exit
        AdcOp1RegDX:
            CALL ourGetSrcOp 
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_adcdx 
            CLC
            CALL ourGetCF
            ADC ourValRegDX, AX ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_adcdx:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_adcdx  
            CLC
            CALL ourGetCF
            ADC ourValRegDX, AX ;command
            CALL ourSetCF        
            notthispower2_adcdx:
            CALL GetSrcOp
            CLC
            CALL GetCF
            ADC ValRegDX, AX
            CALL SetCF
            JMP Exit
        AdcOp1RegDL:
            CALL ourGetSrcOp_8Bit 
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_adcdl 
            CLC
            CALL ourGetCF
            ADC BYTE PTR ourValRegDX, AL ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_adcdl:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_adcdl  
            CLC
            CALL ourGetCF
            ADC BYTE PTR ourValRegDX, AL ;command
            CALL ourSetCF        
            notthispower2_adcdl:
            CALL GetSrcOp_8Bit
            CLC
            CALL GetCF
            ADC BYTE PTR ValRegDX, AL
            CALL SetCF
            JMP Exit
        AdcOp1RegDH:
            CALL ourGetSrcOp_8Bit 
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_adcdh 
            CLC
            CALL ourGetCF
            ADC BYTE PTR ourValRegDX+1, AL ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_adcdh:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_adcdh 
            CLC
            CALL ourGetCF
            ADC BYTE PTR ourValRegDX+1, AL ;command
            CALL ourSetCF        
            notthispower2_adcdh:
            CALL GetSrcOp_8Bit
            CLC
            CALL GetCF
            ADC BYTE PTR ValRegDX+1, AL
            CALL SetCF
            JMP Exit
        AdcOp1RegBP:
            CALL ourGetSrcOp 
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_adcbp 
            CLC
            CALL ourGetCF
            ADC ourValRegBP, AX ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_adcbp:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_adcbp  
            CLC
            CALL ourGetCF
            ADC ourValRegBP, AX ;command
            CALL ourSetCF        
            notthispower2_adcbp:
            CALL GetSrcOp
            CLC
            CALL GetCF
            ADC ValRegBP, AX
            CALL SetCF
            JMP Exit
        AdcOp1RegSP:
            CALL ourGetSrcOp 
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_adcsp 
            CLC
            CALL ourGetCF
            ADC ourValRegSP, AX ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_adcsp:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_adcsp  
            CLC
            CALL ourGetCF
            ADC ourValRegSP, AX ;command
            CALL ourSetCF        
            notthispower2_adcsp:
            CALL GetSrcOp
            CLC
            CALL GetCF
            ADC ValRegSP, AX
            CALL SetCF
            JMP Exit
        AdcOp1RegSI:
            CALL ourGetSrcOp 
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_adcsi 
            CLC
            CALL ourGetCF
            ADC ourValRegSI, AX ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_adcsi:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_adcsi  
            CLC
            CALL ourGetCF
            ADC ourValRegSI, AX ;command
            CALL ourSetCF        
            notthispower2_adcsi:
            CALL GetSrcOp
            CLC
            CALL GetCF
            ADC ValRegSI, AX
            CALL SetCF
            JMP Exit
        AdcOp1RegDI:
            CALL ourGetSrcOp 
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_adcdi 
            CLC
            CALL ourGetCF
            ADC ourValRegDI, AX ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_adcdi:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_adcdi  
            CLC
            CALL ourGetCF
            ADC ourValRegDI, AX ;command
            CALL ourSetCF        
            notthispower2_adcdi:
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
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_adcaddbx 
            EexecAdcAddReg ourValRegBX, ourValMem     
            jmp Exit
            notthispower1_adcaddbx:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_adcaddbx 
            EexecAdcAddReg ourValRegBX, ourValMem        
            notthispower2_adcaddbx:
            EexecAdcAddReg ValRegBX, ValMem
        AdcOp1AddregBP:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_adcaddbp 
            EexecAdcAddReg ourValRegBP, ourValMem     
            jmp Exit
            notthispower1_adcaddbp:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_adcaddbp 
            EexecAdcAddReg ourValRegBP, ourValMem        
            notthispower2_adcaddbp:
            EexecAdcAddReg ValRegBP, ValMem
        AdcOp1AddregSI:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_adcaddsi 
            EexecAdcAddReg ourValRegSI, ourValMem     
            jmp Exit
            notthispower1_adcaddsi:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_adcaddsi
            EexecAdcAddReg ourValRegSI, ourValMem        
            notthispower2_adcaddsi:
            EexecAdcAddReg ValRegSI, ValMem
        AdcOp1AddregDI:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_adcadddi 
            EexecAdcAddReg ourValRegDI, ourValMem     
            jmp Exit
            notthispower1_adcadddi:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_adcadddi
            EexecAdcAddReg ourValRegDI, ourValMem        
            notthispower2_adcadddi:
            EexecAdcAddReg ValRegDI, ValMem
    AdcOp1Mem:

            mov si,0
            SearchForMemadc:
            mov cx,si 
            cmp selectedOp2Mem,cl
            JNE Nextadc
            cmp selectedPUPType,1 ; our command
            jne notthispower1_adcmem
            ExecAdcMem ourValMem[si] ; command
            jmp Exit
            notthispower1_adcmem:  
            cmp selectedPUPType,2 ;his/her and our command 
            jne notthispower2_adcmem 
            ExecAdcMem ourValMem[si] ;command
            notthispower2_adcmem: 
            ExecAdcMem ValMem[si]
            JMP Exit 
            Nextadc:
            inc si 
            jmp SearchForMemadc

    
    JMP Exit
    RET
ENDP
PUSH_Comm_PROC PROC FAR
    
    CALL Op1Menu

     
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
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_pushax  
            ourExecPush ourValRegAX      
            jmp Exit
            notthispower1_pushax:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_pushax  
            ourExecPush ourValRegAX        
            notthispower2_pushax:
            ExecPush ValRegAX
            JMP Exit
        PushOpRegBX:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_pushbx  
            ourExecPush ourValRegBX      
            jmp Exit
            notthispower1_pushbx:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_pushbx  
            ourExecPush ourValRegBX        
            notthispower2_pushbx:
            ExecPush ValRegBX
            JMP Exit
        PushOpRegCX:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_pushcx  
            ourExecPush ourValRegCX      
            jmp Exit
            notthispower1_pushcx:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_pushcx  
            ourExecPush ourValRegCX        
            notthispower2_pushcx:
            ExecPush ValRegCX
            JMP Exit
        PushOpRegDX:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_pushdx  
            ourExecPush ourValRegDX      
            jmp Exit
            notthispower1_pushdx:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_pushdx  
            ourExecPush ourValRegDX        
            notthispower2_pushdx:
            ExecPush ValRegDX
            JMP Exit
        PushOpRegBP:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_pushbp  
            ourExecPush ourValRegBP      
            jmp Exit
            notthispower1_pushbp:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_pushbp  
            ourExecPush ourValRegBP       
            notthispower2_pushbp:
            ExecPush ValRegBP
            JMP Exit
        PushOpRegSP:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_pushsp  
            ourExecPush ourValRegSP      
            jmp Exit
            notthispower1_pushsp:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_pushsp  
            ourExecPush ourValRegSP        
            notthispower2_pushsp:
            ExecPush ValRegSP
            JMP Exit
        PushOpRegSI:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_pushsi  
            ourExecPush ourValRegSI      
            jmp Exit
            notthispower1_pushsi:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_pushsi  
            ourExecPush ourValRegSI        
            notthispower2_pushsi:
            ExecPush ValRegSI
            JMP Exit
        PushOpRegDI:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_pushdi  
            ourExecPush ourValRegDI      
            jmp Exit
            notthispower1_pushdi:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_pushdi  
            ourExecPush ourValRegDI        
            notthispower2_pushdi:
            ExecPush ValRegDI
            JMP Exit

    ; Mem as operand
    PushOpMem:
            mov si,0
            SearchForMempush:
            mov cx,si 
            cmp selectedOp2Mem,cl
            JNE Nextpush
            cmp selectedPUPType,1 ; our command
            jne notthispower1_pushmem
            ourExecPushMem ourValMem[si] ; command
            jmp Exit
            notthispower1_pushmem:  
            cmp selectedPUPType,2 ;his/her and our command 
            jne notthispower2_pushmem 
            ourExecPushMem ourValMem[si] ;command
            notthispower2_pushmem: 
            ExecPushMem ValMem[si]
            JMP Exit 
            Nextpush:
            inc si 
            jmp SearchForMempush

    
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
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_pushaddbx  
            mov dx, ourValRegBX
            CALL CheckAddress
            cmp bl, 1               ; Value is greater than 16
            JZ InValidCommand
            mov SI, ourValRegBX
            ourExecPushMem ourValMem[SI]      
            jmp Exit
            notthispower1_pushaddbx:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_pushaddbx  
            mov dx, ourValRegBX
            CALL CheckAddress
            cmp bl, 1               ; Value is greater than 16
            JZ InValidCommand
            mov SI, ourValRegBX
            ourExecPushMem ourValMem[SI]       
            notthispower2_pushaddbx:

            mov dx, ValRegBX
            CALL CheckAddress
            cmp bl, 1               ; Value is greater than 16
            JZ InValidCommand
            mov SI, ValRegBX
            ExecPushMem ValMem[SI]
            JMP Exit
        PushOpAddRegBP:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_pushaddbp  
            mov dx, ourValRegBP
            CALL CheckAddress
            cmp bl, 1               ; Value is greater than 16
            JZ InValidCommand
            mov SI, ourValRegBP
            ourExecPushMem ourValMem[SI]      
            jmp Exit
            notthispower1_pushaddbp:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_pushaddbp  
            mov dx, ourValRegBP
            CALL CheckAddress
            cmp bl, 1               ; Value is greater than 16
            JZ InValidCommand
            mov SI, ourValRegBP
            ourExecPushMem ourValMem[SI]       
            notthispower2_pushaddbp:

            mov dx, ValRegBP
            CALL CheckAddress
            cmp bl, 1               ; Value is greater than 16
            JZ InValidCommand
            mov SI, ValRegBP
            ExecPushMem ValMem[SI]
            JMP Exit

        PushOpAddRegSI:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_pushaddsi  
            mov dx, ourValRegSI
            CALL CheckAddress
            cmp bl, 1               ; Value is greater than 16
            JZ InValidCommand
            mov SI, ourValRegSI
            ourExecPushMem ourValMem[SI]      
            jmp Exit
            notthispower1_pushaddsi:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_pushaddsi  
            mov dx, ourValRegSI
            CALL CheckAddress
            cmp bl, 1               ; Value is greater than 16
            JZ InValidCommand
            mov SI, ourValRegSI
            ourExecPushMem ourValMem[SI]       
            notthispower2_pushaddsi:

            mov dx, ValRegSI
            CALL CheckAddress
            cmp bl, 1               ; Value is greater than 16
            JZ InValidCommand
            mov SI, ValRegSI
            ExecPushMem ValMem[SI]
            JMP Exit
        
        PushOpAddRegDI:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_pushadddi  
            mov dx, ourValRegDI
            CALL CheckAddress
            cmp bl, 1               ; Value is greater than 16
            JZ InValidCommand
            mov SI, ourValRegDI
            ourExecPushMem ourValMem[SI]      
            jmp Exit
            notthispower1_pushadddi:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_pushadddi  
            mov dx, ourValRegDI
            CALL CheckAddress
            cmp bl, 1               ; Value is greater than 16
            JZ InValidCommand
            mov SI, ourValRegDI
            ourExecPushMem ourValMem[SI]       
            notthispower2_pushadddi:

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
        cmp selectedPUPType,1 ;command on your own processor  
        jne notthispower1_pushval  
        ourExecPush Op1Val      
        jmp Exit
        notthispower1_pushval:
        cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
        jne notthispower2_pushval  
        ourExecPush Op1Val       
        notthispower2_pushval:
        ExecPush Op1Val
        JMP Exit
    
    JMP Exit
    RET
ENDP
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
        CALL ClearBuffer
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
        CALL WaitKeyPress

    Push ax
    PUSH dx 
        CALL ClearBuffer
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
PowerUpMenu PROC
    ; Reset Cursor
        mov ah,2
        mov dx, PUPCursorLoc
        int 10h
        
    mov ah, 9
    mov dx, offset NOPUP
    int 21h

    CheckKeyOp1Type2:
        CALL WaitKeyPress

    Push ax
    PUSH dx 
        CALL ClearBuffer
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
    
    cmp ah, RightScanCode
    jz MoveRight_PowerUpMenu
    cmp ah, LeftScanCode
    jz MoveLeft_PowerUpMenu
    cmp ah, 57
    jz DrawBullet_PowerUpMenu
    cmp ah, EscScanCode
    jz Exit_PowerUpMenu

    JMP CheckKeyOp1Type2

    DrawBullet_PowerUpMenu:
        Call DrawBullet
        JMP CheckKeyOp1Type2
    MoveLeft_PowerUpMenu:
        CALL MoveShooterLeft
        JMP CheckKeyOp1Type2
    MoveRight_PowerUpMenu:
        CALL MoveShooterRight
        JMP CheckKeyOp1Type2
    Exit_PowerUpMenu:
        Call Terminate



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
PowerUpMenu ENDP
ExecutePwrUp PROC FAR
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
LineStuckPwrUp PROC  FAR   ; Value to be stucked is saved in AX/AL
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH AX
    CMP PwrUpStuckEnabled, 1
    jnz NoTStuck
        CMP PwrUpStuckVal, 0
        JZ PwrUpZero
        CMP PwrUpStuckVal, 1
        JZ PwrupOne
        JMP Return_LineStuckPwrUp

        PwrUpZero:
            MOV BX, 0FFFEH
            mov cl,PwrUpDataLineIndex
            ROL BX, cl
            AND AX, BX
            mov PwrUpStuckEnabled,0
            JMP NoTStuck
        PwrupOne:
            MOV BX, 1
            mov cl,PwrUpDataLineIndex
            ROL BX,cl
            OR AX, BX
            mov PwrUpStuckEnabled,0
    NoTStuck:
        cmp selectedPUPType,4
        jne Return_LineStuckPwrUp
        ;TODO Take 1 input from the user as the value to be stuck 0 or 1, and 1 input for the index of the value stuck
        
        mov ah,1
        int 21h
        cmp al,31h
        jg notvalid10 
        sub al,30h
        mov PwrUpStuckVal,al
        mov ah,1
        int 21h
        sub al,30h
        mov ah,0
        mov cx,c
        mul cx
        mov dx,ax
        mov ah,1
        int 21h
        sub al,30h 
        mov ah,0
        add dx,ax
        mov PwrUpDataLineIndex,dl
        cmp dx,15h
        jg notvalid10
        mov PwrUpStuckEnabled,1
        notvalid10:
        mov PwrUpStuckEnabled,0
    Return_LineStuckPwrUp:
    POP AX
    POP DX
    POP CX
    POP BX
    RET
ENDP
Op2TypeMenu PROC

    
    mov ah, 9
    mov dx, offset Reg
    int 21h

    CheckKey_Op2Type:
        CALL WaitKeyPress

    Push ax
    PUSH dx 
        CALL ClearBuffer
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
            CALL WaitKeyPress


        Push ax
        PUSH dx 
            CALL ClearBuffer
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
            CALL WaitKeyPress


        Push ax
        PUSH dx 
            CALL ClearBuffer
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
            CALL WaitKeyPress


        Push ax
        PUSH dx 
            CALL ClearBuffer
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

        CALL ClearBuffer
        

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
            CALL WaitKeyPress


        Push ax
        PUSH dx 
            CALL ClearBuffer
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
            CALL WaitKeyPress


        Push ax
        PUSH dx 
            CALL ClearBuffer
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
            CALL WaitKeyPress


        Push ax
        PUSH dx 
            CALL ClearBuffer
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
        CALL ClearBuffer

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
ourSetCF PROC
    PUSH BX
        MOV BL, 0
        ADC BL, 0
        MOV BL, ourValCF
    POP BX

    RET
ENDP
ourGetCF PROC
    PUSH BX
        MOV BL, ourValCF
        ADD BL, 0FFH
    POP BX

    RET
ENDP
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
ClearBuffer PROC     ;A Procedure to Clear Buffer
    push ax
    clr:
        mov ah,1
        int 16h
    jz exit_CLF
        mov ah,0
        int 16h
        jmp clr
    exit_CLF:
    pop ax
    RET
    ;Buffer Cleared
ENDP
END   MAIN