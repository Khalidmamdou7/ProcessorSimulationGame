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
    
    RegAX db 'AX   ','$'
    RegAL db 'AL   ','$'                
    RegAH db 'AH   ','$'  
    RegBX db 'BX   ','$'   
    RegBL db 'BL   ','$'    
    RegBH db 'BH   ','$'
    RegCX db 'CX   ','$'                
    RegCL db 'CL   ','$'  
    RegCH db 'CH   ','$'   
    RegDX db 'DX   ','$'
    RegDL db 'DL   ','$'
    RegDH db 'DH   ','$'                
    RegSX db 'SX   ','$'  
    RegSL db 'SL   ','$'   
    RegSH db 'SH   ','$'
    RegBP db 'BP   ','$'
    RegSP db 'SP   ','$'
    RegSI db 'SI   ','$'
    RegDI db 'DI   ','$'

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
    AddRegAH db '[AH] ','$'  
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
    AddRegBP db '[BP] ','$'
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
    ValCF db 0d
    
    ; Operand Value Needed Variables
    ClearSpace db '     ', '$'
    num db 30,?,30 DUP(?)       
    StrSize db ?
    num2 db 30,?,30 DUP(?)       
    StrSize2 db ?
    a EQU 1000
    B EQU 100
    C EQU 10

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
        cmp selectedComm, 14
        JZ SHL_Comm
        cmp selectedComm, 15
        JZ SHR_Comm

        JMP TODO_Comm
        ; Continue comparing for all operations


        ; Commands (operations) Labels
        NOP_Comm:
            ; Execute Command
            NOP
            JMP Exit
        
        CLC_Comm:
            CLC
            JMP Exit
        
        MOV_Comm:
            CALL Op1Menu
            MOV DX, CommaCursorLoc
            CALL SetCursor
            mov dl, ','
            CALL DisplayChar
            CALL Op2Menu

            
            CMP selectedOp1Type, 0
            JZ MovOp1Reg
            CMP selectedOp1Type, 1
            JZ MovOp1AddReg
            CMP selectedOp1Type, 2
            JZ MovOp1Mem
            JMP InValidCommand

            MovOp1Reg:
                CMP selectedOp1Reg, 0
                JZ MovOp1RegAX
                CMP selectedOp1Reg, 1
                JZ MovOp1RegAL
                CMP selectedOp1Reg, 2
                JZ MovOp1RegAH
                CMP selectedOp1Reg, 3
                JZ MovOp1RegBX
                CMP selectedOp1Reg, 4
                JZ MovOp1RegBL
                CMP selectedOp1Reg, 5
                JZ MovOp1RegBH
                CMP selectedOp1Reg, 6
                JZ MovOp1RegCX
                CMP selectedOp1Reg, 7
                JZ MovOp1RegCL
                CMP selectedOp1Reg, 8
                JZ MovOp1RegCH
                CMP selectedOp1Reg, 9
                JZ MovOp1RegDX
                CMP selectedOp1Reg, 10
                JZ MovOp1RegDL
                CMP selectedOp1Reg, 11
                JZ MovOp1RegDH

                CMP selectedOp1Reg, 15
                JZ MovOp1RegBP
                CMP selectedOp1Reg, 16
                JZ MovOp1RegSP
                CMP selectedOp1Reg, 17
                JZ MovOp1RegSI
                CMP selectedOp1Reg, 18
                JZ MovOp1RegDI
                

                JMP InValidCommand

                MovOp1RegAX:
                    CALL GetSrcOp
                    MOV ValRegAX, AX
                    JMP Exit
                MovOp1RegAL:
                    CALL GetSrcOp_8Bit
                    MOV BYTE PTR ValRegAX, AL
                    JMP Exit
                MovOp1RegAH:
                    CALL GetSrcOp_8Bit
                    MOV BYTE PTR ValRegAX+1, AL
                    JMP Exit
                MovOp1RegBX:
                    CALL GetSrcOp
                    MOV ValRegBX, AX
                    JMP Exit
                MovOp1RegBL:
                    CALL GetSrcOp_8Bit
                    MOV BYTE PTR ValRegBX, AL
                    JMP Exit
                MovOp1RegBH:
                    CALL GetSrcOp_8Bit
                    MOV BYTE PTR ValRegBX+1, AL
                    JMP Exit
                MovOp1RegCX:
                    CALL GetSrcOp
                    MOV ValRegCX, AX
                    JMP Exit
                MovOp1RegCL:
                    CALL GetSrcOp_8Bit
                    MOV BYTE PTR ValRegCX, AL
                    JMP Exit
                MovOp1RegCH:
                    CALL GetSrcOp_8Bit
                    MOV BYTE PTR ValRegCX+1, AL
                    JMP Exit
                MovOp1RegDX:
                    CALL GetSrcOp
                    MOV ValRegDX, AX
                    JMP Exit
                MovOp1RegDL:
                    CALL GetSrcOp_8Bit
                    MOV BYTE PTR ValRegDX, AL
                    JMP Exit
                MovOp1RegDH:
                    CALL GetSrcOp_8Bit
                    MOV BYTE PTR ValRegDX+1, AL
                    JMP Exit
                MovOp1RegBP:
                    CALL GetSrcOp
                    MOV ValRegBP, AX
                    JMP Exit
                MovOp1RegSP:
                    CALL GetSrcOp
                    MOV ValRegSP, AX
                    JMP Exit
                MovOp1RegSI:
                    CALL GetSrcOp
                    MOV ValRegSI, AX
                    JMP Exit
                MovOp1RegDI:
                    CALL GetSrcOp
                    MOV ValRegDI, AX
                    JMP Exit

            MovOp1AddReg:

                ; Check Memory-to-Memory operations
                CMP selectedOp2Type, 1
                JZ InValidCommand
                CMP selectedOp2Type, 2
                jz InValidCommand

                CMP selectedOp1AddReg, 3
                JZ MovOp1AddRegBX
                CMP selectedOp1AddReg, 15
                JZ MovOp1AddRegBP
                CMP selectedOp1AddReg, 17
                JZ MovOp1AddRegSI
                CMP selectedOp1AddReg, 18
                JZ MovOp1AddRegDI
                JMP InValidCommand

                MovOp1AddRegBX:

                    mov dx, ValRegBX
                    CALL CheckAddress
                    cmp bl, 1               ; Value is greater than 16
                    JZ InValidCommand

                    CMP selectedOp2Size, 8
                    jz MovOp1AddRegBX_Op2_8Bit 
                    CALL GetSrcOp
                    mov SI, ValRegBX
                    MOV WORD PTR ValMem[SI], AX
                    JMP Exit
                    MovOp1AddRegBX_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        MOV SI, ValRegBX
                        MOV ValMem[SI], AL
                    JMP Exit
                MovOp1AddRegBP:
                    mov dx, ValRegBP
                    CALL CheckAddress
                    cmp bl, 1               ; Value is greater than 16
                    JZ InValidCommand

                    CMP selectedOp2Size, 8
                    jz MovOp1AddRegBP_Op2_8Bit 
                    CALL GetSrcOp
                    mov SI, ValRegBP
                    MOV WORD PTR ValMem[SI], AX
                    JMP Exit
                    MovOp1AddRegBP_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        MOV SI, ValRegBP
                        MOV ValMem[SI], AL
                    JMP Exit

                MovOp1AddRegSI:
                    mov dx, ValRegSI
                    CALL CheckAddress
                    cmp bl, 1               ; Value is greater than 16
                    JZ InValidCommand

                    CMP selectedOp2Size, 8
                    jz MovOp1AddRegSI_Op2_8Bit 
                    CALL GetSrcOp
                    mov SI, ValRegSI
                    MOV WORD PTR ValMem[SI], AX
                    JMP Exit
                    MovOp1AddRegSI_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        MOV SI, ValRegSI
                        MOV ValMem[SI], AL
                    JMP Exit
                
                MovOp1AddRegDI:
                    mov dx, ValRegDI
                    CALL CheckAddress
                    cmp bl, 1               ; Value is greater than 16
                    JZ InValidCommand

                    CMP selectedOp2Size, 8
                    jz MovOp1AddRegDI_Op2_8Bit 
                    CALL GetSrcOp
                    mov SI, ValRegDI
                    MOV WORD PTR ValMem[SI], AX
                    JMP Exit
                    MovOp1AddRegDI_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        MOV SI, ValRegDI
                        MOV ValMem[SI], AL
                    JMP Exit

            MovOp1Mem:
                
                CMP selectedOp1Mem, 0
                JZ MovOp1Mem0
                CMP selectedOp1Mem, 1
                JZ MovOp1Mem1
                CMP selectedOp1Mem, 2
                JZ MovOp1Mem2
                CMP selectedOp1Mem, 3
                JZ MovOp1Mem3
                CMP selectedOp1Mem, 4
                JZ MovOp1Mem4
                CMP selectedOp1Mem, 5
                JZ MovOp1Mem5
                CMP selectedOp1Mem, 6
                JZ MovOp1Mem6
                CMP selectedOp1Mem, 7
                JZ MovOp1Mem7
                CMP selectedOp1Mem, 8
                JZ MovOp1Mem8
                CMP selectedOp1Mem, 9
                JZ MovOp1Mem9
                CMP selectedOp1Mem, 10
                JZ MovOp1Mem10
                CMP selectedOp1Mem, 11
                JZ MovOp1Mem11
                CMP selectedOp1Mem, 12
                JZ MovOp1Mem12
                CMP selectedOp1Mem, 13
                JZ MovOp1Mem13
                CMP selectedOp1Mem, 14
                JZ MovOp1Mem14
                CMP selectedOp1Mem, 15
                JZ MovOp1Mem15
                JMP InValidCommand
                
                MovOp1Mem0:
                    CMP selectedOp2Size, 8
                    JZ MovOp1Mem0_Op2_8Bit
                    CALL GetSrcOp
                    MOV WORD PTR ValMem, AX

                    MovOp1Mem0_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        MOV ValMem, AL 
                    JMP Exit
                MovOp1Mem1:
                   CMP selectedOp2Size, 8
                    JZ MovOp1Mem1_Op2_8Bit
                    CALL GetSrcOp
                    MOV WORD PTR ValMem+1, AX

                    MovOp1Mem1_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        MOV ValMem+1, AL 
                    JMP Exit
                MovOp1Mem2:
                    CMP selectedOp2Size, 8
                    JZ MovOp1Mem2_Op2_8Bit
                    CALL GetSrcOp
                    MOV WORD PTR ValMem+2, AX

                    MovOp1Mem2_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        MOV ValMem+2, AL 
                    JMP Exit
                MovOp1Mem3:
                    CMP selectedOp2Size, 8
                    JZ MovOp1Mem3_Op2_8Bit
                    CALL GetSrcOp
                    MOV WORD PTR ValMem+3, AX

                    MovOp1Mem3_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        MOV ValMem+3, AL 
                    JMP Exit
                MovOp1Mem4:
                    CMP selectedOp2Size, 8
                    JZ MovOp1Mem4_Op2_8Bit
                    CALL GetSrcOp
                    MOV WORD PTR ValMem+4, AX

                    MovOp1Mem4_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        MOV ValMem+4, AL 
                    JMP Exit
                MovOp1Mem5:
                    CMP selectedOp2Size, 8
                    JZ MovOp1Mem5_Op2_8Bit
                    CALL GetSrcOp
                    MOV WORD PTR ValMem+5, AX

                    MovOp1Mem5_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        MOV ValMem+5, AL 
                    JMP Exit
                MovOp1Mem6:
                    CMP selectedOp2Size, 8
                    JZ MovOp1Mem6_Op2_8Bit
                    CALL GetSrcOp
                    MOV WORD PTR ValMem+6, AX

                    MovOp1Mem6_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        MOV ValMem+6, AL 
                    JMP Exit
                MovOp1Mem7:
                    CMP selectedOp2Size, 8
                    JZ MovOp1Mem7_Op2_8Bit
                    CALL GetSrcOp
                    MOV WORD PTR ValMem+7, AX

                    MovOp1Mem7_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        MOV ValMem+7, AL 
                    JMP Exit
                MovOp1Mem8:
                    CMP selectedOp2Size, 8
                    JZ MovOp1Mem8_Op2_8Bit
                    CALL GetSrcOp
                    MOV WORD PTR ValMem+8, AX

                    MovOp1Mem8_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        MOV ValMem+8, AL 
                    JMP Exit
                MovOp1Mem9:
                    CMP selectedOp2Size, 8
                    JZ MovOp1Mem9_Op2_8Bit
                    CALL GetSrcOp
                    MOV WORD PTR ValMem+9, AX

                    MovOp1Mem9_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        MOV ValMem+9, AL 
                    JMP Exit
                MovOp1Mem10:
                    CMP selectedOp2Size, 8
                    JZ MovOp1Mem10_Op2_8Bit
                    CALL GetSrcOp
                    MOV WORD PTR ValMem+10, AX

                    MovOp1Mem10_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        MOV ValMem+10, AL 
                    JMP Exit
                MovOp1Mem11:
                    CMP selectedOp2Size, 8
                    JZ MovOp1Mem11_Op2_8Bit
                    CALL GetSrcOp
                    MOV WORD PTR ValMem+11, AX

                    MovOp1Mem11_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        MOV ValMem+11, AL 
                    JMP Exit
                MovOp1Mem12:
                    CMP selectedOp2Size, 8
                    JZ MovOp1Mem12_Op2_8Bit
                    CALL GetSrcOp
                    MOV WORD PTR ValMem+12, AX

                    MovOp1Mem12_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        MOV ValMem+12, AL 
                    JMP Exit
                MovOp1Mem13:
                    CMP selectedOp2Size, 8
                    JZ MovOp1Mem13_Op2_8Bit
                    CALL GetSrcOp
                    MOV WORD PTR ValMem+13, AX

                    MovOp1Mem13_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        MOV ValMem+13, AL 
                    JMP Exit
                MovOp1Mem14:
                    CMP selectedOp2Size, 8
                    JZ MovOp1Mem14_Op2_8Bit
                    CALL GetSrcOp
                    MOV WORD PTR ValMem+14, AX
                    
                    MovOp1Mem14_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        MOV ValMem+14, AL 
                    JMP Exit
                MovOp1Mem15:
                    CMP selectedOp2Size, 8
                    JZ MovOp1Mem15_Op2_8Bit
                    CALL GetSrcOp
                    MOV WORD PTR ValMem+15, AX

                    MovOp1Mem15_Op2_8Bit:
                        CALL GetSrcOp_8Bit
                        MOV ValMem+15, AL 
                    JMP Exit

            
            JMP Exit

        ADD_Comm:
            CALL Op1Menu

            ; TODO - Check Validations

            MOV DX, CommaCursorLoc
            CALL SetCursor
            mov dl, ','
            CALL DisplayChar
            CALL Op2Menu

            ; TODO - Check Validations

            ; TODO - Execute Commands with different Combinations
            JMP Exit
        
        PUSH_Comm:
            CALL Op1Menu

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
                    ExecPush ValRegAX
                    JMP Exit
                PushOpRegBX:
                    ExecPush ValRegBX
                    JMP Exit
                PushOpRegCX:
                    ExecPush ValRegCX
                    JMP Exit
                PushOpRegDX:
                    ExecPush ValRegDX
                    JMP Exit
                PushOpRegBP:
                    ExecPush ValRegBP
                    JMP Exit
                PushOpRegSP:
                    ExecPush ValRegSP
                    JMP Exit
                PushOpRegSI:
                    ExecPush ValRegSI
                    JMP Exit
                PushOpRegDI:
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
                    ExecPushMem ValMem
                    JMP Exit
                PushOpMem1:
                    ExecPushMem ValMem+1
                    JMP Exit
                PushOpMem2:
                    ExecPushMem ValMem+2
                    JMP Exit
                PushOpMem3:
                    ExecPushMem ValMem+3
                    JMP Exit
                PushOpMem4:
                    ExecPushMem ValMem+4
                    JMP Exit
                PushOpMem5:
                    ExecPushMem ValMem+5
                    JMP Exit
                PushOpMem6:
                    ExecPushMem ValMem+6
                    JMP Exit
                PushOpMem7:
                    ExecPushMem ValMem+7
                    JMP Exit
                PushOpMem8:
                    ExecPushMem ValMem+8
                    JMP Exit
                PushOpMem9:
                    ExecPushMem ValMem+9
                    JMP Exit
                PushOpMem10:
                    ExecPushMem ValMem+10
                    JMP Exit
                PushOpMem11:
                    ExecPushMem ValMem+11
                    JMP Exit
                PushOpMem12:
                    ExecPushMem ValMem+12
                    JMP Exit
                PushOpMem13:
                    ExecPushMem ValMem+13
                    JMP Exit
                PushOpMem14:
                    ExecPushMem ValMem+14
                    JMP Exit
                PushOpMem15:
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

            ; Todo - CHECK VALIDATIONS

            ; TODO - EXECUTE COMMAND WITH DIFFERENT OPERANDS
            JMP Exit
        
        DIV_Comm:
            CALL Op1Menu

            ; Todo - CHECK VALIDATIONS

            ; TODO - EXECUTE COMMAND WITH DIFFERENT OPERANDS
            JMP Exit
        
        ROR_Comm:
            CALL Op1Menu

            ; TODO - Check Validations

            MOV DX, CommaCursorLoc
            CALL SetCursor
            mov dl, ','
            CALL DisplayChar
            CALL Op2Menu

            ; TODO - Check Validations

            ; TODO - Execute Commands with different Combinations
            ;jmp Exit
        
        ROL_Comm:
            CALL Op1Menu

            ; TODO - Check Validations

            MOV DX, CommaCursorLoc
            CALL SetCursor
            mov dl, ','
            CALL DisplayChar
            CALL Op2Menu

            ; TODO - Check Validations

            ; TODO - Execute Commands with different Combinations
            JMP Exit
        
        RCR_Comm:
            CALL Op1Menu

            ; TODO - Check Validations

            MOV DX, CommaCursorLoc
            CALL SetCursor
            mov dl, ','
            CALL DisplayChar
            CALL Op2Menu

            ; TODO - Check Validations

            ; TODO - Execute Commands with different Combinations
            JMP Exit
        
        RCL_Comm:
            CALL Op1Menu

            ; TODO - Check Validations

            MOV DX, CommaCursorLoc
            CALL SetCursor
            mov dl, ','
            CALL DisplayChar
            CALL Op2Menu

            ; TODO - Check Validations

            ; TODO - Execute Commands with different Combinations
            JMP Exit

        SHL_Comm:
            CALL Op1Menu

            ; TODO - Check Validations

            MOV DX, CommaCursorLoc
            CALL SetCursor
            mov dl, ','
            CALL DisplayChar
            CALL Op2Menu

            ; TODO - Check Validations

            ; TODO - Execute Commands with different Combinations
            JMP Exit
        
        SHR_Comm:
            CALL Op1Menu

            ; TODO - Check Validations

            MOV DX, CommaCursorLoc
            CALL SetCursor
            mov dl, ','
            CALL DisplayChar
            CALL Op2Menu

            ; TODO - Check Validations

            ; TODO - Execute Commands with different Combinations
            JMP Exit
        
        TODO_Comm:
            mov dx, offset error
            CALL DisplayString
            JMP Exit
        
        InValidCommand:
            mov dx, offset error
            CALL DisplayString

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
            jmp hoop2
            
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
            jmp hoop2_Op2Menu
            
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
    
    END CommMenu