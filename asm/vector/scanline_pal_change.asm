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
    ; skipping 8 cpu cycles
    NOP
    NOP
    NOP
    NOP
    ; setup registers
    LDX #SPLIT_PAL0_1
    LDY #SPLIT_PAL0_2
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
    LDA #SPLIT_PAL0_0
    STA PPU_DATA
    STX PPU_DATA
    STY PPU_DATA
    ;
    LDA #$00
    STA MMC5_CHR_UPPER
    ; wait
    LDX #$10
    @dialog_wait_1:
        DEX
        bnz @dialog_wait_1

    ; - - - - - - - -
    ; second scanline (152)
    ; - - - - - - - -
    LDX #SPLIT_PAL1_1
    LDY #SPLIT_PAL1_2
    ; send 4 byte
    LDA #$0F
    STA PPU_DATA
    LDA #SPLIT_PAL1_0
    STA PPU_DATA
    STX PPU_DATA
    STY PPU_DATA
    ; wait
    LDX #$11
    @dialog_wait_2:
        DEX
        bnz @dialog_wait_2

    ; - - - - - - - -
    ; third scanline (153)
    ; - - - - - - - -
    LDX #SPLIT_PAL2_1
    LDY #SPLIT_PAL2_2
    ; send 4 byte
    LDA #$0F
    STA PPU_DATA
    LDA #SPLIT_PAL2_0
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
    LDX #SPLIT_PAL3_1
    LDY #SPLIT_PAL3_2
    ; send 4 byte
    LDA #$0F
    STA PPU_DATA
    LDA #SPLIT_PAL3_0
    STA PPU_DATA
    STX PPU_DATA
    STY PPU_DATA
    ; wait
    LDX #$10
    @dialog_wait_4:
        DEX
        bnz @dialog_wait_4

    ; - - - - - - - -
    ; fifth scanline (155)
    ; - - - - - - - -
    ; change first CHR bank to fix wrong left pixels at the end of palette split
    ; (for the first line of a few tile, the PPU don't see the dialog box tiles
    ; but the ones in the first sprite bank, so we need to update it)
    LDA #$00
    STA MMC5_CHR_BNK0
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
    ; LDX #$14
    ; @dialog_wait_5:
    ;     DEX
    ;     bnz @dialog_wait_5

    ; - - - - - - - -
    ; sixth scanline (156)
    ; - - - - - - - -
    ; re-enable rendering with sprites
    ; LDA #(PPU_MASK_BKG + PPU_MASK_BKG8 + PPU_MASK_SPR + PPU_MASK_SPR8)
    ; LDA #(PPU_MASK_BKG + PPU_MASK_BKG8)
    ; STA PPU_MASK
    ; set next scanline.
    ; Because we have disabled rendering,
    ; MMC5 scanline counter is now at 0 at the scanline where we re-enabled rendering,
    ; Therefore, scanline 60 mean scanline when enable (155) + 60 = 215
    LDA #60
    STA MMC5_SCNL_VAL
    ; return
    JMP @end
