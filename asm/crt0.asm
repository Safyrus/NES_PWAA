;****************
; Author: Safyrus
;****************

; Header of the file (not part of the cartridge, used by the emulator)
.segment "HEADER"
    ; 0-3: Identification String
    .byte "NES", $1A

    ; 4: PRG ROM size in 16KB
    .byte $40

    ; 5: CHR ROM size in 8KB
    .byte $80

.ifndef INES1
    .out "ines 2.0"
    ; 6: Flags 6
    ; NNNN FTBM
    ; |||| |||+-- Hard-wired nametable mirroring type
    ; |||| |||     0: Horizontal or mapper-controlled
    ; |||| |||     1: Vertical
    ; |||| ||+--- "Battery" and other non-volatile memory
    ; |||| ||      0: Not present
    ; |||| ||      1: Present
    ; |||| |+--- 512-byte Trainer
    ; |||| |      0: Not present
    ; |||| |      1: Present between Header and PRG-ROM data
    ; |||| +---- Hard-wired four-screen mode
    ; ||||        0: No
    ; ||||        1: Yes
    ; ++++------ Mapper Number D0..D3
    .byte %01010010

    ; 7: Flags 7
    ; NNNN 10TT
    ; |||| ||++- Console type
    ; |||| ||     0: Nintendo Entertainment System/Family Computer
    ; |||| ||     1: Nintendo Vs. System
    ; |||| ||     2: Nintendo Playchoice 10
    ; |||| ||     3: Extended Console Type
    ; |||| ++--- NES 2.0 identifier
    ; ++++------ Mapper Number D4..D7
    .byte %00001000

    ; 8: Mapper MSB/Submapper
    ; SSSS NNNN
    ; |||| ++++- Mapper number D8..D11
    ; ++++------ Submapper number
    .byte %00000000

    ; 9: PRG-ROM/CHR-ROM size MSB
    ; CCCC PPPP
    ; |||| ++++- PRG-ROM size MSB
    ; ++++------ CHR-ROM size MSB
    .byte %00000000

    ; 10: PRG-RAM/EEPROM size
    ; pppp PPPP
    ; |||| ++++- PRG-RAM (volatile) shift count
    ; ++++------ PRG-NVRAM/EEPROM (non-volatile) shift count
    ; If the shift count is zero, there is no PRG-(NV)RAM.
    ; If the shift count is non-zero, the actual size is
    ; "64 << shift count" bytes, i.e. 8192 bytes for a shift count of 7.
    .byte %10000000

    ; 11: CHR-RAM size
    ; cccc CCCC
    ; |||| ++++- CHR-RAM size (volatile) shift count
    ; ++++------ CHR-NVRAM size (non-volatile) shift count
    ; 
    ; If the shift count is zero, there is no CHR-(NV)RAM.
    ; If the shift count is non-zero, the actual size is
    ; "64 << shift count" bytes, i.e. 8192 bytes for a shift count of 7.
    .byte %00000000

    ; 12: CPU/PPU Timing
    ; .... ..VV
    ;        ++- CPU/PPU timing mode
    ;             0: RP2C02 ("NTSC NES")
    ;             1: RP2C07 ("Licensed PAL NES")
    ;             2: Multiple-region
    ;             3: UMC 6527P ("Dendy")
    .byte %00000000

    ; 13: When Byte 7 AND 3 =1: Vs. System Type
    ;       MMMM PPPP
    ;       |||| ++++- Vs. PPU Type
    ;       ++++------ Vs. Hardware Type
    ;
    ;     When Byte 7 AND 3 =3: Extended Console Type
    ;       .... CCCC
    ;            ++++- Extended Console Type
    .byte %00000000

    ; 14: Miscellaneous ROMs
    ; .... ..RR
    ;        ++- Number of miscellaneous ROMs present
    .byte %00000000

    ; 15: Default Expansion Device
    ; ..DD DDDD
    ;   ++-++++- Default Expansion Device
    .byte %00000000
.else
    .out "ines 1.0"
    ; Flag 6
    ; 76543210
    ; ||||||||
    ; |||||||+- Mirroring: 0: horizontal (vertical arrangement) (CIRAM A10 = PPU A11)
    ; |||||||              1: vertical (horizontal arrangement) (CIRAM A10 = PPU A10)
    ; ||||||+-- 1: Cartridge contains battery-backed PRG RAM ($6000-7FFF) or other persistent memory
    ; |||||+--- 1: 512-byte trainer at $7000-$71FF (stored before PRG data)
    ; ||||+---- 1: Ignore mirroring control or above mirroring bit; instead provide four-screen VRAM
    ; ++++----- Lower nybble of mapper number
    .byte %01010010

    ; Flag 7
    ; 76543210
    ; ||||||||
    ; |||||||+- VS Unisystem
    ; ||||||+-- PlayChoice-10 (8 KB of Hint Screen data stored after CHR data)
    ; ||||++--- If equal to 2, flags 8-15 are in NES 2.0 format
    ; ++++----- Upper nybble of mapper number
    .byte %00000000

    ; Flag 8
    ; 76543210
    ; ||||||||
    ; ++++++++- PRG RAM size
    .byte %00000010

    ; Flag 9
    ; 76543210
    ; ||||||||
    ; |||||||+- TV system (0: NTSC; 1: PAL)
    ; +++++++-- Reserved, set to zero
    .byte %00000000

    ; Flag 10
    ; 76543210
    ;   ||  ||
    ;   ||  ++- TV system (0: NTSC; 2: PAL; 1/3: dual compatible)
    ;   |+----- PRG RAM ($6000-$7FFF) (0: present; 1: not present)
    ;   +------ 0: Board has no bus conflicts; 1: Board has bus conflicts
    .byte %00000000

    ; padding
    .byte 0, 0, 0, 0, 0

.endif

; assembler declaration
.include "constant.asm"
.include "macro.asm"
.include "memory.asm"

.segment "LAST_BNK"
    ; 6502 vectors subrountines
    .include "vector/nmi.asm"
    .include "vector/rst.asm"
    .include "vector/irq.asm"
    .include "vector/scanline.asm"

    ; main file
    .include "main.asm"
    .include "joypad.asm"
    .include "other.asm"

    ; FamiStudio Sound Engine
    .include "audio/famistudio_ca65.s"
    ; musics
    .include "audio/data.asm"

.segment "CODE_BNK"
    .include "dialog/main.asm"
    .include "choice.asm"
    .include "img/main.asm"
    .include "courtrecord/main.asm"
    .include "investigation/main.asm"

.segment "IMGS_BNK"
    .include "data/imgs.asm"

.segment "TXT_BNK"
    .include "data/txt_data.asm"

.segment "EVI_BNK"
    evi_imgs:
    .incbin "data/evidences.bin"

; 6502 vectors
.segment "VECTORS"
    ; 6502 vectors
    .word NMI    ; fffa nmi/vblank
    .word RST    ; fffc reset
    .word IRQ    ; fffe irq/brk


; CHR ROM data 
.segment "CHARS"
.incbin "PWAA.chr"
