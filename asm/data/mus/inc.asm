; This file was generated

; Include SFX
.segment "SFX_BNK"
.include "sfx.s"
.include "dpcm.s"
; Include music data
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
; Include DPCM
.segment "DPCM_BNK0"
.incbin "music_bank0.dmc"
.segment "DPCM_BNK1"
.incbin "music_bank1.dmc"
.segment "DPCM_BNK2"
.incbin "music_bank2.dmc"
.segment "DPCM_BNK3"
.incbin "music_bank3.dmc"
.segment "DPCM_BNK4"
.incbin "music_bank4.dmc"

.segment "LAST_BNK"

music_idx_table:
    .byte $0 ; 0 - Opening (WIP)
    .byte $0 ; 1 - Courtroom Lounge
    .byte $1 ; 2 - Trial
    .byte $1 ; 3 - Questioning - Moderato
    .byte $0 ; 4 - Logic and Trick
    .byte $1 ; 5 - Objection!
    .byte $0 ; 6 - Questioning - Allegro
    .byte $1 ; 7 - Cornered
    .byte $2 ; 8 - Telling the Truth
    .byte $0 ; 9 - Suspense
    .byte $2 ; 10 - Cornered - Variation
    .byte $3 ; 11 - Jingle
    .byte $2 ; 12 - Investigation
    .byte $3 ; 13 - Maya Fey
    .byte $3 ; 14 - Detention Center
    .byte $4 ; 15 - Dick Gumshoe
    .byte $2 ; 16 - Heartbroken Maya
    .byte $1 ; 17 - Marvin Grossberg
    .byte $3 ; 18 - Happy People
    .byte $4 ; 19 - Light and Shadow of the Film Studio
    .byte $4 ; 20 - Steel Samuria
    .byte $2 ; 21 - The DL-6 Incident
    .byte $3 ; 22 - Investigation - Core
    .byte $5 ; 23 - Class Trial
    .byte $4 ; 24 - Victory
    .byte $4 ; 25 - Ending
    .byte $5 ; 26 - Turnabout Sisters Ballad
    .byte $5 ; 27 - dpcm

music_bank_table:
    .byte $3+MUS_BNK ; 0 - Opening (WIP)
    .byte $0+MUS_BNK ; 1 - Courtroom Lounge
    .byte $0+MUS_BNK ; 2 - Trial
    .byte $3+MUS_BNK ; 3 - Questioning - Moderato
    .byte $1+MUS_BNK ; 4 - Logic and Trick
    .byte $1+MUS_BNK ; 5 - Objection!
    .byte $2+MUS_BNK ; 6 - Questioning - Allegro
    .byte $2+MUS_BNK ; 7 - Cornered
    .byte $1+MUS_BNK ; 8 - Telling the Truth
    .byte $4+MUS_BNK ; 9 - Suspense
    .byte $3+MUS_BNK ; 10 - Cornered - Variation
    .byte $3+MUS_BNK ; 11 - Jingle
    .byte $0+MUS_BNK ; 12 - Investigation
    .byte $0+MUS_BNK ; 13 - Maya Fey
    .byte $1+MUS_BNK ; 14 - Detention Center
    .byte $1+MUS_BNK ; 15 - Dick Gumshoe
    .byte $2+MUS_BNK ; 16 - Heartbroken Maya
    .byte $4+MUS_BNK ; 17 - Marvin Grossberg
    .byte $2+MUS_BNK ; 18 - Happy People
    .byte $2+MUS_BNK ; 19 - Light and Shadow of the Film Studio
    .byte $3+MUS_BNK ; 20 - Steel Samuria
    .byte $4+MUS_BNK ; 21 - The DL-6 Incident
    .byte $4+MUS_BNK ; 22 - Investigation - Core
    .byte $2+MUS_BNK ; 23 - Class Trial
    .byte $0+MUS_BNK ; 24 - Victory
    .byte $4+MUS_BNK ; 25 - Ending
    .byte $3+MUS_BNK ; 26 - Turnabout Sisters Ballad
    .byte $0+MUS_BNK ; 27 - dpcm
