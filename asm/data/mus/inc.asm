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
.segment "MUS_BNK5"
.include "music_5.s"
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
.segment "DPCM_BNK5"
.incbin "music_bank5.dmc"

.segment "LAST_BNK"

music_idx_table:
    .byte $0 ; 0 - Opening (WIP)
    .byte $0 ; 1 - Courtroom Lounge
    .byte $1 ; 2 - Trial
    .byte $0 ; 3 - Questioning - Moderato
    .byte $2 ; 4 - Logic and Trick
    .byte $0 ; 5 - Objection!
    .byte $1 ; 6 - Questioning - Allegro
    .byte $0 ; 7 - Cornered
    .byte $1 ; 8 - Telling the Truth
    .byte $3 ; 9 - Suspense
    .byte $2 ; 10 - Cornered - Variation
    .byte $1 ; 11 - Jingle
    .byte $4 ; 12 - Investigation
    .byte $2 ; 13 - Maya Fey
    .byte $0 ; 14 - Detention Center
    .byte $3 ; 15 - Dick Gumshoe
    .byte $2 ; 16 - Heartbroken Maya
    .byte $3 ; 17 - Marvin Grossberg
    .byte $3 ; 18 - Happy People
    .byte $1 ; 19 - Light and Shadow of the Film Studio
    .byte $1 ; 20 - Steel Samuria
    .byte $4 ; 21 - The DL-6 Incident
    .byte $2 ; 22 - Investigation - Core
    .byte $2 ; 23 - Class Trial
    .byte $5 ; 24 - Victory
    .byte $3 ; 25 - Ending
    .byte $6 ; 26 - Turnabout Sisters Ballad
    .byte $5 ; 27 - dpcm

music_bank_table:
    .byte $3+MUS_BNK ; 0 - Opening (WIP)
    .byte $5+MUS_BNK ; 1 - Courtroom Lounge
    .byte $3+MUS_BNK ; 2 - Trial
    .byte $4+MUS_BNK ; 3 - Questioning - Moderato
    .byte $3+MUS_BNK ; 4 - Logic and Trick
    .byte $2+MUS_BNK ; 5 - Objection!
    .byte $2+MUS_BNK ; 6 - Questioning - Allegro
    .byte $0+MUS_BNK ; 7 - Cornered
    .byte $4+MUS_BNK ; 8 - Telling the Truth
    .byte $3+MUS_BNK ; 9 - Suspense
    .byte $2+MUS_BNK ; 10 - Cornered - Variation
    .byte $0+MUS_BNK ; 11 - Jingle
    .byte $3+MUS_BNK ; 12 - Investigation
    .byte $0+MUS_BNK ; 13 - Maya Fey
    .byte $1+MUS_BNK ; 14 - Detention Center
    .byte $0+MUS_BNK ; 15 - Dick Gumshoe
    .byte $4+MUS_BNK ; 16 - Heartbroken Maya
    .byte $4+MUS_BNK ; 17 - Marvin Grossberg
    .byte $2+MUS_BNK ; 18 - Happy People
    .byte $5+MUS_BNK ; 19 - Light and Shadow of the Film Studio
    .byte $1+MUS_BNK ; 20 - Steel Samuria
    .byte $4+MUS_BNK ; 21 - The DL-6 Incident
    .byte $1+MUS_BNK ; 22 - Investigation - Core
    .byte $5+MUS_BNK ; 23 - Class Trial
    .byte $4+MUS_BNK ; 24 - Victory
    .byte $1+MUS_BNK ; 25 - Ending
    .byte $4+MUS_BNK ; 26 - Turnabout Sisters Ballad
    .byte $3+MUS_BNK ; 27 - dpcm
