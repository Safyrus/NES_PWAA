
.segment "MUS_BNK0"
.include "music_0.s"

.segment "MUS_BNK1"
.include "music_1.s"


.segment "MUS_SFX"
.include "sfx.s"

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
.byte $00           ; NONE
.byte $00 ; Prologue
.byte $01 ; Courtroom Lounge
.byte $02 ; Trial
.byte $03 ; Examination
.byte $04 ; Examination 2
.byte $00 ; Objection
.byte $01 ; Cornered
.byte $02 ; Cornered 2
.byte $03 ; Won the Case
