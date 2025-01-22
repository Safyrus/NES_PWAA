;################
; File: Main
;################

;--------------------------------
; Function: Main
;--------------------------------
; Main function called just after the reset vector
;
; Summary:
;--- Text
;   init()
;   loop:
;     wait_next_frame()
;     inputs() TODO
;     effects() TODO
;     update image
;     update text
;---
;--------------------------------
MAIN:
    .include "init.asm"

MAIN_LOOP:
    ; wait for start of frame / acknowledge nmi
    JSR wait_next_frame
    @MAIN_LOOP_START:

    ; ----------------
    ; Update Inputs
    ; ----------------
    JSR update_input
    JSR input_normal

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
        LDY #$3*8
        @update_pals:
            LDA img_tmp_pals, Y
            STA img_pals, Y
            DEY
            BPL @update_pals
        ; update palettes
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
    @anim_fi:

    ; update animation
    JSR update_anim

    @MAIN_END:
    ; loop back to start of main
    JMP MAIN_LOOP
