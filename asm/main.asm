;**********
; Main
;**********

MAIN:
.if FAMISTUDIO=1
    LDX #<music_data ; music data (lo)
    LDY #>music_data ; music data (hi)
    LDA #$01 ; NTSC
    JSR famistudio_init

    LDA #$00 ; Song 0
    JSR famistudio_music_play
.endif

    @wait_vblank:
        LDA nmi_flags
        AND #NMI_DONE
        BEQ @wait_vblank

.if FAMISTUDIO=1
    ; update sound engine
    JSR famistudio_update
.endif

    LDA #(PPU_MASK_BKG8+PPU_MASK_BKG+PPU_MASK_SPR8+PPU_MASK_SPR)
    STA PPU_MASK

    LDA #(NMI_ATR+NMI_PLT+NMI_SCRL+NMI_BKG+NMI_SPR)
    STA nmi_flags

    LDA #$23
    STA atr_nametable

    LDX #$00
    LDA #$00
    @loop_atr:
        STA attributes, X
        INX
        CPX #$40
        BNE @loop_atr
    
    LDX #$00
    @loop_plt:
        TXA
        STA palettes, X
        INX
        CPX #25
        BNE @loop_plt

    LDA #$40
    STA OAM+0
    LDA #$01
    STA OAM+1
    LDA #$00
    STA OAM+2
    LDA game_state
    STA OAM+3

    LDA #($05 + %00000000)
    STA background+0
    LDA #$20
    STA background+1
    LDA game_state
    STA background+2
    LDA #$04
    STA background+3
    LDA #$00
    STA background+4
    LDA #$01
    STA background+5
    LDA #$02
    STA background+6
    LDA #$03
    STA background+7
    LDA #$00
    STA background+8

    LDX game_state
    INX
    STX game_state

    JMP @wait_vblank
