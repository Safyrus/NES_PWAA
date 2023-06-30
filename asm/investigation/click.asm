investigation_click:
    pushregs

    ; Y = cursor_y >> 3 - 3
    LDA cursor_y
    shift LSR, 3
    sub #$03
    TAY
    ; X = cursor_x >> 3
    LDA cursor_x
    shift LSR, 3
    TAX
    ;
    LDA #IMG_BUF_BNK
    STA mmc5_banks+0
    STA MMC5_RAM_BNK
    ; ptr = get_collision_ptr()
    JSR get_collision_ptr

    ; jmp_idx = collision_map[ptr]
    LDY #$00
    LDA (tmp), Y
    ; if jmp_idx:
    BEQ @end
        ; jmp_idx--
        TAX
        DEX
        ; collision_jumps[jmp_idx]
        STX MMC5_MUL_A
        LDA #$03
        STA MMC5_MUL_B
        LDX MMC5_MUL_A
        ; jmp_adr = collision_jumps[jmp_idx]
        LDA HITBOX_ADR, X
        STA txt_jump_buf+0
        INX
        LDA HITBOX_ADR, X
        STA txt_jump_buf+1
        INX
        LDA HITBOX_ADR, X
        STA txt_jump_buf+2
        ;
        and_adr click_flag, #($FF-CLICK_ENA-CLICK_INIT)
        ; jump_text(jmp_adr)
        JSR read_jump
        ; clear cursor sprite
        LDA #$FF
        for_x @clr_spr, #7
            STA OAM, X
        to_x_dec @clr_spr, #0
    @end:
    pullregs
    RTS
