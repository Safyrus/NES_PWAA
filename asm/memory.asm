;**********
; Memory
;**********



.segment "ZEROPAGE"

    ; NMI Flags to activate graphical update
    ; Note: You cannot activate all updates.
    ;       You need to have a execution time
    ;       < ~2273 cycles (2000 to be sure)
    ; 7  bit  0
    ; ---- ----
    ; E..R PASB
    ; |  | ||||
    ; |  | |||+- Background tiles update
    ; |  | |||   Execution time depend on data
    ; |  | |||   (cycles ~= 16 + 38*p + for i:p do (14*p[i].n))
    ; |  | |||   (p=packet number, p[i].n = packet data size)
    ; |  | ||+-- Sprites update (513+ cycles)
    ; |  | |+--- Nametables attributes update (821 cycles)
    ; |  | +---- Palettes update (356 cycles)
    ; |  +------ Scroll update (31 cycles)
    ; +--------- 1 when NMI has ended, should be set to 0 after reading.
    ;            If let to 1, it means the NMI is disable
    nmi_flags: .res 1
    .export _nmi_flags=nmi_flags

    ; Scroll X position
    scroll_x: .res 1
    .export _scroll_x=scroll_x

    ; Scroll Y position
    scroll_y: .res 1
    .export _scroll_y=scroll_y

    ; Nametable high adress to update attributes for
    ; $23 = Nametable 1
    ; $27 = Nametable 2
    ; $2B = Nametable 3
    ; $2F = Nametable 4
    atr_nametable: .res 1
    .export _atr_nametable=atr_nametable
    
    ; value of the PPU_MASK (need to be refresh manually)
    ppu_ctrl_val: .res 1
    .export _ppu_ctrl_val=ppu_ctrl_val

    ; Attributes data to send to PPU during VBLANK
    attributes: .res 64
    .export _attributes=attributes

    ; Palettes data to send to PPU during VBLANK
    ;   byte 0   = transparente color
    ;   byte 1-3 = background palette 1
    ;   byte 4-6 = background palette 2
    ;   ...
    ;   byte 13-16 = sprite palette 1
    ;   ...
    palettes: .res 25
    .export _palettes=palettes

    ; Index for the background data
    background_index: .res 1
    .export _background_index=background_index

    ; Background data to send to PPU during VBLANK
    ; Packet structure:
    ; byte 0   = v.ssssss (v= vertical draw, s= size)
    ; byte 1-2 = ppu adress
    ; byte 3-s = tile data
    ; packet of size 0 means there is no more data to draw
    background: .res 127
    .export _background=background


;****************
; OAM SEGMENT
;****************
.segment "OAM"
OAM:
    .export _OAM=OAM


;****************
; BSS SEGMENT
;****************
.segment "BSS"
    game_state: .res 1
    .export _game_state=game_state
