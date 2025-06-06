display_cr:
    ; async display midbox
    ora_adr txt_flags, #TXT_FLAG_MIDBOX
    ;
    ; reset dialog box variables
    mov text_wait, #$00
    mov text_speed, #MAX_TXT_SPD
    mov text_font, #DEFAULT_TEXT_FONT
    mov text_color, #DEFAULT_TEXT_COLOR
    mov text_lb_offset, #ONE_LINE_OFFSET_7_SPACE
    mov print_offset, #CR_PRINT_OFFSET
    STA print_start
    mov text_box_bnk, #GENERAL_BNK
    mov text_ppu_start+0, #$E0
    mov text_ppu_start+1, #$80
    ;
    mov evi_off_x, #$10
    mov evi_off_y, #$30
    ;
    LDA mmc5_banks+0
    PHA
    ;
    LDA #GENERAL_BNK
    STA mmc5_banks+0
    STA MMC5_RAM_BNK
    ; jump to evidence text
    LDX cr_idx
    LDA evi_jmp_b0, X
    STA jmp_buf+0
    LDA evi_jmp_b1, X
    STA jmp_buf+1
    LDA evi_jmp_b2, X
    STA jmp_buf+2
    JSR text_jump
    ;
    PLA
    STA mmc5_banks+0
    STA MMC5_RAM_BNK
    ; return
    RTS


remove_cr:
    ; disable midbox
    and_adr effect_flags, #$FF-EFFECT_FLAG_MIDBOX
    ;
    mov text_box_bnk, #IMG_BUF_BNK
    mov text_ppu_start+0, #$60
    mov text_ppu_start+1, #$82
    ; undisplay act box
    JSR update_midbox
    ; return
    RTS
