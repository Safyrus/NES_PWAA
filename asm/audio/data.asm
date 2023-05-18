
.segment "MUS_BNK0"
.include "music_0.s"

.segment "MUS_BNK1"
.include "music_1.s"

.segment "MUS_SFX"
.include "sfx.s"

.segment "DPCM_BNK"
.incbin "dpcm.dmc"

.segment "LAST_BNK"
music_bank_table:
.byte $00           ; NONE
.byte MUS_BNK + $00 ; Prologue
.byte MUS_BNK + $00 ; Courtroom Lounge
.byte MUS_BNK + $00 ; Trial
.byte MUS_BNK + $00 ; Examination
.byte MUS_BNK + $00 ; Examination 2
.byte MUS_BNK + $01 ; Objection
.byte MUS_BNK + $01 ; Cornered
.byte MUS_BNK + $01 ; Cornered 2
.byte MUS_BNK + $01 ; Won the Case

music_idx_table:
.byte $00 ; NONE
.byte $00 ; Prologue
.byte $01 ; Courtroom Lounge
.byte $02 ; Trial
.byte $03 ; Examination
.byte $04 ; Examination 2
.byte $00 ; Objection
.byte $01 ; Cornered
.byte $02 ; Cornered 2
.byte $03 ; Won the Case

dpcm_samples:
.byte $00+.lobyte(FAMISTUDIO_DPCM_PTR),$74,$8d,$40	;1 (phoenix_obj)
.byte $1d+.lobyte(FAMISTUDIO_DPCM_PTR),$54,$8d,$40	;2 (phoenix_holdit)
.byte $32+.lobyte(FAMISTUDIO_DPCM_PTR),$6a,$8c,$40	;3 (payne_obj)
