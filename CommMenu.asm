; Macros
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
            LEA DI, p1_ValMem[BX]
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
            LEA DI, p2_ValMem[BX]
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
            MOV AX, WORD PTR p1_ValMem[SI]
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
            MOV AX, WORD PTR p2_ValMem[SI]
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
            MOV AL, p1_ValMem[SI]
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
            MOV AL, p2_ValMem[SI]
            JMP RETURN_GetSrcOp_8Bit

ENDM
ExecPush MACRO Op
    mov bh, 0
    mov bl,p2_ValStackPointer
    mov ax, Op
    lea di,p2_ValStack
    mov [di][bx], ax
    ADD p2_ValStackPointer,2
ENDM
ourExecPush MACRO Op
    mov bh, 0
    mov bl, p1_ValStackPointer
    mov ax, Op
    lea di, p1_ValStack
    mov [di][bx], ax
    ADD p1_ValStackPointer,2
ENDM
ExecPushMem MACRO Op
    mov bh, 0
    mov bl,p2_ValStackPointer
    mov ax, word ptr Op
    lea di,p2_ValStack
    mov [di][bx], ax
    ADD p2_ValStackPointer,2
ENDM
ourExecPushMem MACRO Op
    mov bh, 0
    mov bl, p1_ValStackPointer
    mov ax, word ptr Op
    lea di,p2_ValStack
    mov [di][bx], ax
    ADD p1_ValStackPointer,2
ENDM
ExecPop MACRO Op
    mov bh, 0
    mov bl,p2_ValStackPointer
    lea di,p2_ValStack
    mov ax, [di][bx]
    mov Op, ax
    SUB p2_ValStackPointer,2
ENDM
ourExecPop MACRO Op
    mov bh, 0
    mov bl, p1_ValStackPointer
    lea di, p1_ValStack
    mov ax, [di][bx]
    mov Op, ax
    SUB p1_ValStackPointer,2
ENDM
ExecPopMem MACRO Op
    mov bh, 0
    mov bl,p2_ValStackPointer
    lea di,p2_ValStack
    mov ax, [di][bx]
    mov word ptr Op, ax
    SUB p2_ValStackPointer,2
ENDM
ourExecPopMem MACRO Op
    mov bh, 0
    mov bl, p1_ValStackPointer
    lea di, p1_ValStack
    mov ax, [di][bx]
    mov word ptr Op, ax
    SUB p1_ValStackPointer,2
ENDM
ExecINC MACRO Op
    INC Op
ENDM
ExecDEC MACRO Op
    DEC Op
ENDM
ExecAndReg MACRO p2_ValReg, CF
    CALL GetSrcOp
    AND p2_ValReg, AX
    MOV CF, 0
    CALL ExitPROC
ENDM
ExecAndReg_8Bit MACRO p2_ValReg, CF
    CALL GetSrcOp_8Bit
    And BYTE PTR p2_ValReg, AL
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
ExecAndAddReg MACRO p2_ValReg, Mem, CF
    Local AndOp1AddReg_Op2_8Bit

    MOV dx,p2_ValReg
    CALL CheckAddress
    cmp bl, 1               ;p2_Value is greater than 16
    JZ InValidCommand

    CMP selectedOp2Size, 8
    jz AndOp1AddReg_Op2_8Bit 
    CALL GetSrcOp
    MOV SI,p2_ValReg
    And WORD PTR Mem[SI], AX
    MOV CF, 0
    CALL ExitPROC

    AndOp1AddReg_Op2_8Bit:
        CALL GetSrcOp_8Bit
        MOV SI,p2_ValReg
        And Mem[SI], AL
        MOV CF, 0
    CALL ExitPROC
ENDM
ExecMovAddReg MACRO p2_ValReg, Mem
    Local MOVOp1AddReg_Op2_8Bit 

    MOV dx,p2_ValReg
    CALL CheckAddress
    cmp bl, 1               ;p2_Value is greater than 16
    JZ InValidCommand

    CMP selectedOp2Size, 8
    jz MOVOp1AddReg_Op2_8Bit 
    CALL GetSrcOp
    MOV SI,p2_ValReg
    MOV WORD PTR Mem[SI], AX
    JMP Exit
    MOVOp1AddReg_Op2_8Bit:
        CALL GetSrcOp_8Bit
        MOV SI,p2_ValReg
        MOV Mem[SI], AL
    JMP Exit
ENDM
ExecAddAddReg MACRO p2_ValReg, Mem
    LOCAL AddOp1AddReg_Op2_8Bit

    MOV dx,p2_ValReg
    CALL CheckAddress
    cmp bl, 1               ;p2_Value is greater than 16
    JZ InValidCommand

    CMP selectedOp2Size, 8
    jz AddOp1AddReg_Op2_8Bit 
    CALL GetSrcOp
    MOV SI,p2_ValReg
    CLC
    ADD WORD PTR Mem[SI], AX
    CALL SetCF
    JMP Exit
    AddOp1AddReg_Op2_8Bit:
        CALL GetSrcOp_8Bit
        MOV SI,p2_ValReg
        CLC
        ADD Mem[SI], AL
        CALL SetCF
    JMP Exit
ENDM
EexecAdcAddReg MACRO p2_ValReg, Mem
    LOCAL AdcOp1Addreg_Op2_8Bit

    MOV dx,p2_ValReg
    CALL CheckAddress
    cmp bl, 1               ;p2_Value is greater than 16
    JZ InValidCommand

    CMP selectedOp2Size, 8
    jz AdcOp1Addreg_Op2_8Bit 
    CALL GetSrcOp
    MOV SI,p2_ValReg
    CLC
    CALL GetCF
    ADC WORD PTR Mem[SI], AX
    CALL SetCF
    JMP Exit
    AdcOp1Addreg_Op2_8Bit:
        CALL GetSrcOp_8Bit
        MOV SI,p2_ValReg
        CLC
        CALL GetCF
        ADC Mem[SI], AL
        CALL SetCF
    JMP Exit
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
.Model Huge
.386
.Stack 64
;================================================================================================================    
.Data
    ;; ----------------------------------  Menus Strings ----------------------------------- ;;
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

    ;; -------------------------------------- Player's Data ------------------------------ ;;
        p2_ValRegAX dw 'AX'
        p2_ValRegBX dw 'BX'
        p2_ValRegCX dw 'CX'
        p2_ValRegDX dw 'DX'
        p2_ValRegBP dw 0
        p2_ValRegSP dw 1
        p2_ValRegSI dw 'SI'
        p2_ValRegDI dw 'DI'

        p2_ValMem db 16 dup('M'), '$'
        p2_ValStack DW 8 dup('Ss'), '$'
        ;p2_ValStackPointer db 0
        p2_ValCF db 1

        ;OUR Regisesters
        p1_ValRegAX dw 'AX'
        p1_ValRegBX dw 'BX'
        p1_ValRegCX dw 'CX'
        p1_ValRegDX dw 'DX'
        p1_ValRegBP dw 0
        p1_ValRegSP dw 1
        p1_ValRegSI dw 'SI'
        p1_ValRegDI dw 'DI' 
        p1_ValCF db 0
        p1_ValMem db 16 dup('M'), '$'

        p1_ValStack DW 8 dup('S'), '$'
        ;p1_ValStackPointer db 0
    

    ; Operandp2_Value Needed Variables
    ClearSpace db '     ', '$'
    num db 30,?,30 DUP(?)       
    StrSize db ?
    num2 db 30,?,30 DUP(?)       
    StrSize2 db ?
    a EQU 1000H
    B EQU 100H
    C EQU 10H

    ; Variables Memory Locations and data
    CommStringSize EQU  6


    ; Test Messages
    mesCom db 10,'You have selected Command #', '$'
    mesOp1Type db 10,'You have selected Operand 1 of Type #', '$'
    mesReg db 10, 'You have selected Reg #', '$'
    ;mesMem db 10, 'You have selected Mem #', '$'
    mesVal db 10, 'You Enteredp2_Value: ', '$'
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

    tstmsg db 13, 10, "Test ", '$'





    selectedComm db -1, '$'

    selectedOp1Type db -1, '$'  
    selectedOp1Reg  db -1, '$'
    selectedOp1AddReg db -1, '$'
    selectedOp1Mem  db -1, '$'
    selectedOp1Size db 8, '$'

    selectedPUPType db -1, '$' 
    

    Op1Val dw 0
    Op1Valid db 1               ; 0 if Invalid 

    selectedOp2Type db -1, '$'
    selectedOp2Reg  db -1, '$'
    selectedOp2AddReg db -1, '$'
    selectedOp2Mem  db -1, '$'
    selectedOp2Size db 8, '$'
    Op2Val dw 0
    Op2Valid db 1               ; 0 if Invalid 

    
    ; Game Variables
    Player1Points dw 0
    ForbidChar db 'l'
    isInvalidCommand db 0    ; 1 if Invalid
    p1_CpuEnabled db 0      ; 1 if command will run on it
    p2_CpuEnabled db 1      ; ..

    ; Power Up Variables
    UsedBeforeOrNot db 1    ;Chance to use forbiden power up
    ourPwrUpDataLineIndex db 0
    ourPwrUpStuckVal db 0
    ourPwrUpStuckEnabled db 0

    opponentPwrUpDataLineIndex db 0
    opponentPwrUpStuckVal      db 0
    opponentPwrUpStuckEnabled  db 0


    ; Keys Scan Codes
    UpArrowScanCode EQU 72
    DownArrowScanCode EQU 80

    EnterScanCode EQU 28 

    ; Cursor Locations
    MenmonicCursorLoc EQU 0000H
    Op1CursorLoc EQU 0006H
    CommaCursorLoc EQU 000BH
    Op2CursorLoc EQU 000CH
    PUPCursorLoc EQU 0011H
    ForbidPUPCursor EQU 0016H
    
 
;================================================================================================================
.Code
    
CommMenu proc far
    
    mov ax, @Data
    mov ds, ax
    mov es, ax
    CALL ClearScreenTxtMode

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

    ;JMP TODO_Comm
    ; Continue comparing for all operations

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
            JZ ValidCommand
            mov dx, offset error
            CALL DisplayString

            ValidCommand:

            ; Test Messages
            LEA DX, mesCom
            CALL DisplayString
            mov dl, selectedComm
            add dl, '0'
            CALL DisplayChar 

            LEA DX, mesOp1Type
            CALL DisplayString
            mov dl, selectedOp1Type
            add dl, '0'
            CALL DisplayChar

            LEA DX, mesReg
            CALL DisplayString
            mov dl, selectedOp1Reg
            add dl, '0'
            CALL DisplayChar 

            lea dx, mesMem
            CAll DisplayString
            lea dx,p2_ValMem
            CALL DisplayString

            lea dx, mesStack
            CAll DisplayString
            lea dx,p2_ValStack
            Call DisplayString

            lea dx, mesVal
            CALL DisplayString
            mov dx, Op1Val
            Call DisplayChar

            LEA DX, mesRegAX
            CALL DisplayString
            mov dl,Byte ptr p2_ValRegAX
            CALL DisplayChar
            mov dl, byte ptr p2_ValRegAX+1
            CALL DisplayChar

            LEA DX, mesRegBX
            CALL DisplayString
            mov dl,Byte ptr p2_ValRegBX
            CALL DisplayChar
            mov dl, byte ptr p2_ValRegBX+1
            CALL DisplayChar 

            LEA DX, mesRegCX
            CALL DisplayString
            mov dl,Byte ptr p2_ValRegCX
            CALL DisplayChar
            mov dl, byte ptr p2_ValRegCX+1
            CALL DisplayChar 

            LEA DX, mesRegDX
            CALL DisplayString
            mov dl,Byte ptr p2_ValRegDX
            CALL DisplayChar
            mov dl, byte ptr p2_ValRegDX+1
            CALL DisplayChar 

            LEA DX, mesRegSI
            CALL DisplayString
            mov dl,Byte ptr p2_ValRegSI
            CALL DisplayChar
            mov dl, byte ptr p2_ValRegSI+1
            CALL DisplayChar 

            LEA DX, mesRegDI
            CALL DisplayString
            mov dl,Byte ptr p2_ValRegDI
            CALL DisplayChar
            mov dl, byte ptr p2_ValRegDI+1
            CALL DisplayChar 

            LEA DX, mesRegBP
            CALL DisplayString
            mov dl,Byte ptr p2_ValRegBP
            CALL DisplayChar
            mov dl, byte ptr p2_ValRegBP+1
            CALL DisplayChar 

            LEA DX, mesRegSP
            CALL DisplayString
            mov dl,Byte ptr p2_ValRegSP
            CALL DisplayChar
            mov dl, byte ptr p2_ValRegSP+1
            CALL DisplayChar
            
            LEA DX, mesRegCF
            CALL DisplayString
            mov dl, p2_ValCF
            add dl, '0'
            CALL DisplayChar

            LEA DX, mesReg
            CALL DisplayString
            mov dl, Op2Valid
            add dl, '0'
            CALL DisplayChar  

            

            CALL ExitPROC

            ret
        


CommMenu ENDP
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

                Mov BX, p1_ValRegSP
                MOV p1_ValStack[BX], AX
                INC p1_ValRegSP
                JMP Push_p2

                

            Push_p2:
                MOV p1_CpuEnabled, 0
                MOV isInvalidCommand, 0
                CMP p2_CpuEnabled, 1
                jnz Return_PushCom

                CALL GetSrcOp

                CMP isInvalidCommand, 1
                JZ Return_PushCom

                Mov BX, p2_ValRegSP
                MOV p2_ValStack[BX], AX
                INC p2_ValRegSP

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

                Mov BX, p1_ValRegSP
                MOV DX, p1_ValStack[BX]
                MOV [DI], DX
                DEC p1_ValRegSP
                JMP POP_p2

            POP_p2:
                MOV p1_CpuEnabled, 0
                MOV isInvalidCommand, 0
                CMP p2_CpuEnabled, 1
                jnz Return_POPCom

                CALL GetDst

                CMP isInvalidCommand, 1
                JZ Return_POPCom

                Mov BX, p2_ValRegSP
                MOV DX, p2_ValStack[BX]
                MOV [DI], DX
                DEC p2_ValRegSP

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
                DIV BX
                call SetCF
                call UpdateP1Registers
                jmp DIV_p2
            DIV_p1_8bit:
                call GetSrcOp_8Bit
                mov bl,al
                call LoadP1Registers
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
                DIV BX
                call SetCF
                call UpdateP2Registers
                jmp Return_DIV
            DIV_p2_8bit:
                call GetSrcOp_8Bit
                mov bl,al
                call LoadP2Registers
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
                IDIV BX
                call SetCF
                call UpdateP1Registers
                jmp IDIV_p2
            IDIV_p1_8bit:
                call GetSrcOp_8Bit
                mov bl,al
                call LoadP1Registers
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
                IDIV BX
                call SetCF
                call UpdateP2Registers
                jmp Return_IDIV
            IDIV_p2_8bit:
                call GetSrcOp_8Bit
                mov bl,al
                call LoadP2Registers
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

            ; Display Command
            DisplayComm:
                mov ah, 9
                mov dx, offset DECcom
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

                ; Clear buffer
                mov ah,07
                int 21h
                

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
                ; Clear buffer
                    mov ah,07
                    int 21h

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
        PowrUpMenu ENDP
        
        
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
                    DstOpReg p1_ValRegAX, p2_ValRegAX

                DstOp1RegAH:
                    DstOpReg p1_ValRegAX+1, p2_ValRegAX+1

                DstOp1RegBX:
                    DstOpReg p1_ValRegBX, p2_ValRegBX

                DstOp1RegBH:
                    DstOpReg p1_ValRegBX+1, p2_ValRegBX+1

                DstOp1RegCX:
                    DstOpReg p1_ValRegCX, p2_ValRegCX

                DstOp1RegCH:
                    DstOpReg p1_ValRegCX+1, p2_ValRegCX+1
                
                DstOp1RegDX:
                    DstOpReg p1_ValRegDX, p2_ValRegDX

                DstOp1RegDH:
                    DstOpReg p1_ValRegDX+1, p2_ValRegDX+1

                DstOp1RegBP:
                    DstOpReg p1_ValRegBP, p2_ValRegBP

                DstOp1RegSP:
                    DstOpReg p1_ValRegSP, p2_ValRegSP

                DstOp1RegSI:
                    DstOpReg p1_ValRegSI, p2_ValRegSI

                DstOp1RegDI:
                    DstOpReg p1_ValRegDI, p2_ValRegDI
                


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
                    DstOpAddReg p1_ValRegBX, p2_ValRegBX
                DstOp1AddRegBP:
                    DstOpAddReg p1_ValRegBP, p2_ValRegBP
                DstOp1AddRegSI:
                    DstOpAddReg p1_ValRegSI, p2_ValRegSI
                DstOp1AddRegDI:
                    DstOpAddReg p1_ValRegDI, p2_ValRegDI

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
                        LEA DI, p1_ValMem[BX]      ;command
                        JMP RETURN_DstSrc
                    
                    p2_DstMem:
                        LEA DI, p2_ValMem[BX]      ;command
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
                    SrcOpReg p1_ValRegAX, p2_ValRegAX
                SrcOp2RegBX:
                    SrcOpReg p1_ValRegBX, p2_ValRegBX
                SrcOp2RegCX:
                    SrcOpReg p1_ValRegCX, p2_ValRegCX
                SrcOp2pRegDX:
                    SrcOpReg p1_ValRegDX, p2_ValRegDX
                SrcOp2RegBP:
                    SrcOpReg p1_ValRegBP, p2_ValRegBP
                SrcOp2RegSP:
                    SrcOpReg p1_ValRegSP, p2_ValRegSP
                SrcOp2RegSI:
                    SrcOpReg p1_ValRegSI, p2_ValRegSI
                SrcOp2RegDI:
                    SrcOpReg p1_ValRegDI, p2_ValRegDI
                


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
                    SrcOpAddReg p1_ValRegBX, p2_ValRegBX
                SrcOp2AddRegBP:
                    
                    SrcOpAddReg p1_ValRegBP, p2_ValRegBP
                SrcOp2AddRegSI:
                    SrcOpAddReg p1_ValRegSI, p2_ValRegSI
                SrcOp2AddRegDI:
                    SrcOpAddReg p1_ValRegDI, p2_ValRegDI

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
                        MOV AX, WORD PTR p1_ValMem[BX]      ;command
                        JMP RETURN_GetSrcOp
                    
                    p2_GetSrc:
                        MOV AX, WORD PTR p2_ValMem[BX]      ;command
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
                    SrcOpReg_8bit p1_ValRegAX, p2_ValRegAX
                SrcOp2RegAH_8Bit:
                    SrcOpReg_8bit p1_ValRegAX+1, p2_ValRegAX+1
                SrcOp2RegBL_8Bit:
                    SrcOpReg_8bit p1_ValRegBX, p2_ValRegBX
                SrcOp2RegBH_8Bit:
                    SrcOpReg_8bit p1_ValRegBX+1, p2_ValRegBX+1
                SrcOp2RegCL_8Bit:
                    SrcOpReg_8bit p1_ValRegCX, p2_ValRegCX
                SrcOp2RegCH_8Bit:
                    SrcOpReg_8bit p1_ValRegCX+1, p2_ValRegCX+1
                SrcOp2RegDL_8Bit:
                    SrcOpReg_8bit p1_ValRegDX, p2_ValRegDX
                SrcOp2RegDH_8Bit:
                    SrcOpReg_8bit p1_ValRegDX+1, p2_ValRegDX+1
                


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
                    SrcOpAddReg_8bit p1_ValRegBX, p2_ValRegBX
                SrcOp2AddRegBP_8Bit:
                    SrcOpAddReg_8bit p1_ValRegBP, p2_ValRegBP
                SrcOp2AddRegSI_8Bit:
                    SrcOpAddReg_8bit p1_ValRegSI, p2_ValRegSI
                SrcOp2AddRegDI_8Bit:
                    SrcOpAddReg_8Bit p1_ValRegDI, p2_ValRegDI

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
                        MOV AL, p1_ValMem[BX]      ;command
                        JMP RETURN_GetSrcOp_8Bit
                    
                    p2_GetSrc_8BIT:
                        MOV AL, p2_ValMem[BX]      ;command
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
                    MOV p1_ValCF, BL 
                    JMP Return_SetCF
                p2_SetCF:
                    MOV BL, 0
                    ADC BL, 0
                    MOV p2_ValCF, Bl
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
                MOV BL, p1_ValCF
                ADD BL, 0FFH
                JMP Return_GetCF
            p2_GetCF:
                MOV BL, p2_ValCF
                ADD BL, 0FFH

            Return_GetCF:
                POP BX

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
            mov al, ForbidChar
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
                
                ; TODO - Check Available Points and consume it if available

                MOV p1_CpuEnabled, 1    ; Assuming that p1_cpu is the cpu of the current player
                JMP Return_ExecPwrUp

            PwrUp2: ; Power Up #2: Executing a command on your processor and your opponent processor at the same time (consumes 3 points)

                ; TODO - Check Available Points and consume it if available

                MOV p1_CpuEnabled, 1
                MOV p2_CpuEnabled, 1
                JMP Return_ExecPwrUp
            PwrUp3: ; Power Up #3: Changing the forbidden character only once (consumes 8 points)
                
                ; TODO - Check Available Points and consume it if available

                CALL ChangeForbiddenChar
                JMP Return_ExecPwrUp

            PwrUp4: ; Power Up #4: Making one of the data lines stuck at zero or at one for a single instruction (consumes 2 points) 

                ; TODO - Check Available Points and consume it if available

                ; Prompt the user for the details

                MOV opponentPwrUpStuckEnabled, 1

                JMP Return_ExecPwrUp



            NoAvailablePoints:

            Return_ExecPwrUp:    
                RET
        ENDP
        ChangeForbiddenChar PROC FAR


            RET
        ENDP
    ;; ------------------------- Other Helper prcoedures ------------------- ;;
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
            NotStuck:
                
            POP DX
            POP CX
            POP BX
            RET
        ENDP
        

;; --------------------------------- General Helper Procedures ------------------------------- ;;


    WaitKeyPress PROC ; AH:scancode,AL:ASCII
        ; Wait for a key pressed
        CHECK: 
            mov ah,1
            int 16h
        jz CHECK

        ret
    WaitKeyPress ENDP
    DisplayChar PROC    ; char is saved in dl
        mov ah,2
        int 21h

        RET
    DisplayChar ENDP
    DisplayString PROC ; string offset saved in DX
        mov ah, 9
        int 21h

        RET
    DisplayString ENDP
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
    SetCursor PROC ; position is saved in dx   
        mov ah,2
        int 10h

        ret
    SetCursor ENDP
    ClearScreenTxtMode PROC far
        ; Change to text mode (clear screen)
        mov ah,0
        mov al,3
        int 10h

        ret
    ClearScreenTxtMode ENDP
    ExitPROC PROC FAR
        ; Return to dos
        mov ah,4ch
        int 21h
        
    ENDP

    LoadP1Registers PROC FAR
        MOV AX,p1_ValRegAX
        mov DX,p1_ValRegDX
        RET
    ENDP
    UpdateP1Registers PROC FAR
        MOV p1_ValRegAX,AX
        mov p1_ValRegDX,DX
        RET
    ENDP

    LoadP2Registers PROC FAR
        MOV AX,p2_ValRegAX
        mov DX,p2_ValRegDX
        RET
    ENDP
    UpdateP2Registers PROC FAR
        MOV p2_ValRegAX,AX
        mov p2_ValRegDX,DX
        RET
    ENDP

    




END CommMenu