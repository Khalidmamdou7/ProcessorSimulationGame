.Model Huge
.386
.Stack 64
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
    RegSI db 'SI   ','$'
    RegDI db 'DI   ','$'
    
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
    
    
 
    

.Code
    
    CommMenu proc far
        
        mov ax, @Data
        mov ds, ax
        CALL ClearScreen
        
        CALL MnemonicMenu
        CALL Op1Menu
        MOV DX, CommaCursorLoc
        CALL SetCursor
        mov dl, ','
        CALL DisplayChar
        CALL Op2Menu

        ; Test Messages 
        mov dx, offset mesCom
        CALL DisplayString
        mov dl, selectedComm
        add dl, '0'
        CALL DisplayChar

        mov dx, offset mesOp1Type
        CALL DisplayString
        mov dl, selectedOp1Type
        add dl, '0'
        CALL DisplayChar

        mov dx, offset mesReg
        CALL DisplayString
        mov dl, selectedOp1Reg
        add dl, '0'
        CALL DisplayChar

        mov dx, offset mesMem
        CALL DisplayString
        mov dl, selectedOp1Mem
        add dl, '0'
        CALL DisplayChar

        


        mov dx, offset mesOp1Type
        CALL DisplayString
        mov dl, selectedOp2Type
        add dl, '0'
        CALL DisplayChar

        mov dx, offset mesReg
        CALL DisplayString
        mov dl, selectedOp2Reg
        add dl, '0'
        CALL DisplayChar

        mov dx, offset mesMem
        CALL DisplayString
        mov dl, selectedOp2Mem
        add dl, '0'
        CALL DisplayChar


        Exit:
            
            ; Return to dos
            mov ah,4ch
            int 21h


    CommMenu ENDP

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
            jz Selected2
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