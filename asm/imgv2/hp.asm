draw_hp:
    ; if hp_state == HP_STATE_HIDE
    LDA hp_state
    CMP #HP_STATE_HIDE
        ; return
        BEQ @ret
    
    ; if hp_state == HP_STATE_ENTER
    CMP #HP_STATE_ENTER
    BNE :++
        ; if hp_anim_timer >= HP_BAR_SIZE_PX
        LDA hp_anim_timer
        CMP #HP_BAR_SIZE_PX
        blt :+
            ; hp_state = HP_STATE_SHOW
            mov hp_state, #HP_STATE_SHOW
            ; hp_anim_timer = 0
            mov hp_anim_timer, #$00
            ; return
            RTS
        :
        ; hp_anim_timer += HP_TIMER_STEP
        LDA hp_anim_timer
        add #HP_TIMER_STEP
        STA hp_anim_timer
        ; offset = HP_BAR_SIZE_PX-hp_anim_timer
        LDA #HP_BAR_SIZE_PX
        sub hp_anim_timer
        ; draw_hp_spr(offset)
        ; return
        JMP draw_hp_spr
    :

    ; if hp_state == HP_STATE_EXIT
    CMP #HP_STATE_EXIT
    BNE :++
        ; if hp_anim_timer >= HP_BAR_SIZE_PX
        LDA hp_anim_timer
        CMP #HP_BAR_SIZE_PX
        blt :+
            ; hp_state = HP_STATE_HIDE
            mov hp_state, #HP_STATE_HIDE
            ; hp_anim_timer = 0
            mov hp_anim_timer, #$00
            ; return
            RTS
        :
        ; hp_anim_timer += HP_TIMER_STEP
        LDA hp_anim_timer
        add #HP_TIMER_STEP
        STA hp_anim_timer
        ; offset = hp_anim_timer
        LDA hp_anim_timer
        ; draw_hp_spr(offset)
        ; return
        JMP draw_hp_spr
    :

    ; draw_hp_spr(0)
    ; return
    LDA #$00
    JMP draw_hp_spr

    ; return
    @ret:
    RTS

; param: A = offset
draw_hp_spr:
    @offset = hp_tmp+0
    @chr_offset = hp_tmp+1
    @hp_min_hp_danger = hp_tmp+2
    @hp_min_hp_damage = hp_tmp+2
    @x = hp_tmp+3
    STA @offset

    ;
    mov img_tmp_pals+(7*3)+1, #HP_PAL_0
    mov img_tmp_pals+(7*3)+2, #HP_PAL_1
    mov img_tmp_pals+(7*3)+3, #HP_PAL_2
    ; copy_palettes()
    JSR copy_palettes
    ; update_palettes()
    JSR update_palettes


    ; b = get_res_bnk(HP_START_TILE >> 5)
    LDA #(HP_START_TILE >> 5)
    JSR get_res_bnk
    ; chr_offset = b
    STA @chr_offset
    ; for X from MAX_HP-1 to -1
    LDX #MAX_HP-1
    @for:
        ; sprite order note: NORMAL, DANGER, DAMAGE, EMPTY
        ; hp_type = HP_TYPE_EMPTY
        LDY #HP_TYPE_EMPTY
        ; if hp > X
        CPX hp
        bge @type_end
            ; hp_type = HP_TYPE_NORMAL
            LDY #HP_TYPE_NORMAL
            ; if hp_danger > hp or hp - hp_danger <= X
            LDA hp
            sub hp_danger
            BCC :+
            STA @hp_min_hp_danger
            CPX @hp_min_hp_danger
            blt :++
            :
                ; hp_type = HP_TYPE_DANGER
                LDY #HP_TYPE_DANGER
            :
            ; if hp - hp_damage <= X
            LDA hp
            sub hp_damage
            BCC :+
            STA @hp_min_hp_damage
            CPX @hp_min_hp_damage
            blt :++
            :
                ; hp_type = HP_TYPE_DAMAGE
                LDY #HP_TYPE_DAMAGE
            :
        @type_end:

        ;
        STX @x
        ; spr = res sprite
        LDA res_oam
        TAX
        add #$04
        STA res_oam
        ; x_pos = (7-X) * (8 + PX_BETWEEN_HP)
        LDA #(8 + PX_BETWEEN_HP)
        STA MMC5_MUL_A
        LDA #$07
        sub @x
        STA MMC5_MUL_B
        ; x_pos += 256 - ((7 * (8 + PX_BETWEEN_HP)) + 8)
        LDA #256 - ((7 * (8 + PX_BETWEEN_HP)) + 8)
        add MMC5_MUL_A
        ; if x_pos + offset >= 256
        add @offset
        BCC :+
            ; spr.y = #$FF
            LDA #$FF
            STA OAM+0, X
            JMP :++
        ; else
        :
            ; spr.x = x_pos + offset
            STA OAM+3, X
            ; spr.y = HP_POS_Y
            LDA #HP_POS_Y
            STA OAM+0, X
            ; spr.a = HP_SPR_ATR
            LDA #HP_SPR_ATR
            STA OAM+2, X
            ; spr.t = HP_START_TILE + (hp_type << 1)
            TYA
            add #HP_START_TILE
            ; spr.t |= chr_offset
            ORA @chr_offset
            STA OAM+1, X
        :
        ;
        LDX @x
        ; continue
        DEX
        BPL @for

    ; return
    RTS
