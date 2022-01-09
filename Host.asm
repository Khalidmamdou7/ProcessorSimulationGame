.Model small
.Stack 64
.Data
    NAMEP1  DB 'KHALED', '$'
    NAMEP2  DB  16 DUP('$')
    HOST DB 1
    mesSend db "Enter a message to send: ", '$'
    mesRec db "Recieved message : ", '$'
    TestString db 10, 'Chat ended Successfully', '$'
.Code
    Main proc far

        mov ax, @Data
        mov ds, ax

        CALL PortInitialization

        CALL ClearScreen

        CMP HOST, 1
        JZ SENDFIRST
        JMP SENDSECOND

        SENDFIRST:
            lea si, NAMEP1
            CALL SendMsg
            LEA DI, NAMEP2
            CALL RecMsg
            JMP Finish

        SENDSECOND:
            LEA DI, NAMEP2
            CALL RecMsg
            lea si, NAMEP1
            CALL SendMsg


        Finish:

        LEA DX, NAMEP1
        CALL DisplayString
        LEA DX, NAMEP2
        CALL DisplayString

        mov dx, offset TestString
        CALL DisplayString         

        CALL EXIT


    MAIN ENDP


    PortInitialization PROC
        ;Set Divisor Latch Access Bit 
        mov dx,3fbh 			; Line Control Register
        mov al,10000000b		; Set Divisor Latch Access Bit
        out dx,al				; Out it

        ;Set LSB byte of the Baud Rate Divisor Latch register.
        mov dx,3f8h			
        mov al,0ch			
        out dx,al

        ; Set MSB byte of the Baud Rate Divisor Latch register.
        mov dx,3f9h
        mov al,00h
        out dx,al

        ; Set port configuration
        mov dx,3fbh
        mov al,00011011b
                                ; 0: Access to Receiver buffer, Transmitter buffer
                                ; 0: Set Break disabled
                                ; 011: Even Parity
                                ; 0: One Stop Bit
                                ; 11: 8bits
        out dx,al

        ret
    PortInitialization ENDP
    SendData PROC  ; data transferred is pointed to by si (8 bits)

        ;Check that Transmitter Holding Register is Empty
		mov dx , 3FDH		        ; Line Status Register
        AGAIN:
  	        In al, dx 			    ; Read Line Status
  		    test al, 00100000b
        JZ AGAIN                    ; Not empty

        ;If empty put the VALUE in Transmit data register
  		mov dx, 3F8H		        ; Transmit data register
  		mov al, [si]
  		out dx, al

        ret
    SendData ENDP
    SendMsg PROC  ; Sent string offset is saved in si, ended with '$'
        SendMessage:
            CALL SendData
            inc si
            mov dl, '$'
            cmp dl , byte ptr [si]-1
            jnz SendMessage

        RET
    SendMsg ENDP
    RecieveData PROC ; data is saved in BL

        ;Check that Data is Ready
        mov dx , 3FDH		; Line Status Register
        CHK2:
            in al , dx 
            test al , 1
        JZ Return_RecieveData              ; Not Ready

        ; If Ready read the VALUE in Receive data register
        mov dx , 03F8H
        in al , dx 
        mov bl , al

        Return_RecieveData:
            ret
    RecieveData ENDP
    RecMsg PROC     ; Recieved string offset is saved in di
        RecieveMsg:
            CALL RecieveData
            mov [di], bl
            inc di
            cmp bl, '$'
            jnz RecieveMsg

        RET
    RecMsg ENDP
    ClearScreen PROC
        ; Change to text mode (clear screen)
        mov ah,0
        mov al,3
        int 10h

        ret
    ClearScreen ENDP
    SetCursor PROC
        ; position is saved in dx
        mov ah,2
        int 10h

        ret
    SetCursor ENDP
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
    TakeString PROC     ; string offset saved in dx
        mov ah,0AH
        int 21h

        RET
    TakeString ENDP
    EXIT PROC
        ; Return to dos
        mov ah,4ch
        int 21h

        ret
    EXIT ENDP

    END MAIN
