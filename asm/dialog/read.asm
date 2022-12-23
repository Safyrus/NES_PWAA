
read_next_dailog:
    PHA

    ; init ptr to ext ram
    LDA #<(MMC5_EXP_RAM+282)
    STA print_ext_ptr+0
    LDA #>(MMC5_EXP_RAM+282)
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

    ; set ptr
    LDA txt_rd_ptr+0
    STA tmp+0
    LDA txt_rd_ptr+1
    STA tmp+1

    ; while not print 1 character
    @loop:
        ; - - - - - - - -
        ; guard condition (delay, animation, etc.)
        ; - - - - - - - -
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
                ; and clear dialog box
                JSR draw_dialog_box
                JSR read_next_dailog
        @no_wait_flag:

        ; - - - - - - - -
        ; main part
        ; - - - - - - - -

        ; load ptr
        LDA txt_rd_ptr+0
        STA tmp+0
        LDA txt_rd_ptr+1
        STA tmp+1
        ; c = next_char()
        LDY #$00
        LDA (tmp), Y
        inc_16 txt_rd_ptr

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

            ; switch (c)
            PLA
            TAX
            LDA @switch_hi, X
            PHA
            LDA @switch_lo, X
            PHA
            RTS

            ; case END
            @END_char:
                ; should not occure, so jump forever
                JSR print_flush
                JMP @END_char
            ; case LB
            @LB:
                ; go to next line
                JSR print_lb
                JMP @loop
            ; case DB
            @DB:
                ; set flag to wait for user input to continue
                LDA txt_flags
                ORA #TXT_FLAG_WAIT
                STA txt_flags
                JMP @loop
            ; case FDB
            @FDB:
                ; set flag to wait for user input to continue
                ; and set force flag to ignore player input
                LDA txt_flags
                ORA #(TXT_FLAG_WAIT + TXT_FLAG_FORCE)
                STA txt_flags
                JMP @loop
            ; case TD
                ; toggle flag to display dialog box
            ; case SCR
                ; set scroll flag
            ; case SPD
                ; spd = next_char()
            ; case DL
                ; delay = next_char()
            ; case NAM
                ; name = next_char()
            ; case FLH
                ; set flash flag
                ; flash_color = next_char()
            ; case FI
                ; set fade in flag
                ; fade_color = next_char()
            ; case FO
                ; set fade out flag
                ; fade_color = next_char()
            ; case COL
                ; txt_color = next_char()
            ; case BC
                ; txt_bck_color = next_char()
            ; case BIP
                ; txt_bip = next_char()
            ; case MUS
                ; m = next_char()
                ; play_music(m)
            ; case SND
                ; s = next_char()
                ; play_sound(s)
            ; case PHT
                ; photo = next_char()
                ; show_photo flag = photo != 0
            ; case CHR
                ; character = next_char()
            ; case ANI
                ; character_animation = next_char()
            ; case BCK
                ; background = next_char()
            ; case FNT
                ; font_adr = font_base_adr + next_char() * 96
            ; case JMP
                ; j1 = next_char()
                ; j2 = next_char()
                ; j3 = next_char()
                ; txt_rd_ptr = j1[0..6] + (j2[0..5] << 7)
                ; block = (j3[0..6] << 1) + j2[6]
                ; if block != current_block:
                    ; lz_in, lz_in_bnk = block_table[block]
                    ; lz_decode()
            ; case ACT
                ; j1 = next_char()
                ; j2 = next_char()
                ; j3 = next_char()
                ; n = next_char()
                ; TODO
            ; case BP
                ; for i from 0 to 4
                    ; p = next_char()
                    ; palette[i] = palette_table[p]
            ; case SP
                ; for i from 4 to 8
                    ; p = next_char()
                    ; palette[i] = palette_table[p]
            ; case EVT
                ; e = next_char()
                ; jsr event_table[e]
            ; case EXT
                ; e = next_char()
                ; extension_char(e)
            ; default
            @default:
                ; unknow control char
                JMP @loop
    @switch_lo:
        .byte <(@END_char-1)
        .byte <(@LB-1)
        .byte <(@DB-1)
        .byte <(@FDB-1)
        .byte <(@default-1)
        .byte <(@default-1)
        .byte <(@default-1)
        .byte <(@default-1)
        .byte <(@default-1)
        .byte <(@default-1)
        .byte <(@default-1)
        .byte <(@default-1)
        .byte <(@default-1)
        .byte <(@default-1)
        .byte <(@default-1)
        .byte <(@default-1)
        .byte <(@default-1)
        .byte <(@default-1)
        .byte <(@default-1)
        .byte <(@default-1)
        .byte <(@default-1)
        .byte <(@default-1)
        .byte <(@default-1)
        .byte <(@default-1)
        .byte <(@default-1)
        .byte <(@default-1)
        .byte <(@default-1)
        .byte <(@default-1)
        .byte <(@default-1)
        .byte <(@default-1)
        .byte <(@default-1)
        .byte <(@default-1)
    @switch_hi:
        .byte >(@END_char-1)
        .byte >(@LB-1)
        .byte >(@DB-1)
        .byte >(@FDB-1)
        .byte >(@default-1)
        .byte >(@default-1)
        .byte >(@default-1)
        .byte >(@default-1)
        .byte >(@default-1)
        .byte >(@default-1)
        .byte >(@default-1)
        .byte >(@default-1)
        .byte >(@default-1)
        .byte >(@default-1)
        .byte >(@default-1)
        .byte >(@default-1)
        .byte >(@default-1)
        .byte >(@default-1)
        .byte >(@default-1)
        .byte >(@default-1)
        .byte >(@default-1)
        .byte >(@default-1)
        .byte >(@default-1)
        .byte >(@default-1)
        .byte >(@default-1)
        .byte >(@default-1)
        .byte >(@default-1)
        .byte >(@default-1)
        .byte >(@default-1)
        .byte >(@default-1)
        .byte >(@default-1)
        .byte >(@default-1)

    @end:
    ; pull registers
    pullregs
    ; flush any text
    JMP print_flush
