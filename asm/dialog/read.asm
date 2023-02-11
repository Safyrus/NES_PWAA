
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
    LDA #<(MMC5_EXP_RAM+$282)
    STA print_ext_ptr+0
    LDA #>(MMC5_EXP_RAM+$282)
    STA print_ext_ptr+1
    ; init ptr to ppu
    LDA #<(PPU_NAMETABLE_0+$282)
    STA print_ppu_ptr+0
    LDA #>(PPU_NAMETABLE_0+$282)
    STA print_ppu_ptr+1

    PLA
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
        BEQ @fade_end
            JMP @end
        @fade_end:

        ; if wait flag
        LDA txt_flags
        AND #TXT_FLAG_WAIT
        BEQ @no_wait_flag
            ; then check if user press any input or that force flag is set
            LDA txt_flags
            AND #(TXT_FLAG_INPUT + TXT_FLAG_FORCE)
            BNE @wait_input
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
        BEQ @delay_end
        @delay_not_0:
            ; then delay -= 1
            DEC txt_delay
            ; and stop
            JMP @end
        @delay_end:

        ; if speed != 0
        LDA txt_speed_count
        BEQ @speed_is_0
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
        BCC @special_char
        @normal_char:
            ; print(c)
            JSR print_char
            ; break
            JMP @end
        ; else
        @special_char:
            ; save char
            PHA
            ; debug print
            JSR print_char

            ; - - - - - - - -
            ; switch (c)
            ; - - - - - - - -
            ; get switch index
            PLA
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

            ; case END
            @END_char:
                ; should not occure, so jump forever
                JSR print_flush
                JMP @END_char
                RTS
            ; case LB
            @LB:
                ; go to next line
                JSR print_lb
                RTS
            ; case DB
            @DB:
                ; set flag to wait for user input to continue
                LDA txt_flags
                ORA #TXT_FLAG_WAIT
                STA txt_flags
                RTS
            ; case FDB
            @FDB:
                ; set flag to wait for user input to continue
                ; and set force flag to ignore player input
                LDA txt_flags
                ORA #(TXT_FLAG_WAIT + TXT_FLAG_FORCE)
                STA txt_flags
                RTS
            ; case TD
            @TD:
                ; toggle flag to display dialog box
                LDA effect_flags
                EOR #EFFECT_FLAG_HIDE
                STA effect_flags
                ;
                AND #EFFECT_FLAG_HIDE
                BEQ @td_on
                @td_off:
                    JSR frame_decode
                    ; set text bank
                    LDA #TEXT_BUF_BNK
                    STA MMC5_RAM_BNK
                    RTS
                @td_on:
                    JSR draw_dialog_box
                    RTS
            ; case SET
            @SET:
                JSR read_next_char
                JMP set_dialog_flag
            ; case CLR
            @CLR:
                JSR read_next_char
                JMP clear_dialog_flag
            ; case SCR
            ; @SCR:
            ;     ; toggle scroll flag
            ;     LDA effect_flags
            ;     EOR #EFFECT_FLAG_SCROLL
            ;     STA effect_flags
            ;     ; set scroll timer
            ;     LDA #$FF
            ;     STA scroll_timer
            ;     RTS
            ; case SAK
            @SAK:
                ; set shake timer
                LDA #$1E
                STA shake_timer
                RTS
            ; case SPD
            @SPD:
                ; spd = next_char() - 1
                JSR read_next_char
                SEC
                SBC #$01
                STA txt_speed
                RTS
            ; case DL
            @DL:
                ; delay = next_char()*2
                JSR read_next_char
                ASL
                STA txt_delay
                RTS
            ; case NAM
            @NAM:
                ; name = next_char()
                JSR read_next_char
                STA txt_name
                RTS
            ; case FLH
            @FLH:
                ; flash_color = next_char()
                ; JSR read_next_char
                ; STA flash_color
                ; set flash timer
                LDA #$FF
                STA scroll_timer
                RTS
            ; case FI
            @FI:
                ; fade_color = next_char()
                ; JSR read_next_char
                ; STA fade_color
                ; set fade timer
                LDA #FADE_TIME
                STA fade_timer
                ; set fade in flag
                LDA effect_flags
                ORA #EFFECT_FLAG_FADE
                STA effect_flags
                RTS
            ; case FO
            @FO:
                ; fade_color = next_char()
                ; JSR read_next_char
                ; STA fade_color
                ; set fade timer
                LDA #FADE_TIME
                STA fade_timer
                ; set fade out flag
                LDA effect_flags
                AND #($FF - EFFECT_FLAG_FADE)
                STA effect_flags
                RTS
            ; case COL
            @COL:
                ; print_ext_val & 0x3F
                LDA print_ext_val
                AND #$3F
                STA print_ext_val
                ; col = next_char()
                JSR read_next_char
                ; (col-1) << 6
                SEC
                SBC #$01
                AND #$03
                CLC
                ROR
                ROR
                ROR
                ; print_ext_val | col
                ORA print_ext_val
                STA print_ext_val
                RTS
            ; case BC
            @BC:
                ; txt_bck_color = next_char()
                JSR read_next_char
                STA txt_bck_color
                RTS
            ; case BIP
            @BIP:
                ; txt_bip = next_char()
                JSR read_next_char
                STA bip
                RTS
            ; case MUS
            @MUS:
                ; m = next_char()
                JSR read_next_char
                STA music
                ; play_music(m)
                ; TODO
                RTS
            ; case SND
            @SND:
                ; s = next_char()
                JSR read_next_char
                STA sound
                ; play_sound(s)
                ; TODO
                RTS
            ; case PHT
            @PHT:
                ; photo = next_char()
                JSR read_next_char
                STA img_photo
                RTS
            ; case CHR
            @CHR:
                ; character = next_char()
                JSR read_next_char
                STA img_character
                ;
                JSR find_anim
                ; set text bank
                LDA #TEXT_BUF_BNK
                STA MMC5_RAM_BNK
                RTS
            ; case ANI
            @ANI:
                ; character_animation = next_char()
                JSR read_next_char
                STA img_animation
                ;
                JSR find_anim
                ; set text bank
                LDA #TEXT_BUF_BNK
                STA MMC5_RAM_BNK
                RTS
            ; case BKG
            @BKG:
                ; background = next_char()
                JSR read_next_char
                STA img_background
                ;
                JSR find_anim
                ; set text bank
                LDA #TEXT_BUF_BNK
                STA MMC5_RAM_BNK
                RTS
            ; case FNT
            @FNT:
                ; font = next_char()
                JSR read_next_char
                STA txt_font
                RTS
            ; case JMP
            @JMP_char: ; TODO
                ; c = next_char()
                JSR read_next_char
                STA txt_jump_buf+1
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
                JSR read_next_char
                STA txt_jump_buf+2
                ; c = block & 0x40
                AND #$40
                ; if c:
                BEQ @JMP_char_cond_end
                    ; c_idx = next_char()
                    JSR read_next_char
                    ; flag = dialog_flag[c_idx]
                    JSR get_dialog_flag
                    ; if flag clear then break
                    BEQ @JMP_char_end
                @JMP_char_cond_end:
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
            ; case ACT
            @ACT: ; TODO
                JMP @ACT
            ; case BP
            @BP:
                ; for i from 0 to 4
                LDX #$00
                @bp_loop:
                    ; p = next_char()
                    JSR read_next_char
                    ; palette[i] = palette_table[p]
                    JSR set_img_bck_palette
                    ; continue
                    INX
                    CPX #$04
                    BNE @bp_loop
                RTS
            ; case SP
            @SP:
                ; for i from 0 to 4
                LDX #$00
                @sp_loop:
                    ; p = next_char()
                    JSR read_next_char
                    ; palette[i] = palette_table[p]
                    JSR set_img_spr_palette
                    ; continue
                    INX
                    CPX #$04
                    BNE @sp_loop
                RTS
            ; case EVT
            @EVT:
                ; e = next_char()
                JSR read_next_char
                ; jsr event_table[e]
                JMP exec_evt
            ; case EXT
            @EXT:
                ; e = next_char()
                JSR read_next_char
                ; extension_char(e)
                JMP exec_ext
            ; default
            @default:
                ; unknow control char
                RTS
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
