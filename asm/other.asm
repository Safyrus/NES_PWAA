; use: A
wait_next_frame:
    ; wait for next frame to start
    @wait_vblank:
        BIT nmi_flags
        BPL @wait_vblank
    ; acknowledge nmi
    and_adr nmi_flags, #($FF-NMI_DONE)
    ; return
    RTS


; tmp+0 = input page
; tmp+2 = output page
; do not save registers
cp_page:
    LDY #$00
    @loop:
        LDA (tmp+0), Y
        STA (tmp+2), Y
    to_y_inc @loop, #0
    RTS


; copy upper tiles from image buffer to MMC5
; do not save registers
cp_mmc5:
    ; set image buffer bank
    LDA #IMG_BUF_BNK
    STA mmc5_banks+0
    STA MMC5_RAM_BNK
    ; output page = MMC5_EXP_RAM+$60
    mov tmp+2, #$60
    mov tmp+3, #>MMC5_EXP_RAM
    ; input page = IMG_BUF_HI_ADR
    mov tmp+0, #$00
    mov tmp+1, #>IMG_BUF_HI_ADR
    ; if other nametable
    LDA img_flag
    AND #IMG_FLAG_OTHERNT
    BEQ :+
        ; input page = IMG_BUF2_HI_ADR
        mov tmp+1, #>IMG_BUF2_HI_ADR
    :
    ; copy 3 pages
    JSR cp_page
    INC tmp+1
    INC tmp+3
    JSR cp_page
    INC tmp+1
    INC tmp+3
    ; or 2 if dialog box is displayed
    LDA effect_flags
    AND #EFFECT_FLAG_DIALOG
    BNE :+
        JMP cp_page
    :
    ; if input mode is act or cr
    LDA input_mode
    CMP #IM_ACT
    BEQ :+
    LDA input_mode
    CMP #IM_CR
    BNE :++
    :
        ; set general bank
        LDA #GENERAL_BNK
        STA mmc5_banks+0
        STA MMC5_RAM_BNK
        ; output page = MMC5_EXP_RAM+$E0
        mov tmp+2, #<(MMC5_EXP_RAM+$E0)
        mov tmp+3, #>(MMC5_EXP_RAM+$E0)
        ; input page = DB_ADR_HI
        mov tmp+0, #<DB_ADR_HI
        mov tmp+1, #>DB_ADR_HI
        ; copy midbox page
        JSR cp_page
    :
    ; return
    RTS


update_shake:
    ; if shake_timer < 0
    LDA shake_timer
        ; return
        BMI @ret

    ; if shake_timer == 0
    LDA shake_timer
    BNE :+
        ; scroll_x, scroll_y = 0
        STA scroll_x
        STA scroll_y
        ; shake_timer = -1
        mov shake_timer, #$FF
        ; return
        RTS
    :

    ; offset = rng() & $0F
    JSR rng
    AND #$0F
    ; offset *= shake_force
    STA MMC5_MUL_A
    LDA shake_force
    STA MMC5_MUL_B
    ; offset /= 8
    LDA MMC5_MUL_A
    LSR
    LSR
    LSR
    ; scroll_x = offset
    STA scroll_x

    ; return
    @ret:
    RTS


; A = wanted bank in region
; return A = CHR bank idx
; Note: the code kinda cheat and will not work
;       if we need to reserved more than 2 banks
get_res_bnk:
    ; find if the same bank is already reserved
    PHA
    CMP res_bnks+7
    BNE :+
        @get_7:
        PLA
        STA res_bnks+7
        DEC n_nonres_bnk
        LDA #$07
        RTS
    :
    CMP res_bnks+6
    BNE :+
        @get_6:
        PLA
        STA res_bnks+6
        DEC n_nonres_bnk
        LDA #$06
        RTS
    :
    ; find the first free one
    LDA #$FF
    CMP res_bnks+7
    BEQ @get_7
    CMP res_bnks+6
    BEQ @get_6
    ; error
    BRK
