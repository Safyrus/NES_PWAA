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
;     inputs()
;     effects()
;     image()
;     name()
;     lz()
;     dialog_box()
;     photo()
;---
;--------------------------------
MAIN:
    .include "init.asm"

MAIN_LOOP:
    ; wait for start of frame / acknowledge nmi
    JSR wait_next_frame
    @MAIN_LOOP_START:

    ; if currently drawing an image
    ; TODO: better flag condition ?
    LDA img_flag
    AND #(IMG_FLAG_UNSPRITE+IMG_FLAG_UNMMC5)
    BEQ :+
        ; if packet_buf_read_adr == packet_buf_write_adr
        ; (a.k.a nothing left to draw)
        LDA packet_buf_read_adr+1
        CMP packet_buf_write_adr+1
        BNE :++
        LDA packet_buf_read_adr+0
        CMP packet_buf_write_adr+0
        BNE :++
            ; re-enable sprites and MMC5 tiles update
            LDA img_flag
            AND #$FF-(IMG_FLAG_UNMMC5+IMG_FLAG_UNSPRITE)
            ; enable force image update
            ORA #IMG_FLAG_FORCE
            ; and swap nametable to use
            EOR #IMG_FLAG_OTHERNT
            STA img_flag
            ; update palettes
            LDY #$3*8
            @update_pals:
                LDA img_pals, Y
                STA palettes, Y
                DEY
                BPL @update_pals
            ; wait to be in frame
            @wait_inframe:
                BIT scanline
                BVC @wait_inframe
            ; change scroll position to other nametable
            ; (we need to change scroll before updating MMC5 tiles)
            LDA ppu_ctrl_val
            EOR #$01
            STA PPU_CTRL
            STA ppu_ctrl_val
            ; copy MMC5 tiles
            JSR cp_mmc5
            ; update sprites
            JSR draw_sprites
            ;
            mov mmc5_banks+0, IMG_BNK
            STA MMC5_RAM_BNK
            JSR update_all_image
            ;
            and_adr img_flag, #($FF-IMG_FLAG_FORCE)
    :
    ; else
    :
    ; update animation
    JSR update_anim
    @MAIN_END:
    ; loop back to start of main
    JMP MAIN_LOOP
