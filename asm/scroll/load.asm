; X, Y = img idx
scroll_load_1:
    ; arguments
    mov tmp+3, #$62
    mov tmp+7, #$68
    mov tmp+9, #$7D
    mov tmp+4, #<$7D00
    mov tmp+5, #>$7D00
    mov tmp+10, #<$6180
    mov tmp+11, #>$6180
    mov tmp+12, #GENERAL_BNK
    ; display_img(...)
    ; return
    JMP display_img


; X, Y = img idx
scroll_load_2:
    ; arguments
    mov tmp+3, #$65
    mov tmp+7, #$6B
    mov tmp+9, #$7D
    mov tmp+4, #<$7D00
    mov tmp+5, #>$7D00
    mov tmp+10, #<($6180+32)
    mov tmp+11, #>($6180+32)
    mov tmp+12, #GENERAL_BNK
    ; display_img(...)
    ; return
    JMP display_img
