; "
; OAM_size = from RAM
; cur_bnk = [0]*8
; for list in sprite lists
;     update_cur_bnk()
;     for s from 0 to 64
;         if list.spr[s].bnk not in cur_bnk
;             continue
;         if list.spr[s].y >= 240
;             continue
;         if list.spr[s].y not in displayble line (behind/infront of UI)
;             continue
;         OAMpage[OAM_size] = list.spr[s]
;         OAM_size++
;         if OAMsize == 64
;             save list and spr and restore next call

; Note: OAMsize = nb_reserved_sprite each frame
; "