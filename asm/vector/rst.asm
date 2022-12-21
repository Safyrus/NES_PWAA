;***********
; RST vector
;***********


RST:
    SEI         ; Disable interrupt
    CLD         ; Clear/disable decimal

    LDX #$FF    ; Initialized stack
    TXS

    INX         ; X=0
    STX PPU_CTRL ; Disable NMI
    STX PPU_MASK ; Disable Rendering
    STX APU_DMC_FREQ ; Disable DMC IRQ

    ; Wait for the PPU to initialized
    BIT PPU_STATUS       ; Clear the VBL flag if it was set at reset time
@vwait1:
    BIT PPU_STATUS
    BPL @vwait1      ; At this point, about 27384 cycles have passed

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
    BNE @clrmem

@vwait2:
    BIT PPU_STATUS
    BPL @vwait2      ; At this point, about 57165 cycles have passed

    LDA #%10010000      ; Enable NMI + set background table to $1000
    STA PPU_CTRL
    STA ppu_ctrl_val

    ; - - - - - - -
    ; setup MMC5
    ; - - - - - - -
    ; set $8000-9FFF to BNK 0
    LDA #$80
    STA MMC5_PRG_BNK0
    ; set $A000-BFFF to BNK 1
    LDA #$81
    STA MMC5_PRG_BNK1
    ; set $C000-DFFF to BNK 2
    LDA #$82
    STA MMC5_PRG_BNK2

    CLI

    JMP MAIN
