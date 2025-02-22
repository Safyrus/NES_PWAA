; ################
; File: Image Pointers
; ################
; Note: This file was generated

img_ptr_list_lo:
.byte (0 >> 0) & $FF
.byte (124832 >> 0) & $FF

img_ptr_list_hi:
.byte ((0 >> 8) & $1F) + $80
.byte ((124832 >> 8) & $1F) + $80

img_ptr_list_bnk:
.byte ((0 >> 13) & $7F) + IMG_BNK
.byte ((124832 >> 13) & $7F) + IMG_BNK

evi_ptr_list_lo:
.byte (144387 >> 0) & $FF

evi_ptr_list_hi:
.byte ((144387 >> 8) & $1F) + $80

evi_ptr_list_bnk:
.byte ((144387 >> 13) & $7F) + IMG_BNK

