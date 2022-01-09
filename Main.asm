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
        ;;blabla
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
    DstOpReg MACRO p1_Reg, p2_Reg
        LOCAL p1_DstValReg, p2_DstValReg

        CMP p1_CpuEnabled, 1
        JZ p1_DstValReg
        CMP p2_CpuEnabled, 1
        JZ p2_DstValReg
        JMP RETURN_DstSrc

        p1_DstValReg:
            LEA DI, p1_Reg
            JMP RETURN_DstSrc
        p2_DstValReg:
            LEA DI, p2_Reg   
            JMP RETURN_DstSrc

    ENDM
    SrcOpReg MACRO p1_Reg, p2_Reg
        LOCAL p1_SrcValReg, p2_SrcValReg

        CMP p1_CpuEnabled, 1
        JZ p1_SrcValReg
        CMP p2_CpuEnabled, 1
        JZ p2_SrcValReg
        JMP RETURN_GetSrcOp

        p1_SrcValReg:
            mov AX, p1_Reg
            JMP RETURN_GetSrcOp
        p2_SrcValReg:
            MOV AX, p2_Reg
            JMP RETURN_GetSrcOp

    ENDM
    SrcOpReg_8bit MACRO p1_Reg, p2_Reg
        LOCAL p1_SrcValReg, p2_SrcValReg

        CMP p1_CpuEnabled, 1
        JZ p1_SrcValReg
        CMP p2_CpuEnabled, 1
        JZ p2_SrcValReg
        JMP RETURN_GetSrcOp_8Bit

        p1_SrcValReg:
            mov AL, BYTE PTR p1_Reg
            JMP RETURN_GetSrcOp_8Bit
        p2_SrcValReg:
            
            mov AL, BYTE PTR p2_Reg
            JMP RETURN_GetSrcOp_8Bit

    ENDM
    DstOpAddReg MACRO p1_Reg, p2_Reg
        LOCAL p1_DstValAddReg, p2_DstValAddReg, p1_ValidAddress, p2_ValidAddress

        CMP p1_CpuEnabled, 1
        JZ p1_DstValAddReg
        CMP p2_CpuEnabled, 1
        JZ p2_DstValAddReg
        JMP RETURN_DstSrc

        p1_DstValAddReg:
            MOV DX, p1_Reg
            CALL CheckAddress
            CMP BL, 1           ; Check Invalid address
            JNZ p1_ValidAddress
            MOV isInValidCommand, 1
            JMP RETURN_DstSrc

            p1_ValidAddress:
                MOV BX, p1_Reg
                LEA DI, ourValMem[BX]
                JMP RETURN_DstSrc
        p2_DstValAddReg:
            MOV DX, p2_Reg
            CALL CheckAddress
            CMP BL, 1           ; Check Invalid address
            JNZ p2_ValidAddress
            MOV isInValidCommand, 1
            JMP RETURN_DstSrc

            p2_ValidAddress:
                MOV BX, p2_Reg
                LEA DI, ValMem[BX]
                JMP RETURN_DstSrc

    ENDM
    SrcOpAddReg MACRO p1_Reg, p2_Reg
        LOCAL p1_SrcOpAddReg, p2_SrcOpAddReg, p1_ValidAddress, p2_ValidAddress

        CMP p1_CpuEnabled, 1
        JZ p1_SrcOpAddReg
        CMP p2_CpuEnabled, 1
        JZ p2_SrcOpAddReg
        
        
        JMP RETURN_GetSrcOp

        p1_SrcOpAddReg:
            MOV DX, p1_Reg
            CALL CheckAddress
            CMP BL, 1           ; Check Invalid address
            JNZ p1_ValidAddress
            MOV isInValidCommand, 1
            JMP RETURN_GetSrcOp

            p1_ValidAddress:
                MOV SI, p1_Reg
                MOV AX, WORD PTR ourValMem[SI]
                JMP RETURN_GetSrcOp
        p2_SrcOpAddReg:
            MOV DX, p2_Reg
            CALL CheckAddress
            CMP BL, 1           ; Check Invalid address
            
            JNZ p2_ValidAddress
            MOV isInValidCommand, 1
            JMP RETURN_GetSrcOp

            p2_ValidAddress:
                MOV SI, p2_Reg
                MOV AX, WORD PTR ValMem[SI]
                JMP RETURN_GetSrcOp

    ENDM
    SrcOpAddReg_8bit MACRO p1_Reg, p2_Reg
        LOCAL p1_SrcOpAddReg, p2_SrcOpAddReg, p1_ValidAddress, p2_ValidAddress

        CMP p1_CpuEnabled, 1
        JZ p1_SrcOpAddReg
        CMP p2_CpuEnabled, 1
        JZ p2_SrcOpAddReg
        JMP RETURN_GetSrcOp_8Bit

        p1_SrcOpAddReg:
            MOV DX, p1_Reg
            CALL CheckAddress
            CMP BL, 1           ; Check Invalid address
            JNZ p1_ValidAddress
            MOV isInValidCommand, 1
            JMP RETURN_GetSrcOp_8Bit

            p1_ValidAddress:
                MOV SI, p1_Reg
                MOV AL, ourValMem[SI]
                JMP RETURN_GetSrcOp_8Bit
        p2_SrcOpAddReg:
            MOV DX, p2_Reg
            CALL CheckAddress
            CMP BL, 1           ; Check Invalid address
            JNZ p2_ValidAddress
            MOV isInValidCommand, 1
            JMP RETURN_GetSrcOp_8Bit

            p2_ValidAddress:
                MOV SI, p2_Reg
                MOV AL, ValMem[SI]
                JMP RETURN_GetSrcOp_8Bit

    ENDM

    CheckForbidCharMacro MACRO comm
        Local ValidCommand
        mov di, comm
        Call CheckForbidChar
        CMP bl, 1
        jnz ValidCommand
        MOV isInvalidCommand, 1
        ValidCommand:
    ENDM
;================================================================================================================
.MODEL HUGE
;----------------
.386
.STACK 64
;================================================================================================================
.DATA
    ;---------------------------------------LEFT PROCESSOR----------------------------------------------:

        ; positions of X axis of the AX register in right processor
        p1_AX_X1 EQU 44
        p1_AX_X3 EQU 46
        p1_AX_Y EQU 4 ; the Y axis of the AX register of the left processor 


        ; positions of X axis of the BX register in right processor
        p1_BX_X1 EQU 44
        p1_BX_X3 EQU 46
        p1_BX_Y EQU 6 ; the Y axis of the AX register of the left processor 


        ; position of X axis of the DX register in right processor
        p1_CX_X1 EQU 44
        p1_CX_X3 EQU 46
        p1_CX_Y EQU 8 ; the Y axis of the AX register of the left processor 


        ; positions of X axis of the DX register in right processor
        p1_DX_X1 EQU 44   
        p1_DX_X3 EQU 46     
        p1_DX_Y EQU 10 ; the Y axis of the AX register of the left processor 


        ; positions of X axis of SP register in right processor 
        p1_SP_X1 equ 49
        p1_SP_X3 EQU 51
        p1_SP_Y equ 4 ; the Y position of SP register in the left processor 


        ; positions of X axis of BP register in right processor 
        p1_BP_X1 equ 49
        p1_BP_X3 EQU 51
        p1_BP_Y equ 6 ; the Y position of BP register in the left processor 

        ; positions of X axis of SI register in right processor 
        p1_SI_X1 equ 49
        p1_SI_X3 EQU 51
        p1_SI_Y equ 8 ; the Y position of SI register in the left processor 


        ; positions of X axis of DI register in right processor 
        p1_DI_X1 equ 49
        p1_DI_X3 EQU 51
        p1_DI_Y equ 10 ; the Y position of SI register in the left processor 

    ;---------------------------------------RIGHT PROCESSOR----------------------------------------------:

        ; positions of X axis of the AX register in right processor
        p2_AX_X1 EQU 107
        p2_AX_X3 EQU 109
        p2_AX_Y EQU 4 ; the Y axis of the AX register of the left processor 


        ; positions of X axis of the BX register in right processor
        p2_BX_X1 EQU 107
        p2_BX_X3 EQU 109
        p2_BX_Y EQU 6 ; the Y axis of the AX register of the left processor 


        ; positions of X axis of the DX register in right processor
        p2_CX_X1 EQU 107
        p2_CX_X3 EQU 109
        p2_CX_Y EQU 8 ; the Y axis of the AX register of the left processor 


        ; positions of X axis of the DX register in right processor
        p2_DX_X1 EQU 107
        p2_DX_X3 EQU 109
        p2_DX_Y EQU 10 ; the Y axis of the AX register of the left processor 


        ; positions of X axis of SP register in right processor 
        p2_SP_X1 equ 113
        p2_SP_X3 EQU 115
        p2_SP_Y equ 4 ; the Y position of SP register in the left processor 


        ; positions of X axis of BP register in right processor 
        p2_BP_X1 equ 113
        p2_BP_X3 EQU 115
        p2_BP_Y equ 6 ; the Y position of BP register in the left processor 

        ; positions of X axis of SI register in right processor 
        p2_SI_X1 equ 113
        p2_SI_X3 EQU 115
        p2_SI_Y equ 8 ; the Y position of SI register in the left processor 


        ; positions of X axis of DI register in right processor 
        p2_DI_X1 equ 113
        p2_DI_X3 EQU 115
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

    
    

    ; ----------------------------------------------- Keys Scan Codes ------------------------------------------- ;
        UpArrowScanCode EQU 72
        DownArrowScanCode EQU 80
        RightScanCode EQU 77
        LeftScanCode EQU 75
        EnterScanCode EQU 28
        SpaceScanCode EQU 57
        EscScanCode EQU 1
        F1ScanCode EQU 59
        F2ScanCode EQU 60
    ; ------------------------------------------------ Test Messages -------------------------------------------- ;
        mesSelCom db 10,'You have selected Command #', '$'
        mesSelOp1Type db 10,'You have selected Operand 1 of Type #', '$'
        mesSelReg db 10, 'You have selected Reg #', '$'
        mesSelMem db 10, 'You have selected Mem #', '$'
        mesEntVal db 10, 'You Entered value: ', '$'
        mesOponentData db 10, '--------- Oponent Data ----------', 10, '$'
        mesMyData db 10 ,     '------------ My Data ------------', 10, '$'
        mesBackScreen db 10, 'Press any key to return to the game.', 10, '$'
        mesMem db 10, 'Values Opponent in memory as Ascii: ', 10, '$'
        mesStack db 10, 'Values in stack as Ascii: ', 10, '$'
        mesStackPointer db 10,  'Value of stack pointer: ', 10 ,  '$'
        mesTest db 10,  ' TESTTTTTTT ', 10 ,  '$'
        mesRegAX db 10, 'Value of AX: ', '$'
        mesRegBX db 9, 'Value of BX: ', '$'
        mesRegCX db 10, 'Value of CX: ', '$'
        mesRegDX db 9, 'Value of DX: ', '$'
        mesRegSI db 10, 'Value of SI: ', '$'
        mesRegDI db 9, 'Value of DI: ', '$'
        mesRegBP db 10, 'Value of BP: ', '$'
        mesRegSP db 9, 'Value of SP: ', '$'
        mesRegCF db 10, 'Value of CF: ', '$'
        mesPoints db 9, 'Score: ', '$'
        mesForbidChar db 10, 'Forbid Char: ', '$'
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
		ChatInviteMsg DB 10, 'You have recieved a chat invitation, to accept it press F1 key!$'
        GameInviteMsg DB 10, 'You have recieved a game invitation, to accept it press F2 key!$'
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
            SerialData DB ?
            X2position db 9
            XpositionShooter1 db 8
            XpositionShooter2 db 32
            inputKey db ?
            XbulletShooter1 db 8
            YbulletShooter1 db 18
            XbulletShooter2 db 32
            YbulletShooter2 db 18
            X_Arr db 2,2,24,24
            red_pt db '1'
            blue_pt db '1'
            yellow_pt db '1'
            ball_colr db 0ch
            X db 0
            Y db 1
            x_axis db ?
            y_axis db ?
            text db 'string$'

        InstructionMsg db 10,      'Use Up/Down Arrows to navigate between commands.        ', '$'
        ExecutionFailed db 10,     'Invalid Command. Press Enter to continue.               ', '$'
        ExecutedSuccesfully db 10, 'Command Executed Sucessfully. Press Enter to continue.  ', '$'
        PlayerTwoWaitRound db 10,  'Waiting for player two...  Press Enter to skip          ', '$'
        ChangeForbidMsg db 10, 'Press the new forbidden char: ', '$'
        LineStuckIndexMsg db 10, 'Enter the number of the stuck data line (0-15): ', '$'
        LineStuckValMsg db 10, 'Enter the value to be stuck at (0/1): ', '$'
        NoAvailablePointsMsg db 10, 'No Available points.', '$'    
        ClearCommandSpace db 15 dup(' '), '$'
        Player1WinsMsg db 10, 'You Won! Congrats$', 10
        Player2WinsMsg db 10, 'You lost!$', 10
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
                SubPwrUpSize EQU 13

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

                
                AddRegAX db '[AX] ','$' ;0
                AddRegAL db '[AL] ','$' ;1
                AddRegAH db '[AH] ','$' ;2                
                AddRegBX db '[BX] ','$' ;3  
                AddRegBL db '[BL] ','$' ;4   
                AddRegBH db '[BH] ','$' ;5
                AddRegCX db '[CX] ','$' ;6               
                AddRegCL db '[CL] ','$' ;7 
                AddRegCH db '[CH] ','$' ;8  
                AddRegDX db '[DX] ','$' ;9
                AddRegDL db '[DL] ','$' ;10
                AddRegDH db '[DH] ','$' ;11                
                AddRegSX db '[SX] ','$' ;12  
                AddRegSL db '[SL] ','$' ;13  
                AddRegSH db '[SH] ','$' ;14
                AddRegBP db '[BP] ','$' ;15
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

                NOPUP db 'NoPo ','$'
                PUP1 db 'PUp1 ','$'
                PUP2 db 'PUp2 ','$'
                PUP3 db 'PUp3 ','$'
                PUP4 db 'PUp4 ','$'
                PUP5 db 'PUp5 ','$'

                DataIndex0 db  'Data Line 0 ','$'
                DataIndex1 db  'Data Line 1 ','$'
                DataIndex2 db  'Data Line 2 ','$'
                DataIndex3 db  'Data Line 3 ','$'
                DataIndex4 db  'Data Line 4 ','$'
                DataIndex5 db  'Data Line 5 ','$'
                DataIndex6 db  'Data Line 6 ','$'
                DataIndex7 db  'Data Line 7 ','$'
                DataIndex8 db  'Data Line 8 ','$'
                DataIndex9 db  'Data Line 9 ','$'
                DataIndex10 db 'Data Line 10','$'
                DataIndex11 db 'Data Line 11','$'
                DataIndex12 db 'Data Line 12','$'
                DataIndex13 db 'Data Line 13','$'
                DataIndex14 db 'Data Line 14','$'
                DataIndex15 db 'Data Line 15','$'

                StuckVal0 db   'Stuck Val: 0', '$'
                StuckVal1 db   'Stuck Val: 1', '$'
            
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
                cc equ 10

        ; ------------------------------------- Game Variables ------------------------------ ;
            ; ----------- Opponent Data ----------;
                ValRegAX dw 'AX'
                ValRegBX dw 'BX'
                ValRegCX dw 'CX'
                ValRegDX dw 'DX'
                ValRegBP dw 'BP'
                ValRegSP dw 0
                ValRegSI dw 'SI'
                ValRegDI dw 5677H

                ValMem db 16 dup('M'), '$'
                ValStack dw 8 dup('S'), '$'
                ValCF db 1
            
            ; ------------ Player Data -----------;

                ourValRegAX dw 'AX'
                ourValRegBX dw 'BX'
                ourValRegCX dw 'CX'
                ourValRegDX dw 'DX'
                ourValRegBP dw 'BP'
                ourValRegSP dw 0
                ourValRegSI dw 'SI'
                ourValRegDI dw 'DI' 
                
                ourValMem db 16 dup('M'), '$'
                ourValStack dw 8 dup('S'), '$'
                ourValCF db 0

            ; --------- Score and others --------;
                Player1_Points DB 8
                Player2_Points DB 0
                Player1_ForbidChar DB 0
		        Player2_ForbidChar DB 'X'
		        LEVEL           DB 0
                isInvalidCommand db 0   ; 1 if Invalid
                p1_CpuEnabled db 0      ; 1 if command will run on it
                p2_CpuEnabled db 1      ; ..

            ; ------- Power Up Variables --------;
                isPwrUp3Used db 0    ;Chance to use forbiden power up
                isPwrUp5Used db 0
                ourPwrUpDataLineIndex db 1
                ourPwrUpStuckVal db 1
                ourPwrUpStuckEnabled db 0

                opponentPwrUpDataLineIndex db 0
                opponentPwrUpStuckVal      db 0
                opponentPwrUpStuckEnabled  db 0

            ; ---------- Connection Variables ----- ;
                GameInvite db 0
                ChatInvite db 0
                AcceptGame db 0
                AcceptChat db 0
                HOST DB 0
            

        
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

        ; JMP TestSkip


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
        ;MOV DL, 0
        ;MOV DH, 22
        ;CALL MOVECURSOR
        ;MOV DX,OFFSET BORDER2
        ;CALL PRINTMESSAGE
        ;MOV BP, OFFSET   NAMEP2         ; SAVE THE NAEM OF THE SECOND PLAYER IN NAEMP2
        ;CALL FIRSTSCREEN
        ;MOV DX, NAMELENGTH
        ;MOV NAMEP2LEN, DX
        ;MOV NAMELENGTH,0
        ;MOV BH , InitialPoints
        ;MOV InitialPointsP2, BH
        ;CALL CLEARSCREEN
        ;---------------------------------------------------------------------------------------------------------------------------------------	
        

        BACK_TO_MAIN_SCREEN:

        CALL RecieveInvitations
        CALL PrintInvitation

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

        CALL CheckInvitationsAcception
        CMP AcceptChat, 1
        JZ GuestChat
        CMP AcceptGame, 1
        JZ GuestGame
    

        
        JMP BACK_TO_MAIN_SCREEN
        NEXTSCREEN:
        ;;  IF THERE IS AN INVITATION AND USER WANT TO BECOME HOST
        CMP GameInvite, 1
        JE BACK_TO_MAIN_SCREEN
        CMP ChatInvite, 1
        JE BACK_TO_MAIN_SCREEN
        CMP  CHOSEN,1
        JNE CHECK_CHAT
        GAME_AGAIN:
            MOV HOST, 1
            CALL SendGameInvite
            CALL WaitGameAcception
            MOV CX, 100
            WasteTime:
                DEC CX
                JNZ WasteTime
            GuestGame:
                CALL ExchangeInfo

            MOV BH , InitialPointsP1
            MOV BL , InitialPointsP2
            CMP BL, BH
            JB TAKE_PLAYER2POINTS
            sub bh,16
            MOV Player1_Points, BH
            MOV Player2_Points, BH
            jmp NotThisPointsDone
            TAKE_PLAYER2POINTS:
                sub bl,16
                MOV Player1_Points, BL
                MOV Player2_Points, BL
            NotThisPointsDone:
        CALL GAME  
        CHECK_CHAT:  CMP CHOSEN,2
                    JNE EXITP_ROGRAM
                    MOV HOST, 1
                    Call SendChatInvite 
                    CALL WaitChatAcception
                    GuestChat:
                        CALL ExchangeInfo
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
        PrintInvitation PROC FAR
            MOV DL, 0                     
            MOV DH, 22                    
            CALL MOVECURSOR
            CMP ChatInvite, 1
            JZ ShowChatInviteMsg
            CMP GameInvite, 1
            JZ ShowGameInviteMsg
            RET
            ShowChatInviteMsg:
                MOV DX,OFFSET ChatInviteMsg
                CALL PRINTMESSAGE
                RET
            ShowGameInviteMsg:
                MOV DX,OFFSET GameInviteMsg
                CALL PRINTMESSAGE
                RET
        ENDP	
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
    MOV DH, 000h
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
                        cmp HOST,1
                        jne GuestWaitforLevel

                        MOV DX, OFFSET MESG7
                        CALL PRINTMESSAGE
                        MOV AH, 0
                        INT 16H 
                        CMP AL, 31H                   ; THE LEVEL CHOSEN IS 1
                        JNZ LEVEL_2
                        MOV LEVEL, 1
                        mov bl,LEVEL
                        CALL SendByte
                        JMP LEVEL_1
            LEVEL_2:	 CMP AL, 32H
                        JNZ GET_ANOTHER_INPUT
                        ;-----------------------------------------------ADD THE NEW FEATURES HERE FOR LEVEL 2-----------------------------------------
                        MOV LEVEL, 2
                        NotThisHost:
                        CALL ReadInitialRegisters       ;;;;;;;;;;;Zawedha_Henaaaaaa;;;;;;;;;;;;
                        jmp GotoForbiddenChar
                        GuestWaitforLevel:
                            CALL CLEARSCREEN
                            CALL RecieveByte
                            mov Level,bl
                            cmp Level,1
                            je LEVEL_1
                            jmp NotThisHost

            LEVEL_1:	MOV DH, 0
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
            GotoForbiddenChar:
                        CALL GETFORBIDDEN
                        MOV Player1_ForbidChar, BL
                        CALL ExchangeForbiddenChar
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

        ret 
    CLEAR_SCREEN ENDP

    PlayerTwoRound PROC FAR

        lea dx, PlayerTwoWaitRound
        CALL ShowMsg

        CheckKey_P2Round:
            CALL ClearBuffer
            CALL WaitKeyPress
        
        PUSH ax
        PUSH DX
            CALL ClearBuffer
        POP DX
        pop ax
        
        cmp ah, EnterScanCode
        jz CONT_P2Round
        cmp ah, EscScanCode
        jz Exit_P2Round

        jmp CheckKey_P2Round

        Exit_P2Round:
            Call Terminate
        CONT_P2Round:
            RET
        
        RET
    ENDP
    ResetValues PROC FAR
        MOV isInvalidCommand, 0
        MOV p1_CpuEnabled, 0
        MOV p2_CpuEnabled, 0

        MOV selectedPUPType, -1
        MOV selectedComm, -1
        
        MOV selectedOp1Type, -1
        MOV selectedOp1Reg, -1
        MOV selectedOp1AddReg, -1
        MOV selectedOp1Mem, -1
        MOV selectedOp1Size,  8
        MOV Op1Val, 0
        MOV Op1Valid, 1               ; 0 if Invalid 

        MOV selectedOp2Type, -1
        MOV selectedOp2Reg, -1
        MOV selectedOp2AddReg, -1
        MOV selectedOp2Mem, -1
        MOV selectedOp2Size, 8
        MOV Op2Val, 0
        MOV Op2Valid, 1               ; 0 if Invalid

        RET
    ENDP
    ClearCommand PROC FAR
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH SI
        PUSH DI
            MOV DX, MenmonicCursorLoc
            CALL SetCursor
            LEA DX, ClearCommandSpace
            CALL DisplayString
        POP DI
        POP SI
        POP DX
        POP CX
        POP BX
        POP AX
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
            CALL PowrUpMenu
            CALL ExecPwrUp
            CALL ClearCommand
            CALL CommMenu
            CALL ClearCommand
            CALL DetectWinner
                CALL PlayerTwoRound
            CALL DetectWinner
            CALL ResetValues
            MOV p2_CpuEnabled, 1

        JMP GameLoop

        BreakGameLoop:



        RET
    ENDP

    ; ------------------------------------------- GUI Procedures ------------------------------------------- ;
    DrawFlyingObj PROC FAR

        ; Create the flying objects

        update_object: ; updating the position of the objects
        
        set 13 X_Arr[1]
        draw_obj ball_colr
        inc X_Arr[1]
    
        set 13 X_Arr[3]
        draw_obj 0bh
        inc X_Arr[3]


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
        mov bx,60000
        stop3:
        dec bx
        jnz stop3
        set 13 X_Arr[0]
        PrintChar_black 'o'
        inc X_Arr[0] 

        set 13 X_Arr[2]
        PrintChar_black 'o'
        inc X_Arr[2]

        RET

        ;jmp update_object

        set_object: ; set the objects to be all cleared 
        
            set 13 X_Arr[0]
            PrintChar_black 'o' 
            mov X_Arr[0],2
            mov X_Arr[1],2

            set 13 X_Arr[2]
            PrintChar_black 'o' 
            mov X_Arr[2],24
            mov X_Arr[3],24


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

        ;Draw the vertical line that seprates the chat from the commands

        mov cx,38
        mov dx,162
        seprate_vert:
            mov AH,0ch ; set for drawing a pixel
            mov AL,09h ; choose the blue color
            push cx
            mov cx,180
            INT 10H
            pop Cx
            inc dx
            dec cx
        jnz seprate_vert


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

        ;Draw the four registers in the two processors
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
        memory_:
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
        jnz memory_

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

            ;shooters names and points/////////////////////

            ;mov dx,OFFSET text 
            ;mov bl,0
            ;mov bh,4
            ;call ShowMsg 

            ;for P1
            Set 0 1
            draw_point 'P', 0fh
            Set 0 2
            draw_point '1', 0fh
            Set 0 3
            draw_point ':', 0fh
            Set 0 4
            Lea dx, NAMEP1
            CALL DisplayString

            ;for S1
            Set 0 14
            draw_point 'S', 0fh
            Set 0 15
            draw_point ':', 0fh
            Set 0 16
            MOV AL, Player1_Points
            MOV AH, 0
            MOV BL, 0
            MOV BH, 16
            CALL Display_Digit

            ;for P2
            Set 0 24
            draw_point 'P', 0fh
            Set 0 25
            draw_point '2', 0fh
            Set 0 26
            draw_point ':', 0fh
            Set 0 27
            LEA DX, NAMEP2
            CALL DisplayString

            ;for S1
            Set 0 34
            draw_point 'S', 0fh
            Set 0 35
            draw_point ':', 0fh
            Set 0 36
            MOV AH, 0
            MOV AL, Player2_Points
            MOV BL, 0
            MOV BH, 36
            CALL Display_Digit

        RET
    DrawGuiLayout ENDP

    DisplayGUIValues PROC FAR

        P1_Registers:
            mov dx, ourValRegAX
            mov BH, p1_AX_X3        ; x3 POS
            mov BL, p1_AX_Y         ; y3 pos
            mov al,dl
            call Display_ByteNum
            
            mov BH, p1_AX_X1        ; x1 POS
            mov BL, p1_AX_Y         ; y1 pos
            mov al,dh
            call Display_ByteNum

            mov dx, ourValRegBX
            mov BH, p1_BX_X3        ; x3 POS
            mov BL, p1_BX_Y         ; y3 pos
            
            mov al,dl
            call Display_ByteNum
            mov BH, p1_BX_X1        ; x1 POS
            mov BL, p1_BX_Y         ; y1 pos
            mov al,dh
            call Display_ByteNum

            mov dx, ourValRegCX
            mov BH, p1_CX_X3        ; x3 POS
            mov BL, p1_CX_Y         ; y3 pos
            
            mov al,dl
            call Display_ByteNum
            mov BH, p1_CX_X1        ; x1 POS
            mov BL, p1_CX_Y         ; y1 pos
            mov al,dh
            call Display_ByteNum

            mov dx, ourValRegDX
            mov BH, p1_DX_X3        ; x3 POS
            mov BL, p1_DX_Y         ; y3 pos
            
            mov al,dl
            call Display_ByteNum
            mov BH, p1_DX_X1        ; x1 POS
            mov BL, p1_DX_Y         ; y1 pos
            mov al,dh
            call Display_ByteNum

            mov dx, ourValRegBP
            mov BH, p1_BP_X3        ; x3 POS
            mov BL, p1_BP_Y         ; y3 pos
            mov al,dl
            
            call Display_ByteNum
            mov BH, p1_BP_X1        ; x1 POS
            mov BL, p1_BP_Y         ; y1 pos
            mov al,dh
            call Display_ByteNum

            mov dx, ourValRegSP
            mov BH, p1_SP_X3        ; x3 POS
            mov BL, p1_SP_Y         ; y3 pos
            mov al,dl
            call Display_ByteNum
            mov BH, p1_SP_X1        ; x1 POS
            mov BL, p1_SP_Y         ; y1 pos
            mov al,dh
            call Display_ByteNum

            mov dx, ourValRegSI
            mov BH, p1_SI_X3        ; x3 POS
            mov BL, p1_SI_Y         ; y3 pos
            
            mov al,dl
            call Display_ByteNum
            mov BH, p1_SI_X1        ; x1 POS
            mov BL, p1_SI_Y         ; y1 pos
            mov al,dh
            call Display_ByteNum

            mov dx, ourValRegDI
            mov BH, p1_DI_X3        ; x3 POS
            mov BL, p1_DI_Y         ; y3 pos
            
            mov al,dl
            call Display_ByteNum
            mov BH, p1_DI_X1        ; x1 POS
            mov BL, p1_DI_Y         ; y1 pos
            mov al,dh
            call Display_ByteNum

        P2_Registers:
            mov dx, ValRegAX
            mov BH, p2_AX_X3        ; x1 POS
            mov BL, p2_AX_Y         ; y1 pos
            
            mov al,dl
            call Display_ByteNum
            mov BH, p2_AX_X1        ; x1 POS
            mov BL, p2_AX_Y         ; y1 pos
            mov al,dh
            call Display_ByteNum

            mov dx, ValRegBX
            mov BH, p2_BX_X3        ; x1 POS
            mov BL, p2_BX_Y         ; y1 pos
           
            mov al,dl
            call Display_ByteNum
            mov BH, p2_BX_X1        ; x1 POS
            mov BL, p2_BX_Y         ; y1 pos
            mov al,dh
            call Display_ByteNum

            mov dx, ValRegCX
            mov BH, p2_CX_X3        ; x1 POS
            mov BL, p2_CX_Y         ; y1 pos
            
            mov al,dl
            call Display_ByteNum
            mov BH, p2_CX_X1        ; x1 POS
            mov BL, p2_CX_Y         ; y1 pos
            mov al,dh
            call Display_ByteNum

            mov dx, ValRegDX
            mov BH, p2_DX_X3        ; x1 POS
            mov BL, p2_DX_Y         ; y1 pos
            mov al,dl
            call Display_ByteNum
            mov BH, p2_DX_X1        ; x1 POS
            mov BL, p2_DX_Y         ; y1 pos
            mov al,dh
            call Display_ByteNum

            mov dx, ValRegBP
            mov BH, p2_BP_X3        ; x1 POS
            mov BL, p2_BP_Y         ; y1 pos
            mov al,dl
            call Display_ByteNum
            mov BH, p2_BP_X1        ; x1 POS
            mov BL, p2_BP_Y         ; y1 pos
            mov al,dh
            call Display_ByteNum

            mov dx, ValRegSP
            mov BH, p2_SP_X3        ; x1 POS
            mov BL, p2_SP_Y         ; y1 pos
            
            mov al,dl
            call Display_ByteNum
            mov BH, p2_SP_X1        ; x1 POS
            mov BL, p2_SP_Y         ; y1 pos
            mov al,dh
            call Display_ByteNum

            mov dx, ValRegSI
            mov BH, p2_SI_X3        ; x1 POS
            mov BL, p2_SI_Y         ; y1 pos
            
            mov al,dl
            call Display_ByteNum
            mov BH, p2_SI_X1        ; x1 POS
            mov BL, p2_SI_Y         ; y1 pos
            mov al,dh
            call Display_ByteNum

            mov dx, ValRegDI
            mov BH, p2_DI_X3        ; x1 POS
            mov BL, p2_DI_Y         ; y1 pos
            
            mov al,dl
            call Display_ByteNum
            mov BH, p2_DI_X1        ; x1 POS
            mov BL, p2_DI_Y         ; y1 pos
            mov al,dh
            call Display_ByteNum    


        left_memo:
            mov dh, 00
            mov dl, ourValMem
            mov bh, left_mem_X0  ;row
            mov bl, left_mem_Y0  ;column
            mov al,dl
            call Display_ByteNum

            MOV DH, 0
            MOV DL, ourValMem+1
            mov bh, left_mem_X2
            mov bl, left_mem_Y2
            mov al,dl
            call Display_ByteNum

            MOV DH, 0
            MOV DL, ourValMem+2
            mov bh, left_mem_X4
            mov bl, left_mem_Y4
            mov al,dl
            call Display_ByteNum

            MOV DH, 0
            MOV DL, ourValMem+3
            mov bh, left_mem_X6
            mov bl, left_mem_Y6
            mov al,dl
            call Display_ByteNum
            
            MOV DH, 0
            MOV DL, ourValMem+4
            mov bh, left_mem_X8
            mov bl, left_mem_Y8
            mov al,dl
            call Display_ByteNum
            
            MOV DH, 0
            MOV DL, ourValMem+5
            mov bh, left_mem_X10
            mov bl, left_mem_Y10
            mov al,dl
            call Display_ByteNum

            MOV DH, 0
            MOV DL, ourValMem+6
            mov bh, left_mem_X12
            mov bl, left_mem_Y12
            mov al,dl
            call Display_ByteNum

            MOV DH, 0
            MOV DL, ourValMem+7
            mov bh, left_mem_X14
            mov bl, left_mem_Y14
            mov al,dl
            call Display_ByteNum

            MOV DH, 0
            MOV DL, ourValMem+8
            mov bh, left_mem_X16
            mov bl, left_mem_Y16
            mov al,dl
            call Display_ByteNum

            MOV DH, 0
            MOV DL, ourValMem+9
            mov bh, left_mem_X18
            mov bl, left_mem_Y18
            mov al,dl
            call Display_ByteNum

            MOV DH, 0
            MOV DL, ourValMem+10
            mov bh, left_mem_X20
            mov bl, left_mem_Y20
            mov al,dl
            call Display_ByteNum

            MOV DH, 0
            MOV DL, ourValMem+11
            mov bh, left_mem_X22
            mov bl, left_mem_Y22
            mov al,dl
            call Display_ByteNum

            MOV DH, 0
            MOV DL, ourValMem+12
            mov bh, left_mem_X24
            mov bl, left_mem_Y24
            mov al,dl
            call Display_ByteNum

            MOV DH, 0
            MOV DL, ourValMem+13
            mov bh, left_mem_X26
            mov bl, left_mem_Y26
            mov al,dl
            call Display_ByteNum

            MOV DH, 0
            MOV DL, ourValMem+14
            mov bh, left_mem_X28
            mov bl, left_mem_Y28
            mov al,dl
            call Display_ByteNum

            MOV DH, 0
            MOV DL, ourValMem+15
            mov bh, left_mem_X30
            mov bl, left_mem_Y30
            mov al,dl
            call Display_ByteNum

        right_memo:
            MOV DH, 0
            MOV DL, ValMem
            mov bh, right_mem_X0
            mov bl, right_mem_Y0
            mov al,dl
            call Display_ByteNum

            MOV DH, 0
            MOV DL, ValMem+1
            mov bh, right_mem_X2
            mov bl, right_mem_Y2
            mov al,dl
            call Display_ByteNum
            
            MOV DH, 0
            MOV DL, ValMem+2
            mov bh, right_mem_X4
            mov bl, right_mem_Y4
            mov al,dl
            call Display_ByteNum
            
            MOV DH, 0
            MOV DL, ValMem+3
            mov bh, right_mem_X6
            mov bl, right_mem_Y6
            mov al,dl
            call Display_ByteNum
            
            MOV DH, 0
            MOV DL, ValMem+4
            mov bh, right_mem_X8
            mov bl, right_mem_Y8
            mov al,dl
            call Display_ByteNum

            MOV DH, 0
            MOV DL, ValMem+5
            mov bh, right_mem_X10
            mov bl, right_mem_Y10
            mov al,dl
            call Display_ByteNum

            MOV DH, 0
            MOV DL, ValMem+6
            mov bh, right_mem_X12
            mov bl, right_mem_Y12
            mov al,dl
            call Display_ByteNum
            
            MOV DH, 0
            MOV DL, ValMem+7
            mov bh, right_mem_X14
            mov bl, right_mem_Y14
            mov al,dl
            call Display_ByteNum
            
            MOV DH, 0
            MOV DL, ValMem+8
            mov bh, right_mem_X16
            mov bl, right_mem_Y16
            mov al,dl
            call Display_ByteNum
            
            MOV DH, 0
            MOV DL, ValMem+9
            mov bh, right_mem_X18
            mov bl, right_mem_Y18
            mov al,dl
            call Display_ByteNum

            MOV DH, 0
            MOV DL, ValMem+10
            mov bh, right_mem_X20
            mov bl, right_mem_Y20
            mov al,dl
            call Display_ByteNum
            
            MOV DH, 0
            MOV DL, ValMem+11
            mov bh, right_mem_X22
            mov bl, right_mem_Y22
            mov al,dl
            call Display_ByteNum

            MOV DH, 0
            MOV DL, ValMem+12
            mov bh, right_mem_X24
            mov bl, right_mem_Y24
            mov al,dl
            call Display_ByteNum

            MOV DH, 0
            MOV DL, ValMem+13
            mov bh, right_mem_X26
            mov bl, right_mem_Y26
            mov al,dl
            call Display_ByteNum
            
            MOV DH, 0
            MOV DL, ValMem+14
            mov bh, right_mem_X28
            mov bl, right_mem_Y28
            mov al,dl
            call Display_ByteNum
            
            MOV DH, 0
            MOV DL, ValMem+15
            mov bh, right_mem_X30
            mov bl, right_mem_Y30
            mov al,dl
            call Display_ByteNum

            
        RET
    ENDP
    DisplayRegValues PROC FAR
        CALL CLEAR_SCREEN

        ; Show Opponent variables
        lea dx, mesOponentData
        Call DisplayString

        lea dx, mesMem
        CALL DisplayString
        lea dx, ValMem
        CALL DisplayString

        lea dx, mesStack
        CALL DisplayString
        lea dx, ValStack
        CALL DisplayString

        LEA DX, mesRegAX
        CALL DisplayString
        PUSH ValRegAX
        CALL DisplayHexanumber

        mov dl,Byte ptr ValRegAX
        CALL DisplayChar
        mov dl, byte ptr ValRegAX+1
        CALL DisplayChar

        LEA DX, mesRegBX
        CALL DisplayString
        mov dl,Byte ptr ValRegBX
        CALL DisplayChar
        mov dl, byte ptr ValRegBX+1
        CALL DisplayChar 

        LEA DX, mesRegCX
        CALL DisplayString
        mov dl,Byte ptr ValRegCX
        CALL DisplayChar
        mov dl, byte ptr ValRegCX+1
        CALL DisplayChar 

        LEA DX, mesRegDX
        CALL DisplayString
        mov dl,Byte ptr ValRegDX
        CALL DisplayChar
        mov dl, byte ptr ValRegDX+1
        CALL DisplayChar 

        LEA DX, mesRegSI
        CALL DisplayString
        mov dl,Byte ptr ValRegSI
        CALL DisplayChar
        mov dl, byte ptr ValRegSI+1
        CALL DisplayChar 

        LEA DX, mesRegDI
        CALL DisplayString
        mov dl,Byte ptr ValRegDI
        CALL DisplayChar
        mov dl, byte ptr ValRegDI+1
        CALL DisplayChar 

        LEA DX, mesRegBP
        CALL DisplayString
        mov dl,Byte ptr ValRegBP
        CALL DisplayChar
        mov dl, byte ptr ValRegBP+1
        CALL DisplayChar 

        LEA DX, mesRegSP
        CALL DisplayString
        mov dl,Byte ptr ValRegSP
        CALL DisplayChar
        mov dl, byte ptr ValRegSP+1
        CALL DisplayChar
        
        LEA DX, mesRegCF
        CALL DisplayString
        mov dl, ValCF
        add dl, '0'
        CALL DisplayChar

        LEA DX, mesPoints
        CALL DisplayString
        mov dl, Player2_Points
        add dl, '0'
        CALL DisplayChar

        LEA DX, mesForbidChar
        CALL DisplayString
        mov dl, Player2_ForbidChar
        CALL DisplayChar

        ; Show user Data

        lea dx, mesMyData
        Call DisplayString

        lea dx, mesMem
        CALL DisplayString
        lea dx, ourValMem
        CALL DisplayString

        lea dx, mesStack
        CALL DisplayString
        lea dx, ourValStack
        CALL DisplayString

        LEA DX, mesRegAX
        CALL DisplayString
        mov dl,Byte ptr ourValRegAX
        CALL DisplayChar
        mov dl, byte ptr ourValRegAX+1
        CALL DisplayChar

        LEA DX, mesRegBX
        CALL DisplayString
        mov dl,Byte ptr ourValRegBX
        CALL DisplayChar
        mov dl, byte ptr ourValRegBX+1
        CALL DisplayChar 

        LEA DX, mesRegCX
        CALL DisplayString
        mov dl,Byte ptr ourValRegCX
        CALL DisplayChar
        mov dl, byte ptr ourValRegCX+1
        CALL DisplayChar 

        LEA DX, mesRegDX
        CALL DisplayString
        mov dl,Byte ptr ourValRegDX
        CALL DisplayChar
        mov dl, byte ptr ourValRegDX+1
        CALL DisplayChar 

        LEA DX, mesRegSI
        CALL DisplayString
        mov dl,Byte ptr ourValRegSI
        CALL DisplayChar
        mov dl, byte ptr ourValRegSI+1
        CALL DisplayChar 

        LEA DX, mesRegDI
        CALL DisplayString
        mov dl,Byte ptr ourValRegDI
        CALL DisplayChar
        mov dl, byte ptr ourValRegDI+1
        CALL DisplayChar 

        LEA DX, mesRegBP
        CALL DisplayString
        mov dl,Byte ptr ourValRegBP
        CALL DisplayChar
        mov dl, byte ptr ourValRegBP+1
        CALL DisplayChar 

        LEA DX, mesRegSP
        CALL DisplayString
        mov dl,Byte ptr ourValRegSP
        CALL DisplayChar
        mov dl, byte ptr ourValRegSP+1
        CALL DisplayChar
        
        LEA DX, mesRegCF
        CALL DisplayString
        mov dl, ourValCF
        add dl, '0'
        CALL DisplayChar

        LEA DX, mesPoints
        CALL DisplayString
        mov dl, Player1_Points
        add dl, '0'
        CALL DisplayChar

        LEA DX, mesForbidChar
        CALL DisplayString
        mov dl, Player2_ForbidChar
        CALL DisplayChar

        ; End
        lea dx, mesBackScreen
        CALL DisplayString
        
        ; Stop the screen
        mov ah,0
        int 16h

        mov cx,22
        mov ax, 13h 
        int 10h   ;converting to graphics mode

        RET
    ENDP
    DrawShooter PROC FAR
            mov ax,0
        Draw_shooter:
            Set 19 XpositionShooter1 
            PrintChar '^'
            Set 19 XpositionShooter2 
            PrintChar '^'

        RET
    ENDP
    ourDrawBullet PROC FAR
        Draw_bullet:
            push dx
                mov ah,0
                int 16h
                mov cl,XpositionShooter1
                mov  XbulletShooter1,cl
            Set YbulletShooter1 XbulletShooter1; move the bullet
            PrintChar '.'
            jmp update_bullet

        set_bullet:
            Set YbulletShooter1 XbulletShooter1; move the bullet
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
            Set YbulletShooter1 XbulletShooter1 ;clear the bullet
            PrintChar_black '.'
            dec YbulletShooter1

        chk_red:
            mov cl,X_Arr[0]
            cmp YbulletShooter1,13
            je chk_red_col
            jg chk_bound
        chk_red_col:
            mov cl,X_Arr[0]
            cmp XbulletShooter1,cl
            je increment_red

        chk_bound:
            cmp YbulletShooter1,13; compare with the boundry
            jg set_bullet

        back_to_update:
            Set YbulletShooter1 XbulletShooter1 ;clear the bullet
            PrintChar_black '.'
            mov cl,XpositionShooter1
            mov  XbulletShooter1,cl
            mov cl,17
            mov YbulletShooter1,cl

            POP Dx
            RET

            
        increment_red:; increment the red points

            inc Player1_Points
            ;Set 0 16
            ;draw_point Player1_Points, 0fh
            jmp back_to_update
    ENDP
    opponentDrawBullet PROC FAR
        Draw_bullet_Shooter2:
            mov ah,0
            int 16h
            
            mov cl,XpositionShooter2
            mov  XbulletShooter2,cl
            Set YbulletShooter2 XbulletShooter2; move the bullet
            PrintChar '.'
        jmp update_bullet_Shooter2

        set_bullet_Shooter2:
            Set YbulletShooter2 XbulletShooter2; move the bullet
            PrintChar '.'
            mov cx,5000
            delay1_Sh2:
            dec cx
            jnz delay1_Sh2
            mov cx,50000
            delay2_Sh2:
            dec cx
            jnz delay2_Sh2
            mov cx,50000
            delay3_Sh2:
            dec cx
            jnz delay3_Sh2
        jmp update_bullet_Shooter2

        update_bullet_Shooter2:
            Set YbulletShooter2 XbulletShooter2 ;clear the bullet
            PrintChar_black '.'
            dec YbulletShooter2


        ;check if the bullet hits any flying object or the boundry
        chk_red2:
            mov cl,X_Arr[0]
            cmp YbulletShooter2,13
            je chk_red_col
            jg chk_bound
        chk_red_col2:
            mov cl,X_Arr[0]
            cmp XbulletShooter2,cl
            je increment_red2


        chk_bound2:
            cmp YbulletShooter2,13; compare with the boundry
            jg set_bullet_Shooter2



        back_to_update2:
            Set YbulletShooter2 XbulletShooter2 ;clear the bullet
            PrintChar_black '.'
            mov cl,XpositionShooter2
            mov  XbulletShooter2,cl
            mov cl,17
            mov YbulletShooter2,cl

            RET

        increment_red2:; increment the red points
            jmp back_to_update

        RET
    ENDP
    MoveShooter1Left PROC FAR
        Is_smallerShooter1:  ; check the left boundry 
            ;mov ah,0
            ;int 16h
            cmp XpositionShooter1, 2
            jl RETURN_MoveShooter1Left
            jge moveleftShooter1

        moveleftShooter1:
            push dx
                ;draw the shooter with the black color as im deleting it 
                Set 19 XpositionShooter1
                PrintChar_black '^'
                dec XpositionShooter1
            pop dx

        RETURN_MoveShooter1Left:
            RET
    ENDP
    MoveShooter1Right PROC FAR
        Is_greaterShooter1:  ; check the right boundry
            cmp XpositionShooter1, 14
            jg RETURN_MoveShooter1Right
            jle moveRightShooter1

        moveRightShooter1:
            push dx
                ;draw the shooter with the black color as im deleting it
                Set 19 XpositionShooter1
                PrintChar_black '^' 
                inc XpositionShooter1
            pop dx
        
        RETURN_MoveShooter1Right:
            RET
    ENDP
    MoveShooter2Left PROC FAR
        Is_smallerShooter2:  ; check the left boundry 
            ;mov ah,0
            ;int 16h
            cmp XpositionShooter2, 26
            jl RETURN_MoveShooter2Left
            jge moveleftShooter2

        moveleftShooter2:
            push dx
                ;draw the shooter with the black color as im deleting it 
                Set 19 XpositionShooter2
                PrintChar_black '^'
                dec XpositionShooter2
            pop dx

        RETURN_MoveShooter2Left:
            RET
    ENDP
    MoveShooter2Right PROC FAR
        Is_greaterShooter2:  ; check the right boundry
            cmp XpositionShooter2, 38
            jg RETURN_MoveShooter2Right
            jle moveRightShooter2

        moveRightShooter2:
            push dx
                ;draw the shooter with the black color as im deleting it
                Set 19 XpositionShooter2
                PrintChar_black '^' 
                inc XpositionShooter2
            pop dx
        
        RETURN_MoveShooter2Right:
            RET

        RET
    ENDP
    ; ================================================ COMMANDS PROCEDURE ===================================;
    CommMenu proc far

        Start:
        ;CALL PowrUpMenu
        ;CALL ExecPwrUp
        
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

        ; Commands (operations) Labels
            NOP_Comm:
                CALL CheckForbidCharProc
                JMP Exit
            
            CLC_Comm:
                CALL CheckForbidCharProc

                CMP p1_CpuEnabled, 1
                JZ CLC_p1
                JMP CLC_p2

                CLC_p1:
                    CLC
                    CALL SetCf

                CLC_p2:
                    MOV p1_CpuEnabled, 0
                    CMP p2_CpuEnabled, 1
                    JNZ Exit
                    CLC
                    CALL SetCF

                JMP Exit
            AND_Comm:
                CALL AND_Comm_PROC
                JMP Exit
            MOV_Comm:
                CALL MOV_Comm_PROC
                JMP Exit
            ADD_Comm:
                CALL ADD_Comm_PROC
                JMP Exit
            ADC_Comm:
                CALL ADC_Comm_PROC
                JMP Exit
            PUSH_Comm:
                CALL PUSH_Comm_PROC
                JMP Exit
            POP_Comm:
                CALL POP_Comm_PROC
                JMP Exit
            INC_Comm:
                CALL INC_Comm_PROC
                JMP Exit
            DEC_Comm:
                CALL DEC_Comm_PROC
                JMP Exit
            MUL_Comm:
                CALL MUL_Comm_PROC
                jmp Exit
            DIV_Comm:
                CALL DIV_Comm_PROC
                jmp Exit
            IMul_Comm:
                CALL IMUL_Comm_PROC
                jmp Exit
            IDiv_Comm:
                CALL IDIV_Comm_PROC
                jmp Exit
            ROR_Comm:
                CALL ROR_Comm_PROC
                JMP Exit
            ROL_Comm:
                CALL ROL_Comm_PROC
                JMP Exit
            RCR_Comm:
                CALL RCR_Comm_PROC
                JMP Exit
            RCL_Comm:
                CALL RCL_Comm_PROC
                JMP Exit
            SHL_Comm:
                CALL SHL_Comm_PROC
                JMP Exit
            SHR_Comm:
                CALL SHR_Comm_PROC
                JMP Exit
            Exit:
            
                CMP isInvalidCommand, 0
                JZ Valid_Command

                InValid_Command:
                    mov dx, offset ExecutionFailed
                    CALL DisplayString

                    DEC Player1_Points

                    CheckKey_Invalid:
                        CALL ClearBuffer
                        CALL WaitKeyPress

                    Push ax
                    PUSH DX
                        CALL ClearBuffer
                    POP DX
                    pop ax
                    
                    cmp ah, EnterScanCode
                    jz CONT_INVALID
                    cmp ah, EscScanCode
                    jz Exit_Invalid

                    jmp CheckKey_Invalid

                    Exit_Invalid:
                        Call Terminate
                    CONT_INVALID:
                        RET

                Valid_Command:

                    lea dx, ExecutedSuccesfully
                    CALL ShowMsg

                    CheckKey_Exit:
                        CALL WaitKeyPress
                    
                    Push ax
                    PUSH DX
                        CALL ClearBuffer
                    POP DX
                    pop ax
                    
                    cmp ah, EnterScanCode
                    jz CONT__Exit
                    cmp ah, EscScanCode
                    jz Exit__Exit

                    jmp CheckKey_Exit

                    Exit__Exit:
                        Call Terminate
                    CONT__Exit:
                        RET


    CommMenu ENDP
    ;================================================================================================================
    ;================================================================================================================
    ;; ---------------------------------- Commands Procedures ----------------------------------- ;;
        AND_Comm_PROC PROC FAR
            CALL Op1Menu
            mov DX, CommaCursorLoc
            CALL SetCursor
            mov dl, ','
            CALL DisplayChar
            CALL Op2Menu

            ;call  PowrUpMenu ; to choose power up
            CALL CheckMemToMem
            CALL CheckForbidCharProc
            CALL CheckSizeMismatch

            CMP isInvalidCommand, 1
            JZ Return_AndCom

            CMP p1_CpuEnabled, 1
            JZ And_p1
            JMP And_p2
            And_p1:
                CALL GetDst

                CMP selectedOp1Size, 16
                JZ p1_AndDst_16BIT
                CMP selectedOp1Size, 8
                JZ p1_AndDst_8BIT
                JMP And_p2

                p1_AndDst_16BIT:
                    CMP selectedOp2Size, 16
                    JZ p1_AndSrc_16_16BIT
                    CMP selectedOp2Size, 8
                    JZ p1_AndSrc_16_8BIT

                    MOV isInValidCommand, 1
                    RET

                    p1_AndSrc_16_16BIT:
                        CALL GetSrcOp
                        CMP isInvalidCommand, 1
                        JZ Return_AndCom
                        AND [DI], AX
                        CALL SetCF
                        JMP And_p2
                    
                    p1_AndSrc_16_8BIT:
                        CALL GetSrcOp_8Bit
                        CMP isInvalidCommand, 1
                        JZ Return_AndCom
                        AND [DI], AL
                        CALL SetCF
                        JMP And_p2
                
                p1_AndDst_8BIT:    
                    CALL GetSrcOp_8Bit
                    CMP isInvalidCommand, 1
                    JZ Return_AndCom
                    AND BYTE PTR [DI], AL
                    CALL SetCF
                    JMP And_p2

            And_p2:
                MOV p1_CpuEnabled, 0
                CMP p2_CpuEnabled, 1
                jnz Return_AndCom

                CALL GetDst

                CMP selectedOp1Size, 16
                JZ p2_AndDst_16BIT
                CMP selectedOp1Size, 8
                JZ p2_AndDst_8BIT
                JMP And_p2

                p2_AndDst_16BIT:
                    CMP selectedOp2Size, 16
                    JZ p2_AndSrc_16_16BIT
                    CMP selectedOp2Size, 8
                    JZ p2_AndSrc_16_8BIT

                    MOV isInValidCommand, 1
                    RET

                    p2_AndSrc_16_16BIT:
                        CALL GetSrcOp
                        CMP isInvalidCommand, 1
                        JZ Return_AndCom
                        AND [DI], AX
                        CALL SetCF
                        JMP Return_AndCom
                    
                    p2_AndSrc_16_8BIT:
                        CALL GetSrcOp_8Bit
                        CMP isInvalidCommand, 1
                        JZ Return_AndCom
                        AND [DI], AL
                        CALL SetCF
                        JMP Return_AndCom
                
                p2_AndDst_8BIT:    
                    CALL GetSrcOp_8Bit
                    CMP isInvalidCommand, 1
                    JZ Return_AndCom
                    AND BYTE PTR [DI], AL
                    CALL SetCF
                    JMP Return_AndCom



            Return_AndCom:
                RET
        ENDP
        MOV_Comm_PROC PROC FAR
            CALL Op1Menu
            mov DX, CommaCursorLoc
            CALL SetCursor
            mov dl, ','
            CALL DisplayChar
            CALL Op2Menu

            ;call  PowrUpMenu ; to choose power up
            CALL CheckMemToMem
            CALL CheckForbidCharProc
            CALL CheckSizeMismatch

            CMP isInvalidCommand, 1
            JZ Return_MovCom

            CMP p1_CpuEnabled, 1
            JZ Mov_p1
            JMP Mov_p2
            Mov_p1:
                CALL GetDst

                CMP selectedOp1Size, 16
                JZ p1_MovDst_16BIT
                CMP selectedOp1Size, 8
                JZ p1_MovDst_8BIT
                JMP Mov_p2

                p1_MovDst_16BIT:
                    CMP selectedOp2Size, 16
                    JZ p1_MovSrc_16_16BIT
                    CMP selectedOp2Size, 8
                    JZ p1_MovSrc_16_8BIT

                    p1_MovSrc_16_16BIT:
                        CALL GetSrcOp
                        CMP isInvalidCommand, 1
                        JZ Return_MovCom
                        Mov [DI], AX
                        JMP Mov_p2
                    
                    p1_MovSrc_16_8BIT:
                        CALL GetSrcOp_8Bit
                        CMP isInvalidCommand, 1
                        JZ Return_MovCom
                        Mov [DI], AL
                        JMP Mov_p2
                
                p1_MovDst_8BIT:    
                    CALL GetSrcOp_8Bit
                    CMP isInvalidCommand, 1
                        JZ Return_MovCom
                    Mov BYTE PTR [DI], AL
                    JMP Mov_p2

            Mov_p2:
                MOV p1_CpuEnabled, 0
                CMP p2_CpuEnabled, 1
                jnz Return_MovCom

                CALL GetDst
                
                CMP selectedOp1Size, 16
                JZ p2_MovDst_16BIT
                CMP selectedOp1Size, 8
                JZ p2_MovDst_8BIT

                p2_MovDst_16BIT:
                    CMP selectedOp2Size, 16
                    JZ p2_MovSrc_16_16BIT
                    CMP selectedOp2Size, 8
                    JZ p2_MovSrc_16_8BIT


                    p2_MovSrc_16_16BIT:
                        CALL GetSrcOp
                        CMP isInvalidCommand, 1
                        JZ Return_MovCom
                        Mov [DI], AX
                        JMP Return_MovCom
                    
                    p2_MovSrc_16_8BIT:
                        CALL GetSrcOp_8Bit
                        
                        CMP isInvalidCommand, 1
                        JZ Return_MovCom
                        Mov [DI], AL
                        JMP Return_MovCom
                
                p2_MovDst_8BIT:    
                    CALL GetSrcOp_8Bit
                    CMP isInvalidCommand, 1
                    JZ Return_MovCom
                    Mov BYTE PTR [DI], AL
                    JMP Return_MovCom



            Return_MovCom:
                RET
        ENDP
        ADD_Comm_PROC PROC FAR
            CALL Op1Menu
            mov DX, CommaCursorLoc
            CALL SetCursor
            mov dl, ','
            CALL DisplayChar
            CALL Op2Menu

            ;call  PowrUpMenu ; to choose power up
            CALL CheckMemToMem
            CALL CheckForbidCharProc
            CALL CheckSizeMismatch

            CMP isInvalidCommand, 1
            JZ Return_AddCom

            CMP p1_CpuEnabled, 1
            JZ Add_p1
            JMP Add_p2
            Add_p1:
                CALL GetDst

                CMP selectedOp1Size, 16
                JZ p1_AddDst_16BIT
                CMP selectedOp1Size, 8
                JZ p1_AddDst_8BIT
                JMP Add_p2

                p1_AddDst_16BIT:
                    CMP selectedOp2Size, 16
                    JZ p1_AddSrc_16_16BIT
                    CMP selectedOp2Size, 8
                    JZ p1_AddSrc_16_8BIT

                    MOV isInValidCommand, 1
                    RET

                    p1_AddSrc_16_16BIT:
                        CALL GetSrcOp
                        CMP isInvalidCommand, 1
                        JZ Return_AddCom
                        Add [DI], AX
                        CALL SetCF
                        JMP Add_p2
                    
                    p1_AddSrc_16_8BIT:
                        CALL GetSrcOp_8Bit
                        CMP isInvalidCommand, 1
                        JZ Return_AddCom
                        Add [DI], AL
                        CALL SetCF
                        JMP Add_p2
                
                p1_AddDst_8BIT:    
                    CALL GetSrcOp_8Bit
                    CMP isInvalidCommand, 1
                    JZ Return_AddCom
                    Add BYTE PTR [DI], AL
                    CALL SetCF
                    JMP Add_p2

            Add_p2:
                MOV p1_CpuEnabled, 0
                CMP p2_CpuEnabled, 1
                jnz Return_AddCom

                CALL GetDst
                
                CMP selectedOp1Size, 16
                JZ p2_AddDst_16BIT
                CMP selectedOp1Size, 8
                JZ p2_AddDst_8BIT
                JMP Add_p2

                p2_AddDst_16BIT:
                    CMP selectedOp2Size, 16
                    JZ p2_AddSrc_16_16BIT
                    CMP selectedOp2Size, 8
                    JZ p2_AddSrc_16_8BIT

                    
                    MOV isInValidCommand, 1
                    RET

                    p2_AddSrc_16_16BIT:
                        CALL GetSrcOp
                        CMP isInvalidCommand, 1
                        JZ Return_AddCom
                        Add [DI], AX
                        CALL SetCF
                        JMP Return_AddCom
                    
                    p2_AddSrc_16_8BIT:
                        CALL GetSrcOp_8Bit
                        CMP isInvalidCommand, 1
                        JZ Return_AddCom
                        Add [DI], AL
                        CALL SetCF
                        JMP Return_AddCom
                
                p2_AddDst_8BIT:    
                    CALL GetSrcOp_8Bit
                    CMP isInvalidCommand, 1
                    JZ Return_AddCom
                    Add BYTE PTR [DI], AL
                    CALL SetCF
                    JMP Return_AddCom



            Return_AddCom:
                RET
        ENDP
        ADC_Comm_PROC PROC FAR

            CALL Op1Menu
            mov DX, CommaCursorLoc
            CALL SetCursor
            mov dl, ','
            CALL DisplayChar
            CALL Op2Menu

            ;call  PowrUpMenu ; to choose power up
            CALL CheckMemToMem
            CALL CheckForbidCharProc
            CALL CheckSizeMismatch

            CMP isInvalidCommand, 1
            JZ Return_AdcCom

            CMP p1_CpuEnabled, 1
            JZ Adc_p1
            JMP Adc_p2
            Adc_p1:
                CALL GetDst

                CMP selectedOp1Size, 16
                JZ p1_AdcDst_16BIT
                CMP selectedOp1Size, 8
                JZ p1_AdcDst_8BIT
                JMP Adc_p2

                p1_AdcDst_16BIT:
                    CMP selectedOp2Size, 16
                    JZ p1_AdcSrc_16_16BIT
                    CMP selectedOp2Size, 8
                    JZ p1_AdcSrc_16_8BIT

                    MOV isInValidCommand, 1
                    RET

                    p1_AdcSrc_16_16BIT:
                        CALL GetSrcOp
                        CMP isInvalidCommand, 1
                        JZ Return_AdcCom
                        CALL GetCF
                        Adc [DI], AX
                        CALL SetCF
                        JMP Adc_p2
                    
                    p1_AdcSrc_16_8BIT:
                        CALL GetSrcOp_8Bit
                        CMP isInvalidCommand, 1
                        JZ Return_AdcCom
                        CALL GetCF
                        Adc [DI], AL
                        CALL SetCF
                        JMP Adc_p2
                
                p1_AdcDst_8BIT:    
                    CALL GetSrcOp_8Bit
                    CMP isInvalidCommand, 1
                    JZ Return_AdcCom
                    CALL GetCF
                    Adc BYTE PTR [DI], AL
                    CALL SetCF
                    JMP Adc_p2

            Adc_p2:
                MOV p1_CpuEnabled, 0
                CMP p2_CpuEnabled, 1
                jnz Return_AdcCom

                CALL GetDst
                
                CMP selectedOp1Size, 16
                JZ p2_AdcDst_16BIT
                CMP selectedOp1Size, 8
                JZ p2_AdcDst_8BIT
                JMP Adc_p2

                p2_AdcDst_16BIT:
                    CMP selectedOp2Size, 16
                    JZ p2_AdcSrc_16_16BIT
                    CMP selectedOp2Size, 8
                    JZ p2_AdcSrc_16_8BIT

                    
                    MOV isInValidCommand, 1
                    RET

                    p2_AdcSrc_16_16BIT:
                        CALL GetSrcOp
                        CMP isInvalidCommand, 1
                        JZ Return_AdcCom
                        CALL GetCF
                        Adc [DI], AX
                        CALL SetCF
                        JMP Return_AdcCom
                    
                    p2_AdcSrc_16_8BIT:
                        CALL GetSrcOp_8Bit
                        CMP isInvalidCommand, 1
                        JZ Return_AdcCom
                        CALL GetCF
                        Adc [DI], AL
                        CALL SetCF
                        JMP Return_AdcCom
                
                p2_AdcDst_8BIT:    
                    CALL GetSrcOp_8Bit
                    CMP isInvalidCommand, 1
                    JZ Return_AdcCom
                    CALL GetCF
                    Adc BYTE PTR [DI], AL
                    CALL SetCF
                    JMP Return_AdcCom



            Return_AdcCom:
                RET
        ENDP
        PUSH_Comm_PROC PROC FAR
            CALL Op2Menu

            CALL CheckForbidCharProc
            CMP isInvalidCommand, 1
            JZ Return_PushCom

            CMP selectedOp2Size, 8
            JNZ ValidSize_Push

            MOV isInvalidCommand, 1
            JMP Return_PushCom

            ValidSize_Push:
                CMP p1_CpuEnabled, 1
                JZ Push_p1
                JMP Push_p2
                Push_p1:
                    CALL GetSrcOp

                    CMP isInvalidCommand, 1
                    JZ Push_p2

                    Mov BX, ourValRegSP
                    MOV ourValStack[BX], AX
                    INC ourValRegSP
                    JMP Push_p2

                    

                Push_p2:
                    MOV p1_CpuEnabled, 0
                    MOV isInvalidCommand, 0
                    CMP p2_CpuEnabled, 1
                    jnz Return_PushCom

                    CALL GetSrcOp

                    CMP isInvalidCommand, 1
                    JZ Return_PushCom

                    Mov BX, ValRegSP
                    MOV ValStack[BX], AX
                    INC ValRegSP

            Return_PushCom:
                RET
            
        ENDP
        POP_Comm_PROC PROC FAR
            CALL Op1Menu

            CALL CheckForbidCharProc
            CMP isInvalidCommand, 1
            JZ Return_POPCom

            CMP selectedOp1Size, 8
            JNZ ValidSize_POP
            
            MOV isInvalidCommand, 1
            JMP Return_POPCom

            ValidSize_POP:
                CMP p1_CpuEnabled, 1
                JZ POP_p1
                JMP POP_p2
                POP_p1:
                    CALL GetDst

                    CMP isInvalidCommand, 1
                    JZ POP_p2

                    Mov BX, ourValRegSP
                    MOV DX, ourValStack[BX]
                    MOV [DI], DX
                    DEC ourValRegSP
                    JMP POP_p2

                POP_p2:
                    MOV p1_CpuEnabled, 0
                    MOV isInvalidCommand, 0
                    CMP p2_CpuEnabled, 1
                    jnz Return_POPCom

                    CALL GetDst

                    CMP isInvalidCommand, 1
                    JZ Return_POPCom

                    Mov BX, ValRegSP
                    MOV DX, ValStack[BX]
                    MOV [DI], DX
                    DEC ValRegSP

            Return_POPCom:
                RET

        ENDP
        INC_Comm_PROC PROC FAR
            CALL Op1Menu

            CALL CheckForbidCharProc
            CMP isInvalidCommand, 1
            JZ Return_IncCom

            CMP p1_CpuEnabled, 1
            JZ Inc_p1
            JMP Inc_p2
            Inc_p1:
                CALL GetDst

                CMP isInvalidCommand, 1
                JZ Inc_p2

                INC [DI]
                
                JMP Inc_p2

            Inc_p2:
                MOV p1_CpuEnabled, 0
                MOV isInvalidCommand, 0
                CMP p2_CpuEnabled, 1
                jnz Return_IncCom

                CALL GetDst

                CMP isInvalidCommand, 1
                JZ Return_IncCom

                
                INC [DI]

            Return_IncCom:
                RET

        ENDP
        DEC_Comm_PROC PROC FAR
            
            CALL Op1Menu

            CALL CheckForbidCharProc
            CMP isInvalidCommand, 1
            JZ Return_DecCom

            CMP p1_CpuEnabled, 1
            JZ Dec_p1
            JMP Dec_p2
            Dec_p1:
                CALL GetDst

                CMP isInvalidCommand, 1
                JZ Dec_p2

                DEC [DI]
                
                JMP Dec_p2

            Dec_p2:
                MOV p1_CpuEnabled, 0
                MOV isInvalidCommand, 0
                CMP p2_CpuEnabled, 1
                jnz Return_DecCom

                CALL GetDst

                CMP isInvalidCommand, 1
                JZ Return_DecCom

                
                DEC [DI]

            Return_DecCom:
                RET

        ENDP
        MUL_Comm_PROC PROC FAR
            CALL Op2Menu

            ;call  PowrUpMenu ; to choose power up
            CALL CheckForbidCharProc
            cmp selectedOp2Type,ValIndex
            jne MUL_righttype
            mov isInvalidCommand, 1
            jmp Return_MUL
            MUL_righttype:
            CMP isInvalidCommand, 1
            Je Return_MUL

            CMP p1_CpuEnabled, 1
            je MUL_p1
            jmp MUL_p2

            MUL_p1:
                cmp selectedOp2Size,16
                je MUL_p1_16bit
                jmp MUL_p1_8bit

                MUL_p1_16bit:
                    call GetSrcOp
                    mov bx,ax
                    call LoadP1Registers
                    mul BX
                    call SetCF
                    call UpdateP1Registers
                    jmp MUL_p2
                MUL_p1_8bit:
                    call GetSrcOp_8Bit
                    mov bl,al
                    call LoadP1Registers
                    mul Bl
                    call SetCF
                    call UpdateP1Registers
                    jmp MUL_p2
            MUL_p2:
                mov p1_CpuEnabled,0
                cmp p2_CpuEnabled,1
                jne Return_MUL
                cmp selectedOp2Size,16
                je MUL_p2_16bit
                jmp MUL_p2_8bit
                MUL_p2_16bit:
                    call GetSrcOp
                    mov bx,ax
                    call LoadP2Registers
                    mul BX
                    call SetCF
                    call UpdateP2Registers
                    jmp Return_MUL
                MUL_p2_8bit:
                    call GetSrcOp_8Bit
                    mov bl,al
                    call LoadP2Registers
                    mul Bl
                    call SetCF
                    call UpdateP2Registers
            Return_MUL:
            RET
        ENDP
        DIV_Comm_PROC PROC FAR
        CALL Op2Menu

        ;call  PowrUpMenu ; to choose power up
        CALL CheckForbidCharProc
        cmp selectedOp2Type,ValIndex
        jne DIV_righttype
        mov isInvalidCommand, 1
        jmp Return_DIV
        DIV_righttype:
        CMP isInvalidCommand, 1
        Je Return_DIV

        CMP p1_CpuEnabled, 1
        je DIV_p1
        jmp DIV_p2

        DIV_p1:
            cmp selectedOp2Size,16
            je DIV_p1_16bit
            jmp DIV_p1_8bit

            DIV_p1_16bit:
                call GetSrcOp
                mov bx,ax
                call LoadP1Registers
                cmp bx,0
                je Return_DIV
                DIV BX
                call SetCF
                call UpdateP1Registers
                jmp DIV_p2
            DIV_p1_8bit:
                call GetSrcOp_8Bit
                mov bl,al
                call LoadP1Registers
                cmp bl,0
                je Return_DIV
                DIV Bl
                call SetCF
                call UpdateP1Registers
                jmp DIV_p2
        DIV_p2:
            mov p1_CpuEnabled,0
            cmp p2_CpuEnabled,1
            jne Return_DIV
            cmp selectedOp2Size,16
            je DIV_p2_16bit
            jmp DIV_p2_8bit
            DIV_p2_16bit:
                call GetSrcOp
                mov bx,ax
                call LoadP2Registers
                cmp bx,0
                je Return_DIV
                DIV BX
                call SetCF
                call UpdateP2Registers
                jmp Return_DIV
            DIV_p2_8bit:
                call GetSrcOp_8Bit
                mov bl,al
                call LoadP2Registers
                cmp bl,0
                je Return_DIV
                DIV Bl
                call SetCF
                call UpdateP2Registers
        Return_DIV:
        RET
        ENDP
        IMUL_Comm_PROC PROC FAR
            CALL Op2Menu

            ;call  PowrUpMenu ; to choose power up
            CALL CheckForbidCharProc
            cmp selectedOp2Type,ValIndex
            jne IMUL_righttype
            mov isInvalidCommand, 1
            jmp Return_IMUL
            IMUL_righttype:
            CMP isInvalidCommand, 1
            Je Return_IMUL

            CMP p1_CpuEnabled, 1
            je IMUL_p1
            jmp IMUL_p2

            IMUL_p1:
                cmp selectedOp2Size,16
                je IMUL_p1_16bit
                jmp IMUL_p1_8bit

                IMUL_p1_16bit:
                    call GetSrcOp
                    mov bx,ax
                    call LoadP1Registers
                    IMUL BX
                    call SetCF
                    call UpdateP1Registers
                    jmp IMUL_p2
                IMUL_p1_8bit:
                    call GetSrcOp_8Bit
                    mov bl,al
                    call LoadP1Registers
                    IMUL Bl
                    call SetCF
                    call UpdateP1Registers
                    jmp IMUL_p2
            IMUL_p2:
                mov p1_CpuEnabled,0
                cmp p2_CpuEnabled,1
                jne Return_IMUL
                cmp selectedOp2Size,16
                je IMUL_p2_16bit
                jmp IMUL_p2_8bit
                IMUL_p2_16bit:
                    call GetSrcOp
                    mov bx,ax
                    call LoadP2Registers
                    IMUL BX
                    call SetCF
                    call UpdateP2Registers
                    jmp Return_IMUL
                IMUL_p2_8bit:
                    call GetSrcOp_8Bit
                    mov bl,al
                    call LoadP2Registers
                    IMUL Bl
                    call SetCF
                    call UpdateP2Registers
            Return_IMUL:
            RET
        ENDP
        IDIV_Comm_PROC PROC FAR
        CALL Op2Menu

        ;call  PowrUpMenu ; to choose power up
        CALL CheckForbidCharProc
        cmp selectedOp2Type,ValIndex
        jne IDIV_righttype
        mov isInvalidCommand, 1
        jmp Return_IDIV
        IDIV_righttype:
        CMP isInvalidCommand, 1
        Je Return_IDIV

        CMP p1_CpuEnabled, 1
        je IDIV_p1
        jmp IDIV_p2

        IDIV_p1:
            cmp selectedOp2Size,16
            je IDIV_p1_16bit
            jmp IDIV_p1_8bit

            IDIV_p1_16bit:
                call GetSrcOp
                mov bx,ax
                call LoadP1Registers
                cmp bx,0
                je Return_IDIV
                IDIV BX
                call SetCF
                call UpdateP1Registers
                jmp IDIV_p2
            IDIV_p1_8bit:
                call GetSrcOp_8Bit
                mov bl,al
                call LoadP1Registers
                cmp bl,0
                je Return_IDIV
                IDIV Bl
                call SetCF
                call UpdateP1Registers
                jmp IDIV_p2
        IDIV_p2:
            mov p1_CpuEnabled,0
            cmp p2_CpuEnabled,1
            jne Return_IDIV
            cmp selectedOp2Size,16
            je IDIV_p2_16bit
            jmp IDIV_p2_8bit
            IDIV_p2_16bit:
                call GetSrcOp
                mov bx,ax
                call LoadP2Registers
                cmp bx,0
                je Return_IDIV
                IDIV BX
                call SetCF
                call UpdateP2Registers
                jmp Return_IDIV
            IDIV_p2_8bit:
                call GetSrcOp_8Bit
                mov bl,al
                call LoadP2Registers
                cmp bl,0
                je Return_IDIV
                IDIV Bl
                call SetCF
                call UpdateP2Registers
        Return_IDIV:
        RET
        ENDP
        ROR_Comm_PROC PROC FAR
            CALL Op1Menu
            mov DX, CommaCursorLoc
            CALL SetCursor
            mov dl, ','
            CALL DisplayChar
            CALL Op2Menu

            cmp selectedOp2Type,RegIndex
            je check_ROR_reg
            cmp selectedOp2Type,ValIndex
            je check_ROR_val
            mov isInvalidCommand,1
            jmp Return_ROR

            check_ROR_reg:
                cmp selectedOp2Reg, 7
                je ROR_right
                mov isInvalidCommand,1
                jmp Return_ROR
            check_ROR_val:
                cmp Op2Val,255d
                jle ROR_right
                mov isInvalidCommand,1
                jmp Return_ROR
            
            ROR_right:
            CALL CheckForbidCharProc
            cmp isInvalidCommand,1
            je Return_ROR

            cmp p1_CpuEnabled,1
            je ROR_p1
            jmp ROR_p2

            ROR_p1:
                CALL GetDst
                CALL GetSrcOp_8Bit
                mov cl,al
                cmp selectedOp1Size,8
                jne ROR_p1_16bit
                ROR BYTE PTR [di],cl
                call SetCF
                jmp ROR_p2
                ROR_p1_16bit:
                ROR [di],cl
                call SetCF
                jmp ROR_p2
            ROR_p2:
                mov p1_CpuEnabled,0
                cmp p2_CpuEnabled,1
                jne Return_ROR
                call GetDst
                call GetSrcOp_8Bit
                mov cl,AL
                cmp selectedOp1Size,8
                jne ROR_p2_16bit
                ROR BYTE PTR [di],cl
                call SetCF
                jmp Return_ROR
                ROR_p2_16bit:
                ROR [di],cl
                call SetCF
            Return_ROR:
            RET
        ENDP
        ROL_Comm_PROC PROC FAR
            CALL Op1Menu
            mov DX, CommaCursorLoc
            CALL SetCursor
            mov dl, ','
            CALL DisplayChar
            CALL Op2Menu

            cmp selectedOp2Type,RegIndex
            je check_ROL_reg
            cmp selectedOp2Type,ValIndex
            je check_ROL_val
            mov isInvalidCommand,1
            jmp Return_ROL

            check_ROL_reg:
                cmp selectedOp2Reg, 7
                je ROL_right
                mov isInvalidCommand,1
                jmp Return_ROL
            check_ROL_val:
                cmp Op2Val,255d
                jle ROL_right
                mov isInvalidCommand,1
                jmp Return_ROL
            
            ROL_right:
            CALL CheckForbidCharProc
            cmp isInvalidCommand,1
            je Return_ROL

            cmp p1_CpuEnabled,1
            je ROL_p1
            jmp ROL_p2

            ROL_p1:
                CALL GetDst
                CALL GetSrcOp_8Bit
                mov cl,al
                cmp selectedOp1Size,8
                jne ROL_p1_16bit
                ROL BYTE PTR [di],cl
                call SetCF
                jmp ROL_p2
                ROL_p1_16bit:
                ROL [di],cl
                call SetCF
                jmp ROL_p2
            ROL_p2:
                mov p1_CpuEnabled,0
                cmp p2_CpuEnabled,1
                jne Return_ROL
                call GetDst
                call GetSrcOp_8Bit
                mov cl,AL
                cmp selectedOp1Size,8
                jne ROL_p2_16bit
                ROL BYTE PTR [di],cl
                call SetCF
                jmp Return_ROL
                ROL_p2_16bit:
                ROL [di],cl
                call SetCF
            Return_ROL:
            RET
        ENDP
        SHL_Comm_PROC PROC FAR
            CALL Op1Menu
            mov DX, CommaCursorLoc
            CALL SetCursor
            mov dl, ','
            CALL DisplayChar
            CALL Op2Menu

            cmp selectedOp2Type,RegIndex
            je check_SHL_reg
            cmp selectedOp2Type,ValIndex
            je check_SHL_val
            mov isInvalidCommand,1
            jmp Return_SHL

            check_SHL_reg:
                cmp selectedOp2Reg, 7
                je SHL_right
                mov isInvalidCommand,1
                jmp Return_SHL
            check_SHL_val:
                cmp Op2Val,255d
                jle SHL_right
                mov isInvalidCommand,1
                jmp Return_SHL
            
            SHL_right:
            CALL CheckForbidCharProc
            cmp isInvalidCommand,1
            je Return_SHL

            cmp p1_CpuEnabled,1
            je SHL_p1
            jmp SHL_p2

            SHL_p1:
                CALL GetDst
                CALL GetSrcOp_8Bit
                mov cl,al
                cmp selectedOp1Size,8
                jne SHL_p1_16bit
                SHL BYTE PTR [di],cl
                call SetCF
                jmp SHL_p2
                SHL_p1_16bit:
                SHL [di],cl
                call SetCF
                jmp SHL_p2
            SHL_p2:
                mov p1_CpuEnabled,0
                cmp p2_CpuEnabled,1
                jne Return_SHL
                call GetDst
                call GetSrcOp_8Bit
                mov cl,AL
                cmp selectedOp1Size,8
                jne SHL_p2_16bit
                SHL BYTE PTR [di],cl
                call SetCF
                jmp Return_SHL
                SHL_p2_16bit:
                SHL [di],cl
                call SetCF
            Return_SHL:
            RET
        ENDP
        SHR_Comm_PROC PROC FAR
            CALL Op1Menu
            mov DX, CommaCursorLoc
            CALL SetCursor
            mov dl, ','
            CALL DisplayChar
            CALL Op2Menu

            cmp selectedOp2Type,RegIndex
            je check_SHR_reg
            cmp selectedOp2Type,ValIndex
            je check_SHR_val
            mov isInvalidCommand,1
            jmp Return_SHR

            check_SHR_reg:
                cmp selectedOp2Reg, 7
                je SHR_right
                mov isInvalidCommand,1
                jmp Return_SHR
            check_SHR_val:
                cmp Op2Val,255d
                jle SHR_right
                mov isInvalidCommand,1
                jmp Return_SHR
            
            SHR_right:
            CALL CheckForbidCharProc
            cmp isInvalidCommand,1
            je Return_SHR

            cmp p1_CpuEnabled,1
            je SHR_p1
            jmp SHR_p2

            SHR_p1:
                CALL GetDst
                CALL GetSrcOp_8Bit
                mov cl,al
                cmp selectedOp1Size,8
                jne SHR_p1_16bit
                SHR BYTE PTR [di],cl
                call SetCF
                jmp SHR_p2
                SHR_p1_16bit:
                SHR [di],cl
                call SetCF
                jmp SHR_p2
            SHR_p2:
                mov p1_CpuEnabled,0
                cmp p2_CpuEnabled,1
                jne Return_SHR
                call GetDst
                call GetSrcOp_8Bit
                mov cl,AL
                cmp selectedOp1Size,8
                jne SHR_p2_16bit
                SHR BYTE PTR [di],cl
                call SetCF
                jmp Return_SHR
                SHR_p2_16bit:
                SHR [di],cl
                call SetCF
            Return_SHR:
            RET
        ENDP
        RCR_Comm_PROC PROC FAR
            CALL Op1Menu
            mov DX, CommaCursorLoc
            CALL SetCursor
            mov dl, ','
            CALL DisplayChar
            CALL Op2Menu

            cmp selectedOp2Type,RegIndex
            je check_RCR_reg
            cmp selectedOp2Type,ValIndex
            je check_RCR_val
            mov isInvalidCommand,1
            jmp Return_RCR

            check_RCR_reg:
                cmp selectedOp2Reg, 7
                je RCR_right
                mov isInvalidCommand,1
                jmp Return_RCR
            check_RCR_val:
                cmp Op2Val,255d
                jle RCR_right
                mov isInvalidCommand,1
                jmp Return_RCR
            
            RCR_right:
            CALL CheckForbidCharProc
            cmp isInvalidCommand,1
            je Return_RCR

            cmp p1_CpuEnabled,1
            je RCR_p1
            jmp RCR_p2

            RCR_p1:
                CALL GetDst
                CALL GetSrcOp_8Bit
                mov cl,al
                cmp selectedOp1Size,8
                jne RCR_p1_16bit
                call GetCF
                RCR BYTE PTR [di],cl
                call SetCF
                jmp RCR_p2
                RCR_p1_16bit:
                call GetCF
                RCR [di],cl
                call SetCF
                jmp RCR_p2
            RCR_p2:
                mov p1_CpuEnabled,0
                cmp p2_CpuEnabled,1
                jne Return_RCR
                call GetDst
                call GetSrcOp_8Bit
                mov cl,AL
                cmp selectedOp1Size,8
                jne RCR_p2_16bit
                call GetCF
                RCR BYTE PTR [di],cl
                call SetCF
                jmp Return_RCR
                RCR_p2_16bit:
                call GetCF
                RCR [di],cl
                call SetCF
            Return_RCR:
            RET
        ENDP
        RCL_Comm_PROC PROC FAR
            CALL Op1Menu
            mov DX, CommaCursorLoc
            CALL SetCursor
            mov dl, ','
            CALL DisplayChar
            CALL Op2Menu

            cmp selectedOp2Type,RegIndex
            je check_RCL_reg
            cmp selectedOp2Type,ValIndex
            je check_RCL_val
            mov isInvalidCommand,1
            jmp Return_RCL

            check_RCL_reg:
                cmp selectedOp2Reg, 7
                je RCL_right
                mov isInvalidCommand,1
                jmp Return_RCL
            check_RCL_val:
                cmp Op2Val,255d
                jle RCL_right
                mov isInvalidCommand,1
                jmp Return_RCL
            
            RCL_right:
            CALL CheckForbidCharProc
            cmp isInvalidCommand,1
            je Return_RCL

            cmp p1_CpuEnabled,1
            je RCL_p1
            jmp RCL_p2

            RCL_p1:
                CALL GetDst
                CALL GetSrcOp_8Bit
                mov cl,al
                cmp selectedOp1Size,8
                jne RCL_p1_16bit
                call GetCF
                RCL BYTE PTR [di],cl
                call SetCF
                jmp RCL_p2
                RCL_p1_16bit:
                call GetCF
                RCL [di],cl
                call SetCF
                jmp RCL_p2
            RCL_p2:
                mov p1_CpuEnabled,0
                cmp p2_CpuEnabled,1
                jne Return_RCL
                call GetDst
                call GetSrcOp_8Bit
                mov cl,AL
                cmp selectedOp1Size,8
                jne RCL_p2_16bit
                call GetCF
                RCL BYTE PTR [di],cl
                call SetCF
                jmp Return_RCL
                RCL_p2_16bit:
                call GetCF
                RCL [di],cl
                call SetCF
            Return_RCL:
            RET
        ENDP
        
    ;; ------------------------------ Commands Helper Procedures -------------------------------- ;;
        ;; -------------------------- Menus Procedures ------------------------- ;;
            MnemonicMenu PROC
                
                ; Reset Cursor
                    mov ah,2
                    mov dx, MenmonicCursorLoc
                    int 10h

                ; Display Command
                DisplayComm:
                    CALL ClearBuffer
                    mov ah, 9
                    mov dx, offset ADDcom
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
                jmp CheckKeyComType


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
            Op1TypeMenu PROC

                mov ah, 9
                mov dx, offset Reg
                int 21h

                CheckKeyOp1Type:
                    CALL ClearBuffer
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
                JMP CheckKeyOp1Type


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
            Op2TypeMenu PROC

                
                mov ah, 9
                mov dx, offset Reg
                int 21h

                CheckKey_Op2Type:
                    CALL ClearBuffer
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
                JMP CheckKey_Op2Type


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
                        CALL ClearBuffer
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
                    jmp CheckKeyRegType


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
                        CALL ClearBuffer
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
                    jmp CheckKey_AddReg


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
                        CALL ClearBuffer
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
                    jmp CheckKeyMemType


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

                    ; Clear the space which the user should enter thep2_Value into
                    mov dx, offset ClearSpace
                    CALL DisplayString

                    ; Reset Cursor
                    mov dx, Op1CursorLoc
                    CALL SetCursor

                    CALL ClearBuffer
                    

                    ; Takep2_Value as a String from User
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
                        cmp cl,4         ;check thatp2_Value is hexa or Get error    
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
                    CALL CheckOp1Size
                    RET
            Op1Menu ENDP
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
                        CALL ClearBuffer
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
                    jmp CheckKey_RegType_Op2Menu


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
                        CALL ClearBuffer
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
                    jz Selected_AddReg_Op2Menu
                    jmp CheckKey_AddReg_Op2Menu


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
                        CALL ClearBuffer
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
                    jmp CheckKey_MemType_Op2Menu


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

                    ; Clear the space which the user should enter thep2_Value into
                    mov dx, offset ClearSpace
                    CALL DisplayString

                    ; Reset Cursor
                    mov dx, Op2CursorLoc
                    CALL SetCursor

                    CALL ClearBuffer

                    ; Takep2_Value as a String from User
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
                        cmp cl,4         ;check thatp2_Value is hexa or Get error    
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
                        MOV isInValidCommand, 1
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
            
            PowrUpMenu PROC
                ; Reset Cursor
                mov ah,2
                mov dx, PUPCursorLoc
                int 10h
                    
                mov ah, 9
                mov dx, offset NOPUP
                int 21h

                CheckKeyOp1Type2:
                    ;CALL ClearBuffer
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
                JMP CheckKeyOp1Type2


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
            PowrUpMenu ENDP
            StuckIndexSubMenu PROC FAR
                ; Reset Cursor
                    mov ah,2
                    mov dx, PUPCursorLoc
                    int 10h
                    
                mov ah, 9
                mov dx, offset DataIndex0
                int 21h

                CheckKeyOp1Type_DataIndex:
                    CALL ClearBuffer
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
                jz CommUp_DataIndex 
                cmp ah, DownArrowScanCode
                jz CommDown_DataIndex 
                cmp ah, EnterScanCode
                jz Selected_DataIndex 
                JMP CheckKeyOp1Type_DataIndex


                CommUp_DataIndex:
                    mov ah, 9
                    ; Check overflow
                        cmp dx, offset DataIndex0     ; Power Up firstChoiceLoc
                        jnz NotOverflow_DataIndex 
                        mov dx, offset DataIndex15           ; Power Up LastChoiceLoc
                        add dx, SubPwrUpSize
                    NotOverflow_DataIndex:
                        sub dx, SubPwrUpSize
                        int 21h
                        jmp CheckKeyOp1Type_DataIndex
                
                CommDown_DataIndex :
                    mov ah, 9
                    ; Check End of file
                        cmp dx, offset DataIndex15          ; Power Up LastChoiceLoc
                        jnz NotEOF_DataIndex
                        mov dx, offset DataIndex0
                        sub dx, SubPwrUpSize
                    NotEOF_DataIndex:
                        add dx, SubPwrUpSize
                        int 21h
                        jmp CheckKeyOp1Type_DataIndex
                
                Selected_DataIndex :
                    ; Detecting index of selected command
                    mov ax, dx
                    sub ax, offset DataIndex0         ; Op1FirstChoiceLoc
                    mov bl, SubPwrUpSize
                    div bl                                      ; Op=byte: AL:=AX / Op 
                    mov opponentPwrUpDataLineIndex, AL
                    

                RET
            ENDP
            StuckValSubMenu PROC FAR
                ; Reset Cursor
                    mov ah,2
                    mov dx, PUPCursorLoc
                    int 10h
                    
                mov ah, 9
                mov dx, offset StuckVal0
                int 21h

                CheckKeyOp1Type_StuckVal:
                    CALL ClearBuffer
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
                jz CommUp_StuckVal 
                cmp ah, DownArrowScanCode
                jz CommDown_StuckVal 
                cmp ah, EnterScanCode
                jz Selected_StuckVal 
                JMP CheckKeyOp1Type_StuckVal


                CommUp_StuckVal:
                    mov ah, 9
                    ; Check overflow
                        cmp dx, offset StuckVal0     ; Power Up firstChoiceLoc
                        jnz NotOverflow_StuckVal 
                        mov dx, offset StuckVal1           ; Power Up LastChoiceLoc
                        add dx, SubPwrUpSize
                    NotOverflow_StuckVal:
                        sub dx, SubPwrUpSize
                        int 21h
                        jmp CheckKeyOp1Type_StuckVal
                
                CommDown_StuckVal :
                    mov ah, 9
                    ; Check End of file
                        cmp dx, offset StuckVal1          ; Power Up LastChoiceLoc
                        jnz NotEOF_StuckVal
                        mov dx, offset StuckVal0
                        sub dx, SubPwrUpSize
                    NotEOF_StuckVal:
                        add dx, SubPwrUpSize
                        int 21h
                        jmp CheckKeyOp1Type_StuckVal
                
                Selected_StuckVal :
                    ; Detecting index of selected command
                    mov ax, dx
                    sub ax, offset StuckVal0         ; Op1FirstChoiceLoc
                    mov bl, SubPwrUpSize
                    div bl                                      ; Op=byte: AL:=AX / Op 
                    mov opponentPwrUpStuckVal, AL
                    

                RET
            ENDP
            
        ;; -------------------------- Getters Procedures ----------------------- ;;
            GetDst PROC FAR  ; offset of the operand is saved in di, destination is called by op1 menu. Call the procedure twice to get the next value if two cpus are enabled
                ; Saving values of AX
                    PUSH AX
                CMP selectedOp1Type, 0
                JZ DstOp1Reg
                CMP selectedOp1Type, 1
                JZ DstOp1AddReg
                CMP selectedOp1Type, 2
                JZ DstOp1Mem

                MOV isInValidCommand, 1
                JMP RETURN_DstSrc
                
                DstOp1Reg:
                    CMP selectedOp1Reg, 0
                    JZ DstOp1RegAX
                    CMP selectedOp1Reg, 1
                    JZ DstOp1RegAX
                    CMP selectedOp1Reg, 2
                    JZ DstOp1RegAH


                    CMP selectedOp1Reg, 3
                    JZ DstOp1RegBX
                    CMP selectedOp1Reg, 4
                    JZ DstOp1RegBX
                    CMP selectedOp1Reg, 5
                    JZ DstOp1RegBH


                    CMP selectedOp1Reg, 6
                    JZ DstOp1RegCX
                    CMP selectedOp1Reg, 7
                    JZ DstOp1RegCX
                    CMP selectedOp1Reg, 8
                    JZ DstOp1RegCH

                    CMP selectedOp1Reg, 9
                    JZ DstOp1RegDX
                    CMP selectedOp1Reg, 8
                    JZ DstOp1RegDX
                    CMP selectedOp1Reg, 10
                    JZ DstOp1RegDH

                    CMP selectedOp1Reg, 15
                    JZ DstOp1RegBP
                    CMP selectedOp1Reg, 16
                    JZ DstOp1RegSP
                    CMP selectedOp1Reg, 17
                    JZ DstOp1RegSI
                    CMP selectedOp1Reg, 18
                    JZ DstOp1RegDI

                    MOV isInValidCommand, 1
                    JMP RETURN_DstSrc

                    DstOp1RegAX:
                        DstOpReg ourValRegAX, ValRegAX

                    DstOp1RegAH:
                        DstOpReg ourValRegAX+1, ValRegAX+1

                    DstOp1RegBX:
                        DstOpReg ourValRegBX, ValRegBX

                    DstOp1RegBH:
                        DstOpReg ourValRegBX+1, ValRegBX+1

                    DstOp1RegCX:
                        DstOpReg ourValRegCX, ValRegCX

                    DstOp1RegCH:
                        DstOpReg ourValRegCX+1, ValRegCX+1
                    
                    DstOp1RegDX:
                        DstOpReg ourValRegDX, ValRegDX

                    DstOp1RegDH:
                        DstOpReg ourValRegDX+1, ValRegDX+1

                    DstOp1RegBP:
                        DstOpReg ourValRegBP, ValRegBP

                    DstOp1RegSP:
                        DstOpReg ourValRegSP, ValRegSP

                    DstOp1RegSI:
                        DstOpReg ourValRegSI, ValRegSI

                    DstOp1RegDI:
                        DstOpReg ourValRegDI, ValRegDI
                    


                DstOp1AddReg:

                    CMP selectedOp1AddReg, 3
                    JZ DstOp1AddRegBX
                    CMP selectedOp1AddReg, 15
                    JZ DstOp1AddRegBP
                    CMP selectedOp1AddReg, 17
                    JZ DstOp1AddRegSI
                    CMP selectedOp1AddReg, 18
                    JZ DstOp1AddRegDI

                    MOV isInValidCommand, 1
                    JMP RETURN_DstSrc

                    DstOp1AddRegBX:
                        DstOpAddReg ourValRegBX, ValRegBX
                    DstOp1AddRegBP:
                        DstOpAddReg ourValRegBP, ValRegBP
                    DstOp1AddRegSI:
                        DstOpAddReg ourValRegSI, ValRegSI
                    DstOp1AddRegDI:
                        DstOpAddReg ourValRegDI, ValRegDI

                DstOp1Mem:

                    MOV BX, 0
                    SearchForMem_GetDst: 
                        CMP selectedOp1Mem, BL
                        JNE NextMem_GetDst

                        CMP p1_CpuEnabled, 1
                        JZ p1_DstMem
                        CMP p2_CpuEnabled, 1
                        JZ p2_DstMem
                        JMP RETURN_DstSrc

                        p1_DstMem:
                            LEA DI, ourValMem[BX]      ;command
                            JMP RETURN_DstSrc
                        
                        p2_DstMem:
                            LEA DI, ValMem[BX]      ;command
                            JMP RETURN_DstSrc


                        NextMem_GetDst:
                            INC BX
                            CMP BX, 16
                            JZ EndSearch_GetDst
                    jmp SearchForMem_GetDst
                    EndSearch_GetDst:
                        MOV isInValidCommand, 1
                        JMP RETURN_DstSrc


                RETURN_DstSrc:
                    ; Saving values of AX
                        POP AX
                    RET
            GetDst ENDP

            GetSrcOp PROC    ; Returned Value is saved in AX, CALL TWICE IF Command is executed on BOTH CPUS
                ; Saving values of DI
                    PUSH DI
                CMP selectedOp2Type, 0
                JZ SrcOp2Reg
                CMP selectedOp2Type, 1
                JZ SrcOp2AddReg
                CMP selectedOp2Type, 2
                JZ SrcOp2Mem
                CMP selectedOp2Type, 3
                JZ SrcOp2Val

                MOV isInValidCommand, 1
                JMP RETURN_GetSrcOp

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

                    MOV isInValidCommand, 1
                    JMP RETURN_GetSrcOp

                    SrcOp2RegAX:
                        SrcOpReg ourValRegAX, ValRegAX
                    SrcOp2RegBX:
                        SrcOpReg ourValRegBX, ValRegBX
                    SrcOp2RegCX:
                        SrcOpReg ourValRegCX, ValRegCX
                    SrcOp2pRegDX:
                        SrcOpReg ourValRegDX, ValRegDX
                    SrcOp2RegBP:
                        SrcOpReg ourValRegBP, ValRegBP
                    SrcOp2RegSP:
                        SrcOpReg ourValRegSP, ValRegSP
                    SrcOp2RegSI:
                        SrcOpReg ourValRegSI, ValRegSI
                    SrcOp2RegDI:
                        SrcOpReg ourValRegDI, ValRegDI
                    


                SrcOp2AddReg:
                    CMP selectedOp2AddReg, 3
                    JZ SrcOp2AddRegBX
                    CMP selectedOp2AddReg, 15
                    JZ SrcOp2AddRegBP
                    CMP selectedOp2AddReg, 17
                    JZ SrcOp2AddRegSI
                    CMP selectedOp2AddReg, 18
                    JZ SrcOp2AddRegDI

                    MOV isInValidCommand, 1
                    JMP RETURN_GetSrcOp

                    SrcOp2AddRegBX:
                        SrcOpAddReg ourValRegBX, ValRegBX
                    SrcOp2AddRegBP:
                        
                        SrcOpAddReg ourValRegBP, ValRegBP
                    SrcOp2AddRegSI:
                        SrcOpAddReg ourValRegSI, ValRegSI
                    SrcOp2AddRegDI:
                        SrcOpAddReg ourValRegDI, ValRegDI

                SrcOp2Mem:

                    MOV BX, 0
                    SearchForMem_GetSrc: 
                        CMP selectedOp2Mem, BL
                        JNE NextMem_GetSrc

                        CMP p1_CpuEnabled, 1
                        JZ p1_GetSrc
                        CMP p2_CpuEnabled, 1
                        JZ p2_GetSrc
                        JMP RETURN_GetSrcOp

                        p1_GetSrc:
                            MOV AX, WORD PTR ourValMem[BX]      ;command
                            JMP RETURN_GetSrcOp
                        
                        p2_GetSrc:
                            MOV AX, WORD PTR ValMem[BX]      ;command
                            JMP RETURN_GetSrcOp


                        NextMem_GetSrc:
                            INC BX
                            CMP BX, 16
                            JZ EndSearch_GetSrc
                    jmp SearchForMem_GetSrc
                    EndSearch_GetSrc:
                        MOV isInValidCommand, 1
                        JMP RETURN_GetSrcOp

                SrcOp2Val:
                    CMP Op2Valid, 1
                    JZ ValidVal_GetSrc
                    MOV isInValidCommand, 1
                    ValidVal_GetSrc:
                        MOV AX, Op2Val
                        JMP RETURN_GetSrcOp

                RETURN_GetSrcOp:
                    CALL LineStuckPwrUp
                    ; Saving values of DI
                        POP DI
                    RET

            GetSrcOp ENDP
            GetSrcOp_8Bit PROC    ; Returned Value is saved in AL
                ; Saving values of DI
                    PUSH DI

                CMP selectedOp2Type, 0
                JZ SrcOp2Reg_8Bit
                CMP selectedOp2Type, 1
                JZ SrcOp2AddReg_8Bit
                CMP selectedOp2Type, 2
                JZ SrcOp2Mem_8Bit
                CMP selectedOp2Type, 3
                JZ SrcOp2Val_8Bit
                MOV isInValidCommand, 1
                JMP RETURN_GetSrcOp_8Bit

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

                    MOV isInValidCommand, 1
                    JMP RETURN_GetSrcOp_8Bit

                    SrcOp2RegAL_8Bit:
                        SrcOpReg_8bit ourValRegAX, ValRegAX
                    SrcOp2RegAH_8Bit:
                        SrcOpReg_8bit ourValRegAX+1, ValRegAX+1
                    SrcOp2RegBL_8Bit:
                        SrcOpReg_8bit ourValRegBX, ValRegBX
                    SrcOp2RegBH_8Bit:
                        SrcOpReg_8bit ourValRegBX+1, ValRegBX+1
                    SrcOp2RegCL_8Bit:
                        SrcOpReg_8bit ourValRegCX, ValRegCX
                    SrcOp2RegCH_8Bit:
                        SrcOpReg_8bit ourValRegCX+1, ValRegCX+1
                    SrcOp2RegDL_8Bit:
                        SrcOpReg_8bit ourValRegDX, ValRegDX
                    SrcOp2RegDH_8Bit:
                        SrcOpReg_8bit ourValRegDX+1, ValRegDX+1
                    


                SrcOp2AddReg_8Bit:

                    CMP selectedOp2AddReg, 3
                    JZ SrcOp2AddRegBX_8Bit
                    CMP selectedOp2AddReg, 15
                    JZ SrcOp2AddRegBP_8Bit
                    CMP selectedOp2AddReg, 17
                    JZ SrcOp2AddRegSI_8Bit
                    CMP selectedOp2AddReg, 18
                    JZ SrcOp2AddRegDI_8Bit

                    MOV isInValidCommand, 1
                    JMP RETURN_GetSrcOp_8Bit

                    SrcOp2AddRegBX_8Bit:
                        SrcOpAddReg_8bit ourValRegBX, ValRegBX
                    SrcOp2AddRegBP_8Bit:
                        SrcOpAddReg_8bit ourValRegBP, ValRegBP
                    SrcOp2AddRegSI_8Bit:
                        SrcOpAddReg_8bit ourValRegSI, ValRegSI
                    SrcOp2AddRegDI_8Bit:
                        SrcOpAddReg_8Bit ourValRegDI, ValRegDI

                SrcOp2Mem_8Bit:

                    MOV BX, 0
                    SearchForMem_GetSrc_8BIT: 
                        CMP selectedOp2Mem, BL
                        JNE NextMem_GetSrc_8BIT

                        CMP p1_CpuEnabled, 1
                        JZ p1_GetSrc_8BIT
                        CMP p2_CpuEnabled, 1
                        JZ p2_GetSrc_8BIT
                        JMP RETURN_GetSrcOp_8Bit

                        p1_GetSrc_8BIT:
                            MOV AL, ourValMem[BX]      ;command
                            JMP RETURN_GetSrcOp_8Bit
                        
                        p2_GetSrc_8BIT:
                            MOV AL, ValMem[BX]      ;command
                            JMP RETURN_GetSrcOp_8Bit


                        NextMem_GetSrc_8BIT:
                            INC BX
                            CMP BX, 16
                            JZ EndSearch_GetSrc_8BIT
                    jmp SearchForMem_GetSrc_8BIT
                    EndSearch_GetSrc_8BIT:
                        MOV isInValidCommand, 1
                        JMP RETURN_GetSrcOp_8Bit

                SrcOp2Val_8Bit:
                    CMP Op2Valid, 1
                    JZ ValidVal_GetSrc_8BIT
                    MOV isInValidCommand, 1
                    ValidVal_GetSrc_8BIT:
                        MOV AL, BYTE PTR Op2Val
                        JMP RETURN_GetSrcOp_8Bit
                
                RETURN_GetSrcOp_8Bit:
                    CALL LineStuckPwrUp
                    ; Saving values of DI
                        POP DI
                    RET
            GetSrcOp_8Bit ENDP
            SetCF PROC
                PUSH BX
                    CMP p1_CpuEnabled, 1
                    JZ p1_SetCF
                    CMP p2_CpuEnabled, 1
                    JZ p2_SetCF

                    JMP Return_SetCF

                    p1_SetCF:
                        MOV BL, 0
                        ADC BL, 0
                        MOV ourValCF, BL 
                        JMP Return_SetCF
                    p2_SetCF:
                        MOV BL, 0
                        ADC BL, 0
                        MOV ValCF, Bl
                Return_SetCF:
                    POP BX

                RET
            ENDP
            GetCF PROC
                PUSH BX

                CMP p1_CpuEnabled, 1
                JZ p1_GetCF
                CMP p2_CpuEnabled, 1
                JZ p2_GetCF

                JMP Return_GetCF

                p1_GetCF:
                    MOV BL, ourValCF
                    ADD BL, 0FFH
                    JMP Return_GetCF
                p2_GetCF:
                    MOV BL, ValCF
                    ADD BL, 0FFH

                Return_GetCF:
                    POP BX

                RET
            ENDP

            LoadP1Registers PROC FAR
                MOV AX,ourValRegAX
                mov DX,ourValRegDX
                RET
            ENDP
            UpdateP1Registers PROC FAR
                MOV ourValRegAX,AX
                mov ourValRegDX,DX
                RET
            ENDP

            LoadP2Registers PROC FAR
                MOV AX,ValRegAX
                mov DX,ValRegDX
                RET
            ENDP
            UpdateP2Registers PROC FAR
                MOV ValRegAX,AX
                mov ValRegDX,DX
                RET
            ENDP

        ;; ----------------------------- Validations --------------------------- ;;
            CheckMemToMem PROC FAR

                CMP selectedOp1Type, AddRegIndex
                JZ Op1Mem_Check
                CMP selectedOp1Type, MemIndex
                JZ Op1Mem_Check
                RET

                Op1Mem_Check:
                    CMP selectedOp2Type, AddRegIndex
                    JZ Op2Mem_Check
                    CMP selectedOp2Type, MemIndex
                    JZ Op2Mem_Check
                    RET

                    Op2Mem_Check:
                        MOV isInValidCommand, 1

                RET
            ENDP
            CheckSizeMismatch PROC FAR

                CMP selectedOp1Type, RegIndex
                JZ CheckSizeOp2
                RET

                CheckSizeOp2:
                    CMP selectedOp2Type, RegIndex
                    JZ CheckSizeMismatch_Op2Reg
                    CMP selectedOp2Type, ValIndex
                    JZ CheckSizeMismatch_Op2Val
                    RET

                    CheckSizeMismatch_Op2Reg:
                        ; Saving values of ax
                            push ax
                        mov al, selectedOp1Size
                        CMP AL, selectedOp2Size
                        JNZ SizeMismatch
                        POP AX
                        RET
                        SizeMismatch:
                            MOV isInValidCommand, 1
                            POP AX
                            RET
                    CheckSizeMismatch_Op2Val:
                        PUSH AX

                        MOV AL, selectedOp1Size
                        CMP AL, selectedOp2Size
                        JB SizeMismatch
                        POP AX
                        RET

                        



                
            ENDP
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
                mov al, Player2_ForbidChar
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
                    
                    JMP CheckForbidCharOp2

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


                RET
            ENDP


            CheckOp1Size PROC
                CMP selectedOp1Type, RegIndex
                jz Reg_CheckOp1Size
                CMP selectedOp1Type, ValIndex
                jz Val_CheckOp1Size
                
                ; Memory is 16-bit addressable
                MOV selectedOp1Size, 16
                RET
                
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
            CheckOp2Size PROC
                CMP selectedOp2Type, RegIndex
                jz Reg_CheckOp2Size
                CMP selectedOp2Type, ValIndex
                jz Val_CheckOp2Size
                
                ; Memory is 16-bit addressable
                MOV selectedOp2Size, 16
                RET
                
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
                    ret
            ENDP 
        ;; ---------------------------- Power Ups ------------------------------ ;;
            ExecPwrUp PROC FAR
                CMP selectedPUPType, 1
                JZ PwrUp1
                CMP selectedPUPType, 2
                JZ PwrUp2
                CMP selectedPUPType, 3
                JZ PwrUp3
                CMP selectedPUPType, 4
                JZ PwrUp4
                CMP selectedPUPType, 5
                JZ PwrUp5
                RET

                PwrUp1: ; Power Up #1: Executing a command on your own processor (consumes 5 points)
                    
                    CMP Player1_Points, 5
                    JBE NoAvailablePoints
                    SUB Player1_Points, 5

                    MOV p1_CpuEnabled, 1    ; Assuming that p1_cpu is the cpu of the current player
                    JMP Return_ExecPwrUp

                PwrUp2: ; Power Up #2: Executing a command on your processor and your opponent processor at the same time (consumes 3 points)

                    CMP Player1_Points, 3
                    JBE NoAvailablePoints
                    SUB Player1_Points, 3

                    MOV p1_CpuEnabled, 1
                    MOV p2_CpuEnabled, 1
                    JMP Return_ExecPwrUp
                PwrUp3: ; Power Up #3: Changing the forbidden character only once (consumes 8 points)
                    
                    CMP isPwrUp3Used, 1
                    JZ Return_ExecPwrUp

                    CMP Player1_Points, 8
                    JBE NoAvailablePoints
                    SUB Player1_Points, 8

                    CALL ChangeForbiddenChar
                    MOV isPwrUp3Used, 1
                    JMP Return_ExecPwrUp

                PwrUp4: ; Power Up #4: Making one of the data lines stuck at zero or at one for a single instruction (consumes 2 points)
                    
                    CMP Player1_Points, 2
                    JBE NoAvailablePoints
                    SUB Player1_Points, 2

                    ; Prompt the user for the details using LineStuckIndexMsg, LineStuckValMsg
                    ; Validate user Input and enter it in the opponent data line variables
                    CALL StuckIndexSubMenu
                    CALL StuckValSubMenu
                    MOV opponentPwrUpStuckEnabled, 1

                    JMP Return_ExecPwrUp
                PwrUp5: ; Clearing all registers at once. (Consumes 30 points and could be used only once).
                    
                    CMP isPwrUp5Used, 1
                    JZ Return_ExecPwrUp
                    
                    CMP Player1_Points, 30
                    JBE NoAvailablePoints
                    SUB Player1_Points, 30

                    CALL ClearAllRegisters
                    MOV isPwrUp5Used, 1
                    JMP Return_ExecPwrUp 
                NoAvailablePoints:
                    LEA Dx, NoAvailablePointsMsg
                    CALL DisplayString
                    RET
                Return_ExecPwrUp:    
                    RET
            ENDP
            ChangeForbiddenChar PROC FAR
                LEA DX, ChangeForbidMsg
                CALL DisplayString
                NotValidChar:
                    CALL WaitKeyPress
                    CMP AL, ' '
                    JZ NotValidChar
                
                CALL CharToUpper
                MOV Player2_ForbidChar, AL


                RET
            ENDP
            ClearAllRegisters PROC FAR
                MOV ourValRegAX, 0
                MOV ourValRegBX, 0
                MOV ourValRegCX, 0
                MOV ourValRegDX, 0
                MOV ourValRegBP, 0
                MOV ourValRegSP, 0
                MOV ourValRegSI, 0
                MOV ourValRegDI, 0

                MOV ValRegAX, 0
                MOV ValRegBX, 0
                MOV ValRegCX, 0
                MOV ValRegDX, 0
                MOV ValRegBP, 0
                MOV ValRegSP, 0
                MOV ValRegSI, 0
                MOV ValRegDI, 0
                RET
            ENDP
            LineStuckPwrUp PROC  FAR   ; Value to be stucked is saved in AX/AL
                PUSH BX
                PUSH CX
                PUSH DX

                CMP ourPwrUpStuckEnabled, 1
                jnz NotStuck
                CMP ourPwrUpStuckVal, 0
                JZ PwrUpZero
                CMP ourPwrUpStuckVal, 1
                JZ PwrupOne

                PwrUpZero:
                    MOV BX, 0FFFEH
                    mov cl, ourPwrUpDataLineIndex
                    ROL BX, cl
                    AND AX, BX
                    mov ourPwrUpStuckEnabled, 0
                    JMP NoTStuck
                PwrupOne:
                    MOV BX, 1
                    mov cl, ourPwrUpDataLineIndex
                    ROL BX,cl
                    OR AX, BX
                    mov ourPwrUpStuckEnabled, 0
                    ;MOV DL, AL
                    ;CALL DisplayChar
                NotStuck:
                    
                POP DX
                POP CX
                POP BX
                RET
            ENDP
            
        ;; ------------------------- Other Helper prcoedures ------------------- ;;
            
            

    ;; --------------------------------- General Helper Procedures ------------------------------- ;;
        WaitKeyPress PROC ; AH:scancode,AL:ASCII
            ; Wait for a key pressed
            CHECK:
                PUSHA
                    CALL DrawGuiLayout
                    CALL DisplayGUIValues
                    CALL DrawFlyingObj
                    CALL DrawShooter
                POPA

                mov ah,1
                int 16h
            jz CHECK

            CALL CheckShootingGame
            ret
        WaitKeyPress ENDP
        CheckShootingGame PROC
            PUSHA
                cmp ah, RightScanCode
                jz MoveRight_CheckShootingGame
                cmp ah, LeftScanCode
                jz MoveLeft_CheckShootingGame
                cmp ah, SpaceScanCode
                jz ourDrawBullet_CheckShootingGame
                cmp ah, EscScanCode
                jz Exit_CheckShootingGame

                JMP Return_CheckShootingGame

                ourDrawBullet_CheckShootingGame:
                    Call ourDrawBullet
                    JMP Return_CheckShootingGame
                MoveLeft_CheckShootingGame:
                    CALL MoveShooter1Left
                    JMP Return_CheckShootingGame
                MoveRight_CheckShootingGame:
                    CALL MoveShooter1Right
                    JMP Return_CheckShootingGame
                Exit_CheckShootingGame:
                    Call Terminate

            Return_CheckShootingGame:
                POPA
                RET
        ENDP
        CharToUpper PROC FAR    ; Convert Char in AL to upper Case
            ; Check if it's an alpapetic lower case
            CMP AL, 'a'
            JAE ChckUpperLimit
            RET
            ChckUpperLimit:
                CMP AL, 'z'
                JA NotLower
                SUB AL, 14H
            NotLower:    

            RET
        ENDP
        DisplayHexanumber PROC ;display Hexanumber from Registers   
            mov ax,234h     ;pop ax
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
                            
            RET

        DisplayHexanumber ENDP
        Display_ByteNum proc
            mov x_axis,bl
            mov y_axis,bh
            mov ah,0
            mov cl,c
            div cl
            mov ch,ah
            mov dl,al
            cmp dl,0Ah 
            jnl hexalet11
            add dl,30h
            jmp hexanum11
            hexalet11:
            add dl,37h
            hexanum11:
            Set x_axis y_axis      
            PrintChar dl

            mov dl,ch
            cmp dl,0Ah 
            jnl hexalet12
            add dl,30h
            jmp hexanum12
            hexalet12:
            add dl,37h
            hexanum12:
            inc y_axis
            Set x_axis y_axis           
            PrintChar dl

            RET
            Display_ByteNum ENDP 
        DisPlayNumber PROC 
            mov x_axis,bl
            mov y_axis, bh
            pop bp
            pop ax
            mov bx,ax

            mov cx,a
            div cx

            ; display first digit
            mov ah,2     ; display first digit
            mov dl,al
            cmp dl,0Ah 
            jnl hexalet
            add dl,30h
            jmp hexanum
            hexalet:
            add dl,37h
            ;sub dl,30h
            sub dl,17h
            hexanum:  
            Set x_axis y_axis
            ; cmp dl,41h
            ; jnl catchit 
            ; sub dl,7h 
            ; catchit:
            PrintChar dl


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
            cmp dl,0Ah 
            jnl hexalet2
            add dl,30h
            jmp hexanum2
            hexalet2:
            add dl,37h
            hexanum2: 
            inc y_axis  
            Set x_axis y_axis
            PrintChar dl

            mov dl,c
            mov al,bl
            mov ah,0

            div dl 

            mov ah,2     ; display third digit
            mov dl,al
            cmp dl,0Ah 
            jnl hexalet3
            add dl,30h
            jmp hexanum3
            hexalet3:
            add dl,37h
            hexanum3:      
            inc y_axis  
            Set x_axis y_axis
            PrintChar dl 

            mov cl,c 
            mov al,bl
            mov ah,0
            div cl
            mov al,ah
            mov ah,2     ; display fourth digit
            mov dl,al 
            cmp dl,0Ah 
            jnl hexalet4
            add dl,30h
            jmp hexanum4
            hexalet4:
            add dl,37h
            hexanum4:  
            inc y_axis  
            Set x_axis y_axis
            PrintChar dl

            PUSH BP

            RET        

        DisPlayNumber ENDP 
        Display_Digit proc  ; Mov Val to ax, BL: X-AXIS , BH: Y-AXIS
            mov x_axis,bl
            mov y_axis,bh
            mov ch,cc
            div ch 
            mov ch,ah
            mov dl,al
            add dl,30h
            
            Set x_axis y_axis
            PrintChar dl 

            mov dl,ch
            add dl,30h

            inc y_axis 
            Set x_axis y_axis
            PrintChar dl

            RET
            ENDP
        ClearScreenTxtMode PROC far
            ; Change to text mode (clear screen)
            mov ah,0
            mov al,3
            int 10h

            ret
        ClearScreenTxtMode ENDP
        Terminate PROC FAR
            ; Return to dos
            mov ah,4ch
            int 21h

            ret
        ENDP
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

    ;; ======================================================================================== ;;
        DetectWinner PROC FAR
            CMP Player1_Points, 0
            JBE Player2Wins
            CMP Player2_Points, 0
            JBE Player1Wins

            LEA DI, ValRegAX
            CheckMyWin:
                MOV CX, 8
                CMP [DI], 105eH
                JZ Player1Wins
                ADD DI, 2
                DEC CX
                JNZ CheckMyWin
            
            LEA DI, ourValRegAX
            CheckOpponentWin:
                MOV CX, 8
                CMP [DI], 105eH
                JZ Player2Wins
                ADD DI, 2
                DEC CX
                JNZ CheckOpponentWin
            RET

            Player1Wins:
                CALL ClearScreenTxtMode
                lea dx, Player1WinsMsg
                CALL DisplayString

                MOV CX, 1000
                WasteTimeWin:
                    DEC CX
                    JNZ WasteTimeWin
                POP AX
                JMP BreakGameLoop
                RET
            Player2Wins:

                CALL ClearScreenTxtMode
                lea dx, Player2WinsMsg
                CALL DisplayString

                MOV CX, 1000
                WasteTimeWin:
                    DEC CX
                    JNZ WasteTimeWin
                POP AX
                JMP BreakGameLoop

            RET
        ENDP
    ;; ------------------------------------ Connection Procedures ----------------------- ;;
        RecieveInvitations PROC FAR
            PUSHA

            ;Check that Data is Ready
            mov dx , 3FDH		; Line Status Register
            CHK2:
                in al , dx 
                test al , 1
            JZ Return_RecieveInvitations             ; Not Ready

            ; If Ready read the VALUE in Receive data register
            mov dx , 03F8H
            in al , dx 
            
            CMP AL, F1ScanCode
            JZ RecievedChatInvite
            CMP AL, F2ScanCode
            JZ RecievedGameInvite
            JMP Return_RecieveInvitations

            RecievedChatInvite:
                MOV ChatInvite, 1
                JMP Return_RecieveInvitations
            RecievedGameInvite:
                MOV GameInvite, 1
                JMP Return_RecieveInvitations
        

            Return_RecieveInvitations:
                POPA
                RET
        ENDP
        CheckInvitationsAcception PROC FAR
            CMP AH, F1ScanCode
            JZ AcceptChatInvite
            CMP AH, F2ScanCode
            JZ AcceptGameInvite
            JMP Return_CheckInvitationsAcception

            AcceptChatInvite:
                CMP ChatInvite, 0
                JZ Return_CheckInvitationsAcception
                MOV ChatInvite, 0
                ;;; Accepted Invite
                ;;; Send Acception
                MOV BL, F1ScanCode
                CALL SendByte
                MOV AcceptChat, 1
                JMP Return_CheckInvitationsAcception

            AcceptGameInvite:
                CMP GameInvite, 0
                JZ Return_CheckInvitationsAcception
                MOV GameInvite, 0
                ;;; Accepted Invite
                ;;; Send Acception
                MOV BL, F2ScanCode
                CALL SendByte
                MOV AcceptGame, 1
                JMP Return_CheckInvitationsAcception

            Return_CheckInvitationsAcception:
                RET
        ENDP
        SendGameInvite PROC FAR
            PUSHA
                MOV BL, F2ScanCode
                CALL SendByte
            POPA
            RET
        ENDP
        SendChatInvite PROC FAR
            PUSHA
                MOV BL, F1ScanCode
                CALL SendByte
            POPA
            RET
        ENDP
        SendByte PROC  ; data transferred is in BL (8 bits)
            ;Check that Transmitter Holding Register is Empty
            mov dx , 3FDH		        ; Line Status Register
            AGAIN:
                In al, dx 			    ; Read Line Status
                test al, 00100000b
            JZ AGAIN                    ; Not empty

            ;If empty put the VALUE in Transmit data register
            mov dx, 3F8H		        ; Transmit data register
            mov al, BL
            out dx, al

            ret
        SendByte ENDP
        RecieveByte PROC ; data is saved in BL

            ;Check that Data is Ready
            mov dx , 3FDH		; Line Status Register
            CHK_RecieveByte:
                in al , dx 
                test al , 1
            JZ CHK_RecieveByte              ; Not Ready

            ; If Ready read the VALUE in Receive data register
            mov dx , 03F8H
            in al , dx 
            mov bl , al

            Return_RecieveByte:
                ret
        RecieveByte ENDP
        WaitGameAcception PROC FAR
            WaitGameAccept:
                CALL RecieveByte
                CMP BL, F2ScanCode
                JZ GameAccepted
                JMP WaitGameAccept
            GameAccepted:
                RET
        ENDP
        WaitChatAcception PROC FAR
            WaitChatAccept:
                CALL RecieveByte
                CMP BL, F1ScanCode
                JZ ChatAccepted
                JMP WaitChatAccept
            ChatAccepted:
                RET
        ENDP
        ExchangeInfo PROC FAR

            CMP HOST, 1
            JZ SENDFIRST
            JMP SENDSECOND

            SENDFIRST:

                lea si, NAMEP1
                CALL SendMsg
                LEA DI, NAMEP2
                CALL RecMsg
                
                MOV BL, InitialPointsP1
                CALL SendByte

                CALL RecieveByte
                MOV InitialPointsP2, BL

                JMP Finish

            SENDSECOND:
                LEA DI, NAMEP2
                CALL RecMsg
                lea si, NAMEP1
                CALL SendMsg

                CALL RecieveByte
                MOV InitialPointsP2, BL

                MOV BL, InitialPointsP1
                CALL SendByte


            Finish:
            RET
        ENDP
        SendMsg PROC  ; Sent string offset is saved in si, ended with '$'
            SendMessage:
                CALL SendData
                inc si
                mov dl, '$'
                cmp dl , byte ptr [si]-1
                jnz SendMessage

            RET
        SendMsg ENDP
        SendData PROC  ; data transferred is pointed to by si (8 bits)

            ;Check that Transmitter Holding Register is Empty
            mov dx , 3FDH		        ; Line Status Register
            AGAIN_SendData:
                In al, dx 			    ; Read Line Status
                test al, 00100000b
            JZ AGAIN_SendData                    ; Not empty

            ;If empty put the VALUE in Transmit data register
            mov dx, 3F8H		        ; Transmit data register
            mov al, [si]
            out dx, al

            ret
        SendData ENDP
        RecMsg PROC     ; Recieved string offset is saved in di
            RecieveMsg:
                CALL RecieveByte
                mov [di], bl
                inc di
                cmp bl, '$'
                jnz RecieveMsg

            RET
        RecMsg ENDP
        RecieveData PROC ; data is saved in BL

            ;Check that Data is Ready
            mov dx , 3FDH		; Line Status Register
            CHK_RecieveData:
                in al , dx 
                test al , 1
            JZ Return_RecieveData              ; Not Ready

            ; If Ready read the VALUE in Receive data register
            mov dx , 03F8H
            in al , dx 
            mov bl , al

            Return_RecieveData:
                ret
        RecieveData ENDP

        ExchangeForbiddenChar PROC FAR

            CMP HOST, 1
            JZ SENDforbiddenFIRST
            JMP SENDforbiddenSECOND

            SENDforbiddenFIRST:

                lea si, Player1_ForbidChar
                CALL SendByte
                LEA DI, Player2_ForbidChar
                CALL RecieveByte

                JMP Finishforbidden

            SENDforbiddenSECOND:
                LEA DI, Player2_ForbidChar
                CALL RecieveByte
                lea si, Player1_ForbidChar
                CALL SendByte

            Finishforbidden:
            RET
        ENDP

        ReadInitialRegisters PROC FAR

            RET
        ENDP
        
END   MAIN