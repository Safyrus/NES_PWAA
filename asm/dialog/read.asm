; return in A the char read and increase the ptr
; change Y to 0
read_next_char:
    LDA txt_rd_ptr+0
    STA tmp+0
    LDA txt_rd_ptr+1
    STA tmp+1
    LDY #$00
    LDA (tmp), Y
    inc_16 txt_rd_ptr
    RTS


read_next_dailog:
    PHA

    ; init ptr to ext ram
    sta_ptr print_ext_ptr, (MMC5_EXP_RAM+$282)
    ; init ptr to ppu
    sta_ptr print_ppu_ptr, (PPU_NAMETABLE_0+$282)

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
    RTS

read_jump:
    ; block = lz_bnk_table[block]
    LDA txt_jump_buf+2
    AND #$3F
    TAX
    LDA lz_bnk_table, X
    STA txt_jump_buf+2
    ; txt_rd_ptr = adr_lo, adr_hi
    LDA txt_jump_buf+0
    STA txt_rd_ptr+0
    LDA txt_jump_buf+1
    STA txt_rd_ptr+1
    ; if block != current_block:
    LDA txt_jump_buf+2
    CMP lz_in_bnk
    BEQ @JMP_char_end
        ; lz_in_bnk = block
        STA lz_in_bnk
        ; lz_decode()
        JSR lz_decode
        ; set text bank
        LDA #TEXT_BUF_BNK
        STA MMC5_RAM_BNK
    @JMP_char_end:
    RTS


read_bip:
    ; if bip = 0 then break
    LDA bip
    bze @end
    ; if bip already play then break
    LDX #FAMISTUDIO_SFX_CH0
    LDA famistudio_sfx_ptr_hi, X
    bnz @end
    ;
    LDA mmc5_banks+2
    PHA
    LDA #MUS_BNK
    STA mmc5_banks+2
    STA MMC5_PRG_BNK1
    ;
    LDA bip
    SEC
    SBC #$01
    JSR famistudio_sfx_play
    ;
    PLA
    STA mmc5_banks+2
    STA MMC5_PRG_BNK1
    @end:
    RTS

; description:
;   Read text from memory and "execute" it.
; param:
; - txt_rd_ptr: pointer to current text
; use: tmp[0..1]
; /!\ assume to be in bank 0
; /!\ change ram bank
read_text:
    pushregs

    ; set text bank
    LDA #TEXT_BUF_BNK
    STA MMC5_RAM_BNK

    ; while not print 1 character
    @loop:
        ; - - - - - - - -
        ; guard condition (delay, animation, etc.)
        ; - - - - - - - -

        ; fade guard
        LDA fade_timer
        bze @fade_end
            JMP @end
        @fade_end:

        ; choice guard
        LDA max_choice
        bze @choice_end
            JMP @end
        @choice_end:

        ; if wait flag
        LDA txt_flags
        AND #TXT_FLAG_WAIT
        bze @no_wait_flag
            ; then check if user press any input or that force flag is set
            LDA txt_flags
            AND #(TXT_FLAG_INPUT + TXT_FLAG_FORCE)
            bnz @wait_input
                ; if not, then stop
                JMP @end
            @wait_input:
                ; else, clear flags (wait, input, force)
                LDA txt_flags
                AND #($FF - TXT_FLAG_WAIT - TXT_FLAG_INPUT - TXT_FLAG_FORCE)
                STA txt_flags
                ; and clear dialog box (if dialog box not hidden)
                BIT effect_flags
                BMI @wait_input_boxhidden
                    JSR draw_dialog_box
                @wait_input_boxhidden:
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
            JSR print_char

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
            LDA @switch_hi, X
            PHA
            LDA @switch_lo, X
            PHA
            ; jump
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
            .include "spe_chr/FI.asm"
            .include "spe_chr/FLH.asm"
            .include "spe_chr/FNT.asm"
            .include "spe_chr/FO.asm"
            .include "spe_chr/JMP.asm"
            .include "spe_chr/LB.asm"
            .include "spe_chr/MUS.asm"
            .include "spe_chr/NAM.asm"
            .include "spe_chr/PHT.asm"
            .include "spe_chr/SAK.asm"
            .include "spe_chr/SET.asm"
            .include "spe_chr/SND.asm"
            .include "spe_chr/SP.asm"
            .include "spe_chr/SPD.asm"
            .include "spe_chr/TD.asm"
            .include "spe_chr/default.asm"

    @switch_lo:
        .byte <(@END_char-1)
        .byte <(@LB-1)
        .byte <(@DB-1)
        .byte <(@FDB-1)
        .byte <(@TD-1)
        .byte <(@SET-1)
        .byte <(@CLR-1)
        .byte <(@SAK-1)
        .byte <(@SPD-1)
        .byte <(@DL-1)
        .byte <(@NAM-1)
        .byte <(@FLH-1)
        .byte <(@FI-1)
        .byte <(@FO-1)
        .byte <(@COL-1)
        .byte <(@BC-1)
        .byte <(@BIP-1)
        .byte <(@MUS-1)
        .byte <(@SND-1)
        .byte <(@PHT-1)
        .byte <(@CHR-1)
        .byte <(@ANI-1)
        .byte <(@BKG-1)
        .byte <(@FNT-1)
        .byte <(@JMP_char-1)
        .byte <(@ACT-1)
        .byte <(@BP-1)
        .byte <(@SP-1)
        .byte <(@default-1)
        .byte <(@default-1)
        .byte <(@EVT-1)
        .byte <(@EXT-1)
    @switch_hi:
        .byte >(@END_char-1)
        .byte >(@LB-1)
        .byte >(@DB-1)
        .byte >(@FDB-1)
        .byte >(@TD-1)
        .byte >(@SET-1)
        .byte >(@CLR-1)
        .byte >(@SAK-1)
        .byte >(@SPD-1)
        .byte >(@DL-1)
        .byte >(@NAM-1)
        .byte >(@FLH-1)
        .byte >(@FI-1)
        .byte >(@FO-1)
        .byte >(@COL-1)
        .byte >(@BC-1)
        .byte >(@BIP-1)
        .byte >(@MUS-1)
        .byte >(@SND-1)
        .byte >(@PHT-1)
        .byte >(@CHR-1)
        .byte >(@ANI-1)
        .byte >(@BKG-1)
        .byte >(@FNT-1)
        .byte >(@JMP_char-1)
        .byte >(@ACT-1)
        .byte >(@BP-1)
        .byte >(@SP-1)
        .byte >(@default-1)
        .byte >(@default-1)
        .byte >(@EVT-1)
        .byte >(@EXT-1)

    @end:
    ; pull registers
    pullregs
    ; flush any text
    JMP print_flush
