; return in A the char read and increase the ptr
; change Y to 0
read_next_char:
    ; get char at txt_rd_ptr
    LDY #$00
    LDA (txt_rd_ptr), Y
    ; txt_rd_ptr += 1
    inc_16 txt_rd_ptr
    ; save char
    TAY
    ; if txt_rd_ptr is out of the text block
    LDA txt_rd_ptr+1
    BPL @end
        ; lz_ret = caller address
        ; PLA
        ; STA lz_ret+0
        ; PLA
        ; STA lz_ret+1
        ; lz_idx += 1
        INC lz_idx
        ; reset lz decoding
        JSR lz_init
        ;
        sta_ptr txt_rd_ptr, MMC5_RAM
        ; async lz_decode()
        ora_adr txt_flags, #TXT_FLAG_LZ
        JSR lz_decode
        and_adr txt_flags, #($FF-TXT_FLAG_LZ)
        ; push back caller address
        ; LDA lz_ret+1
        ; PHA
        ; LDA lz_ret+0
        ; PHA
        ; save last char read
        ; TYA
        ; STA lz_ret_chr
        ;
        ; JMP read_text_end ; return if async lz() has been called
        ; ; change last bit to signifie bank change
        ; ; (works because char are 7-bit)
        ; ORA #$80
        ; TAY
    @end:
    ; retreive char
    TYA
    RTS


read_next_dailog:
    PHA
    ; init ptr to ext ram
    sta_ptr print_ext_ptr, (MMC5_EXP_RAM+$282)
    ; init ptr to ppu
    sta_ptr print_ppu_ptr, (PPU_NAMETABLE_0+$282)
    ; save adr
    mov txt_last_dialog_adr+0, txt_rd_ptr+0
    mov txt_last_dialog_adr+1, txt_rd_ptr+1
    mov txt_last_dialog_adr+2, lz_idx
    ; return
    PLA
    RTS

read_next_jmp:
    ; c = next_char()
    JSR read_next_char
    STA txt_jump_buf+1
    STA txt_jump_flag_buf
    ; adr_lo = (c << 7) & 0xFF
    ROR
    ROR
    AND #$80
    STA txt_jump_buf+0
    ; adr_hi = ((next_char() >> 1) & 0x1F) | 0x60
    LDA txt_jump_buf+1
    LSR
    AND #$1F
    ORA #$60
    STA txt_jump_buf+1
    ; adr_lo += next_char()
    JSR read_next_char
    ORA txt_jump_buf+0
    STA txt_jump_buf+0
    ; block = next_char()
    LDA txt_jump_flag_buf
    ASL
    AND #$80
    STA txt_jump_flag_buf
    JSR read_next_char
    STA txt_jump_buf+2
    ORA txt_jump_flag_buf
    STA txt_jump_flag_buf
    ; clear negative flag
    LDA #$00
    @end:
    RTS

read_jump:
    ; txt_rd_ptr = adr_lo, adr_hi
    mov_ptr txt_rd_ptr, txt_jump_buf
    ; block = lz_bnk_table[block]
    LDA txt_jump_buf+2
    AND #$3F
    CMP lz_idx
    STA lz_idx
    STA txt_jump_buf+2
    BNE @lz
    ; if block != current_block:
    TAX
    LDA lz_bnk_table, X
    CMP lz_in_bnk
    BEQ @JMP_char_end
    @lz:
        ; reset lz decoding
        JSR lz_init
        ; async lz_decode()
        ora_adr txt_flags, #TXT_FLAG_LZ
    @JMP_char_end:
    RTS


.segment "LAST_BNK"
; /!\ don't save registers
read_bip:
    ; if bip = 0 then break
    LDA bip
    bze @end
    ; if bip already play then break
    LDX #FAMISTUDIO_SFX_CH0
    LDA famistudio_sfx_ptr_hi, X
    bnz @end
    ; push bank
    LDA mmc5_banks+SFX_BNK_OFF
    PHA
    ; set the correct sfx bank
    mov mmc5_banks+SFX_BNK_OFF, #SFX_BNK
    STA MMC5_RAM_BNK+SFX_BNK_OFF
    ; sfx_play(bip)
    LDA bip
    sub #$01
    JSR famistudio_sfx_play
    ; pull bank
    PLA
    STA mmc5_banks+SFX_BNK_OFF
    STA MMC5_RAM_BNK+SFX_BNK_OFF
    ; return
    @end:
    RTS

; description:
;   Read text from memory and "execute" it.
; /!\ assume to be in bank 0
; /!\ change ram bank
read_text:
    pushregs

    ; set text bank
    mov MMC5_RAM_BNK, #TEXT_BUF_BNK

    ; while not print 1 character
    @loop:
        ; - - - - - - - -
        ; guard condition (delay, animation, etc.)
        ; - - - - - - - -

        ; if we are ready
        LDA txt_flags
        AND #TXT_FLAG_READY
        BNE :+
            JMP read_text_end
        :

        ; if we need to wait for time consomming task to end
        ; (draw dialog box, lz decoding and printing characters)
        LDA txt_flags
        AND #(TXT_FLAG_LZ + TXT_FLAG_BOX + TXT_FLAG_PRINT)
        bze :+
            JMP read_text_end
        :
        ; if we are in investigation mode
        LDA click_flag
        bze :+
            JMP read_text_end
        :
        @fps_label:

        ; if we need to jump back at a special character
        ; (because the instruction was cut mid bank)
        ; if lz_ret != 0
        LDX lz_ret+0
        BNE @lz_return
        LDA lz_ret+1
        BEQ @lz_return_end
        @lz_return:
            LDY #$00
            ; push return address + lz_ret = 0
            LDA lz_ret+1
            PHA
            STY lz_ret+1
            LDA lz_ret+0
            PHA
            STY lz_ret+0
            ; A = lz_ret_chr
            LDA lz_ret_chr
            ; rts trick
            RTS
        @lz_return_end:

        ; fade guard
        LDA fade_timer
        bze :+
            JMP @end
        :

        ; choice guard
        LDA max_choice
        bze :+
            JMP @end
        :

        ; if wait flag
        LDA txt_flags
        AND #TXT_FLAG_WAIT
        bze @no_wait_flag
            ; then check if user press any input or that force flag is set
            LDA txt_flags
            AND #(TXT_FLAG_INPUT + TXT_FLAG_FORCE)
            ; if not, then stop
            bze @end
            ; else
            @input:
                ; else, clear flags (wait, input, force)
                and_adr txt_flags, #($FF - TXT_FLAG_WAIT - TXT_FLAG_INPUT - TXT_FLAG_FORCE)
                ; and clear dialog box (if dialog box not hidden)
                BIT box_flags
                BMI @input_boxhidden
                    ; async refresh_dialog_box()
                    ora_adr box_flags, #BOX_FLAG_REFRESH
                    ora_adr txt_flags, #TXT_FLAG_BOX
                @input_boxhidden:
                JSR read_next_dailog
        @no_wait_flag:

        ; if delay > 0
        LDA txt_delay
        bze @delay_end
        @delay_not_0:
            ; then delay -= 1
            DEC txt_delay
            ; and stop
            JMP @end
        @delay_end:

        ; if speed != 0
        LDA txt_speed_count
        bze @speed_is_0
        @speed_not_0:
            DEC txt_speed_count
            JMP @end
        @speed_is_0:
            LDA txt_speed
            STA txt_speed_count
        @speed_end:

        ; - - - - - - - -
        ; main part
        ; - - - - - - - -
        @start:
        ; c = next_char()
        JSR read_next_char

        ; if c is graphic char:
        CMP #$20
        blt @special_char
        @normal_char:
            ; print(c)
            JSR print_char
            ; break
            JMP @end
        ; else
        @special_char:
            ; debug print
            ; JSR print_char

            ; if TXT_FLAG_SKIP
            BIT txt_flags
            BVC :+
                ; if c == TD|SET|CLR|FAD then skip char
                CMP #SPE_CHR::TD
                BEQ @end
                CMP #SPE_CHR::SET
                BEQ @skip_1chr
                CMP #SPE_CHR::CLR
                BEQ @skip_1chr
                CMP #SPE_CHR::FAD
                BEQ @end
                JMP :+

                @skip_1chr:
                JSR read_next_char
                JMP @end
            :

            ; - - - - - - - -
            ; switch (c)
            ; - - - - - - - -
            ; get switch index
            TAX
            ; push return adr
            LDA #>(@loop-1)
            PHA
            LDA #<(@loop-1)
            PHA
            ; push jump adr
            LDA read_text_switch_hi, X
            PHA
            LDA read_text_switch_lo, X
            PHA
            ; jump
            RTS

    @end:
    sta_ptr lz_ret, 0
read_text_end:
    ; flush any text if needed
    LDA print_counter
    BEQ :+
        ora_adr txt_flags, #TXT_FLAG_PRINT
    :
    ; pull registers
    pullregs
    RTS

    .include "spe_chr/ACT.asm"
    .include "spe_chr/ANI.asm"
    .include "spe_chr/BC.asm"
    .include "spe_chr/BIP.asm"
    .include "spe_chr/BKG.asm"
    .include "spe_chr/BP.asm"
    .include "spe_chr/CHR.asm"
    .include "spe_chr/CLR.asm"
    .include "spe_chr/COL.asm"
    .include "spe_chr/DB.asm"
    .include "spe_chr/DL.asm"
    .include "spe_chr/END.asm"
    .include "spe_chr/EVT.asm"
    .include "spe_chr/EXT.asm"
    .include "spe_chr/FDB.asm"
    .include "spe_chr/FAD.asm"
    .include "spe_chr/FLH.asm"
    .include "spe_chr/FNT.asm"
    .include "spe_chr/JMP.asm"
    .include "spe_chr/LB.asm"
    .include "spe_chr/MUS.asm"
    .include "spe_chr/NAM.asm"
    .include "spe_chr/PHT.asm"
    .include "spe_chr/RET.asm"
    .include "spe_chr/SAK.asm"
    .include "spe_chr/SAV.asm"
    .include "spe_chr/SET.asm"
    .include "spe_chr/SND.asm"
    .include "spe_chr/SP.asm"
    .include "spe_chr/SPD.asm"
    .include "spe_chr/TD.asm"
    .include "spe_chr/default.asm"

read_text_switch_lo:
        .byte <(END_char-1)
        .byte <(LB-1)
        .byte <(DB-1)
        .byte <(FDB-1)
        .byte <(TD-1)
        .byte <(SET-1)
        .byte <(CLR-1)
        .byte <(SAK-1)
        .byte <(SPD-1)
        .byte <(DL-1)
        .byte <(NAM-1)
        .byte <(FLH-1)
        .byte <(FAD-1)
        .byte <(SAV-1)
        .byte <(COL-1)
        .byte <(RET-1)
        .byte <(BIP-1)
        .byte <(MUS-1)
        .byte <(SND-1)
        .byte <(PHT-1)
        .byte <(CHR-1)
        .byte <(ANI-1)
        .byte <(BKG-1)
        .byte <(FNT-1)
        .byte <(JMP_char-1)
        .byte <(ACT-1)
        .byte <(BP-1)
        .byte <(SP-1)
        .byte <(default-1)
        .byte <(default-1)
        .byte <(EVT-1)
        .byte <(EXT-1)
read_text_switch_hi:
        .byte >(END_char-1)
        .byte >(LB-1)
        .byte >(DB-1)
        .byte >(FDB-1)
        .byte >(TD-1)
        .byte >(SET-1)
        .byte >(CLR-1)
        .byte >(SAK-1)
        .byte >(SPD-1)
        .byte >(DL-1)
        .byte >(NAM-1)
        .byte >(FLH-1)
        .byte >(FAD-1)
        .byte >(SAV-1)
        .byte >(COL-1)
        .byte >(RET-1)
        .byte >(BIP-1)
        .byte >(MUS-1)
        .byte >(SND-1)
        .byte >(PHT-1)
        .byte >(CHR-1)
        .byte >(ANI-1)
        .byte >(BKG-1)
        .byte >(FNT-1)
        .byte >(JMP_char-1)
        .byte >(ACT-1)
        .byte >(BP-1)
        .byte >(SP-1)
        .byte >(default-1)
        .byte >(default-1)
        .byte >(EVT-1)
        .byte >(EXT-1)

.segment "CODE_BNK"
