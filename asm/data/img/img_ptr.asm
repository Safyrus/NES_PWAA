; ################
; File: Image Pointers
; ################
; Note: This file was generated

img_ptr_list_lo:
.byte (0 >> 0) & $FF
.byte (124696 >> 0) & $FF

img_ptr_list_hi:
.byte ((0 >> 8) & $1F) + $A0
.byte ((124696 >> 8) & $1F) + $A0

img_ptr_list_bnk:
.byte ((0 >> 13) & $7F) + IMG_BNK
.byte ((124696 >> 13) & $7F) + IMG_BNK

