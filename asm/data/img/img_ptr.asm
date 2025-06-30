img_ptr_list_lo:
.byte (0 >> 0) & $FF
.byte (101612 >> 0) & $FF

img_ptr_list_hi:
.byte ((0 >> 8) & $1F) + $80
.byte ((101612 >> 8) & $1F) + $80

img_ptr_list_bnk:
.byte ((0 >> 13) & $7F) + IMG_BNK
.byte ((101612 >> 13) & $7F) + IMG_BNK

evi_ptr_list_lo:
.byte (204967 >> 0) & $FF

evi_ptr_list_hi:
.byte ((204967 >> 8) & $1F) + $80

evi_ptr_list_bnk:
.byte ((204967 >> 13) & $7F) + IMG_BNK
