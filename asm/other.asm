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

update_screen_scroll:
    ; PHA
    ; ; update high scroll
    ; and_adr ppu_ctrl_val, #$FE
    ; LDA effect_flags
    ; AND #EFFECT_FLAG_NT
    ; LSR
    ; LSR
    ; ORA ppu_ctrl_val
    ; STA ppu_ctrl_val
    ; STA PPU_CTRL
    ; ; update mmmc5 high upper chr bits
    ; LDA img_header
    ; AND #$03
    ; STA mmc5_upper_chr
    ; ; return
    ; PLA
    BRK
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
    ; or 2 fi dialog box is displayed
    LDA effect_flags
    AND #EFFECT_FLAG_PAL_SPLIT
    BNE :+
        JMP cp_page
    :
    RTS


; A / tmp
; X = result
; A = remainder
; div:
;     LDX #$FF
;     @loop:
;         sub tmp
;         INX
;         BCS @loop
;     BNE @end
;         INX
;     @end:
;     ADC tmp
;     RTS
