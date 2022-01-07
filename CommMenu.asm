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
        MOV p1_CpuEnabled, 0
        JMP RETURN_DstSrc
    p2_DstValReg:
        LEA DI, p2_Reg
        MOV p2_CpuEnabled, 0    
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
        MOV p1_CpuEnabled, 0
        JMP RETURN_GetSrcOp
    p2_SrcValReg:
        MOV AX, p2_Reg
        MOV p2_CpuEnabled, 0    
        JMP RETURN_GetSrcOp

ENDM
DstOpAddReg MACRO p1_Reg, p2_Reg
    LOCAL p1_DstValAddReg, p2_DstValAddReg, ValidAddress

    CMP p1_CpuEnabled, 1
    JZ p1_DstValAddReg
    CMP p2_CpuEnabled, 1
    JZ p2_DstValAddReg
    JMP RETURN_DstSrc

    p1_DstValAddReg:
        MOV p1_CpuEnabled, 0
        MOV DX, p1_Reg
        CALL CheckAddress
        CMP BL, 1           ; Check Invalid address
        JNZ ValidAddress
        MOV InvalidCommand, 1
        JMP RETURN_DstSrc

        ValidAddress:
            MOV DI, p1_Reg
            JMP RETURN_DstSrc
    p2_DstValAddReg:
        MOV p2_CpuEnabled, 0
        MOV DX, p2_Reg
        CALL CheckAddress
        CMP BL, 1           ; Check Invalid address
        JNZ ValidAddress
        MOV InvalidCommand, 1
        JMP RETURN_DstSrc

        ValidAddress:
            MOV DI, p2_Reg
            JMP RETURN_DstSrc

ENDM
SrcOpAddReg MACRO p1_Reg, p2_Reg
    LOCAL p1_SrcOpAddReg, p2_SrcOpAddReg, ValidAddress

    CMP p1_CpuEnabled, 1
    JZ p1_SrcOpAddReg
    CMP p2_CpuEnabled, 1
    JZ p2_SrcOpAddReg
    JMP RETURN_GetSrcOp

    p1_SrcOpAddReg:
        MOV p1_CpuEnabled, 0
        MOV DX, p1_Reg
        CALL CheckAddress
        CMP BL, 1           ; Check Invalid address
        JNZ ValidAddress
        MOV InvalidCommand, 1
        JMP RETURN_GetSrcOp

        ValidAddress:
            MOV SI, p1_Reg
            MOV AX, [SI]
            JMP RETURN_GetSrcOp
    p2_SrcOpAddReg:
        MOV p2_CpuEnabled, 0
        MOV DX, p2_Reg
        CALL CheckAddress
        CMP BL, 1           ; Check Invalid address
        JNZ ValidAddress
        MOV InvalidCommand, 1
        JMP RETURN_GetSrcOp

        ValidAddress:
            MOV SI, p2_Reg
            MOV AX, [SI]
            JMP RETURN_GetSrcOp

ENDM
ExecPush MACRO Op
    mov bh, 0
    mov bl,p2_ValStackPointer
    mov ax, Op
    lea di,p2_ValStack
    mov [di][bx], ax
    ADDp2_ValStackPointer,2
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
    ADDp2_ValStackPointer,2
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
    SUBp2_ValStackPointer,2
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
    SUBp2_ValStackPointer,2
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
ExecAndReg MACROp2_ValReg, CF
    CALL GetSrcOp
    ANDp2_ValReg, AX
    MOV CF, 0
    CALL ExitPROC
ENDM
ExecAndReg_8Bit MACROp2_ValReg, CF
    CALL GetSrcOp_8Bit
    And BYTE PTRp2_ValReg, AL
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
ExecAndAddReg MACROp2_ValReg, Mem, CF
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
ExecMovAddReg MACROp2_ValReg, Mem
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
ExecAddAddReg MACROp2_ValReg, Mem
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
EexecAdcAddReg MACROp2_ValReg, Mem
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
   p2_Value  db 'VAL  ','$'
    RegIndex    EQU 0
    AddRegIndex EQU 1
    MemIndex    EQU 2
   p2_ValIndex    EQU 3 
    

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

   p2_ValRegAX dw 'AX'
   p2_ValRegBX dw 'BX'
   p2_ValRegCX dw 'CX'
   p2_ValRegDX dw 'DX'
   p2_ValRegBP dw 'BP'
   p2_ValRegSP dw 'SP'
   p2_ValRegSI dw 'SI'
   p2_ValRegDI dw 'DI'
    
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

   p2_ValMem db 16 dup('M'), '$'
   p2_ValStack db 16 dup('S'), '$'
   p2_ValStackPointer db 0
   p2_ValCF db 1

    ;OUR Regisesters
    p1_ValRegAX dw 'AX'
    p1_ValRegBX dw 'BX'
    p1_ValRegCX dw 'CX'
    p1_ValRegDX dw 'DX'
    p1_ValRegBP dw 'BP'
    p1_ValRegSP dw 'SP'
    p1_ValRegSI dw 'SI'
    p1_ValRegDI dw 'DI' 
    p1_ValCF db 0
    p1_ValMem db 16 dup('M'), '$'

    p1_ValStack db 16 dup('S'), '$'
    p1_ValStackPointer db 0
    

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
    InvalidCommand db 0    ; 1 if Invalid
    p1_CpuEnabled db 0      ; 1 if command will run on it
    p2_CpuEnabled db 0      ; ..

    ; Power Up Variables
    UsedBeforeOrNot db 1    ;Chance to use forbiden power up
    PwrUpDataLineIndex db 0
    PwrUpStuckVal db 0
    PwrUpStuckEnabled db 0


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
            MOV p1_ValCF, 0      ;command
            jmp Exit
            notthispower1_clc:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_clc  
            MOV p1_ValCF, 0       ;coomand
            notthispower2_clc:
            MOVp2_ValCF, 0  ;command
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
                    movp2_ValRegAX,0
                    movp2_ValRegBX,0
                    movp2_ValRegCX,0
                    movp2_ValRegDX,0 
                
                    movp2_ValRegBP,0
                    movp2_ValRegSP,0
                    movp2_ValRegSI,0
                    movp2_ValRegDI,0
                
                    mov p1_ValRegAX,0
                    mov p1_ValRegBX,0
                    mov p1_ValRegCX,0
                    mov p1_ValRegDX,0
                
                    mov p1_ValRegBP,0
                    mov p1_ValRegSP,0
                    mov p1_ValRegSI,0
                    mov p1_ValRegDI,0

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
            lea dx,p2_ValMem
            CALL DisplayString

            lea dx, mesStack
            CAll DisplayString
            lea dx,p2_ValStack
            Call DisplayString

            lea dx, mesStackPointer
            CALL DisplayString
            mov dl,p2_ValStackPointer
            add dl, '0'
            Call DisplayChar

            lea dx, mesVal
            CALL DisplayString
            mov dx, Op1Val
            Call DisplayChar

            LEA DX, mesRegAX
            CALL DisplayString
            mov dl,Byte ptrp2_ValRegAX
            CALL DisplayChar
            mov dl, byte ptrp2_ValRegAX+1
            CALL DisplayChar

            LEA DX, mesRegBX
            CALL DisplayString
            mov dl,Byte ptrp2_ValRegBX
            CALL DisplayChar
            mov dl, byte ptrp2_ValRegBX+1
            CALL DisplayChar 

            LEA DX, mesRegCX
            CALL DisplayString
            mov dl,Byte ptrp2_ValRegCX
            CALL DisplayChar
            mov dl, byte ptrp2_ValRegCX+1
            CALL DisplayChar 

            LEA DX, mesRegDX
            CALL DisplayString
            mov dl,Byte ptrp2_ValRegDX
            CALL DisplayChar
            mov dl, byte ptrp2_ValRegDX+1
            CALL DisplayChar 

            LEA DX, mesRegSI
            CALL DisplayString
            mov dl,Byte ptrp2_ValRegSI
            CALL DisplayChar
            mov dl, byte ptrp2_ValRegSI+1
            CALL DisplayChar 

            LEA DX, mesRegDI
            CALL DisplayString
            mov dl,Byte ptrp2_ValRegDI
            CALL DisplayChar
            mov dl, byte ptrp2_ValRegDI+1
            CALL DisplayChar 

            LEA DX, mesRegBP
            CALL DisplayString
            mov dl,Byte ptrp2_ValRegBP
            CALL DisplayChar
            mov dl, byte ptrp2_ValRegBP+1
            CALL DisplayChar 

            LEA DX, mesRegSP
            CALL DisplayString
            mov dl,Byte ptrp2_ValRegSP
            CALL DisplayChar
            mov dl, byte ptrp2_ValRegSP+1
            CALL DisplayChar
            
            LEA DX, mesRegCF
            CALL DisplayString
            mov dl,p2_ValCF
            add dl, '0'
            CALL DisplayChar

            LEA DX, mesReg
            CALL DisplayString
            mov dl, Op2Valid
            add dl, '0'
            CALL DisplayChar  

            ;JMP Start
            ; Return to dos
            mov ah,4ch
            int 21h
        POP_Comm:
            CALL Op1Menu
            CALL CheckForbidCharProc

            call  PowerUpeMenu ; to choose power up

            ; Todo - CHECKp2_ValIDATIONS
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
                    ourExecPop p1_ValRegAX      
                    jmp Exit
                    notthispower1_popax:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_popax  
                    ourExecPop p1_ValRegAX        
                    notthispower2_popax:
                    ExecPopp2_ValRegAX
                    JMP Exit
                PopOpRegBX:
                    cmp selectedPUPType,1 ;command on your own processor  
                    jne notthispower1_popbx  
                    ourExecPop p1_ValRegBX      
                    jmp Exit
                    notthispower1_popbx:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_popbx  
                    ourExecPop p1_ValRegBX        
                    notthispower2_popbx:
                    ExecPopp2_ValRegBX
                    JMP Exit
                PopOpRegCX:
                    cmp selectedPUPType,1 ;command on your own processor  
                    jne notthispower1_popcx  
                    ourExecPop p1_ValRegCX      
                    jmp Exit
                    notthispower1_popcx:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_popcx  
                    ourExecPop p1_ValRegCX        
                    notthispower2_popcx:
                    ExecPopp2_ValRegCX
                    JMP Exit
                PopOpRegDX:
                    cmp selectedPUPType,1 ;command on your own processor  
                    jne notthispower1_popdx  
                    ourExecPop p1_ValRegDX      
                    jmp Exit
                    notthispower1_popdx:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_popdx  
                    ourExecPop p1_ValRegDX        
                    notthispower2_popdx:
                    ExecPopp2_ValRegDX
                    JMP Exit
                PopOpRegBP:
                    cmp selectedPUPType,1 ;command on your own processor  
                    jne notthispower1_popbp  
                    ourExecPop p1_ValRegBP      
                    jmp Exit
                    notthispower1_popbp:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_popbp  
                    ourExecPop p1_ValRegBP        
                    notthispower2_popbp:
                    ExecPopp2_ValRegBP
                    JMP Exit
                PopOpRegSP:
                    cmp selectedPUPType,1 ;command on your own processor  
                    jne notthispower1_popsp  
                    ourExecPop p1_ValRegSP      
                    jmp Exit
                    notthispower1_popsp:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_popsp  
                    ourExecPop p1_ValRegSP        
                    notthispower2_popsp:
                    ExecPopp2_ValRegSP
                    JMP Exit
                PopOpRegSI:
                    cmp selectedPUPType,1 ;command on your own processor  
                    jne notthispower1_popsi  
                    ourExecPop p1_ValRegSI     
                    jmp Exit
                    notthispower1_popsi:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_popsi  
                    ourExecPop p1_ValRegSI        
                    notthispower2_popsi:
                    ExecPopp2_ValRegSI
                    JMP Exit
                PopOpRegDI:
                    cmp selectedPUPType,1 ;command on your own processor  
                    jne notthispower1_popdi  
                    ourExecPop p1_ValRegDI      
                    jmp Exit
                    notthispower1_popdi:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_popdi  
                    ourExecPop p1_ValRegDI        
                    notthispower2_popdi:
                    ExecPopp2_ValRegDI
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
                    ourExecPopMem p1_ValMem[si] ; command
                    jmp Exit
                    notthispower1_popmem:  
                    cmp selectedPUPType,2 ;his/her and our command 
                    jne notthispower2_popmem 
                    ourExecPopMem p1_ValMem[si] ;command
                    notthispower2_popmem: 
                    ExecPopMemp2_ValMem[si]
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
                    mov dx, p1_ValRegBX
                    CALL CheckAddress
                    cmp bl, 1               ;p2_Value is greater than 16
                    JZ InValidCommand
                    mov SI, p1_ValRegBX
                    ourExecPopMem p1_ValMem[SI]      
                    jmp Exit
                    notthispower1_popaddbx:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_popaddbx  
                    mov dx, p1_ValRegBX
                    CALL CheckAddress
                    cmp bl, 1               ;p2_Value is greater than 16
                    JZ InValidCommand
                    mov SI, p1_ValRegBX
                    ourExecPopMem p1_ValMem[SI]       
                    notthispower2_popaddbx:

                    mov dx,p2_ValRegBX
                    CALL CheckAddress
                    cmp bl, 1               ;p2_Value is greater than 16
                    JZ InValidCommand
                    mov SI,p2_ValRegBX
                    ExecPopMemp2_ValMem[SI]
                    JMP Exit
                PopOpAddRegBP:
                    cmp selectedPUPType,1 ;command on your own processor  
                    jne notthispower1_popaddbp  
                    mov dx, p1_ValRegBP
                    CALL CheckAddress
                    cmp bl, 1               ;p2_Value is greater than 16
                    JZ InValidCommand
                    mov SI, p1_ValRegBP
                    ourExecPopMem p1_ValMem[SI]      
                    jmp Exit
                    notthispower1_popaddbp:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_popaddbp  
                    mov dx, p1_ValRegBP
                    CALL CheckAddress
                    cmp bl, 1               ;p2_Value is greater than 16
                    JZ InValidCommand
                    mov SI, p1_ValRegBP
                    ourExecPopMem p1_ValMem[SI]       
                    notthispower2_popaddbp:

                    mov dx,p2_ValRegBP
                    CALL CheckAddress
                    cmp bl, 1               ;p2_Value is greater than 16
                    JZ InValidCommand
                    mov SI,p2_ValRegBP
                    ExecPopMemp2_ValMem[SI]
                    JMP Exit

                PopOpAddRegSI:
                    cmp selectedPUPType,1 ;command on your own processor  
                    jne notthispower1_popaddsi  
                    mov dx, p1_ValRegSI
                    CALL CheckAddress
                    cmp bl, 1               ;p2_Value is greater than 16
                    JZ InValidCommand
                    mov SI, p1_ValRegSI
                    ourExecPopMem p1_ValMem[SI]      
                    jmp Exit
                    notthispower1_popaddsi:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_popaddsi  
                    mov dx, p1_ValRegSI
                    CALL CheckAddress
                    cmp bl, 1               ;p2_Value is greater than 16
                    JZ InValidCommand
                    mov SI, p1_ValRegSI
                    ourExecPopMem p1_ValMem[SI]       
                    notthispower2_popaddsi:

                    mov dx,p2_ValRegSI
                    CALL CheckAddress
                    cmp bl, 1               ;p2_Value is greater than 16
                    JZ InValidCommand
                    mov SI,p2_ValRegSI
                    ExecPopMemp2_ValMem[SI]
                    JMP Exit
                
                PopOpAddRegDI:
                    cmp selectedPUPType,1 ;command on your own processor  
                    jne notthispower1_popadddi  
                    mov dx, p1_ValRegDI
                    CALL CheckAddress
                    cmp bl, 1               ;p2_Value is greater than 16
                    JZ InValidCommand
                    mov SI, p1_ValRegDI
                    ourExecPopMem p1_ValMem[SI]      
                    jmp Exit
                    notthispower1_popadddi:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_popadddi  
                    mov dx, p1_ValRegDI
                    CALL CheckAddress
                    cmp bl, 1               ;p2_Value is greater than 16
                    JZ InValidCommand
                    mov SI, p1_ValRegDI
                    ourExecPopMem p1_ValMem[SI]       
                    notthispower2_popadddi:

                    mov dx,p2_ValRegDI
                    CALL CheckAddress
                    cmp bl, 1               ;p2_Value is greater than 16
                    JZ InValidCommand
                    mov SI,p2_ValRegDI
                    ExecPopMemp2_ValMem[SI]
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
                    ExecINC p1_ValRegAX      
                    jmp Exit
                    notthispower1_incax:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_incax 
                    ExecINC p1_ValRegAX       
                    notthispower2_incax:
                    ExecINCp2_ValRegAX
                    JMP Exit
                IncOpRegAL:
                    cmp selectedPUPType,1 ;command on your own processor  
                    jne notthispower1_incal  
                    ExecINC p1_ValRegAX      
                    jmp Exit
                    notthispower1_incal:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_incal 
                    ExecINC p1_ValRegAX       
                    notthispower2_incal:
                    ExecINCp2_ValRegAX
                    JMP Exit
                IncOpRegAH:
                    cmp selectedPUPType,1 ;command on your own processor  
                    jne notthispower1_incah  
                    ExecINC p1_ValRegAX+1      
                    jmp Exit
                    notthispower1_incah:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_incah 
                    ExecINC p1_ValRegAX+1       
                    notthispower2_incah:
                    ExecINCp2_ValRegAX+1
                    JMP Exit
                IncOpRegBX:
                    cmp selectedPUPType,1 ;command on your own processor  
                    jne notthispower1_incbx  
                    ExecINC p1_ValRegBX      
                    jmp Exit
                    notthispower1_incbx:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_incbx 
                    ExecINC p1_ValRegBX       
                    notthispower2_incbx:
                    ExecINCp2_ValRegBX
                    JMP Exit
                IncOpRegBL:
                    cmp selectedPUPType,1 ;command on your own processor  
                    jne notthispower1_incbl  
                    ExecINC p1_ValRegBX      
                    jmp Exit
                    notthispower1_incbl:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_incbl 
                    ExecINC p1_ValRegBX       
                    notthispower2_incbl:
                    ExecINCp2_ValRegBX
                    JMP Exit
                IncOpRegBH:
                    cmp selectedPUPType,1 ;command on your own processor  
                    jne notthispower1_incbh  
                    ExecINC p1_ValRegBX+1      
                    jmp Exit
                    notthispower1_incbh:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_incbh 
                    ExecINC p1_ValRegBX+1       
                    notthispower2_incbh:
                    ExecINCp2_ValRegBX+1
                    JMP Exit
                IncOpRegCX:
                    cmp selectedPUPType,1 ;command on your own processor  
                    jne notthispower1_inccx  
                    ExecINC p1_ValRegCX      
                    jmp Exit
                    notthispower1_inccx:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_inccx 
                    ExecINC p1_ValRegCX       
                    notthispower2_inccx:
                    ExecINCp2_ValRegCX
                    JMP Exit
                IncOpRegCL:
                    cmp selectedPUPType,1 ;command on your own processor  
                    jne notthispower1_inccl  
                    ExecINC p1_ValRegCX      
                    jmp Exit
                    notthispower1_inccl:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_inccl 
                    ExecINC p1_ValRegCX       
                    notthispower2_inccl:
                    ExecINCp2_ValRegCX
                    JMP Exit
                IncOpRegCH:
                    cmp selectedPUPType,1 ;command on your own processor  
                    jne notthispower1_incch  
                    ExecINC p1_ValRegCX+1      
                    jmp Exit
                    notthispower1_incch:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_incch 
                    ExecINC p1_ValRegCX+1       
                    notthispower2_incch:
                    ExecINCp2_ValRegCX+1
                    JMP Exit
                IncOpRegDX:  
                    cmp selectedPUPType,1 ;command on your own processor  
                    jne notthispower1_incdx  
                    ExecINC p1_ValRegDX      
                    jmp Exit
                    notthispower1_incdx:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_incdx 
                    ExecINC p1_ValRegDX       
                    notthispower2_incdx:
                    ExecINCp2_ValRegDX
                    JMP Exit
                IncOpRegDL:
                    cmp selectedPUPType,1 ;command on your own processor  
                    jne notthispower1_incdl  
                    ExecINC p1_ValRegDX      
                    jmp Exit
                    notthispower1_incdl:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_incdl 
                    ExecINC p1_ValRegDX       
                    notthispower2_incdl:
                    ExecINCp2_ValRegDX
                    JMP Exit
                IncOpRegDH:
                    cmp selectedPUPType,1 ;command on your own processor  
                    jne notthispower1_incdh  
                    ExecINC p1_ValRegDX+1      
                    jmp Exit
                    notthispower1_incdh:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_incdh 
                    ExecINC p1_ValRegDX+1       
                    notthispower2_incdh:
                    ExecINCp2_ValRegDX+1
                    JMP Exit
                IncOpRegBP:
                    cmp selectedPUPType,1 ;command on your own processor  
                    jne notthispower1_incbp  
                    ExecINC p1_ValRegBP      
                    jmp Exit
                    notthispower1_incbp:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_incbp 
                    ExecINC p1_ValRegBP       
                    notthispower2_incbp:
                    ExecINCp2_ValRegBP
                    JMP Exit
                IncOpRegSP:
                    cmp selectedPUPType,1 ;command on your own processor  
                    jne notthispower1_incsp  
                    ExecINC p1_ValRegSP      
                    jmp Exit
                    notthispower1_incsp:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_incsp 
                    ExecINC p1_ValRegSP       
                    notthispower2_incsp:
                    ExecINCp2_ValRegSP
                    JMP Exit
                IncOpRegSI:
                    cmp selectedPUPType,1 ;command on your own processor  
                    jne notthispower1_incsi  
                    ExecINC p1_ValRegSI      
                    jmp Exit
                    notthispower1_incsi:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_incsi 
                    ExecINC p1_ValRegSI       
                    notthispower2_incsi:
                    ExecINCp2_ValRegSI
                    JMP Exit
                IncOpRegDI:
                    cmp selectedPUPType,1 ;command on your own processor  
                    jne notthispower1_incdi  
                    ExecINC p1_ValRegDI      
                    jmp Exit
                    notthispower1_incdi:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_incdi 
                    ExecINC p1_ValRegDI       
                    notthispower2_incdi:
                    ExecINCp2_ValRegDI
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
                    mov dx, p1_ValRegBX
                    CALL CheckAddress
                    cmp bl, 1
                    jz InValidCommand
                    mov di, p1_ValRegBX
                    ExecINC p1_ValMem[di]      
                    jmp Exit
                    notthispower1_incaddbx:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_incaddbx  
                    mov dx, p1_ValRegBX
                    CALL CheckAddress
                    cmp bl, 1
                    jz InValidCommand
                    mov di, p1_ValRegBX
                    ExecINC p1_ValMem[di]  
                    notthispower2_incaddbx:

                    mov dx,p2_ValRegBX
                    CALL CheckAddress
                    cmp bl, 1
                    jz InValidCommand
                    mov di,p2_ValRegBX
                    ExecINCp2_ValMem[di]
                    JMP Exit
                IncOpAddRegBP:
                    cmp selectedPUPType,1 ;command on your own processor  
                    jne notthispower1_incaddbp  
                    mov dx, p1_ValRegBP
                    CALL CheckAddress
                    cmp bl, 1
                    jz InValidCommand
                    mov di, p1_ValRegBP
                    ExecINC p1_ValMem[di]      
                    jmp Exit
                    notthispower1_incaddbp:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_incaddbp  
                    mov dx, p1_ValRegBP
                    CALL CheckAddress
                    cmp bl, 1
                    jz InValidCommand
                    mov di, p1_ValRegBP
                    ExecINC p1_ValMem[di]  
                    notthispower2_incaddbp:

                    mov dx,p2_ValRegBP
                    CALL CheckAddress
                    cmp bl, 1
                    jz InValidCommand
                    mov di,p2_ValRegBP
                    ExecINCp2_ValMem[di]
                    JMP Exit
                IncOpAddRegSP:
                    cmp selectedPUPType,1 ;command on your own processor  
                    jne notthispower1_incaddsp  
                    mov dx, p1_ValRegSP
                    CALL CheckAddress
                    cmp bl, 1
                    jz InValidCommand
                    mov di, p1_ValRegSP
                    ExecINC p1_ValMem[di]      
                    jmp Exit
                    notthispower1_incaddsp:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_incaddsp  
                    mov dx, p1_ValRegSP
                    CALL CheckAddress
                    cmp bl, 1
                    jz InValidCommand
                    mov di, p1_ValRegSP
                    ExecINC p1_ValMem[di]  
                    notthispower2_incaddsp:

                    mov dx,p2_ValRegSP
                    CALL CheckAddress
                    cmp bl, 1
                    jz InValidCommand
                    mov di,p2_ValRegSP
                    ExecINCp2_ValMem[di]
                    JMP Exit
                IncOpAddRegSI:
                    cmp selectedPUPType,1 ;command on your own processor  
                    jne notthispower1_incaddsi  
                    mov dx, p1_ValRegSI
                    CALL CheckAddress
                    cmp bl, 1
                    jz InValidCommand
                    mov di, p1_ValRegSI
                    ExecINC p1_ValMem[di]      
                    jmp Exit
                    notthispower1_incaddsi:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_incaddsi 
                    mov dx, p1_ValRegSI
                    CALL CheckAddress
                    cmp bl, 1
                    jz InValidCommand
                    mov di, p1_ValRegSI
                    ExecINC p1_ValMem[di]  
                    notthispower2_incaddsi:

                    mov dx,p2_ValRegSI
                    CALL CheckAddress
                    cmp bl, 1
                    jz InValidCommand
                    mov di,p2_ValRegSI
                    ExecINCp2_ValMem[di]
                    JMP Exit
                IncOpAddRegDI:
                    cmp selectedPUPType,1 ;command on your own processor  
                    jne notthispower1_incadddi  
                    mov dx, p1_ValRegDI
                    CALL CheckAddress
                    cmp bl, 1
                    jz InValidCommand
                    mov di, p1_ValRegDI
                    ExecINC p1_ValMem[di]      
                    jmp Exit
                    notthispower1_incadddi:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_incadddi 
                    mov dx, p1_ValRegDI
                    CALL CheckAddress
                    cmp bl, 1
                    jz InValidCommand
                    mov di, p1_ValRegDI
                    ExecINC p1_ValMem[di]  
                    notthispower2_incadddi:

                    mov dx,p2_ValRegDI
                    CALL CheckAddress
                    cmp bl, 1
                    jz InValidCommand
                    mov di,p2_ValRegDI
                    ExecINCp2_ValMem[di]
                    JMP Exit

            IncOpMem:

                    mov si,0
                    SearchForMeminc:
                    mov cx,si 
                    cmp selectedOp2Mem,cl
                    JNE Nextinc
                    cmp selectedPUPType,1 ; our command
                    jne notthispower1_incmem
                    ExecINC p1_ValMem[si] ; command
                    jmp Exit
                    notthispower1_incmem:  
                    cmp selectedPUPType,2 ;his/her and our command 
                    jne notthispower2_incmem 
                    ExecINC p1_ValMem[si] ;command
                    notthispower2_incmem: 
                    ExecINCp2_ValMem[si]
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
                    Execdec p1_ValRegAX      
                    jmp Exit
                    notthispower1_decax:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_decax 
                    Execdec p1_ValRegAX       
                    notthispower2_decax:
                    Execdecp2_ValRegAX
                    JMP Exit
                decOpRegAL:
                    cmp selectedPUPType,1 ;command on your own processor  
                    jne notthispower1_decal  
                    Execdec p1_ValRegAX      
                    jmp Exit
                    notthispower1_decal:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_decal 
                    Execdec p1_ValRegAX       
                    notthispower2_decal:
                    Execdecp2_ValRegAX
                    JMP Exit
                decOpRegAH:
                    cmp selectedPUPType,1 ;command on your own processor  
                    jne notthispower1_decah  
                    Execdec p1_ValRegAX+1      
                    jmp Exit
                    notthispower1_decah:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_decah 
                    Execdec p1_ValRegAX+1       
                    notthispower2_decah:
                    Execdecp2_ValRegAX+1
                    JMP Exit
                decOpRegBX:
                    cmp selectedPUPType,1 ;command on your own processor  
                    jne notthispower1_decbx  
                    Execdec p1_ValRegBX      
                    jmp Exit
                    notthispower1_decbx:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_decbx 
                    Execdec p1_ValRegBX       
                    notthispower2_decbx:
                    Execdecp2_ValRegBX
                    JMP Exit
                decOpRegBL:
                    cmp selectedPUPType,1 ;command on your own processor  
                    jne notthispower1_decbl  
                    Execdec p1_ValRegBX      
                    jmp Exit
                    notthispower1_decbl:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_decbl 
                    Execdec p1_ValRegBX       
                    notthispower2_decbl:
                    Execdecp2_ValRegBX
                    JMP Exit
                decOpRegBH:
                    cmp selectedPUPType,1 ;command on your own processor  
                    jne notthispower1_decbh  
                    Execdec p1_ValRegBX+1      
                    jmp Exit
                    notthispower1_decbh:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_decbh 
                    Execdec p1_ValRegBX+1       
                    notthispower2_decbh:
                    Execdecp2_ValRegBX+1
                    JMP Exit
                decOpRegCX:
                    cmp selectedPUPType,1 ;command on your own processor  
                    jne notthispower1_deccx  
                    Execdec p1_ValRegCX      
                    jmp Exit
                    notthispower1_deccx:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_deccx 
                    Execdec p1_ValRegCX       
                    notthispower2_deccx:
                    Execdecp2_ValRegCX
                    JMP Exit
                decOpRegCL:
                    cmp selectedPUPType,1 ;command on your own processor  
                    jne notthispower1_deccl  
                    Execdec p1_ValRegCX      
                    jmp Exit
                    notthispower1_deccl:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_deccl 
                    Execdec p1_ValRegCX       
                    notthispower2_deccl:
                    Execdecp2_ValRegCX
                    JMP Exit
                decOpRegCH:
                    cmp selectedPUPType,1 ;command on your own processor  
                    jne notthispower1_decch  
                    Execdec p1_ValRegCX+1      
                    jmp Exit
                    notthispower1_decch:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_decch 
                    Execdec p1_ValRegCX+1       
                    notthispower2_decch:
                    Execdecp2_ValRegCX+1
                    JMP Exit
                decOpRegDX:  
                    cmp selectedPUPType,1 ;command on your own processor  
                    jne notthispower1_decdx  
                    Execdec p1_ValRegDX      
                    jmp Exit
                    notthispower1_decdx:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_decdx 
                    Execdec p1_ValRegDX       
                    notthispower2_decdx:
                    Execdecp2_ValRegDX
                    JMP Exit
                decOpRegDL:
                    cmp selectedPUPType,1 ;command on your own processor  
                    jne notthispower1_decdl  
                    Execdec p1_ValRegDX      
                    jmp Exit
                    notthispower1_decdl:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_decdl 
                    Execdec p1_ValRegDX       
                    notthispower2_decdl:
                    Execdecp2_ValRegDX
                    JMP Exit
                decOpRegDH:
                    cmp selectedPUPType,1 ;command on your own processor  
                    jne notthispower1_decdh  
                    Execdec p1_ValRegDX+1      
                    jmp Exit
                    notthispower1_decdh:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_decdh 
                    Execdec p1_ValRegDX+1       
                    notthispower2_decdh:
                    Execdecp2_ValRegDX+1
                    JMP Exit
                decOpRegBP:
                    cmp selectedPUPType,1 ;command on your own processor  
                    jne notthispower1_decbp  
                    Execdec p1_ValRegBP      
                    jmp Exit
                    notthispower1_decbp:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_decbp 
                    Execdec p1_ValRegBP       
                    notthispower2_decbp:
                    Execdecp2_ValRegBP
                    JMP Exit
                decOpRegSP:
                    cmp selectedPUPType,1 ;command on your own processor  
                    jne notthispower1_decsp  
                    Execdec p1_ValRegSP      
                    jmp Exit
                    notthispower1_decsp:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_decsp 
                    Execdec p1_ValRegSP       
                    notthispower2_decsp:
                    Execdecp2_ValRegSP
                    JMP Exit
                decOpRegSI:
                    cmp selectedPUPType,1 ;command on your own processor  
                    jne notthispower1_decsi  
                    Execdec p1_ValRegSI      
                    jmp Exit
                    notthispower1_decsi:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_decsi 
                    Execdec p1_ValRegSI       
                    notthispower2_decsi:
                    Execdecp2_ValRegSI
                    JMP Exit
                decOpRegDI:
                    cmp selectedPUPType,1 ;command on your own processor  
                    jne notthispower1_decdi  
                    Execdec p1_ValRegDI      
                    jmp Exit
                    notthispower1_decdi:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_decdi 
                    Execdec p1_ValRegDI       
                    notthispower2_decdi:
                    Execdecp2_ValRegDI
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
                    mov dx, p1_ValRegBX
                    CALL CheckAddress
                    cmp bl, 1
                    jz InValidCommand
                    mov di, p1_ValRegBX
                    Execdec p1_ValMem[di]      
                    jmp Exit
                    notthispower1_decaddbx:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_decaddbx  
                    mov dx, p1_ValRegBX
                    CALL CheckAddress
                    cmp bl, 1
                    jz InValidCommand
                    mov di, p1_ValRegBX
                    Execdec p1_ValMem[di]  
                    notthispower2_decaddbx:

                    mov dx,p2_ValRegBX
                    CALL CheckAddress
                    cmp bl, 1
                    jz InValidCommand
                    mov di,p2_ValRegBX
                    Execdecp2_ValMem[di]
                    JMP Exit
                decOpAddRegBP:
                    cmp selectedPUPType,1 ;command on your own processor  
                    jne notthispower1_decaddbp  
                    mov dx, p1_ValRegBP
                    CALL CheckAddress
                    cmp bl, 1
                    jz InValidCommand
                    mov di, p1_ValRegBP
                    Execdec p1_ValMem[di]      
                    jmp Exit
                    notthispower1_decaddbp:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_decaddbp  
                    mov dx, p1_ValRegBP
                    CALL CheckAddress
                    cmp bl, 1
                    jz InValidCommand
                    mov di, p1_ValRegBP
                    Execdec p1_ValMem[di]  
                    notthispower2_decaddbp:

                    mov dx,p2_ValRegBP
                    CALL CheckAddress
                    cmp bl, 1
                    jz InValidCommand
                    mov di,p2_ValRegBP
                    Execdecp2_ValMem[di]
                    JMP Exit
                decOpAddRegSP:
                    cmp selectedPUPType,1 ;command on your own processor  
                    jne notthispower1_decaddsp  
                    mov dx, p1_ValRegSP
                    CALL CheckAddress
                    cmp bl, 1
                    jz InValidCommand
                    mov di, p1_ValRegSP
                    Execdec p1_ValMem[di]      
                    jmp Exit
                    notthispower1_decaddsp:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_decaddsp  
                    mov dx, p1_ValRegSP
                    CALL CheckAddress
                    cmp bl, 1
                    jz InValidCommand
                    mov di, p1_ValRegSP
                    Execdec p1_ValMem[di]  
                    notthispower2_decaddsp:

                    mov dx,p2_ValRegSP
                    CALL CheckAddress
                    cmp bl, 1
                    jz InValidCommand
                    mov di,p2_ValRegSP
                    Execdecp2_ValMem[di]
                    JMP Exit
                decOpAddRegSI:
                    cmp selectedPUPType,1 ;command on your own processor  
                    jne notthispower1_decaddsi  
                    mov dx, p1_ValRegSI
                    CALL CheckAddress
                    cmp bl, 1
                    jz InValidCommand
                    mov di, p1_ValRegSI
                    Execdec p1_ValMem[di]      
                    jmp Exit
                    notthispower1_decaddsi:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_decaddsi 
                    mov dx, p1_ValRegSI
                    CALL CheckAddress
                    cmp bl, 1
                    jz InValidCommand
                    mov di, p1_ValRegSI
                    Execdec p1_ValMem[di]  
                    notthispower2_decaddsi:

                    mov dx,p2_ValRegSI
                    CALL CheckAddress
                    cmp bl, 1
                    jz InValidCommand
                    mov di,p2_ValRegSI
                    Execdecp2_ValMem[di]
                    JMP Exit
                decOpAddRegDI:
                    cmp selectedPUPType,1 ;command on your own processor  
                    jne notthispower1_decadddi  
                    mov dx, p1_ValRegDI
                    CALL CheckAddress
                    cmp bl, 1
                    jz InValidCommand
                    mov di, p1_ValRegDI
                    Execdec p1_ValMem[di]      
                    jmp Exit
                    notthispower1_decadddi:
                    cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
                    jne notthispower2_decadddi 
                    mov dx, p1_ValRegDI
                    CALL CheckAddress
                    cmp bl, 1
                    jz InValidCommand
                    mov di, p1_ValRegDI
                    Execdec p1_ValMem[di]  
                    notthispower2_decadddi:

                    mov dx,p2_ValRegDI
                    CALL CheckAddress
                    cmp bl, 1
                    jz InValidCommand
                    mov di,p2_ValRegDI
                    Execdecp2_ValMem[di]
                    JMP Exit

            decOpMem:
            
                    mov si,0
                    SearchForMemdec:
                    mov cx,si 
                    cmp selectedOp2Mem,cl
                    JNE Nextdec
                    cmp selectedPUPType,1 ; our command
                    jne notthispower1_decmem
                    Execdec p1_ValMem[si] ; command
                    jmp Exit
                    notthispower1_decmem:  
                    cmp selectedPUPType,2 ;his/her and our command 
                    jne notthispower2_decmem 
                    Execdec p1_ValMem[si] ;command
                    notthispower2_decmem: 
                    Execdecp2_ValMem[si]
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
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegDX
                    MUL ax
                    mov p1_ValRegAX,ax
                    mov p1_ValRegDX,dx
                    jmp Exit
                    MUL_Ax_his:
                    mov ax,ValRegAX
                    mov dx,ValRegDX
                    call LineStuckPwrUp
                    MUL ax
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
                    cmp selectedPUPType,2
                    je MUL_Ax_our
                    jmp Exit
                MUL_Al:
                    cmp selectedPUPType,1
                    jne MUL_Al_his
                    MUL_Al_our:
                    mov ax,p1_ValRegAX
                    MUL al
                    mov p1_ValRegAX,ax
                    jmp Exit
                    MUL_Al_his:
                    mov ax,ValRegAX
                    call LineStuckPwrUp
                    MUL al
                    movp2_ValRegAX,ax
                    cmp selectedPUPType,2
                    je MUL_Al_our
                    jmp Exit
                MUL_Ah:
                    cmp selectedPUPType,1
                    jne MUL_Ah_his
                    MUL_Ah_our:
                    mov ax,p1_ValRegAX
                    MUL ah
                    mov p1_ValRegAX,ax
                    jmp Exit
                    MUL_Ah_his:
                    mov ax,ValRegAX
                    mov al,ah
                    call LineStuckPwrUp
                    MUL al
                    movp2_ValRegAX,ax
                    cmp selectedPUPType,2
                    je MUL_Ah_our
                    jmp Exit
                MUL_Bx:
                    cmp selectedPUPType,1
                    jne MUL_Bx_his
                    MUL_Bx_our:
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegDX
                    mov bx,p1_ValRegBX
                    MUL bx
                    mov p1_ValRegAX,ax
                    mov p1_ValRegDX,dx
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
                    cmp selectedPUPType,2
                    je MUL_Bx_our
                    jmp Exit
                MUL_Bl:
                    cmp selectedPUPType,1
                    jne MUL_Bl_his
                    MUL_Bl_our:
                    mov ax,p1_ValRegAX
                    mov bx,p1_ValRegBX
                    MUL bl
                    mov p1_ValRegAX,ax
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
                    movp2_ValRegAX,ax
                    cmp selectedPUPType,2
                    je MUL_Bl_our
                    jmp Exit
                MUL_Bh:
                    cmp selectedPUPType,1
                    jne MUL_Bh_his
                    MUL_Bh_our:
                    mov ax,p1_ValRegAX
                    mov bx,p1_ValRegBX
                    MUL Bh
                    mov p1_ValRegAX,ax
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
                    movp2_ValRegAX,ax
                    cmp selectedPUPType,2
                    je MUL_Bh_our
                    jmp Exit
                MUL_Cx:
                    cmp selectedPUPType,1
                    jne MUL_Cx_his
                    MUL_Cx_our:
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegDX
                    mov Cx,p1_ValRegCx
                    MUL Cx
                    mov p1_ValRegAX,ax
                    mov p1_ValRegDX,dx
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
                    cmp selectedPUPType,2
                    je MUL_Cx_our
                    jmp Exit
                MUL_Cl:
                    cmp selectedPUPType,1
                    jne MUL_Cl_his
                    MUL_Cl_our:
                    mov ax,p1_ValRegAX
                    mov Cx,p1_ValRegCx
                    MUL Cl
                    mov p1_ValRegAX,ax
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
                    movp2_ValRegAX,ax
                    cmp selectedPUPType,2
                    je MUL_Cl_our
                    jmp Exit
                MUL_Ch:
                    cmp selectedPUPType,1
                    jne MUL_Ch_his
                    MUL_Ch_our:
                    mov ax,p1_ValRegAX
                    mov Cx,p1_ValRegCx
                    MUL Ch
                    mov p1_ValRegAX,ax
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
                    movp2_ValRegAX,ax
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
                    cmp selectedPUPType,2
                    je MUL_Dx_our
                    jmp Exit
                MUL_Dl:
                    cmp selectedPUPType,1
                    jne MUL_Dl_his
                    MUL_Dl_our:
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegBX
                    MUL dl
                    mov p1_ValRegAX,ax
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
                    movp2_ValRegAX,ax
                    cmp selectedPUPType,2
                    je MUL_Dl_our
                    jmp Exit
                MUL_Dh:
                    cmp selectedPUPType,1
                    jne MUL_Dh_his
                    MUL_Dh_our:
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegBX
                    MUL Dh
                    mov p1_ValRegAX,ax
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
                    movp2_ValRegAX,ax
                    cmp selectedPUPType,2
                    je MUL_Dh_our
                    jmp Exit
                MUL_Bp:
                    cmp selectedPUPType,1
                    jne MUL_Bp_his
                    MUL_Bp_our:
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegDX
                    mov Bp,p1_ValRegBp
                    MUL Bp
                    mov p1_ValRegAX,ax
                    mov p1_ValRegDX,dx
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
                    cmp selectedPUPType,2
                    je MUL_Bp_our
                    jmp Exit
                MUL_Sp:
                    cmp selectedPUPType,1
                    jne MUL_Sp_his
                    MUL_Sp_our:
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegDX
                    mov Sp,p1_ValRegSp
                    MUL Sp
                    mov p1_ValRegAX,ax
                    mov p1_ValRegDX,dx
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
                    cmp selectedPUPType,2
                    je MUL_Sp_our
                    jmp Exit
                MUL_Si:
                    cmp selectedPUPType,1
                    jne MUL_Si_his
                    MUL_Si_our:
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegDX
                    mov Si,p1_ValRegSi
                    MUL Si
                    mov p1_ValRegAX,ax
                    mov p1_ValRegDX,dx
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
                    cmp selectedPUPType,2
                    je MUL_Si_our
                    jmp Exit
                MUL_di:
                    MUL_Di:
                    cmp selectedPUPType,1
                    jne MUL_Di_his
                    MUL_Di_our:
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegDX
                    mov Di,p1_ValRegDi
                    MUL Di
                    mov p1_ValRegAX,ax
                    mov p1_ValRegDX,dx
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
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
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegDX
                    mov bx,p1_ValRegBX
                    cmp bx,15d
                    ja MUL_invalid
                    MUL p1_ValMem[bx]
                    mov p1_ValRegAX,ax
                    mov p1_ValRegDX,dx
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
                    cmp selectedPUPType,2
                    je MUL_AddBx_our
                    jmp Exit
                MUL_AddBp:
                    cmp selectedPUPType,1
                    jne MUL_AddBp_his
                    MUL_AddBp_our:
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegDX
                    mov Bp,p1_ValRegBp
                    cmp Bp,15d
                    ja MUL_invalid
                    MUL p1_ValMem[bp]
                    mov p1_ValRegAX,ax
                    mov p1_ValRegDX,dx
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
                    cmp selectedPUPType,2
                    je MUL_AddBp_our
                    jmp Exit
                MUL_AddSi:
                    cmp selectedPUPType,1
                    jne MUL_AddSi_his
                    MUL_AddSi_our:
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegDX
                    mov Si,p1_ValRegSi
                    cmp Si,15d
                    ja MUL_invalid
                    MUL p1_ValMem[si]
                    mov p1_ValRegAX,ax
                    mov p1_ValRegDX,dx
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
                    cmp selectedPUPType,2
                    je MUL_AddSi_our
                    jmp Exit
                MUL_AddDi:
                    cmp selectedPUPType,1
                    jne MUL_AddDi_his
                    MUL_AddDi_our:
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegDX
                    mov Di,p1_ValRegDi
                    cmp Di,15d
                    ja MUL_invalid
                    MUL p1_ValMem[di]
                    mov p1_ValRegAX,ax
                    mov p1_ValRegDX,dx
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
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
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegDX
                    MUL p1_ValMem[si]
                    mov p1_ValRegAX,ax
                    mov p1_ValRegDX,dx
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
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

            call  PowerUpeMenu ; to choose power up
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
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegDX
                    DIV ax
                    mov p1_ValRegAX,ax
                    mov p1_ValRegDX,dx
                    jmp Exit
                    DIV_Ax_his:
                    mov ax,ValRegAX
                    mov dx,ValRegDX
                    call LineStuckPwrUp
                    DIV ax
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
                    cmp selectedPUPType,2
                    je DIV_Ax_our
                    jmp Exit
                DIV_Al:
                    cmp selectedPUPType,1
                    jne DIV_Al_his
                    DIV_Al_our:
                    mov ax,p1_ValRegAX
                    DIV al
                    mov p1_ValRegAX,ax
                    jmp Exit
                    DIV_Al_his:
                    mov ax,ValRegAX
                    call LineStuckPwrUp
                    DIV al
                    movp2_ValRegAX,ax
                    cmp selectedPUPType,2
                    je DIV_Al_our
                    jmp Exit
                DIV_Ah:
                    cmp selectedPUPType,1
                    jne DIV_Ah_his
                    DIV_Ah_our:
                    mov ax,p1_ValRegAX
                    DIV ah
                    mov p1_ValRegAX,ax
                    jmp Exit
                    DIV_Ah_his:
                    mov ax,ValRegAX
                    mov al,ah
                    call LineStuckPwrUp
                    DIV al
                    movp2_ValRegAX,ax
                    cmp selectedPUPType,2
                    je DIV_Ah_our
                    jmp Exit
                DIV_Bx:
                    cmp selectedPUPType,1
                    jne DIV_Bx_his
                    DIV_Bx_our:
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegDX
                    mov bx,p1_ValRegBX
                    DIV bx
                    mov p1_ValRegAX,ax
                    mov p1_ValRegDX,dx
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
                    cmp selectedPUPType,2
                    je DIV_Bx_our
                    jmp Exit
                DIV_Bl:
                    cmp selectedPUPType,1
                    jne DIV_Bl_his
                    DIV_Bl_our:
                    mov ax,p1_ValRegAX
                    mov bx,p1_ValRegBX
                    DIV bl
                    mov p1_ValRegAX,ax
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
                    movp2_ValRegAX,ax
                    cmp selectedPUPType,2
                    je DIV_Bl_our
                    jmp Exit
                DIV_Bh:
                    cmp selectedPUPType,1
                    jne DIV_Bh_his
                    DIV_Bh_our:
                    mov ax,p1_ValRegAX
                    mov bx,p1_ValRegBX
                    DIV Bh
                    mov p1_ValRegAX,ax
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
                    movp2_ValRegAX,ax
                    cmp selectedPUPType,2
                    je DIV_Bh_our
                    jmp Exit
                DIV_Cx:
                    cmp selectedPUPType,1
                    jne DIV_Cx_his
                    DIV_Cx_our:
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegDX
                    mov Cx,p1_ValRegCx
                    DIV Cx
                    mov p1_ValRegAX,ax
                    mov p1_ValRegDX,dx
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
                    cmp selectedPUPType,2
                    je DIV_Cx_our
                    jmp Exit
                DIV_Cl:
                    cmp selectedPUPType,1
                    jne DIV_Cl_his
                    DIV_Cl_our:
                    mov ax,p1_ValRegAX
                    mov Cx,p1_ValRegCx
                    DIV Cl
                    mov p1_ValRegAX,ax
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
                    movp2_ValRegAX,ax
                    cmp selectedPUPType,2
                    je DIV_Cl_our
                    jmp Exit
                DIV_Ch:
                    cmp selectedPUPType,1
                    jne DIV_Ch_his
                    DIV_Ch_our:
                    mov ax,p1_ValRegAX
                    mov Cx,p1_ValRegCx
                    DIV Ch
                    mov p1_ValRegAX,ax
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
                    movp2_ValRegAX,ax
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
                    cmp selectedPUPType,2
                    je DIV_Dx_our
                    jmp Exit
                DIV_Dl:
                    cmp selectedPUPType,1
                    jne DIV_Dl_his
                    DIV_Dl_our:
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegBX
                    DIV dl
                    mov p1_ValRegAX,ax
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
                    movp2_ValRegAX,ax
                    cmp selectedPUPType,2
                    je DIV_Dl_our
                    jmp Exit
                DIV_Dh:
                    cmp selectedPUPType,1
                    jne DIV_Dh_his
                    DIV_Dh_our:
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegBX
                    DIV Dh
                    mov p1_ValRegAX,ax
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
                    movp2_ValRegAX,ax
                    cmp selectedPUPType,2
                    je DIV_Dh_our
                    jmp Exit
                DIV_Bp:
                    cmp selectedPUPType,1
                    jne DIV_Bp_his
                    DIV_Bp_our:
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegDX
                    mov Bp,p1_ValRegBp
                    DIV Bp
                    mov p1_ValRegAX,ax
                    mov p1_ValRegDX,dx
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
                    cmp selectedPUPType,2
                    je DIV_Bp_our
                    jmp Exit
                DIV_Sp:
                    cmp selectedPUPType,1
                    jne DIV_Sp_his
                    DIV_Sp_our:
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegDX
                    mov Sp,p1_ValRegSp
                    DIV Sp
                    mov p1_ValRegAX,ax
                    mov p1_ValRegDX,dx
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
                    cmp selectedPUPType,2
                    je DIV_Sp_our
                    jmp Exit
                DIV_Si:
                    cmp selectedPUPType,1
                    jne DIV_Si_his
                    DIV_Si_our:
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegDX
                    mov Si,p1_ValRegSi
                    DIV Si
                    mov p1_ValRegAX,ax
                    mov p1_ValRegDX,dx
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
                    cmp selectedPUPType,2
                    je DIV_Si_our
                    jmp Exit
                DIV_di:
                    DIV_Di:
                    cmp selectedPUPType,1
                    jne DIV_Di_his
                    DIV_Di_our:
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegDX
                    mov Di,p1_ValRegDi
                    DIV Di
                    mov p1_ValRegAX,ax
                    mov p1_ValRegDX,dx
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
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
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegDX
                    mov bx,p1_ValRegBX
                    cmp bx,15d
                    ja DIV_invalid
                    DIV p1_ValMem[bx]
                    mov p1_ValRegAX,ax
                    mov p1_ValRegDX,dx
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
                    cmp selectedPUPType,2
                    je DIV_AddBx_our
                    jmp Exit
                DIV_AddBp:
                    cmp selectedPUPType,1
                    jne DIV_AddBp_his
                    DIV_AddBp_our:
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegDX
                    mov Bp,p1_ValRegBp
                    cmp Bp,15d
                    ja DIV_invalid
                    DIV p1_ValMem[bp]
                    mov p1_ValRegAX,ax
                    mov p1_ValRegDX,dx
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
                    cmp selectedPUPType,2
                    je DIV_AddBp_our
                    jmp Exit
                DIV_AddSi:
                    cmp selectedPUPType,1
                    jne DIV_AddSi_his
                    DIV_AddSi_our:
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegDX
                    mov Si,p1_ValRegSi
                    cmp Si,15d
                    ja DIV_invalid
                    DIV p1_ValMem[si]
                    mov p1_ValRegAX,ax
                    mov p1_ValRegDX,dx
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
                    cmp selectedPUPType,2
                    je DIV_AddSi_our
                    jmp Exit
                DIV_AddDi:
                    cmp selectedPUPType,1
                    jne DIV_AddDi_his
                    DIV_AddDi_our:
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegDX
                    mov Di,p1_ValRegDi
                    cmp Di,15d
                    ja DIV_invalid
                    DIV p1_ValMem[di]
                    mov p1_ValRegAX,ax
                    mov p1_ValRegDX,dx
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
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
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegDX
                    DIV p1_ValMem[si]
                    mov p1_ValRegAX,ax
                    mov p1_ValRegDX,dx
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
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
                    cmp selectedPUPType,1
                    jne IMul_Ax_his
                    IMul_Ax_our:
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegDX
                    IMul ax
                    mov p1_ValRegAX,ax
                    mov p1_ValRegDX,dx
                    jmp Exit
                    IMul_Ax_his:
                    mov ax,ValRegAX
                    mov dx,ValRegDX
                    call LineStuckPwrUp
                    IMul ax
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
                    cmp selectedPUPType,2
                    je IMul_Ax_our
                    jmp Exit
                IMul_Al:
                    cmp selectedPUPType,1
                    jne IMul_Al_his
                    IMul_Al_our:
                    mov ax,p1_ValRegAX
                    IMul al
                    mov p1_ValRegAX,ax
                    jmp Exit
                    IMul_Al_his:
                    mov ax,ValRegAX
                    call LineStuckPwrUp
                    IMul al
                    movp2_ValRegAX,ax
                    cmp selectedPUPType,2
                    je IMul_Al_our
                    jmp Exit
                IMul_Ah:
                    cmp selectedPUPType,1
                    jne IMul_Ah_his
                    IMul_Ah_our:
                    mov ax,p1_ValRegAX
                    IMul ah
                    mov p1_ValRegAX,ax
                    jmp Exit
                    IMul_Ah_his:
                    mov ax,ValRegAX
                    mov al,ah
                    call LineStuckPwrUp
                    IMul al
                    movp2_ValRegAX,ax
                    cmp selectedPUPType,2
                    je IMul_Ah_our
                    jmp Exit
                IMul_Bx:
                    cmp selectedPUPType,1
                    jne IMul_Bx_his
                    IMul_Bx_our:
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegDX
                    mov bx,p1_ValRegBX
                    IMul bx
                    mov p1_ValRegAX,ax
                    mov p1_ValRegDX,dx
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
                    cmp selectedPUPType,2
                    je IMul_Bx_our
                    jmp Exit
                IMul_Bl:
                    cmp selectedPUPType,1
                    jne IMul_Bl_his
                    IMul_Bl_our:
                    mov ax,p1_ValRegAX
                    mov bx,p1_ValRegBX
                    IMul bl
                    mov p1_ValRegAX,ax
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
                    movp2_ValRegAX,ax
                    cmp selectedPUPType,2
                    je IMul_Bl_our
                    jmp Exit
                IMul_Bh:
                    cmp selectedPUPType,1
                    jne IMul_Bh_his
                    IMul_Bh_our:
                    mov ax,p1_ValRegAX
                    mov bx,p1_ValRegBX
                    IMul Bh
                    mov p1_ValRegAX,ax
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
                    movp2_ValRegAX,ax
                    cmp selectedPUPType,2
                    je IMul_Bh_our
                    jmp Exit
                IMul_Cx:
                    cmp selectedPUPType,1
                    jne IMul_Cx_his
                    IMul_Cx_our:
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegDX
                    mov Cx,p1_ValRegCx
                    IMul Cx
                    mov p1_ValRegAX,ax
                    mov p1_ValRegDX,dx
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
                    cmp selectedPUPType,2
                    je IMul_Cx_our
                    jmp Exit
                IMul_Cl:
                    cmp selectedPUPType,1
                    jne IMul_Cl_his
                    IMul_Cl_our:
                    mov ax,p1_ValRegAX
                    mov Cx,p1_ValRegCx
                    IMul Cl
                    mov p1_ValRegAX,ax
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
                    movp2_ValRegAX,ax
                    cmp selectedPUPType,2
                    je IMul_Cl_our
                    jmp Exit
                IMul_Ch:
                    cmp selectedPUPType,1
                    jne IMul_Ch_his
                    IMul_Ch_our:
                    mov ax,p1_ValRegAX
                    mov Cx,p1_ValRegCx
                    IMul Ch
                    mov p1_ValRegAX,ax
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
                    movp2_ValRegAX,ax
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
                    cmp selectedPUPType,2
                    je IMul_Dx_our
                    jmp Exit
                IMul_Dl:
                    cmp selectedPUPType,1
                    jne IMul_Dl_his
                    IMul_Dl_our:
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegBX
                    IMul dl
                    mov p1_ValRegAX,ax
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
                    movp2_ValRegAX,ax
                    cmp selectedPUPType,2
                    je IMul_Dl_our
                    jmp Exit
                IMul_Dh:
                    cmp selectedPUPType,1
                    jne IMul_Dh_his
                    IMul_Dh_our:
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegBX
                    IMul Dh
                    mov p1_ValRegAX,ax
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
                    movp2_ValRegAX,ax
                    cmp selectedPUPType,2
                    je IMul_Dh_our
                    jmp Exit
                IMul_Bp:
                    cmp selectedPUPType,1
                    jne IMul_Bp_his
                    IMul_Bp_our:
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegDX
                    mov Bp,p1_ValRegBp
                    IMul Bp
                    mov p1_ValRegAX,ax
                    mov p1_ValRegDX,dx
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
                    cmp selectedPUPType,2
                    je IMul_Bp_our
                    jmp Exit
                IMul_Sp:
                    cmp selectedPUPType,1
                    jne IMul_Sp_his
                    IMul_Sp_our:
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegDX
                    mov Sp,p1_ValRegSp
                    IMul Sp
                    mov p1_ValRegAX,ax
                    mov p1_ValRegDX,dx
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
                    cmp selectedPUPType,2
                    je IMul_Sp_our
                    jmp Exit
                IMul_Si:
                    cmp selectedPUPType,1
                    jne IMul_Si_his
                    IMul_Si_our:
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegDX
                    mov Si,p1_ValRegSi
                    IMul Si
                    mov p1_ValRegAX,ax
                    mov p1_ValRegDX,dx
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
                    cmp selectedPUPType,2
                    je IMul_Si_our
                    jmp Exit
                IMul_di:
                    IMul_Di:
                    cmp selectedPUPType,1
                    jne IMul_Di_his
                    IMul_Di_our:
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegDX
                    mov Di,p1_ValRegDi
                    IMul Di
                    mov p1_ValRegAX,ax
                    mov p1_ValRegDX,dx
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
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
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegDX
                    mov bx,p1_ValRegBX
                    cmp bx,15d
                    ja IMul_invalid
                    IMul p1_ValMem[bx]
                    mov p1_ValRegAX,ax
                    mov p1_ValRegDX,dx
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
                    cmp selectedPUPType,2
                    je IMul_AddBx_our
                    jmp Exit
                IMul_AddBp:
                    cmp selectedPUPType,1
                    jne IMul_AddBp_his
                    IMul_AddBp_our:
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegDX
                    mov Bp,p1_ValRegBp
                    cmp Bp,15d
                    ja IMul_invalid
                    IMul p1_ValMem[bp]
                    mov p1_ValRegAX,ax
                    mov p1_ValRegDX,dx
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
                    cmp selectedPUPType,2
                    je IMul_AddBp_our
                    jmp Exit
                IMul_AddSi:
                    cmp selectedPUPType,1
                    jne IMul_AddSi_his
                    IMul_AddSi_our:
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegDX
                    mov Si,p1_ValRegSi
                    cmp Si,15d
                    ja IMul_invalid
                    IMul p1_ValMem[si]
                    mov p1_ValRegAX,ax
                    mov p1_ValRegDX,dx
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
                    cmp selectedPUPType,2
                    je IMul_AddSi_our
                    jmp Exit
                IMul_AddDi:
                    cmp selectedPUPType,1
                    jne IMul_AddDi_his
                    IMul_AddDi_our:
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegDX
                    mov Di,p1_ValRegDi
                    cmp Di,15d
                    ja IMul_invalid
                    IMul p1_ValMem[di]
                    mov p1_ValRegAX,ax
                    mov p1_ValRegDX,dx
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
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
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegDX
                    IMul p1_ValMem[si]
                    mov p1_ValRegAX,ax
                    mov p1_ValRegDX,dx
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
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
                    cmp selectedPUPType,1
                    jne IDiv_Ax_his
                    IDiv_Ax_our:
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegDX
                    IDiv ax
                    mov p1_ValRegAX,ax
                    mov p1_ValRegDX,dx
                    jmp Exit
                    IDiv_Ax_his:
                    mov ax,ValRegAX
                    mov dx,ValRegDX
                    call LineStuckPwrUp
                    IDiv ax
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
                    cmp selectedPUPType,2
                    je IDiv_Ax_our
                    jmp Exit
                IDiv_Al:
                    cmp selectedPUPType,1
                    jne IDiv_Al_his
                    IDiv_Al_our:
                    mov ax,p1_ValRegAX
                    IDiv al
                    mov p1_ValRegAX,ax
                    jmp Exit
                    IDiv_Al_his:
                    mov ax,ValRegAX
                    call LineStuckPwrUp
                    IDiv al
                    movp2_ValRegAX,ax
                    cmp selectedPUPType,2
                    je IDiv_Al_our
                    jmp Exit
                IDiv_Ah:
                    cmp selectedPUPType,1
                    jne IDiv_Ah_his
                    IDiv_Ah_our:
                    mov ax,p1_ValRegAX
                    IDiv ah
                    mov p1_ValRegAX,ax
                    jmp Exit
                    IDiv_Ah_his:
                    mov ax,ValRegAX
                    mov al,ah
                    call LineStuckPwrUp
                    IDiv al
                    movp2_ValRegAX,ax
                    cmp selectedPUPType,2
                    je IDiv_Ah_our
                    jmp Exit
                IDiv_Bx:
                    cmp selectedPUPType,1
                    jne IDiv_Bx_his
                    IDiv_Bx_our:
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegDX
                    mov bx,p1_ValRegBX
                    IDiv bx
                    mov p1_ValRegAX,ax
                    mov p1_ValRegDX,dx
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
                    cmp selectedPUPType,2
                    je IDiv_Bx_our
                    jmp Exit
                IDiv_Bl:
                    cmp selectedPUPType,1
                    jne IDiv_Bl_his
                    IDiv_Bl_our:
                    mov ax,p1_ValRegAX
                    mov bx,p1_ValRegBX
                    IDiv bl
                    mov p1_ValRegAX,ax
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
                    movp2_ValRegAX,ax
                    cmp selectedPUPType,2
                    je IDiv_Bl_our
                    jmp Exit
                IDiv_Bh:
                    cmp selectedPUPType,1
                    jne IDiv_Bh_his
                    IDiv_Bh_our:
                    mov ax,p1_ValRegAX
                    mov bx,p1_ValRegBX
                    IDiv Bh
                    mov p1_ValRegAX,ax
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
                    movp2_ValRegAX,ax
                    cmp selectedPUPType,2
                    je IDiv_Bh_our
                    jmp Exit
                IDiv_Cx:
                    cmp selectedPUPType,1
                    jne IDiv_Cx_his
                    IDiv_Cx_our:
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegDX
                    mov Cx,p1_ValRegCx
                    IDiv Cx
                    mov p1_ValRegAX,ax
                    mov p1_ValRegDX,dx
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
                    cmp selectedPUPType,2
                    je IDiv_Cx_our
                    jmp Exit
                IDiv_Cl:
                    cmp selectedPUPType,1
                    jne IDiv_Cl_his
                    IDiv_Cl_our:
                    mov ax,p1_ValRegAX
                    mov Cx,p1_ValRegCx
                    IDiv Cl
                    mov p1_ValRegAX,ax
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
                    movp2_ValRegAX,ax
                    cmp selectedPUPType,2
                    je IDiv_Cl_our
                    jmp Exit
                IDiv_Ch:
                    cmp selectedPUPType,1
                    jne IDiv_Ch_his
                    IDiv_Ch_our:
                    mov ax,p1_ValRegAX
                    mov Cx,p1_ValRegCx
                    IDiv Ch
                    mov p1_ValRegAX,ax
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
                    movp2_ValRegAX,ax
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
                    cmp selectedPUPType,2
                    je IDiv_Dx_our
                    jmp Exit
                IDiv_Dl:
                    cmp selectedPUPType,1
                    jne IDiv_Dl_his
                    IDiv_Dl_our:
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegBX
                    IDiv dl
                    mov p1_ValRegAX,ax
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
                    movp2_ValRegAX,ax
                    cmp selectedPUPType,2
                    je IDiv_Dl_our
                    jmp Exit
                IDiv_Dh:
                    cmp selectedPUPType,1
                    jne IDiv_Dh_his
                    IDiv_Dh_our:
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegBX
                    IDiv Dh
                    mov p1_ValRegAX,ax
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
                    movp2_ValRegAX,ax
                    cmp selectedPUPType,2
                    je IDiv_Dh_our
                    jmp Exit
                IDiv_Bp:
                    cmp selectedPUPType,1
                    jne IDiv_Bp_his
                    IDiv_Bp_our:
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegDX
                    mov Bp,p1_ValRegBp
                    IDiv Bp
                    mov p1_ValRegAX,ax
                    mov p1_ValRegDX,dx
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
                    cmp selectedPUPType,2
                    je IDiv_Bp_our
                    jmp Exit
                IDiv_Sp:
                    cmp selectedPUPType,1
                    jne IDiv_Sp_his
                    IDiv_Sp_our:
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegDX
                    mov Sp,p1_ValRegSp
                    IDiv Sp
                    mov p1_ValRegAX,ax
                    mov p1_ValRegDX,dx
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
                    cmp selectedPUPType,2
                    je IDiv_Sp_our
                    jmp Exit
                IDiv_Si:
                    cmp selectedPUPType,1
                    jne IDiv_Si_his
                    IDiv_Si_our:
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegDX
                    mov Si,p1_ValRegSi
                    IDiv Si
                    mov p1_ValRegAX,ax
                    mov p1_ValRegDX,dx
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
                    cmp selectedPUPType,2
                    je IDiv_Si_our
                    jmp Exit
                IDiv_di:
                    IDiv_Di:
                    cmp selectedPUPType,1
                    jne IDiv_Di_his
                    IDiv_Di_our:
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegDX
                    mov Di,p1_ValRegDi
                    IDiv Di
                    mov p1_ValRegAX,ax
                    mov p1_ValRegDX,dx
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
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
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegDX
                    mov bx,p1_ValRegBX
                    cmp bx,15d
                    ja IDiv_invalid
                    IDiv p1_ValMem[bx]
                    mov p1_ValRegAX,ax
                    mov p1_ValRegDX,dx
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
                    cmp selectedPUPType,2
                    je IDiv_AddBx_our
                    jmp Exit
                IDiv_AddBp:
                    cmp selectedPUPType,1
                    jne IDiv_AddBp_his
                    IDiv_AddBp_our:
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegDX
                    mov Bp,p1_ValRegBp
                    cmp Bp,15d
                    ja IDiv_invalid
                    IDiv p1_ValMem[bp]
                    mov p1_ValRegAX,ax
                    mov p1_ValRegDX,dx
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
                    cmp selectedPUPType,2
                    je IDiv_AddBp_our
                    jmp Exit
                IDiv_AddSi:
                    cmp selectedPUPType,1
                    jne IDiv_AddSi_his
                    IDiv_AddSi_our:
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegDX
                    mov Si,p1_ValRegSi
                    cmp Si,15d
                    ja IDiv_invalid
                    IDiv p1_ValMem[si]
                    mov p1_ValRegAX,ax
                    mov p1_ValRegDX,dx
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
                    cmp selectedPUPType,2
                    je IDiv_AddSi_our
                    jmp Exit
                IDiv_AddDi:
                    cmp selectedPUPType,1
                    jne IDiv_AddDi_his
                    IDiv_AddDi_our:
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegDX
                    mov Di,p1_ValRegDi
                    cmp Di,15d
                    ja IDiv_invalid
                    IDiv p1_ValMem[di]
                    mov p1_ValRegAX,ax
                    mov p1_ValRegDX,dx
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
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
                    mov ax,p1_ValRegAX
                    mov dx,p1_ValRegDX
                    IDiv p1_ValMem[si]
                    mov p1_ValRegAX,ax
                    mov p1_ValRegDX,dx
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
                    movp2_ValRegAX,ax
                    movp2_ValRegDX,dx
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
                        cmp selectedPUPType,1
                        jne ROR_Ax_Reg_his
                        ROR_Ax_Reg_our:
                        mov ax,p1_ValRegAX
                        mov cx,p1_ValRegCX
                        ror Ax,cl
                        call ourSetCF
                        mov p1_ValRegAX,ax
                        jmp Exit
                        ROR_Ax_Reg_his:
                        mov ax,ValRegAX
                        mov cx,ValRegCX
                        ror Ax,cl
                        call SetCarryFlag
                        movp2_ValRegAX,ax
                        cmp selectedPUPType,2
                        je ROR_Ax_Reg_our
                        jmp Exit
                    ROR_Ax_Val:
                        cmp Op2Val,255d
                        ja ROR_invalid
                        cmp selectedPUPType,1
                        jne ROR_Ax_Val_his
                        ROR_Ax_Val_our:
                        mov ax,p1_ValRegAX
                        mov cx,Op2Val
                        ror ax,cl
                        call ourSetCF
                        mov p1_ValRegAX,ax
                        jmp Exit
                        ROR_Ax_Val_his:
                        mov ax,ValRegAX
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        ror ax,cl
                        call SetCarryFlag
                        movp2_ValRegAX,ax
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
                        mov ax,p1_ValRegAX
                        mov cx,p1_ValRegCX
                        ror Al,cl
                        call ourSetCF
                        mov p1_ValRegAX,ax
                        jmp Exit
                        ROR_Al_Reg_his:
                        mov ax,ValRegAX
                        mov cx,ValRegCX
                        ror Al,cl
                        call SetCarryFlag
                        movp2_ValRegAX,ax
                        cmp selectedPUPType,2
                        je ROR_Al_Reg_our
                        jmp Exit
                    ROR_Al_Val:
                        cmp Op2Val,255d
                        ja ROR_invalid
                        cmp selectedPUPType,1
                        jne ROR_Al_Val_his
                        ROR_Al_Val_our:
                        mov ax,p1_ValRegAX
                        mov cx,Op2Val
                        ror al,cl
                        call ourSetCF
                        mov p1_ValRegAX,ax
                        jmp Exit
                        ROR_Al_Val_his:
                        mov ax,ValRegAX
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        ror al,cl
                        call SetCarryFlag
                        movp2_ValRegAX,ax
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
                        mov ax,p1_ValRegAX
                        mov cx,p1_ValRegCX
                        ror Ah,cl
                        call ourSetCF
                        mov p1_ValRegAX,ax
                        jmp Exit
                        ROR_Ah_Reg_his:
                        mov ax,ValRegAX
                        mov cx,ValRegCX
                        ror Ah,cl
                        call SetCarryFlag
                        movp2_ValRegAX,ax
                        cmp selectedPUPType,2
                        je ROR_Ah_Reg_our
                        jmp Exit
                    ROR_Ah_Val:
                        cmp Op2Val,255d
                        ja ROR_invalid
                        cmp selectedPUPType,1
                        jne ROR_Ah_Val_his
                        ROR_Ah_Val_our:
                        mov ax,p1_ValRegAX
                        mov cx,Op2Val
                        ror ah,cl
                        call ourSetCF
                        mov p1_ValRegAX,ax
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
                        movp2_ValRegAX,ax
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
                        mov Bx,p1_ValRegBx
                        mov cx,p1_ValRegCX
                        ror Bx,cl
                        call ourSetCF
                        mov p1_ValRegBx,Bx
                        jmp Exit
                        ROR_Bx_Reg_his:
                        mov Bx,ValRegBx
                        mov cx,ValRegCX
                        ror Bx,cl
                        call SetCarryFlag
                        movp2_ValRegBx,Bx
                        cmp selectedPUPType,2
                        je ROR_Bx_Reg_our
                        jmp Exit
                    ROR_Bx_Val:
                        cmp Op2Val,255d
                        ja ROR_invalid
                        cmp selectedPUPType,1
                        jne ROR_Bx_Val_his
                        ROR_Bx_Val_our:
                        mov Bx,p1_ValRegBx
                        mov cx,Op2Val
                        ror Bx,cl
                        call ourSetCF
                        mov p1_ValRegBx,Bx
                        jmp Exit
                        ROR_Bx_Val_his:
                        mov Bx,ValRegBx
                        mov cx,Op2Val
                        mov ax,bx
                        call LineStuckPwrUp
                        mov bx,ax
                        ror Bx,cl
                        call SetCarryFlag
                        movp2_ValRegBx,Bx
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
                        mov Bx,p1_ValRegBX
                        mov cx,p1_ValRegCX
                        ror Bl,cl
                        call ourSetCF
                        mov p1_ValRegBX,Bx
                        jmp Exit
                        ROR_Bl_Reg_his:
                        mov Bx,ValRegBX
                        mov cx,ValRegCX
                        ror Bl,cl
                        call SetCarryFlag
                        movp2_ValRegBX,Bx
                        cmp selectedPUPType,2
                        je ROR_Bl_Reg_our
                        jmp Exit
                    ROR_Bl_Val:
                        cmp Op2Val,255d
                        ja ROR_invalid
                        cmp selectedPUPType,1
                        ROR_Bl_Val_our:
                        mov Bx,p1_ValRegBX
                        mov cx,Op2Val
                        ror Bl,cl
                        call ourSetCF
                        mov p1_ValRegBX,Bx
                        jmp Exit
                        ROR_Bl_Val_his:
                        mov Bx,ValRegBX
                        mov cx,Op2Val
                        mov al,Bl
                        call LineStuckPwrUp
                        mov Bl,al
                        ror Bl,cl
                        call SetCarryFlag
                        movp2_ValRegBX,Bx
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
                        mov Bx,p1_ValRegBX
                        mov cx,p1_ValRegCX
                        ror Bh,cl
                        call ourSetCF
                        mov p1_ValRegBX,Bx
                        jmp Exit
                        ROR_Bh_Reg_his:
                        mov Bx,ValRegBX
                        mov cx,ValRegCX
                        ror Bh,cl
                        call SetCarryFlag
                        movp2_ValRegBX,Bx
                        cmp selectedPUPType,2
                        je ROR_Bh_Reg_our
                        jmp Exit
                    ROR_Bh_Val:
                        cmp Op2Val,255d
                        ja ROR_invalid
                        cmp selectedPUPType,1
                        ROR_Bh_Val_our:
                        mov Bx,p1_ValRegBX
                        mov cx,Op2Val
                        ror Bh,cl
                        call ourSetCF
                        mov p1_ValRegBX,Bx
                        jmp Exit
                        ROR_Bh_Val_his:
                        mov Bx,ValRegBX
                        mov cx,Op2Val
                        mov al,Bh
                        call LineStuckPwrUp
                        mov Bh,al
                        ror Bh,cl
                        call SetCarryFlag
                        movp2_ValRegBX,Bx
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
                        mov Cx,p1_ValRegCx
                        mov ax,cx
                        mov cx,ax
                        ror Cx,cl
                        call ourSetCF
                        mov p1_ValRegCx,Cx
                        jmp Exit
                        ROR_Cx_Reg_his:
                        cmp selectedOp2Reg,7
                        jne ROR_invalid
                        mov Cx,ValRegCx
                        mov ax,cx
                        mov cx,ax
                        ror Cx,cl
                        call SetCarryFlag
                        movp2_ValRegCx,Cx
                        cmp selectedPUPType,2
                        je ROR_Cx_Reg_our
                        jmp Exit
                    ROR_Cx_Val:
                        cmp Op2Val,255d
                        ja ROR_invalid
                        cmp selectedPUPType,1
                        jne ROR_Cx_Val_his
                        ROR_Cx_Val_our:
                        mov bx,p1_ValRegCx
                        mov cx,Op2Val
                        ror bx,cl
                        call ourSetCF
                        mov p1_ValRegCx,bx
                        jmp Exit
                        ROR_Cx_Val_his:
                        mov bx,ValRegCx
                        mov cx,Op2Val
                        mov ax,bx
                        call LineStuckPwrUp
                        mov bx,ax
                        ror bx,cl
                        call SetCarryFlag
                        movp2_ValRegCx,bx
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
                        mov ax,p1_ValRegCX
                        mov cx,p1_ValRegCX
                        ror Al,cl
                        call ourSetCF
                        mov p1_ValRegCX,ax
                        jmp Exit
                        ROR_Cl_Reg_his:
                        mov ax,ValRegCX
                        mov cx,ValRegCX
                        ror Al,cl
                        call SetCarryFlag
                        movp2_ValRegCX,ax
                        cmp selectedPUPType,2
                        je ROR_Cl_Reg_our
                        jmp Exit
                    ROR_Cl_Val:
                        cmp Op2Val,255d
                        ja ROR_invalid
                        cmp selectedPUPType,1
                        jne ROR_Cl_Val_his
                        ROR_Cl_Val_our:
                        mov ax,p1_ValRegCX
                        mov cx,Op2Val
                        ror al,cl
                        call ourSetCF
                        mov p1_ValRegCX,ax
                        jmp Exit
                        ROR_Cl_Val_his:
                        mov ax,ValRegCX
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        ror al,cl
                        call SetCarryFlag
                        movp2_ValRegCX,ax
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
                        mov cx,p1_ValRegCX
                        ror Ch,cl
                        call ourSetCF
                        mov p1_ValRegCX,Cx
                        jmp Exit
                        ROR_Ch_Reg_his:
                        mov cx,ValRegCX
                        ror Ch,cl
                        call SetCarryFlag
                        movp2_ValRegCX,Cx
                        cmp selectedPUPType,2
                        je ROR_Ch_Reg_our
                        jmp Exit
                    ROR_Ch_Val:
                        cmp Op2Val,255d
                        ja ROR_invalid
                        cmp selectedPUPType,1
                        jne ROR_Ch_Val_his
                        ROR_Ch_Val_our:
                        mov ax,p1_ValRegCX
                        mov cx,Op2Val
                        ror ah,cl
                        call ourSetCF
                        mov p1_ValRegCX,ax
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
                        movp2_ValRegCX,ax
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
                        mov Dx,p1_ValRegDx
                        mov cx,p1_ValRegCX
                        ror Dx,cl
                        call ourSetCF
                        mov p1_ValRegDx,Dx
                        jmp Exit
                        ROR_Dx_Reg_his:
                        mov Dx,ValRegDx
                        mov cx,ValRegCX
                        ror Dx,cl
                        call SetCarryFlag
                        movp2_ValRegDx,Dx
                        cmp selectedPUPType,2
                        je ROR_Dx_Reg_our
                        jmp Exit
                    ROR_Dx_Val:
                        cmp Op2Val,255d
                        ja ROR_invalid
                        cmp selectedPUPType,1
                        jne ROR_Dx_Val_his
                        ROR_Dx_Val_our:
                        mov ax,p1_ValRegDx
                        mov cx,Op2Val
                        ror ax,cl
                        call ourSetCF
                        mov p1_ValRegDx,ax
                        jmp Exit
                        ROR_Dx_Val_his:
                        mov ax,ValRegDx
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        ror ax,cl
                        call SetCarryFlag
                        movp2_ValRegDx,ax
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
                        mov Dx,p1_ValRegDX
                        mov cx,p1_ValRegCX
                        ror Dl,cl
                        call ourSetCF
                        mov p1_ValRegDX,Dx
                        jmp Exit
                        ROR_Dl_Reg_his:
                        mov Dx,ValRegDX
                        mov cx,ValRegCX
                        ror Dl,cl
                        call SetCarryFlag
                        movp2_ValRegDX,Dx
                        cmp selectedPUPType,2
                        je ROR_Dl_Reg_our
                        jmp Exit
                    ROR_Dl_Val:
                        cmp Op2Val,255d
                        ja ROR_invalid
                        cmp selectedPUPType,1
                        jne ROR_Dl_Val_his
                        ROR_Dl_Val_our:
                        mov Dx,p1_ValRegDX
                        mov cx,Op2Val
                        ror Dl,cl
                        call ourSetCF
                        mov p1_ValRegDX,Dx
                        jmp Exit
                        ROR_Dl_Val_his:
                        mov ax,ValRegDX
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        ror al,cl
                        call SetCarryFlag
                        movp2_ValRegDX,ax
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
                        mov Dx,p1_ValRegDX
                        mov cx,p1_ValRegCX
                        ror dh,cl
                        call ourSetCF
                        mov p1_ValRegDX,Dx
                        jmp Exit
                        ROR_Dh_Reg_his:
                        mov Dx,ValRegDX
                        mov cx,ValRegCX
                        ror dh,cl
                        call SetCarryFlag
                        movp2_ValRegDX,Dx
                        cmp selectedPUPType,2
                        je ROR_Dh_Reg_our
                        jmp Exit
                    ROR_Dh_Val:
                        cmp Op2Val,255d
                        ja ROR_invalid
                        cmp selectedPUPType,1
                        jne ROR_Dh_Val_his
                        ROR_Dh_Val_our:
                        mov Dx,p1_ValRegDX
                        mov cx,Op2Val
                        ror dh,cl
                        call ourSetCF
                        mov p1_ValRegDX,Dx
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
                        movp2_ValRegDX,ax
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
                        mov Bp,p1_ValRegBp
                        mov cx,p1_ValRegCX
                        ror Bp,cl
                        call ourSetCF
                        mov p1_ValRegBp,Bp
                        jmp Exit
                        ROR_Bp_Reg_his:
                        mov Bp,ValRegBp
                        mov cx,ValRegCX
                        ror Bp,cl
                        call SetCarryFlag
                        movp2_ValRegBp,Bp
                        cmp selectedPUPType,2
                        je ROR_Bp_Reg_our
                        jmp Exit
                    ROR_Bp_Val:
                        cmp Op2Val,255d
                        ja ROR_invalid
                        cmp selectedPUPType,1
                        jne ROR_Bp_Val_his
                        ROR_Bp_Val_our:
                        mov Bp,p1_ValRegBp
                        mov cx,Op2Val
                        ror Bp,cl
                        call ourSetCF
                        mov p1_ValRegBp,Bp
                        jmp Exit
                        ROR_Bp_Val_his:
                        mov ax,ValRegBp
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        ror ax,cl
                        call SetCarryFlag
                        movp2_ValRegBp,ax
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
                        mov Sp,p1_ValRegSp
                        mov cx,p1_ValRegCX
                        ror Sp,cl
                        call ourSetCF
                        mov p1_ValRegSp,Sp
                        jmp Exit
                        ROR_Sp_Reg_his:
                        mov Sp,ValRegSp
                        mov cx,ValRegCX
                        ror Sp,cl
                        call SetCarryFlag
                        movp2_ValRegSp,Sp
                        cmp selectedPUPType,2
                        je ROR_Sp_Reg_our
                        jmp Exit
                    ROR_Sp_Val:
                        cmp Op2Val,255d
                        ja ROR_invalid
                        cmp selectedPUPType,1
                        jne ROR_Sp_Val_his
                        ROR_Sp_Val_our:
                        mov Sp,p1_ValRegSp
                        mov cx,Op2Val
                        ror Sp,cl
                        call ourSetCF
                        mov p1_ValRegSp,Sp
                        jmp Exit
                        ROR_Sp_Val_his:
                        mov ax,ValRegSp
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        ror ax,cl
                        call SetCarryFlag
                        movp2_ValRegSp,ax
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
                        mov Si,p1_ValRegSi
                        mov cx,p1_ValRegCX
                        ror Si,cl
                        call ourSetCF
                        mov p1_ValRegSi,Si
                        jmp Exit
                        ROR_Si_Reg_his:
                        mov Si,ValRegSi
                        mov cx,ValRegCX
                        ror Si,cl
                        call SetCarryFlag
                        movp2_ValRegSi,Si
                        cmp selectedPUPType,2
                        je ROR_Si_Reg_our
                        jmp Exit
                    ROR_Si_Val:
                        cmp Op2Val,255d
                        ja ROR_invalid
                        cmp selectedPUPType,1
                        jne ROR_Si_Val_his
                        ROR_Si_Val_our:
                        mov Si,p1_ValRegSi
                        mov cx,Op2Val
                        ror Si,cl
                        call ourSetCF
                        mov p1_ValRegSi,Si
                        jmp Exit
                        ROR_Si_Val_his:
                        mov ax,ValRegSi
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        ror ax,cl
                        call SetCarryFlag
                        movp2_ValRegSi,ax
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
                        mov Di,p1_ValRegDi
                        mov cx,p1_ValRegCX
                        ror Di,cl
                        call ourSetCF
                        mov p1_ValRegDi,Di
                        jmp Exit
                        ROR_Di_Reg_his:
                        mov Di,ValRegDi
                        mov cx,ValRegCX
                        ror Di,cl
                        call SetCarryFlag
                        movp2_ValRegDi,Di
                        cmp selectedPUPType,2
                        je ROR_Di_Reg_our
                        jmp Exit
                    ROR_Di_Val:
                        cmp Op2Val,255d
                        ja ROR_invalid
                        cmp selectedPUPType,1
                        jne ROR_Di_Val_his
                        ROR_Di_Val_our:
                        mov Di,p1_ValRegDi
                        mov cx,Op2Val
                        ror Di,cl
                        call ourSetCF
                        mov p1_ValRegDi,Di
                        jmp Exit
                        ROR_Di_Val_his:
                        mov ax,ValRegDi
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        ror ax,cl
                        call SetCarryFlag
                        movp2_ValRegDi,ax
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
                        mov Bx,p1_ValRegBX
                        cmp Bx,15d
                        ja ROR_invalid
                        mov cx,p1_ValRegCX
                        ror p1_ValMem[Bx],cl
                        call ourSetCF
                        mov p1_ValRegBX,Bx
                        jmp Exit
                        ROR_AddBx_Reg_his:
                        mov Bx,ValRegBX
                        cmp Bx,15d
                        ja ROR_invalid
                        mov cx,ValRegCX
                        ;;;;;;;;;;;;;;;;;;;;;;;
                            mov al,ValMem[Bx]
                            call LineStuckPwrUp
                            movp2_ValMem[Bx],al
                        rorp2_ValMem[Bx],cl
                        call SetCarryFlag
                        movp2_ValRegBX,Bx
                        cmp selectedPUPType,2
                        je ROR_AddBx_Reg_our
                        jmp Exit
                    ROR_AddBx_Val:
                        cmp Op2Val,255d
                        ja ROR_invalid
                        cmp selectedPUPType,1
                        jne ROR_AddBx_Val_his
                        ROR_AddBx_Val_our:
                        mov Bx,p1_ValRegBX
                        cmp Bx,15d
                        ja ROR_invalid
                        mov cx,Op2Val
                        ror p1_ValMem[Bx],cl
                        call ourSetCF
                        mov p1_ValRegBX,Bx
                        jmp Exit
                        ROR_AddBx_Val_his:
                        mov Bx,ValRegBX
                        cmp Bx,15d
                        ja ROR_invalid
                        mov cx,Op2Val
                        ;;;;;;;;;;;;;;;;;;;;;;;
                            mov al,ValMem[Bx]
                            call LineStuckPwrUp
                            movp2_ValMem[Bx],al
                        rorp2_ValMem[Bx],cl
                        call SetCarryFlag
                        movp2_ValRegBX,Bx
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
                        mov Bp,p1_ValRegBp
                        cmp Bp,15d
                        ja ROR_invalid
                        mov cx,p1_ValRegCX
                        ror p1_ValMem[Bp],cl
                        call ourSetCF
                        mov p1_ValRegBp,Bp
                        jmp Exit
                        ROR_AddBp_Reg_his:
                        mov Bp,ValRegBp
                        cmp Bp,15d
                        ja ROR_invalid
                        mov cx,ValRegCX
                        ;;;;;;;;;;;;;;;;;;;;;;;
                            mov al,ValMem[Bp]
                            call LineStuckPwrUp
                            movp2_ValMem[Bp],al
                        rorp2_ValMem[Bp],cl
                        call SetCarryFlag
                        movp2_ValRegBp,Bp
                        cmp selectedPUPType,2
                        je ROR_AddBp_Reg_our
                        jmp Exit
                    ROR_AddBp_Val:
                        cmp Op2Val,255d
                        ja ROR_invalid
                        cmp selectedPUPType,1
                        jne ROR_AddBp_Val_his
                        ROR_AddBp_Val_our:
                        mov Bp,p1_ValRegBp
                        cmp Bp,15d
                        ja ROR_invalid
                        mov cx,Op2Val
                        ror p1_ValMem[Bp],cl
                        call ourSetCF
                        mov p1_ValRegBp,Bp
                        jmp Exit
                        ROR_AddBp_Val_his:
                        mov Bp,ValRegBp
                        cmp Bp,15d
                        ja ROR_invalid
                        mov cx,Op2Val
                        ;;;;;;;;;;;;;;;;;;;;;;;
                            mov al,ValMem[Bp]
                            call LineStuckPwrUp
                            movp2_ValMem[Bp],al
                        rorp2_ValMem[Bp],cl
                        call SetCarryFlag
                        movp2_ValRegBp,Bp
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
                        mov Si,p1_ValRegSi
                        cmp Si,15d
                        ja ROR_invalid
                        mov cx,p1_ValRegCX
                        ror p1_ValMem[Si],cl
                        call ourSetCF
                        mov p1_ValRegSi,Si
                        jmp Exit
                        ROR_AddSi_Reg_his:
                        mov Si,ValRegSi
                        cmp Si,15d
                        ja ROR_invalid
                        mov cx,ValRegCX
                        ;;;;;;;;;;;;;;;;;;;;;;;
                            mov al,ValMem[Si]
                            call LineStuckPwrUp
                            movp2_ValMem[Si],al
                        rorp2_ValMem[Si],cl
                        call SetCarryFlag
                        movp2_ValRegSi,Si
                        cmp selectedPUPType,2
                        je ROR_AddSi_Reg_our
                        jmp Exit
                    ROR_AddSi_Val:
                        cmp Op2Val,255d
                        ja ROR_invalid
                        cmp selectedPUPType,1
                        jne ROR_AddSi_Val_his
                        ROR_AddSi_Val_our:
                        mov Si,p1_ValRegSi
                        cmp Si,15d
                        ja ROR_invalid
                        mov cx,Op2Val
                        ror p1_ValMem[Si],cl
                        call ourSetCF
                        mov p1_ValRegSi,Si
                        jmp Exit
                        ROR_AddSi_Val_his:
                        mov Si,ValRegSi
                        cmp Si,15d
                        ja ROR_invalid
                        mov cx,Op2Val
                        ;;;;;;;;;;;;;;;;;;;;;;;
                            mov al,ValMem[Si]
                            call LineStuckPwrUp
                            movp2_ValMem[Si],al
                        rorp2_ValMem[Si],cl
                        call SetCarryFlag
                        movp2_ValRegSi,Si
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
                        mov Di,p1_ValRegDi
                        cmp Di,15d
                        ja ROR_invalid
                        mov cx,p1_ValRegCX
                        ror p1_ValMem[Di],cl
                        call ourSetCF
                        mov p1_ValRegDi,Di
                        jmp Exit
                        ROR_AddDi_Reg_his:
                        mov Di,ValRegDi
                        cmp Di,15d
                        ja ROR_invalid
                        mov cx,ValRegCX
                        ;;;;;;;;;;;;;;;;;;;;;;;
                            mov al,ValMem[Di]
                            call LineStuckPwrUp
                            movp2_ValMem[Di],al
                        rorp2_ValMem[Di],cl
                        call SetCarryFlag
                        movp2_ValRegDi,Di
                        cmp selectedPUPType,2
                        je ROR_AddDi_Reg_our
                        jmp Exit
                    ROR_AddDi_Val:
                        cmp Op2Val,255d
                        ja ROR_invalid
                        cmp selectedPUPType,1
                        jne ROR_AddDi_Val_his
                        ROR_AddDi_Val_our:
                        mov Di,p1_ValRegDi
                        cmp Di,15d
                        ja ROR_invalid
                        mov cx,Op2Val
                        ror p1_ValMem[Di],cl
                        call ourSetCF
                        mov p1_ValRegDi,Di
                        jmp Exit
                        ROR_AddDi_Val_his:
                        mov Di,ValRegDi
                        cmp Di,15d
                        ja ROR_invalid
                        mov cx,Op2Val
                        ;;;;;;;;;;;;;;;;;;;;;;;
                            mov al,ValMem[Di]
                            call LineStuckPwrUp
                            movp2_ValMem[Di],al
                        rorp2_ValMem[Di],cl
                        call SetCarryFlag
                        movp2_ValRegDi,Di
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
                    mov cx,p1_ValRegCX
                    Ror p1_ValMem[si],cl
                    call ourSetCF
                    jmp Exit
                    ROR_Mem_Reg_his:
                    mov cx,ValRegCX
                    ;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[si]
                        call LineStuckPwrUp
                        movp2_ValMem[si],al
                    Rorp2_ValMem[si],cl
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
                    ror p1_ValMem[si],cl
                    call ourSetCF
                    jmp Exit
                    ROR_Mem_Val_his:
                    mov cx,Op2Val
                    ;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[si]
                        call LineStuckPwrUp
                        movp2_ValMem[si],al
                    rorp2_ValMem[si],cl
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
                        cmp selectedPUPType,1
                        jne ROL_Ax_Reg_his
                        ROL_Ax_Reg_our:
                        mov ax,p1_ValRegAX
                        mov cx,p1_ValRegCX
                        ROL Ax,cl
                        call ourSetCF
                        mov p1_ValRegAX,ax
                        jmp Exit
                        ROL_Ax_Reg_his:
                        mov ax,ValRegAX
                        mov cx,ValRegCX
                        ROL Ax,cl
                        call SetCarryFlag
                        movp2_ValRegAX,ax
                        cmp selectedPUPType,2
                        je ROL_Ax_Reg_our
                        jmp Exit
                    ROL_Ax_Val:
                        cmp Op2Val,255d
                        ja ROL_invalid
                        cmp selectedPUPType,1
                        jne ROL_Ax_Val_his
                        ROL_Ax_Val_our:
                        mov ax,p1_ValRegAX
                        mov cx,Op2Val
                        ROL ax,cl
                        call ourSetCF
                        mov p1_ValRegAX,ax
                        jmp Exit
                        ROL_Ax_Val_his:
                        mov ax,ValRegAX
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        ROL ax,cl
                        call SetCarryFlag
                        movp2_ValRegAX,ax
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
                        mov ax,p1_ValRegAX
                        mov cx,p1_ValRegCX
                        ROL Al,cl
                        call ourSetCF
                        mov p1_ValRegAX,ax
                        jmp Exit
                        ROL_Al_Reg_his:
                        mov ax,ValRegAX
                        mov cx,ValRegCX
                        ROL Al,cl
                        call SetCarryFlag
                        movp2_ValRegAX,ax
                        cmp selectedPUPType,2
                        je ROL_Al_Reg_our
                        jmp Exit
                    ROL_Al_Val:
                        cmp Op2Val,255d
                        ja ROL_invalid
                        cmp selectedPUPType,1
                        jne ROL_Al_Val_his
                        ROL_Al_Val_our:
                        mov ax,p1_ValRegAX
                        mov cx,Op2Val
                        ROL al,cl
                        call ourSetCF
                        mov p1_ValRegAX,ax
                        jmp Exit
                        ROL_Al_Val_his:
                        mov ax,ValRegAX
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        ROL al,cl
                        call SetCarryFlag
                        movp2_ValRegAX,ax
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
                        mov ax,p1_ValRegAX
                        mov cx,p1_ValRegCX
                        ROL Ah,cl
                        call ourSetCF
                        mov p1_ValRegAX,ax
                        jmp Exit
                        ROL_Ah_Reg_his:
                        mov ax,ValRegAX
                        mov cx,ValRegCX
                        ROL Ah,cl
                        call SetCarryFlag
                        movp2_ValRegAX,ax
                        cmp selectedPUPType,2
                        je ROL_Ah_Reg_our
                        jmp Exit
                    ROL_Ah_Val:
                        cmp Op2Val,255d
                        ja ROL_invalid
                        cmp selectedPUPType,1
                        jne ROL_Ah_Val_his
                        ROL_Ah_Val_our:
                        mov ax,p1_ValRegAX
                        mov cx,Op2Val
                        ROL ah,cl
                        call ourSetCF
                        mov p1_ValRegAX,ax
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
                        movp2_ValRegAX,ax
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
                        mov Bx,p1_ValRegBx
                        mov cx,p1_ValRegCX
                        ROL Bx,cl
                        call ourSetCF
                        mov p1_ValRegBx,Bx
                        jmp Exit
                        ROL_Bx_Reg_his:
                        mov Bx,ValRegBx
                        mov cx,ValRegCX
                        ROL Bx,cl
                        call SetCarryFlag
                        movp2_ValRegBx,Bx
                        cmp selectedPUPType,2
                        je ROL_Bx_Reg_our
                        jmp Exit
                    ROL_Bx_Val:
                        cmp Op2Val,255d
                        ja ROL_invalid
                        cmp selectedPUPType,1
                        jne ROL_Bx_Val_his
                        ROL_Bx_Val_our:
                        mov Bx,p1_ValRegBx
                        mov cx,Op2Val
                        ROL Bx,cl
                        call ourSetCF
                        mov p1_ValRegBx,Bx
                        jmp Exit
                        ROL_Bx_Val_his:
                        mov Bx,ValRegBx
                        mov cx,Op2Val
                        mov ax,bx
                        call LineStuckPwrUp
                        mov bx,ax
                        ROL Bx,cl
                        call SetCarryFlag
                        movp2_ValRegBx,Bx
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
                        mov Bx,p1_ValRegBX
                        mov cx,p1_ValRegCX
                        ROL Bl,cl
                        call ourSetCF
                        mov p1_ValRegBX,Bx
                        jmp Exit
                        ROL_Bl_Reg_his:
                        mov Bx,ValRegBX
                        mov cx,ValRegCX
                        ROL Bl,cl
                        call SetCarryFlag
                        movp2_ValRegBX,Bx
                        cmp selectedPUPType,2
                        je ROL_Bl_Reg_our
                        jmp Exit
                    ROL_Bl_Val:
                        cmp Op2Val,255d
                        ja ROL_invalid
                        cmp selectedPUPType,1
                        ROL_Bl_Val_our:
                        mov Bx,p1_ValRegBX
                        mov cx,Op2Val
                        ROL Bl,cl
                        call ourSetCF
                        mov p1_ValRegBX,Bx
                        jmp Exit
                        ROL_Bl_Val_his:
                        mov Bx,ValRegBX
                        mov cx,Op2Val
                        mov al,Bl
                        call LineStuckPwrUp
                        mov Bl,al
                        ROL Bl,cl
                        call SetCarryFlag
                        movp2_ValRegBX,Bx
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
                        mov Bx,p1_ValRegBX
                        mov cx,p1_ValRegCX
                        ROL Bh,cl
                        call ourSetCF
                        mov p1_ValRegBX,Bx
                        jmp Exit
                        ROL_Bh_Reg_his:
                        mov Bx,ValRegBX
                        mov cx,ValRegCX
                        ROL Bh,cl
                        call SetCarryFlag
                        movp2_ValRegBX,Bx
                        cmp selectedPUPType,2
                        je ROL_Bh_Reg_our
                        jmp Exit
                    ROL_Bh_Val:
                        cmp Op2Val,255d
                        ja ROL_invalid
                        cmp selectedPUPType,1
                        ROL_Bh_Val_our:
                        mov Bx,p1_ValRegBX
                        mov cx,Op2Val
                        ROL Bh,cl
                        call ourSetCF
                        mov p1_ValRegBX,Bx
                        jmp Exit
                        ROL_Bh_Val_his:
                        mov Bx,ValRegBX
                        mov cx,Op2Val
                        mov al,Bh
                        call LineStuckPwrUp
                        mov Bh,al
                        ROL Bh,cl
                        call SetCarryFlag
                        movp2_ValRegBX,Bx
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
                        mov Cx,p1_ValRegCx
                        mov ax,cx
                        mov cx,ax
                        ROL Cx,cl
                        call ourSetCF
                        mov p1_ValRegCx,Cx
                        jmp Exit
                        ROL_Cx_Reg_his:
                        cmp selectedOp2Reg,7
                        jne ROL_invalid
                        mov Cx,ValRegCx
                        mov ax,cx
                        mov cx,ax
                        ROL Cx,cl
                        call SetCarryFlag
                        movp2_ValRegCx,Cx
                        cmp selectedPUPType,2
                        je ROL_Cx_Reg_our
                        jmp Exit
                    ROL_Cx_Val:
                        cmp Op2Val,255d
                        ja ROL_invalid
                        cmp selectedPUPType,1
                        jne ROL_Cx_Val_his
                        ROL_Cx_Val_our:
                        mov bx,p1_ValRegCx
                        mov cx,Op2Val
                        ROL bx,cl
                        call ourSetCF
                        mov p1_ValRegCx,bx
                        jmp Exit
                        ROL_Cx_Val_his:
                        mov bx,ValRegCx
                        mov cx,Op2Val
                        mov ax,bx
                        call LineStuckPwrUp
                        mov bx,ax
                        ROL bx,cl
                        call SetCarryFlag
                        movp2_ValRegCx,bx
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
                        mov ax,p1_ValRegCX
                        mov cx,p1_ValRegCX
                        ROL Al,cl
                        call ourSetCF
                        mov p1_ValRegCX,ax
                        jmp Exit
                        ROL_Cl_Reg_his:
                        mov ax,ValRegCX
                        mov cx,ValRegCX
                        ROL Al,cl
                        call SetCarryFlag
                        movp2_ValRegCX,ax
                        cmp selectedPUPType,2
                        je ROL_Cl_Reg_our
                        jmp Exit
                    ROL_Cl_Val:
                        cmp Op2Val,255d
                        ja ROL_invalid
                        cmp selectedPUPType,1
                        jne ROL_Cl_Val_his
                        ROL_Cl_Val_our:
                        mov ax,p1_ValRegCX
                        mov cx,Op2Val
                        ROL al,cl
                        call ourSetCF
                        mov p1_ValRegCX,ax
                        jmp Exit
                        ROL_Cl_Val_his:
                        mov ax,ValRegCX
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        ROL al,cl
                        call SetCarryFlag
                        movp2_ValRegCX,ax
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
                        mov cx,p1_ValRegCX
                        ROL Ch,cl
                        call ourSetCF
                        mov p1_ValRegCX,Cx
                        jmp Exit
                        ROL_Ch_Reg_his:
                        mov cx,ValRegCX
                        ROL Ch,cl
                        call SetCarryFlag
                        movp2_ValRegCX,Cx
                        cmp selectedPUPType,2
                        je ROL_Ch_Reg_our
                        jmp Exit
                    ROL_Ch_Val:
                        cmp Op2Val,255d
                        ja ROL_invalid
                        cmp selectedPUPType,1
                        jne ROL_Ch_Val_his
                        ROL_Ch_Val_our:
                        mov ax,p1_ValRegCX
                        mov cx,Op2Val
                        ROL ah,cl
                        call ourSetCF
                        mov p1_ValRegCX,ax
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
                        movp2_ValRegCX,ax
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
                        mov Dx,p1_ValRegDx
                        mov cx,p1_ValRegCX
                        ROL Dx,cl
                        call ourSetCF
                        mov p1_ValRegDx,Dx
                        jmp Exit
                        ROL_Dx_Reg_his:
                        mov Dx,ValRegDx
                        mov cx,ValRegCX
                        ROL Dx,cl
                        call SetCarryFlag
                        movp2_ValRegDx,Dx
                        cmp selectedPUPType,2
                        je ROL_Dx_Reg_our
                        jmp Exit
                    ROL_Dx_Val:
                        cmp Op2Val,255d
                        ja ROL_invalid
                        cmp selectedPUPType,1
                        jne ROL_Dx_Val_his
                        ROL_Dx_Val_our:
                        mov ax,p1_ValRegDx
                        mov cx,Op2Val
                        ROL ax,cl
                        call ourSetCF
                        mov p1_ValRegDx,ax
                        jmp Exit
                        ROL_Dx_Val_his:
                        mov ax,ValRegDx
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        ROL ax,cl
                        call SetCarryFlag
                        movp2_ValRegDx,ax
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
                        mov Dx,p1_ValRegDX
                        mov cx,p1_ValRegCX
                        ROL Dl,cl
                        call ourSetCF
                        mov p1_ValRegDX,Dx
                        jmp Exit
                        ROL_Dl_Reg_his:
                        mov Dx,ValRegDX
                        mov cx,ValRegCX
                        ROL Dl,cl
                        call SetCarryFlag
                        movp2_ValRegDX,Dx
                        cmp selectedPUPType,2
                        je ROL_Dl_Reg_our
                        jmp Exit
                    ROL_Dl_Val:
                        cmp Op2Val,255d
                        ja ROL_invalid
                        cmp selectedPUPType,1
                        jne ROL_Dl_Val_his
                        ROL_Dl_Val_our:
                        mov Dx,p1_ValRegDX
                        mov cx,Op2Val
                        ROL Dl,cl
                        call ourSetCF
                        mov p1_ValRegDX,Dx
                        jmp Exit
                        ROL_Dl_Val_his:
                        mov ax,ValRegDX
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        ROL al,cl
                        call SetCarryFlag
                        movp2_ValRegDX,ax
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
                        mov Dx,p1_ValRegDX
                        mov cx,p1_ValRegCX
                        ROL dh,cl
                        call ourSetCF
                        mov p1_ValRegDX,Dx
                        jmp Exit
                        ROL_Dh_Reg_his:
                        mov Dx,ValRegDX
                        mov cx,ValRegCX
                        ROL dh,cl
                        call SetCarryFlag
                        movp2_ValRegDX,Dx
                        cmp selectedPUPType,2
                        je ROL_Dh_Reg_our
                        jmp Exit
                    ROL_Dh_Val:
                        cmp Op2Val,255d
                        ja ROL_invalid
                        cmp selectedPUPType,1
                        jne ROL_Dh_Val_his
                        ROL_Dh_Val_our:
                        mov Dx,p1_ValRegDX
                        mov cx,Op2Val
                        ROL dh,cl
                        call ourSetCF
                        mov p1_ValRegDX,Dx
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
                        movp2_ValRegDX,ax
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
                        mov Bp,p1_ValRegBp
                        mov cx,p1_ValRegCX
                        ROL Bp,cl
                        call ourSetCF
                        mov p1_ValRegBp,Bp
                        jmp Exit
                        ROL_Bp_Reg_his:
                        mov Bp,ValRegBp
                        mov cx,ValRegCX
                        ROL Bp,cl
                        call SetCarryFlag
                        movp2_ValRegBp,Bp
                        cmp selectedPUPType,2
                        je ROL_Bp_Reg_our
                        jmp Exit
                    ROL_Bp_Val:
                        cmp Op2Val,255d
                        ja ROL_invalid
                        cmp selectedPUPType,1
                        jne ROL_Bp_Val_his
                        ROL_Bp_Val_our:
                        mov Bp,p1_ValRegBp
                        mov cx,Op2Val
                        ROL Bp,cl
                        call ourSetCF
                        mov p1_ValRegBp,Bp
                        jmp Exit
                        ROL_Bp_Val_his:
                        mov ax,ValRegBp
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        ROL ax,cl
                        call SetCarryFlag
                        movp2_ValRegBp,ax
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
                        mov Sp,p1_ValRegSp
                        mov cx,p1_ValRegCX
                        ROL Sp,cl
                        call ourSetCF
                        mov p1_ValRegSp,Sp
                        jmp Exit
                        ROL_Sp_Reg_his:
                        mov Sp,ValRegSp
                        mov cx,ValRegCX
                        ROL Sp,cl
                        call SetCarryFlag
                        movp2_ValRegSp,Sp
                        cmp selectedPUPType,2
                        je ROL_Sp_Reg_our
                        jmp Exit
                    ROL_Sp_Val:
                        cmp Op2Val,255d
                        ja ROL_invalid
                        cmp selectedPUPType,1
                        jne ROL_Sp_Val_his
                        ROL_Sp_Val_our:
                        mov Sp,p1_ValRegSp
                        mov cx,Op2Val
                        ROL Sp,cl
                        call ourSetCF
                        mov p1_ValRegSp,Sp
                        jmp Exit
                        ROL_Sp_Val_his:
                        mov ax,ValRegSp
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        ROL ax,cl
                        call SetCarryFlag
                        movp2_ValRegSp,ax
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
                        mov Si,p1_ValRegSi
                        mov cx,p1_ValRegCX
                        ROL Si,cl
                        call ourSetCF
                        mov p1_ValRegSi,Si
                        jmp Exit
                        ROL_Si_Reg_his:
                        mov Si,ValRegSi
                        mov cx,ValRegCX
                        ROL Si,cl
                        call SetCarryFlag
                        movp2_ValRegSi,Si
                        cmp selectedPUPType,2
                        je ROL_Si_Reg_our
                        jmp Exit
                    ROL_Si_Val:
                        cmp Op2Val,255d
                        ja ROL_invalid
                        cmp selectedPUPType,1
                        jne ROL_Si_Val_his
                        ROL_Si_Val_our:
                        mov Si,p1_ValRegSi
                        mov cx,Op2Val
                        ROL Si,cl
                        call ourSetCF
                        mov p1_ValRegSi,Si
                        jmp Exit
                        ROL_Si_Val_his:
                        mov ax,ValRegSi
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        ROL ax,cl
                        call SetCarryFlag
                        movp2_ValRegSi,ax
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
                        mov Di,p1_ValRegDi
                        mov cx,p1_ValRegCX
                        ROL Di,cl
                        call ourSetCF
                        mov p1_ValRegDi,Di
                        jmp Exit
                        ROL_Di_Reg_his:
                        mov Di,ValRegDi
                        mov cx,ValRegCX
                        ROL Di,cl
                        call SetCarryFlag
                        movp2_ValRegDi,Di
                        cmp selectedPUPType,2
                        je ROL_Di_Reg_our
                        jmp Exit
                    ROL_Di_Val:
                        cmp Op2Val,255d
                        ja ROL_invalid
                        cmp selectedPUPType,1
                        jne ROL_Di_Val_his
                        ROL_Di_Val_our:
                        mov Di,p1_ValRegDi
                        mov cx,Op2Val
                        ROL Di,cl
                        call ourSetCF
                        mov p1_ValRegDi,Di
                        jmp Exit
                        ROL_Di_Val_his:
                        mov ax,ValRegDi
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        ROL ax,cl
                        call SetCarryFlag
                        movp2_ValRegDi,ax
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
                        mov Bx,p1_ValRegBX
                        cmp Bx,15d
                        ja ROL_invalid
                        mov cx,p1_ValRegCX
                        ROL p1_ValMem[Bx],cl
                        call ourSetCF
                        mov p1_ValRegBX,Bx
                        jmp Exit
                        ROL_AddBx_Reg_his:
                        mov Bx,ValRegBX
                        cmp Bx,15d
                        ja ROL_invalid
                        mov cx,ValRegCX
                        ;;;;;;;;;;;;;;;;;;;;;;;
                            mov al,ValMem[Bx]
                            call LineStuckPwrUp
                            movp2_ValMem[Bx],al
                        ROLp2_ValMem[Bx],cl
                        call SetCarryFlag
                        movp2_ValRegBX,Bx
                        cmp selectedPUPType,2
                        je ROL_AddBx_Reg_our
                        jmp Exit
                    ROL_AddBx_Val:
                        cmp Op2Val,255d
                        ja ROL_invalid
                        cmp selectedPUPType,1
                        jne ROL_AddBx_Val_his
                        ROL_AddBx_Val_our:
                        mov Bx,p1_ValRegBX
                        cmp Bx,15d
                        ja ROL_invalid
                        mov cx,Op2Val
                        ROL p1_ValMem[Bx],cl
                        call ourSetCF
                        mov p1_ValRegBX,Bx
                        jmp Exit
                        ROL_AddBx_Val_his:
                        mov Bx,ValRegBX
                        cmp Bx,15d
                        ja ROL_invalid
                        mov cx,Op2Val
                        ;;;;;;;;;;;;;;;;;;;;;;;
                            mov al,ValMem[Bx]
                            call LineStuckPwrUp
                            movp2_ValMem[Bx],al
                        ROLp2_ValMem[Bx],cl
                        call SetCarryFlag
                        movp2_ValRegBX,Bx
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
                        mov Bp,p1_ValRegBp
                        cmp Bp,15d
                        ja ROL_invalid
                        mov cx,p1_ValRegCX
                        ROL p1_ValMem[Bp],cl
                        call ourSetCF
                        mov p1_ValRegBp,Bp
                        jmp Exit
                        ROL_AddBp_Reg_his:
                        mov Bp,ValRegBp
                        cmp Bp,15d
                        ja ROL_invalid
                        mov cx,ValRegCX
                        ;;;;;;;;;;;;;;;;;;;;;;;
                            mov al,ValMem[Bp]
                            call LineStuckPwrUp
                            movp2_ValMem[Bp],al
                        ROLp2_ValMem[Bp],cl
                        call SetCarryFlag
                        movp2_ValRegBp,Bp
                        cmp selectedPUPType,2
                        je ROL_AddBp_Reg_our
                        jmp Exit
                    ROL_AddBp_Val:
                        cmp Op2Val,255d
                        ja ROL_invalid
                        cmp selectedPUPType,1
                        jne ROL_AddBp_Val_his
                        ROL_AddBp_Val_our:
                        mov Bp,p1_ValRegBp
                        cmp Bp,15d
                        ja ROL_invalid
                        mov cx,Op2Val
                        ROL p1_ValMem[Bp],cl
                        call ourSetCF
                        mov p1_ValRegBp,Bp
                        jmp Exit
                        ROL_AddBp_Val_his:
                        mov Bp,ValRegBp
                        cmp Bp,15d
                        ja ROL_invalid
                        mov cx,Op2Val
                        ;;;;;;;;;;;;;;;;;;;;;;;
                            mov al,ValMem[Bp]
                            call LineStuckPwrUp
                            movp2_ValMem[Bp],al
                        ROLp2_ValMem[Bp],cl
                        call SetCarryFlag
                        movp2_ValRegBp,Bp
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
                        mov Si,p1_ValRegSi
                        cmp Si,15d
                        ja ROL_invalid
                        mov cx,p1_ValRegCX
                        ROL p1_ValMem[Si],cl
                        call ourSetCF
                        mov p1_ValRegSi,Si
                        jmp Exit
                        ROL_AddSi_Reg_his:
                        mov Si,ValRegSi
                        cmp Si,15d
                        ja ROL_invalid
                        mov cx,ValRegCX
                        ;;;;;;;;;;;;;;;;;;;;;;;
                            mov al,ValMem[Si]
                            call LineStuckPwrUp
                            movp2_ValMem[Si],al
                        ROLp2_ValMem[Si],cl
                        call SetCarryFlag
                        movp2_ValRegSi,Si
                        cmp selectedPUPType,2
                        je ROL_AddSi_Reg_our
                        jmp Exit
                    ROL_AddSi_Val:
                        cmp Op2Val,255d
                        ja ROL_invalid
                        cmp selectedPUPType,1
                        jne ROL_AddSi_Val_his
                        ROL_AddSi_Val_our:
                        mov Si,p1_ValRegSi
                        cmp Si,15d
                        ja ROL_invalid
                        mov cx,Op2Val
                        ROL p1_ValMem[Si],cl
                        call ourSetCF
                        mov p1_ValRegSi,Si
                        jmp Exit
                        ROL_AddSi_Val_his:
                        mov Si,ValRegSi
                        cmp Si,15d
                        ja ROL_invalid
                        mov cx,Op2Val
                        ;;;;;;;;;;;;;;;;;;;;;;;
                            mov al,ValMem[Si]
                            call LineStuckPwrUp
                            movp2_ValMem[Si],al
                        ROLp2_ValMem[Si],cl
                        call SetCarryFlag
                        movp2_ValRegSi,Si
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
                        mov Di,p1_ValRegDi
                        cmp Di,15d
                        ja ROL_invalid
                        mov cx,p1_ValRegCX
                        ROL p1_ValMem[Di],cl
                        call ourSetCF
                        mov p1_ValRegDi,Di
                        jmp Exit
                        ROL_AddDi_Reg_his:
                        mov Di,ValRegDi
                        cmp Di,15d
                        ja ROL_invalid
                        mov cx,ValRegCX
                        ;;;;;;;;;;;;;;;;;;;;;;;
                            mov al,ValMem[Di]
                            call LineStuckPwrUp
                            movp2_ValMem[Di],al
                        ROLp2_ValMem[Di],cl
                        call SetCarryFlag
                        movp2_ValRegDi,Di
                        cmp selectedPUPType,2
                        je ROL_AddDi_Reg_our
                        jmp Exit
                    ROL_AddDi_Val:
                        cmp Op2Val,255d
                        ja ROL_invalid
                        cmp selectedPUPType,1
                        jne ROL_AddDi_Val_his
                        ROL_AddDi_Val_our:
                        mov Di,p1_ValRegDi
                        cmp Di,15d
                        ja ROL_invalid
                        mov cx,Op2Val
                        ROL p1_ValMem[Di],cl
                        call ourSetCF
                        mov p1_ValRegDi,Di
                        jmp Exit
                        ROL_AddDi_Val_his:
                        mov Di,ValRegDi
                        cmp Di,15d
                        ja ROL_invalid
                        mov cx,Op2Val
                        ;;;;;;;;;;;;;;;;;;;;;;;
                            mov al,ValMem[Di]
                            call LineStuckPwrUp
                            movp2_ValMem[Di],al
                        ROLp2_ValMem[Di],cl
                        call SetCarryFlag
                        movp2_ValRegDi,Di
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
                    mov cx,p1_ValRegCX
                    ROL p1_ValMem[si],cl
                    call ourSetCF
                    jmp Exit
                    ROL_Mem_Reg_his:
                    mov cx,ValRegCX
                    ;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[si]
                        call LineStuckPwrUp
                        movp2_ValMem[si],al
                    ROLp2_ValMem[si],cl
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
                    ROL p1_ValMem[si],cl
                    call ourSetCF
                    jmp Exit
                    ROL_Mem_Val_his:
                    mov cx,Op2Val
                    ;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[si]
                        call LineStuckPwrUp
                        movp2_ValMem[si],al
                    ROLp2_ValMem[si],cl
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
                        cmp selectedPUPType,1
                        jne RCR_Ax_Reg_his
                        RCR_Ax_Reg_our:
                        mov ax,p1_ValRegAX
                        mov cx,p1_ValRegCX
                        call ourGetCF
                        RCR Ax,cl
                        call ourSetCF
                        mov p1_ValRegAX,ax
                        jmp Exit
                        RCR_Ax_Reg_his:
                        mov ax,ValRegAX
                        mov cx,ValRegCX
                        call GetCarryFlag
                        RCR Ax,cl
                        call SetCarryFlag
                        movp2_ValRegAX,ax
                        cmp selectedPUPType,2
                        je RCR_Ax_Reg_our
                        jmp Exit
                    RCR_Ax_Val:
                        cmp Op2Val,255d
                        ja RCR_invalid
                        cmp selectedPUPType,1
                        jne RCR_Ax_Val_his
                        RCR_Ax_Val_our:
                        mov ax,p1_ValRegAX
                        mov cx,Op2Val
                        call ourGetCF
                        RCR ax,cl
                        call ourSetCF
                        mov p1_ValRegAX,ax
                        jmp Exit
                        RCR_Ax_Val_his:
                        mov ax,ValRegAX
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        call GetCarryFlag
                        RCR ax,cl
                        call SetCarryFlag
                        movp2_ValRegAX,ax
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
                        mov ax,p1_ValRegAX
                        mov cx,p1_ValRegCX
                        call ourGetCF
                        RCR Al,cl
                        call ourSetCF
                        mov p1_ValRegAX,ax
                        jmp Exit
                        RCR_Al_Reg_his:
                        mov ax,ValRegAX
                        mov cx,ValRegCX
                        call GetCarryFlag
                        RCR Al,cl
                        call SetCarryFlag
                        movp2_ValRegAX,ax
                        cmp selectedPUPType,2
                        je RCR_Al_Reg_our
                        jmp Exit
                    RCR_Al_Val:
                        cmp Op2Val,255d
                        ja RCR_invalid
                        cmp selectedPUPType,1
                        jne RCR_Al_Val_his
                        RCR_Al_Val_our:
                        mov ax,p1_ValRegAX
                        mov cx,Op2Val
                        call ourGetCF
                        RCR al,cl
                        call ourSetCF
                        mov p1_ValRegAX,ax
                        jmp Exit
                        RCR_Al_Val_his:
                        mov ax,ValRegAX
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        call GetCarryFlag
                        RCR al,cl
                        call SetCarryFlag
                        movp2_ValRegAX,ax
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
                        mov ax,p1_ValRegAX
                        mov cx,p1_ValRegCX
                        call ourGetCF
                        RCR Ah,cl
                        call ourSetCF
                        mov p1_ValRegAX,ax
                        jmp Exit
                        RCR_Ah_Reg_his:
                        mov ax,ValRegAX
                        mov cx,ValRegCX
                        call GetCarryFlag
                        RCR Ah,cl
                        call SetCarryFlag
                        movp2_ValRegAX,ax
                        cmp selectedPUPType,2
                        je RCR_Ah_Reg_our
                        jmp Exit
                    RCR_Ah_Val:
                        cmp Op2Val,255d
                        ja RCR_invalid
                        cmp selectedPUPType,1
                        jne RCR_Ah_Val_his
                        RCR_Ah_Val_our:
                        mov ax,p1_ValRegAX
                        mov cx,Op2Val
                        call ourGetCF
                        RCR ah,cl
                        call ourSetCF
                        mov p1_ValRegAX,ax
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
                        movp2_ValRegAX,ax
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
                        mov Bx,p1_ValRegBx
                        mov cx,p1_ValRegCX
                        call ourGetCF
                        RCR Bx,cl
                        call ourSetCF
                        mov p1_ValRegBx,Bx
                        jmp Exit
                        RCR_Bx_Reg_his:
                        mov Bx,ValRegBx
                        mov cx,ValRegCX
                        call GetCarryFlag
                        RCR Bx,cl
                        call SetCarryFlag
                        movp2_ValRegBx,Bx
                        cmp selectedPUPType,2
                        je RCR_Bx_Reg_our
                        jmp Exit
                    RCR_Bx_Val:
                        cmp Op2Val,255d
                        ja RCR_invalid
                        cmp selectedPUPType,1
                        jne RCR_Bx_Val_his
                        RCR_Bx_Val_our:
                        mov Bx,p1_ValRegBx
                        mov cx,Op2Val
                        call ourGetCF
                        RCR Bx,cl
                        call ourSetCF
                        mov p1_ValRegBx,Bx
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
                        movp2_ValRegBx,Bx
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
                        mov Bx,p1_ValRegBX
                        mov cx,p1_ValRegCX
                        call ourGetCF
                        RCR Bl,cl
                        call ourSetCF
                        mov p1_ValRegBX,Bx
                        jmp Exit
                        RCR_Bl_Reg_his:
                        mov Bx,ValRegBX
                        mov cx,ValRegCX
                        call GetCarryFlag
                        RCR Bl,cl
                        call SetCarryFlag
                        movp2_ValRegBX,Bx
                        cmp selectedPUPType,2
                        je RCR_Bl_Reg_our
                        jmp Exit
                    RCR_Bl_Val:
                        cmp Op2Val,255d
                        ja RCR_invalid
                        cmp selectedPUPType,1
                        RCR_Bl_Val_our:
                        mov Bx,p1_ValRegBX
                        mov cx,Op2Val
                        call ourGetCF
                        RCR Bl,cl
                        call ourSetCF
                        mov p1_ValRegBX,Bx
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
                        movp2_ValRegBX,Bx
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
                        mov Bx,p1_ValRegBX
                        mov cx,p1_ValRegCX
                        call ourGetCF
                        RCR Bh,cl
                        call ourSetCF
                        mov p1_ValRegBX,Bx
                        jmp Exit
                        RCR_Bh_Reg_his:
                        mov Bx,ValRegBX
                        mov cx,ValRegCX
                        call GetCarryFlag
                        RCR Bh,cl
                        call SetCarryFlag
                        movp2_ValRegBX,Bx
                        cmp selectedPUPType,2
                        je RCR_Bh_Reg_our
                        jmp Exit
                    RCR_Bh_Val:
                        cmp Op2Val,255d
                        ja RCR_invalid
                        cmp selectedPUPType,1
                        RCR_Bh_Val_our:
                        mov Bx,p1_ValRegBX
                        mov cx,Op2Val
                        call ourGetCF
                        RCR Bh,cl
                        call ourSetCF
                        mov p1_ValRegBX,Bx
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
                        movp2_ValRegBX,Bx
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
                        mov Cx,p1_ValRegCx
                        mov ax,cx
                        mov cx,ax
                        call ourGetCF
                        RCR Cx,cl
                        call ourSetCF
                        mov p1_ValRegCx,Cx
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
                        movp2_ValRegCx,Cx
                        cmp selectedPUPType,2
                        je RCR_Cx_Reg_our
                        jmp Exit
                    RCR_Cx_Val:
                        cmp Op2Val,255d
                        ja RCR_invalid
                        cmp selectedPUPType,1
                        jne RCR_Cx_Val_his
                        RCR_Cx_Val_our:
                        mov bx,p1_ValRegCx
                        mov cx,Op2Val
                        call ourGetCF
                        RCR bx,cl
                        call ourSetCF
                        mov p1_ValRegCx,bx
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
                        movp2_ValRegCx,bx
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
                        mov ax,p1_ValRegCX
                        mov cx,p1_ValRegCX
                        call ourGetCF
                        RCR Al,cl
                        call ourSetCF
                        mov p1_ValRegCX,ax
                        jmp Exit
                        RCR_Cl_Reg_his:
                        mov ax,ValRegCX
                        mov cx,ValRegCX
                        call GetCarryFlag
                        RCR Al,cl
                        call SetCarryFlag
                        movp2_ValRegCX,ax
                        cmp selectedPUPType,2
                        je RCR_Cl_Reg_our
                        jmp Exit
                    RCR_Cl_Val:
                        cmp Op2Val,255d
                        ja RCR_invalid
                        cmp selectedPUPType,1
                        jne RCR_Cl_Val_his
                        RCR_Cl_Val_our:
                        mov ax,p1_ValRegCX
                        mov cx,Op2Val
                        call ourGetCF
                        RCR al,cl
                        call ourSetCF
                        mov p1_ValRegCX,ax
                        jmp Exit
                        RCR_Cl_Val_his:
                        mov ax,ValRegCX
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        call GetCarryFlag
                        RCR al,cl
                        call SetCarryFlag
                        movp2_ValRegCX,ax
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
                        mov cx,p1_ValRegCX
                        call ourGetCF
                        RCR Ch,cl
                        call ourSetCF
                        mov p1_ValRegCX,Cx
                        jmp Exit
                        RCR_Ch_Reg_his:
                        mov cx,ValRegCX
                        call GetCarryFlag
                        RCR Ch,cl
                        call SetCarryFlag
                        movp2_ValRegCX,Cx
                        cmp selectedPUPType,2
                        je RCR_Ch_Reg_our
                        jmp Exit
                    RCR_Ch_Val:
                        cmp Op2Val,255d
                        ja RCR_invalid
                        cmp selectedPUPType,1
                        jne RCR_Ch_Val_his
                        RCR_Ch_Val_our:
                        mov ax,p1_ValRegCX
                        mov cx,Op2Val
                        call ourGetCF
                        RCR ah,cl
                        call ourSetCF
                        mov p1_ValRegCX,ax
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
                        movp2_ValRegCX,ax
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
                        mov Dx,p1_ValRegDx
                        mov cx,p1_ValRegCX
                        call ourGetCF
                        RCR Dx,cl
                        call ourSetCF
                        mov p1_ValRegDx,Dx
                        jmp Exit
                        RCR_Dx_Reg_his:
                        mov Dx,ValRegDx
                        mov cx,ValRegCX
                        call GetCarryFlag
                        RCR Dx,cl
                        call SetCarryFlag
                        movp2_ValRegDx,Dx
                        cmp selectedPUPType,2
                        je RCR_Dx_Reg_our
                        jmp Exit
                    RCR_Dx_Val:
                        cmp Op2Val,255d
                        ja RCR_invalid
                        cmp selectedPUPType,1
                        jne RCR_Dx_Val_his
                        RCR_Dx_Val_our:
                        mov ax,p1_ValRegDx
                        mov cx,Op2Val
                        call ourGetCF
                        RCR ax,cl
                        call ourSetCF
                        mov p1_ValRegDx,ax
                        jmp Exit
                        RCR_Dx_Val_his:
                        mov ax,ValRegDx
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        call GetCarryFlag
                        RCR ax,cl
                        call SetCarryFlag
                        movp2_ValRegDx,ax
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
                        mov Dx,p1_ValRegDX
                        mov cx,p1_ValRegCX
                        call ourGetCF
                        RCR Dl,cl
                        call ourSetCF
                        mov p1_ValRegDX,Dx
                        jmp Exit
                        RCR_Dl_Reg_his:
                        mov Dx,ValRegDX
                        mov cx,ValRegCX
                        call GetCarryFlag
                        RCR Dl,cl
                        call SetCarryFlag
                        movp2_ValRegDX,Dx
                        cmp selectedPUPType,2
                        je RCR_Dl_Reg_our
                        jmp Exit
                    RCR_Dl_Val:
                        cmp Op2Val,255d
                        ja RCR_invalid
                        cmp selectedPUPType,1
                        jne RCR_Dl_Val_his
                        RCR_Dl_Val_our:
                        mov Dx,p1_ValRegDX
                        mov cx,Op2Val
                        call ourGetCF
                        RCR Dl,cl
                        call ourSetCF
                        mov p1_ValRegDX,Dx
                        jmp Exit
                        RCR_Dl_Val_his:
                        mov ax,ValRegDX
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        call GetCarryFlag
                        RCR al,cl
                        call SetCarryFlag
                        movp2_ValRegDX,ax
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
                        mov Dx,p1_ValRegDX
                        mov cx,p1_ValRegCX
                        call ourGetCF
                        RCR dh,cl
                        call ourSetCF
                        mov p1_ValRegDX,Dx
                        jmp Exit
                        RCR_Dh_Reg_his:
                        mov Dx,ValRegDX
                        mov cx,ValRegCX
                        call GetCarryFlag
                        RCR dh,cl
                        call SetCarryFlag
                        movp2_ValRegDX,Dx
                        cmp selectedPUPType,2
                        je RCR_Dh_Reg_our
                        jmp Exit
                    RCR_Dh_Val:
                        cmp Op2Val,255d
                        ja RCR_invalid
                        cmp selectedPUPType,1
                        jne RCR_Dh_Val_his
                        RCR_Dh_Val_our:
                        mov Dx,p1_ValRegDX
                        mov cx,Op2Val
                        call ourGetCF
                        RCR dh,cl
                        call ourSetCF
                        mov p1_ValRegDX,Dx
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
                        movp2_ValRegDX,ax
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
                        mov Bp,p1_ValRegBp
                        mov cx,p1_ValRegCX
                        call ourGetCF
                        RCR Bp,cl
                        call ourSetCF
                        mov p1_ValRegBp,Bp
                        jmp Exit
                        RCR_Bp_Reg_his:
                        mov Bp,ValRegBp
                        mov cx,ValRegCX
                        call GetCarryFlag
                        RCR Bp,cl
                        call SetCarryFlag
                        movp2_ValRegBp,Bp
                        cmp selectedPUPType,2
                        je RCR_Bp_Reg_our
                        jmp Exit
                    RCR_Bp_Val:
                        cmp Op2Val,255d
                        ja RCR_invalid
                        cmp selectedPUPType,1
                        jne RCR_Bp_Val_his
                        RCR_Bp_Val_our:
                        mov Bp,p1_ValRegBp
                        mov cx,Op2Val
                        call ourGetCF
                        RCR Bp,cl
                        call ourSetCF
                        mov p1_ValRegBp,Bp
                        jmp Exit
                        RCR_Bp_Val_his:
                        mov ax,ValRegBp
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        call GetCarryFlag
                        RCR ax,cl
                        call SetCarryFlag
                        movp2_ValRegBp,ax
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
                        mov Sp,p1_ValRegSp
                        mov cx,p1_ValRegCX
                        call ourGetCF
                        RCR Sp,cl
                        call ourSetCF
                        mov p1_ValRegSp,Sp
                        jmp Exit
                        RCR_Sp_Reg_his:
                        mov Sp,ValRegSp
                        mov cx,ValRegCX
                        call GetCarryFlag
                        RCR Sp,cl
                        call SetCarryFlag
                        movp2_ValRegSp,Sp
                        cmp selectedPUPType,2
                        je RCR_Sp_Reg_our
                        jmp Exit
                    RCR_Sp_Val:
                        cmp Op2Val,255d
                        ja RCR_invalid
                        cmp selectedPUPType,1
                        jne RCR_Sp_Val_his
                        RCR_Sp_Val_our:
                        mov Sp,p1_ValRegSp
                        mov cx,Op2Val
                        call ourGetCF
                        RCR Sp,cl
                        call ourSetCF
                        mov p1_ValRegSp,Sp
                        jmp Exit
                        RCR_Sp_Val_his:
                        mov ax,ValRegSp
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        call GetCarryFlag
                        RCR ax,cl
                        call SetCarryFlag
                        movp2_ValRegSp,ax
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
                        mov Si,p1_ValRegSi
                        mov cx,p1_ValRegCX
                        call ourGetCF
                        RCR Si,cl
                        call ourSetCF
                        mov p1_ValRegSi,Si
                        jmp Exit
                        RCR_Si_Reg_his:
                        mov Si,ValRegSi
                        mov cx,ValRegCX
                        call GetCarryFlag
                        RCR Si,cl
                        call SetCarryFlag
                        movp2_ValRegSi,Si
                        cmp selectedPUPType,2
                        je RCR_Si_Reg_our
                        jmp Exit
                    RCR_Si_Val:
                        cmp Op2Val,255d
                        ja RCR_invalid
                        cmp selectedPUPType,1
                        jne RCR_Si_Val_his
                        RCR_Si_Val_our:
                        mov Si,p1_ValRegSi
                        mov cx,Op2Val
                        call ourGetCF
                        RCR Si,cl
                        call ourSetCF
                        mov p1_ValRegSi,Si
                        jmp Exit
                        RCR_Si_Val_his:
                        mov ax,ValRegSi
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        call GetCarryFlag
                        RCR ax,cl
                        call SetCarryFlag
                        movp2_ValRegSi,ax
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
                        mov Di,p1_ValRegDi
                        mov cx,p1_ValRegCX
                        call ourGetCF
                        RCR Di,cl
                        call ourSetCF
                        mov p1_ValRegDi,Di
                        jmp Exit
                        RCR_Di_Reg_his:
                        mov Di,ValRegDi
                        mov cx,ValRegCX
                        call GetCarryFlag
                        RCR Di,cl
                        call SetCarryFlag
                        movp2_ValRegDi,Di
                        cmp selectedPUPType,2
                        je RCR_Di_Reg_our
                        jmp Exit
                    RCR_Di_Val:
                        cmp Op2Val,255d
                        ja RCR_invalid
                        cmp selectedPUPType,1
                        jne RCR_Di_Val_his
                        RCR_Di_Val_our:
                        mov Di,p1_ValRegDi
                        mov cx,Op2Val
                        call ourGetCF
                        RCR Di,cl
                        call ourSetCF
                        mov p1_ValRegDi,Di
                        jmp Exit
                        RCR_Di_Val_his:
                        mov ax,ValRegDi
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        call GetCarryFlag
                        RCR ax,cl
                        call SetCarryFlag
                        movp2_ValRegDi,ax
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
                        mov Bx,p1_ValRegBX
                        cmp Bx,15d
                        ja RCR_invalid
                        mov cx,p1_ValRegCX
                        call ourGetCF
                        RCR p1_ValMem[Bx],cl
                        call ourSetCF
                        mov p1_ValRegBX,Bx
                        jmp Exit
                        RCR_AddBx_Reg_his:
                        mov Bx,ValRegBX
                        cmp Bx,15d
                        ja RCR_invalid
                        mov cx,ValRegCX
                        ;;;;;;;;;;;;;;;;;;;;;;;
                            mov al,ValMem[Bx]
                            call LineStuckPwrUp
                            movp2_ValMem[Bx],al
                        call GetCarryFlag
                        RCRp2_ValMem[Bx],cl
                        call SetCarryFlag
                        movp2_ValRegBX,Bx
                        cmp selectedPUPType,2
                        je RCR_AddBx_Reg_our
                        jmp Exit
                    RCR_AddBx_Val:
                        cmp Op2Val,255d
                        ja RCR_invalid
                        cmp selectedPUPType,1
                        jne RCR_AddBx_Val_his
                        RCR_AddBx_Val_our:
                        mov Bx,p1_ValRegBX
                        cmp Bx,15d
                        ja RCR_invalid
                        mov cx,Op2Val
                        call ourGetCF
                        RCR p1_ValMem[Bx],cl
                        call ourSetCF
                        mov p1_ValRegBX,Bx
                        jmp Exit
                        RCR_AddBx_Val_his:
                        mov Bx,ValRegBX
                        cmp Bx,15d
                        ja RCR_invalid
                        mov cx,Op2Val
                        ;;;;;;;;;;;;;;;;;;;;;;;
                            mov al,ValMem[Bx]
                            call LineStuckPwrUp
                            movp2_ValMem[Bx],al
                        call GetCarryFlag
                        RCRp2_ValMem[Bx],cl
                        call SetCarryFlag
                        movp2_ValRegBX,Bx
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
                        mov Bp,p1_ValRegBp
                        cmp Bp,15d
                        ja RCR_invalid
                        mov cx,p1_ValRegCX
                        call ourGetCF
                        RCR p1_ValMem[Bp],cl
                        call ourSetCF
                        mov p1_ValRegBp,Bp
                        jmp Exit
                        RCR_AddBp_Reg_his:
                        mov Bp,ValRegBp
                        cmp Bp,15d
                        ja RCR_invalid
                        mov cx,ValRegCX
                        ;;;;;;;;;;;;;;;;;;;;;;;
                            mov al,ValMem[Bp]
                            call LineStuckPwrUp
                            movp2_ValMem[Bp],al
                        call GetCarryFlag
                        RCRp2_ValMem[Bp],cl
                        call SetCarryFlag
                        movp2_ValRegBp,Bp
                        cmp selectedPUPType,2
                        je RCR_AddBp_Reg_our
                        jmp Exit
                    RCR_AddBp_Val:
                        cmp Op2Val,255d
                        ja RCR_invalid
                        cmp selectedPUPType,1
                        jne RCR_AddBp_Val_his
                        RCR_AddBp_Val_our:
                        mov Bp,p1_ValRegBp
                        cmp Bp,15d
                        ja RCR_invalid
                        mov cx,Op2Val
                        call ourGetCF
                        RCR p1_ValMem[Bp],cl
                        call ourSetCF
                        mov p1_ValRegBp,Bp
                        jmp Exit
                        RCR_AddBp_Val_his:
                        mov Bp,ValRegBp
                        cmp Bp,15d
                        ja RCR_invalid
                        mov cx,Op2Val
                        ;;;;;;;;;;;;;;;;;;;;;;;
                            mov al,ValMem[Bp]
                            call LineStuckPwrUp
                            movp2_ValMem[Bp],al
                        call GetCarryFlag
                        RCRp2_ValMem[Bp],cl
                        call SetCarryFlag
                        movp2_ValRegBp,Bp
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
                        mov Si,p1_ValRegSi
                        cmp Si,15d
                        ja RCR_invalid
                        mov cx,p1_ValRegCX
                        call ourGetCF
                        RCR p1_ValMem[Si],cl
                        call ourSetCF
                        mov p1_ValRegSi,Si
                        jmp Exit
                        RCR_AddSi_Reg_his:
                        mov Si,ValRegSi
                        cmp Si,15d
                        ja RCR_invalid
                        mov cx,ValRegCX
                        ;;;;;;;;;;;;;;;;;;;;;;;
                            mov al,ValMem[Si]
                            call LineStuckPwrUp
                            movp2_ValMem[Si],al
                        call GetCarryFlag
                        RCRp2_ValMem[Si],cl
                        call SetCarryFlag
                        movp2_ValRegSi,Si
                        cmp selectedPUPType,2
                        je RCR_AddSi_Reg_our
                        jmp Exit
                    RCR_AddSi_Val:
                        cmp Op2Val,255d
                        ja RCR_invalid
                        cmp selectedPUPType,1
                        jne RCR_AddSi_Val_his
                        RCR_AddSi_Val_our:
                        mov Si,p1_ValRegSi
                        cmp Si,15d
                        ja RCR_invalid
                        mov cx,Op2Val
                        call ourGetCF
                        RCR p1_ValMem[Si],cl
                        call ourSetCF
                        mov p1_ValRegSi,Si
                        jmp Exit
                        RCR_AddSi_Val_his:
                        mov Si,ValRegSi
                        cmp Si,15d
                        ja RCR_invalid
                        mov cx,Op2Val
                        ;;;;;;;;;;;;;;;;;;;;;;;
                            mov al,ValMem[Si]
                            call LineStuckPwrUp
                            movp2_ValMem[Si],al
                        call GetCarryFlag
                        RCRp2_ValMem[Si],cl
                        call SetCarryFlag
                        movp2_ValRegSi,Si
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
                        mov Di,p1_ValRegDi
                        cmp Di,15d
                        ja RCR_invalid
                        mov cx,p1_ValRegCX
                        call ourGetCF
                        RCR p1_ValMem[Di],cl
                        call ourSetCF
                        mov p1_ValRegDi,Di
                        jmp Exit
                        RCR_AddDi_Reg_his:
                        mov Di,ValRegDi
                        cmp Di,15d
                        ja RCR_invalid
                        mov cx,ValRegCX
                        ;;;;;;;;;;;;;;;;;;;;;;;
                            mov al,ValMem[Di]
                            call LineStuckPwrUp
                            movp2_ValMem[Di],al
                        call GetCarryFlag
                        RCRp2_ValMem[Di],cl
                        call SetCarryFlag
                        movp2_ValRegDi,Di
                        cmp selectedPUPType,2
                        je RCR_AddDi_Reg_our
                        jmp Exit
                    RCR_AddDi_Val:
                        cmp Op2Val,255d
                        ja RCR_invalid
                        cmp selectedPUPType,1
                        jne RCR_AddDi_Val_his
                        RCR_AddDi_Val_our:
                        mov Di,p1_ValRegDi
                        cmp Di,15d
                        ja RCR_invalid
                        mov cx,Op2Val
                        call ourGetCF
                        RCR p1_ValMem[Di],cl
                        call ourSetCF
                        mov p1_ValRegDi,Di
                        jmp Exit
                        RCR_AddDi_Val_his:
                        mov Di,ValRegDi
                        cmp Di,15d
                        ja RCR_invalid
                        mov cx,Op2Val
                        ;;;;;;;;;;;;;;;;;;;;;;;
                            mov al,ValMem[Di]
                            call LineStuckPwrUp
                            movp2_ValMem[Di],al
                        call GetCarryFlag
                        RCRp2_ValMem[Di],cl
                        call SetCarryFlag
                        movp2_ValRegDi,Di
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
                    mov cx,p1_ValRegCX
                    call ourGetCF
                    RCR p1_ValMem[si],cl
                    call ourSetCF
                    jmp Exit
                    RCR_Mem_Reg_his:
                    mov cx,ValRegCX
                    ;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[si]
                        call LineStuckPwrUp
                        movp2_ValMem[si],al
                    call GetCarryFlag
                    RCRp2_ValMem[si],cl
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
                    RCR p1_ValMem[si],cl
                    call ourSetCF
                    jmp Exit
                    RCR_Mem_Val_his:
                    mov cx,Op2Val
                    ;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[si]
                        call LineStuckPwrUp
                        movp2_ValMem[si],al
                    call GetCarryFlag
                    RCRp2_ValMem[si],cl
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
                        cmp selectedPUPType,1
                        jne RCL_Ax_Reg_his
                        RCL_Ax_Reg_our:
                        mov ax,p1_ValRegAX
                        mov cx,p1_ValRegCX
                        call ourGetCF
                        RCL Ax,cl
                        call ourSetCF
                        mov p1_ValRegAX,ax
                        jmp Exit
                        RCL_Ax_Reg_his:
                        mov ax,ValRegAX
                        mov cx,ValRegCX
                        call GetCarryFlag
                        RCL Ax,cl
                        call SetCarryFlag
                        movp2_ValRegAX,ax
                        cmp selectedPUPType,2
                        je RCL_Ax_Reg_our
                        jmp Exit
                    RCL_Ax_Val:
                        cmp Op2Val,255d
                        ja RCL_invalid
                        cmp selectedPUPType,1
                        jne RCL_Ax_Val_his
                        RCL_Ax_Val_our:
                        mov ax,p1_ValRegAX
                        mov cx,Op2Val
                        call ourGetCF
                        RCL ax,cl
                        call ourSetCF
                        mov p1_ValRegAX,ax
                        jmp Exit
                        RCL_Ax_Val_his:
                        mov ax,ValRegAX
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        call GetCarryFlag
                        RCL ax,cl
                        call SetCarryFlag
                        movp2_ValRegAX,ax
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
                        mov ax,p1_ValRegAX
                        mov cx,p1_ValRegCX
                        call ourGetCF
                        RCL Al,cl
                        call ourSetCF
                        mov p1_ValRegAX,ax
                        jmp Exit
                        RCL_Al_Reg_his:
                        mov ax,ValRegAX
                        mov cx,ValRegCX
                        call GetCarryFlag
                        RCL Al,cl
                        call SetCarryFlag
                        movp2_ValRegAX,ax
                        cmp selectedPUPType,2
                        je RCL_Al_Reg_our
                        jmp Exit
                    RCL_Al_Val:
                        cmp Op2Val,255d
                        ja RCL_invalid
                        cmp selectedPUPType,1
                        jne RCL_Al_Val_his
                        RCL_Al_Val_our:
                        mov ax,p1_ValRegAX
                        mov cx,Op2Val
                        call ourGetCF
                        RCL al,cl
                        call ourSetCF
                        mov p1_ValRegAX,ax
                        jmp Exit
                        RCL_Al_Val_his:
                        mov ax,ValRegAX
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        call GetCarryFlag
                        RCL al,cl
                        call SetCarryFlag
                        movp2_ValRegAX,ax
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
                        mov ax,p1_ValRegAX
                        mov cx,p1_ValRegCX
                        call ourGetCF
                        RCL Ah,cl
                        call ourSetCF
                        mov p1_ValRegAX,ax
                        jmp Exit
                        RCL_Ah_Reg_his:
                        mov ax,ValRegAX
                        mov cx,ValRegCX
                        call GetCarryFlag
                        RCL Ah,cl
                        call SetCarryFlag
                        movp2_ValRegAX,ax
                        cmp selectedPUPType,2
                        je RCL_Ah_Reg_our
                        jmp Exit
                    RCL_Ah_Val:
                        cmp Op2Val,255d
                        ja RCL_invalid
                        cmp selectedPUPType,1
                        jne RCL_Ah_Val_his
                        RCL_Ah_Val_our:
                        mov ax,p1_ValRegAX
                        mov cx,Op2Val
                        call ourGetCF
                        RCL ah,cl
                        call ourSetCF
                        mov p1_ValRegAX,ax
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
                        movp2_ValRegAX,ax
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
                        mov Bx,p1_ValRegBx
                        mov cx,p1_ValRegCX
                        call ourGetCF
                        RCL Bx,cl
                        call ourSetCF
                        mov p1_ValRegBx,Bx
                        jmp Exit
                        RCL_Bx_Reg_his:
                        mov Bx,ValRegBx
                        mov cx,ValRegCX
                        call GetCarryFlag
                        RCL Bx,cl
                        call SetCarryFlag
                        movp2_ValRegBx,Bx
                        cmp selectedPUPType,2
                        je RCL_Bx_Reg_our
                        jmp Exit
                    RCL_Bx_Val:
                        cmp Op2Val,255d
                        ja RCL_invalid
                        cmp selectedPUPType,1
                        jne RCL_Bx_Val_his
                        RCL_Bx_Val_our:
                        mov Bx,p1_ValRegBx
                        mov cx,Op2Val
                        call ourGetCF
                        RCL Bx,cl
                        call ourSetCF
                        mov p1_ValRegBx,Bx
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
                        movp2_ValRegBx,Bx
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
                        mov Bx,p1_ValRegBX
                        mov cx,p1_ValRegCX
                        call ourGetCF
                        RCL Bl,cl
                        call ourSetCF
                        mov p1_ValRegBX,Bx
                        jmp Exit
                        RCL_Bl_Reg_his:
                        mov Bx,ValRegBX
                        mov cx,ValRegCX
                        call GetCarryFlag
                        RCL Bl,cl
                        call SetCarryFlag
                        movp2_ValRegBX,Bx
                        cmp selectedPUPType,2
                        je RCL_Bl_Reg_our
                        jmp Exit
                    RCL_Bl_Val:
                        cmp Op2Val,255d
                        ja RCL_invalid
                        cmp selectedPUPType,1
                        RCL_Bl_Val_our:
                        mov Bx,p1_ValRegBX
                        mov cx,Op2Val
                        call ourGetCF
                        RCL Bl,cl
                        call ourSetCF
                        mov p1_ValRegBX,Bx
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
                        movp2_ValRegBX,Bx
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
                        mov Bx,p1_ValRegBX
                        mov cx,p1_ValRegCX
                        call ourGetCF
                        RCL Bh,cl
                        call ourSetCF
                        mov p1_ValRegBX,Bx
                        jmp Exit
                        RCL_Bh_Reg_his:
                        mov Bx,ValRegBX
                        mov cx,ValRegCX
                        call GetCarryFlag
                        RCL Bh,cl
                        call SetCarryFlag
                        movp2_ValRegBX,Bx
                        cmp selectedPUPType,2
                        je RCL_Bh_Reg_our
                        jmp Exit
                    RCL_Bh_Val:
                        cmp Op2Val,255d
                        ja RCL_invalid
                        cmp selectedPUPType,1
                        RCL_Bh_Val_our:
                        mov Bx,p1_ValRegBX
                        mov cx,Op2Val
                        call ourGetCF
                        RCL Bh,cl
                        call ourSetCF
                        mov p1_ValRegBX,Bx
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
                        movp2_ValRegBX,Bx
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
                        mov Cx,p1_ValRegCx
                        mov ax,cx
                        mov cx,ax
                        call ourGetCF
                        RCL Cx,cl
                        call ourSetCF
                        mov p1_ValRegCx,Cx
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
                        movp2_ValRegCx,Cx
                        cmp selectedPUPType,2
                        je RCL_Cx_Reg_our
                        jmp Exit
                    RCL_Cx_Val:
                        cmp Op2Val,255d
                        ja RCL_invalid
                        cmp selectedPUPType,1
                        jne RCL_Cx_Val_his
                        RCL_Cx_Val_our:
                        mov bx,p1_ValRegCx
                        mov cx,Op2Val
                        call ourGetCF
                        RCL bx,cl
                        call ourSetCF
                        mov p1_ValRegCx,bx
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
                        movp2_ValRegCx,bx
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
                        mov ax,p1_ValRegCX
                        mov cx,p1_ValRegCX
                        call ourGetCF
                        RCL Al,cl
                        call ourSetCF
                        mov p1_ValRegCX,ax
                        jmp Exit
                        RCL_Cl_Reg_his:
                        mov ax,ValRegCX
                        mov cx,ValRegCX
                        call GetCarryFlag
                        RCL Al,cl
                        call SetCarryFlag
                        movp2_ValRegCX,ax
                        cmp selectedPUPType,2
                        je RCL_Cl_Reg_our
                        jmp Exit
                    RCL_Cl_Val:
                        cmp Op2Val,255d
                        ja RCL_invalid
                        cmp selectedPUPType,1
                        jne RCL_Cl_Val_his
                        RCL_Cl_Val_our:
                        mov ax,p1_ValRegCX
                        mov cx,Op2Val
                        call ourGetCF
                        RCL al,cl
                        call ourSetCF
                        mov p1_ValRegCX,ax
                        jmp Exit
                        RCL_Cl_Val_his:
                        mov ax,ValRegCX
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        call GetCarryFlag
                        RCL al,cl
                        call SetCarryFlag
                        movp2_ValRegCX,ax
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
                        mov cx,p1_ValRegCX
                        call ourGetCF
                        RCL Ch,cl
                        call ourSetCF
                        mov p1_ValRegCX,Cx
                        jmp Exit
                        RCL_Ch_Reg_his:
                        mov cx,ValRegCX
                        call GetCarryFlag
                        RCL Ch,cl
                        call SetCarryFlag
                        movp2_ValRegCX,Cx
                        cmp selectedPUPType,2
                        je RCL_Ch_Reg_our
                        jmp Exit
                    RCL_Ch_Val:
                        cmp Op2Val,255d
                        ja RCL_invalid
                        cmp selectedPUPType,1
                        jne RCL_Ch_Val_his
                        RCL_Ch_Val_our:
                        mov ax,p1_ValRegCX
                        mov cx,Op2Val
                        call ourGetCF
                        RCL ah,cl
                        call ourSetCF
                        mov p1_ValRegCX,ax
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
                        movp2_ValRegCX,ax
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
                        mov Dx,p1_ValRegDx
                        mov cx,p1_ValRegCX
                        call ourGetCF
                        RCL Dx,cl
                        call ourSetCF
                        mov p1_ValRegDx,Dx
                        jmp Exit
                        RCL_Dx_Reg_his:
                        mov Dx,ValRegDx
                        mov cx,ValRegCX
                        call GetCarryFlag
                        RCL Dx,cl
                        call SetCarryFlag
                        movp2_ValRegDx,Dx
                        cmp selectedPUPType,2
                        je RCL_Dx_Reg_our
                        jmp Exit
                    RCL_Dx_Val:
                        cmp Op2Val,255d
                        ja RCL_invalid
                        cmp selectedPUPType,1
                        jne RCL_Dx_Val_his
                        RCL_Dx_Val_our:
                        mov ax,p1_ValRegDx
                        mov cx,Op2Val
                        call ourGetCF
                        RCL ax,cl
                        call ourSetCF
                        mov p1_ValRegDx,ax
                        jmp Exit
                        RCL_Dx_Val_his:
                        mov ax,ValRegDx
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        call GetCarryFlag
                        RCL ax,cl
                        call SetCarryFlag
                        movp2_ValRegDx,ax
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
                        mov Dx,p1_ValRegDX
                        mov cx,p1_ValRegCX
                        call ourGetCF
                        RCL Dl,cl
                        call ourSetCF
                        mov p1_ValRegDX,Dx
                        jmp Exit
                        RCL_Dl_Reg_his:
                        mov Dx,ValRegDX
                        mov cx,ValRegCX
                        call GetCarryFlag
                        RCL Dl,cl
                        call SetCarryFlag
                        movp2_ValRegDX,Dx
                        cmp selectedPUPType,2
                        je RCL_Dl_Reg_our
                        jmp Exit
                    RCL_Dl_Val:
                        cmp Op2Val,255d
                        ja RCL_invalid
                        cmp selectedPUPType,1
                        jne RCL_Dl_Val_his
                        RCL_Dl_Val_our:
                        mov Dx,p1_ValRegDX
                        mov cx,Op2Val
                        call ourGetCF
                        RCL Dl,cl
                        call ourSetCF
                        mov p1_ValRegDX,Dx
                        jmp Exit
                        RCL_Dl_Val_his:
                        mov ax,ValRegDX
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        call GetCarryFlag
                        RCL al,cl
                        call SetCarryFlag
                        movp2_ValRegDX,ax
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
                        mov Dx,p1_ValRegDX
                        mov cx,p1_ValRegCX
                        call ourGetCF
                        RCL dh,cl
                        call ourSetCF
                        mov p1_ValRegDX,Dx
                        jmp Exit
                        RCL_Dh_Reg_his:
                        mov Dx,ValRegDX
                        mov cx,ValRegCX
                        call GetCarryFlag
                        RCL dh,cl
                        call SetCarryFlag
                        movp2_ValRegDX,Dx
                        cmp selectedPUPType,2
                        je RCL_Dh_Reg_our
                        jmp Exit
                    RCL_Dh_Val:
                        cmp Op2Val,255d
                        ja RCL_invalid
                        cmp selectedPUPType,1
                        jne RCL_Dh_Val_his
                        RCL_Dh_Val_our:
                        mov Dx,p1_ValRegDX
                        mov cx,Op2Val
                        call ourGetCF
                        RCL dh,cl
                        call ourSetCF
                        mov p1_ValRegDX,Dx
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
                        movp2_ValRegDX,ax
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
                        mov Bp,p1_ValRegBp
                        mov cx,p1_ValRegCX
                        call ourGetCF
                        RCL Bp,cl
                        call ourSetCF
                        mov p1_ValRegBp,Bp
                        jmp Exit
                        RCL_Bp_Reg_his:
                        mov Bp,ValRegBp
                        mov cx,ValRegCX
                        call GetCarryFlag
                        RCL Bp,cl
                        call SetCarryFlag
                        movp2_ValRegBp,Bp
                        cmp selectedPUPType,2
                        je RCL_Bp_Reg_our
                        jmp Exit
                    RCL_Bp_Val:
                        cmp Op2Val,255d
                        ja RCL_invalid
                        cmp selectedPUPType,1
                        jne RCL_Bp_Val_his
                        RCL_Bp_Val_our:
                        mov Bp,p1_ValRegBp
                        mov cx,Op2Val
                        call ourGetCF
                        RCL Bp,cl
                        call ourSetCF
                        mov p1_ValRegBp,Bp
                        jmp Exit
                        RCL_Bp_Val_his:
                        mov ax,ValRegBp
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        call GetCarryFlag
                        RCL ax,cl
                        call SetCarryFlag
                        movp2_ValRegBp,ax
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
                        mov Sp,p1_ValRegSp
                        mov cx,p1_ValRegCX
                        call ourGetCF
                        RCL Sp,cl
                        call ourSetCF
                        mov p1_ValRegSp,Sp
                        jmp Exit
                        RCL_Sp_Reg_his:
                        mov Sp,ValRegSp
                        mov cx,ValRegCX
                        call GetCarryFlag
                        RCL Sp,cl
                        call SetCarryFlag
                        movp2_ValRegSp,Sp
                        cmp selectedPUPType,2
                        je RCL_Sp_Reg_our
                        jmp Exit
                    RCL_Sp_Val:
                        cmp Op2Val,255d
                        ja RCL_invalid
                        cmp selectedPUPType,1
                        jne RCL_Sp_Val_his
                        RCL_Sp_Val_our:
                        mov Sp,p1_ValRegSp
                        mov cx,Op2Val
                        call ourGetCF
                        RCL Sp,cl
                        call ourSetCF
                        mov p1_ValRegSp,Sp
                        jmp Exit
                        RCL_Sp_Val_his:
                        mov ax,ValRegSp
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        call GetCarryFlag
                        RCL ax,cl
                        call SetCarryFlag
                        movp2_ValRegSp,ax
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
                        mov Si,p1_ValRegSi
                        mov cx,p1_ValRegCX
                        call ourGetCF
                        RCL Si,cl
                        call ourSetCF
                        mov p1_ValRegSi,Si
                        jmp Exit
                        RCL_Si_Reg_his:
                        mov Si,ValRegSi
                        mov cx,ValRegCX
                        call GetCarryFlag
                        RCL Si,cl
                        call SetCarryFlag
                        movp2_ValRegSi,Si
                        cmp selectedPUPType,2
                        je RCL_Si_Reg_our
                        jmp Exit
                    RCL_Si_Val:
                        cmp Op2Val,255d
                        ja RCL_invalid
                        cmp selectedPUPType,1
                        jne RCL_Si_Val_his
                        RCL_Si_Val_our:
                        mov Si,p1_ValRegSi
                        mov cx,Op2Val
                        call ourGetCF
                        RCL Si,cl
                        call ourSetCF
                        mov p1_ValRegSi,Si
                        jmp Exit
                        RCL_Si_Val_his:
                        mov ax,ValRegSi
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        call GetCarryFlag
                        RCL ax,cl
                        call SetCarryFlag
                        movp2_ValRegSi,ax
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
                        mov Di,p1_ValRegDi
                        mov cx,p1_ValRegCX
                        call ourGetCF
                        RCL Di,cl
                        call ourSetCF
                        mov p1_ValRegDi,Di
                        jmp Exit
                        RCL_Di_Reg_his:
                        mov Di,ValRegDi
                        mov cx,ValRegCX
                        call GetCarryFlag
                        RCL Di,cl
                        call SetCarryFlag
                        movp2_ValRegDi,Di
                        cmp selectedPUPType,2
                        je RCL_Di_Reg_our
                        jmp Exit
                    RCL_Di_Val:
                        cmp Op2Val,255d
                        ja RCL_invalid
                        cmp selectedPUPType,1
                        jne RCL_Di_Val_his
                        RCL_Di_Val_our:
                        mov Di,p1_ValRegDi
                        mov cx,Op2Val
                        call ourGetCF
                        RCL Di,cl
                        call ourSetCF
                        mov p1_ValRegDi,Di
                        jmp Exit
                        RCL_Di_Val_his:
                        mov ax,ValRegDi
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        call GetCarryFlag
                        RCL ax,cl
                        call SetCarryFlag
                        movp2_ValRegDi,ax
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
                        mov Bx,p1_ValRegBX
                        cmp Bx,15d
                        ja RCL_invalid
                        mov cx,p1_ValRegCX
                        call ourGetCF
                        RCL p1_ValMem[Bx],cl
                        call ourSetCF
                        mov p1_ValRegBX,Bx
                        jmp Exit
                        RCL_AddBx_Reg_his:
                        mov Bx,ValRegBX
                        cmp Bx,15d
                        ja RCL_invalid
                        mov cx,ValRegCX
                        ;;;;;;;;;;;;;;;;;;;;;;;
                            mov al,ValMem[Bx]
                            call LineStuckPwrUp
                            movp2_ValMem[Bx],al
                        call GetCarryFlag
                        RCLp2_ValMem[Bx],cl
                        call SetCarryFlag
                        movp2_ValRegBX,Bx
                        cmp selectedPUPType,2
                        je RCL_AddBx_Reg_our
                        jmp Exit
                    RCL_AddBx_Val:
                        cmp Op2Val,255d
                        ja RCL_invalid
                        cmp selectedPUPType,1
                        jne RCL_AddBx_Val_his
                        RCL_AddBx_Val_our:
                        mov Bx,p1_ValRegBX
                        cmp Bx,15d
                        ja RCL_invalid
                        mov cx,Op2Val
                        call ourGetCF
                        RCL p1_ValMem[Bx],cl
                        call ourSetCF
                        mov p1_ValRegBX,Bx
                        jmp Exit
                        RCL_AddBx_Val_his:
                        mov Bx,ValRegBX
                        cmp Bx,15d
                        ja RCL_invalid
                        mov cx,Op2Val
                        ;;;;;;;;;;;;;;;;;;;;;;;
                            mov al,ValMem[Bx]
                            call LineStuckPwrUp
                            movp2_ValMem[Bx],al
                        call GetCarryFlag
                        RCLp2_ValMem[Bx],cl
                        call SetCarryFlag
                        movp2_ValRegBX,Bx
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
                        mov Bp,p1_ValRegBp
                        cmp Bp,15d
                        ja RCL_invalid
                        mov cx,p1_ValRegCX
                        call ourGetCF
                        RCL p1_ValMem[Bp],cl
                        call ourSetCF
                        mov p1_ValRegBp,Bp
                        jmp Exit
                        RCL_AddBp_Reg_his:
                        mov Bp,ValRegBp
                        cmp Bp,15d
                        ja RCL_invalid
                        mov cx,ValRegCX
                        ;;;;;;;;;;;;;;;;;;;;;;;
                            mov al,ValMem[Bp]
                            call LineStuckPwrUp
                            movp2_ValMem[Bp],al
                        call GetCarryFlag
                        RCLp2_ValMem[Bp],cl
                        call SetCarryFlag
                        movp2_ValRegBp,Bp
                        cmp selectedPUPType,2
                        je RCL_AddBp_Reg_our
                        jmp Exit
                    RCL_AddBp_Val:
                        cmp Op2Val,255d
                        ja RCL_invalid
                        cmp selectedPUPType,1
                        jne RCL_AddBp_Val_his
                        RCL_AddBp_Val_our:
                        mov Bp,p1_ValRegBp
                        cmp Bp,15d
                        ja RCL_invalid
                        mov cx,Op2Val
                        call ourGetCF
                        RCL p1_ValMem[Bp],cl
                        call ourSetCF
                        mov p1_ValRegBp,Bp
                        jmp Exit
                        RCL_AddBp_Val_his:
                        mov Bp,ValRegBp
                        cmp Bp,15d
                        ja RCL_invalid
                        mov cx,Op2Val
                        ;;;;;;;;;;;;;;;;;;;;;;;
                            mov al,ValMem[Bp]
                            call LineStuckPwrUp
                            movp2_ValMem[Bp],al
                        call GetCarryFlag
                        RCLp2_ValMem[Bp],cl
                        call SetCarryFlag
                        movp2_ValRegBp,Bp
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
                        mov Si,p1_ValRegSi
                        cmp Si,15d
                        ja RCL_invalid
                        mov cx,p1_ValRegCX
                        call ourGetCF
                        RCL p1_ValMem[Si],cl
                        call ourSetCF
                        mov p1_ValRegSi,Si
                        jmp Exit
                        RCL_AddSi_Reg_his:
                        mov Si,ValRegSi
                        cmp Si,15d
                        ja RCL_invalid
                        mov cx,ValRegCX
                        ;;;;;;;;;;;;;;;;;;;;;;;
                            mov al,ValMem[Si]
                            call LineStuckPwrUp
                            movp2_ValMem[Si],al
                        call GetCarryFlag
                        RCLp2_ValMem[Si],cl
                        call SetCarryFlag
                        movp2_ValRegSi,Si
                        cmp selectedPUPType,2
                        je RCL_AddSi_Reg_our
                        jmp Exit
                    RCL_AddSi_Val:
                        cmp Op2Val,255d
                        ja RCL_invalid
                        cmp selectedPUPType,1
                        jne RCL_AddSi_Val_his
                        RCL_AddSi_Val_our:
                        mov Si,p1_ValRegSi
                        cmp Si,15d
                        ja RCL_invalid
                        mov cx,Op2Val
                        call ourGetCF
                        RCL p1_ValMem[Si],cl
                        call ourSetCF
                        mov p1_ValRegSi,Si
                        jmp Exit
                        RCL_AddSi_Val_his:
                        mov Si,ValRegSi
                        cmp Si,15d
                        ja RCL_invalid
                        mov cx,Op2Val
                        ;;;;;;;;;;;;;;;;;;;;;;;
                            mov al,ValMem[Si]
                            call LineStuckPwrUp
                            movp2_ValMem[Si],al
                        call GetCarryFlag
                        RCLp2_ValMem[Si],cl
                        call SetCarryFlag
                        movp2_ValRegSi,Si
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
                        mov Di,p1_ValRegDi
                        cmp Di,15d
                        ja RCL_invalid
                        mov cx,p1_ValRegCX
                        call ourGetCF
                        RCL p1_ValMem[Di],cl
                        call ourSetCF
                        mov p1_ValRegDi,Di
                        jmp Exit
                        RCL_AddDi_Reg_his:
                        mov Di,ValRegDi
                        cmp Di,15d
                        ja RCL_invalid
                        mov cx,ValRegCX
                        ;;;;;;;;;;;;;;;;;;;;;;;
                            mov al,ValMem[Di]
                            call LineStuckPwrUp
                            movp2_ValMem[Di],al
                        call GetCarryFlag
                        RCLp2_ValMem[Di],cl
                        call SetCarryFlag
                        movp2_ValRegDi,Di
                        cmp selectedPUPType,2
                        je RCL_AddDi_Reg_our
                        jmp Exit
                    RCL_AddDi_Val:
                        cmp Op2Val,255d
                        ja RCL_invalid
                        cmp selectedPUPType,1
                        jne RCL_AddDi_Val_his
                        RCL_AddDi_Val_our:
                        mov Di,p1_ValRegDi
                        cmp Di,15d
                        ja RCL_invalid
                        mov cx,Op2Val
                        call ourGetCF
                        RCL p1_ValMem[Di],cl
                        call ourSetCF
                        mov p1_ValRegDi,Di
                        jmp Exit
                        RCL_AddDi_Val_his:
                        mov Di,ValRegDi
                        cmp Di,15d
                        ja RCL_invalid
                        mov cx,Op2Val
                        ;;;;;;;;;;;;;;;;;;;;;;;
                            mov al,ValMem[Di]
                            call LineStuckPwrUp
                            movp2_ValMem[Di],al
                        call GetCarryFlag
                        RCLp2_ValMem[Di],cl
                        call SetCarryFlag
                        movp2_ValRegDi,Di
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
                    mov cx,p1_ValRegCX
                    call ourGetCF
                    RCL p1_ValMem[si],cl
                    call ourSetCF
                    jmp Exit
                    RCL_Mem_Reg_his:
                    mov cx,ValRegCX
                    ;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[si]
                        call LineStuckPwrUp
                        movp2_ValMem[si],al
                    call GetCarryFlag
                    RCLp2_ValMem[si],cl
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
                    RCL p1_ValMem[si],cl
                    call ourSetCF
                    jmp Exit
                    RCL_Mem_Val_his:
                    mov cx,Op2Val
                    ;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[si]
                        call LineStuckPwrUp
                        movp2_ValMem[si],al
                    call GetCarryFlag
                    RCLp2_ValMem[si],cl
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
                        cmp selectedPUPType,1
                        jne SHL_Ax_Reg_his
                        SHL_Ax_Reg_our:
                        mov ax,p1_ValRegAX
                        mov cx,p1_ValRegCX
                        SHL Ax,cl
                        call ourSetCF
                        mov p1_ValRegAX,ax
                        jmp Exit
                        SHL_Ax_Reg_his:
                        mov ax,ValRegAX
                        mov cx,ValRegCX
                        SHL Ax,cl
                        call SetCarryFlag
                        movp2_ValRegAX,ax
                        cmp selectedPUPType,2
                        je SHL_Ax_Reg_our
                        jmp Exit
                    SHL_Ax_Val:
                        cmp Op2Val,255d
                        ja SHL_invalid
                        cmp selectedPUPType,1
                        jne SHL_Ax_Val_his
                        SHL_Ax_Val_our:
                        mov ax,p1_ValRegAX
                        mov cx,Op2Val
                        SHL ax,cl
                        call ourSetCF
                        mov p1_ValRegAX,ax
                        jmp Exit
                        SHL_Ax_Val_his:
                        mov ax,ValRegAX
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        SHL ax,cl
                        call SetCarryFlag
                        movp2_ValRegAX,ax
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
                        mov ax,p1_ValRegAX
                        mov cx,p1_ValRegCX
                        SHL Al,cl
                        call ourSetCF
                        mov p1_ValRegAX,ax
                        jmp Exit
                        SHL_Al_Reg_his:
                        mov ax,ValRegAX
                        mov cx,ValRegCX
                        SHL Al,cl
                        call SetCarryFlag
                        movp2_ValRegAX,ax
                        cmp selectedPUPType,2
                        je SHL_Al_Reg_our
                        jmp Exit
                    SHL_Al_Val:
                        cmp Op2Val,255d
                        ja SHL_invalid
                        cmp selectedPUPType,1
                        jne SHL_Al_Val_his
                        SHL_Al_Val_our:
                        mov ax,p1_ValRegAX
                        mov cx,Op2Val
                        SHL al,cl
                        call ourSetCF
                        mov p1_ValRegAX,ax
                        jmp Exit
                        SHL_Al_Val_his:
                        mov ax,ValRegAX
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        SHL al,cl
                        call SetCarryFlag
                        movp2_ValRegAX,ax
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
                        mov ax,p1_ValRegAX
                        mov cx,p1_ValRegCX
                        SHL Ah,cl
                        call ourSetCF
                        mov p1_ValRegAX,ax
                        jmp Exit
                        SHL_Ah_Reg_his:
                        mov ax,ValRegAX
                        mov cx,ValRegCX
                        SHL Ah,cl
                        call SetCarryFlag
                        movp2_ValRegAX,ax
                        cmp selectedPUPType,2
                        je SHL_Ah_Reg_our
                        jmp Exit
                    SHL_Ah_Val:
                        cmp Op2Val,255d
                        ja SHL_invalid
                        cmp selectedPUPType,1
                        jne SHL_Ah_Val_his
                        SHL_Ah_Val_our:
                        mov ax,p1_ValRegAX
                        mov cx,Op2Val
                        SHL ah,cl
                        call ourSetCF
                        mov p1_ValRegAX,ax
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
                        movp2_ValRegAX,ax
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
                        mov Bx,p1_ValRegBx
                        mov cx,p1_ValRegCX
                        SHL Bx,cl
                        call ourSetCF
                        mov p1_ValRegBx,Bx
                        jmp Exit
                        SHL_Bx_Reg_his:
                        mov Bx,ValRegBx
                        mov cx,ValRegCX
                        SHL Bx,cl
                        call SetCarryFlag
                        movp2_ValRegBx,Bx
                        cmp selectedPUPType,2
                        je SHL_Bx_Reg_our
                        jmp Exit
                    SHL_Bx_Val:
                        cmp Op2Val,255d
                        ja SHL_invalid
                        cmp selectedPUPType,1
                        jne SHL_Bx_Val_his
                        SHL_Bx_Val_our:
                        mov Bx,p1_ValRegBx
                        mov cx,Op2Val
                        SHL Bx,cl
                        call ourSetCF
                        mov p1_ValRegBx,Bx
                        jmp Exit
                        SHL_Bx_Val_his:
                        mov Bx,ValRegBx
                        mov cx,Op2Val
                        mov ax,bx
                        call LineStuckPwrUp
                        mov bx,ax
                        SHL Bx,cl
                        call SetCarryFlag
                        movp2_ValRegBx,Bx
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
                        mov Bx,p1_ValRegBX
                        mov cx,p1_ValRegCX
                        SHL Bl,cl
                        call ourSetCF
                        mov p1_ValRegBX,Bx
                        jmp Exit
                        SHL_Bl_Reg_his:
                        mov Bx,ValRegBX
                        mov cx,ValRegCX
                        SHL Bl,cl
                        call SetCarryFlag
                        movp2_ValRegBX,Bx
                        cmp selectedPUPType,2
                        je SHL_Bl_Reg_our
                        jmp Exit
                    SHL_Bl_Val:
                        cmp Op2Val,255d
                        ja SHL_invalid
                        cmp selectedPUPType,1
                        SHL_Bl_Val_our:
                        mov Bx,p1_ValRegBX
                        mov cx,Op2Val
                        SHL Bl,cl
                        call ourSetCF
                        mov p1_ValRegBX,Bx
                        jmp Exit
                        SHL_Bl_Val_his:
                        mov Bx,ValRegBX
                        mov cx,Op2Val
                        mov al,Bl
                        call LineStuckPwrUp
                        mov Bl,al
                        SHL Bl,cl
                        call SetCarryFlag
                        movp2_ValRegBX,Bx
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
                        mov Bx,p1_ValRegBX
                        mov cx,p1_ValRegCX
                        SHL Bh,cl
                        call ourSetCF
                        mov p1_ValRegBX,Bx
                        jmp Exit
                        SHL_Bh_Reg_his:
                        mov Bx,ValRegBX
                        mov cx,ValRegCX
                        SHL Bh,cl
                        call SetCarryFlag
                        movp2_ValRegBX,Bx
                        cmp selectedPUPType,2
                        je SHL_Bh_Reg_our
                        jmp Exit
                    SHL_Bh_Val:
                        cmp Op2Val,255d
                        ja SHL_invalid
                        cmp selectedPUPType,1
                        SHL_Bh_Val_our:
                        mov Bx,p1_ValRegBX
                        mov cx,Op2Val
                        SHL Bh,cl
                        call ourSetCF
                        mov p1_ValRegBX,Bx
                        jmp Exit
                        SHL_Bh_Val_his:
                        mov Bx,ValRegBX
                        mov cx,Op2Val
                        mov al,Bh
                        call LineStuckPwrUp
                        mov Bh,al
                        SHL Bh,cl
                        call SetCarryFlag
                        movp2_ValRegBX,Bx
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
                        mov Cx,p1_ValRegCx
                        mov ax,cx
                        mov cx,ax
                        SHL Cx,cl
                        call ourSetCF
                        mov p1_ValRegCx,Cx
                        jmp Exit
                        SHL_Cx_Reg_his:
                        cmp selectedOp2Reg,7
                        jne SHL_invalid
                        mov Cx,ValRegCx
                        mov ax,cx
                        mov cx,ax
                        SHL Cx,cl
                        call SetCarryFlag
                        movp2_ValRegCx,Cx
                        cmp selectedPUPType,2
                        je SHL_Cx_Reg_our
                        jmp Exit
                    SHL_Cx_Val:
                        cmp Op2Val,255d
                        ja SHL_invalid
                        cmp selectedPUPType,1
                        jne SHL_Cx_Val_his
                        SHL_Cx_Val_our:
                        mov bx,p1_ValRegCx
                        mov cx,Op2Val
                        SHL bx,cl
                        call ourSetCF
                        mov p1_ValRegCx,bx
                        jmp Exit
                        SHL_Cx_Val_his:
                        mov bx,ValRegCx
                        mov cx,Op2Val
                        mov ax,bx
                        call LineStuckPwrUp
                        mov bx,ax
                        SHL bx,cl
                        call SetCarryFlag
                        movp2_ValRegCx,bx
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
                        mov ax,p1_ValRegCX
                        mov cx,p1_ValRegCX
                        SHL Al,cl
                        call ourSetCF
                        mov p1_ValRegCX,ax
                        jmp Exit
                        SHL_Cl_Reg_his:
                        mov ax,ValRegCX
                        mov cx,ValRegCX
                        SHL Al,cl
                        call SetCarryFlag
                        movp2_ValRegCX,ax
                        cmp selectedPUPType,2
                        je SHL_Cl_Reg_our
                        jmp Exit
                    SHL_Cl_Val:
                        cmp Op2Val,255d
                        ja SHL_invalid
                        cmp selectedPUPType,1
                        jne SHL_Cl_Val_his
                        SHL_Cl_Val_our:
                        mov ax,p1_ValRegCX
                        mov cx,Op2Val
                        SHL al,cl
                        call ourSetCF
                        mov p1_ValRegCX,ax
                        jmp Exit
                        SHL_Cl_Val_his:
                        mov ax,ValRegCX
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        SHL al,cl
                        call SetCarryFlag
                        movp2_ValRegCX,ax
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
                        mov cx,p1_ValRegCX
                        SHL Ch,cl
                        call ourSetCF
                        mov p1_ValRegCX,Cx
                        jmp Exit
                        SHL_Ch_Reg_his:
                        mov cx,ValRegCX
                        SHL Ch,cl
                        call SetCarryFlag
                        movp2_ValRegCX,Cx
                        cmp selectedPUPType,2
                        je SHL_Ch_Reg_our
                        jmp Exit
                    SHL_Ch_Val:
                        cmp Op2Val,255d
                        ja SHL_invalid
                        cmp selectedPUPType,1
                        jne SHL_Ch_Val_his
                        SHL_Ch_Val_our:
                        mov ax,p1_ValRegCX
                        mov cx,Op2Val
                        SHL ah,cl
                        call ourSetCF
                        mov p1_ValRegCX,ax
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
                        movp2_ValRegCX,ax
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
                        mov Dx,p1_ValRegDx
                        mov cx,p1_ValRegCX
                        SHL Dx,cl
                        call ourSetCF
                        mov p1_ValRegDx,Dx
                        jmp Exit
                        SHL_Dx_Reg_his:
                        mov Dx,ValRegDx
                        mov cx,ValRegCX
                        SHL Dx,cl
                        call SetCarryFlag
                        movp2_ValRegDx,Dx
                        cmp selectedPUPType,2
                        je SHL_Dx_Reg_our
                        jmp Exit
                    SHL_Dx_Val:
                        cmp Op2Val,255d
                        ja SHL_invalid
                        cmp selectedPUPType,1
                        jne SHL_Dx_Val_his
                        SHL_Dx_Val_our:
                        mov ax,p1_ValRegDx
                        mov cx,Op2Val
                        SHL ax,cl
                        call ourSetCF
                        mov p1_ValRegDx,ax
                        jmp Exit
                        SHL_Dx_Val_his:
                        mov ax,ValRegDx
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        SHL ax,cl
                        call SetCarryFlag
                        movp2_ValRegDx,ax
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
                        mov Dx,p1_ValRegDX
                        mov cx,p1_ValRegCX
                        SHL Dl,cl
                        call ourSetCF
                        mov p1_ValRegDX,Dx
                        jmp Exit
                        SHL_Dl_Reg_his:
                        mov Dx,ValRegDX
                        mov cx,ValRegCX
                        SHL Dl,cl
                        call SetCarryFlag
                        movp2_ValRegDX,Dx
                        cmp selectedPUPType,2
                        je SHL_Dl_Reg_our
                        jmp Exit
                    SHL_Dl_Val:
                        cmp Op2Val,255d
                        ja SHL_invalid
                        cmp selectedPUPType,1
                        jne SHL_Dl_Val_his
                        SHL_Dl_Val_our:
                        mov Dx,p1_ValRegDX
                        mov cx,Op2Val
                        SHL Dl,cl
                        call ourSetCF
                        mov p1_ValRegDX,Dx
                        jmp Exit
                        SHL_Dl_Val_his:
                        mov ax,ValRegDX
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        SHL al,cl
                        call SetCarryFlag
                        movp2_ValRegDX,ax
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
                        mov Dx,p1_ValRegDX
                        mov cx,p1_ValRegCX
                        SHL dh,cl
                        call ourSetCF
                        mov p1_ValRegDX,Dx
                        jmp Exit
                        SHL_Dh_Reg_his:
                        mov Dx,ValRegDX
                        mov cx,ValRegCX
                        SHL dh,cl
                        call SetCarryFlag
                        movp2_ValRegDX,Dx
                        cmp selectedPUPType,2
                        je SHL_Dh_Reg_our
                        jmp Exit
                    SHL_Dh_Val:
                        cmp Op2Val,255d
                        ja SHL_invalid
                        cmp selectedPUPType,1
                        jne SHL_Dh_Val_his
                        SHL_Dh_Val_our:
                        mov Dx,p1_ValRegDX
                        mov cx,Op2Val
                        SHL dh,cl
                        call ourSetCF
                        mov p1_ValRegDX,Dx
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
                        movp2_ValRegDX,ax
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
                        mov Bp,p1_ValRegBp
                        mov cx,p1_ValRegCX
                        SHL Bp,cl
                        call ourSetCF
                        mov p1_ValRegBp,Bp
                        jmp Exit
                        SHL_Bp_Reg_his:
                        mov Bp,ValRegBp
                        mov cx,ValRegCX
                        SHL Bp,cl
                        call SetCarryFlag
                        movp2_ValRegBp,Bp
                        cmp selectedPUPType,2
                        je SHL_Bp_Reg_our
                        jmp Exit
                    SHL_Bp_Val:
                        cmp Op2Val,255d
                        ja SHL_invalid
                        cmp selectedPUPType,1
                        jne SHL_Bp_Val_his
                        SHL_Bp_Val_our:
                        mov Bp,p1_ValRegBp
                        mov cx,Op2Val
                        SHL Bp,cl
                        call ourSetCF
                        mov p1_ValRegBp,Bp
                        jmp Exit
                        SHL_Bp_Val_his:
                        mov ax,ValRegBp
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        SHL ax,cl
                        call SetCarryFlag
                        movp2_ValRegBp,ax
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
                        mov Sp,p1_ValRegSp
                        mov cx,p1_ValRegCX
                        SHL Sp,cl
                        call ourSetCF
                        mov p1_ValRegSp,Sp
                        jmp Exit
                        SHL_Sp_Reg_his:
                        mov Sp,ValRegSp
                        mov cx,ValRegCX
                        SHL Sp,cl
                        call SetCarryFlag
                        movp2_ValRegSp,Sp
                        cmp selectedPUPType,2
                        je SHL_Sp_Reg_our
                        jmp Exit
                    SHL_Sp_Val:
                        cmp Op2Val,255d
                        ja SHL_invalid
                        cmp selectedPUPType,1
                        jne SHL_Sp_Val_his
                        SHL_Sp_Val_our:
                        mov Sp,p1_ValRegSp
                        mov cx,Op2Val
                        SHL Sp,cl
                        call ourSetCF
                        mov p1_ValRegSp,Sp
                        jmp Exit
                        SHL_Sp_Val_his:
                        mov ax,ValRegSp
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        SHL ax,cl
                        call SetCarryFlag
                        movp2_ValRegSp,ax
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
                        mov Si,p1_ValRegSi
                        mov cx,p1_ValRegCX
                        SHL Si,cl
                        call ourSetCF
                        mov p1_ValRegSi,Si
                        jmp Exit
                        SHL_Si_Reg_his:
                        mov Si,ValRegSi
                        mov cx,ValRegCX
                        SHL Si,cl
                        call SetCarryFlag
                        movp2_ValRegSi,Si
                        cmp selectedPUPType,2
                        je SHL_Si_Reg_our
                        jmp Exit
                    SHL_Si_Val:
                        cmp Op2Val,255d
                        ja SHL_invalid
                        cmp selectedPUPType,1
                        jne SHL_Si_Val_his
                        SHL_Si_Val_our:
                        mov Si,p1_ValRegSi
                        mov cx,Op2Val
                        SHL Si,cl
                        call ourSetCF
                        mov p1_ValRegSi,Si
                        jmp Exit
                        SHL_Si_Val_his:
                        mov ax,ValRegSi
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        SHL ax,cl
                        call SetCarryFlag
                        movp2_ValRegSi,ax
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
                        mov Di,p1_ValRegDi
                        mov cx,p1_ValRegCX
                        SHL Di,cl
                        call ourSetCF
                        mov p1_ValRegDi,Di
                        jmp Exit
                        SHL_Di_Reg_his:
                        mov Di,ValRegDi
                        mov cx,ValRegCX
                        SHL Di,cl
                        call SetCarryFlag
                        movp2_ValRegDi,Di
                        cmp selectedPUPType,2
                        je SHL_Di_Reg_our
                        jmp Exit
                    SHL_Di_Val:
                        cmp Op2Val,255d
                        ja SHL_invalid
                        cmp selectedPUPType,1
                        jne SHL_Di_Val_his
                        SHL_Di_Val_our:
                        mov Di,p1_ValRegDi
                        mov cx,Op2Val
                        SHL Di,cl
                        call ourSetCF
                        mov p1_ValRegDi,Di
                        jmp Exit
                        SHL_Di_Val_his:
                        mov ax,ValRegDi
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        SHL ax,cl
                        call SetCarryFlag
                        movp2_ValRegDi,ax
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
                        mov Bx,p1_ValRegBX
                        cmp Bx,15d
                        ja SHL_invalid
                        mov cx,p1_ValRegCX
                        SHL p1_ValMem[Bx],cl
                        call ourSetCF
                        mov p1_ValRegBX,Bx
                        jmp Exit
                        SHL_AddBx_Reg_his:
                        mov Bx,ValRegBX
                        cmp Bx,15d
                        ja SHL_invalid
                        mov cx,ValRegCX
                        ;;;;;;;;;;;;;;;;;;;;;;;
                            mov al,ValMem[Bx]
                            call LineStuckPwrUp
                            movp2_ValMem[Bx],al
                        SHLp2_ValMem[Bx],cl
                        call SetCarryFlag
                        movp2_ValRegBX,Bx
                        cmp selectedPUPType,2
                        je SHL_AddBx_Reg_our
                        jmp Exit
                    SHL_AddBx_Val:
                        cmp Op2Val,255d
                        ja SHL_invalid
                        cmp selectedPUPType,1
                        jne SHL_AddBx_Val_his
                        SHL_AddBx_Val_our:
                        mov Bx,p1_ValRegBX
                        cmp Bx,15d
                        ja SHL_invalid
                        mov cx,Op2Val
                        SHL p1_ValMem[Bx],cl
                        call ourSetCF
                        mov p1_ValRegBX,Bx
                        jmp Exit
                        SHL_AddBx_Val_his:
                        mov Bx,ValRegBX
                        cmp Bx,15d
                        ja SHL_invalid
                        mov cx,Op2Val
                        ;;;;;;;;;;;;;;;;;;;;;;;
                            mov al,ValMem[Bx]
                            call LineStuckPwrUp
                            movp2_ValMem[Bx],al
                        SHLp2_ValMem[Bx],cl
                        call SetCarryFlag
                        movp2_ValRegBX,Bx
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
                        mov Bp,p1_ValRegBp
                        cmp Bp,15d
                        ja SHL_invalid
                        mov cx,p1_ValRegCX
                        SHL p1_ValMem[Bp],cl
                        call ourSetCF
                        mov p1_ValRegBp,Bp
                        jmp Exit
                        SHL_AddBp_Reg_his:
                        mov Bp,ValRegBp
                        cmp Bp,15d
                        ja SHL_invalid
                        mov cx,ValRegCX
                        ;;;;;;;;;;;;;;;;;;;;;;;
                            mov al,ValMem[Bp]
                            call LineStuckPwrUp
                            movp2_ValMem[Bp],al
                        SHLp2_ValMem[Bp],cl
                        call SetCarryFlag
                        movp2_ValRegBp,Bp
                        cmp selectedPUPType,2
                        je SHL_AddBp_Reg_our
                        jmp Exit
                    SHL_AddBp_Val:
                        cmp Op2Val,255d
                        ja SHL_invalid
                        cmp selectedPUPType,1
                        jne SHL_AddBp_Val_his
                        SHL_AddBp_Val_our:
                        mov Bp,p1_ValRegBp
                        cmp Bp,15d
                        ja SHL_invalid
                        mov cx,Op2Val
                        SHL p1_ValMem[Bp],cl
                        call ourSetCF
                        mov p1_ValRegBp,Bp
                        jmp Exit
                        SHL_AddBp_Val_his:
                        mov Bp,ValRegBp
                        cmp Bp,15d
                        ja SHL_invalid
                        mov cx,Op2Val
                        ;;;;;;;;;;;;;;;;;;;;;;;
                            mov al,ValMem[Bp]
                            call LineStuckPwrUp
                            movp2_ValMem[Bp],al
                        SHLp2_ValMem[Bp],cl
                        call SetCarryFlag
                        movp2_ValRegBp,Bp
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
                        mov Si,p1_ValRegSi
                        cmp Si,15d
                        ja SHL_invalid
                        mov cx,p1_ValRegCX
                        SHL p1_ValMem[Si],cl
                        call ourSetCF
                        mov p1_ValRegSi,Si
                        jmp Exit
                        SHL_AddSi_Reg_his:
                        mov Si,ValRegSi
                        cmp Si,15d
                        ja SHL_invalid
                        mov cx,ValRegCX
                        ;;;;;;;;;;;;;;;;;;;;;;;
                            mov al,ValMem[Si]
                            call LineStuckPwrUp
                            movp2_ValMem[Si],al
                        SHLp2_ValMem[Si],cl
                        call SetCarryFlag
                        movp2_ValRegSi,Si
                        cmp selectedPUPType,2
                        je SHL_AddSi_Reg_our
                        jmp Exit
                    SHL_AddSi_Val:
                        cmp Op2Val,255d
                        ja SHL_invalid
                        cmp selectedPUPType,1
                        jne SHL_AddSi_Val_his
                        SHL_AddSi_Val_our:
                        mov Si,p1_ValRegSi
                        cmp Si,15d
                        ja SHL_invalid
                        mov cx,Op2Val
                        SHL p1_ValMem[Si],cl
                        call ourSetCF
                        mov p1_ValRegSi,Si
                        jmp Exit
                        SHL_AddSi_Val_his:
                        mov Si,ValRegSi
                        cmp Si,15d
                        ja SHL_invalid
                        mov cx,Op2Val
                        ;;;;;;;;;;;;;;;;;;;;;;;
                            mov al,ValMem[Si]
                            call LineStuckPwrUp
                            movp2_ValMem[Si],al
                        SHLp2_ValMem[Si],cl
                        call SetCarryFlag
                        movp2_ValRegSi,Si
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
                        mov Di,p1_ValRegDi
                        cmp Di,15d
                        ja SHL_invalid
                        mov cx,p1_ValRegCX
                        SHL p1_ValMem[Di],cl
                        call ourSetCF
                        mov p1_ValRegDi,Di
                        jmp Exit
                        SHL_AddDi_Reg_his:
                        mov Di,ValRegDi
                        cmp Di,15d
                        ja SHL_invalid
                        mov cx,ValRegCX
                        ;;;;;;;;;;;;;;;;;;;;;;;
                            mov al,ValMem[Di]
                            call LineStuckPwrUp
                            movp2_ValMem[Di],al
                        SHLp2_ValMem[Di],cl
                        call SetCarryFlag
                        movp2_ValRegDi,Di
                        cmp selectedPUPType,2
                        je SHL_AddDi_Reg_our
                        jmp Exit
                    SHL_AddDi_Val:
                        cmp Op2Val,255d
                        ja SHL_invalid
                        cmp selectedPUPType,1
                        jne SHL_AddDi_Val_his
                        SHL_AddDi_Val_our:
                        mov Di,p1_ValRegDi
                        cmp Di,15d
                        ja SHL_invalid
                        mov cx,Op2Val
                        SHL p1_ValMem[Di],cl
                        call ourSetCF
                        mov p1_ValRegDi,Di
                        jmp Exit
                        SHL_AddDi_Val_his:
                        mov Di,ValRegDi
                        cmp Di,15d
                        ja SHL_invalid
                        mov cx,Op2Val
                        ;;;;;;;;;;;;;;;;;;;;;;;
                            mov al,ValMem[Di]
                            call LineStuckPwrUp
                            movp2_ValMem[Di],al
                        SHLp2_ValMem[Di],cl
                        call SetCarryFlag
                        movp2_ValRegDi,Di
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
                    mov cx,p1_ValRegCX
                    SHL p1_ValMem[si],cl
                    call ourSetCF
                    jmp Exit
                    SHL_Mem_Reg_his:
                    mov cx,ValRegCX
                    ;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[si]
                        call LineStuckPwrUp
                        movp2_ValMem[si],al
                    SHLp2_ValMem[si],cl
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
                    SHL p1_ValMem[si],cl
                    call ourSetCF
                    jmp Exit
                    SHL_Mem_Val_his:
                    mov cx,Op2Val
                    ;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[si]
                        call LineStuckPwrUp
                        movp2_ValMem[si],al
                    SHLp2_ValMem[si],cl
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
                        cmp selectedPUPType,1
                        jne SHR_Ax_Reg_his
                        SHR_Ax_Reg_our:
                        mov ax,p1_ValRegAX
                        mov cx,p1_ValRegCX
                        SHR Ax,cl
                        call ourSetCF
                        mov p1_ValRegAX,ax
                        jmp Exit
                        SHR_Ax_Reg_his:
                        mov ax,ValRegAX
                        mov cx,ValRegCX
                        SHR Ax,cl
                        call SetCarryFlag
                        movp2_ValRegAX,ax
                        cmp selectedPUPType,2
                        je SHR_Ax_Reg_our
                        jmp Exit
                    SHR_Ax_Val:
                        cmp Op2Val,255d
                        ja SHR_invalid
                        cmp selectedPUPType,1
                        jne SHR_Ax_Val_his
                        SHR_Ax_Val_our:
                        mov ax,p1_ValRegAX
                        mov cx,Op2Val
                        SHR ax,cl
                        call ourSetCF
                        mov p1_ValRegAX,ax
                        jmp Exit
                        SHR_Ax_Val_his:
                        mov ax,ValRegAX
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        SHR ax,cl
                        call SetCarryFlag
                        movp2_ValRegAX,ax
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
                        mov ax,p1_ValRegAX
                        mov cx,p1_ValRegCX
                        SHR Al,cl
                        call ourSetCF
                        mov p1_ValRegAX,ax
                        jmp Exit
                        SHR_Al_Reg_his:
                        mov ax,ValRegAX
                        mov cx,ValRegCX
                        SHR Al,cl
                        call SetCarryFlag
                        movp2_ValRegAX,ax
                        cmp selectedPUPType,2
                        je SHR_Al_Reg_our
                        jmp Exit
                    SHR_Al_Val:
                        cmp Op2Val,255d
                        ja SHR_invalid
                        cmp selectedPUPType,1
                        jne SHR_Al_Val_his
                        SHR_Al_Val_our:
                        mov ax,p1_ValRegAX
                        mov cx,Op2Val
                        SHR al,cl
                        call ourSetCF
                        mov p1_ValRegAX,ax
                        jmp Exit
                        SHR_Al_Val_his:
                        mov ax,ValRegAX
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        SHR al,cl
                        call SetCarryFlag
                        movp2_ValRegAX,ax
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
                        mov ax,p1_ValRegAX
                        mov cx,p1_ValRegCX
                        SHR Ah,cl
                        call ourSetCF
                        mov p1_ValRegAX,ax
                        jmp Exit
                        SHR_Ah_Reg_his:
                        mov ax,ValRegAX
                        mov cx,ValRegCX
                        SHR Ah,cl
                        call SetCarryFlag
                        movp2_ValRegAX,ax
                        cmp selectedPUPType,2
                        je SHR_Ah_Reg_our
                        jmp Exit
                    SHR_Ah_Val:
                        cmp Op2Val,255d
                        ja SHR_invalid
                        cmp selectedPUPType,1
                        jne SHR_Ah_Val_his
                        SHR_Ah_Val_our:
                        mov ax,p1_ValRegAX
                        mov cx,Op2Val
                        SHR ah,cl
                        call ourSetCF
                        mov p1_ValRegAX,ax
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
                        movp2_ValRegAX,ax
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
                        mov Bx,p1_ValRegBx
                        mov cx,p1_ValRegCX
                        SHR Bx,cl
                        call ourSetCF
                        mov p1_ValRegBx,Bx
                        jmp Exit
                        SHR_Bx_Reg_his:
                        mov Bx,ValRegBx
                        mov cx,ValRegCX
                        SHR Bx,cl
                        call SetCarryFlag
                        movp2_ValRegBx,Bx
                        cmp selectedPUPType,2
                        je SHR_Bx_Reg_our
                        jmp Exit
                    SHR_Bx_Val:
                        cmp Op2Val,255d
                        ja SHR_invalid
                        cmp selectedPUPType,1
                        jne SHR_Bx_Val_his
                        SHR_Bx_Val_our:
                        mov Bx,p1_ValRegBx
                        mov cx,Op2Val
                        SHR Bx,cl
                        call ourSetCF
                        mov p1_ValRegBx,Bx
                        jmp Exit
                        SHR_Bx_Val_his:
                        mov Bx,ValRegBx
                        mov cx,Op2Val
                        mov ax,bx
                        call LineStuckPwrUp
                        mov bx,ax
                        SHR Bx,cl
                        call SetCarryFlag
                        movp2_ValRegBx,Bx
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
                        mov Bx,p1_ValRegBX
                        mov cx,p1_ValRegCX
                        SHR Bl,cl
                        call ourSetCF
                        mov p1_ValRegBX,Bx
                        jmp Exit
                        SHR_Bl_Reg_his:
                        mov Bx,ValRegBX
                        mov cx,ValRegCX
                        SHR Bl,cl
                        call SetCarryFlag
                        movp2_ValRegBX,Bx
                        cmp selectedPUPType,2
                        je SHR_Bl_Reg_our
                        jmp Exit
                    SHR_Bl_Val:
                        cmp Op2Val,255d
                        ja SHR_invalid
                        cmp selectedPUPType,1
                        SHR_Bl_Val_our:
                        mov Bx,p1_ValRegBX
                        mov cx,Op2Val
                        SHR Bl,cl
                        call ourSetCF
                        mov p1_ValRegBX,Bx
                        jmp Exit
                        SHR_Bl_Val_his:
                        mov Bx,ValRegBX
                        mov cx,Op2Val
                        mov al,Bl
                        call LineStuckPwrUp
                        mov Bl,al
                        SHR Bl,cl
                        call SetCarryFlag
                        movp2_ValRegBX,Bx
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
                        mov Bx,p1_ValRegBX
                        mov cx,p1_ValRegCX
                        SHR Bh,cl
                        call ourSetCF
                        mov p1_ValRegBX,Bx
                        jmp Exit
                        SHR_Bh_Reg_his:
                        mov Bx,ValRegBX
                        mov cx,ValRegCX
                        SHR Bh,cl
                        call SetCarryFlag
                        movp2_ValRegBX,Bx
                        cmp selectedPUPType,2
                        je SHR_Bh_Reg_our
                        jmp Exit
                    SHR_Bh_Val:
                        cmp Op2Val,255d
                        ja SHR_invalid
                        cmp selectedPUPType,1
                        SHR_Bh_Val_our:
                        mov Bx,p1_ValRegBX
                        mov cx,Op2Val
                        SHR Bh,cl
                        call ourSetCF
                        mov p1_ValRegBX,Bx
                        jmp Exit
                        SHR_Bh_Val_his:
                        mov Bx,ValRegBX
                        mov cx,Op2Val
                        mov al,Bh
                        call LineStuckPwrUp
                        mov Bh,al
                        SHR Bh,cl
                        call SetCarryFlag
                        movp2_ValRegBX,Bx
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
                        mov Cx,p1_ValRegCx
                        mov ax,cx
                        mov cx,ax
                        SHR Cx,cl
                        call ourSetCF
                        mov p1_ValRegCx,Cx
                        jmp Exit
                        SHR_Cx_Reg_his:
                        cmp selectedOp2Reg,7
                        jne SHR_invalid
                        mov Cx,ValRegCx
                        mov ax,cx
                        mov cx,ax
                        SHR Cx,cl
                        call SetCarryFlag
                        movp2_ValRegCx,Cx
                        cmp selectedPUPType,2
                        je SHR_Cx_Reg_our
                        jmp Exit
                    SHR_Cx_Val:
                        cmp Op2Val,255d
                        ja SHR_invalid
                        cmp selectedPUPType,1
                        jne SHR_Cx_Val_his
                        SHR_Cx_Val_our:
                        mov bx,p1_ValRegCx
                        mov cx,Op2Val
                        SHR bx,cl
                        call ourSetCF
                        mov p1_ValRegCx,bx
                        jmp Exit
                        SHR_Cx_Val_his:
                        mov bx,ValRegCx
                        mov cx,Op2Val
                        mov ax,bx
                        call LineStuckPwrUp
                        mov bx,ax
                        SHR bx,cl
                        call SetCarryFlag
                        movp2_ValRegCx,bx
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
                        mov ax,p1_ValRegCX
                        mov cx,p1_ValRegCX
                        SHR Al,cl
                        call ourSetCF
                        mov p1_ValRegCX,ax
                        jmp Exit
                        SHR_Cl_Reg_his:
                        mov ax,ValRegCX
                        mov cx,ValRegCX
                        SHR Al,cl
                        call SetCarryFlag
                        movp2_ValRegCX,ax
                        cmp selectedPUPType,2
                        je SHR_Cl_Reg_our
                        jmp Exit
                    SHR_Cl_Val:
                        cmp Op2Val,255d
                        ja SHR_invalid
                        cmp selectedPUPType,1
                        jne SHR_Cl_Val_his
                        SHR_Cl_Val_our:
                        mov ax,p1_ValRegCX
                        mov cx,Op2Val
                        SHR al,cl
                        call ourSetCF
                        mov p1_ValRegCX,ax
                        jmp Exit
                        SHR_Cl_Val_his:
                        mov ax,ValRegCX
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        SHR al,cl
                        call SetCarryFlag
                        movp2_ValRegCX,ax
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
                        mov cx,p1_ValRegCX
                        SHR Ch,cl
                        call ourSetCF
                        mov p1_ValRegCX,Cx
                        jmp Exit
                        SHR_Ch_Reg_his:
                        mov cx,ValRegCX
                        SHR Ch,cl
                        call SetCarryFlag
                        movp2_ValRegCX,Cx
                        cmp selectedPUPType,2
                        je SHR_Ch_Reg_our
                        jmp Exit
                    SHR_Ch_Val:
                        cmp Op2Val,255d
                        ja SHR_invalid
                        cmp selectedPUPType,1
                        jne SHR_Ch_Val_his
                        SHR_Ch_Val_our:
                        mov ax,p1_ValRegCX
                        mov cx,Op2Val
                        SHR ah,cl
                        call ourSetCF
                        mov p1_ValRegCX,ax
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
                        movp2_ValRegCX,ax
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
                        mov Dx,p1_ValRegDx
                        mov cx,p1_ValRegCX
                        SHR Dx,cl
                        call ourSetCF
                        mov p1_ValRegDx,Dx
                        jmp Exit
                        SHR_Dx_Reg_his:
                        mov Dx,ValRegDx
                        mov cx,ValRegCX
                        SHR Dx,cl
                        call SetCarryFlag
                        movp2_ValRegDx,Dx
                        cmp selectedPUPType,2
                        je SHR_Dx_Reg_our
                        jmp Exit
                    SHR_Dx_Val:
                        cmp Op2Val,255d
                        ja SHR_invalid
                        cmp selectedPUPType,1
                        jne SHR_Dx_Val_his
                        SHR_Dx_Val_our:
                        mov ax,p1_ValRegDx
                        mov cx,Op2Val
                        SHR ax,cl
                        call ourSetCF
                        mov p1_ValRegDx,ax
                        jmp Exit
                        SHR_Dx_Val_his:
                        mov ax,ValRegDx
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        SHR ax,cl
                        call SetCarryFlag
                        movp2_ValRegDx,ax
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
                        mov Dx,p1_ValRegDX
                        mov cx,p1_ValRegCX
                        SHR Dl,cl
                        call ourSetCF
                        mov p1_ValRegDX,Dx
                        jmp Exit
                        SHR_Dl_Reg_his:
                        mov Dx,ValRegDX
                        mov cx,ValRegCX
                        SHR Dl,cl
                        call SetCarryFlag
                        movp2_ValRegDX,Dx
                        cmp selectedPUPType,2
                        je SHR_Dl_Reg_our
                        jmp Exit
                    SHR_Dl_Val:
                        cmp Op2Val,255d
                        ja SHR_invalid
                        cmp selectedPUPType,1
                        jne SHR_Dl_Val_his
                        SHR_Dl_Val_our:
                        mov Dx,p1_ValRegDX
                        mov cx,Op2Val
                        SHR Dl,cl
                        call ourSetCF
                        mov p1_ValRegDX,Dx
                        jmp Exit
                        SHR_Dl_Val_his:
                        mov ax,ValRegDX
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        SHR al,cl
                        call SetCarryFlag
                        movp2_ValRegDX,ax
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
                        mov Dx,p1_ValRegDX
                        mov cx,p1_ValRegCX
                        SHR dh,cl
                        call ourSetCF
                        mov p1_ValRegDX,Dx
                        jmp Exit
                        SHR_Dh_Reg_his:
                        mov Dx,ValRegDX
                        mov cx,ValRegCX
                        SHR dh,cl
                        call SetCarryFlag
                        movp2_ValRegDX,Dx
                        cmp selectedPUPType,2
                        je SHR_Dh_Reg_our
                        jmp Exit
                    SHR_Dh_Val:
                        cmp Op2Val,255d
                        ja SHR_invalid
                        cmp selectedPUPType,1
                        jne SHR_Dh_Val_his
                        SHR_Dh_Val_our:
                        mov Dx,p1_ValRegDX
                        mov cx,Op2Val
                        SHR dh,cl
                        call ourSetCF
                        mov p1_ValRegDX,Dx
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
                        movp2_ValRegDX,ax
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
                        mov Bp,p1_ValRegBp
                        mov cx,p1_ValRegCX
                        SHR Bp,cl
                        call ourSetCF
                        mov p1_ValRegBp,Bp
                        jmp Exit
                        SHR_Bp_Reg_his:
                        mov Bp,ValRegBp
                        mov cx,ValRegCX
                        SHR Bp,cl
                        call SetCarryFlag
                        movp2_ValRegBp,Bp
                        cmp selectedPUPType,2
                        je SHR_Bp_Reg_our
                        jmp Exit
                    SHR_Bp_Val:
                        cmp Op2Val,255d
                        ja SHR_invalid
                        cmp selectedPUPType,1
                        jne SHR_Bp_Val_his
                        SHR_Bp_Val_our:
                        mov Bp,p1_ValRegBp
                        mov cx,Op2Val
                        SHR Bp,cl
                        call ourSetCF
                        mov p1_ValRegBp,Bp
                        jmp Exit
                        SHR_Bp_Val_his:
                        mov ax,ValRegBp
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        SHR ax,cl
                        call SetCarryFlag
                        movp2_ValRegBp,ax
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
                        mov Sp,p1_ValRegSp
                        mov cx,p1_ValRegCX
                        SHR Sp,cl
                        call ourSetCF
                        mov p1_ValRegSp,Sp
                        jmp Exit
                        SHR_Sp_Reg_his:
                        mov Sp,ValRegSp
                        mov cx,ValRegCX
                        SHR Sp,cl
                        call SetCarryFlag
                        movp2_ValRegSp,Sp
                        cmp selectedPUPType,2
                        je SHR_Sp_Reg_our
                        jmp Exit
                    SHR_Sp_Val:
                        cmp Op2Val,255d
                        ja SHR_invalid
                        cmp selectedPUPType,1
                        jne SHR_Sp_Val_his
                        SHR_Sp_Val_our:
                        mov Sp,p1_ValRegSp
                        mov cx,Op2Val
                        SHR Sp,cl
                        call ourSetCF
                        mov p1_ValRegSp,Sp
                        jmp Exit
                        SHR_Sp_Val_his:
                        mov ax,ValRegSp
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        SHR ax,cl
                        call SetCarryFlag
                        movp2_ValRegSp,ax
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
                        mov Si,p1_ValRegSi
                        mov cx,p1_ValRegCX
                        SHR Si,cl
                        call ourSetCF
                        mov p1_ValRegSi,Si
                        jmp Exit
                        SHR_Si_Reg_his:
                        mov Si,ValRegSi
                        mov cx,ValRegCX
                        SHR Si,cl
                        call SetCarryFlag
                        movp2_ValRegSi,Si
                        cmp selectedPUPType,2
                        je SHR_Si_Reg_our
                        jmp Exit
                    SHR_Si_Val:
                        cmp Op2Val,255d
                        ja SHR_invalid
                        cmp selectedPUPType,1
                        jne SHR_Si_Val_his
                        SHR_Si_Val_our:
                        mov Si,p1_ValRegSi
                        mov cx,Op2Val
                        SHR Si,cl
                        call ourSetCF
                        mov p1_ValRegSi,Si
                        jmp Exit
                        SHR_Si_Val_his:
                        mov ax,ValRegSi
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        SHR ax,cl
                        call SetCarryFlag
                        movp2_ValRegSi,ax
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
                        mov Di,p1_ValRegDi
                        mov cx,p1_ValRegCX
                        SHR Di,cl
                        call ourSetCF
                        mov p1_ValRegDi,Di
                        jmp Exit
                        SHR_Di_Reg_his:
                        mov Di,ValRegDi
                        mov cx,ValRegCX
                        SHR Di,cl
                        call SetCarryFlag
                        movp2_ValRegDi,Di
                        cmp selectedPUPType,2
                        je SHR_Di_Reg_our
                        jmp Exit
                    SHR_Di_Val:
                        cmp Op2Val,255d
                        ja SHR_invalid
                        cmp selectedPUPType,1
                        jne SHR_Di_Val_his
                        SHR_Di_Val_our:
                        mov Di,p1_ValRegDi
                        mov cx,Op2Val
                        SHR Di,cl
                        call ourSetCF
                        mov p1_ValRegDi,Di
                        jmp Exit
                        SHR_Di_Val_his:
                        mov ax,ValRegDi
                        mov cx,Op2Val
                        call LineStuckPwrUp
                        SHR ax,cl
                        call SetCarryFlag
                        movp2_ValRegDi,ax
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
                        mov Bx,p1_ValRegBX
                        cmp Bx,15d
                        ja SHR_invalid
                        mov cx,p1_ValRegCX
                        SHR p1_ValMem[Bx],cl
                        call ourSetCF
                        mov p1_ValRegBX,Bx
                        jmp Exit
                        SHR_AddBx_Reg_his:
                        mov Bx,ValRegBX
                        cmp Bx,15d
                        ja SHR_invalid
                        mov cx,ValRegCX
                        ;;;;;;;;;;;;;;;;;;;;;;;
                            mov al,ValMem[Bx]
                            call LineStuckPwrUp
                            movp2_ValMem[Bx],al
                        SHRp2_ValMem[Bx],cl
                        call SetCarryFlag
                        movp2_ValRegBX,Bx
                        cmp selectedPUPType,2
                        je SHR_AddBx_Reg_our
                        jmp Exit
                    SHR_AddBx_Val:
                        cmp Op2Val,255d
                        ja SHR_invalid
                        cmp selectedPUPType,1
                        jne SHR_AddBx_Val_his
                        SHR_AddBx_Val_our:
                        mov Bx,p1_ValRegBX
                        cmp Bx,15d
                        ja SHR_invalid
                        mov cx,Op2Val
                        SHR p1_ValMem[Bx],cl
                        call ourSetCF
                        mov p1_ValRegBX,Bx
                        jmp Exit
                        SHR_AddBx_Val_his:
                        mov Bx,ValRegBX
                        cmp Bx,15d
                        ja SHR_invalid
                        mov cx,Op2Val
                        ;;;;;;;;;;;;;;;;;;;;;;;
                            mov al,ValMem[Bx]
                            call LineStuckPwrUp
                            movp2_ValMem[Bx],al
                        SHRp2_ValMem[Bx],cl
                        call SetCarryFlag
                        movp2_ValRegBX,Bx
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
                        mov Bp,p1_ValRegBp
                        cmp Bp,15d
                        ja SHR_invalid
                        mov cx,p1_ValRegCX
                        SHR p1_ValMem[Bp],cl
                        call ourSetCF
                        mov p1_ValRegBp,Bp
                        jmp Exit
                        SHR_AddBp_Reg_his:
                        mov Bp,ValRegBp
                        cmp Bp,15d
                        ja SHR_invalid
                        mov cx,ValRegCX
                        ;;;;;;;;;;;;;;;;;;;;;;;
                            mov al,ValMem[Bp]
                            call LineStuckPwrUp
                            movp2_ValMem[Bp],al
                        SHRp2_ValMem[Bp],cl
                        call SetCarryFlag
                        movp2_ValRegBp,Bp
                        cmp selectedPUPType,2
                        je SHR_AddBp_Reg_our
                        jmp Exit
                    SHR_AddBp_Val:
                        cmp Op2Val,255d
                        ja SHR_invalid
                        cmp selectedPUPType,1
                        jne SHR_AddBp_Val_his
                        SHR_AddBp_Val_our:
                        mov Bp,p1_ValRegBp
                        cmp Bp,15d
                        ja SHR_invalid
                        mov cx,Op2Val
                        SHR p1_ValMem[Bp],cl
                        call ourSetCF
                        mov p1_ValRegBp,Bp
                        jmp Exit
                        SHR_AddBp_Val_his:
                        mov Bp,ValRegBp
                        cmp Bp,15d
                        ja SHR_invalid
                        mov cx,Op2Val
                        ;;;;;;;;;;;;;;;;;;;;;;;
                            mov al,ValMem[Bp]
                            call LineStuckPwrUp
                            movp2_ValMem[Bp],al
                        SHRp2_ValMem[Bp],cl
                        call SetCarryFlag
                        movp2_ValRegBp,Bp
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
                        mov Si,p1_ValRegSi
                        cmp Si,15d
                        ja SHR_invalid
                        mov cx,p1_ValRegCX
                        SHR p1_ValMem[Si],cl
                        call ourSetCF
                        mov p1_ValRegSi,Si
                        jmp Exit
                        SHR_AddSi_Reg_his:
                        mov Si,ValRegSi
                        cmp Si,15d
                        ja SHR_invalid
                        mov cx,ValRegCX
                        ;;;;;;;;;;;;;;;;;;;;;;;
                            mov al,ValMem[Si]
                            call LineStuckPwrUp
                            movp2_ValMem[Si],al
                        SHRp2_ValMem[Si],cl
                        call SetCarryFlag
                        movp2_ValRegSi,Si
                        cmp selectedPUPType,2
                        je SHR_AddSi_Reg_our
                        jmp Exit
                    SHR_AddSi_Val:
                        cmp Op2Val,255d
                        ja SHR_invalid
                        cmp selectedPUPType,1
                        jne SHR_AddSi_Val_his
                        SHR_AddSi_Val_our:
                        mov Si,p1_ValRegSi
                        cmp Si,15d
                        ja SHR_invalid
                        mov cx,Op2Val
                        SHR p1_ValMem[Si],cl
                        call ourSetCF
                        mov p1_ValRegSi,Si
                        jmp Exit
                        SHR_AddSi_Val_his:
                        mov Si,ValRegSi
                        cmp Si,15d
                        ja SHR_invalid
                        mov cx,Op2Val
                        ;;;;;;;;;;;;;;;;;;;;;;;
                            mov al,ValMem[Si]
                            call LineStuckPwrUp
                            movp2_ValMem[Si],al
                        SHRp2_ValMem[Si],cl
                        call SetCarryFlag
                        movp2_ValRegSi,Si
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
                        mov Di,p1_ValRegDi
                        cmp Di,15d
                        ja SHR_invalid
                        mov cx,p1_ValRegCX
                        SHR p1_ValMem[Di],cl
                        call ourSetCF
                        mov p1_ValRegDi,Di
                        jmp Exit
                        SHR_AddDi_Reg_his:
                        mov Di,ValRegDi
                        cmp Di,15d
                        ja SHR_invalid
                        mov cx,ValRegCX
                        ;;;;;;;;;;;;;;;;;;;;;;;
                            mov al,ValMem[Di]
                            call LineStuckPwrUp
                            movp2_ValMem[Di],al
                        SHRp2_ValMem[Di],cl
                        call SetCarryFlag
                        movp2_ValRegDi,Di
                        cmp selectedPUPType,2
                        je SHR_AddDi_Reg_our
                        jmp Exit
                    SHR_AddDi_Val:
                        cmp Op2Val,255d
                        ja SHR_invalid
                        cmp selectedPUPType,1
                        jne SHR_AddDi_Val_his
                        SHR_AddDi_Val_our:
                        mov Di,p1_ValRegDi
                        cmp Di,15d
                        ja SHR_invalid
                        mov cx,Op2Val
                        SHR p1_ValMem[Di],cl
                        call ourSetCF
                        mov p1_ValRegDi,Di
                        jmp Exit
                        SHR_AddDi_Val_his:
                        mov Di,ValRegDi
                        cmp Di,15d
                        ja SHR_invalid
                        mov cx,Op2Val
                        ;;;;;;;;;;;;;;;;;;;;;;;
                            mov al,ValMem[Di]
                            call LineStuckPwrUp
                            movp2_ValMem[Di],al
                        SHRp2_ValMem[Di],cl
                        call SetCarryFlag
                        movp2_ValRegDi,Di
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
                    mov cx,p1_ValRegCX
                    SHR p1_ValMem[si],cl
                    call ourSetCF
                    jmp Exit
                    SHR_Mem_Reg_his:
                    mov cx,ValRegCX
                    ;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[si]
                        call LineStuckPwrUp
                        movp2_ValMem[si],al
                    SHRp2_ValMem[si],cl
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
                    SHR p1_ValMem[si],cl
                    call ourSetCF
                    jmp Exit
                    SHR_Mem_Val_his:
                    mov cx,Op2Val
                    ;;;;;;;;;;;;;;;;;;
                        mov al,ValMem[si]
                        call LineStuckPwrUp
                        movp2_ValMem[si],al
                    SHRp2_ValMem[si],cl
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
            mov dx, offset error
            CALL DisplayString
            jmp Exit
            ; TODO - BEEP SOUND WHEN INVALID COMMAND ENTERED

        


CommMenu ENDP
;================================================================================================================
AND_Comm_PROC PROC FAR
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
            ExecAndReg p1_ValRegAX, p1_ValCF      ;command
            jmp Exit
            notthispower1_andax:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_andax  
            ExecAndReg p1_ValRegAX, p1_ValCF       ;coomand
            notthispower2_andax:
            ExecAndRegp2_ValRegAX,p2_ValCF
        AndOp1RegAL:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_andal   
            ExecAndReg_8Bit p1_ValRegAX, p1_ValCF      ;command
            jmp Exit
            notthispower1_andal:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_andal  
            ExecAndReg_8Bit p1_ValRegAX, p1_ValCF       ;coomand
            notthispower2_andal:
            ExecAndReg_8Bitp2_ValRegAX,p2_ValCF
        AndOp1RegAH:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_andah    
            ExecAndReg_8Bit p1_ValRegAX+1, p1_ValCF      ;command
            jmp Exit
            notthispower1_andah:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_andah  
            ExecAndReg_8Bit p1_ValRegAX+1, p1_ValCF       ;coomand
            notthispower2_andah:
            ExecAndReg_8Bitp2_ValRegAX+1,p2_ValCF
        AndOp1RegBX:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_andbx   
            ExecAndReg p1_ValRegBX, p1_ValCF      ;command
            jmp Exit
            notthispower1_andbx:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_andbx  
            ExecAndReg p1_ValRegBX, p1_ValCF       ;coomand
            notthispower2_andbx:
            ExecAndRegp2_ValRegBX,p2_ValCF
        AndOp1RegBL:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_andbl    
            ExecAndReg_8Bit p1_ValRegBX, p1_ValCF      ;command
            jmp Exit
            notthispower1_andbl:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_andbl 
            ExecAndReg_8Bit p1_ValRegBX, p1_ValCF       ;coomand
            notthispower2_andbl:
            ExecAndReg_8Bitp2_ValRegBX,p2_ValCF
        AndOp1RegBH:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_andbh    
            ExecAndReg_8Bit p1_ValRegBX+1, p1_ValCF      ;command
            jmp Exit
            notthispower1_andbh:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_andbh  
            ExecAndReg_8Bit p1_ValRegBX+1, p1_ValCF       ;coomand
            notthispower2_andbh:
            ExecAndReg_8Bitp2_ValRegBX+1,p2_ValCF
        AndOp1RegCX:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_andcx    
            ExecAndReg p1_ValRegCX, p1_ValCF      ;command
            jmp Exit
            notthispower1_andcx:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_andcx  
            ExecAndReg p1_ValRegCX, p1_ValCF       ;coomand
            notthispower2_andcx:
            ExecAndRegp2_ValRegCX,p2_ValCF
        AndOp1RegCL:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_andcl    
            ExecAndReg_8Bit p1_ValRegCX, p1_ValCF      ;command
            jmp Exit
            notthispower1_andcl:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_andcl  
            ExecAndReg_8Bit p1_ValRegCX, p1_ValCF       ;coomand
            notthispower2_andcl:
            ExecAndReg_8Bitp2_ValRegCX,p2_ValCF
        AndOp1RegCH:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_andch    
            ExecAndReg_8Bit p1_ValRegCX+1, p1_ValCF      ;command
            jmp Exit
            notthispower1_andch:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_andch  
            ExecAndReg_8Bit p1_ValRegCX+1, p1_ValCF       ;coomand
            notthispower2_andch:
            ExecAndReg_8Bitp2_ValRegCX+1,p2_ValCF
        AndOp1RegDX:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_anddx    
            ExecAndReg p1_ValRegDX, p1_ValCF      ;command
            jmp Exit
            notthispower1_anddx:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_anddx  
            ExecAndReg p1_ValRegDX, p1_ValCF       ;coomand
            notthispower2_anddx:
            ExecAndRegp2_ValRegDX,p2_ValCF
        AndOp1RegDL:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_anddl    
            ExecAndReg_8Bit p1_ValRegDX, p1_ValCF      ;command
            jmp Exit
            notthispower1_anddl:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_anddl  
            ExecAndReg_8Bit p1_ValRegDX, p1_ValCF       ;coomand
            notthispower2_anddl:
            ExecAndReg_8Bitp2_ValRegDX,p2_ValCF
        AndOp1RegDH:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_anddh    
            ExecAndReg_8Bit p1_ValRegDX+1, p1_ValCF      ;command
            jmp Exit
            notthispower1_anddh:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_anddh  
            ExecAndReg_8Bit p1_ValRegDX+1, p1_ValCF       ;coomand
            notthispower2_anddh:
            ExecAndReg_8Bitp2_ValRegDX+1,p2_ValCF
        AndOp1RegBP: 
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_andbp    
            ExecAndReg p1_ValRegBP, p1_ValCF      ;command
            jmp Exit
            notthispower1_andbp:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_andbp  
            ExecAndReg p1_ValRegBP, p1_ValCF       ;coomand
            notthispower2_andbp:
            ExecAndRegp2_ValRegBP,p2_ValCF
        AndOp1RegSP:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_andsp    
            ExecAndReg p1_ValRegSP, p1_ValCF      ;command
            jmp Exit
            notthispower1_andsp:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_andsp  
            ExecAndReg p1_ValRegSP, p1_ValCF       ;coomand
            notthispower2_andsp:
            ExecAndRegp2_ValRegSP,p2_ValCF
        AndOp1RegSI:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_andsi    
            ExecAndReg p1_ValRegSI, p1_ValCF      ;command
            jmp Exit
            notthispower1_andsi:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_andsi  
            ExecAndReg p1_ValRegSI, p1_ValCF       ;coomand
            notthispower2_andsi:
            ExecAndRegp2_ValRegSI,p2_ValCF
        AndOp1RegDI:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_anddi    
            ExecAndReg p1_ValRegDI, p1_ValCF      ;command
            jmp Exit
            notthispower1_anddi:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_anddi  
            ExecAndReg p1_ValRegDI, p1_ValCF       ;coomand
            notthispower2_anddi:
            ExecAndRegp2_ValRegDI,p2_ValCF

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
            ExecAndAddReg p1_ValRegBX, p1_ValMem, p1_ValCF      ;command
            jmp Exit
            notthispower1_andaddbx:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_andaddbx  
            ExecAndAddReg p1_ValRegBX, p1_ValMem, p1_ValCF       ;coomand
            notthispower2_andaddbx:   
            ExecAndAddRegp2_ValRegBX,p2_ValMem,p2_ValCF
        AndOp1AddRegBP:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_andaddbp    
            ExecAndAddReg p1_ValRegBP, p1_ValMem, p1_ValCF      ;command
            jmp Exit
            notthispower1_andaddbp:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_andaddbp  
            ExecAndAddReg p1_ValRegBP, p1_ValMem, p1_ValCF       ;coomand
            notthispower2_andaddbp:
            ExecAndAddRegp2_ValRegBP,p2_ValMem,p2_ValCF
        AndOp1AddRegSI:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_andaddsi    
            ExecAndAddReg p1_ValRegSI, p1_ValMem, p1_ValCF      ;command
            jmp Exit
            notthispower1_andaddsi:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_andaddsi 
            ExecAndAddReg p1_ValRegSI, p1_ValMem, p1_ValCF       ;coomand
            notthispower2_andaddsi:
            ExecAndAddRegp2_ValRegSI,p2_ValMem,p2_ValCF
        AndOp1AddRegDI:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_andadddi    
            ExecAndAddReg p1_ValRegDI, p1_ValMem, p1_ValCF      ;command
            jmp Exit
            notthispower1_andadddi:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_andadddi 
            ExecAndAddReg p1_ValRegDI, p1_ValMem, p1_ValCF       ;coomand
            notthispower2_andadddi:
            ExecAndAddRegp2_ValRegDI,p2_ValMem,p2_ValCF
    AndOp1Mem:
                
        mov si,0
        SearchForMemand:
        mov cx,si 
        cmp selectedOp2Mem,cl
        JNE Nextand
        cmp selectedPUPType,1 ;command on your own processor  
        jne notthispower1_andmem   
        ExecAndMem p1_ValMem[si], p1_ValCF      ;command
        jmp Exit
        notthispower1_andmem:
        cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
        jne notthispower2_andmem 
        ExecAndMem p1_ValMem[si], p1_ValCF       ;coomand
        notthispower2_andmem:
        ExecAndMemp2_ValMem[si],p2_ValCF
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
            MOV p1_ValRegAX, AX     ;command
            jmp Exit
            notthispower1_movax:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_movax 
            MOV p1_ValRegAX, AX      ;coomand
            notthispower2_movax:
            CALL GetSrcOp
            MOVp2_ValRegAX, AX
            JMP Exit
        MOVOp1RegAL:
            CALL ourGetSrcOp_8Bit
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_moval  
            MOV BYTE PTR p1_ValRegAX, AL    ;command
            jmp Exit
            notthispower1_moval:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_moval 
            MOV BYTE PTR p1_ValRegAX, AL      ;coomand
            notthispower2_moval:
            CALL GetSrcOp_8Bit
            MOV BYTE PTRp2_ValRegAX, AL
            JMP Exit
        MOVOp1RegAH:
            ; Delete this lineAH
            CALL ourGetSrcOp_8Bit
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_movah 
            MOV BYTE PTR p1_ValRegAX+1, AL    ;command
            jmp Exit
            notthispower1_movah:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_movah 
            MOV BYTE PTR p1_ValRegAX+1, AL      ;coomand
            notthispower2_movah:
            CALL GetSrcOp_8Bit
            MOV BYTE PTRp2_ValRegAX+1, AL
            JMP Exit
        MOVOp1RegBX:
            CALL ourGetSrcOp
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_movbx   
            MOV p1_ValRegBX, AX    ;command
            jmp Exit
            notthispower1_movbx:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_movbx 
            MOV p1_ValRegBX, AX      ;coomand
            notthispower2_movbx:
            CALL GetSrcOp
            MOVp2_ValRegBX, AX
            JMP Exit
        MOVOp1RegBL:
            CALL ourGetSrcOp_8Bit
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_movbl 
            MOV BYTE PTR p1_ValRegBX, AL    ;command
            jmp Exit
            notthispower1_movbl:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_movbl
            MOV BYTE PTR p1_ValRegBX, AL      ;coomand
            notthispower2_movbl:
            CALL GetSrcOp_8Bit
            MOV BYTE PTRp2_ValRegBX, AL
            JMP Exit
        MOVOp1RegBH:
            CALL ourGetSrcOp_8Bit
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_movbh
            MOV BYTE PTR p1_ValRegBX+1, AL    ;command
            jmp Exit
            notthispower1_movbh:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_movbh
            MOV BYTE PTR p1_ValRegBX+1, AL     ;coomand
            notthispower2_movbh:
            CALL GetSrcOp_8Bit
            MOV BYTE PTRp2_ValRegBX+1, AL
            JMP Exit
        MOVOp1RegCX:
            CALL ourGetSrcOp
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_movcx   
            MOV p1_ValRegCX, AX    ;command
            jmp Exit
            notthispower1_movcx:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_movcx 
            MOV p1_ValRegCX, AX      ;coomand
            notthispower2_movcx:
            CALL GetSrcOp
            MOVp2_ValRegCX, AX
            JMP Exit
        MOVOp1RegCL:
            CALL ourGetSrcOp_8Bit
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_movcl
            MOV BYTE PTR p1_ValRegCX, AL    ;command
            jmp Exit
            notthispower1_movcl:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_movcl
            MOV BYTE PTR p1_ValRegCX, AL     ;coomand
            notthispower2_movcl:
            CALL GetSrcOp_8Bit
            MOV BYTE PTRp2_ValRegCX, AL
            JMP Exit
        MOVOp1RegCH:
            CALL ourGetSrcOp_8Bit
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_movch
            MOV BYTE PTR p1_ValRegCX+1, AL    ;command
            jmp Exit
            notthispower1_movch:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_movch
            MOV BYTE PTR p1_ValRegCX+1, AL     ;coomand
            notthispower2_movch:
            CALL GetSrcOp_8Bit
            MOV BYTE PTRp2_ValRegCX+1, AL
            JMP Exit
        MOVOp1RegDX:
            CALL ourGetSrcOp
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_movdx   
            MOV p1_ValRegDX, AX    ;command
            jmp Exit
            notthispower1_movdx:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_movdx 
            MOV p1_ValRegDX, AX      ;coomand
            notthispower2_movdx:
            CALL GetSrcOp
            MOVp2_ValRegDX, AX
            JMP Exit
        MOVOp1RegDL:
            CALL ourGetSrcOp_8Bit
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_movdl
            MOV BYTE PTR p1_ValRegDX, AL    ;command
            jmp Exit
            notthispower1_movdl:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_movdl
            MOV BYTE PTR p1_ValRegDX, AL     ;coomand
            notthispower2_movdl:
            CALL GetSrcOp_8Bit
            MOV BYTE PTRp2_ValRegDX, AL
            JMP Exit
        MOVOp1RegDH:
            CALL ourGetSrcOp_8Bit
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_movdh
            MOV BYTE PTR p1_ValRegDX+1, AL    ;command
            jmp Exit
            notthispower1_movdh:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_movdh
            MOV BYTE PTR p1_ValRegDX+1, AL     ;coomand
            notthispower2_movdh:
            CALL GetSrcOp_8Bit
            MOV BYTE PTRp2_ValRegDX+1, AL
            JMP Exit
        MOVOp1RegBP:
            CALL ourGetSrcOp
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_movbp   
            MOV p1_ValRegBP, AX    ;command
            jmp Exit
            notthispower1_movbp:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_movbp 
            MOV p1_ValRegBP, AX      ;coomand
            notthispower2_movbp:
            CALL GetSrcOp
            MOVp2_ValRegBP, AX
            JMP Exit
        MOVOp1RegSP:
            CALL ourGetSrcOp
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_movsp   
            MOV p1_ValRegSP, AX    ;command
            jmp Exit
            notthispower1_movsp:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_movsp 
            MOV p1_ValRegSP, AX      ;coomand
            notthispower2_movsp:
            CALL GetSrcOp
            MOVp2_ValRegSP, AX
            JMP Exit
        MOVOp1RegSI:
            CALL ourGetSrcOp
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_movsi   
            MOV p1_ValRegSI, AX    ;command
            jmp Exit
            notthispower1_movsi:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_movsi 
            MOV p1_ValRegSI, AX      ;coomand
            notthispower2_movsi:
            CALL GetSrcOp
            MOVp2_ValRegSI, AX
            JMP Exit
        MOVOp1RegDI:
            CALL ourGetSrcOp
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_movdi   
            MOV p1_ValRegDI, AX    ;command
            jmp Exit
            notthispower1_movdi:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_movdi 
            MOV p1_ValRegDI, AX      ;coomand
            notthispower2_movdi:
            CALL GetSrcOp
            MOVp2_ValRegDI, AX
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
            ExecMovAddReg p1_ValRegBX, p1_ValMem    ;command
            jmp Exit
            notthispower1_movaddbx:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_movaddbx 
            ExecMovAddReg p1_ValRegBX, p1_ValMem      ;coomand
            notthispower2_movaddbx:
            ExecMovAddRegp2_ValRegBX,p2_ValMem
        MOVOp1AddRegBP:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_movaddbp   
            ExecMovAddReg p1_ValRegBP, p1_ValMem    ;command
            jmp Exit
            notthispower1_movaddbp:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_movaddbp
            ExecMovAddReg p1_ValRegBP, p1_ValMem      ;coomand
            notthispower2_movaddbp:
            ExecMovAddRegp2_ValRegBP,p2_ValMem
        MOVOp1AddRegSI:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_movaddsi 
            ExecMovAddReg p1_ValRegSI, p1_ValMem    ;command
            jmp Exit
            notthispower1_movaddsi:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_movaddsi 
            ExecMovAddReg p1_ValRegSI, p1_ValMem      ;coomand
            notthispower2_movaddsi:
            ExecMovAddRegp2_ValRegSI,p2_ValMem
        MOVOp1AddRegDI:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_movadddi 
            ExecMovAddReg p1_ValRegDI, p1_ValMem    ;command
            jmp Exit
            notthispower1_movadddi:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_movadddi 
            ExecMovAddReg p1_ValRegDI, p1_ValMem      ;coomand
            notthispower2_movadddi:
            ExecMovAddRegp2_ValRegDI,p2_ValMem
    MOVOp1Mem:
        
            mov si,0
            SearchForMemmov:
            mov cx,si 
            cmp selectedOp2Mem,cl
            JNE Nextmov
            cmp selectedPUPType,1 ; our command
            jne notthispower1_movmem
            ExecMovMem p1_ValMem[si] ; command
            jmp Exit
            notthispower1_movmem:  
            cmp selectedPUPType,2 ;his/her and our command 
            jne notthispower2_movmem 
            ExecMovMem p1_ValMem[si] ;command
            notthispower2_movmem: 
            ExecMovMemp2_ValMem[si]
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
            ADD p1_ValRegAX, AX ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_addax:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_addax  
            CLC
            ADD p1_ValRegAX, AX ;command
            CALL ourSetCF        
            notthispower2_addax:
            CALL GetSrcOp
            CLC
            ADDp2_ValRegAX, AX ;command
            CALL SetCF
            JMP Exit
        AddOp1RegAL:
            CALL ourGetSrcOp_8Bit
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_addal  
            CLC
            ADD BYTE PTR p1_ValRegAX, AL
            CALL ourSetCF      
            jmp Exit
            notthispower1_addal:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_addal 
            CLC
            ADD BYTE PTR p1_ValRegAX, AL
            CALL ourSetCF        
            notthispower2_addal:
            CALL GetSrcOp_8Bit
            CLC
            ADD BYTE PTRp2_ValRegAX, AL
            CALL SetCF
            JMP Exit
        AddOp1RegAH:
            CALL ourGetSrcOp_8Bit
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_addah  
            CLC
            ADD BYTE PTR p1_ValRegAX+1, AL ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_addah:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_addah 
            CLC
            ADD BYTE PTR p1_ValRegAX+1, AL ;command
            CALL ourSetCF        
            notthispower2_addah:
            CALL GetSrcOp_8Bit
            CLC
            ADD BYTE PTRp2_ValRegAX+1, AL ;command
            CALL SetCF
            JMP Exit
        AddOp1RegBX:
            CALL ourGetSrcOp
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_addbx 
            CLC
            ADD p1_ValRegBX, AX ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_addbx:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_addbx  
            CLC
            ADD p1_ValRegBX, AX ;command
            CALL ourSetCF        
            notthispower2_addbx:
            CALL GetSrcOp
            CLC
            ADDp2_ValRegBX, AX
            CALL SetCF
            JMP Exit
        AddOp1RegBL:
            CALL ourGetSrcOp_8Bit
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_addbl  
            CLC
            ADD BYTE PTR p1_ValRegBX, AL
            CALL ourSetCF      
            jmp Exit
            notthispower1_addbl:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_addbl 
            CLC
            ADD BYTE PTR p1_ValRegBX, AL
            CALL ourSetCF        
            notthispower2_addbl:
            CALL GetSrcOp_8Bit
            CLC
            ADD BYTE PTRp2_ValRegBX, AL
            CALL SetCF
            JMP Exit
        AddOp1RegBH:
            CALL ourGetSrcOp_8Bit
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_addbh  
            CLC
            ADD BYTE PTR p1_ValRegBX+1, AL
            CALL ourSetCF      
            jmp Exit
            notthispower1_addbh:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_addbh 
            CLC
            ADD BYTE PTR p1_ValRegBX+1, AL
            CALL ourSetCF        
            notthispower2_addbh:
            CALL GetSrcOp_8Bit
            CLC
            ADD BYTE PTRp2_ValRegBX+1, AL
            CALL SetCF
            JMP Exit
        AddOp1RegCX:
            CALL ourGetSrcOp
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_addcx 
            CLC
            ADD p1_ValRegCX, AX ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_addcx:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_addcx  
            CLC
            ADD p1_ValRegCX, AX ;command
            CALL ourSetCF        
            notthispower2_addcx:
            CALL GetSrcOp
            CLC
            ADDp2_ValRegCX, AX
            CALL SetCF
            JMP Exit
        AddOp1RegCL:
            CALL ourGetSrcOp_8Bit
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_addcl 
            CLC
            ADD BYTE PTR p1_ValRegCX, AL
            CALL ourSetCF      
            jmp Exit
            notthispower1_addcl:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_addcl 
            CLC
            ADD BYTE PTR p1_ValRegCX, AL
            CALL ourSetCF        
            notthispower2_addcl:
            CALL GetSrcOp_8Bit
            CLC
            ADD BYTE PTRp2_ValRegCX, AL
            CALL SetCF
            JMP Exit
        AddOp1RegCH:
            CALL ourGetSrcOp_8Bit
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_addch 
            CLC
            ADD BYTE PTR p1_ValRegCX+1, AL
            CALL ourSetCF      
            jmp Exit
            notthispower1_addch:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_addch 
            CLC
            ADD BYTE PTR p1_ValRegCX+1, AL
            CALL ourSetCF        
            notthispower2_addch:
            CALL GetSrcOp_8Bit
            CLC
            ADD BYTE PTRp2_ValRegCX+1, AL
            CALL SetCF
            JMP Exit
        AddOp1RegDX:
            CALL ourGetSrcOp
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_adddx 
            CLC
            ADD p1_ValRegDX, AX ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_adddx:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_adddx  
            CLC
            ADD p1_ValRegDX, AX ;command
            CALL ourSetCF        
            notthispower2_adddx:
            CALL GetSrcOp
            CLC
            ADDp2_ValRegDX, AX
            CALL SetCF
            JMP Exit
        AddOp1RegDL:
            CALL ourGetSrcOp_8Bit
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_adddl 
            CLC
            ADD BYTE PTR p1_ValRegDX, AL
            CALL ourSetCF      
            jmp Exit
            notthispower1_adddl:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_adddl 
            CLC
            ADD BYTE PTR p1_ValRegDX, AL
            CALL ourSetCF        
            notthispower2_adddl:
            CALL GetSrcOp_8Bit
            CLC
            ADD BYTE PTRp2_ValRegDX, AL
            CALL SetCF
            JMP Exit
        AddOp1RegDH:
            CALL ourGetSrcOp_8Bit
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_adddh 
            CLC
            ADD BYTE PTR p1_ValRegDX+1, AL
            CALL ourSetCF      
            jmp Exit
            notthispower1_adddh:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_adddh
            CLC
            ADD BYTE PTR p1_ValRegDX+1, AL
            CALL ourSetCF        
            notthispower2_adddh:
            CALL GetSrcOp_8Bit
            CLC
            ADD BYTE PTRp2_ValRegDX+1, AL
            CALL SetCF
            JMP Exit
        AddOp1RegBP:
            CALL ourGetSrcOp
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_addbp 
            CLC
            ADD p1_ValRegBP, AX ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_addbp:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_addbp  
            CLC
            ADD p1_ValRegBP, AX ;command
            CALL ourSetCF        
            notthispower2_addbp:
            CALL GetSrcOp
            CLC
            ADDp2_ValRegBP, AX
            CALL SetCF
            JMP Exit
        AddOp1RegSP:
            CALL ourGetSrcOp
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_addsp 
            CLC
            ADD p1_ValRegSP, AX ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_addsp:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_addsp  
            CLC
            ADD p1_ValRegSP, AX ;command
            CALL ourSetCF        
            notthispower2_addsp:
            CALL GetSrcOp
            CLC
            ADDp2_ValRegSP, AX
            CALL SetCF
            JMP Exit
        AddOp1RegSI:
            CALL ourGetSrcOp
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_addsi 
            CLC
            ADD p1_ValRegSI, AX ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_addsi:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_addsi 
            CLC
            ADD p1_ValRegSI, AX ;command
            CALL ourSetCF        
            notthispower2_addsi:
            CALL GetSrcOp
            CLC
            ADDp2_ValRegSI, AX
            CALL SetCF
            JMP Exit
        AddOp1RegDI:
            CALL ourGetSrcOp
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_adddi 
            CLC
            ADD p1_ValRegDI, AX ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_adddi:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_adddi  
            CLC
            ADD p1_ValRegDI, AX ;command
            CALL ourSetCF        
            notthispower2_adddi:
            CALL GetSrcOp
            CLC
            ADDp2_ValRegDI, AX
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
            ExecAddAddReg p1_ValRegBx, p1_ValMem ;command      
            jmp Exit
            notthispower1_addaddbx:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_addaddbx   
            ExecAddAddReg p1_ValRegBx, p1_ValMem ;command       
            notthispower2_addaddbx:
            ExecAddAddRegp2_ValRegBx,p2_ValMem
        AddOp1AddRegBP:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_addaddbp 
            ExecAddAddReg p1_ValRegBP, p1_ValMem ;command      
            jmp Exit
            notthispower1_addaddbp:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_addaddbp   
            ExecAddAddReg p1_ValRegBP, p1_ValMem ;command       
            notthispower2_addaddbp:
            ExecAddAddRegp2_ValRegBP,p2_ValMem
        AddOp1AddRegSI:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_addaddsi 
            ExecAddAddReg p1_ValRegSI, p1_ValMem ;command      
            jmp Exit
            notthispower1_addaddsi:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_addaddsi   
            ExecAddAddReg p1_ValRegSI, p1_ValMem ;command       
            notthispower2_addaddsi:
            ExecAddAddRegp2_ValRegSI,p2_ValMem
        AddOp1AddRegDI:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_addadddi 
            ExecAddAddReg p1_ValRegDI, p1_ValMem ;command      
            jmp Exit
            notthispower1_addadddi:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_addadddi   
            ExecAddAddReg p1_ValRegDI, p1_ValMem ;command       
            notthispower2_addadddi:
            ExecAddAddRegp2_ValRegDI,p2_ValMem

    AddOp1Mem:
        
            mov si,0
            SearchForMemadd:
            mov cx,si 
            cmp selectedOp2Mem,cl
            JNE Nextadd
            cmp selectedPUPType,1 ; our command
            jne notthispower1_addmem
            ExecAddMem p1_ValMem[si] ; command
            jmp Exit
            notthispower1_addmem:  
            cmp selectedPUPType,2 ;his/her and our command 
            jne notthispower2_addmem 
            ExecAddMem p1_ValMem[si] ;command
            notthispower2_addmem: 
            ExecAddMemp2_ValMem[si]
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
            ADC p1_ValRegAX, AX ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_adcax:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_adcax  
            CLC
            CALL ourGetCF
            ADC p1_ValRegAX, AX ;command
            CALL ourSetCF        
            notthispower2_adcax:
            CALL GetSrcOp 
            CLC
            CALL GetCF
            ADCp2_ValRegAX, AX
            CALL SetCF
            JMP Exit
        AdcOp1RegAL:
            CALL ourGetSrcOp_8Bit 
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_adcal 
            CLC
            CALL ourGetCF
            ADC BYTE PTR p1_ValRegAX, AL ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_adcal:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_adcal  
            CLC
            CALL ourGetCF
            ADC BYTE PTR p1_ValRegAX, AL ;command
            CALL ourSetCF        
            notthispower2_adcal:
            CALL GetSrcOp_8Bit
            CLC
            CALL GetCF
            ADC BYTE PTRp2_ValRegAX, AL
            CALL SetCF
            JMP Exit
        AdcOp1RegAH:
            CALL ourGetSrcOp_8Bit 
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_adcah 
            CLC
            CALL ourGetCF
            ADC BYTE PTR p1_ValRegAX+1, AL ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_adcah:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_adcah  
            CLC
            CALL ourGetCF
            ADC BYTE PTR p1_ValRegAX+1, AL ;command
            CALL ourSetCF        
            notthispower2_adcah:
            CALL GetSrcOp_8Bit
            CLC
            CALL GetCF
            ADC BYTE PTRp2_ValRegAX+1, AL
            CALL SetCF
            JMP Exit
        AdcOp1RegBX:
            CALL ourGetSrcOp 
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_adcbx 
            CLC
            CALL ourGetCF
            ADC p1_ValRegBX, AX ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_adcbx:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_adcbx  
            CLC
            CALL ourGetCF
            ADC p1_ValRegBX, AX ;command
            CALL ourSetCF        
            notthispower2_adcbx:
            CALL GetSrcOp
            CLC
            CALL GetCF
            ADCp2_ValRegBX, AX
            CALL SetCF
            JMP Exit
        AdcOp1RegBL:
            CALL ourGetSrcOp_8Bit 
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_adcbl 
            CLC
            CALL ourGetCF
            ADC BYTE PTR p1_ValRegBX, AL ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_adcbl:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_adcbl  
            CLC
            CALL ourGetCF
            ADC BYTE PTR p1_ValRegBX, AL ;command
            CALL ourSetCF        
            notthispower2_adcbl:
            CALL GetSrcOp_8Bit
            CLC
            CALL GetCF
            ADC BYTE PTRp2_ValRegBX, AL
            CALL SetCF
            JMP Exit
        AdcOp1RegBH:
            CALL ourGetSrcOp_8Bit 
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_adcbh 
            CLC
            CALL ourGetCF
            ADC BYTE PTR p1_ValRegBX+1, AL ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_adcbh:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_adcbh  
            CLC
            CALL ourGetCF
            ADC BYTE PTR p1_ValRegBX+1, AL ;command
            CALL ourSetCF        
            notthispower2_adcbh:
            CALL GetSrcOp_8Bit
            CLC
            CALL GetCF
            ADC BYTE PTRp2_ValRegBX+1, AL
            CALL SetCF
            JMP Exit
        AdcOp1RegCX:
            CALL ourGetSrcOp 
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_adccx 
            CLC
            CALL ourGetCF
            ADC p1_ValRegCX, AX ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_adccx:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_adccx  
            CLC
            CALL ourGetCF
            ADC p1_ValRegCX, AX ;command
            CALL ourSetCF        
            notthispower2_adccx:
            CALL GetSrcOp
            CLC
            CALL GetCF
            ADCp2_ValRegCX, AX
            CALL SetCF
            JMP Exit
        AdcOp1RegCL:
            CALL ourGetSrcOp_8Bit 
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_adccl 
            CLC
            CALL ourGetCF
            ADC BYTE PTR p1_ValRegCX, AL ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_adccl:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_adccl  
            CLC
            CALL ourGetCF
            ADC BYTE PTR p1_ValRegCX, AL ;command
            CALL ourSetCF        
            notthispower2_adccl:
            CALL GetSrcOp_8Bit
            CLC
            CALL GetCF
            ADC BYTE PTRp2_ValRegCX, AL
            CALL SetCF
            JMP Exit
        AdcOp1RegCH:
            CALL ourGetSrcOp_8Bit 
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_adcch 
            CLC
            CALL ourGetCF
            ADC BYTE PTR p1_ValRegCX+1, AL ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_adcch:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_adcch 
            CLC
            CALL ourGetCF
            ADC BYTE PTR p1_ValRegCX+1, AL ;command
            CALL ourSetCF        
            notthispower2_adcch:
            CALL GetSrcOp_8Bit
            CLC
            CALL GetCF
            ADC BYTE PTRp2_ValRegCX+1, AL
            CALL SetCF
            JMP Exit
        AdcOp1RegDX:
            CALL ourGetSrcOp 
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_adcdx 
            CLC
            CALL ourGetCF
            ADC p1_ValRegDX, AX ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_adcdx:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_adcdx  
            CLC
            CALL ourGetCF
            ADC p1_ValRegDX, AX ;command
            CALL ourSetCF        
            notthispower2_adcdx:
            CALL GetSrcOp
            CLC
            CALL GetCF
            ADCp2_ValRegDX, AX
            CALL SetCF
            JMP Exit
        AdcOp1RegDL:
            CALL ourGetSrcOp_8Bit 
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_adcdl 
            CLC
            CALL ourGetCF
            ADC BYTE PTR p1_ValRegDX, AL ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_adcdl:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_adcdl  
            CLC
            CALL ourGetCF
            ADC BYTE PTR p1_ValRegDX, AL ;command
            CALL ourSetCF        
            notthispower2_adcdl:
            CALL GetSrcOp_8Bit
            CLC
            CALL GetCF
            ADC BYTE PTRp2_ValRegDX, AL
            CALL SetCF
            JMP Exit
        AdcOp1RegDH:
            CALL ourGetSrcOp_8Bit 
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_adcdh 
            CLC
            CALL ourGetCF
            ADC BYTE PTR p1_ValRegDX+1, AL ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_adcdh:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_adcdh 
            CLC
            CALL ourGetCF
            ADC BYTE PTR p1_ValRegDX+1, AL ;command
            CALL ourSetCF        
            notthispower2_adcdh:
            CALL GetSrcOp_8Bit
            CLC
            CALL GetCF
            ADC BYTE PTRp2_ValRegDX+1, AL
            CALL SetCF
            JMP Exit
        AdcOp1RegBP:
            CALL ourGetSrcOp 
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_adcbp 
            CLC
            CALL ourGetCF
            ADC p1_ValRegBP, AX ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_adcbp:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_adcbp  
            CLC
            CALL ourGetCF
            ADC p1_ValRegBP, AX ;command
            CALL ourSetCF        
            notthispower2_adcbp:
            CALL GetSrcOp
            CLC
            CALL GetCF
            ADCp2_ValRegBP, AX
            CALL SetCF
            JMP Exit
        AdcOp1RegSP:
            CALL ourGetSrcOp 
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_adcsp 
            CLC
            CALL ourGetCF
            ADC p1_ValRegSP, AX ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_adcsp:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_adcsp  
            CLC
            CALL ourGetCF
            ADC p1_ValRegSP, AX ;command
            CALL ourSetCF        
            notthispower2_adcsp:
            CALL GetSrcOp
            CLC
            CALL GetCF
            ADCp2_ValRegSP, AX
            CALL SetCF
            JMP Exit
        AdcOp1RegSI:
            CALL ourGetSrcOp 
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_adcsi 
            CLC
            CALL ourGetCF
            ADC p1_ValRegSI, AX ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_adcsi:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_adcsi  
            CLC
            CALL ourGetCF
            ADC p1_ValRegSI, AX ;command
            CALL ourSetCF        
            notthispower2_adcsi:
            CALL GetSrcOp
            CLC
            CALL GetCF
            ADCp2_ValRegSI, AX
            CALL SetCF
            JMP Exit
        AdcOp1RegDI:
            CALL ourGetSrcOp 
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_adcdi 
            CLC
            CALL ourGetCF
            ADC p1_ValRegDI, AX ;command
            CALL ourSetCF      
            jmp Exit
            notthispower1_adcdi:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_adcdi  
            CLC
            CALL ourGetCF
            ADC p1_ValRegDI, AX ;command
            CALL ourSetCF        
            notthispower2_adcdi:
            CALL GetSrcOp
            CLC
            CALL GetCF
            ADCp2_ValRegDI, AX
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
            EexecAdcAddReg p1_ValRegBX, p1_ValMem     
            jmp Exit
            notthispower1_adcaddbx:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_adcaddbx 
            EexecAdcAddReg p1_ValRegBX, p1_ValMem        
            notthispower2_adcaddbx:
            EexecAdcAddRegp2_ValRegBX,p2_ValMem
        AdcOp1AddregBP:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_adcaddbp 
            EexecAdcAddReg p1_ValRegBP, p1_ValMem     
            jmp Exit
            notthispower1_adcaddbp:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_adcaddbp 
            EexecAdcAddReg p1_ValRegBP, p1_ValMem        
            notthispower2_adcaddbp:
            EexecAdcAddRegp2_ValRegBP,p2_ValMem
        AdcOp1AddregSI:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_adcaddsi 
            EexecAdcAddReg p1_ValRegSI, p1_ValMem     
            jmp Exit
            notthispower1_adcaddsi:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_adcaddsi
            EexecAdcAddReg p1_ValRegSI, p1_ValMem        
            notthispower2_adcaddsi:
            EexecAdcAddRegp2_ValRegSI,p2_ValMem
        AdcOp1AddregDI:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_adcadddi 
            EexecAdcAddReg p1_ValRegDI, p1_ValMem     
            jmp Exit
            notthispower1_adcadddi:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_adcadddi
            EexecAdcAddReg p1_ValRegDI, p1_ValMem        
            notthispower2_adcadddi:
            EexecAdcAddRegp2_ValRegDI,p2_ValMem
    AdcOp1Mem:

            mov si,0
            SearchForMemadc:
            mov cx,si 
            cmp selectedOp2Mem,cl
            JNE Nextadc
            cmp selectedPUPType,1 ; our command
            jne notthispower1_adcmem
            ExecAdcMem p1_ValMem[si] ; command
            jmp Exit
            notthispower1_adcmem:  
            cmp selectedPUPType,2 ;his/her and our command 
            jne notthispower2_adcmem 
            ExecAdcMem p1_ValMem[si] ;command
            notthispower2_adcmem: 
            ExecAdcMemp2_ValMem[si]
            JMP Exit 
            Nextadc:
            inc si 
            jmp SearchForMemadc

    
    JMP Exit
    RET
ENDP
PUSH_Comm_PROC PROC FAR
    
    CALL Op1Menu

    call  PowerUpeMenu ; to choose power up
    CALL CheckForbidCharProc

    ; Todo - CHECKp2_ValIDATIONS
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
            ourExecPush p1_ValRegAX      
            jmp Exit
            notthispower1_pushax:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_pushax  
            ourExecPush p1_ValRegAX        
            notthispower2_pushax:
            ExecPushp2_ValRegAX
            JMP Exit
        PushOpRegBX:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_pushbx  
            ourExecPush p1_ValRegBX      
            jmp Exit
            notthispower1_pushbx:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_pushbx  
            ourExecPush p1_ValRegBX        
            notthispower2_pushbx:
            ExecPushp2_ValRegBX
            JMP Exit
        PushOpRegCX:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_pushcx  
            ourExecPush p1_ValRegCX      
            jmp Exit
            notthispower1_pushcx:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_pushcx  
            ourExecPush p1_ValRegCX        
            notthispower2_pushcx:
            ExecPushp2_ValRegCX
            JMP Exit
        PushOpRegDX:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_pushdx  
            ourExecPush p1_ValRegDX      
            jmp Exit
            notthispower1_pushdx:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_pushdx  
            ourExecPush p1_ValRegDX        
            notthispower2_pushdx:
            ExecPushp2_ValRegDX
            JMP Exit
        PushOpRegBP:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_pushbp  
            ourExecPush p1_ValRegBP      
            jmp Exit
            notthispower1_pushbp:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_pushbp  
            ourExecPush p1_ValRegBP       
            notthispower2_pushbp:
            ExecPushp2_ValRegBP
            JMP Exit
        PushOpRegSP:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_pushsp  
            ourExecPush p1_ValRegSP      
            jmp Exit
            notthispower1_pushsp:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_pushsp  
            ourExecPush p1_ValRegSP        
            notthispower2_pushsp:
            ExecPushp2_ValRegSP
            JMP Exit
        PushOpRegSI:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_pushsi  
            ourExecPush p1_ValRegSI      
            jmp Exit
            notthispower1_pushsi:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_pushsi  
            ourExecPush p1_ValRegSI        
            notthispower2_pushsi:
            ExecPushp2_ValRegSI
            JMP Exit
        PushOpRegDI:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_pushdi  
            ourExecPush p1_ValRegDI      
            jmp Exit
            notthispower1_pushdi:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_pushdi  
            ourExecPush p1_ValRegDI        
            notthispower2_pushdi:
            ExecPushp2_ValRegDI
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
            ourExecPushMem p1_ValMem[si] ; command
            jmp Exit
            notthispower1_pushmem:  
            cmp selectedPUPType,2 ;his/her and our command 
            jne notthispower2_pushmem 
            ourExecPushMem p1_ValMem[si] ;command
            notthispower2_pushmem: 
            ExecPushMemp2_ValMem[si]
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
            mov dx, p1_ValRegBX
            CALL CheckAddress
            cmp bl, 1               ;p2_Value is greater than 16
            JZ InValidCommand
            mov SI, p1_ValRegBX
            ourExecPushMem p1_ValMem[SI]      
            jmp Exit
            notthispower1_pushaddbx:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_pushaddbx  
            mov dx, p1_ValRegBX
            CALL CheckAddress
            cmp bl, 1               ;p2_Value is greater than 16
            JZ InValidCommand
            mov SI, p1_ValRegBX
            ourExecPushMem p1_ValMem[SI]       
            notthispower2_pushaddbx:

            mov dx,p2_ValRegBX
            CALL CheckAddress
            cmp bl, 1               ;p2_Value is greater than 16
            JZ InValidCommand
            mov SI,p2_ValRegBX
            ExecPushMemp2_ValMem[SI]
            JMP Exit
        PushOpAddRegBP:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_pushaddbp  
            mov dx, p1_ValRegBP
            CALL CheckAddress
            cmp bl, 1               ;p2_Value is greater than 16
            JZ InValidCommand
            mov SI, p1_ValRegBP
            ourExecPushMem p1_ValMem[SI]      
            jmp Exit
            notthispower1_pushaddbp:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_pushaddbp  
            mov dx, p1_ValRegBP
            CALL CheckAddress
            cmp bl, 1               ;p2_Value is greater than 16
            JZ InValidCommand
            mov SI, p1_ValRegBP
            ourExecPushMem p1_ValMem[SI]       
            notthispower2_pushaddbp:

            mov dx,p2_ValRegBP
            CALL CheckAddress
            cmp bl, 1               ;p2_Value is greater than 16
            JZ InValidCommand
            mov SI,p2_ValRegBP
            ExecPushMemp2_ValMem[SI]
            JMP Exit

        PushOpAddRegSI:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_pushaddsi  
            mov dx, p1_ValRegSI
            CALL CheckAddress
            cmp bl, 1               ;p2_Value is greater than 16
            JZ InValidCommand
            mov SI, p1_ValRegSI
            ourExecPushMem p1_ValMem[SI]      
            jmp Exit
            notthispower1_pushaddsi:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_pushaddsi  
            mov dx, p1_ValRegSI
            CALL CheckAddress
            cmp bl, 1               ;p2_Value is greater than 16
            JZ InValidCommand
            mov SI, p1_ValRegSI
            ourExecPushMem p1_ValMem[SI]       
            notthispower2_pushaddsi:

            mov dx,p2_ValRegSI
            CALL CheckAddress
            cmp bl, 1               ;p2_Value is greater than 16
            JZ InValidCommand
            mov SI,p2_ValRegSI
            ExecPushMemp2_ValMem[SI]
            JMP Exit
        
        PushOpAddRegDI:
            cmp selectedPUPType,1 ;command on your own processor  
            jne notthispower1_pushadddi  
            mov dx, p1_ValRegDI
            CALL CheckAddress
            cmp bl, 1               ;p2_Value is greater than 16
            JZ InValidCommand
            mov SI, p1_ValRegDI
            ourExecPushMem p1_ValMem[SI]      
            jmp Exit
            notthispower1_pushadddi:
            cmp selectedPUPType,2 ;command on your processor and your opponent processor at the same time 
            jne notthispower2_pushadddi  
            mov dx, p1_ValRegDI
            CALL CheckAddress
            cmp bl, 1               ;p2_Value is greater than 16
            JZ InValidCommand
            mov SI, p1_ValRegDI
            ourExecPushMem p1_ValMem[SI]       
            notthispower2_pushadddi:

            mov dx,p2_ValRegDI
            CALL CheckAddress
            cmp bl, 1               ;p2_Value is greater than 16
            JZ InValidCommand
            mov SI,p2_ValRegDI
            ExecPushMemp2_ValMem[SI]
            JMP Exit


    ;p2_Value as operand
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
ExitPROC PROC FAR
    ; Return to dos
    mov ah,4ch
    int 21h
    
ENDP
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
    movp2_ValCF,dl
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
CheckAddress proc     ;p2_Value of register supposed to be in dx before calling the proc, if greater bl = 1 else bl = 0
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
            mov dx, offsetp2_Value           ; Op1TypeLastChoiceLoc
            add dx, CommStringSize
        NotOverflow_1:
            sub dx, CommStringSize
            int 21h
            jmp CheckKeyOp1Type
    
    CommDown_1:
        mov ah, 9
        ; Check End of file
            cmp dx, offsetp2_Value           ; Op1TypeLastChoiceLoc
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
LineStuckPwrUp PROC  FAR   ;p2_Value to be stucked is saved in AX/AL
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
        ;TODO Take 1 input from the user as thep2_Value to be stuck 0 or 1, and 1 input for the index of thep2_Value stuck
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
            mov dx, offsetp2_Value           ; OpTypeLastChoiceLoc
            add dx, CommStringSize
        NotOverflow_Op2Type:
            sub dx, CommStringSize
            int 21h
            jmp CheckKey_Op2Type
    
    CommDown_Op2Type:
        mov ah, 9
        ; Check End of file
            cmp dx, offsetp2_Value           ; OpTypeLastChoiceLoc
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
    CMP selectedOp1Type,p2_ValIndex
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
        CALL CheckOp2Size
        RET
Op1Menu ENDP
CheckOp1Size PROC
    CMP selectedOp1Type, RegIndex
    jz Reg_CheckOp1Size
    CMP selectedOp1Type,p2_ValIndex
    jzp2_Val_CheckOp1Size
    
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

   p2_Val_CheckOp1Size:
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
    CMP selectedOp2Type,p2_ValIndex
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
            JMP InValidCommand   

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
    CMP selectedOp2Type,p2_ValIndex
    jzp2_Val_CheckOp2Size
    
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

   p2_Val_CheckOp2Size:
        CMP Op2Val, 0FFH
        ja Op2Val_16Bit
        mov selectedOp2Size, 8
        RET
        Op2Val_16Bit:
        mov selectedOp2Size, 16
        ret
ENDP
ourGetSrcOp_8Bit PROC    ; Returnedp2_Value is saved in AL

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
            mov al, BYTE PTR p1_ValRegAX
            RET
        SrcOp2RegAH_8Bit2:
            mov al, BYTE PTR p1_ValRegAX+1
            RET
        SrcOp2RegBL_8Bit2:
            mov al, BYTE PTR p1_ValRegBX
            RET
        SrcOp2RegBH_8Bit2:
            mov al, BYTE PTR p1_ValRegBX+1
            RET
        SrcOp2RegCL_8Bit2:
            mov al, BYTE PTR p1_ValRegCX
            RET
        SrcOp2RegCH_8Bit2:
            mov al, BYTE PTR p1_ValRegCX+1
            RET
        SrcOp2RegDL_8Bit2:
            mov al, BYTE PTR p1_ValRegDX
            RET
        SrcOp2RegDH_8Bit2:
            mov al, BYTE PTR p1_ValRegDX+1
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
            MOV DX, p1_ValRegBX
            CALL CheckAddress
            CMP BL, 1
            JZ InValidCommand
            MOV SI, p1_ValRegBX
            MOV AL, [SI]
            RET
        SrcOp2AddRegBP_8Bit2:
            MOV DX, p1_ValRegBP
            CALL CheckAddress
            CMP BL, 1
            JZ InValidCommand
            MOV SI, p1_ValRegBP
            MOV AL, [SI]
            RET
        SrcOp2AddRegSI_8Bit2:
            MOV DX, p1_ValRegSI
            CALL CheckAddress
            CMP BL, 1
            JZ InValidCommand
            MOV SI, p1_ValRegSI
            MOV AL, [SI]
            RET
        SrcOp2AddRegDI_8Bit2:
            MOV DX, p1_ValRegDI
            CALL CheckAddress
            CMP BL, 1
            JZ InValidCommand
            MOV SI, p1_ValRegDI
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
            MOV AL, p1_ValMem
            RET
        SrcOp2Mem1_8Bit2:
            MOV AL, p1_ValMem+1
            RET
        SrcOp2Mem2_8Bit2:
            MOV AL, p1_ValMem+2
            RET
        SrcOp2Mem3_8Bit2:
            MOV AL, p1_ValMem+3
            RET
        SrcOp2Mem4_8Bit2:
            MOV AL, p1_ValMem+4
            RET
        SrcOp2Mem5_8Bit2:
            MOV AL, p1_ValMem+5
            RET
        SrcOp2Mem6_8Bit2:
            MOV AL, p1_ValMem+6
            RET
        SrcOp2Mem7_8Bit2:
            MOV AL, p1_ValMem+7
            RET
        SrcOp2Mem8_8Bit2:
            MOV AL, p1_ValMem+8
            RET
        SrcOp2Mem9_8Bit2:
            MOV AL, p1_ValMem+9
            RET
        SrcOp2Mem10_8Bit2:
            MOV AL, p1_ValMem+10
            RET
        SrcOp2Mem11_8Bit2:
            MOV AL, p1_ValMem+11
            RET
        SrcOp2Mem12_8Bit2:
            MOV AL, p1_ValMem+12
            RET
        SrcOp2Mem13_8Bit2:
            MOV AL, p1_ValMem+13
            RET
        SrcOp2Mem14_8Bit2:
            MOV AL, p1_ValMem+14
            RET
        SrcOp2Mem15_8Bit2:
            MOV AL, p1_ValMem+15
            RET
    SrcOp2Val_8Bit2:
        CMP Op2Valid, 0
        jz InValidCommand
        MOV AL, BYTE PTR Op2Val
        RET
ourGetSrcOp_8Bit ENDP    
GetSrcOp_8Bit PROC    ; Returnedp2_Value is saved in AL

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
            mov al, BYTE PTRp2_ValRegAX
            JMP RETURN_GetSrcOp_8Bit
        SrcOp2RegAH_8Bit:
            mov al, BYTE PTRp2_ValRegAX+1
            JMP RETURN_GetSrcOp_8Bit
        SrcOp2RegBL_8Bit:
            mov al, BYTE PTRp2_ValRegBX
            JMP RETURN_GetSrcOp_8Bit
        SrcOp2RegBH_8Bit:
            mov al, BYTE PTRp2_ValRegBX+1
            JMP RETURN_GetSrcOp_8Bit
        SrcOp2RegCL_8Bit:
            mov al, BYTE PTRp2_ValRegCX
            JMP RETURN_GetSrcOp_8Bit
        SrcOp2RegCH_8Bit:
            mov al, BYTE PTRp2_ValRegCX+1
            JMP RETURN_GetSrcOp_8Bit
        SrcOp2RegDL_8Bit:
            mov al, BYTE PTRp2_ValRegDX
            JMP RETURN_GetSrcOp_8Bit
        SrcOp2RegDH_8Bit:
            mov al, BYTE PTRp2_ValRegDX+1
            JMP RETURN_GetSrcOp_8Bit
        


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
            MOV DX,p2_ValRegBX
            CALL CheckAddress
            CMP BL, 1
            JZ InValidCommand
            MOV SI,p2_ValRegBX
            MOV AL, [SI]
            JMP RETURN_GetSrcOp_8Bit
        SrcOp2AddRegBP_8Bit:
            MOV DX,p2_ValRegBP
            CALL CheckAddress
            CMP BL, 1
            JZ InValidCommand
            MOV SI,p2_ValRegBP
            MOV AL, [SI]
            JMP RETURN_GetSrcOp_8Bit
        SrcOp2AddRegSI_8Bit:
            MOV DX,p2_ValRegSI
            CALL CheckAddress
            CMP BL, 1
            JZ InValidCommand
            MOV SI,p2_ValRegSI
            MOV AL, [SI]
            JMP RETURN_GetSrcOp_8Bit
        SrcOp2AddRegDI_8Bit:
            MOV DX,p2_ValRegDI
            CALL CheckAddress
            CMP BL, 1
            JZ InValidCommand
            MOV SI,p2_ValRegDI
            MOV AL, [SI]
            JMP RETURN_GetSrcOp_8Bit

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
            MOV AL,p2_ValMem
            JMP RETURN_GetSrcOp_8Bit
        SrcOp2Mem1_8Bit:
            MOV AL,p2_ValMem+1
            JMP RETURN_GetSrcOp_8Bit
        SrcOp2Mem2_8Bit:
            MOV AL,p2_ValMem+2
            JMP RETURN_GetSrcOp_8Bit
        SrcOp2Mem3_8Bit:
            MOV AL,p2_ValMem+3
            JMP RETURN_GetSrcOp_8Bit
        SrcOp2Mem4_8Bit:
            MOV AL,p2_ValMem+4
            JMP RETURN_GetSrcOp_8Bit
        SrcOp2Mem5_8Bit:
            MOV AL,p2_ValMem+5
            JMP RETURN_GetSrcOp_8Bit
        SrcOp2Mem6_8Bit:
            MOV AL,p2_ValMem+6
            JMP RETURN_GetSrcOp_8Bit
        SrcOp2Mem7_8Bit:
            MOV AL,p2_ValMem+7
            JMP RETURN_GetSrcOp_8Bit
        SrcOp2Mem8_8Bit:
            MOV AL,p2_ValMem+8
            JMP RETURN_GetSrcOp_8Bit
        SrcOp2Mem9_8Bit:
            MOV AL,p2_ValMem+9
            JMP RETURN_GetSrcOp_8Bit
        SrcOp2Mem10_8Bit:
            MOV AL,p2_ValMem+10
            JMP RETURN_GetSrcOp_8Bit
        SrcOp2Mem11_8Bit:
            MOV AL,p2_ValMem+11
            JMP RETURN_GetSrcOp_8Bit
        SrcOp2Mem12_8Bit:
            MOV AL,p2_ValMem+12
            JMP RETURN_GetSrcOp_8Bit
        SrcOp2Mem13_8Bit:
            MOV AL,p2_ValMem+13
            JMP RETURN_GetSrcOp_8Bit
        SrcOp2Mem14_8Bit:
            MOV AL,p2_ValMem+14
            JMP RETURN_GetSrcOp_8Bit
        SrcOp2Mem15_8Bit:
            MOV AL,p2_ValMem+15
            JMP RETURN_GetSrcOp_8Bit
    SrcOp2Val_8Bit:
        CMP Op2Valid, 0
        jz InValidCommand
        MOV AL, BYTE PTR Op2Val
        JMP RETURN_GetSrcOp_8Bit
    
    RETURN_GetSrcOp_8Bit:
        CALL LineStuckPwrUp
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
GetSrcOp PROC    ; Returned Value is saved in AX, CALL TWICE IF Command is executed on BOTH CPUS
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

        MOV InValidCommand, 1
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

        MOV InValidCommand, 1
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
                MOV p1_CpuEnabled, 0
                MOV AX, p1_ValMem[BX]      ;command
                JMP RETURN_GetSrcOp
            
            p2_GetSrc:
                MOV p2_CpuEnabled, 0
                MOV AX, p2_ValMem[BX]      ;command
                JMP RETURN_GetSrcOp


            NextMem_GetSrc:
                INC BX
                CMP BX, 16
                JZ EndSearch
        jmp SearchForMem_GetSrc
        EndSearch_GetSrc:
            MOV InvalidCommand, 1
            JMP RETURN_GetSrcOp

    SrcOp2Val:
        CMP Op2Valid, 1
        JZ ValidVal_GetSrc
        MOV InvalidCommand, 1
        ValidVal_GetSrc:
            MOV AX, Op2Val
            JMP RETURN_GetSrcOp

    RETURN_GetSrcOp:
        CALL LineStuckPwrUp
        RET

GetSrcOp ENDP
ourGetSrcOp PROC    ; Returnedp2_Value is saved in AX
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
            MOV AX, p1_ValRegAX
            RET
        SrcOp2RegBXa:
            MOV AX, p1_ValRegBX
            RET
        SrcOp2RegCXa:
            MOV AX, p1_ValRegCX
            RET
        SrcOp2pRegDXa:
            MOV AX, p1_ValRegDX
            RET
        SrcOp2RegBPa:
            MOV AX, p1_ValRegBP
            RET
        SrcOp2RegSPa:
            MOV AX, p1_ValRegSP
            RET
        SrcOp2RegSIa:
            MOV AX, p1_ValRegSI
            RET
        SrcOp2RegDIa:
            MOV AX, p1_ValRegDI
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
            MOV DX, p1_ValRegBX
            CALL CheckAddress
            CMP BL, 1
            JZ InValidCommand
            MOV SI, p1_ValRegBX
            MOV AX, [SI]
            RET
        SrcOp2AddRegBPa:
            MOV DX, p1_ValRegBP
            CALL CheckAddress
            CMP BL, 1
            JZ InValidCommand
            MOV SI, p1_ValRegBP
            MOV AX, [SI]
            RET
        SrcOp2AddRegSIa:
            MOV DX, p1_ValRegSI
            CALL CheckAddress
            CMP BL, 1
            JZ InValidCommand
            MOV SI, p1_ValRegSI
            MOV AX, [SI]
            RET
        SrcOp2AddRegDIa:
            MOV DX, p1_ValRegDI
            CALL CheckAddress
            CMP BL, 1
            JZ InValidCommand
            MOV SI, p1_ValRegDI
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
            MOV AX, WORD PTR p1_ValMem
            RET
        SrcOp2Mem1a:
            MOV AX, WORD PTR p1_ValMem+1
            RET
        SrcOp2Mem2a:
            MOV AX, WORD PTR p1_ValMem+2
            RET
        SrcOp2Mem3a:
            MOV AX, WORD PTR p1_ValMem+3
            RET
        SrcOp2Mem4a:
            MOV AX, WORD PTR p1_ValMem+4
            RET
        SrcOp2Mem5a:
            MOV AX, WORD PTR p1_ValMem+5
            RET
        SrcOp2Mem6a:
            MOV AX, WORD PTR p1_ValMem+6
            RET
        SrcOp2Mem7a:
            MOV AX, WORD PTR p1_ValMem+7
            RET
        SrcOp2Mem8a:
            MOV AX, WORD PTR p1_ValMem+8
            RET
        SrcOp2Mem9a:
            MOV AX, WORD PTR p1_ValMem+9
            RET
        SrcOp2Mem10a:
            MOV AX, WORD PTR p1_ValMem+10
            RET
        SrcOp2Mem11a:
            MOV AX, WORD PTR p1_ValMem+11
            RET
        SrcOp2Mem12a:
            MOV AX, WORD PTR p1_ValMem+12
            RET
        SrcOp2Mem13a:
            MOV AX, WORD PTR p1_ValMem+13
            RET
        SrcOp2Mem14a:
            MOV AX, WORD PTR p1_ValMem+14
            RET
        SrcOp2Mem15a:
            MOV AX, WORD PTR p1_ValMem+15
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
        MOV BL,p2_ValCF
    POP BX

    RET
ENDP
ourSetCF PROC
    PUSH BX
        MOV BL, 0
        ADC BL, 0
        MOV BL, p1_ValCF
    POP BX

    RET
ENDP
ourGetCF PROC
    PUSH BX
        MOV BL, p1_ValCF
        ADD BL, 0FFH
    POP BX

    RET
ENDP
GetCF PROC
    PUSH BX
        MOV BL,p2_ValCF
        ADD BL, 0FFH
    POP BX

    RET
ENDP
GetDst PROC FAR  ; offset of the operand is saved in di, destination is called by op1 menu. Call the procedure twice to get the next value if two cpus are enabled

    CMP selectedOp1Type, 0
    JZ DstOp1Reg
    CMP selectedOp1Type, 1
    JZ DstOp1AddReg
    CMP selectedOp1Type, 2
    JZ DstOp1Mem

    MOV InvalidCommand, 1
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

        MOV InvalidCommand, 1
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

        MOV InvalidCommand, 1
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
                MOV p1_CpuEnabled, 0
                LEA DI, p1_ValMem[BX]      ;command
                JMP RETURN_DstSrc
            
            p2_DstMem:
                MOV p2_CpuEnabled, 0
                LEA DI, p2_ValMem[BX]      ;command
                JMP RETURN_DstSrc


            NextMem_GetDst:
                INC BX
                CMP BX, 16
                JZ EndSearch
        jmp SearchForMem_GetDst
        EndSearch_GetDst:
            MOV InvalidCommand, 1
            JMP RETURN_DstSrc


    RETURN_DstSrc:
        RET
GetDst ENDP
END CommMenu