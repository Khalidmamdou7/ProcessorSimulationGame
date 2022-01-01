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


    ValRegAX dw 0000h 
    ValRegBX dw 0000h   
    ValRegCX dw 0000h                  
    ValRegDX dw 0000h                
    ValRegBP dw 0000h
    ValRegSP dw 0000h
    ValRegSI dw 0000h
    ValRegDI dw 0000h
    
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

            ; TODO - Check Validations

            ; TODO - Execute Commands with different Combinations
            
            JMP Exit

        ADD_Comm:
            CALL Op1Menu

            MOV DX, CommaCursorLoc
            CALL SetCursor
            mov dl, ','
            CALL DisplayChar
            CALL Op2Menu

            cmp selectedOp1Type,0 ; check for Op1 Reg
            jne notthiscom1

            cmp selectedOp1Reg,0 ; check for Ax
            jne notax

            cmp selectedOp2Type,3 ; check for Op2 Value
            jne Notvalue
            addal:
            mov ax,Op2Val
            add ValRegAX,ax
            jmp Exit
            Notvalue:

            cmp selectedOp2Type,2 ;check for Memory
            jne Notmem1
            mov si,0
            SearchForMem1:
            mov cx,si
            mov ch,0h 
            cmp selectedOp2Mem,cl
            jne notit1
            mov ax,word ptr ValMem[si]
            add ValRegAX,ax
            jmp Exit 
            notit1:
            inc si 
            jmp SearchForMem1
            Notmem1:

            cmp selectedOp2Type,1 ;check for addresing
            jne Notaddmem

            cmp selectedOp2AddReg,3 ; check for bx
            jne notaddbx
            cmp ValRegBX,0FH
            jg NotValidAddress
            mov si,ValRegBX
            mov ax,word ptr ValMem[si]
            add ValRegAX,ax
            jmp Exit
            notaddbx:

            cmp selectedOp2AddReg,15 ; check for SI
            jne notaddSI
            cmp ValRegSI,0FH
            jg NotValidAddress
            mov si,ValRegSI
            mov ax,word ptr ValMem[si]
            add ValRegAX,ax
            jmp Exit
            notaddSI:

            cmp selectedOp2AddReg,16 ; check for DI
            jne notaddDI
            cmp ValRegDI,0FH
            jg NotValidAddress
            mov si,ValRegDI
            mov ax,word ptr ValMem[si]
            add ValRegAX,ax
            jmp Exit
            notaddDI:

            cmp selectedOp2AddReg,2 ; check for BP
            jne notaddBP
            cmp ValRegBP,0FH
            jg NotValidAddress
            mov si,ValRegBP
            mov ax,word ptr ValMem[si]
            add ValRegAX,ax
            jmp Exit
            notaddBP:

            Notaddmem:

            cmp selectedOp2Type,0 ; check for Register
            jne NotReg
            cmp selectedOp2Reg,0 ; check for operand 2 ax
            jne notax2
            mov ax,ValRegAX
            add ValRegAX,ax
            jmp Exit
            notax2:

            cmp selectedOp2Reg,3 ; check for operand 2 bx
            jne notbx2
            mov ax,ValRegBX
            add ValRegAX,ax
            jmp Exit
            notbx2:

            cmp selectedOp2Reg,6 ; check for operand 2 cx
            jne notcx2
            mov ax,ValRegCX
            add ValRegAX,ax
            jmp Exit
            notcx2:

            cmp selectedOp2Reg,9 ; check for operand 2 dx
            jne notdx2
            mov ax,ValRegDX
            add ValRegAX,ax
            jmp Exit
            notdx2:
            NotReg:
            jmp NotValidAddress
            ; display error message
            NotValidAddress:
            mov ah, 9               
            mov dx, offset error
            int 21h
            jmp InValidCommand

notax:      
            cmp selectedOp1Reg,3 ; check for Bx
            jne NotBx

            cmp selectedOp2Type,3 ; check for Op2 Value
            jne Notvalue2
            mov ax,Op2Val
            add ValRegBX,ax
            jmp Exit
            Notvalue2:
           
            cmp selectedOp2Type,2 ;check for Memory
            jne Notmem2
            mov si,0
            SearchForMem2:
            mov cx,si
            mov ch,0h 
            cmp selectedOp2Mem,cl
            jne notit2
            mov ax,word ptr ValMem[si]
            add ValRegBX,ax
            jmp Exit 
            notit2:
            inc si 
            jmp SearchForMem2
            Notmem2:

            cmp selectedOp2Type,1 ;check for addresing
            jne Notaddmem2

            cmp selectedOp2AddReg,3 ; check for bx
            jne notaddbx2
            cmp ValRegBX,0FH
            jg NotValidAddress
            mov si,ValRegBX
            mov ax,word ptr ValMem[si]
            add ValRegBX,ax
            jmp Exit
            notaddbx2:

            cmp selectedOp2AddReg,15 ; check for SI
            jne notaddSI2
            cmp ValRegSI,0FH
            jg NotValidAddress
            mov si,ValRegSI
            mov ax,word ptr ValMem[si]
            add ValRegBX,ax
            jmp Exit
            notaddSI2:

            cmp selectedOp2AddReg,16 ; check for DI
            jne notaddDI2
            cmp ValRegDI,0FH
            jg NotValidAddress
            mov si,ValRegDI
            mov ax,word ptr ValMem[si]
            add ValRegBX,ax
            jmp Exit
            notaddDI2:

            cmp selectedOp2AddReg,2 ; check for BP
            jne notaddBP2
            cmp ValRegBP,0FH
            jg NotValidAddress
            mov si,ValRegBP
            mov ax,word ptr ValMem[si]
            add ValRegBX,ax
            jmp Exit
            notaddBP2:

            Notaddmem2:

            cmp selectedOp2Type,0 ; check for Register
            jne NotReg2
            cmp selectedOp2Reg,0 ; check for operand 2 ax
            jne notax3
            mov ax,ValRegAX
            add ValRegBX,ax
            jmp Exit
            notax3:

            cmp selectedOp2Reg,3 ; check for operand 2 bx
            jne notbx3
            mov ax,ValRegBX
            add ValRegBX,ax
            jmp Exit
            notbx3:

            cmp selectedOp2Reg,6 ; check for operand 2 cx
            jne notcx3
            mov ax,ValRegCX
            add ValRegBX,ax
            jmp Exit
            notcx3:

            cmp selectedOp2Reg,9 ; check for operand 2 dx
            jne notdx3
            mov ax,ValRegDX
            add ValRegBX,ax
            jmp Exit
            notdx3:
            NotReg2:

            jmp NotValidAddress
NotBx:
             cmp selectedOp1Reg,6 ; check for Cx
            jne NotCx

            cmp selectedOp2Type,3 ; check for Op2 Value
            jne Notvalue3
            mov ax,Op2Val
            add ValRegCX,ax
            jmp Exit
            Notvalue3:

            cmp selectedOp2Type,2 ;check for Memory
            jne Notmem3
            mov si,0
            SearchForMem3:
            mov cx,si
            mov ch,0h 
            cmp selectedOp2Mem,cl
            jne notit3
            mov ax,word ptr ValMem[si]
            add ValRegCX,ax
            jmp Exit 
            notit3:
            inc si 
            jmp SearchForMem3
            Notmem3:

            cmp selectedOp2Type,1 ;check for addresing
            jne Notaddmem3

            cmp selectedOp2AddReg,3 ; check for bx
            jne notaddbx3
            cmp ValRegBX,0FH
            jg NotValidAddress
            mov si,ValRegBX
            mov ah,0
            mov al,ValMem[si]
            add ValRegCX,ax
            jmp Exit
            notaddbx3:

            cmp selectedOp2AddReg,15 ; check for SI
            jne notaddSI2
            cmp ValRegSI,0FH
            jg NotValidAddress
            mov si,ValRegSI
            mov ax,word ptr ValMem[si]
            add ValRegCX,ax
            jmp Exit
            notaddSI3:

            cmp selectedOp2AddReg,16 ; check for DI
            jne notaddDI3
            cmp ValRegDI,0FH
            jg NotValidAddress
            mov si,ValRegDI
            mov ax,word ptr ValMem[si]
            add ValRegCX,ax
            jmp Exit
            notaddDI3:

            cmp selectedOp2AddReg,2 ; check for BP
            jne notaddBP3
            cmp ValRegBP,0FH
            jg NotValidAddress
            mov si,ValRegBP
            mov ax,word ptr ValMem[si]
            add ValRegCX,ax
            jmp Exit
            notaddBP3:

            Notaddmem3:

            cmp selectedOp2Type,0 ; check for Register
            jne NotReg3
            cmp selectedOp2Reg,0 ; check for operand 2 ax
            jne notax4
            mov ax,ValRegAX
            add ValRegCX,ax
            jmp Exit
            notax4:

            cmp selectedOp2Reg,3 ; check for operand 2 bx
            jne notbx4
            mov ax,ValRegBX
            add ValRegCX,ax
            jmp Exit
            notbx4:

            cmp selectedOp2Reg,6 ; check for operand 2 cx
            jne notcx4
            mov ax,ValRegCX
            add ValRegCX,ax
            jmp Exit
            notcx4:

            cmp selectedOp2Reg,9 ; check for operand 2 dx
            jne notdx4
            mov ax,ValRegDX
            add ValRegCX,ax
            jmp Exit
            notdx4:
            NotReg3:

            jmp NotValidAddress
NotCx:
            cmp selectedOp1Reg,9 ; check for Dx
            jne NotDx

            cmp selectedOp2Type,3 ; check for Op2 Value
            jne Notvalue4
            mov ax,Op2Val
            add ValRegDX,ax
            jmp Exit
            Notvalue4:

            cmp selectedOp2Type,2 ;check for Memory
            jne Notmem
            mov si,0
            SearchForMem:
            mov cx,si
            mov ch,0h 
            cmp selectedOp2Mem,cl
            jne notit
            mov ax,word ptr ValMem[si]
            add ValRegDX,ax
            jmp Exit 
            notit:
            inc si 
            jmp SearchForMem
            Notmem:

            cmp selectedOp2Type,1 ;check for addresing
            jne Notaddmem4

            cmp selectedOp2AddReg,3 ; check for bx
            jne notaddbx4
            cmp ValRegBX,0FH
            jg NotValidAddress
            mov si,ValRegBX
            mov ax,word ptr ValMem[si]
            add ValRegDX,ax
            jmp Exit
            notaddbx4:

            cmp selectedOp2AddReg,15 ; check for SI
            jne notaddSI4
            cmp ValRegSI,0FH
            jg NotValidAddress
            mov si,ValRegSI
            mov ax,word ptr ValMem[si]
            add ValRegDX,ax
            jmp Exit
            notaddSI4:

            cmp selectedOp2AddReg,16 ; check for DI
            jne notaddDI4
            cmp ValRegDI,0FH
            jg NotValidAddress
            mov si,ValRegDI
            mov ax,word ptr ValMem[si]
            add ValRegDX,ax
            notaddDI4:

            cmp selectedOp2AddReg,2 ; check for BP
            jne notaddBP4
            cmp ValRegBP,0FH
            jg NotValidAddress
            mov si,ValRegBP
            mov ax,word ptr ValMem[si]
            add ValRegDX,ax
            notaddBP4:

            Notaddmem4:

            cmp selectedOp2Type,0 ; check for Register
            jne NotReg4
            cmp selectedOp2Reg,0 ; check for operand 2 ax
            jne notax5
            mov ax,ValRegAX
            add ValRegDX,ax
            notax5:

            cmp selectedOp2Reg,3 ; check for operand 2 bx
            jne notbx5
            mov ax,ValRegBX
            add ValRegDX,ax
            notbx5:

            cmp selectedOp2Reg,6 ; check for operand 2 cx
            jne notcx5
            mov ax,ValRegCX
            add ValRegDX,ax
            notcx5:

            cmp selectedOp2Reg,9 ; check for operand 2 dx
            jne notdx5
            mov ax,ValRegDX
            add ValRegDX,ax
            notdx5:
            NotReg4:

            jmp NotValidAddress
NotDx:
            cmp selectedOp1Reg,0 ; check for Al
            jne notal

            cmp selectedOp2Type,3 ;check for value
            jne notvalue5

            cmp Op2Val,0FFh   ; check that it's 8 bits
            jg NotValidAddress
            jmp addal
            notvalue5:

            cmp selectedOp2Type,2 ;check for Memory
            jne Notmem5
            mov si,0
            SearchForMem5:
            mov cx,si
            mov ch,0h 
            cmp selectedOp2Mem,cl
            jne notit4
            mov ah,0
            mov al,ValMem[si]
            add ValRegAX,ax
            jmp Exit 
            notit4:
            inc si 
            jmp SearchForMem5
            Notmem5:

            cmp selectedOp2Type,1 ; check for Register
            jne NotReg10
            cmp selectedOp2Reg,1 ; check for operand 2 al
            jne notal1
            mov ax,ValRegAX
            add al,al
            add ValRegAX,ax
            jmp Exit
notal1:

            cmp selectedOp2Reg,2 ; check for operand 2 ah
            jne notah1
            mov ax,ValRegAX
            add al,ah
            add ValRegAX,ax
            jmp Exit

notah1:
            cmp selectedOp2Reg,4 ; check for operand 2 bl
            jne notbl1
            mov bx,ValRegBX
            add al,bl
            add ValRegAX,ax
            jmp Exit
notbl1:
            cmp selectedOp2Reg,5 ; check for operand 2 bh 
            jne notbl1
            mov bx,ValRegBX
            add al,bh
            add ValRegAX,ax
            jmp Exit
notbh1:
            cmp selectedOp2Reg,7 ; check for operand 2 cl 
            jne notcl1
            mov cx,ValRegCX
            add al,cl
            add ValRegAX,ax
            jmp Exit
notcl1:
            cmp selectedOp2Reg,8 ; check for operand 2 ch 
            jne notch1
            mov cx,ValRegCX
            add al,ch
            add ValRegAX,ax
            jmp Exit
notch1:
            cmp selectedOp2Reg,10 ; check for operand 2 dl 
            jne notdl1
            mov dx,ValRegDX
            add al,dl
            add ValRegAX,ax
            jmp Exit
notdl1:
            cmp selectedOp2Reg,11 ; check for operand 2 dh
            jne notdh1
            mov dx,ValRegDX
            add al,dh
            add ValRegAX,ax
            jmp Exit
notdh1:



NotReg10:
            cmp selectedOp2Type,1 ;check for addresing
            jne Notaddmem5

            cmp selectedOp2AddReg,3 ; check for bx
            jne notaddbx5
            cmp ValRegBX,0FH
            jg NotValidAddress
            mov si,ValRegBX
            mov ah,0
            mov al,ValMem[si]
            add ValRegAX,ax
            jmp Exit
            notaddbx5:

            cmp selectedOp2AddReg,15 ; check for SI
            jne notaddSI5
            cmp ValRegSI,0FH
            jg NotValidAddress
            mov si,ValRegSI
            mov ah,0
            mov al,ValMem[si]
            add ValRegAX,ax
            jmp Exit
            notaddSI5:

            cmp selectedOp2AddReg,16 ; check for DI
            jne notaddDI5
            cmp ValRegDI,0FH
            jg NotValidAddress
            mov si,ValRegDI
            mov ah,0
            mov al,ValMem[si]
            add ValRegAX,ax
            jmp Exit
            notaddDI5:

            cmp selectedOp2AddReg,2 ; check for BP
            jne notaddBP5
            cmp ValRegBP,0FH
            jg NotValidAddress
            mov si,ValRegBP
            mov ah,0
            mov al,ValMem[si]
            add ValRegAX,ax
            jmp Exit
            notaddBP5:

            Notaddmem5:


            jmp NotValidAddress           
notal:
            
            cmp selectedOp1Reg,2 ; check for Ah
            jne notah

            cmp selectedOp2Type,3 ;check for value
            jne notvalue6

            cmp Op2Val,0FFh   ; check that it's 8 bits
            jg NotValidAddress
            mov ax,Op2Val
            add ValRegAX,ax
            notvalue6:

            cmp selectedOp2Type,2 ;check for Memory
            jne Notmem6
            mov si,0
            SearchForMem6:
            mov cx,si
            mov ch,0h 
            cmp selectedOp2Mem,cl
            jne notit5
            mov al,0
            mov ah,ValMem[si]
            add ValRegAX,ax
            jmp Exit 
            notit5:
            inc si 
            jmp SearchForMem6
            Notmem6:

            cmp selectedOp2Type,1 ; check for Register
            jne NotReg20
            cmp selectedOp2Reg,1 ; check for operand 2 al
            jne notal2
            mov ax,ValRegAX
            add ah,al
            add ValRegAX,ax
            jmp Exit
notal2:

            cmp selectedOp2Reg,2 ; check for operand 2 ah
            jne notah2
            mov ax,ValRegAX
            add ah,ah
            add ValRegAX,ax
            jmp Exit

notah2:
            cmp selectedOp2Reg,4 ; check for operand 2 bl
            jne notbl2
            mov bx,ValRegBX
            add ah,bl
            add ValRegAX,ax
            jmp Exit
notbl2:
            cmp selectedOp2Reg,5 ; check for operand 2 bh 
            jne notbh2
            mov bx,ValRegBX
            add ah,bh
            add ValRegAX,ax
            jmp Exit
notbh2:
            cmp selectedOp2Reg,7 ; check for operand 2 cl 
            jne notcl2
            mov cx,ValRegCX
            add ah,cl
            add ValRegAX,ax
            jmp Exit
notcl2:
            cmp selectedOp2Reg,8 ; check for operand 2 ch 
            jne notch2
            mov cx,ValRegCX
            add ah,ch
            add ValRegAX,ax
            jmp Exit
notch2:
            cmp selectedOp2Reg,10 ; check for operand 2 dl 
            jne notdl2
            mov dx,ValRegDX
            add ah,dl
            add ValRegAX,ax
            jmp Exit
notdl2:
            cmp selectedOp2Reg,11 ; check for operand 2 dh
            jne notdh2
            mov dx,ValRegDX
            add ah,dh
            add ValRegAX,ax
            jmp Exit
notdh2:

NotReg20:
            cmp selectedOp2Type,1 ;check for addresing
            jne Notaddmem6

            cmp selectedOp2AddReg,3 ; check for bx
            jne notaddbx6
            cmp ValRegBX,0FH
            jg NotValidAddress
            mov si,ValRegBX
            mov al,0
            mov ah,ValMem[si]
            add ValRegAX,ax
            jmp Exit
            notaddbx6:

            cmp selectedOp2AddReg,15 ; check for SI
            jne notaddSI6
            cmp ValRegSI,0FH
            jg NotValidAddress
            mov si,ValRegSI
            mov al,0
            mov ah,ValMem[si]
            add ValRegAX,ax
            jmp Exit
            notaddSI6:

            cmp selectedOp2AddReg,16 ; check for DI
            jne notaddDI6
            cmp ValRegDI,0FH
            jg NotValidAddress
            mov si,ValRegDI
            mov al,0
            mov ah,ValMem[si]
            add ValRegAX,ax
            jmp Exit
            notaddDI6:

            cmp selectedOp2AddReg,2 ; check for BP
            jne notaddBP6
            cmp ValRegBP,0FH
            jg NotValidAddress
            mov si,ValRegBP
            mov al,0
            mov ah,ValMem[si]
            add ValRegAX,ax
            jmp Exit
            notaddBP6:

            Notaddmem6:


            jmp NotValidAddress           
notah:
            cmp selectedOp1Reg,4 ; check for bl
            jne notbl

            cmp selectedOp2Type,3 ;check for value
            jne notvalue7

            cmp Op2Val,0FFh   ; check that it's 8 bits
            jg NotValidAddress
            mov bx,Op2Val
            add ValRegBX,bx
            notvalue7:

            cmp selectedOp2Type,2 ;check for Memory
            jne Notmem7
            mov si,0
            SearchForMem7:
            mov cx,si
            mov ch,0h 
            cmp selectedOp2Mem,cl
            jne notit6
            mov bh,0
            mov bl,ValMem[si]
            add ValRegBX,bx
            jmp Exit 
            notit6:
            inc si 
            jmp SearchForMem7
            Notmem7:

            cmp selectedOp2Type,1 ; check for Register
            jne NotReg30
            cmp selectedOp2Reg,1 ; check for operand 2 al
            jne notal3
            mov ax,ValRegAX
            add bl,al
            mov bh,0
            add ValRegBX,bx
            jmp Exit
notal3:

            cmp selectedOp2Reg,2 ; check for operand 2 ah
            jne notah3
            mov ax,ValRegAX
            add bl,ah
            mov bh,0
            add ValRegBX,bx
            jmp Exit

notah3:
            cmp selectedOp2Reg,4 ; check for operand 2 bl
            jne notbl3
            mov bx,ValRegBX
            add bl,bl
            mov bh,0
            add ValRegBX,bx
            jmp Exit
notbl3:
            cmp selectedOp2Reg,5 ; check for operand 2 bh 
            jne notbh3
            mov bx,ValRegBX
            add bl,bh
            mov bh,0
            add ValRegBX,bx
            jmp Exit
notbh3:
            cmp selectedOp2Reg,7 ; check for operand 2 cl 
            jne notcl3
            mov cx,ValRegCX
            add BL,cl
            mov bh,0
            add ValRegBX,bx
            jmp Exit
notcl3:
            cmp selectedOp2Reg,8 ; check for operand 2 ch 
            jne notch3
            mov cx,ValRegCX
            add BL,ch
            mov bh,0
            add ValRegBX,bx
            jmp Exit
notch3:
            cmp selectedOp2Reg,10 ; check for operand 2 dl 
            jne notdl3
            mov dx,ValRegDX
            add bl,dl
            mov bh,0
            add ValRegBX,bx
            jmp Exit
notdl3:
            cmp selectedOp2Reg,11 ; check for operand 2 dh
            jne notdh3
            mov dx,ValRegDX
            add bl,dh
            mov bh,0
            add ValRegBX,bx
            jmp Exit
notdh3:

NotReg30:
            cmp selectedOp2Type,1 ;check for addresing
            jne Notaddmem7

            cmp selectedOp2AddReg,3 ; check for bx
            jne notaddbx7
            cmp ValRegBX,0FH
            jg NotValidAddress
            mov si,ValRegBX
            mov ah,0
            mov al,ValMem[si]
            add ValRegBX,ax
            jmp Exit
            notaddbx7:

            cmp selectedOp2AddReg,15 ; check for SI
            jne notaddSI7
            cmp ValRegSI,0FH
            jg NotValidAddress
            mov si,ValRegSI
            mov ah,0
            mov al,ValMem[si]
            add ValRegBX,ax
            jmp Exit
            notaddSI7:

            cmp selectedOp2AddReg,16 ; check for DI
            jne notaddDI7
            cmp ValRegDI,0FH
            jg NotValidAddress
            mov si,ValRegDI
            mov ah,0
            mov al,ValMem[si]
            add ValRegBX,ax
            jmp Exit
            notaddDI7:

            cmp selectedOp2AddReg,2 ; check for BP
            jne notaddBP7
            cmp ValRegBP,0FH
            jg NotValidAddress
            mov si,ValRegBP
            mov ah,0
            mov al,ValMem[si]
            add ValRegBX,ax
            jmp Exit
            notaddBP7:

            Notaddmem7:


            jmp NotValidAddress           
notbl:
            cmp selectedOp1Reg,5 ; check for bh
            jne notbh

            cmp selectedOp2Type,3 ;check for value
            jne notvalue8

            cmp Op2Val,0FFh   ; check that it's 8 bits
            jg NotValidAddress
            mov bx,Op2Val
            add ValRegBX,bx
            notvalue8:

            cmp selectedOp2Type,2 ;check for Memory
            jne Notmem8
            mov si,0
            SearchForMem8:
            mov cx,si
            mov ch,0h 
            cmp selectedOp2Mem,cl
            jne notit7
            mov bl,0
            mov bh,ValMem[si]
            add ValRegBX,bx
            jmp Exit 
            notit7:
            inc si 
            jmp SearchForMem8
            Notmem8:

            cmp selectedOp2Type,1 ; check for Register
            jne NotReg40
            cmp selectedOp2Reg,1 ; check for operand 2 al
            jne notal4
            mov ax,ValRegAX
            add bh,al
            mov bl,0
            add ValRegBX,bx
            jmp Exit
notal4:

            cmp selectedOp2Reg,2 ; check for operand 2 ah
            jne notah4
            mov ax,ValRegAX
            add bh,ah
            mov bl,0
            add ValRegBX,bx
            jmp Exit

notah4:
            cmp selectedOp2Reg,4 ; check for operand 2 bl
            jne notbl4
            mov bx,ValRegBX
            add bh,bl
            mov bl,0
            add ValRegBX,bx
            jmp Exit
notbl4:
            cmp selectedOp2Reg,5 ; check for operand 2 bh 
            jne notbh4
            mov bx,ValRegBX
            add bl,bh
            mov bh,0
            add ValRegBX,bx
            jmp Exit
notbh4:
            cmp selectedOp2Reg,7 ; check for operand 2 cl 
            jne notcl4
            mov cx,ValRegCX
            add Bh,cl
            mov bl,0
            add ValRegBX,bx
            jmp Exit
notcl4:
            cmp selectedOp2Reg,8 ; check for operand 2 ch 
            jne notch4
            mov cx,ValRegCX
            add Bh,ch
            mov bl,0
            add ValRegBX,bx
            jmp Exit
notch4:
            cmp selectedOp2Reg,10 ; check for operand 2 dl 
            jne notdl4
            mov dx,ValRegDX
            add bh,dl
            mov bl,0
            add ValRegBX,bx
            jmp Exit
notdl4:
            cmp selectedOp2Reg,11 ; check for operand 2 dh
            jne notdh4
            mov dx,ValRegDX
            add bh,dh
            mov bl,0
            add ValRegBX,bx
            jmp Exit
notdh4:

NotReg40:
            cmp selectedOp2Type,1 ;check for addresing
            jne Notaddmem8

            cmp selectedOp2AddReg,3 ; check for bx
            jne notaddbx8
            cmp ValRegBX,0FH
            jg NotValidAddress
            mov si,ValRegBX
            mov al,0
            mov ah,ValMem[si]
            add ValRegBX,ax
            jmp Exit
            notaddbx8:

            cmp selectedOp2AddReg,15 ; check for SI
            jne notaddSI8
            cmp ValRegSI,0FH
            jg NotValidAddress
            mov si,ValRegSI
            mov al,0
            mov ah,ValMem[si]
            add ValRegBX,ax
            jmp Exit
            notaddSI8:

            cmp selectedOp2AddReg,16 ; check for DI
            jne notaddDI8
            cmp ValRegDI,0FH
            jg NotValidAddress
            mov si,ValRegDI
            mov al,0
            mov ah,ValMem[si]
            add ValRegBX,ax
            jmp Exit
            notaddDI8:

            cmp selectedOp2AddReg,2 ; check for BP
            jne notaddBP8
            cmp ValRegBP,0FH
            jg NotValidAddress
            mov si,ValRegBP
            mov al,0
            mov ah,ValMem[si]
            add ValRegBX,ax
            jmp Exit
            notaddBP8:

            Notaddmem8:


            jmp NotValidAddress           
notbh:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            cmp selectedOp1Reg,7 ; check for Cl
            jne notcl

            cmp selectedOp2Type,3 ;check for value
            jne notvalue9

            cmp Op2Val,0FFh   ; check that it's 8 bits
            jg NotValidAddress
            mov bx,Op2Val
            add ValRegCX,bx
            notvalue9:

            cmp selectedOp2Type,2 ;check for Memory
            jne Notmem9
            mov si,0
            SearchForMem9:
            mov cx,si
            mov ch,0h 
            cmp selectedOp2Mem,cl
            jne notit8
            mov bh,0
            mov bl,ValMem[si]
            add ValRegCX,bx
            jmp Exit 
            notit8:
            inc si 
            jmp SearchForMem9
            Notmem9:

            cmp selectedOp2Type,1 ; check for Register
            jne NotReg50
            cmp selectedOp2Reg,1 ; check for operand 2 al
            jne notal5
            mov ax,ValRegAX
            add bl,al
            mov bh,0
            add ValRegCX,bx
            jmp Exit
notal5:

            cmp selectedOp2Reg,2 ; check for operand 2 ah
            jne notah5
            mov ax,ValRegAX
            add bl,ah
            mov bh,0
            add ValRegCX,bx
            jmp Exit

notah5:
            cmp selectedOp2Reg,4 ; check for operand 2 bl
            jne notbl5
            mov bx,ValRegBX
            add bl,bl
            mov bh,0
            add ValRegCX,bx
            jmp Exit
notbl5:
            cmp selectedOp2Reg,5 ; check for operand 2 bh 
            jne notbh5
            mov bx,ValRegBX
            add bl,bh
            mov bh,0
            add ValRegCX,bx
            jmp Exit
notbh5:
            cmp selectedOp2Reg,7 ; check for operand 2 cl 
            jne notcl5
            mov cx,ValRegCX
            add BL,cl
            mov bh,0
            add ValRegCX,bx
            jmp Exit
notcl5:
            cmp selectedOp2Reg,8 ; check for operand 2 ch 
            jne notch5
            mov cx,ValRegCX
            add BL,ch
            mov bh,0
            add ValRegCX,bx
            jmp Exit
notch5:
            cmp selectedOp2Reg,10 ; check for operand 2 dl 
            jne notdl5
            mov dx,ValRegDX
            add bl,dl
            mov bh,0
            add ValRegCX,bx
            jmp Exit
notdl5:
            cmp selectedOp2Reg,11 ; check for operand 2 dh
            jne notdh5
            mov dx,ValRegDX
            add bl,dh
            mov bh,0
            add ValRegCX,bx
            jmp Exit
notdh5:

NotReg50:
            cmp selectedOp2Type,1 ;check for addresing
            jne Notaddmem9

            cmp selectedOp2AddReg,3 ; check for bx
            jne notaddbx9
            cmp ValRegBX,0FH
            jg NotValidAddress
            mov si,ValRegBX
            mov ah,0
            mov al,ValMem[si]
            add ValRegCX,ax
            jmp Exit
            notaddbx9:

            cmp selectedOp2AddReg,15 ; check for SI
            jne notaddSI9
            cmp ValRegSI,0FH
            jg NotValidAddress
            mov si,ValRegSI
            mov ah,0
            mov al,ValMem[si]
            add ValRegCX,ax
            jmp Exit
            notaddSI9:

            cmp selectedOp2AddReg,16 ; check for DI
            jne notaddDI9
            cmp ValRegDI,0FH
            jg NotValidAddress
            mov si,ValRegDI
            mov ah,0
            mov al,ValMem[si]
            add ValRegCX,ax
            jmp Exit
            notaddDI9:

            cmp selectedOp2AddReg,2 ; check for BP
            jne notaddBP9
            cmp ValRegBP,0FH
            jg NotValidAddress
            mov si,ValRegBP
            mov ah,0
            mov al,ValMem[si]
            add ValRegCX,ax
            jmp Exit
            notaddBP9:

            Notaddmem9:


            jmp NotValidAddress           
notcl:
            cmp selectedOp1Reg,8 ; check for Ch
            jne notCh

            cmp selectedOp2Type,3 ;check for value
            jne notvalue10

            cmp Op2Val,0FFh   ; check that it's 8 bits
            jg NotValidAddress
            mov bx,Op2Val
            add ValRegBX,bx
            notvalue10:

            cmp selectedOp2Type,2 ;check for Memory
            jne Notmem8
            mov si,0
            SearchForMem10:
            mov cx,si
            mov ch,0h 
            cmp selectedOp2Mem,cl
            jne notit9
            mov bl,0
            mov bh,ValMem[si]
            add ValRegCX,bx
            jmp Exit 
            notit9:
            inc si 
            jmp SearchForMem10
            Notmem10:

            cmp selectedOp2Type,1 ; check for Register
            jne NotReg60
            cmp selectedOp2Reg,1 ; check for operand 2 al
            jne notal6
            mov ax,ValRegAX
            add bh,al
            mov bl,0
            add ValRegCX,bx
            jmp Exit
notal6:

            cmp selectedOp2Reg,2 ; check for operand 2 ah
            jne notah6
            mov ax,ValRegAX
            add bh,ah
            mov bl,0
            add ValRegCX,bx
            jmp Exit

notah6:
            cmp selectedOp2Reg,4 ; check for operand 2 bl
            jne notbl6
            mov bx,ValRegBX
            add bh,bl
            mov bl,0
            add ValRegCX,bx
            jmp Exit
notbl6:
            cmp selectedOp2Reg,5 ; check for operand 2 bh 
            jne notbh6
            mov bx,ValRegBX
            add bl,bh
            mov bh,0
            add ValRegCX,bx
            jmp Exit
notbh6:
            cmp selectedOp2Reg,7 ; check for operand 2 cl 
            jne notcl6
            mov cx,ValRegCX
            add Bh,cl
            mov bl,0
            add ValRegCX,bx
            jmp Exit
notcl6:
            cmp selectedOp2Reg,8 ; check for operand 2 ch 
            jne notch6
            mov cx,ValRegCX
            add Bh,ch
            mov bl,0
            add ValRegCX,bx
            jmp Exit
notch6:
            cmp selectedOp2Reg,10 ; check for operand 2 dl 
            jne notdl6
            mov dx,ValRegDX
            add bh,dl
            mov bl,0
            add ValRegCX,bx
            jmp Exit
notdl6:
            cmp selectedOp2Reg,11 ; check for operand 2 dh
            jne notdh6
            mov dx,ValRegDX
            add bh,dh
            mov bl,0
            add ValRegCX,bx
            jmp Exit
notdh6:

NotReg60:
            cmp selectedOp2Type,1 ;check for addresing
            jne Notaddmem10

            cmp selectedOp2AddReg,3 ; check for bx
            jne notaddbx10
            cmp ValRegBX,0FH
            jg NotValidAddress
            mov si,ValRegBX
            mov al,0
            mov ah,ValMem[si]
            add ValRegCX,ax
            jmp Exit
            notaddbx10:

            cmp selectedOp2AddReg,15 ; check for SI
            jne notaddSI10
            cmp ValRegSI,0FH
            jg NotValidAddress
            mov si,ValRegSI
            mov al,0
            mov ah,ValMem[si]
            add ValRegCX,ax
            jmp Exit
            notaddSI10:

            cmp selectedOp2AddReg,16 ; check for DI
            jne notaddDI10
            cmp ValRegDI,0FH
            jg NotValidAddress
            mov si,ValRegDI
            mov al,0
            mov ah,ValMem[si]
            add ValRegCX,ax
            jmp Exit
            notaddDI10:

            cmp selectedOp2AddReg,2 ; check for BP
            jne notaddBP10
            cmp ValRegBP,0FH
            jg NotValidAddress
            mov si,ValRegBP
            mov al,0
            mov ah,ValMem[si]
            add ValRegCX,ax
            jmp Exit
            notaddBP10:

            Notaddmem10:


            jmp NotValidAddress           
notCh:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            cmp selectedOp1Reg,7 ; check for dl
            jne notdl

            cmp selectedOp2Type,3 ;check for value
            jne notvalue11

            cmp Op2Val,0FFh   ; check that it's 8 bits
            jg NotValidAddress
            mov bx,Op2Val
            add ValRegDX,bx
            notvalue11:

            cmp selectedOp2Type,2 ;check for Memory
            jne Notmem11
            mov si,0
            SearchForMem11:
            mov cx,si
            mov ch,0h 
            cmp selectedOp2Mem,cl
            jne notit11
            mov bh,0
            mov bl,ValMem[si]
            add ValRegDX,bx
            jmp Exit 
            notit11:
            inc si 
            jmp SearchForMem11
            Notmem11:

            cmp selectedOp2Type,1 ; check for Register
            jne NotReg70
            cmp selectedOp2Reg,1 ; check for operand 2 al
            jne notal7
            mov ax,ValRegAX
            add bl,al
            mov bh,0
            add ValRegDX,bx
            jmp Exit
notal7:

            cmp selectedOp2Reg,2 ; check for operand 2 ah
            jne notah60
            mov ax,ValRegAX
            add bl,ah
            mov bh,0
            add ValRegDX,bx
            jmp Exit

notah60:
            cmp selectedOp2Reg,4 ; check for operand 2 bl
            jne notbl60
            mov bx,ValRegBX
            add bl,bl
            mov bh,0
            add ValRegDX,bx
            jmp Exit
notbl60:
            cmp selectedOp2Reg,5 ; check for operand 2 bh 
            jne notbh60
            mov bx,ValRegBX
            add bl,bh
            mov bh,0
            add ValRegDX,bx
            jmp Exit
notbh60:
            cmp selectedOp2Reg,7 ; check for operand 2 cl 
            jne notcl60
            mov cx,ValRegCX
            add BL,cl
            mov bh,0
            add ValRegDX,bx
            jmp Exit
notcl60:
            cmp selectedOp2Reg,8 ; check for operand 2 ch 
            jne notch60
            mov cx,ValRegCX
            add BL,ch
            mov bh,0
            add ValRegDX,bx
            jmp Exit
notch60:
            cmp selectedOp2Reg,10 ; check for operand 2 dl 
            jne notdl60
            mov dx,ValRegDX
            add bl,dl
            mov bh,0
            add ValRegDX,bx
            jmp Exit
notdl60:
            cmp selectedOp2Reg,11 ; check for operand 2 dh
            jne notdh7
            mov dx,ValRegDX
            add bl,dh
            mov bh,0
            add ValRegDX,bx
            jmp Exit
notdh7:

NotReg70:
            cmp selectedOp2Type,1 ;check for addresing
            jne Notaddmem11

            cmp selectedOp2AddReg,3 ; check for bx
            jne notaddbx11
            cmp ValRegBX,0FH
            jg NotValidAddress
            mov si,ValRegBX
            mov ah,0
            mov al,ValMem[si]
            add ValRegDX,ax
            jmp Exit
            notaddbx11:

            cmp selectedOp2AddReg,15 ; check for SI
            jne notaddSI11
            cmp ValRegSI,0FH
            jg NotValidAddress
            mov si,ValRegSI
            mov ah,0
            mov al,ValMem[si]
            add ValRegDX,ax
            jmp Exit
            notaddSI11:

            cmp selectedOp2AddReg,16 ; check for DI
            jne notaddDI11
            cmp ValRegDI,0FH
            jg NotValidAddress
            mov si,ValRegDI
            mov ah,0
            mov al,ValMem[si]
            add ValRegDX,ax
            jmp Exit
            notaddDI11:

            cmp selectedOp2AddReg,2 ; check for BP
            jne notaddBP11
            cmp ValRegBP,0FH
            jg NotValidAddress
            mov si,ValRegBP
            mov ah,0
            mov al,ValMem[si]
            add ValRegDX,ax
            jmp Exit
            notaddBP11:

            Notaddmem11:


            jmp NotValidAddress           
notdl:
            cmp selectedOp1Reg,12 ; check for Dh
            jne notdh

            cmp selectedOp2Type,3 ;check for value
            jne notvalue12

            cmp Op2Val,0FFh   ; check that it's 8 bits
            jg NotValidAddress
            mov bx,Op2Val
            add ValRegDX,bx
            notvalue12:

            cmp selectedOp2Type,2 ;check for Memory
            jne Notmem12
            mov si,0
            SearchForMem12:
            mov cx,si
            mov ch,0h 
            cmp selectedOp2Mem,cl
            jne notit110
            mov bl,0
            mov bh,ValMem[si]
            add ValRegDX,bx
            jmp Exit 
            notit110:
            inc si 
            jmp SearchForMem12
            Notmem12:

            cmp selectedOp2Type,1 ; check for Register
            jne NotReg80
            cmp selectedOp2Reg,1 ; check for operand 2 al
            jne notal8
            mov ax,ValRegAX
            add bh,al
            mov bl,0
            add ValRegDX,bx
            jmp Exit
notal8:

            cmp selectedOp2Reg,2 ; check for operand 2 ah
            jne notah8
            mov ax,ValRegAX
            add bh,ah
            mov bl,0
            add ValRegDX,bx
            jmp Exit

notah8:
            cmp selectedOp2Reg,4 ; check for operand 2 bl
            jne notbl8
            mov bx,ValRegBX
            add bh,bl
            mov bl,0
            add ValRegDX,bx
            jmp Exit
notbl8:
            cmp selectedOp2Reg,5 ; check for operand 2 bh 
            jne notbh8
            mov bx,ValRegBX
            add bl,bh
            mov bh,0
            add ValRegDX,bx
            jmp Exit
notbh8:
            cmp selectedOp2Reg,7 ; check for operand 2 cl 
            jne notcl8
            mov cx,ValRegCX
            add Bh,cl
            mov bl,0
            add ValRegDX,bx
            jmp Exit
notcl8:
            cmp selectedOp2Reg,8 ; check for operand 2 ch 
            jne notch8
            mov cx,ValRegCX
            add Bh,ch
            mov bl,0
            add ValRegDX,bx
            jmp Exit
notch8:
            cmp selectedOp2Reg,10 ; check for operand 2 dl 
            jne notdl8
            mov dx,ValRegDX
            add bh,dl
            mov bl,0
            add ValRegDX,bx
            jmp Exit
notdl8:
            cmp selectedOp2Reg,11 ; check for operand 2 dh
            jne notdh8
            mov dx,ValRegDX
            add bh,dh
            mov bl,0
            add ValRegDX,bx
            jmp Exit
notdh8:

NotReg80:
            cmp selectedOp2Type,1 ;check for addresing
            jne Notaddmem12

            cmp selectedOp2AddReg,3 ; check for bx
            jne notaddbx12
            cmp ValRegBX,0FH
            jg NotValidAddress
            mov si,ValRegBX
            mov al,0
            mov ah,ValMem[si]
            add ValRegDX,ax
            jmp Exit
            notaddbx12:

            cmp selectedOp2AddReg,15 ; check for SI
            jne notaddSI12
            cmp ValRegSI,0FH
            jg NotValidAddress
            mov si,ValRegSI
            mov al,0
            mov ah,ValMem[si]
            add ValRegDX,ax
            jmp Exit
            notaddSI12:

            cmp selectedOp2AddReg,16 ; check for DI
            jne notaddDI12
            cmp ValRegDI,0FH
            jg NotValidAddress
            mov si,ValRegDI
            mov al,0
            mov ah,ValMem[si]
            add ValRegDX,ax
            jmp Exit
            notaddDI12:

            cmp selectedOp2AddReg,2 ; check for BP
            jne notaddBP12
            cmp ValRegBP,0FH
            jg NotValidAddress
            mov si,ValRegBP
            mov al,0
            mov ah,ValMem[si]
            add ValRegDX,ax
            jmp Exit
            notaddBP12:

            Notaddmem12:


            jmp NotValidAddress           
notdh:
            jmp NotValidAddress
            notthiscom1:
            cmp selectedOp1Type,2
            jne notthiscom2

            cmp selectedOp2Type,3 ; check for Op2 Value
            jne Notvalue30
            mov ax,Op2Val
            mov word ptr ValMem,ax
            jmp Exit
            Notvalue30:

            cmp selectedOp2Type,0 ; check for Reg
            jne Notthiss

            cmp selectedOp2Reg,0 ;check for ax
            jne notthisax
            mov ax,ValRegAX
            add word ptr ValMem,ax
            jmp Exit
            notthisax:

            cmp selectedOp2Reg,1 ;check for al
            jne notthisal
            mov ax,ValRegAX
            add ValMem,al
            jmp Exit
            notthisal:

            cmp selectedOp2Reg,2 ;check for ah
            jne notthisah
            mov ax,ValRegAX
            add ValMem,ah
            jmp Exit
            notthisah:

            cmp selectedOp2Reg,3 ;check for Bx
            jne notthisbx
            mov ax,ValRegBX
            add word ptr ValMem,ax
            jmp Exit
            notthisbx:

            cmp selectedOp2Reg,4 ;check for Bl
            jne notthisbl
            mov ax,ValRegBX
            add ValMem,al
            jmp Exit
            notthisbl:

            cmp selectedOp2Reg,5 ;check for Bh
            jne notthisbh
            mov ax,ValRegBX
            add ValMem,ah
            jmp Exit
            notthisbh:

            cmp selectedOp2Reg,6 ;check for Cx
            jne notthiscx
            mov ax,ValRegCX
            add word ptr ValMem,ax
            jmp Exit
            notthiscx:

            cmp selectedOp2Reg,7 ;check for cl
            jne notthiscl
            mov ax,ValRegCX
            add ValMem,al
            jmp Exit
            notthiscl:

            cmp selectedOp2Reg,8 ;check for ch
            jne notthisch
            mov ax,ValRegCX
            add ValMem,ah
            jmp Exit
            notthisch:

            cmp selectedOp2Reg,6 ;check for Dx
            jne notthisdx
            mov ax,ValRegDX
            add word ptr ValMem,ax
            jmp Exit
            notthisdx:

            cmp selectedOp2Reg,7 ;check for Dl
            jne notthisdl
            mov ax,ValRegDX
            add ValMem,al
            jmp Exit
            notthisdl:

            cmp selectedOp2Reg,8 ;check for dh
            jne notthisdh
            mov ax,ValRegDX
            add ValMem,ah
            jmp Exit
            notthisdh:

            notthiss:
            notthiscom2:
            jmp InValidCommand

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
                    ExecPushMem ValRegAX
                    JMP Exit
                PushOpRegBX:
                    ExecPushMem ValRegBX
                    JMP Exit
                PushOpRegCX:
                    ExecPushMem ValRegCX
                    JMP Exit
                PushOpRegDX:
                    ExecPushMem ValRegDX
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
                    mov dx, word ptr ValRegBX
                    CALL CheckAddress
                    cmp bl, 1               ; Value is greater than 16
                    JZ InValidCommand
                    mov SI, word ptr ValRegBX
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
            mov dx, offset PUSHcom
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
            mov ah, 9               ; display error message and exit
            mov dx, offset error
            int 21h

        RETURN_Op2Menu:

            RET
    Op2Menu ENDP
    END CommMenu