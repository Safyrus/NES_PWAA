; ----------------
.segment "LAST_BNK"
; ----------------
.include "snif_decode.asm"
.include "rleinc.asm"
.include "act.asm"

.include "display/anim.asm"
.include "display/img.asm"
.include "display/evi.asm"

.include "fetch/anim.asm"
.include "fetch/evi.asm"
.include "fetch/img.asm"
.include "fetch/util.asm"



; ----------------
.segment "CODE_BNK"
; ----------------
.include "display/bkg_chr.asm"
.include "display/dialog.asm"
.include "display/remove.asm"
.include "display/util.asm"

.include "draw/close_packet.asm"
.include "draw/packet_res.asm"
.include "draw/packets.asm"
.include "draw/sprites.asm"

.include "update/anim.asm"
.include "update/dialog.asm"
.include "update/image2.asm"
.include "update/light.asm"
.include "update/pal.asm"

.include "cp_pal.asm"
.include "cr.asm"
