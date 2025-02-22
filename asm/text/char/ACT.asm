ACT:
    @next = act_var+0
    @y = act_var+1

    ; --------
    ; Change state
    ; --------
    ; stop dialog (using the DB char)
    JSR DB
    ; input_mode = IM_ACT
    LDA #IM_ACT
    STA input_mode
    ; act_select = 0
    LDA #$00
    STA act_select
    ; act_nchoice = 0
    STA act_nchoice
    ; async display act box
    LDA act_flag
    ORA #ACT_FLAG_DRAW
    STA act_flag

    ; --------
    ; Read and buffer choices
    ; --------
    ; next = true
    LDX #$FF
    STX @next
    ; x = 0
    INX
    ; while next
    @while:
        LDA @next
        BEQ @while_end
        ; j = read_jump()
        JSR read_jump
        ; n = j.next
        LDA jmp_buf+JMPADR_POS_NEXT
        AND #JMPADR_MASK_NEXT
        STA @next
        ; if not j.c
        LDA jmp_buf_cond
            ; continue
            BEQ @while
        ; act_buf[x].j = j
        LDA jmp_buf+0
        STA act_buf, X
        LDA jmp_buf+1
        STA act_buf+1, X
        LDA jmp_buf+2
        STA act_buf+2, X
        ; act_buf[x].l = read_line()
        TXA
        TAY
        @line:
            ; c = read_char()
            STY @y
            JSR read_char
            LDY @y
            ; if c != FNT && c == special char
            CMP #SPE_CHR::FNT
            BEQ :+
            CMP #$20
                ; break
                blt @line_end
            :
            ; act_buf[x].l += c
            STA act_buf+3, Y
            INY
            ; continue
            JMP @line
        @line_end:
        ; act_buf[x].l += LB (close string)
        LDA #SPE_CHR::LB
        STA act_buf+3, Y
        ; x++
        TXA
        add #ACT_ONE_CHOICE_SIZE
        TAX
        ; act_nchoice++
        INC act_nchoice
        ; continue
        JMP @while
    @while_end:

    ; return
    @ret:
    RTS
