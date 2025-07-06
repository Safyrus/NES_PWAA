scroll_step:
    ; scroll_px_remain -= scroll_spd
    LDA scroll_px_remain+0
    PHA
    sub scroll_spd
    STA scroll_px_remain+0
    BCS :+
        DEC scroll_px_remain+1
        ; if scroll_px_remain < 0
        BPL :+
            ; scroll_state = SCROLL_STATE_END
            mov scroll_state, #SCROLL_STATE_END
            ; scroll_add(scroll_spd, dir)
            ; return
            PLA
            JMP @scroll
    :

    ; if tile is crossed
    PLA
    AND #%00000111
    sub scroll_spd
    AND #%11111000
    BEQ :+
        ; draw_lines(A)
        EOR #$F8
        add #$08
        JSR scroll_draw
    :

    ; nt_offset += scroll_spd
    LDA nt_offset
    add scroll_spd
    STA nt_offset
    BCS :+
    ; if scroll_dir.ver
    LDA scroll_dir
    AND #$02
    BEQ :++
        ; if nt_offset >= 192
        LDA nt_offset
        CMP #192
        blt :++
            ; nt_offset -= 192
            sub #192
            STA nt_offset
            ; scroll_nt()
            JSR scroll_nt
            JMP :++
    ; else
        ; if nt_offset >= 256
        :
            ; nt_offset -= 256
            ; scroll_nt()
            JSR scroll_nt
    :

    ; scroll_add(scroll_spd, dir)
    @scroll:
    LDX #$00
    LDA scroll_dir
    CMP #SCROLL_DIR_UP
    BNE :+
        LDA scroll_spd
        EOR #$FF
        TAY
        INY
        JMP :+++
    :
    CMP #SCROLL_DIR_DOWN
    BNE :+
        LDY scroll_spd
        JMP :++
    :
    LDY #$00
    LDX scroll_spd
    CMP #SCROLL_DIR_LEFT
    BNE :+
        TXA
        EOR #$FF
        TAX
        INX
    :
    JSR scroll_add

    ; return
    RTS


scroll_step_ppu:
    ; if dir == "UP":
    LDA scroll_dir
    CMP #SCROLL_DIR_UP
    BNE :+++
        ; scroll_ppu_adr -= 32
        LDA scroll_ppu_adr+0
        sub #$20
        STA scroll_ppu_adr+0
        ; if scroll_ppu_adr overflow nametable:
        BCC :+
            JMP @ret
        :
        DEC scroll_ppu_adr+1
        LDA scroll_ppu_adr+1
        AND #$03
        CMP #$03
        BNE :+
            ; scroll_ppu_adr -= 0x0400
            LDA scroll_ppu_adr+1
            sub #$04
            ; scroll_ppu_adr &= 0x0FFF
            AND #$0F
            ; scroll_ppu_adr |= 0x2000
            ORA #$20
            STA scroll_ppu_adr+1
            ; scroll_ppu_adr -= 0x40
            LDA scroll_ppu_adr+0
            sub #$40
            STA scroll_ppu_adr+0
            BCS :+
                DEC scroll_ppu_adr+1
            :
        ; return
        JMP @ret
    :
    ; elif dir == "DOWN":
    CMP #SCROLL_DIR_DOWN
    BNE :++
        ; scroll_ppu_adr += 32
        LDA scroll_ppu_adr+0
        add #$20
        STA scroll_ppu_adr+0
        BCC :+
            INC scroll_ppu_adr+1
        :
        ; if scroll_ppu_adr overflow nametable:
        CMP #$C0
        blt @ret
        LDA scroll_ppu_adr+1
        AND #$03
        CMP #$03
        BNE @ret
            ; scroll_ppu_adr += 0x0800
            LDA scroll_ppu_adr+1
            ADC #$07
            ; scroll_ppu_adr &= 0x0C00
            AND #$0C
            ; scroll_ppu_adr |= 0x2000
            ORA #$20
            STA scroll_ppu_adr+1
            LDA #$00
            STA scroll_ppu_adr+0
        ; return
        JMP @ret
    :
    ; elif dir == "LEFT":
    CMP #SCROLL_DIR_LEFT
    BNE :+
        ; scroll_ppu_adr -= 1
        DEC scroll_ppu_adr+0
        ; if scroll_ppu_adr & 0xE0 < 0x60:
        LDA scroll_ppu_adr+0
        CMP #$60
        bge @ret
            ; scroll_ppu_adr ^= 0x400
            ; scroll_ppu_adr &= 0x041F
            ; scroll_ppu_adr |= 0x2060
            LDA #$7F
            STA scroll_ppu_adr+0
            LDA scroll_ppu_adr+1
            EOR #$04
            AND #$04
            ORA #$20
            STA scroll_ppu_adr+1
        ; return
        JMP @ret
    :
    ; elif dir == "RIGHT":
        ; scroll_ppu_adr += 1
        INC scroll_ppu_adr+0
        ; if scroll_ppu_adr & 0xE0 > 0x7F:
        LDA scroll_ppu_adr+0
        CMP #$80
        blt @ret
            ; scroll_ppu_adr ^= 0x400
            ; scroll_ppu_adr &= 0x0C1F
            ; scroll_ppu_adr |= 0x2060
            LDA #$60
            STA scroll_ppu_adr+0
            LDA scroll_ppu_adr+1
            EOR #$04
            AND #$0C
            ORA #$20
            STA scroll_ppu_adr+1
    @ret:
    ; return
    RTS
