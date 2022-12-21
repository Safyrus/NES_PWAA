;****************
; Author: Safyrus
;****************

; Header of the file (not part of the cartridge, used by the emulator)
.segment "HEADER"
    .byte "NES", $1A; 0-3: Header
    .byte $02       ;   4: PRG ROM
    .byte $01       ;   5: CHR ROM
    .byte $51       ;   6: Flags 6
    .byte $00       ;   7: Flags 7
    .byte $00       ;   8: Flags 8
    .byte $00       ;   9: Flags 9
    .byte $00       ;  10: Flags 10
    .byte $00,$00,$00,$00,$00   ; Padding

.include "constant.asm"
.include "macro.asm"
.include "memory.asm"

.segment "LAST_BNK"
    ; 6502 vectors subrountines
    .include "vector/rst.asm"
    .include "vector/nmi.asm"
    .include "vector/irq.asm"

.if FAMISTUDIO=1
    ; FamiStudio Sound Engine
    .include "audio/famistudio_config.asm"
    .include "audio/famistudio_ca65.s"
.endif


.segment "STARTUP"

; main file
.include "main.asm"


.segment "BNK1"
.if FAMISTUDIO=1
    ; Musics
.endif


; 6502 vectors
.segment "VECTORS"
    ; 6502 vectors
    .word NMI    ; fffa nmi/vblank
    .word RST    ; fffc reset
    .word IRQ    ; fffe irq/brk


; CHR ROM data 
.segment "CHARS"
.incbin "PWAA.chr"
