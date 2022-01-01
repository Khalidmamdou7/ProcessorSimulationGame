; Macros
ExecPush MACRO Op
    mov bh, 0
    mov bl, ValStackPointer
    mov ax, Op
    lea di, ValStack
    mov [di][bx], ax
    ADD ValStackPointer,2
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
ExecPopMem MACRO Op
    mov bh, 0
    mov bl, ValStackPointer
    lea di, ValStack
    mov ax, [di][bx]
    mov word ptr Op, ax
    SUB ValStackPointer,2
ENDM
ExecINC MACRO Op
    INC Op
ENDM
ExecDEC MACRO Op
    DEC Op
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
    PUSHcom db 'PUSH ','$'
    POPcom db 'POP  ','$'
    INCcom db 'INC  ','$'
    DECcom db 'DEC  ','$'
    MULcom db 'MUL  ','$'
    DIVcom db 'DIV  ','$'
    RORcom db 'ROR  ','$'
    ROLcom db 'ROL  ','$'
    RCRcom db 'RCR  ','$'
    RCLcom db 'RCL  ','$'
    ANDcom db 'AND  ','$'
    ADCcom db 'ADC  ','$'
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

    ValMem db 16 dup('M'), '$'
    ValStack db 16 dup('S'), '$'
    ValStackPointer db 0
    ValCF db 1
    
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
    ForbidChar db 'N'
    ForbidCommand db 0    ; 1 if if forbidden



    ; Keys Scan Codes
    UpArrowScanCode EQU 72
    DownArrowScanCode EQU 80
    EnterScanCode EQU 28 

    ; Cursor Locations
    MenmonicCursorLoc EQU 0000H
    Op1CursorLoc EQU 0006H
    CommaCursorLoc EQU 000BH
    Op2CursorLoc EQU 000CH
    
    
 
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
        JZ PUSH_Comm
        CMP selectedComm, 5
        JZ POP_Comm
        CMP selectedComm, 6
        JZ INC_Comm
        CMP selectedComm, 7
        JZ DEC_Comm
        CMP selectedComm, 8
        JZ MUL_Comm
        CMP selectedComm, 9
        JZ DIV_Comm
        CMP selectedComm, 10
        JZ ROR_Comm
        cmp selectedComm, 11
        JZ ROL_Comm
        cmp selectedComm, 12
        JZ RCR_Comm
        cmp selectedComm, 13
        JZ RCL_Comm
        CMP selectedComm, 14
        JZ AND_Comm
        CMP selectedComm, 15
        JZ ADC_Comm
        cmp selectedComm, 16
        JZ SHL_Comm
        cmp selectedComm, 17
        JZ SHR_Comm

        JMP TODO_Comm
        ; Continue comparing for all operations

        ; Commands (operations) Labels
        NOP_Comm:
            CALL CheckForbidCharProc
            NOP
            JMP Exit
        
        CLC_Comm:
            CALL CheckForbidCharProc
            MOV ValCF, 0
            JMP Exit
        AND_Comm:

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
                    ; Delete this lineAX
                    CALL GetSrcOp
                    And ValRegAX, AX
                    JMP Exit
                AndOp1RegAL:
                    ; Delete this lineAL
                    CALL GetSrcOp_8Bit
                    And BYTE PTR ValRegAX, AL
                    JMP Exit
                AndOp1RegAH:
                    ; Delete this lineAH
                    CALL GetSrcOp_8Bit
                    And BYTE PTR ValRegAX+1, AL
                    JMP Exit
                AndOp1RegBX:
                    ; Delete this lineBX
                    CALL GetSrcOp
                    And ValRegBX, AX
                    JMP Exit
                AndOp1RegBL:
                    ; Delete this lineBL
                    CALL GetSrcOp_8Bit
                    And BYTE PTR ValRegBX, AL
                    JMP Exit
                AndOp1RegBH:
                    ; Delete this lineBH
                    CALL GetSrcOp_8Bit
                    And BYTE PTR ValRegBX+1, AL
                    JMP Exit
                AndOp1RegCX:
                    ; Delete this lineCX
                    CALL GetSrcOp
                    And ValRegCX, AX
                    JMP Exit
                AndOp1RegCL:
                    ; Delete this lineCL
                    CALL GetSrcOp_8Bit
                    And BYTE PTR ValRegCX, AL
                    JMP Exit
                AndOp1RegCH:
                    ; Delete this lineCH
                    CALL GetSrcOp_8Bit
                    And BYTE PTR ValRegCX+1, AL
                    JMP Exit
                AndOp1RegDX:
                    ; Delete this lineDX
                    CALL GetSrcOp
                    And ValRegDX, AX
                    JMP Exit
                AndOp1RegDL:
                    ; Delete this lineDL
                    CALL GetSrcOp_8Bit
                    And BYTE PTR ValRegDX, AL
                    JMP Exit
                AndOp1RegDH:
                    ; Delete this lineDH
                    CALL GetSrcOp_8Bit
                    And BYTE PTR ValRegDX+1, AL
                    JMP Exit
                AndOp1RegBP:
                    ; Delete this lineBP
                    CALL GetSrcOp
                    And ValRegBP, AX
                    JMP Exit
                AndOp1RegSP:
                    ; Delete this lineSP
                    CALL GetSrcOp
                    And ValRegSP, AX
                    JMP Exit
                AndOp1RegSI:
                    ; Delete this lineSI
                    CALL GetSrcOp
                    And ValRegSI, AX
                    JMP Exit
                AndOp1RegDI:
                    ; Delete this lineDI
                    CALL GetSrcOp
                    And ValRegDI, AX
                    JMP Exit

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
                    ; Delete this lineRegBX
                    And dx, ValRegBX
                    CALL CheckAddress
                    cmp bl, 1               ; Value is greater than 16
                    JZ InValidCommand

                    CMP selectedOp2Size, 8
                    jz AndOp1AddRegBX_Op2_8Bit 
                    CALL GetSrcOp
                    And SI, ValRegBX
                    And WORD PTR ValMem[SI], AX
                    JMP Exit
                    AndOp1AddRegBX_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        And SI, ValRegBX
                        And ValMem[SI], AL
                    JMP Exit
                AndOp1AddRegBP:
                    ; Delete this lineRegBP

                    And dx, ValRegBP
                    CALL CheckAddress
                    cmp bl, 1               ; Value is greater than 16
                    JZ InValidCommand

                    CMP selectedOp2Size, 8
                    jz AndOp1AddRegBP_Op2_8Bit 
                    CALL GetSrcOp
                    And SI, ValRegBP
                    And WORD PTR ValMem[SI], AX
                    JMP Exit
                    AndOp1AddRegBP_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        And SI, ValRegBP
                        And ValMem[SI], AL
                    JMP Exit

                AndOp1AddRegSI:
                    ; Delete this lineRegSI

                    And dx, ValRegSI
                    CALL CheckAddress
                    cmp bl, 1               ; Value is greater than 16
                    JZ InValidCommand

                    CMP selectedOp2Size, 8
                    jz AndOp1AddRegSI_Op2_8Bit 
                    CALL GetSrcOp
                    And SI, ValRegSI
                    And WORD PTR ValMem[SI], AX
                    JMP Exit
                    AndOp1AddRegSI_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        And SI, ValRegSI
                        And ValMem[SI], AL
                    JMP Exit
                
                AndOp1AddRegDI:
                    ; Delete this lineRegDI

                    And dx, ValRegDI
                    CALL CheckAddress
                    cmp bl, 1               ; Value is greater than 16
                    JZ InValidCommand

                    CMP selectedOp2Size, 8
                    jz AndOp1AddRegDI_Op2_8Bit 
                    CALL GetSrcOp
                    And SI, ValRegDI
                    And WORD PTR ValMem[SI], AX
                    JMP Exit
                    AndOp1AddRegDI_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        And SI, ValRegDI
                        And ValMem[SI], AL
                    JMP Exit

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
                    ; Delete this line0

                    CMP selectedOp2Size, 8
                    JZ AndOp1Mem0_Op2_8Bit
                    CALL GetSrcOp
                    And WORD PTR ValMem, AX

                    AndOp1Mem0_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        And ValMem, AL 
                    JMP Exit
                AndOp1Mem1:
                    ; Delete this line1
                    
                    CMP selectedOp2Size, 8
                    JZ AndOp1Mem1_Op2_8Bit
                    CALL GetSrcOp
                    And WORD PTR ValMem+1, AX

                    AndOp1Mem1_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        And ValMem+1, AL 
                    JMP Exit
                AndOp1Mem2:
                    ; Delete this line2

                    CMP selectedOp2Size, 8
                    JZ AndOp1Mem2_Op2_8Bit
                    CALL GetSrcOp
                    And WORD PTR ValMem+2, AX

                    AndOp1Mem2_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        And ValMem+2, AL 
                    JMP Exit
                AndOp1Mem3:
                    ; Delete this line3
                    
                    CMP selectedOp2Size, 8
                    JZ AndOp1Mem3_Op2_8Bit
                    CALL GetSrcOp
                    And WORD PTR ValMem+3, AX

                    AndOp1Mem3_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        And ValMem+3, AL 
                    JMP Exit
                AndOp1Mem4:
                    ; Delete this line4

                    CMP selectedOp2Size, 8
                    JZ AndOp1Mem4_Op2_8Bit
                    CALL GetSrcOp
                    And WORD PTR ValMem+4, AX

                    AndOp1Mem4_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        And ValMem+4, AL 
                    JMP Exit
                AndOp1Mem5:
                    ; Delete this line5

                    CMP selectedOp2Size, 8
                    JZ AndOp1Mem5_Op2_8Bit
                    CALL GetSrcOp
                    And WORD PTR ValMem+5, AX

                    AndOp1Mem5_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        And ValMem+5, AL 
                    JMP Exit
                AndOp1Mem6:
                    ; Delete this line6

                    CMP selectedOp2Size, 8
                    JZ AndOp1Mem6_Op2_8Bit
                    CALL GetSrcOp
                    And WORD PTR ValMem+6, AX

                    AndOp1Mem6_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        And ValMem+6, AL 
                    JMP Exit
                AndOp1Mem7:
                    ; Delete this line7

                    CMP selectedOp2Size, 8
                    JZ AndOp1Mem7_Op2_8Bit
                    CALL GetSrcOp
                    And WORD PTR ValMem+7, AX

                    AndOp1Mem7_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        And ValMem+7, AL 
                    JMP Exit
                AndOp1Mem8:
                    ; Delete this line8

                    CMP selectedOp2Size, 8
                    JZ AndOp1Mem8_Op2_8Bit
                    CALL GetSrcOp
                    And WORD PTR ValMem+8, AX

                    AndOp1Mem8_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        And ValMem+8, AL 
                    JMP Exit
                AndOp1Mem9:
                    ; Delete this line9

                    CMP selectedOp2Size, 8
                    JZ AndOp1Mem9_Op2_8Bit
                    CALL GetSrcOp
                    And WORD PTR ValMem+9, AX

                    AndOp1Mem9_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        And ValMem+9, AL 
                    JMP Exit
                AndOp1Mem10:
                    ; Delete this line10

                    CMP selectedOp2Size, 8
                    JZ AndOp1Mem10_Op2_8Bit
                    CALL GetSrcOp
                    And WORD PTR ValMem+10, AX

                    AndOp1Mem10_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        And ValMem+10, AL 
                    JMP Exit
                AndOp1Mem11:
                    ; Delete this line11

                    CMP selectedOp2Size, 8
                    JZ AndOp1Mem11_Op2_8Bit
                    CALL GetSrcOp
                    And WORD PTR ValMem+11, AX

                    AndOp1Mem11_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        And ValMem+11, AL 
                    JMP Exit
                AndOp1Mem12:
                    ; Delete this line12

                    CMP selectedOp2Size, 8
                    JZ AndOp1Mem12_Op2_8Bit
                    CALL GetSrcOp
                    And WORD PTR ValMem+12, AX

                    AndOp1Mem12_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        And ValMem+12, AL 
                    JMP Exit
                AndOp1Mem13:
                    ; Delete this line13

                    CMP selectedOp2Size, 8
                    JZ AndOp1Mem13_Op2_8Bit
                    CALL GetSrcOp
                    And WORD PTR ValMem+13, AX

                    AndOp1Mem13_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        And ValMem+13, AL 
                    JMP Exit
                AndOp1Mem14:
                    ; Delete this line14

                    CMP selectedOp2Size, 8
                    JZ AndOp1Mem14_Op2_8Bit
                    CALL GetSrcOp
                    And WORD PTR ValMem+14, AX
                    
                    AndOp1Mem14_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        And ValMem+14, AL 
                    JMP Exit
                AndOp1Mem15:
                    ; Delete this line15

                    CMP selectedOp2Size, 8
                    JZ AndOp1Mem15_Op2_8Bit
                    CALL GetSrcOp
                    And WORD PTR ValMem+15, AX

                    AndOp1Mem15_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        And ValMem+15, AL 
                    JMP Exit

            
            JMP Exit
        MOV_Comm:

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
                    ; Delete this lineRegBX
                    MOV dx, ValRegBX
                    CALL CheckAddress
                    cmp bl, 1               ; Value is greater than 16
                    JZ InValidCommand

                    CMP selectedOp2Size, 8
                    jz MOVOp1AddRegBX_Op2_8Bit 
                    CALL GetSrcOp
                    MOV SI, ValRegBX
                    MOV WORD PTR ValMem[SI], AX
                    JMP Exit
                    MOVOp1AddRegBX_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        MOV SI, ValRegBX
                        MOV ValMem[SI], AL
                    JMP Exit
                MOVOp1AddRegBP:
                    ; Delete this lineRegBP

                    MOV dx, ValRegBP
                    CALL CheckAddress
                    cmp bl, 1               ; Value is greater than 16
                    JZ InValidCommand

                    CMP selectedOp2Size, 8
                    jz MOVOp1AddRegBP_Op2_8Bit 
                    CALL GetSrcOp
                    MOV SI, ValRegBP
                    MOV WORD PTR ValMem[SI], AX
                    JMP Exit
                    MOVOp1AddRegBP_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        MOV SI, ValRegBP
                        MOV ValMem[SI], AL
                    JMP Exit

                MOVOp1AddRegSI:
                    ; Delete this lineRegSI

                    MOV dx, ValRegSI
                    CALL CheckAddress
                    cmp bl, 1               ; Value is greater than 16
                    JZ InValidCommand

                    CMP selectedOp2Size, 8
                    jz MOVOp1AddRegSI_Op2_8Bit 
                    CALL GetSrcOp
                    MOV SI, ValRegSI
                    MOV WORD PTR ValMem[SI], AX
                    JMP Exit
                    MOVOp1AddRegSI_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        MOV SI, ValRegSI
                        MOV ValMem[SI], AL
                    JMP Exit
                
                MOVOp1AddRegDI:
                    ; Delete this lineRegDI

                    MOV dx, ValRegDI
                    CALL CheckAddress
                    cmp bl, 1               ; Value is greater than 16
                    JZ InValidCommand

                    CMP selectedOp2Size, 8
                    jz MOVOp1AddRegDI_Op2_8Bit 
                    CALL GetSrcOp
                    MOV SI, ValRegDI
                    MOV WORD PTR ValMem[SI], AX
                    JMP Exit
                    MOVOp1AddRegDI_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        MOV SI, ValRegDI
                        MOV ValMem[SI], AL
                    JMP Exit

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
                    ; Delete this line0

                    CMP selectedOp2Size, 8
                    JZ MOVOp1Mem0_Op2_8Bit
                    CALL GetSrcOp
                    MOV WORD PTR ValMem, AX

                    MOVOp1Mem0_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        MOV ValMem, AL 
                    JMP Exit
                MOVOp1Mem1:
                    ; Delete this line1
                    
                    CMP selectedOp2Size, 8
                    JZ MOVOp1Mem1_Op2_8Bit
                    CALL GetSrcOp
                    MOV WORD PTR ValMem+1, AX

                    MOVOp1Mem1_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        MOV ValMem+1, AL 
                    JMP Exit
                MOVOp1Mem2:
                    ; Delete this line2

                    CMP selectedOp2Size, 8
                    JZ MOVOp1Mem2_Op2_8Bit
                    CALL GetSrcOp
                    MOV WORD PTR ValMem+2, AX

                    MOVOp1Mem2_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        MOV ValMem+2, AL 
                    JMP Exit
                MOVOp1Mem3:
                    ; Delete this line3
                    
                    CMP selectedOp2Size, 8
                    JZ MOVOp1Mem3_Op2_8Bit
                    CALL GetSrcOp
                    MOV WORD PTR ValMem+3, AX

                    MOVOp1Mem3_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        MOV ValMem+3, AL 
                    JMP Exit
                MOVOp1Mem4:
                    ; Delete this line4

                    CMP selectedOp2Size, 8
                    JZ MOVOp1Mem4_Op2_8Bit
                    CALL GetSrcOp
                    MOV WORD PTR ValMem+4, AX

                    MOVOp1Mem4_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        MOV ValMem+4, AL 
                    JMP Exit
                MOVOp1Mem5:
                    ; Delete this line5

                    CMP selectedOp2Size, 8
                    JZ MOVOp1Mem5_Op2_8Bit
                    CALL GetSrcOp
                    MOV WORD PTR ValMem+5, AX

                    MOVOp1Mem5_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        MOV ValMem+5, AL 
                    JMP Exit
                MOVOp1Mem6:
                    ; Delete this line6

                    CMP selectedOp2Size, 8
                    JZ MOVOp1Mem6_Op2_8Bit
                    CALL GetSrcOp
                    MOV WORD PTR ValMem+6, AX

                    MOVOp1Mem6_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        MOV ValMem+6, AL 
                    JMP Exit
                MOVOp1Mem7:
                    ; Delete this line7

                    CMP selectedOp2Size, 8
                    JZ MOVOp1Mem7_Op2_8Bit
                    CALL GetSrcOp
                    MOV WORD PTR ValMem+7, AX

                    MOVOp1Mem7_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        MOV ValMem+7, AL 
                    JMP Exit
                MOVOp1Mem8:
                    ; Delete this line8

                    CMP selectedOp2Size, 8
                    JZ MOVOp1Mem8_Op2_8Bit
                    CALL GetSrcOp
                    MOV WORD PTR ValMem+8, AX

                    MOVOp1Mem8_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        MOV ValMem+8, AL 
                    JMP Exit
                MOVOp1Mem9:
                    ; Delete this line9

                    CMP selectedOp2Size, 8
                    JZ MOVOp1Mem9_Op2_8Bit
                    CALL GetSrcOp
                    MOV WORD PTR ValMem+9, AX

                    MOVOp1Mem9_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        MOV ValMem+9, AL 
                    JMP Exit
                MOVOp1Mem10:
                    ; Delete this line10

                    CMP selectedOp2Size, 8
                    JZ MOVOp1Mem10_Op2_8Bit
                    CALL GetSrcOp
                    MOV WORD PTR ValMem+10, AX

                    MOVOp1Mem10_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        MOV ValMem+10, AL 
                    JMP Exit
                MOVOp1Mem11:
                    ; Delete this line11

                    CMP selectedOp2Size, 8
                    JZ MOVOp1Mem11_Op2_8Bit
                    CALL GetSrcOp
                    MOV WORD PTR ValMem+11, AX

                    MOVOp1Mem11_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        MOV ValMem+11, AL 
                    JMP Exit
                MOVOp1Mem12:
                    ; Delete this line12

                    CMP selectedOp2Size, 8
                    JZ MOVOp1Mem12_Op2_8Bit
                    CALL GetSrcOp
                    MOV WORD PTR ValMem+12, AX

                    MOVOp1Mem12_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        MOV ValMem+12, AL 
                    JMP Exit
                MOVOp1Mem13:
                    ; Delete this line13

                    CMP selectedOp2Size, 8
                    JZ MOVOp1Mem13_Op2_8Bit
                    CALL GetSrcOp
                    MOV WORD PTR ValMem+13, AX

                    MOVOp1Mem13_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        MOV ValMem+13, AL 
                    JMP Exit
                MOVOp1Mem14:
                    ; Delete this line14

                    CMP selectedOp2Size, 8
                    JZ MOVOp1Mem14_Op2_8Bit
                    CALL GetSrcOp
                    MOV WORD PTR ValMem+14, AX
                    
                    MOVOp1Mem14_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        MOV ValMem+14, AL 
                    JMP Exit
                MOVOp1Mem15:
                    ; Delete this line15

                    CMP selectedOp2Size, 8
                    JZ MOVOp1Mem15_Op2_8Bit
                    CALL GetSrcOp
                    MOV WORD PTR ValMem+15, AX

                    MOVOp1Mem15_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        MOV ValMem+15, AL 
                    JMP Exit

            
            JMP Exit
        

        ADD_Comm:

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
                    MOV dx, ValRegBX
                    CALL CheckAddress
                    cmp bl, 1               ; Value is greater than 16
                    JZ InValidCommand

                    CMP selectedOp2Size, 8
                    jz AddOp1AddRegBX_Op2_8Bit 
                    CALL GetSrcOp
                    MOV SI, ValRegBX
                    CLC
                    ADD WORD PTR ValMem[SI], AX
                    CALL SetCF
                    JMP Exit
                    AddOp1AddRegBX_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        MOV SI, ValRegBX
                        CLC
                        ADD ValMem[SI], AL
                        CALL SetCF
                    JMP Exit
                AddOp1AddRegBP:

                    MOV dx, ValRegBP
                    CALL CheckAddress
                    cmp bl, 1               ; Value is greater than 16
                    JZ InValidCommand

                    CMP selectedOp2Size, 8
                    jz AddOp1AddRegBP_Op2_8Bit 
                    CALL GetSrcOp
                    MOV SI, ValRegBP
                    CLC
                    ADD WORD PTR ValMem[SI], AX
                    CALL SetCF
                    JMP Exit
                    AddOp1AddRegBP_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        MOV SI, ValRegBP
                        CLC
                        ADD ValMem[SI], AL
                        CALL SetCF
                    JMP Exit

                AddOp1AddRegSI:

                    MOV dx, ValRegSI
                    CALL CheckAddress
                    cmp bl, 1               ; Value is greater than 16
                    JZ InValidCommand

                    CMP selectedOp2Size, 8
                    jz AddOp1AddRegSI_Op2_8Bit 
                    CALL GetSrcOp
                    MOV SI, ValRegSI
                    CLC
                    ADD WORD PTR ValMem[SI], AX
                    CALL SetCF
                    JMP Exit
                    AddOp1AddRegSI_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        MOV SI, ValRegSI
                        CLC
                        ADD ValMem[SI], AL
                        CALL SetCF
                    JMP Exit
                
                AddOp1AddRegDI:

                    MOV dx, ValRegDI
                    CALL CheckAddress
                    cmp bl, 1               ; Value is greater than 16
                    JZ InValidCommand

                    CMP selectedOp2Size, 8
                    jz AddOp1AddRegDI_Op2_8Bit 
                    CALL GetSrcOp
                    MOV SI, ValRegDI
                    CLC
                    ADD WORD PTR ValMem[SI], AX
                    CALL SetCF
                    JMP Exit
                    AddOp1AddRegDI_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        MOV SI, ValRegDI
                        CLC
                        ADD ValMem[SI], AL
                        CALL SetCF
                    JMP Exit

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

                    CMP selectedOp2Size, 8
                    JZ AddOp1Mem0_Op2_8Bit
                    CALL GetSrcOp
                    CLC
                    ADD WORD PTR ValMem, AX
                    CALL SetCF

                    AddOp1Mem0_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        CLC
                        ADD ValMem, AL 
                        CALL SetCF
                    JMP Exit
                AddOp1Mem1:
                    
                    CMP selectedOp2Size, 8
                    JZ AddOp1Mem1_Op2_8Bit
                    CALL GetSrcOp
                    CLC
                    ADD WORD PTR ValMem+1, AX
                    CALL SetCF

                    AddOp1Mem1_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        CLC
                        ADD ValMem+1, AL 
                        CALL SetCF
                    JMP Exit
                AddOp1Mem2:

                    CMP selectedOp2Size, 8
                    JZ AddOp1Mem2_Op2_8Bit
                    CALL GetSrcOp
                    CLC
                    ADD WORD PTR ValMem+2, AX
                    CALL SetCF

                    AddOp1Mem2_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        CLC
                        ADD ValMem+2, AL 
                        CALL SetCF 
                    JMP Exit
                AddOp1Mem3:
                    
                    CMP selectedOp2Size, 8
                    JZ AddOp1Mem3_Op2_8Bit
                    CALL GetSrcOp
                    CLC
                    ADD WORD PTR ValMem+3, AX
                    CALL SetCF

                    AddOp1Mem3_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        CLC
                        ADD ValMem+3, AL 
                        CALL SetCF
                    JMP Exit
                AddOp1Mem4:

                    CMP selectedOp2Size, 8
                    JZ AddOp1Mem4_Op2_8Bit
                    CALL GetSrcOp
                    CLC
                    ADD WORD PTR ValMem+4, AX
                    CALL SetCF

                    AddOp1Mem4_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        CLC
                        ADD ValMem+4, AL 
                        CALL SetCF 
                    JMP Exit
                AddOp1Mem5:

                    CMP selectedOp2Size, 8
                    JZ AddOp1Mem5_Op2_8Bit
                    CALL GetSrcOp
                    CLC
                    ADD WORD PTR ValMem+5, AX
                    CALL SetCF

                    AddOp1Mem5_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        CLC
                        ADD ValMem+5, AL 
                        CALL SetCF
                    JMP Exit
                AddOp1Mem6:

                    CMP selectedOp2Size, 8
                    JZ AddOp1Mem6_Op2_8Bit
                    CALL GetSrcOp
                    CLC
                    ADD WORD PTR ValMem+6, AX
                    CALL SetCF

                    AddOp1Mem6_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        CLC
                        ADD ValMem+6, AL 
                        CALL SetCF
                    JMP Exit
                AddOp1Mem7:

                    CMP selectedOp2Size, 8
                    JZ AddOp1Mem7_Op2_8Bit
                    CALL GetSrcOp
                    CLC
                    ADD WORD PTR ValMem+7, AX
                    CALL SetCF

                    AddOp1Mem7_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        CLC
                        ADD ValMem+7, AL 
                        CALL SetCF 
                    JMP Exit
                AddOp1Mem8:

                    CMP selectedOp2Size, 8
                    JZ AddOp1Mem8_Op2_8Bit
                    CALL GetSrcOp
                    CLC
                    ADD WORD PTR ValMem+8, AX
                    CALL SetCF

                    AddOp1Mem8_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        CLC
                        ADD ValMem+8, AL 
                        CALL SetCF
                    JMP Exit
                AddOp1Mem9:

                    CMP selectedOp2Size, 8
                    JZ AddOp1Mem9_Op2_8Bit
                    CALL GetSrcOp
                    CLC
                    ADD WORD PTR ValMem+9, AX
                    CALL SetCF

                    AddOp1Mem9_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        CLC
                        ADD ValMem+9, AL 
                        CALL SetCF 
                    JMP Exit
                AddOp1Mem10:

                    CMP selectedOp2Size, 8
                    JZ AddOp1Mem10_Op2_8Bit
                    CALL GetSrcOp
                    CLC
                    ADD WORD PTR ValMem+10, AX
                    CALL SetCF

                    AddOp1Mem10_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        CLC
                        ADD ValMem+10, AL 
                        CALL SetCF 
                    JMP Exit
                AddOp1Mem11:

                    CMP selectedOp2Size, 8
                    JZ AddOp1Mem11_Op2_8Bit
                    CALL GetSrcOp
                    CLC
                    ADD WORD PTR ValMem+11, AX
                    CALL SetCF

                    AddOp1Mem11_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        CLC
                        ADD ValMem+11, AL 
                        CALL SetCF 
                    JMP Exit
                AddOp1Mem12:

                    CMP selectedOp2Size, 8
                    JZ AddOp1Mem12_Op2_8Bit
                    CALL GetSrcOp
                    CLC
                    ADD WORD PTR ValMem+12, AX
                    CALL SetCF

                    AddOp1Mem12_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        CLC
                        ADD ValMem+12, AL 
                        CALL SetCF
                    JMP Exit
                AddOp1Mem13:

                    CMP selectedOp2Size, 8
                    JZ AddOp1Mem13_Op2_8Bit
                    CALL GetSrcOp
                    CLC
                    ADD WORD PTR ValMem+13, AX
                    CALL SetCF

                    AddOp1Mem13_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        CLC
                        ADD ValMem+13, AL 
                        CALL SetCF 
                    JMP Exit
                AddOp1Mem14:

                    CMP selectedOp2Size, 8
                    JZ AddOp1Mem14_Op2_8Bit
                    CALL GetSrcOp
                    CLC
                    ADD WORD PTR ValMem+14, AX
                    CALL SetCF
                    
                    AddOp1Mem14_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        CLC
                        ADD ValMem+14, AL 
                        CALL SetCF 
                    JMP Exit
                AddOp1Mem15:

                    CMP selectedOp2Size, 8
                    JZ AddOp1Mem15_Op2_8Bit
                    CALL GetSrcOp
                    CLC
                    ADD WORD PTR ValMem+15, AX
                    CALL SetCF

                    AddOp1Mem15_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        CLC
                        ADD ValMem+15, AL 
                        CALL SetCF 
                    JMP Exit

            
            JMP Exit

        ADC_Comm:
            
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
                    MOV dx, ValRegBX
                    CALL CheckAddress
                    cmp bl, 1               ; Value is greater than 16
                    JZ InValidCommand

                    CMP selectedOp2Size, 8
                    jz AdcOp1AddregBX_Op2_8Bit 
                    CALL GetSrcOp
                    MOV SI, ValRegBX
                    CLC
                    CALL GetCF
                    ADC WORD PTR ValMem[SI], AX
                    CALL SetCF
                    JMP Exit
                    AdcOp1AddregBX_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        MOV SI, ValRegBX
                        CLC
                        CALL GetCF
                        ADC ValMem[SI], AL
                        CALL SetCF
                    JMP Exit
                AdcOp1AddregBP:

                    MOV dx, ValRegBP
                    CALL CheckAddress
                    cmp bl, 1               ; Value is greater than 16
                    JZ InValidCommand

                    CMP selectedOp2Size, 8
                    jz AdcOp1AddregBP_Op2_8Bit 
                    CALL GetSrcOp
                    MOV SI, ValRegBP
                    CLC
                    CALL GetCF
                    ADC WORD PTR ValMem[SI], AX
                    CALL SetCF
                    JMP Exit
                    AdcOp1AddregBP_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        MOV SI, ValRegBP
                        CLC
                        CALL GetCF
                        ADC ValMem[SI], AL
                        CALL SetCF
                    JMP Exit

                AdcOp1AddregSI:

                    MOV dx, ValRegSI
                    CALL CheckAddress
                    cmp bl, 1               ; Value is greater than 16
                    JZ InValidCommand

                    CMP selectedOp2Size, 8
                    jz AdcOp1AddregSI_Op2_8Bit 
                    CALL GetSrcOp
                    MOV SI, ValRegSI
                    CLC
                    CALL GetCF
                    ADC WORD PTR ValMem[SI], AX
                    CALL SetCF
                    JMP Exit
                    AdcOp1AddregSI_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        MOV SI, ValRegSI
                        CLC
                        CALL GetCF
                        ADC ValMem[SI], AL
                        CALL SetCF
                    JMP Exit
                
                AdcOp1AddregDI:

                    MOV dx, ValRegDI
                    CALL CheckAddress
                    cmp bl, 1               ; Value is greater than 16
                    JZ InValidCommand

                    CMP selectedOp2Size, 8
                    jz AdcOp1AddregDI_Op2_8Bit 
                    CALL GetSrcOp
                    MOV SI, ValRegDI
                    CLC
                    CALL GetCF
                    ADC WORD PTR ValMem[SI], AX
                    CALL SetCF
                    JMP Exit
                    AdcOp1AddregDI_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        MOV SI, ValRegDI
                        CLC
                        CALL GetCF
                        ADC ValMem[SI], AL
                        CALL SetCF
                    JMP Exit

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

                    CMP selectedOp2Size, 8
                    JZ AdcOp1Mem0_Op2_8Bit
                    CALL GetSrcOp
                    CLC
                    CALL GetCF
                    ADC WORD PTR ValMem, AX
                    CALL SetCF

                    AdcOp1Mem0_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        CLC
                        CALL GetCF
                        ADC ValMem, AL 
                        CALL SetCF
                    JMP Exit
                AdcOp1Mem1:
                    
                    CMP selectedOp2Size, 8
                    JZ AdcOp1Mem1_Op2_8Bit
                    CALL GetSrcOp
                    CLC
                    CALL GetCF
                    ADC WORD PTR ValMem+1, AX
                    CALL SetCF

                    AdcOp1Mem1_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        CLC
                        CALL GetCF
                        ADC ValMem+1, AL 
                        CALL SetCF
                    JMP Exit
                AdcOp1Mem2:

                    CMP selectedOp2Size, 8
                    JZ AdcOp1Mem2_Op2_8Bit
                    CALL GetSrcOp
                    CLC
                    CALL GetCF
                    ADC WORD PTR ValMem+2, AX
                    CALL SetCF

                    AdcOp1Mem2_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        CLC
                        CALL GetCF
                        ADC ValMem+2, AL 
                        CALL SetCF 
                    JMP Exit
                AdcOp1Mem3:
                    
                    CMP selectedOp2Size, 8
                    JZ AdcOp1Mem3_Op2_8Bit
                    CALL GetSrcOp
                    CLC
                    CALL GetCF
                    ADC WORD PTR ValMem+3, AX
                    CALL SetCF

                    AdcOp1Mem3_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        CLC
                        CALL GetCF
                        ADC ValMem+3, AL 
                        CALL SetCF
                    JMP Exit
                AdcOp1Mem4:

                    CMP selectedOp2Size, 8
                    JZ AdcOp1Mem4_Op2_8Bit
                    CALL GetSrcOp
                    CLC
                    CALL GetCF
                    ADC WORD PTR ValMem+4, AX
                    CALL SetCF

                    AdcOp1Mem4_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        CLC
                        CALL GetCF
                        ADC ValMem+4, AL 
                        CALL SetCF 
                    JMP Exit
                AdcOp1Mem5:

                    CMP selectedOp2Size, 8
                    JZ AdcOp1Mem5_Op2_8Bit
                    CALL GetSrcOp
                    CLC
                    CALL GetCF
                    ADC WORD PTR ValMem+5, AX
                    CALL SetCF

                    AdcOp1Mem5_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        CLC
                        CALL GetCF
                        ADC ValMem+5, AL 
                        CALL SetCF
                    JMP Exit
                AdcOp1Mem6:

                    CMP selectedOp2Size, 8
                    JZ AdcOp1Mem6_Op2_8Bit
                    CALL GetSrcOp
                    CLC
                    CALL GetCF
                    ADC WORD PTR ValMem+6, AX
                    CALL SetCF

                    AdcOp1Mem6_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        CLC
                        CALL GetCF
                        ADC ValMem+6, AL 
                        CALL SetCF
                    JMP Exit
                AdcOp1Mem7:

                    CMP selectedOp2Size, 8
                    JZ AdcOp1Mem7_Op2_8Bit
                    CALL GetSrcOp
                    CLC
                    CALL GetCF
                    ADC WORD PTR ValMem+7, AX
                    CALL SetCF

                    AdcOp1Mem7_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        CLC
                        CALL GetCF
                        ADC ValMem+7, AL 
                        CALL SetCF 
                    JMP Exit
                AdcOp1Mem8:

                    CMP selectedOp2Size, 8
                    JZ AdcOp1Mem8_Op2_8Bit
                    CALL GetSrcOp
                    CLC
                    CALL GetCF
                    ADC WORD PTR ValMem+8, AX
                    CALL SetCF

                    AdcOp1Mem8_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        CLC
                        CALL GetCF
                        ADC ValMem+8, AL 
                        CALL SetCF
                    JMP Exit
                AdcOp1Mem9:

                    CMP selectedOp2Size, 8
                    JZ AdcOp1Mem9_Op2_8Bit
                    CALL GetSrcOp
                    CLC
                    CALL GetCF
                    ADC WORD PTR ValMem+9, AX
                    CALL SetCF

                    AdcOp1Mem9_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        CLC
                        CALL GetCF
                        ADC ValMem+9, AL 
                        CALL SetCF 
                    JMP Exit
                AdcOp1Mem10:

                    CMP selectedOp2Size, 8
                    JZ AdcOp1Mem10_Op2_8Bit
                    CALL GetSrcOp
                    CLC
                    CALL GetCF
                    ADC WORD PTR ValMem+10, AX
                    CALL SetCF

                    AdcOp1Mem10_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        CLC
                        CALL GetCF
                        ADC ValMem+10, AL 
                        CALL SetCF 
                    JMP Exit
                AdcOp1Mem11:

                    CMP selectedOp2Size, 8
                    JZ AdcOp1Mem11_Op2_8Bit
                    CALL GetSrcOp
                    CLC
                    CALL GetCF
                    ADC WORD PTR ValMem+11, AX
                    CALL SetCF

                    AdcOp1Mem11_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        CLC
                        CALL GetCF
                        ADC ValMem+11, AL 
                        CALL SetCF 
                    JMP Exit
                AdcOp1Mem12:

                    CMP selectedOp2Size, 8
                    JZ AdcOp1Mem12_Op2_8Bit
                    CALL GetSrcOp
                    CLC
                    CALL GetCF
                    ADC WORD PTR ValMem+12, AX
                    CALL SetCF

                    AdcOp1Mem12_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        CLC
                        CALL GetCF
                        ADC ValMem+12, AL 
                        CALL SetCF
                    JMP Exit
                AdcOp1Mem13:

                    CMP selectedOp2Size, 8
                    JZ AdcOp1Mem13_Op2_8Bit
                    CALL GetSrcOp
                    CLC
                    CALL GetCF
                    ADC WORD PTR ValMem+13, AX
                    CALL SetCF

                    AdcOp1Mem13_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        CLC
                        CALL GetCF
                        ADC ValMem+13, AL 
                        CALL SetCF 
                    JMP Exit
                AdcOp1Mem14:

                    CMP selectedOp2Size, 8
                    JZ AdcOp1Mem14_Op2_8Bit
                    CALL GetSrcOp
                    CLC
                    CALL GetCF
                    ADC WORD PTR ValMem+14, AX
                    CALL SetCF
                    
                    AdcOp1Mem14_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        CLC
                        CALL GetCF
                        ADC ValMem+14, AL 
                        CALL SetCF 
                    JMP Exit
                AdcOp1Mem15:

                    CMP selectedOp2Size, 8
                    JZ AdcOp1Mem15_Op2_8Bit
                    CALL GetSrcOp
                    CLC
                    CALL GetCF
                    ADC WORD PTR ValMem+15, AX
                    CALL SetCF

                    AdcOp1Mem15_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        CLC
                        CALL GetCF
                        ADC ValMem+15, AL 
                        CALL SetCF 
                    JMP Exit

            
            JMP Exit
        PUSH_Comm:

            CALL Op1Menu

            CALL CheckForbidCharProc

            ; Todo - CHECK VALIDATIONS
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

            ; TODO - Mem as operand
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

            
            ; TODO - address reg as operands
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
            ; TODO what happens if invalid operation
            JMP Exit
        
        DIV_Comm:
            CALL Op1Menu
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
            ; TODO what happens if invalid operation
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
            ; TODO what happens if invalid operation
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
            ; TODO what happens if invalid operation
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
            ; TODO what happens when invalid
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
            ; TODO what happens when invalid
            JMP Exit
        
        RCR_Comm:
            CALL Op1Menu
            MOV DX, CommaCursorLoc
            CALL SetCursor
            mov dl, ','
            CALL DisplayChar
            CALL Op2Menu

            CALL CheckForbidCharProc

            ; TODO - Check Validations

            ; TODO - Execute Commands with different Combinations
            JMP Exit
        
        RCL_Comm:
            CALL Op1Menu

            MOV DX, CommaCursorLoc
            CALL SetCursor
            mov dl, ','
            CALL DisplayChar
            CALL Op2Menu

            CALL CheckForbidCharProc

            ; TODO - Check Validations

            ; TODO - Execute Commands with different Combinations
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
            ; TODO what happens when invalid
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
            ; TODO what happens when invalid
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

            
            ; Test Messages
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
        CMP selectedOp1Type, 0
        jz Reg_CheckOp1Size
        
        ; Memory and value is 16-bit addressable
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
        
        ; Memory and value is 16-bit addressable
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


        RET
    ENDP
    GetSrcOp_8Bit PROC    ; Returned Value is saved in AL
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
    END CommMenu