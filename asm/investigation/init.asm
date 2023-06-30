; ***********************
; TODO: refactor variable
; ***********************

investigation_init:
    pushregs

    @ptr_idx = invest_tmp+0
    @x = invest_tmp+1
    @y = invest_tmp+2
    @w = invest_tmp+3
    @h = invest_tmp+4

    ; enable NMI_FORCE flag
    ora_adr nmi_flags, #NMI_FORCE

    ; clear previous collisions
    JSR clear_collisions

    LDA #TEXT_BUF_BNK
    STA mmc5_banks+0
    STA MMC5_RAM_BNK

    ; next = true
    ; ptr_idx = 0
    mov @ptr_idx, #$00
    ; while(next):
    @while:
        ; First character
        ; A = read_next()
        JSR read_next_char
        ; push next
        PHA
        ; y_pos = A
        PHA
        ; y_pos = (y_pos << 4) & $10
        shift ASL, 4
        AND #$10
        STA @y
        ; x_pos = A >> 1
        PLA
        LSR
        AND #$1F
        STA @x

        ; # Second character
        ; A = read_next()
        JSR read_next_char
        ; w = A
        PHA
        ; w = (w << 2) & $1C
        shift ASL, 2
        AND #$1C
        STA @w
        ; y_pos |= A >> 3
        PLA
        shift LSR, 3
        ORA @y
        STA @y

        ; # Third character
        ; A = read_next()
        JSR read_next_char
        ; h = A
        PHA
        STA @h
        ; w |= A >> 5
        shift LSR, 5
        ORA @w
        STA @w
        ; h &= $1F
        PLA
        AND #$1F
        STA @h

        ; Read jump address
        ; jmp_adr = read_jmp()
        JSR read_next_jmp
        ; set bank
        push mmc5_banks+0
        LDA #IMG_BUF_BNK
        STA mmc5_banks+0
        STA MMC5_RAM_BNK
        ; collision_jumps[ptr_idx]
        LDX @ptr_idx
        STX MMC5_MUL_A
        LDX #$03
        STX MMC5_MUL_B
        LDX MMC5_MUL_A
        ; collision_jumps[ptr_idx] = jmp_adr
        LDA txt_jump_buf+0
        STA HITBOX_ADR, X
        INX
        LDA txt_jump_buf+1
        STA HITBOX_ADR, X
        INX
        LDA txt_jump_buf+2
        STA HITBOX_ADR, X
        ; ptr_idx++
        INC @ptr_idx

        ; Draw collision on map
        JSR draw_collision

        ; restore bank
        pull mmc5_banks+0
        STA MMC5_RAM_BNK
        ; loop
        PLA
        ASL
        BPL @end
        JMP @while
    @end:

    ; cursor
    LDA #$80
    STA cursor_x
    STA cursor_y

    ora_adr click_flag, #CLICK_INIT

    ; disable NMI_FORCE flag
    and_adr nmi_flags, #($FF-NMI_FORCE)

    pullregs
    RTS
