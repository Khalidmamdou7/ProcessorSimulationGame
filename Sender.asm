.Model small
.Data
    TestString db 'Sent Successfully', '$'
.Code
    Main proc far

        mov ax, @Data
        mov ds, ax

        ; Port initialization

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


        ; Sending a Value

        mov dx , 3FDH		    ; Line Status Register
        AGAIN:
          	In al , dx 			; Read Line Status
  		    test al , 00100000b
  		JZ AGAIN                ; Not empty
        
        ;If empty put the VALUE in Transmit data register
  		mov dx , 3F8H		; Transmit data register
  		mov al, 'A'
  		out dx , al

        ; Sending a Value

        mov dx , 3FDH		    ; Line Status Register
        AGAIN2:
          	In al , dx 			; Read Line Status
  		    test al , 00100000b
  		JZ AGAIN2                ; Not empty
        
        ;If empty put the VALUE in Transmit data register
  		mov dx , 3F8H		; Transmit data register
  		mov al, '+'
  		out dx , al  


        ; display test string
        mov ah, 9
        mov dx, offset TestString
        int 21h 

        ; Return to dos
        mov ah,4ch
        int 21h


    MAIN ENDP
    END MAIN