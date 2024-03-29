;***********
; RST vector
;***********


;--------------------------------
; Subroutine: RST
;--------------------------------
; Reset Vector
;--------------------------------
RST:
    ; - - - - - - -
    ; setup NES
    ; - - - - - - -

    SEI         ; Disable interrupt
    CLD         ; Clear/disable decimal

    LDX #$FF    ; Initialized stack
    TXS

    INX              ; X=0
    STX PPU_CTRL     ; Disable NMI
    STX PPU_MASK     ; Disable Rendering
    STX APU_DMC_FREQ ; Disable DMC IRQ

    ; Wait 1 frame (for the PPU to be initialized)
    BIT PPU_STATUS ; Clear the VBlank flag if it was set at reset time
    @wait_vblank:
        BIT PPU_STATUS
        BPL @wait_vblank ; At this point, about 27384 cycles have passed

    ; Clear NES RAM
    @clrmem:
        LDA #$00
        STA $0000, x
        STA $0100, x
        STA $0200, x
        STA $0300, x
        STA $0400, x
        STA $0500, x
        STA $0600, x
        STA $0700, x
        INX
        bnz @clrmem

    ; - - - - - - -
    ; setup MMC5
    ; - - - - - - -

    ; disable ram protection
    mov MMC5_RAM_PRO1, #$02
    mov MMC5_RAM_PRO2, #$01

    ; Set the Extented RAM as work RAM to clean it
    mov MMC5_EXT_RAM, #$02
    ; Reset Extended RAM content
    LDA #$00
    for_x @rst_exp_ram, 0
        STA MMC5_EXP_RAM, X
        STA MMC5_EXP_RAM+$100, X
        STA MMC5_EXP_RAM+$200, X
        STA MMC5_EXP_RAM+$300, X
    to_x_dec @rst_exp_ram, 0

    ; Set the Extented RAM as extended attribute data
    mov MMC5_EXT_RAM, #$01

    ; Set fill tile
    LDA #$20
    STA MMC5_FILL_TILE
    STA MMC5_FILL_COL

    ; Enable scanline irq
    mov MMC5_SCNL_STAT, #$80
    mov MMC5_SCNL_VAL, #239
    mov scanline, #SCANLINE_BOT_IMG

    ; Disable Vertical split
    LDA #$00
    STA MMC5_SPLT_MODE
    STA MMC5_SPLT_BNK
    STA MMC5_SPLT_SCRL

    ; Set CHR banking mode
    STA MMC5_CHR_MODE

    ; Clean PRG RAM
    ; mov tmp+2, #$00 ; loop counter
    ; @clean_prgram:
    ;     ; set bank
    ;     mov MMC5_RAM_BNK, tmp+2
    ;     for_x @clean_prgram_bank, #0
    ;         ; set page address
    ;         TXA
    ;         add #$60
    ;         STA tmp+1
    ;         mov tmp, #$00
    ;         ; clear page
    ;         for_y @clean_prgram_page, #0
    ;             STA (tmp), Y
    ;         to_y_inc @clean_prgram_page, #0
    ;     to_x_inc @clean_prgram_bank, #$20
    ;     ; increase loop counter
    ;     LDX tmp+2
    ;     INX
    ;     STX tmp+2
    ; to_x_dec @clean_prgram, #RAM_MAX_BNK

    ; - - - - - - -
    ; setup code
    ; - - - - - - -

    ; set code bank
    LDA #CODE_BNK
    STA MMC5_PRG_BNK0
    STA mmc5_banks+1

    ; set fade in flag (image does not refresh when fade in is clear)
    mov effect_flags, #(EFFECT_FLAG_FADE+EFFECT_FLAG_PAL_SPLIT)

    ; Enable NMI + set background table to $1000
    ; by this time, it is sure that the PPU is initialize
    LDA #%10010000
    STA PPU_CTRL
    STA ppu_ctrl_val

    ; init new line offset
    mov print_nl_offset, #$42

    CLI ; Enable back interrupt
    JMP MAIN ; jump to main function
