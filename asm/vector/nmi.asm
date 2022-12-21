;***********
; NMI vector
;***********


;--------------------
; Cycles notes
;--------------------
; 2273 cycles per VBLANK
; base (before @done) = 13+3+2+3+(2+3)*5
; @sprite = 513+ cycles
; @scroll = 31 cycles
; @attribute = 821 cycles
; @palette = 356 cycless
; @background ~= 16+(38*p+14*p[i].n)
;--------------------


NMI:
    ; save registers
    pushreg

    ; do we need to do stuff ? (E flag)
    BIT nmi_flags
    BPL @start
    JMP @end

    @start:
    ; load NMI flags
    LDA nmi_flags


    ; is the background flag on ? (B flag)
    LSR
    BCC @background_end
    @background:
        ; save flags
        PHA

        LDX #$00
        @background_loop:
            ; read size
            LDA background, X
            ; if size = 0 then end
            BEQ @background_loop_end

            ; save size to Y
            AND #$3F
            TAY
            ; is vertical flag off ?
            LDA background, X
            ASL
            BCC @background_loop_hor

            ; tell the ppu to inc by 32
            @background_loop_ver:
            LDA ppu_ctrl_val
            ORA #(PPU_CTRL_INC)
            STA PPU_CTRL
            JMP @background_loop_start

            ; tell the ppu to inc by 1
            @background_loop_hor:
            LDA ppu_ctrl_val
            AND #($FF-PPU_CTRL_INC)
            STA PPU_CTRL

            @background_loop_start:
            ; reset latch
            BIT PPU_STATUS
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
            JMP @background_loop
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
    LSR
    BCC @attribute_end
    @attribute:
        ; save flags
        PHA

        ; reset latch
        BIT PPU_STATUS
        ; set PPU address
        LDA atr_nametable
        STA PPU_ADDR
        LDA #$C0
        STA PPU_ADDR
 
        ; send data to PPU
        LDX #$00
        @attribute_loop:
            ; send 1 byte
            LDA attributes, X
            STA PPU_DATA
            INX
            ; send another byte
            LDA attributes, X
            STA PPU_DATA
            INX
            ; loop
            CPX #$40
            BNE @attribute_loop
 
        ; restore flags
        PLA
    @attribute_end:


    ; is the palette flag on ? (P flag)
    LSR
    BCC @palette_end
    @palette:
        ; save flags
        PHA

        ; reset latch
        BIT PPU_STATUS
        ; set PPU address
        LDA #$3F
        STA PPU_ADDR
        LDA #$00
        STA PPU_ADDR
 
        ; send data to PPU
        LDX #$00
        ; send transparent color
        LDA palettes, X
        TAY
        INX

        @palette_loop:
            ; send background
            TYA
            STA PPU_DATA
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

        ; restore flags
        PLA
    @palette_end:


    ; is the scroll flag on ? (R flag)
    LSR
    BCC @scroll_end
    @scroll:
        ; reset latch
        BIT PPU_STATUS
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
    ; tell that we are done
    LDA #NMI_DONE
    ORA nmi_flags
    STA nmi_flags

    @end:
    ; restore registers
    pullreg
    ; return
    RTI