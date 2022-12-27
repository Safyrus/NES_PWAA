.include "rleinc.asm"
.include "draw_bkg.asm"
.include "draw_spr.asm"
.include "frame.asm"

palette_table_0:
.byte $0F
.byte $0F
.byte $0F
.byte $0F
palette_table_1:
.byte $00
.byte $01
.byte $14
.byte $26
palette_table_2:
.byte $10
.byte $11
.byte $2A
.byte $37
palette_table_3:
.byte $30
.byte $21
.byte $21
.byte $30

img_data:
; flags
; FPTS ..BB
; ||||   ++-- CHR bits for the MMC5 upper CHR Bank bits
; |||+------- is Sprite map present ?
; ||+-------- is Tile map present ?
; |+--------- is Palette present ?
; +---------- 1 = Full frame
;             0 = partial frame
.byte %11110000

.byte $00, $01 ; palette 0 indices. (background color)
.byte $00, $02 ; palette 1 indices. (character primary color)
.byte $00, $00 ; palette 2 indices. (character contour color)
.byte $00, $03 ; palette 4 indices. (character secondary color)

.incbin "data/img_bkg.bin"
.incbin "data/img_spr.bin"
