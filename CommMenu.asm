; Macros
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
.Model Huge
.386
.Stack 64
;================================================================================================================    
.Data
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

    ValRegAX dw 'AX'
    ValRegBX dw 'BX'
    ValRegCX dw 'CX'
    ValRegDX dw 'DX'
    ValRegBP dw 'BP'
    ValRegSP dw 'SP'
    ValRegSI dw 'SI'
    ValRegDI dw 'DI'
    
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

    NOPUP db 'NoPo ','$'
    PUP1 db 'PUp1 ','$'
    PUP2 db 'PUp2 ','$'
    PUP3 db 'PUp3 ','$'
    PUP4 db 'PUp4 ','$'
    PUP5 db 'PUp5 ','$'

    ValMem db 16 dup('M'), '$'
    ValStack db 16 dup('S'), '$'
    ValStackPointer db 0
    ValCF db 1

    ;OUR Regisesters
    ourValRegAX dw 'AX'
    ourValRegBX dw 'BX'
    ourValRegCX dw 'CX'
    ourValRegDX dw 'DX'
    ourValRegBP dw 'BP'
    ourValRegSP dw 'SP'
    ourValRegSI dw 'SI'
    ourValRegDI dw 'DI' 
    ourValCF db 0
    ourValMem db 16 dup('M'), '$'

    ourValStack db 16 dup('S'), '$'
    ourValStackPointer db 0
    

    ; Operand Value Needed Variables
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
    mesVal db 10, 'You Entered value: ', '$'
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
    ForbidChar db 'N'
    ForbidCommand db 0    ; 1 if forbidden

    ; Power Up Variables
    UsedBeforeOrNot db 1    ;Chance to use forbiden power up
    PwrUpDataLineIndex db 0
    PwrUpStuckVal db 0
    PwrUpStuckEnabled db 1


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
    CALL ClearScreen

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
        call  PowerUpeMenu ; to choose power up
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
        
        call  PowerUpeMenu ; to choose power up

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
        mov dx, offset error
        CALL DisplayString
        ; TODO - BEEP SOUND WHEN INVALID COMMAND ENTERED

    Exit:

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
                mov ForbidChar,al 

                sub Player1Points,8
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

                    sub Player1Points,30
                    notthispower5:

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
            lea dx, ValMem
            CALL DisplayString

            lea dx, mesStack
            CAll DisplayString
            lea dx, ValStack
            Call DisplayString

            lea dx, mesStackPointer
            CALL DisplayString
            mov dl, ValStackPointer
            add dl, '0'
            Call DisplayChar

            lea dx, mesVal
            CALL DisplayString
            mov dx, Op1Val
            Call DisplayChar

            LEA DX, mesRegAX
            CALL DisplayString
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
        ;JMP Start
        ; Return to dos
        mov ah,4ch
        int 21h


CommMenu ENDP
;================================================================================================================
ClearScreen PROC far
    ; Change to text mode (clear screen)
    mov ah,0
    mov al,3
    int 10h

    ret
ClearScreen ENDP
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
WaitKeyPress PROC ; AH:scancode,AL:ASCII
    ; Wait for a key pressed
    CHECK: 
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
LineStuckPwrUp PROC     ; Value to be stucked is saved in AX/AL
    PUSH BX
    PUSH CX
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
        JMP Return_LineStuckPwrUp
    PwrupOne:
        MOV BX, 1
        mov cl,PwrUpDataLineIndex
        ROL BX,cl
        OR AX, BX

    Return_LineStuckPwrUp:
        POP CX
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
        jz Selected_AddReg
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
GetCF PROC
    PUSH BX
        MOV BL, ValCF
        ADD BL, 0FFH
    POP BX

    RET
ENDP
END CommMenu