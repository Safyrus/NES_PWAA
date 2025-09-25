img_ptr_list_lo:
.byte (0 >> 0) & $FF
.byte (110713 >> 0) & $FF
.byte (193284 >> 0) & $FF

img_ptr_list_hi:
.byte ((0 >> 8) & $1F) + $80
.byte ((110713 >> 8) & $1F) + $80
.byte ((193284 >> 8) & $1F) + $80

img_ptr_list_bnk:
.byte ((0 >> 13) & $7F) + IMG_BNK
.byte ((110713 >> 13) & $7F) + IMG_BNK
.byte ((193284 >> 13) & $7F) + IMG_BNK

evi_ptr_list_lo:
.byte (212725 >> 0) & $FF

evi_ptr_list_hi:
.byte ((212725 >> 8) & $1F) + $80

evi_ptr_list_bnk:
.byte ((212725 >> 13) & $7F) + IMG_BNK
