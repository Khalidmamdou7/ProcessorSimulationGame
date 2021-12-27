PrintChar MACRO chara
;draw X in the cursor position
    mov ah,0ah
    mov al,chara
    mov bh,0h
    mov bl,0fh
    mov cx,1
    int 10H
ENDM PrintChar
Set MACRO position1, position2
    mov cx,0
    ;set cursor position
    mov ah,2h
    mov bh,0h
    mov dh,position1
    mov dl,position2
    int 10h
ENDM Set

.MODEL SMALL
.Data
.CODE
MAIN PROC FAR
    mov ax,@Data
    mov ds,ax

    mov cx,22
    mov ax, 13h 
    int 10h   ;converting to graphics mode

    ; Drawing the layout
    ; draw the outer horzontal lines 
    mov cx,319
    Layout_horz:
        mov AH,0ch ; set for drawing a pixel
        mov AL,09h ; choose the blue color
        mov BH,0h  ; choose the page number
        mov DX,0Ah ; choose the row position
        INT 10H
        mov DX,09ch ; choose the row position
        INT 10H
        dec CX
    jnz Layout_horz

    ; draw the outer vertical lines, and the middle line
    mov cx,145
    mov DX,0bh ; choose the row position
    Layout_vert:
        mov AH,0ch ; set for drawing a pixel
        mov AL,09h ; choose the blue color
        mov BH,0h  ; choose the page number
        push cx
        mov Cx,319 ; choose the column position (which is constant)
        INT 10H
        mov Cx,0  ; choose the column position (which is constant)
        INT 10H
        mov Cx,160  ; choose the column position (which is constant)
        INT 10H
        pop cx
        inc DX
        dec CX
    jnz Layout_vert


    ;Draw the processors/////////////////////////////////////////////////////

    ;Draw the left processor horizontal lines
    mov cx,130
    processor_1_horz:
        mov AH,0ch ; set for drawing a pixel
        mov AL,0dh ; choose the purble color
        mov BH,0h  ; choose the page number
        mov DX,0fh ; choose the row position
        INT 10H
        mov Dx,8fh ; choose the row position
        INT 10H
        dec CX
    jnz processor_1_horz

    ;Draw the horizontal lines for the right processor
    mov cx,130
    mov bx,190
    process_2_horz:
        mov AH,0ch ; set for drawing a pixel
        mov AL,0eh ; choose the yellow color
        ; push bx
        ; mov BH,0h  ; choose the page number
        ; pop bx
        push cx
        mov cx,bx
        mov DX,0fh ; choose the row position
        INT 10H
        mov DX,8fh ; choose the row position
        INT 10H
        pop cx
        inc bx
        dec CX
    jnz process_2_horz

    ;Draw the vertical lines for both processors
    mov cx,0
    mov DX,0fh ; choose the row position
    mov cx,129
    Process_1_2:
        mov AH,0ch ; set for drawing a pixel
        mov AL,0dh ; choose the purble color
        mov BH,0h  ; choose the page number
        push cx
        mov Cx,130  ; choose the column position (which is constant)
        INT 10H
        mov AL,0eh ; choose the yellow color
        mov Cx,190  ; choose the column position (which is constant)
        INT 10H
        pop cx
        inc DX
        dec CX
    jnz process_1_2

    ;Draw the four registers in the two processors

    ; draw the left ones horizontal lines
    mov bx,0
    mov cx,38
    mov bx,24  ; as this value will be passed to cx for columns positions 
    Registers_left:
        mov ah,0ch
        mov al,0dh ;choose purble color
        ; push bx  ; to save the value of bx in stack
        ; mov bh,0h ; that the page number to be zero
        ; pop bx  ; retrieve the value of bx
        push cx  ; save the value of cx in stack
        mov cx,bx
        mov dx,1fh
        INT 10h
        mov cx,bx
        mov dx,2fh
        INT 10h
        mov cx,bx
        mov dx,3fh
        INT 10h
        mov dx,4fh
        INT 10h
        mov dx,5fh
        INT 10h
        pop cx  ; retrieve the value of cx
        inc bx
        dec cx
    jnz Registers_left

    ; draw the right ones horizontal lines
    mov bx,0
    mov cx,38
    mov bx,257  ; as this value will be passed to cx for columns positions  
    Registers_right:
        mov ah,0ch
        mov al,0eh ;choose yellow color
        ; push bx  ; to save the value of bx in stack
        ; mov bh,0h ; that the page number to be zero
        ; pop bx  ; retrieve the value of bx
        push cx  ; save the value of cx in stack
        mov cx,bx
        mov dx,1fh
        INT 10h
        mov cx,bx
        mov dx,2fh
        INT 10h
        mov cx,bx
        mov dx,3fh
        INT 10h
        mov dx,4fh
        INT 10h
        mov dx,5fh
        INT 10h
        pop cx  ; retrieve the value of cx
        inc bx
        dec cx
    jnz Registers_right


    ;Draw the left, right, middle vertical lines for the first four registers

    mov cx,0
    mov DX,1fh ; choose the row position
    mov cx,65
    registers_vert:
        mov AH,0ch ; set for drawing a pixel
        mov AL,0dh ; choose the purble color
        mov BH,0h  ; choose the page number
        push cx
        mov Cx,24  ; choose the column position (which is constant)
        INT 10H
        mov Cx,43  ; choose the column position (which is constant)
        INT 10H
        mov Cx,62  ; choose the column position (which is constant)
        INT 10H
        mov al,0eh  ;choose yellow color
        mov Cx,257  ; choose the column position (which is constant)
        INT 10H
        mov Cx,295  ; choose the column position (which is constant)
        INT 10H
        pop cx
        inc DX
        dec CX
    jnz registers_vert

    ;Drawing the segment registers////////////////////

    ; draw the horizontal lines for the left ones 
    mov bx,0
    mov cx,38
    mov bx,70  ; as this value will be passed to cx for columns positions 
    segments_left:
        mov ah,0ch
        mov al,0dh ;choose purble color
        ; push bx  ; to save the value of bx in stack
        ; mov bh,0h ; that the page number to be zero
        ; pop bx  ; retrieve the value of bx
        push cx  ; save the value of cx in stack
        mov cx,bx
        mov dx,1fh
        INT 10h
        mov cx,bx
        mov dx,2fh
        INT 10h
        mov cx,bx
        mov dx,3fh
        INT 10h
        mov dx,4fh
        INT 10h
        mov dx,5fh
        INT 10h
        pop cx  ; retrieve the value of cx
        inc bx
        dec cx
    jnz segments_left


    ; draw the horizontal lines right ones 
    mov bx,0
    mov cx,38
    mov bx,211  ; as this value will be passed to cx for columns positions 
    segments_right:
        mov ah,0ch
        mov al,0eh ;choose yellow color
        ; push bx  ; to save the value of bx in stack
        ; mov bh,0h ; that the page number to be zero
        ; pop bx  ; retrieve the value of bx
        push cx  ; save the value of cx in stack
        mov cx,bx
        mov dx,1fh
        INT 10h
        mov cx,bx
        mov dx,2fh
        INT 10h
        mov cx,bx
        mov dx,3fh
        INT 10h
        mov dx,4fh
        INT 10h
        mov dx,5fh
        INT 10h
        pop cx  ; retrieve the value of cx
        inc bx
        dec cx
    jnz segments_right


    ;Draw the vertical lines for the segments
    mov cx,0
    mov DX,1fh ; choose the row position
    mov cx,65
    segments_vert:
        mov AH,0ch ; set for drawing a pixel
        mov AL,0dh ; choose the purble color
        mov BH,0h  ; choose the page number
        push cx
        mov Cx,70  ; choose the column position (which is constant)
        INT 10H
        mov Cx,108  ; choose the column position (which is constant)
        INT 10H
        mov al,0eh  ;choose yellow color
        mov Cx,211  ; choose the column position (which is constant)
        INT 10H
        mov Cx,230  ; choose the column position (which is constant)
        INT 10H
        mov Cx,249  ; choose the column position (which is constant)
        INT 10H
        pop cx
        inc DX
        dec CX
    jnz segments_vert

    ; draw the boxes for users names

    ;draw the horizontal line for first box 
    mov cx,50
    mov bx,38
    Squares_in1:
        mov AH,0ch ; set for drawing a pixel
        mov AL,0dh ; choose the purble color
        ; push bx
        ; mov BH,0h  ; choose the page number
        ; pop bx
        push cx
        mov cx,bx
        mov DX,07fh ; choose the row position
        INT 10H
        pop cx
        inc bx
        dec CX
    jnz Squares_in1

    ;draw the horizontal line for the second box
    mov cx,50
    mov bx,230
    Squares_in2:
        mov AH,0ch ; set for drawing a pixel
        mov AL,0eh ; choose the yellow color
        ; push bx
        ; mov BH,0h  ; choose the page number
        ; pop bx
        push cx
        mov cx,bx
        mov DX,07fh ; choose the row position
        INT 10H
        pop cx
        inc bx
        dec CX
    jnz Squares_in2

    ;Draw the memory
    mov cx,145
    mov DX,0bh ; choose the row position
    memory:
        mov AH,0ch ; set for drawing a pixel
        mov AL,0bh ; choose the blue color
        mov BH,0h  ; choose the page number
        push cx
        mov Cx,135 ; choose the column position (which is constant)
        INT 10H
        mov Cx,150  ; choose the column position (which is constant)
        INT 10H
        mov Cx,170  ; choose the column position (which is constant)
        INT 10H
        mov Cx,185  ; choose the column position (which is constant)
        INT 10H
        pop cx
        inc DX
        dec CX
    jnz memory


    ;Set the names of the registers///////////////////////////////////////////////////////////////////////////
    ;Disaplay the characters for the first processor
    Set 4 1
    PrintChar 'A'
    Set 4 2
    PrintChar 'X'

    Set 6 1
    PrintChar 'B'
    Set 6 2
    PrintChar 'X'

    Set 8 1
    PrintChar 'C'
    Set 8 2
    PrintChar 'X'

    Set 10 1
    PrintChar 'D'
    Set 10 2
    PrintChar 'X'

    ;Disaplay the characters for the second processor
    Set 4 24
    PrintChar 'A'
    Set 4 25
    PrintChar 'X'

    Set 6 24
    PrintChar 'B'
    Set 6 25
    PrintChar 'X'

    Set 8 24
    PrintChar 'C'
    Set 8 25
    PrintChar 'X'

    Set 10 24
    PrintChar 'D'
    Set 10 25
    PrintChar 'X'

    ;Display the characters of the segments registers of the left processor
    Set 4 14
    PrintChar 'S'
    Set 4 15
    PrintChar 'P'

    Set 6 14
    PrintChar 'B'
    Set 6 15
    PrintChar 'P'

    Set 8 14
    PrintChar 'S'
    Set 8 15
    PrintChar 'I'

    Set 10 14
    PrintChar 'D'
    Set 10 15
    PrintChar 'I'

    ;Display the characters of the segments registers of the right processor 
    Set 4 37
    PrintChar 'S'
    Set 4 38
    PrintChar 'P'

    Set 6 37
    PrintChar 'B'
    Set 6 38
    PrintChar 'P'

    Set 8 37
    PrintChar 'S'
    Set 8 38
    PrintChar 'I'

    Set 10 37
    PrintChar 'D'
    Set 10 38
    PrintChar 'I'

    ;/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
MAIN ENDP 
END MAIN 
