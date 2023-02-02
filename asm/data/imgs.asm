; todo a description

.segment "IMGS_BNK"
img_0:
.incbin "imgs/img_0.bin" ;../../data/space.png
img_1:
.incbin "imgs/img_1.bin" ;../../data/sprite1.png
img_2:
.incbin "imgs/img_2.bin" ;../../data/sprite2.png
img_3:
.incbin "imgs/img_3.bin" ;../../data/sprite3.png
img_4:
.incbin "imgs/img_4.bin" ;../../data/sprite4.png

.segment "CODE_BNK"
img_bkg_table:
.word img_0 ; ../../data/space.png
img_bkg_table_bank:
.byte $82

img_anim_table:
img_anim_0:
.byte $10 ; size
.byte $10 ; time
.word img_1 ; ../../data/sprite1.png
.byte $82 ; bank
.byte $10 ; time
.word img_2 ; ../../data/sprite2.png
.byte $82 ; bank
.byte $10 ; time
.word img_3 ; ../../data/sprite3.png
.byte $82 ; bank
.byte $10 ; time
.word img_4 ; ../../data/sprite4.png
.byte $82 ; bank

