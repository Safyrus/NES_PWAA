img_ptr_list_lo:
.byte (0 >> 0) & $FF
.byte (150748 >> 0) & $FF
.byte (215919 >> 0) & $FF

img_ptr_list_hi:
.byte ((0 >> 8) & $1F) + $80
.byte ((150748 >> 8) & $1F) + $80
.byte ((215919 >> 8) & $1F) + $80

img_ptr_list_bnk:
.byte ((0 >> 13) & $7F) + IMG_BNK
.byte ((150748 >> 13) & $7F) + IMG_BNK
.byte ((215919 >> 13) & $7F) + IMG_BNK

evi_ptr_list_lo:
.byte (235171 >> 0) & $FF

evi_ptr_list_hi:
.byte ((235171 >> 8) & $1F) + $80

evi_ptr_list_bnk:
.byte ((235171 >> 13) & $7F) + IMG_BNK
