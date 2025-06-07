;################
; File: Main
;################

;--------------------------------
; Function: Main
;--------------------------------
; Main function called just after the reset vector
;--------------------------------
MAIN:
    .include "init.asm"

MAIN_LOOP:
    ; wait for start of frame / acknowledge nmi
    JSR wait_next_frame
    @MAIN_LOOP_START:

    ; ----------------
    ; remove reserved sprites
    ; ----------------
    ; if there is reserved sprites
    LDX res_oam
    BEQ @rm_res_spr_end
        ; for res_oam
        LDA #$FF
        @rm_res_spr:
            ; X--
            DEX
            DEX
            DEX
            DEX
            ; remove OAM[X] sprites
            STA OAM, X
            ; continue
            BNE @rm_res_spr
        ; res_oam = 0
        STX res_oam
        ; for X to 8
        @rm_res_bnk:
            ; remove res_bnks[X]
            STA res_bnks, X
            ; continue
            INX
            CPX #$08
            BNE @rm_res_bnk
        ; n_nonres_bnk = 8
        mov n_nonres_bnk, #$08
    @rm_res_spr_end:

    ;
    JSR change_name

    ; ----------------
    ; Update Inputs
    ; ----------------
    ; get joypad state
    JSR update_input
    ; switch(input_mode)
    LDA input_mode
    ; case IM_NORMAL:
    CMP #IM_NORMAL
    BNE :+
        ; input_normal()
        JSR input_normal
        ; break
        JMP @input_end
    :
    ; case IM_ACT:
    CMP #IM_ACT
    BNE :+
        ; input_act()
        JSR input_act
        ; break
        JMP @input_end
    :
    ; case IM_CR:
    CMP #IM_CR
    BNE :+
        ; input_cr()
        JSR input_cr
        ; break
        JMP @input_end
    :
    @input_end:

    ; ----------------
    ; Update Images
    ; ----------------
    ; if currently drawing an image
    ; TODO: better flag condition ?
    LDA img_flag
    AND #(IMG_FLAG_UNSPRITE)
    BEQ @anim_else
    ; and if packet_buf_read_adr == packet_buf_write_adr
    ; (a.k.a nothing left to draw)
    LDA packet_buf_read_adr+1
    CMP packet_buf_write_adr+1
    BNE @anim_else
    LDA packet_buf_read_adr+0
    CMP packet_buf_write_adr+0
    BNE @anim_else
        ; wait to be at the top of the frame
        @wait_topframe:
            LDA scanline
            CMP #SCANLINE_TOP
            BNE @wait_topframe
        ; change scroll position to other nametable
        ; (we need to change scroll before updating MMC5 tiles)
        LDA ppu_ctrl_val
        EOR #$01
        STA PPU_CTRL
        STA ppu_ctrl_val
        ; copy MMC5 tiles
        JSR cp_mmc5
        ; swap nametable to use
        eor_adr img_flag, #IMG_FLAG_OTHERNT
        ; re-enable sprites update
        LDA img_flag
        AND #$FF-(IMG_FLAG_UNSPRITE)
        STA img_flag
        ; use new palettes
        ; copy_palettes()
        JSR copy_palettes
        ; update_palettes()
        JSR update_palettes
        ; update sprites
        JSR draw_sprites
        JMP @anim_fi
    ; else
    @anim_else:
        ; if new_bkg != cur_bkg
        LDX new_bkg
        CPX cur_bkg
        BEQ @new_bkg_end
            ; remove character
            JSR remove_chr
            ; if background < 0
            LDX new_bkg
            BPL :+
                ; remove background
                JSR remove_bkg
                JMP :++
            :
            ;else
                ; display background
                JSR display_bkg
            :
            ; display_anim(cur_chr)
            LDX cur_chr+0
            LDY cur_chr+1
            JSR display_anim
            ; if cur_chr < 0 (no character)
            LDA cur_chr+1
            BPL :+
                ; update image
                JSR call_update_img
            :
        @new_bkg_end:

        ; if new_chr != cur_chr
        LDY new_chr+1
        LDX new_chr+0
        CPX cur_chr+0
        BNE :+
        CPY cur_chr+1
        BEQ :++++
        :
            ; if new_chr < 0
            TYA
            BPL :+
                ; remove character
                JSR remove_chr
                JSR call_update_img
                JMP :++
            :
            ;else
                ; display_anim(new_chr)
                JSR display_anim
            :
        :

        ; if draw midbox
        LDA txt_flags
        AND #TXT_FLAG_MIDBOX
        BEQ :+++
            ; enable midbox
            ora_adr effect_flags, #EFFECT_FLAG_MIDBOX
            ; backup chr (if not already)
            LDA sav_chr+1
            BPL :+
                mov sav_chr+0, cur_chr+0
                mov sav_chr+1, cur_chr+1
            :
            ; remove char
            LDA #$FF
            STA cur_chr+1
            STA new_chr+1
            JSR remove_chr
            JSR call_update_img
            ; clear midbox
            JSR clear_midbox_no_refresh
            ; if act mode
            LDA input_mode
            CMP #IM_ACT
            BNE :+
                ; draw act text
                JSR draw_act_text
            :
            ; send buffer
            JSR update_midbox
            ; cur_bnks[7] = $00
            STA cur_bnks+7
            ; update sprite palette
            LDA #ACT_SPR_PAL_0
            STA img_tmp_pals+13
            LDA #ACT_SPR_PAL_1
            STA img_tmp_pals+14
            LDA #ACT_SPR_PAL_2
            STA img_tmp_pals+15
            ;
            LDA #ACT_BKG_PAL_0
            STA img_tmp_pals+1
            LDA #ACT_BKG_PAL_1
            STA img_tmp_pals+2
            LDA #ACT_BKG_PAL_2
            STA img_tmp_pals+3
            LDA #ACT_BKG_PAL_3
            STA img_tmp_pals+4
            LDA #ACT_BKG_PAL_4
            STA img_tmp_pals+5
            LDA #ACT_BKG_PAL_5
            STA img_tmp_pals+6
            ; copy_palettes()
            JSR copy_palettes
            ; update_palettes()
            JSR update_palettes
            ; clear midbox draw flag
            LDA txt_flags
            AND #$FF-TXT_FLAG_MIDBOX
            STA txt_flags
        :
    @anim_fi:

    ; update animation
    JSR update_anim

    ; if cur_photo != new_photo
    LDA new_photo
    CMP cur_photo
    BEQ :+++
        ; cur_photo = new_photo
        STA cur_photo
        ; if new_photo >= 0
        TAX
        BMI :+
            ; fetch & decode evi
            ; display_evi(new_photo)
            JSR display_evi
            ; offset sprites
            LDA evi_off_x
            STA spr_off_x
            LDA evi_off_y
            STA spr_off_y
            ; clear bkg tiles
            ; set_spr_bkg_tile($10, $10)
            LDX #$10
            LDY #$10
            ; JSR set_spr_bkg_tile
            ; set img_flag.evispr
            LDA img_flag
            ORA #IMG_FLAG_EVISPR
            STA img_flag
            JMP :++
        ; else
        :
            ; remove sprites offset
            LDA #$00
            STA spr_off_x
            STA spr_off_y
            ; clear img_flag.evispr
            LDA img_flag
            AND #$FF-IMG_FLAG_EVISPR
            STA img_flag
            ; restore bkg tiles
            ; clear_spr_bkg_tile($10, $10)
            LDX #$10
            LDY #$10
            ; JSR clear_spr_bkg_tile
        :
        ; copy_palettes()
        JSR copy_palettes
        ; update_palettes()
        JSR update_palettes
    :

    @MAIN_END:
    ; loop back to start of main
    JMP MAIN_LOOP
