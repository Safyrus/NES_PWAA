;################
; File: NMI
;################


;--------------------------------
; Subroutine: NMI
;--------------------------------
; NMI vector
;
; Cycles notes:
;--- Text
; ~2273 cycles per VBLANK
; header (before @background) = 36 cycles
; NMI flag checks = 20 to 25 cycles
; @background:
;   - start/end = 16 cycles
;   - empty packet = 7 cycles
;   - packet header+end = 47 cycles (+3 if vertical)
;   - packet data = 14*(size-1) + 13 cycles
; @sprite = 513+ cycles
; @attribute = ??? cycles
; @palette = 335 cycles
; @scroll = 21 cycles
;---
;--------------------------------
NMI:
    ; save registers
    pushregs

    ; do we need to do stuff ? (E flag)
    ; BIT nmi_flags
    ; BPL @start
    ; BVS @start
    ; JMP @nmi_end

    @start:
    ; update nametable mapping
    LDA #NT_MAPPING_NT1
    STA MMC5_NAMETABLE
    ; reset latch
    BIT PPU_STATUS
    ; load NMI flags
    LDA nmi_flags

    ; is the background flag on ? (B flag)
    LSR
    BCC @background_end
    @background:
        ; save flags
        PHA
        ; for each packet
        LDX #$00
        @background_loop:
            ; read size
            LDA background, X
            ; if size = 0 then end
            BEQ @background_loop_end

            ; is vertical flag off ?
            BPL @background_loop_hor

            ; tell the ppu to inc by 32
            @background_loop_ver:
            ; save size to Y
            AND #$7F
            TAY
            ; ppu inc by 32
            LDA ppu_ctrl_val
            ORA #(PPU_CTRL_INC)
            BNE @background_loop_start ; BNE = JMP because ORA before

            ; tell the ppu to inc by 1
            @background_loop_hor:
            ; save size to Y
            AND #$7F
            TAY
            ; ppu inc by 1
            LDA ppu_ctrl_val
            AND #($FF-PPU_CTRL_INC)

            @background_loop_start:
            STA PPU_CTRL
            ; set PPU adr
            INX
            LDA background, X
            STA PPU_ADDR
            INX
            LDA background, X
            STA PPU_ADDR

            ; send data
            @background_loop_data:
                ; send 1 tile
                INX
                LDA background, X
                STA PPU_DATA
                ; loop
                DEY
                BNE @background_loop_data
            INX
            BNE @background_loop ; BNE = JMP because INX != 0
        @background_loop_end:
        ; restore PPU_CTRL
        LDA ppu_ctrl_val
        STA PPU_CTRL
        ; restore flags
        PLA
    @background_end:

    ; is the sprite flag on ? (S flag)
    LSR
    BCC @sprite_end
    @sprite:
        ; Update sprites
        LDX #>OAM
        STX OAMDMA
    @sprite_end:

    ; is the attribute flag on ? (A flag)
    ; /!\ skip this flag because we will never use it
    LSR
    ; BCC @attribute_end
    ; @attribute:
        ; ; save flags
        ; PHA
        ; ; reset latch
        ; BIT PPU_STATUS
        ; ; set PPU address
        ; LDA atr_nametable
        ; STA PPU_ADDR
        ; LDA #$C0
        ; STA PPU_ADDR
        ; ; send data to PPU
        ; LDX #$00
        ; @attribute_loop:
        ;     ; send 1 byte
        ;     LDA attributes, X
        ;     STA PPU_DATA
        ;     INX
        ;     ; send another byte
        ;     LDA attributes, X
        ;     STA PPU_DATA
        ;     INX
        ;     ; loop
        ;     CPX #$40
        ;     BNE @attribute_loop
        ; ; restore flags
        ; PLA
    ; @attribute_end:

    ; is the palette flag on ? (P flag)
    LSR
    BCC @palette_end
    @palette:
        ; save flags
        PHA
        ; set PPU address
        LDA #$3F
        STA PPU_ADDR
        LDX #$00
        STX PPU_ADDR
        ; send data to PPU
        INX
        LDY #$0
        @palette_loop:
            ; send dummy transparent color
            LDA dummy_pal, Y
            STA PPU_DATA
            INY
            ; send 3 colors
            LDA palettes, X
            STA PPU_DATA
            INX
            LDA palettes, X
            STA PPU_DATA
            INX
            LDA palettes, X
            STA PPU_DATA
            INX
            ; loop
            CPX #25
            BNE @palette_loop
        ; send real transparent color
        LDA #$3F
        STA PPU_ADDR
        LDA #$00
        STA PPU_ADDR
        LDA palettes
        STA PPU_DATA
        ; restore flags
        PLA
    @palette_end:

    ; is the scroll flag on ? (R flag)
    LSR
    BCC @scroll_end
    @scroll:
        ; set scrolling position to scroll_x, scroll_y
        LDX scroll_x
        STX PPU_SCROLL
        LDX scroll_y
        STX PPU_SCROLL
        ; set high order bit of X and Y
        LDA ppu_ctrl_val
        STA PPU_CTRL
    @scroll_end:

    @done:
    ; reset zp background index
    LDA #$00
    STA background_index
    STA background

    @nmi_end:

    ; tell that we are done
    BIT nmi_flags
    BVS :+
        LDA #NMI_DONE
        ORA nmi_flags
        STA nmi_flags
        JMP :++
    :
        LDA #($FF-NMI_DONE)
        AND nmi_flags
        STA nmi_flags
    :

    .include "nmi_next.asm"

    ; restore registers
    pullregs
    @nmi_ret:
    ; return
    RTI


; Transparent palette use to choose scanline color
; during mid-frame palette switch.
; Data is double because writing a background color
; is the same as writing a sprite color.
; First background color = [palettes+0]
dummy_pal:
; padding because we write 8 palettes
; and the 4 first color will be overwritten
.byte $FF, $FF, $FF, $FF
; first byte will be overwritten by the real transparent color
; The next three bytes are the real 'fake' transparent color
.byte $FF, $30, $10, $00
