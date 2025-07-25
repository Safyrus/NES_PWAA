img_ptr_list_lo:
.byte (0 >> 0) & $FF
.byte (106403 >> 0) & $FF
.byte (215173 >> 0) & $FF

img_ptr_list_hi:
.byte ((0 >> 8) & $1F) + $80
.byte ((106403 >> 8) & $1F) + $80
.byte ((215173 >> 8) & $1F) + $80

img_ptr_list_bnk:
.byte ((0 >> 13) & $7F) + IMG_BNK
.byte ((106403 >> 13) & $7F) + IMG_BNK
.byte ((215173 >> 13) & $7F) + IMG_BNK

evi_ptr_list_lo:
.byte (230325 >> 0) & $FF

evi_ptr_list_hi:
.byte ((230325 >> 8) & $1F) + $80

evi_ptr_list_bnk:
.byte ((230325 >> 13) & $7F) + IMG_BNK
