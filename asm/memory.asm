;**********
; Memory
;**********

;****************
; ZEROPAGE SEGMENT
;****************
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

    ; Scroll X position
    scroll_x: .res 1

    ; Scroll Y position
    scroll_y: .res 1

    ; Nametable high adress to update attributes for
    ; $23 = Nametable 1
    ; $27 = Nametable 2
    ; $2B = Nametable 3
    ; $2F = Nametable 4
    atr_nametable: .res 1
    
    ; value of the PPU_MASK (need to be refresh manually)
    ppu_ctrl_val: .res 1

    ; padding
    .res 2

    ; Palettes data to send to PPU during VBLANK
    ;   byte 0   = transparente color
    ;   byte 1-3 = background palette 1
    ;   byte 4-6 = background palette 2
    ;   ...
    ;   byte 13-16 = sprite palette 1
    ;   ...
    palettes: .res 25

    ; Attributes data to send to PPU during VBLANK
    attributes: .res 64

    ; Index for the background data
    background_index: .res 1

    ; Background data to send to PPU during VBLANK
    ; Packet structure:
    ; byte 0   = v.ssssss (v= vertical draw, s= size)
    ; byte 1-2 = ppu adress (most significant byte, least significant byte)
    ; byte 3-s = tile data
    ; packet of size 0 means there is no more data to draw
    background: .res 63

    ; temporary variables
    tmp:

;****************
; OAM SEGMENT
;****************
.segment "OAM"
OAM:


;****************
; BSS SEGMENT
;****************
.segment "BSS"

    ; - - - - - - - -
    ; Vairables for LZ decoding
    ; - - - - - - - -
    ; pointer to input data
    lz_in: .res 2
    ; bank to use for input data
    lz_in_bnk: .res 1

    ; - - - - - - - -
    ; Vairables for text reading
    ; - - - - - - - -
    ; pointer to current text to read
    txt_rd_ptr: .res 2

    ; - - - - - - - -
    ; Variable for text printing
    ; - - - - - - - -
    ; Value to print in ext ram
    ; Represent the font to use
    print_ext_val: .res 1
    ; pointer to current printed text in ext ram
    print_ext_ptr: .res 2
    ; pointer to current printed text in ppu
    print_ppu_ptr: .res 2
    ; number of character to print
    print_counter: .res 1
    ; buffer containing text to print to ppu
    print_ppu_buf: .res 16
    ; buffer containing text to print to ext ram
    print_ext_buf: .res 16
