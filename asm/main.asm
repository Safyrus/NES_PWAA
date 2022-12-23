;**********
; Main
;**********

.macro MAIN_INIT
    ; render background + palette
    LDA #(NMI_BKG + NMI_SCRL + NMI_PLT)
    STA nmi_flags
    LDA #(PPU_MASK_BKG + PPU_MASK_BKG8)
    STA PPU_MASK

    ; set palette
    LDA #$10
    STA palettes+1
    LDA #$20
    STA palettes+2
    LDA #$30
    STA palettes+3

    ; load first dialog block
    LDA #DIALOG_BNK
    STA lz_in_bnk
    STA MMC5_PRG_BNK0
    LDA #<TEXT_PTR
    STA lz_in+0
    LDA #>TEXT_PTR
    STA lz_in+1
    JSR lz_decode

    ; init text read pointer
    LDA #<MMC5_RAM
    STA txt_rd_ptr+0
    LDA #>MMC5_RAM
    STA txt_rd_ptr+1

    ; - - - - - - - -
    ; init print variables
    ; - - - - - - - -
    ; ext value = 0
    LDA #$00
    STA print_ext_val
    ; print_counter = 0
    STA print_counter
    ; init ptr to ext ram
    LDA #<MMC5_EXP_RAM
    STA print_ext_ptr+0
    LDA #>MMC5_EXP_RAM
    STA print_ext_ptr+1
    ; init ptr to ppu
    LDA #<PPU_NAMETABLE_0
    STA print_ppu_ptr+0
    LDA #>PPU_NAMETABLE_0
    STA print_ppu_ptr+1

.endmacro

MAIN:

    MAIN_INIT

    ; wait for next frame to start
    @wait_vblank:
        BIT nmi_flags
        BPL @wait_vblank

    ; acknowledge nmi
    LDA nmi_flags
    AND #($FF-NMI_DONE)
    STA nmi_flags

    ; reset zp background index
    LDA #$00
    STA background_index

    ; read text
    JSR read_text

    ; loop back to start of main
    JMP @wait_vblank
