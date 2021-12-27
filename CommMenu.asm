.Model small
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
    mes db 'You have selected Command #'
    selectedComm db ?, '$'

    CommStringSize EQU  6
    UpArrowScanCode EQU 72
    DownArrowScanCode EQU 80
    EnterScanCode EQU 28

    
.Code
    Main proc far
        
        mov ax, @Data
        mov ds, ax

        ; Display Command
        DisplayComm:
            mov ah, 9
            mov dx, offset MOVcom
            int 21h

        ; Wait for a key pressed
        CHECK: 
            mov ah,1
            int 16h
        jz CHECK

        Push ax
        PUSH dx 
            ; Clear buffer
            mov ah,07
            int 21h
            ; Reset Cursor
            mov ah,2
            mov dx,0
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


        CommUp:
            mov ah, 9
            ; Check overflow
                cmp dx,0
                jnz NotOverflow
                mov dx, offset SHRcom
                add dx, CommStringSize
            NotOverflow:
                sub dx, CommStringSize
                int 21h
                jmp CHECK
        
        CommDown:
            mov ah, 9
            ; Check End of file
                cmp dx, offset SHRcom
                jnz NotEOF
                mov dx, offset NOPcom
                sub dx, CommStringSize
            NotEOF:
                add dx, CommStringSize
                int 21h
                jmp CHECK
        
        Selected:
            ; Detecting index of selected command
            mov ax, dx
            mov bl, CommStringSize
            div bl                                      ; Op=byte: AL:=AX / Op 
            mov selectedComm, al
            add selectedComm, '0'                       ; to convert digit to Ascii
            

            ; Set Cursor
            mov ah,2
            mov dx,0100h
            int 10h

            ; Display message
            mov ah, 9
            mov dx, offset mes
            int 21h


        Exit:
            ; Return to dos
            mov ah,4ch
            int 21h


    MAIN ENDP
    END MAIN