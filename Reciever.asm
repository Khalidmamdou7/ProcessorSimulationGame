.Model small
.Stack 64
.Data
    TestString db 10,'Recieved Successfully', '$'
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


        ; Receiving a value

        ;Check that Data is Ready
		mov dx , 3FDH		; Line Status Register
	    CHK:
            in al , dx 
  		    test al , 1
  		JZ CHK              ; Not Ready

        ; If Ready read the VALUE in Receive data register
  		mov dx , 03F8H
  		in al , dx 
  		mov bl , al

        ; display recieved value
        mov ah, 2
        mov dl, bl
        int 21h

        ; Receiving a value

        ;Check that Data is Ready
		mov dx , 3FDH		; Line Status Register
	    CHK2:
            in al , dx 
  		    test al , 1
  		JZ CHK2              ; Not Ready

        ; If Ready read the VALUE in Receive data register
  		mov dx , 03F8H
  		in al , dx 
  		mov bl , al

        ; display recieved value
        mov ah, 2
        mov dl, bl
        int 21h

        ; display string
        mov ah, 9
        mov dx, offset TestString
        int 21h 


        ; Return to dos
        mov ah,4ch
        int 21h


    MAIN ENDP
    END MAIN