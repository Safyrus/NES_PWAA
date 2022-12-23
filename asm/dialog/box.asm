BOX_TILE_TL = $0080
BOX_TILE_T  = $0081
BOX_TILE_TR = $0082
BOX_TILE_L  = $0090
BOX_TILE_M  = $0091
BOX_TILE_R  = $0092
BOX_TILE_BL = $00A0
BOX_TILE_B  = $00A1
BOX_TILE_BR = $00A2

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
    CLC
    ADC #$01
    @loop_top:
        STA background, X
        INX
        ; next
        DEY
        BNE @loop_top
    ; last tile
    CLC
    ADC #$01
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

    ; - - - - - - - -
    ; frame 1 (top line)
    ; - - - - - - - -
    LDA #<(PPU_NAMETABLE_0+$260)
    STA tmp+0
    LDA #>(PPU_NAMETABLE_0+$260)
    STA tmp+1
    LDA #BOX_TILE_TL
    JSR _draw_dialog_box_line

    ; - - - - - - - -
    ; frame 1 (bot line)
    ; - - - - - - - -
    LDA #<(PPU_NAMETABLE_0+$340)
    STA tmp+0
    LDA #>(PPU_NAMETABLE_0+$340)
    STA tmp+1
    LDA #BOX_TILE_BL
    JSR _draw_dialog_box_line

    ; - - - - - - - -
    ; frame 2, to 7
    ; - - - - - - - -
    ; tmp = ppu adr
    LDA #<(PPU_NAMETABLE_0 + $280)
    STA tmp+0
    LDA #>(PPU_NAMETABLE_0 + $280)
    STA tmp+1
    ; draw each line
    LDA #$03
    STA tmp+2
    @loop_frames:
        ; wait next frame
        @wait_1:
            BIT nmi_flags
            BPL @wait_1
        ; acknowledge nmi
        LDA nmi_flags
        AND #($FF-NMI_DONE)
        STA nmi_flags
        ; reset zp background index
        LDA #$00
        STA background_index

        ; draw one line
        LDA #BOX_TILE_L
        JSR _draw_dialog_box_line
        ; tmp += $20
        LDA #$20
        add_A2ptr tmp
        ; draw another line
        LDA #BOX_TILE_L
        JSR _draw_dialog_box_line
        ; tmp += $20
        LDA #$20
        add_A2ptr tmp

        ; next
        DEC tmp+2
        BNE @loop_frames

    @end:
    pullregs
    RTS