do_db_transistion:
    ; set bank
    push mmc5_banks+0
    LDA #IMG_BUF_BNK
    STA mmc5_banks+0
    STA MMC5_RAM_BNK
    ; draw buffer 2 if needed
    LDA img_flag
    AND #IMG_FLAG_OTHERNT
    BEQ :+
        ; draw buffer 2
        JSR copy_buf_1_to_2
        JSR display_buf_2
        ; wait draw end
        @db_anim_wait:
            LDA packet_buf_read_adr+1
            CMP packet_buf_write_adr+1
            BNE @db_anim_wait
            LDA packet_buf_read_adr+0
            CMP packet_buf_write_adr+0
            BNE @db_anim_wait
        ; update visual
        JSR update_visual_now
    :

    ; adr = $2260
    mov tmp+0, #$60
    mov tmp+1, #$C2 ; + high priority + no mmc5
    ; data_lo.l = 0
    ; data_hi.l = 0
    LDA #$00
    STA tmp+6
    STA tmp+4
    ; if dialog box was on
    LDA effect_flags
    AND #EFFECT_FLAG_DIALOG
    BNE :+
        mov tmp+1, #$82 ; + high priority
        ; disable pal split
        and_adr effect_flags, #$FF-EFFECT_FLAG_PAL_SPLIT
        ; data_lo.h = IMG_BUF_LO_ADR+$200
        ; data_hi.h = IMG_BUF_HI_ADR+$200
        mov tmp+7, #>(IMG_BUF_LO_ADR+$200)
        mov tmp+5, #>(IMG_BUF_HI_ADR+$200)
        ; clear ppu tile of db
        JSR send_box_update
        JMP :++
    ; else
    :
        ; data_lo.h = DB_ADR_LO
        ; data_hi.h = DB_ADR_HI
        mov tmp+7, #>(DB_ADR_LO)
        mov tmp+5, #>(DB_ADR_HI)
        ; set ppu tile of db
        JSR send_box_update
        ; enable pal split and update mmc5 tiles
        ora_adr effect_flags, #EFFECT_FLAG_PAL_SPLIT
        LDX #$00
        @mmc5:
            LDA DB_ADR_HI, X
            STA MMC5_EXP_RAM+$260, X
            INX
            BNE @mmc5
    :
    ; clear db_toggle_flag
    and_adr effect_flags, #$FF-EFFECT_FLAG_DB_ANIM
    ;
    LDA txt_flags
    AND #$FE
    STA txt_flags
    ; restore bank
    pull mmc5_banks+0
    STA MMC5_RAM_BNK
    ; return
    RTS


copy_buf_1_to_2:
    ; for
    LDX #$00
    @for:
        ; copy
        LDA IMG_BUF_LO_ADR+$000, X
        STA IMG_BUF2_LO_ADR+$000, X
        LDA IMG_BUF_LO_ADR+$100, X
        STA IMG_BUF2_LO_ADR+$100, X
        LDA IMG_BUF_LO_ADR+$200, X
        STA IMG_BUF2_LO_ADR+$200, X
        LDA IMG_BUF_HI_ADR+$000, X
        STA IMG_BUF2_HI_ADR+$000, X
        LDA IMG_BUF_HI_ADR+$100, X
        STA IMG_BUF2_HI_ADR+$100, X
        LDA IMG_BUF_HI_ADR+$200, X
        STA IMG_BUF2_HI_ADR+$200, X
        ; continue
        INX
        BNE @for
    ; return
    RTS


display_buf_2:
    ; set ppu tile of db
    @adr = tmp+0
    @data_hi = tmp+4
    @data_lo = tmp+6
    mov @adr+0, #<$C460 ; $2460+prio+nommc5
    mov @adr+1, #>$C460
    mov @data_lo+0, #<IMG_BUF2_LO_ADR
    mov @data_lo+1, #>IMG_BUF2_LO_ADR
    mov @data_hi+0, #<IMG_BUF2_HI_ADR
    mov @data_hi+1, #>IMG_BUF2_HI_ADR
    mov tmp+8, #24
    JSR send_box_update_n
    ; return
    RTS
