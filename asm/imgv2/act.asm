draw_act_text:
    @font = act_var+0
    @n = act_var+1

    ; @font = 0
    LDA #$00
    STA @font
    ; for n from act_nchoice-1 to 0 (included)
    LDX act_nchoice
    DEX
    STX @n
    @text:
        ; Y, X = n * ACT_ONE_CHOICE_SIZE
        LDA @n
        STA MMC5_MUL_A
        LDA #ACT_ONE_CHOICE_SIZE
        STA MMC5_MUL_B
        LDA MMC5_MUL_A
        TAX
        TAY
        ; copy line
        ; while true
        @line:
            ; c = next_char(act_buf[n].l)
            LDA act_buf+3, X
            INX
            ; if c == FNT
            CMP SPE_CHR::FNT
            BNE :+
                ; @font = next_char(act_buf[n].l)
                LDA act_buf+3, X
                INX
                AND #$3F
                ORA #$C0
                STA @font
                ; continue
                JMP @line
            :
            ; if c is special char
            CMP #$20
                ; break
                blt @line_end
            ; DB_ADR_LO[Y+$23] = c
            STA DB_ADR_LO+$23, Y
            LDA @font
            LSR
            BCC :+
                LDA DB_ADR_LO+$23, Y
                ORA #$80
                STA DB_ADR_LO+$23, Y
            :
            ; DB_ADR_HI[Y+$23] = @font + palette 3
            LDA @font
            LSR
            AND #$3F
            ORA #$C0
            STA DB_ADR_HI+$23, Y
            INY
            ; continue
            JMP @line
        @line_end:
        ; continue
        DEC @n
        BPL @text
    ; return
    RTS
