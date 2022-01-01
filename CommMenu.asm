; Macros
    ExecPush MACRO Op
        PUSH Op
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

    ValRegAX dw 0000h
    ValRegBX dw 0000h
    ValRegCX dw 0000h
    ValRegDX dw 0000h
    ValRegBP dw 0000h
    ValRegSP dw 0000h
    ValRegSI dw 0000h
    ValRegDI dw 0000h
    
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
    AddRegSI db '[SI] ','$' ;15
    AddRegDI db '[DI] ','$' ;16

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

    ValMem db 16 dup(00h)
    ValStack db 16 dup(00h)
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
    mesMem db 10, 'You have selected Mem #', '$'
    mesVal db 10, 'You Entered value: ', '$'
    mesTst db 10, 'Yes This is Register Bx', '$'
    error db 13,10,"Error Input",'$'



    selectedComm db -1, '$'

    selectedOp1Type db -1, '$'  
    selectedOp1Reg  db -1, '$'
    selectedOp1AddReg db -1, '$'
    selectedOp1Mem  db -1, '$'
    Op1Val dw 0
    Op1Valid db 1               ; 0 if Invalid 

    selectedOp2Type db -1, '$'
    selectedOp2Reg  db -1, '$'
    selectedOp2AddReg db -1, '$'
    selectedOp2Mem  db -1, '$'
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

            ; TODO - Check Validations

            Mov_invalid:
            ; TODO - What hppens if the command is invalid
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

            ; TODO - EXECUTE COMMAND WITH DIFFERENT OPERANDS
            ; Reg as operands
            PushOpRegAX:
                ExecPush AX
                JMP Exit
            PushOpRegBX:
                ExecPush BX
                JMP Exit
            PushOpRegCX:
                ExecPush CX
                JMP Exit
            PushOpRegDX:
                ExecPush DX
                JMP Exit
            PushOpRegBP:
                ExecPush BP
                JMP Exit
            PushOpRegSP:
                ExecPush SP
                JMP Exit
            PushOpRegSI:
                ExecPush SI
                JMP Exit
            PushOpRegDI:
                ExecPush DI
                JMP Exit

            ; TODO - Mem as operand

            ; TODO - address reg as operands
            
            JMP Exit

        POP_Comm:
            CALL Op1Menu

            ; Todo - CHECK VALIDATIONS

            ; TODO - EXECUTE COMMAND WITH DIFFERENT OPERANDS
            JMP Exit
        
        INC_Comm:
            CALL Op1Menu

            ; Todo - CHECK VALIDATIONS

            ; TODO - EXECUTE COMMAND WITH DIFFERENT OPERANDS
            JMP Exit
        
        DEC_Comm:
            CALL Op1Menu

            ; Todo - CHECK VALIDATIONS

            ; TODO - EXECUTE COMMAND WITH DIFFERENT OPERANDS
            JMP Exit
        
        MUL_Comm:
            CALL Op1Menu
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
                cmp selectedOp1Reg, 12
                je Mul_invalid
                cmp selectedOp1Reg, 13
                je Mul_invalid
                cmp selectedOp1Reg, 14
                je Mul_invalid
                cmp selectedOp1Reg, 15
                je Mul_Bp
                cmp selectedOp1Reg, 16
                je Mul_Sp
                cmp selectedOp1Reg, 17
                je Mul_Si
                cmp selectedOp1Reg, 18
                je Mul_Di
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
                cmp selectedOp1AddReg, 0
                je Mul_invalid
                cmp selectedOp1AddReg, 1
                je Mul_invalid
                cmp selectedOp1AddReg, 2
                je Mul_invalid
                cmp selectedOp1AddReg, 3
                je Mul_AddBx
                cmp selectedOp1AddReg, 4
                je Mul_invalid
                cmp selectedOp1AddReg, 5
                je Mul_invalid
                cmp selectedOp1AddReg, 6
                je Mul_invalid
                cmp selectedOp1AddReg, 7
                je Mul_invalid
                cmp selectedOp1AddReg, 8
                je Mul_invalid
                cmp selectedOp1AddReg, 9
                je Mul_invalid
                cmp selectedOp1AddReg, 10
                je Mul_invalid
                cmp selectedOp1AddReg, 11
                je Mul_invalid
                cmp selectedOp1AddReg, 12
                je Mul_invalid
                cmp selectedOp1AddReg, 13
                je Mul_invalid
                cmp selectedOp1AddReg, 14
                je Mul_invalid
                cmp selectedOp1AddReg, 15
                je Mul_AddSi
                cmp selectedOp1AddReg, 16
                je Mul_AddDi
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
                je Div_AddSi
                cmp selectedOp1AddReg, 16
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
                cmp selectedOp1Reg, 12
                je IMul_invalid
                cmp selectedOp1Reg, 13
                je IMul_invalid
                cmp selectedOp1Reg, 14
                je IMul_invalid
                cmp selectedOp1Reg, 15
                je IMul_Bp
                cmp selectedOp1Reg, 16
                je IMul_Sp
                cmp selectedOp1Reg, 17
                je IMul_Si
                cmp selectedOp1Reg, 18
                je IMul_Di
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
                cmp selectedOp1AddReg, 0
                je IMul_invalid
                cmp selectedOp1AddReg, 1
                je IMul_invalid
                cmp selectedOp1AddReg, 2
                je IMul_invalid
                cmp selectedOp1AddReg, 3
                je IMul_AddBx
                cmp selectedOp1AddReg, 4
                je IMul_invalid
                cmp selectedOp1AddReg, 5
                je IMul_invalid
                cmp selectedOp1AddReg, 6
                je IMul_invalid
                cmp selectedOp1AddReg, 7
                je IMul_invalid
                cmp selectedOp1AddReg, 8
                je IMul_invalid
                cmp selectedOp1AddReg, 9
                je IMul_invalid
                cmp selectedOp1AddReg, 10
                je IMul_invalid
                cmp selectedOp1AddReg, 11
                je IMul_invalid
                cmp selectedOp1AddReg, 12
                je IMul_invalid
                cmp selectedOp1AddReg, 13
                je IMul_invalid
                cmp selectedOp1AddReg, 14
                je IMul_invalid
                cmp selectedOp1AddReg, 15
                je IMul_AddSi
                cmp selectedOp1AddReg, 16
                je IMul_AddDi
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
                cmp selectedOp1Reg, 12
                je IDiv_invalid
                cmp selectedOp1Reg, 13
                je IDiv_invalid
                cmp selectedOp1Reg, 14
                je IDiv_invalid
                cmp selectedOp1Reg, 15
                je IDiv_Bp
                cmp selectedOp1Reg, 16
                je IDiv_Sp
                cmp selectedOp1Reg, 17
                je IDiv_Si
                cmp selectedOp1Reg, 18
                je IDiv_Di
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
                cmp selectedOp1AddReg, 0
                je IDiv_invalid
                cmp selectedOp1AddReg, 1
                je IDiv_invalid
                cmp selectedOp1AddReg, 2
                je IDiv_invalid
                cmp selectedOp1AddReg, 3
                je IDiv_AddBx
                cmp selectedOp1AddReg, 4
                je IDiv_invalid
                cmp selectedOp1AddReg, 5
                je IDiv_invalid
                cmp selectedOp1AddReg, 6
                je IDiv_invalid
                cmp selectedOp1AddReg, 7
                je IDiv_invalid
                cmp selectedOp1AddReg, 8
                je IDiv_invalid
                cmp selectedOp1AddReg, 9
                je IDiv_invalid
                cmp selectedOp1AddReg, 10
                je IDiv_invalid
                cmp selectedOp1AddReg, 11
                je IDiv_invalid
                cmp selectedOp1AddReg, 12
                je IDiv_invalid
                cmp selectedOp1AddReg, 13
                je IDiv_invalid
                cmp selectedOp1AddReg, 14
                je IDiv_invalid
                cmp selectedOp1AddReg, 15
                je IDiv_AddSi
                cmp selectedOp1AddReg, 16
                je IDiv_AddDi
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
                je ROR_AddSi
                cmp selectedOp1AddReg,16
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
                je ROL_AddSi
                cmp selectedOp1AddReg,16
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
            MOV DX, CommaCursorLoc
            CALL SetCursor
            mov dl, ','
            CALL DisplayChar
            CALL Op2Menu
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
                je SHL_AddSi
                cmp selectedOp1AddReg,16
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
                je SHR_AddSi
                cmp selectedOp1AddReg,16
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


        Exit:
            
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
            mov dx, offset NOPcom
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


        ; NEEDS TO CHANGE 
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


        ; NEEDS TO CHANGE 
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

            RET
    Op2Menu ENDP
    END CommMenu