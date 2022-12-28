.include "rleinc.asm"
.include "draw_bkg.asm"
.include "draw_spr.asm"
.include "frame.asm"
.include "pal.asm"

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
