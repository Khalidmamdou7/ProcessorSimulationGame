.Model small
.Stack 64
.Data
    Comm0 db 'Command 0  ','$'
    Comm1 db 'Command 1  ','$'
    Comm2 db 'Command 2  ','$'
    Comm3 db 'Command 3  ','$'
    Comm4 db 'Command 4  ','$'
    Comm5 db 'Command 5  ','$'
    Comm6 db 'Command 6  ','$'
    Comm7 db 'Command 7  ','$'
    Comm8 db 'Command 8  ','$'
    Comm9 db 'Command 9  ','$'
    Comm10 db 'Command 10 ','$'
    Comm11 db 'Command 11 ','$'
    Comm12 db 'Command 12 ','$'
    Comm13 db 'Command 13 ','$'
    Comm14 db 'Command 14 ','$'
    Comm15 db 'Command 15 ','$'
    mes db 'You have selected Command #'
    selectedComm db ?, '$'

    CommStringSize EQU  12
    
.Code
    Main proc far
        
        mov ax, @Data
        mov ds, ax

        ; Display Command
        DisplayComm:
            mov ah, 9
            mov dx, offset Comm1
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
        cmp ah, 72                                  ; Scan Code of Up:72
        jz CommUp 
        cmp ah, 80                                  ; Scan Code of Down:80
        jz CommDown
        cmp ah, 28                                  ; Scan Code of Enter:28
        jz Selected


        CommUp:
            mov ah, 9
            ; Check overflow
                cmp dx,0
                jnz NotOverflow
                mov dx, offset Comm15
                add dx, CommStringSize
            NotOverflow:
                sub dx, CommStringSize
                int 21h
                jmp CHECK
        
        CommDown:
            mov ah, 9
            ; Check End of file
                cmp dx, offset Comm15
                jnz NotEOF
                mov dx, offset Comm1
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


        ; Return to dos
        mov ah,4ch
        int 21h


    MAIN ENDP
    END MAIN