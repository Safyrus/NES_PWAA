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
    .include "main/init.asm"

MAIN_LOOP:
    JSR wait_next_frame

    ; if we are not drawing the background
    LDA effect_flags
    AND #EFFECT_FLAG_DRAW
    bnz :+
        ; then update the scroll position to the correct screen buffer
        JSR update_screen_scroll
    :

    .include "input/input.asm"
    .include "effect/main.asm"

    ; if we don't do a lenghty operation
    LDA txt_flags
    AND #(TXT_FLAG_BOX + TXT_FLAG_LZ + TXT_FLAG_PRINT)
    BNE :+
    ; or if we are not in a choice
    LDA max_choice
    BNE :+
    ; or if we are not in the court record
    LDA cr_flag
    AND #CR_FLAG_SHOW
    BNE :+
        ; then update graphics
        JSR frame_decode
    :

    ; refresh dialog box name if needed
    LDA box_flags
    AND #BOX_FLAG_NAME
    BEQ @name_refresh_end
    @name_refresh:
        and_adr box_flags, #($FF-BOX_FLAG_NAME)
        JSR draw_name
    @name_refresh_end:

    ; lz decode if needed
    LDA txt_flags
    AND #TXT_FLAG_LZ
    BEQ @lz_end
        JSR lz_decode
        and_adr txt_flags, #($FF-TXT_FLAG_LZ)
    @lz_end:

    ; draw/refresh dialog box if needed
    LDA txt_flags
    AND #TXT_FLAG_BOX
    BEQ @box_end
        ; if BOX_FLAG_REFRESH
        LDA box_flags
        AND #BOX_FLAG_REFRESH
        BEQ @box_redraw
        @box_refresh:
            ; then refresh dialog box
            JSR draw_dialog_box
            ; break
            JMP @box_done
        @box_redraw:
            ; if dialog box is switching to on
            LDA box_flags
            AND #BOX_FLAG_HIDE
            BEQ @box_redraw_hide
            @box_redraw_display:
                ; then undraw the dialog box (by drawing the bottom image on top)
                sta_ptr tmp+0, (PPU_NAMETABLE_0+$260)
                JSR img_draw_bot_lo
                sta_ptr tmp+0, (MMC5_EXP_RAM+$260)
                JSR img_draw_bot_hi
                ; break
                JMP @box_redraw_end
            @box_redraw_hide:
                ; else
                JSR draw_dialog_box
            @box_redraw_end:
            ; flip the midframe split flag
            eor_adr effect_flags, #EFFECT_FLAG_PAL_SPLIT
        @box_done:
        ; clear TXT_FLAG_BOX
        and_adr txt_flags, #($FF-TXT_FLAG_BOX)
    @box_end:

    ; display photo if needed
    BIT img_photo
    BPL @photo_end
        ; clear draw flag
        and_adr img_photo, #$7F
        ; draw photo
        LDY #$22
        LDX #$6C
        JSR draw_photo
    @photo_end:

    ;
    LDA click_flag
    BEQ @invest_end
        ;
        AND #CLICK_INIT
        BNE :+
            JSR investigation_init
        :
        ; set cursor sprite palette
        mov img_palette_3+0, #$0F
        LDA buttons_1_timer
        BEQ :+
            mov img_palette_3+1, #$00
            mov img_palette_3+2, #$10
            JMP :++
        :
            mov img_palette_3+1, #$10
            mov img_palette_3+2, #$20
        :

        ; set cursor sprite
        LDA cursor_y
        STA OAM+0 ; y
        STA OAM+4 ; y
        LDA cursor_x
        CMP #$F8
        blt :+
            LDA #$FF
            STA OAM+4
        :
        LDA cursor_x
        STA OAM+3 ; x
        add #$08
        STA OAM+7 ; x
        mov MMC5_CHR_BNK7, #CLICK_SPR_BNK
        LDX #CLICK_SPR_IDX
        STX OAM+1 ; tile
        INX
        INX
        STX OAM+5 ; tile
        LDA #$00
        STA OAM+2 ; atr
        STA OAM+6 ; atr
    @invest_end:


    ; loop back to start of main
    JMP MAIN_LOOP
