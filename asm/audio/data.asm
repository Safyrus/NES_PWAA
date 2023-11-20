
.segment "MUS_BNK0"
.include "music_0.s"

.segment "MUS_BNK1"
.include "music_1.s"

.segment "MUS_BNK2"
.include "music_2.s"

.segment "MUS_BNK3"
.include "music_3.s"

.segment "MUS_BNK4"
.include "music_4.s"

.segment "SFX_BNK"
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
.byte MUS_BNK + $00 ; Logics and Tricks
.byte MUS_BNK + $00 ; Objection
.byte MUS_BNK + $00 ; Examination 2
.byte MUS_BNK + $01 ; Cornered
.byte MUS_BNK + $01 ; Announcing the Truth
.byte MUS_BNK + $01 ; Suspense
.byte MUS_BNK + $01 ; Cornered 2
.byte MUS_BNK + $01 ; Jingle
.byte MUS_BNK + $02 ; Search
.byte MUS_BNK + $02 ; Turnabout Sisters
.byte MUS_BNK + $02 ; Detention Center
.byte MUS_BNK + $02 ; Dick Gumshoe
.byte MUS_BNK + $02 ; Heartbroken Maya
.byte MUS_BNK + $02 ; Age, Regret, Retribution
.byte MUS_BNK + $03 ; Congratulations Everybody
.byte MUS_BNK + $03 ; Light and Shadow of The Film Studio
.byte MUS_BNK + $03 ; Steel Samuria
.byte MUS_BNK + $03 ; Case DL-6
.byte MUS_BNK + $03 ; Investigation
.byte MUS_BNK + $03 ; Won the Case
.byte MUS_BNK + $04 ; End
.byte MUS_BNK + $04 ; Turnabout Sisters Ballad

music_idx_table:
.byte $00 ; NONE
.byte $00 ; Prologue
.byte $01 ; Courtroom Lounge
.byte $02 ; Trial
.byte $03 ; Examination
.byte $04 ; Logics and Tricks
.byte $05 ; Objection
.byte $06 ; Examination 2
.byte $00 ; Cornered
.byte $01 ; Announcing the Truth
.byte $02 ; Suspense
.byte $03 ; Cornered 2
.byte $04 ; Jingle
.byte $00 ; Search
.byte $01 ; Turnabout Sisters
.byte $02 ; Detention Center
.byte $03 ; Dick Gumshoe
.byte $04 ; Heartbroken Maya
.byte $05 ; Age, Regret, Retribution
.byte $00 ; Congratulations Everybody
.byte $01 ; Light and Shadow of The Film Studio
.byte $02 ; Steel Samuria
.byte $03 ; Case DL-6
.byte $04 ; Investigation
.byte $05 ; Won the Case
.byte $00 ; End
.byte $01 ; Turnabout Sisters Ballad

dpcm_samples:
.byte $00+.lobyte(FAMISTUDIO_DPCM_PTR),$74,$8d,$40	;1 (phoenix_obj)
.byte $1d+.lobyte(FAMISTUDIO_DPCM_PTR),$54,$8d,$40	;2 (phoenix_holdit)
.byte $32+.lobyte(FAMISTUDIO_DPCM_PTR),$6a,$8c,$40	;3 (payne_obj)
