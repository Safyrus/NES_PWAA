; ################
; File: Animation Pointers
; ################
; Note: This file was generated

anim_ptr_list_lo:
.byte (0 >> 0) & $FF

anim_ptr_list_hi:
.byte ((0 >> 8) & $1F) + $A0

anim_ptr_list_bnk:
.byte ((0 >> 13) & $7F) + ANI_BNK

