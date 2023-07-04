act_display:
    pushregs

    ; text_adr = act_ptr_buf
    mov txt_rd_ptr+0, act_ptr+0
    mov txt_rd_ptr+1, act_ptr+1
    LDX act_ptr+2
    CPX lz_idx
    STX lz_idx
    ; if it is not the same as now then lz
    BNE @lz
    ; if text bank not the same
    LDA lz_bnk_table, X
    CMP lz_in_bnk
    BEQ @lz_end
    @lz:
        ; reset lz decoding
        JSR lz_init
        ; lz_decode()
        ora_adr txt_flags, #TXT_FLAG_LZ
        JSR lz_decode
        and_adr txt_flags, #($FF-TXT_FLAG_LZ)
    @lz_end:
    ; set text bank
    LDA #TEXT_BUF_BNK
    STA MMC5_RAM_BNK
    STA mmc5_banks+0

    JSR draw_court_record_box_only

    ; print_ext_ptr = MMC5_EXP_RAM + $103
    ; print_ppu_ptr = PPU_NAMETABLE_0 + $103
    LDA #$03
    STA print_ext_ptr+0
    STA print_ppu_ptr+0
    LDA #(>MMC5_EXP_RAM)+1
    STA print_ext_ptr+1
    LDA #(>PPU_NAMETABLE_0)+1
    STA print_ppu_ptr+1

    ; while(true)
    @while:
        ; txt_jump_buf = read_next_jmp()
        JSR read_next_jmp

        ; if txt_jump_buf.cond
        BIT txt_jump_flag_buf
        BVC :++
            ; A = read_next_char()
            JSR read_next_char
            ; if not text_flags[A]:
            JSR get_dialog_flag
            BNE :++
            :
                ; skip_until_b()
                JSR read_next_char
                CMP #SPE_CHR::LB
                BNE :-
        :

        ; do
        @print:
            ; c = read_char()
            JSR read_next_char
            ; print(c)
            JSR print_char
        ; while(c != "<b>")
            CMP #SPE_CHR::LB
            BNE @print
        ; flush()
        JSR print_flush

        ; print_ext_ptr += $20
        LDA print_ext_ptr+0
        AND #$E0
        add #$23
        STA print_ext_ptr+0
        ; print_ppu_ptr += $20
        LDA print_ppu_ptr+0
        AND #$E0
        add #$23
        STA print_ppu_ptr+0

        ; if not ptr.next break
        BIT txt_jump_flag_buf
        BMI @while

    @end:
    pullregs
    RTS
