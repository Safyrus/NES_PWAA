; todo a description

.segment "IMGS_BNK"
img_0:
.incbin "imgs/img_0.bin" ;../../data/empty.png
img_1:
.incbin "imgs/img_1.bin" ;../../data/space.png
img_2:
.incbin "imgs/img_2.bin" ;../../data/empty.png;../../data/sprite1.png
img_3:
.incbin "imgs/img_3.bin" ;../../data/sprite1.png;../../data/sprite2.png
img_4:
.incbin "imgs/img_4.bin" ;../../data/sprite2.png;../../data/sprite3.png
img_5:
.incbin "imgs/img_5.bin" ;../../data/sprite3.png;../../data/sprite4.png
img_6:
.incbin "imgs/img_6.bin" ;../../data/sprite4.png;../../data/sprite1.png

.segment "CODE_BNK"
img_bkg_table:
.word (img_0 & $FFFF) ; ../../data/empty.png
.word (img_1 & $FFFF) ; ../../data/space.png
img_bkg_table_bank:
.byte $c0
.byte $c0

img_anim_table:
default:
.byte $01 ; size
img_anim_0:
.byte $15 ; size
.byte $10 ; time
.word (img_2 & $FFFF) ; ../../data/empty.png;../../data/sprite1.png
.byte $c0 ; bank
.byte $10 ; time
.word (img_3 & $FFFF) ; ../../data/sprite1.png;../../data/sprite2.png
.byte $c0 ; bank
.byte $10 ; time
.word (img_4 & $FFFF) ; ../../data/sprite2.png;../../data/sprite3.png
.byte $c0 ; bank
.byte $10 ; time
.word (img_5 & $FFFF) ; ../../data/sprite3.png;../../data/sprite4.png
.byte $c0 ; bank
.byte $00 ; time
.word (img_6 & $FFFF) ; ../../data/sprite4.png;../../data/sprite1.png
.byte $c0 ; bank

palette_table:
.byte $0F, $0F, $0F, $0F ; BLACK[0, 0, 0], BLACK[0, 0, 0], BLACK[0, 0, 0], BLACK[0, 0, 0]
.byte $0F, $01, $11, $21 ; BLACK[0, 0, 0], DARKEST BLUE[1, 26, 81], DARK BLUE[30, 74, 157], BLUE[105, 158, 252]
.byte $0F, $39, $37, $11 ; BLACK[0, 0, 0], LIGHT OLIVE[201, 226, 158], LIGHT ORANGE[232, 208, 170], DARK BLUE[30, 74, 157]
.byte $0F, $39, $11, $21 ; BLACK[0, 0, 0], LIGHT OLIVE[201, 226, 158], DARK BLUE[30, 74, 157], BLUE[105, 158, 252]
.byte $0F, $26, $22, $30 ; BLACK[0, 0, 0], RED[222, 124, 112], SLATEBLUE[137, 135, 255], WHITE[254, 255, 255]

