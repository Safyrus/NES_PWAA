; todo a description

.segment "IMGS_BNK"
img_0:
.incbin "imgs/img_0.bin" ;../../data/anim\..\empty.png
img_1:
.incbin "imgs/img_1.bin" ;../../data/anim\..\img\star_sky_castle.png
img_2:
.incbin "imgs/img_2.bin" ;../../data/anim\..\img\green_landscape.png
img_3:
.incbin "imgs/img_3.bin" ;../../data/anim\..\img\orange_dune.png
img_4:
.incbin "imgs/img_4.bin" ;../../data/anim\..\img\scene_1.png
img_5:
.incbin "imgs/img_5.bin" ;../../data/anim\..\img\scene_1.png;../../data/anim\..\img\robot\teach\idle_1.png
img_6:
.incbin "imgs/img_6.bin" ;../../data/anim\..\img\robot\teach\idle_1.png;../../data/anim\..\img\robot\teach\idle_2.png
img_7:
.incbin "imgs/img_7.bin" ;../../data/anim\..\img\robot\teach\idle_2.png;../../data/anim\..\img\robot\teach\idle_1.png
img_8:
.incbin "imgs/img_8.bin" ;../../data/anim\..\img\scene_1.png;../../data/anim\..\img\robot\teach\talk_1.png
img_9:
.incbin "imgs/img_9.bin" ;../../data/anim\..\img\robot\teach\talk_1.png;../../data/anim\..\img\robot\teach\talk_2.png
img_10:
.incbin "imgs/img_10.bin" ;../../data/anim\..\img\robot\teach\talk_2.png;../../data/anim\..\img\robot\teach\talk_1.png

.segment "ANIM_BNK"
img_bkg_table:
.word (img_0 & $1FFF) + SEGMENT_IMGS_START_ADR ; ../../data/anim\..\empty.png
.word (img_1 & $1FFF) + SEGMENT_IMGS_START_ADR ; ../../data/anim\..\img\star_sky_castle.png
.word (img_2 & $1FFF) + SEGMENT_IMGS_START_ADR ; ../../data/anim\..\img\green_landscape.png
.word (img_3 & $1FFF) + SEGMENT_IMGS_START_ADR ; ../../data/anim\..\img\orange_dune.png
.word (img_4 & $1FFF) + SEGMENT_IMGS_START_ADR ; ../../data/anim\..\img\scene_1.png
img_bkg_table_bank:
.byte IMG_BNK + $0
.byte IMG_BNK + $0
.byte IMG_BNK + $0
.byte IMG_BNK + $0
.byte IMG_BNK + $0

img_anim_table:
@default:
.byte $01 ; size
img_anim_1:
.byte $0D ; size
.byte $1E ; time
.word (img_5 & $1FFF) + SEGMENT_IMGS_START_ADR ; ../../data/anim\..\img\scene_1.png;../../data/anim\..\img\robot\teach\idle_1.png
.byte IMG_BNK + $0 ; bank
.byte $1E ; time
.word (img_6 & $1FFF) + SEGMENT_IMGS_START_ADR ; ../../data/anim\..\img\robot\teach\idle_1.png;../../data/anim\..\img\robot\teach\idle_2.png
.byte IMG_BNK + $0 ; bank
.byte $00 ; time
.word (img_7 & $1FFF) + SEGMENT_IMGS_START_ADR ; ../../data/anim\..\img\robot\teach\idle_2.png;../../data/anim\..\img\robot\teach\idle_1.png
.byte IMG_BNK + $0 ; bank
img_anim_2:
.byte $0D ; size
.byte $1E ; time
.word (img_8 & $1FFF) + SEGMENT_IMGS_START_ADR ; ../../data/anim\..\img\scene_1.png;../../data/anim\..\img\robot\teach\talk_1.png
.byte IMG_BNK + $0 ; bank
.byte $1E ; time
.word (img_9 & $1FFF) + SEGMENT_IMGS_START_ADR ; ../../data/anim\..\img\robot\teach\talk_1.png;../../data/anim\..\img\robot\teach\talk_2.png
.byte IMG_BNK + $0 ; bank
.byte $00 ; time
.word (img_10 & $1FFF) + SEGMENT_IMGS_START_ADR ; ../../data/anim\..\img\robot\teach\talk_2.png;../../data/anim\..\img\robot\teach\talk_1.png
.byte IMG_BNK + $0 ; bank

