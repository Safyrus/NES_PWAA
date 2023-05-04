MAX_NAME_SIZE = 5

draw_name:
    pushregs

    ; if name == 0 then return
    LDA txt_name
    BEQ @end
    ; if dialog box is hidden then return
    ; BIT box_flags
    ; BPL @end

    ; wait for nmi tile buffer to have space
    @wait_vblank:
        LDX background_index
        CPX #$40-MAX_NAME_SIZE-3
        bge @wait_vblank
    and_adr nmi_flags, #($FF-NMI_DONE) ; fix nmi not doing anything because we wait too many frames
    ; don't draw at the end of a frame (no time to close the packet)
    @wait_inframe:
        BIT scanline
        BVC @wait_inframe

    ; send size
    LDA #MAX_NAME_SIZE
    STA background, X
    INX

    ; send ppu adr
    LDA #>NAME_PPU_ADR
    STA background, X
    INX
    LDA #<NAME_PPU_ADR
    STA background, X
    INX

    ; send data
    LDY name_size
    LDA name_adr
    @loop_draw:
        ; send 1 byte
        STA background, X
        INX
        ; A += 1
        add #$01
        ; continue
        DEY
        BNE @loop_draw

    LDA #MAX_NAME_SIZE
    sub name_size
    TAY
    LDA #BOX_TILE_B
    @loop_erase:
        ; send 1 byte
        STA background, X
        INX
        ; continue
        DEY
        BNE @loop_erase

    ; close packet
    LDA #$00
    STA background, X
    STX background_index

    ; ;
    ; @mmc5_wait:
    ;     LDA scanline
    ;     CMP #SCANLINE_TOP_IMG
    ;     BNE @mmc5_wait
    ; ; mmc5 exp ram update
    ; push tmp
    ; push tmp+1
    ; sta_ptr tmp, (MMC5_EXP_RAM+(NAME_PPU_ADR&$3FF))
    ; LDA #NAME_CHR_BANK
    ; LDY name_size
    ; DEY
    ; @mmc5:
    ;     STA (tmp), Y
    ;     ; continue
    ;     DEY
    ;     BPL @mmc5
    ; pull tmp+1
    ; pull tmp

    @end:
    pullregs
    RTS
