; @scanline_irq_dialog:
    AND #$3F
    TAX
    LDA @next_state, X
    STA scanline
    ; - - - - - - - -
    ; first scanline (151)
    ; - - - - - - - -
    ; test if we need to change palette
    BIT effect_flags
    BMI @palette_change_start
        LDA #215
        STA MMC5_SCNL_VAL
        JMP @end
    @palette_change_start:
    ; skipping 11 cpu cycles
    NOP
    NOP
    NOP
    NOP
    LDA $0
    ; setup registers
    LDX #$16
    LDY #$26
    ; set high byte of address
    LDA #$3F
    STA PPU_ADDR
    ; disable rendering
    LDA #$00
    STA PPU_MASK
    ; set low byte of address
    STA PPU_ADDR
    ; send background color
    LDA #$0F
    STA PPU_DATA
    ; send 3 byte
    LDA #$06
    STA PPU_DATA
    STX PPU_DATA
    STY PPU_DATA
    ;
    LDA #$00
    STA MMC5_CHR_UPPER
    ; wait
    NOP
    LDX #$0F
    @dialog_wait_1:
        DEX
        bnz @dialog_wait_1

    ; - - - - - - - -
    ; second scanline (152)
    ; - - - - - - - -
    LDX #$12
    LDY #$22
    ; send 4 byte
    LDA #$0F
    STA PPU_DATA
    LDA #$02
    STA PPU_DATA
    STX PPU_DATA
    STY PPU_DATA
    ; wait
    LDX #$12
    @dialog_wait_2:
        DEX
        bnz @dialog_wait_2

    ; - - - - - - - -
    ; third scanline (153)
    ; - - - - - - - -
    LDX #$1A
    LDY #$2A
    ; send 4 byte
    LDA #$0F
    STA PPU_DATA
    LDA #$0A
    STA PPU_DATA
    STX PPU_DATA
    STY PPU_DATA
    ; wait
    LDX #$12
    @dialog_wait_3:
        DEX
        bnz @dialog_wait_3

    ; - - - - - - - -
    ; fourth scanline (154)
    ; - - - - - - - -
    LDX #$10
    LDY #$30
    ; send 4 byte
    LDA #$0F
    STA PPU_DATA
    LDA #$00
    STA PPU_DATA
    STX PPU_DATA
    STY PPU_DATA
    ; wait
    LDX #$0F
    @dialog_wait_4:
        DEX
        bnz @dialog_wait_4

    ; - - - - - - - -
    ; fifth scanline (155)
    ; - - - - - - - -
    ; setup registers (scroll position)
    ; see NesDev wiki for explaination (https://www.nesdev.org/wiki/PPU_scrolling)
    ;    First      Second
    ; /¯¯¯¯¯¯¯¯¯\ /¯¯¯¯¯¯¯\
    ; 0 0yy NN YY YYY XXXXX
    ;   ||| || || ||| +++++-- coarse X scroll
    ;   ||| || ++-+++-------- coarse Y scroll
    ;   ||| ++--------------- nametable select
    ;   +++------------------ fine Y scroll
    LDX #$32
    LDY #$60
    ; restore ppu addr (scroll position)
    STX PPU_ADDR
    STY PPU_ADDR
    ; re-enable rendering without sprites
    LDA #(PPU_MASK_BKG + PPU_MASK_BKG8)
    STA PPU_MASK
    ; wait the next scanline
    LDX #$14
    @dialog_wait_5:
        DEX
        bnz @dialog_wait_5

    ; - - - - - - - -
    ; sixth scanline (156)
    ; - - - - - - - -
    ; re-enable rendering with sprites
    ; LDA #(PPU_MASK_BKG + PPU_MASK_BKG8 + PPU_MASK_SPR + PPU_MASK_SPR8)
    LDA #(PPU_MASK_BKG + PPU_MASK_BKG8)
    STA PPU_MASK
    ; set next scanline.
    ; Because we have disabled rendering,
    ; MMC5 scanline counter is now at 0 at the scanline where we re-enabled rendering,
    ; Therefore, scanline 60 mean scanline when enable (155) + 60 = 215
    LDA #60
    STA MMC5_SCNL_VAL
    ; return
    JMP @end
