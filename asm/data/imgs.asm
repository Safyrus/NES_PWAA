; todo a description

.segment "IMGS_BNK"
img_0:
.incbin "imgs/img_0.bin" ;../../data/empty.png

.segment "ANIM_BNK"
img_bkg_table:
.word (img_0 & $1FFF) + SEGMENT_IMGS_START_ADR ; ../../data/empty.png
img_bkg_table_bank:
.byte IMG_BNK + $0

img_anim_table:
@default:
.byte $01 ; size

