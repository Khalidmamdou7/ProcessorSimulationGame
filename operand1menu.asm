.Model small
.Stack 64              
.Data    
    Reg    db 'Register','$'
    Memory db 'Memory  ','$'
    Value  db 'Value   ','$' 
    
    
    Axx db 'Ax      ','$'
    All db 'Al      ','$'                
    Ahh db 'Ah      ','$'  
    Bxx db 'BX      ','$'   
    Bll db 'Bl      ','$'    
    Bhh db 'Bh      ','$'
    Cxx db 'Cx      ','$'                
    Cll db 'Cl      ','$'  
    Chh db 'Ch      ','$'   
    Dxx db 'Dx      ','$'
    Dll db 'Dl      ','$'
    Dhh db 'Dh      ','$'                
    Sxx db 'Sx      ','$'  
    Sll db 'Sl      ','$'   
    Shh db 'Sh      ','$'
    
    M1 db '[0]     ','$'
    M2 db '[1]     ','$'
    M3 db '[2]     ','$'
    M4 db '[3]     ','$'
    M5 db '[4]     ','$'
    M6 db '[5]     ','$'
    M7 db '[6]     ','$'
    M8 db '[7]     ','$'
    M9 db '[8]     ','$'
    M10 db '[9]     ','$'
    M11 db '[A]     ','$'
    M12 db '[B]     ','$'
    M13 db '[C]     ','$'
    M14 db '[D]     ','$'
    M15 db '[E]     ','$'
    M16 db '[F]     ','$'

    selectedComm db ?, '$'  
    selectedReg  db ?,'$'
    selectedMem  db ?,'$'
    st11 db 13,10,"Enter Your Value : ",'$'
       
    num db 30,?,30 DUP(?)       
    valuex dw 0      
    size db ?
    CommStringSize EQU  6
    UpArrowScanCode EQU 72
    DownArrowScanCode EQU 80
    EnterScanCode EQU 28 
    error db 13,10,"Error Input",'$'
    
    a EQU 1000h
    b EQU 100h
    C EQU 10h
    
    CommSize EQU 9
    mes db 'You have selected Command #' 
.Code
    Main proc far
        
        mov ax, @Data
        mov ds, ax
        
        mov ah,0
        mov al,3
        int 10h
        ; Display Command
        DisplayComm:
            mov ah, 9
            mov dx, offset Reg
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
                mov dx, offset Value ; last one to overcome overflow
                add dx, CommSize
            NotOverflow:
                sub dx, CommSize
                int 21h
                jmp CHECK
        
        CommDown:
            mov ah, 9
            ; Check End of file
                cmp dx, offset Value
                jnz NotEOF
                mov dx, offset Reg
                sub dx, CommSize
            NotEOF:
                add dx, CommSize
                int 21h
                jmp CHECK
        
        Selected:
            ; Detecting index of selected command
            mov ax, dx
            mov bl, CommSize
            div bl                                      ; Op=byte: AL:=AX / Op 
            mov selectedComm, al
            add selectedComm, '0'                       ; to convert digit to Ascii
            

            ; Set Cursor
            mov ah,2
            mov dx,0 
            int 10h

            ; Display message        
            
            ;mov ah, 9
            ;mov dx, offset mes
            ;int 21h
            
            cmp al,0                     ;;;;;;;;;;;;;;;;;;;;;;;;;;; open Register combobox
            jne l1 
            
            ; Display Command
        DisplayComm2:
            mov ah, 9
            mov dx, offset Axx
            int 21h

        ; Wait for a key pressed
        CHECK2: 
            mov ah,1
            int 16h
        jz CHECK2

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
        jz CommUp2 
        cmp ah, DownArrowScanCode
        jz CommDown2
        cmp ah, EnterScanCode
        jz Selected2


        CommUp2:
            mov ah, 9
            ; Check overflow
                cmp dx,27 ; the start of combobox
                jnz NotOverflow2
                mov dx, offset Shh ; last one to overcome overflow
                add dx, CommSize
            NotOverflow2:
                sub dx, CommSize
                int 21h
                jmp CHECK2
        
        CommDown2:
            mov ah, 9
            ; Check End of file
                cmp dx, offset Shh
                jnz NotEOF2
                mov dx, offset Axx
                sub dx, CommSize
            NotEOF2:
                add dx, CommSize
                int 21h
                jmp CHECK2
        
        Selected2:
            ; Detecting index of selected command
            mov ax, dx
            mov bl, CommSize
            div bl                                      ; Op=byte: AL:=AX / Op 
            mov selectedReg, al
            add selectedReg, '0'                       ; to convert digit to Ascii
            

            ; Set Cursor
            mov ah,2
            mov dx,0100h
            int 10h
            
            jmp s1
            
            
            
            l1: cmp al,1          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            jne l2 
            
            ; Display memory
        DisplayComm3:
            mov ah, 9
            mov dx, offset M1
            int 21h

        ; Wait for a key pressed
        CHECK3: 
            mov ah,1 
            int 16h
        jz CHECK3

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
        jz CommUp3 
        cmp ah, DownArrowScanCode
        jz CommDown3
        cmp ah, EnterScanCode
        jz Selected3


        CommUp3:
            mov ah, 9
            ; Check overflow
                cmp dx,162         ; the start of combobox
                jnz NotOverflow3
                mov dx, offset M16 ; last one to overcome overflow
                add dx, CommSize
            NotOverflow3:
                sub dx, CommSize
                int 21h
                jmp CHECK3
        
        CommDown3:
            mov ah, 9
            ; Check End of file
                cmp dx, offset M16
                jnz NotEOF3
                mov dx, offset M1
                sub dx, CommSize
            NotEOF3:
                add dx, CommSize
                int 21h
                jmp CHECK3
        
        Selected3:
            ; Detecting index of selected command
            mov ax, dx
            mov bl, CommSize
            div bl                                      ; Op=byte: AL:=AX / Op 
            mov selectedMem, al
            add selectedMem, '0'                       ; to convert digit to Ascii
            

            ; Set Cursor
            mov ah,2
            mov dx,0100h
            int 10h
            
            jmp s1
            
            l2: cmp al,2                              ; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                
            mov ah,2       ; Set Cursor
            mov dx,0100h
            int 10h  
            
            
            
            
            
            mov ah,0Ah                   ; display message to enter Value
            mov dx,offset num 
            int 21h    
            
            mov cl,num+1                 ;Get string size
            mov size,cl
            mov ch,0
            mov si,2                     ;si to get first number from string that is not zero
            
            mov di,2  
            
hoop2:      mov dl,num[di]               ; this loop to check zero in the first string
            sub dl,30h
            cmp dl,0 
            jne hoop1
            inc si
            mov cl,size
            dec cl
            mov size,cl 
            inc di
            jmp hoop2
            
  hoop1:    cmp cl,4         ;check that value is hexa or Get error    
            jng sk 
            
 
            mov ah, 9               ; display error message and exit
            mov dx, offset error
            int 21h
            jmp Exit
            sk:
            
            
            
            mov Bl,size              ; loops to check num from 1 to 9 and A to F
            numloop: 
 
            mov al,num[si] 
            cmp al,30H
            jnge notnum 
            cmp al,39h
            jnle notnum
            sub al,30h  
            jmp done   
            
            notnum: cmp al,41H
            jnge notcharnum
            cmp al,46h
            jnle notcharnum
            sub al,37h
            jmp done  
             
            notcharnum: cmp al,61H
            jnge notcharnum
            cmp al,66h
            jnle notcharnum
            sub al,57h
            jmp done
            
            mov ah, 9                  ; error if it's not number
            mov dx, offset error
            int 21h 
            
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
            
            add valuex,ax  
            
            dec Bl                    ; check to exit 
            cmp Bl,0   
            je Exit 
            
            jmp numloop    
            
        Exit:
            ; Return to dos
            mov ah,4ch
            int 21h
        s1:

    MAIN ENDP
    END MAIN


    ; from line 300 to 412 , Value Part
    ;IN Data Segment , num db 30,?,30 DUP(?)       
  ;                   valuex dw 0      
   ;                  size db ?
   ;             error db 13,10,"Error Input",'$'  