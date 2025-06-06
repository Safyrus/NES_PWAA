img_ptr_list_lo:
.byte (0 >> 0) & $FF
.byte (101653 >> 0) & $FF

img_ptr_list_hi:
.byte ((0 >> 8) & $1F) + $80
.byte ((101653 >> 8) & $1F) + $80

img_ptr_list_bnk:
.byte ((0 >> 13) & $7F) + IMG_BNK
.byte ((101653 >> 13) & $7F) + IMG_BNK

evi_ptr_list_lo:
.byte (205008 >> 0) & $FF

evi_ptr_list_hi:
.byte ((205008 >> 8) & $1F) + $80

evi_ptr_list_bnk:
.byte ((205008 >> 13) & $7F) + IMG_BNK
