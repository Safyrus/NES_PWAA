; params:
; - A: tile
; - tmp: ppu ptr
; use: A, X, Y
; /!\ private
; /!\ does not save registers
_draw_dialog_box_line:
    PHA
    LDX background_index
    ; init packet
    LDA #$20
    STA background, X
    INX
    LDA tmp+1
    STA background, X
    INX
    LDA tmp+0
    STA background, X
    INX
    ; first tile
    PLA
    STA background, X
    INX
    ; fill packet
    LDY #$1E
    add #$01
    @loop_top:
        STA background, X
        INX
        ; next
        DEY
        bnz @loop_top
    ; last tile
    add #$01
    STA background, X
    INX
    ; close packet
    LDA #$00
    STA background, X
    STX background_index
    RTS

; description:
;   draw a new dialog box
; use: tmp[0..2]
draw_dialog_box:
    pushregs

    ; wait for the start of the frame
    @wait_start:
        BIT scanline
        BVC @wait_start
    ; and acknowledge NMI
    JSR wait_next_frame

    ; - - - - - - - -
    ; frame 1 (top line)
    ; - - - - - - - -
    sta_ptr tmp, (PPU_NAMETABLE_0+$260)
    LDA #BOX_TILE_TL
    JSR _draw_dialog_box_line

    ; - - - - - - - -
    ; frame 1 (bot line)
    ; - - - - - - - -
    sta_ptr tmp, (PPU_NAMETABLE_0+$340)
    LDA #BOX_TILE_BL
    JSR _draw_dialog_box_line

    ; - - - - - - - -
    ; frame 2, to 7
    ; - - - - - - - -
    ; tmp = ppu adr
    sta_ptr tmp, (PPU_NAMETABLE_0 + $280)
    ; draw each line
    mov tmp+2, #$03
    @loop_frames:
        JSR wait_next_frame

        ; draw one line
        LDA #BOX_TILE_L
        JSR _draw_dialog_box_line
        ; tmp += $20
        add_A2ptr tmp, #$20
        ; draw another line
        LDA #BOX_TILE_L
        JSR _draw_dialog_box_line
        ; tmp += $20
        add_A2ptr tmp, #$20

        ; next
        DEC tmp+2
        bnz @loop_frames

    JSR wait_next_frame
    ; wait to be in frame
    @wait_inframe:
        BIT scanline
        BVC @wait_inframe
    ; set ptr to ext ram
    sta_ptr tmp, (MMC5_EXP_RAM+$260)
    ; set ext ram
    LDA #BOX_UPPER_TILE
    for_y @loop_ext, #0
        STA (tmp), Y
    to_y_inc @loop_ext, #0

    JSR draw_name

    @end:
    pullregs
    RTS
