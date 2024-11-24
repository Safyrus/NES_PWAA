; snif_decode(in, bkg_lo, bnk_buf, bkg_hi, spr_buf, palette)
snif_decode:
    ; args
    @in = tmp+0
    @bkg_lo = tmp+2
    @bnk_buf = tmp+4
    @bkg_hi = tmp+6
    @spr_buf = tmp+6
    @palette = tmp+8
    ; var
    @w = tmp+10
    @h = tmp+11
    @n = tmp+12
    @idx = tmp+13
    @mask = @idx
    @y = tmp+14
    @pos_y = @y
    @pos_x = @mask
    @atr = @n

    pushregs
    ; enable NMI_FORCE flag
    ora_adr nmi_flags, #NMI_FORCE

    ; --------
    ; byte 0
    ; --------
    ; Y = 0
    LDY #$00
    ; w = in[Y] & $1F + 1
    LDA (@in), Y
    AND #$1F
    add #$01
    STA @w
    ; r = (in[Y] & $60) >> 5
    LDA (@in), Y
    AND #$60
    LSR
    LSR
    LSR
    LSR
    LSR
    ; MMC5_CHR_UPPER = r
    STA MMC5_CHR_UPPER
    ; don't care about compress bit, assume always set
    ; Y++
    INY

    ; --------
    ; byte 1
    ; --------
    ; h = in[Y] & $1F + 1
    LDA (@in), Y
    AND #$1F
    add #$01
    STA @h
    ; Y++
    INY

    ; --------
    ; backdrop pal byte
    ; --------
    ; n = in[Y] & $80
    LDA (@in), Y
    AND #$80
    STA @n
    ; tmp = in[Y] & $3F
    STY @y
    LDA (@in), Y
    AND #$3F
    ; if tmp != 63
    CMP #63
    BEQ :+
        ; palette[0] = tmp
        LDY #$00
        STA (@palette), Y
    :
    ; Y++
    LDY @y
    INY

    ; --------
    ; pal bytes
    ; --------
    @pal:
        ; if not n
        LDA @n
            ; jmp @pal_end
            BEQ @pal_end
        ; n = in[Y+0] & $80
        LDA (@in), Y
        AND #$80
        STA @n
        ; idx = (in[Y+0] & $40) >> 4
        LDA (@in), Y
        AND #$40
        LSR
        LSR
        LSR
        LSR
        STA @idx
        ; idx |= in[Y+1] >> 6
        INY
        LDA (@in), Y
        AND #$C0
        CLC
        ROL
        ROL
        ROL
        ORA @idx
        ; idx = idx*3 + 1
        STA MMC5_MUL_A
        LDA #$03
        STA MMC5_MUL_B
        LDA MMC5_MUL_A
        STA @idx
        INC @idx
        ; palette[idx+0] = in[Y+0] & $3F
        DEY
        STY @y
        LDA (@in), Y
        AND #$3F
        LDY @idx
        STA (@palette), Y
        LDY @y
        ; palette[idx+1] = in[Y+1] & $3F
        INC @idx
        INY
        STY @y
        LDA (@in), Y
        AND #$3F
        LDY @idx
        STA (@palette), Y
        LDY @y
        ; palette[idx+2] = in[Y+2] & $3F
        INC @idx
        INY
        STY @y
        LDA (@in), Y
        AND #$3F
        LDY @idx
        STA (@palette), Y
        LDY @y
        ; Y += 3
        INY
        ; continue
        JMP @pal
    @pal_end:

    ; --------
    ; bnk bytes
    ; --------
    ; mask = in[Y]
    LDA (@in), Y
    STA @mask
    ; bnk_buf[0] = mask
    STY @y
    LDY #$00
    LDA @mask
    STA (@bnk_buf), Y
    LDY @y
    ; Y++
    INY
    ; i = 1
    LDX #$01
    ; while mask != 0
    @bnk:
        LDA @mask
        BEQ @bnk_end
        ; if mask & 1:
        AND #$01
        BEQ :+
            ; bnk_buf[i] = in[Y]
            STY @y
            LDA (@in), Y
            PHA
            TXA
            TAY
            PLA
            STA (@bnk_buf), Y
            LDY @y
            ; Y++
            INY
        :
        ; mask >>= 1
        LSR @mask
        ; i++
        INX
        ; continue
        JMP @bnk
    @bnk_end:

    ; --------
    ; bkg bytes
    ; --------
    ; in += Y
    TYA
    add_A2ptr @in
    ; rleinc(in, bkg_lo)
    JSR rleinc
    ; rleinc(in, bkg_hi)
    mov tmp+2, @bkg_hi+0
    mov tmp+3, @bkg_hi+1
    JSR rleinc
    JMP @return ; skip sprites for now

    ; --------
    ; spr bytes
    ; --------
    LDY #$00
    ; pos_x = 0
    STY @pos_x
    ; pos_y = 0
    STY @pos_y
    ; atr = 0
    STY @atr
    ; while 1
    @spr:
        ; b = *in
        LDA (@in), Y
        TAX
        ; in++
        inc_16 @in
        ; if b & $80
        TXA
        AND #$80
        BEQ :++
            ; spr_buf[0] = (pos_y << 4) | (b & $0F)
            TXA
            AND #$0F
            STA (@spr_buf), Y
            LDA @pos_y
            ASL
            ASL
            ASL
            ASL
            ORA (@spr_buf), Y
            STA (@spr_buf), Y
            ; spr_buf[1] = in[1]
            INY
            LDA (@in), Y
            STA (@spr_buf), Y
            ; spr_buf[2] = atr
            INY
            LDA @atr
            STA (@spr_buf), Y
            ; spr_buf[3] = (pos_x << 3) | ((b & $70) >> 4)
            INY
            TXA
            AND #$70
            LSR
            LSR
            LSR
            LSR
            STA (@spr_buf), Y
            LDA @pos_x
            ASL
            ASL
            ASL
            ORA (@spr_buf), Y
            STA (@spr_buf), Y
            ; in += 2
            inc_16 @in
            inc_16 @in
            ; spr_buf += 4
            add_A2ptr @spr_buf, #$04
            LDY #$00
            ; pos_x++
            INC @pos_x
            ; if pos_x == w
            LDA @pos_x
            CMP @w
            BNE :+
                ; pos_x = 0
                STY @pos_x
                ; pos_y++
                INC @pos_y
                ; if pos_y == h
                LDA @pos_y
                CMP @h
                BNE :+
                    ; pos_y = 0
                    STY @pos_y
            :
            JMP @continue
        ; else
        :
            TXA
            AND #$0C
            ; if b & $0C == 3
            CMP #$03
            BNE :+
                ; pos_x = (b & $01) << 4
                TXA
                AND #$01
                ASL
                ASL
                ASL
                ASL
                STA @pos_x
                ; pos_y = (b & $02) << 3
                TXA
                AND #$02
                ASL
                ASL
                ASL
                STA @pos_y
                ; pos_x |= *in >> 4
                LDA (@in), Y
                LSR
                LSR
                LSR
                LSR
                ORA @pos_x
                STA @pos_x
                ; pos_y |= *in & $0F
                LDA (@in), Y
                AND #$0F
                ORA @pos_y
                STA @pos_y
                ; in++
                inc_16 @in
                JMP @continue
            ; elif b & $0C == 2
            :
            CMP #$02
            BNE :+
                ; atr &= $FC
                LDA @atr
                AND #$FC
                STA @atr
                ; atr |= b & $03
                TXA
                AND #$03
                ORA @atr
                STA @atr
                JMP @continue
            ; elif b & $0C == 1
            :
            CMP #$01
            BNE @spr_end
                ; atr &= $3F
                LDA @atr
                AND #$3F
                STA @atr
                ; atr |= b << 6
                TXA
                ASL
                ASL
                ASL
                ASL
                ASL
                ASL
                ORA @atr
                STA @atr
                JMP @continue
            ; else
                ; break
        ; continue
        @continue:
        JMP @spr
    @spr_end:

    @return:
    ; disable NMI_FORCE flag
    and_adr nmi_flags, #($FF-NMI_FORCE)
    ; return
    pullregs
    RTS
