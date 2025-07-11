img_ptr_list_lo:
.byte (0 >> 0) & $FF
.byte (104275 >> 0) & $FF
.byte (212932 >> 0) & $FF

img_ptr_list_hi:
.byte ((0 >> 8) & $1F) + $80
.byte ((104275 >> 8) & $1F) + $80
.byte ((212932 >> 8) & $1F) + $80

img_ptr_list_bnk:
.byte ((0 >> 13) & $7F) + IMG_BNK
.byte ((104275 >> 13) & $7F) + IMG_BNK
.byte ((212932 >> 13) & $7F) + IMG_BNK

evi_ptr_list_lo:
.byte (214193 >> 0) & $FF

evi_ptr_list_hi:
.byte ((214193 >> 8) & $1F) + $80

evi_ptr_list_bnk:
.byte ((214193 >> 13) & $7F) + IMG_BNK
