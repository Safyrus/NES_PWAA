; scroll_char:
;     ; c = read_char()
;     ; scroll_spd = (c & ??) >> ??
;     mov scroll_spd, #$??
;     ; scroll_dir = (c & ??) >> ??
;     mov scroll_dir, #$??
;     scroll_state = SCROLL_STATE_START
;     mov scroll_state, #SCROLL_STATE_START
;     RTS
;

scroll_start:
    ; scroll_state = SCROLL_STATE_STEP
    mov scroll_state, #SCROLL_STATE_STEP

    ; if scroll_dir is horizontal
    LDA scroll_dir
    AND #$02
    BNE :+
        ; scroll_px_remain = nb_screen*256
        mov scroll_px_remain+1, scroll_n_img
        mov scroll_px_remain+0, #$00
        JMP :++
    ;else
    :
        ; scroll_px_remain = nb_screen*192
        mov MMC5_MUL_A, #192
        mov MMC5_MUL_B, scroll_n_img
        mov scroll_px_remain+0, MMC5_MUL_A
        mov scroll_px_remain+1, MMC5_MUL_B
    :
    DEC scroll_px_remain+0
    LDA scroll_px_remain+0
    CMP #$FF
    BNE :+
        DEC scroll_px_remain+1
    :

    ;
    LDA #$00
    STA tile_offset
    STA nt_offset
    LDA #$80
    STA scroll_pal_flip

    JSR scroll_start_ppu
    JSR scroll_nt
    LDA #$08
    JSR scroll_draw

    ; return
    RTS


scroll_start_ppu:
    ; scroll_ppu_adr = 0x2060
    mov scroll_ppu_adr+0, #$60
    mov scroll_ppu_adr+1, #$20
    ; if other nametable
    LDA img_flag
    AND #IMG_FLAG_OTHERNT
    BNE :+
        ; scroll_ppu_adr |= 0x400
        ora_adr scroll_ppu_adr+1, #$04
    :
    ; if direction is right
    LDA scroll_dir
    CMP #SCROLL_DIR_RIGHT
    BNE :+
        ; scroll_ppu_adr ^= 0x400
        eor_adr scroll_ppu_adr+1, #$04
    :
    ; if direction is down
    LDA scroll_dir
    CMP #SCROLL_DIR_DOWN
    BNE :+
        ; scroll_ppu_adr += 0x300
        LDA scroll_ppu_adr+1
        add #$03
        STA scroll_ppu_adr+1
    :

    ; if dir is LEFT or UP:
    LDA scroll_dir
    AND #$01
    BNE :+
        ; scroll_step_ppu()
        ; return
        JMP scroll_step_ppu
    :
    ; return
    RTS
