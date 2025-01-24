; This file was generated

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
    .byte $4 ; 11 - Jingle
    .byte $5 ; 12 - Investigation
    .byte $1 ; 13 - Maya Fey
    .byte $2 ; 14 - Detention Center
    .byte $2 ; 15 - Dick Gumshoe
    .byte $3 ; 16 - Heartbroken Maya
    .byte $4 ; 17 - Marvin Grossberg
    .byte $3 ; 18 - Happy People
    .byte $1 ; 19 - Light and Shadow of the Film Studio
    .byte $0 ; 20 - Steel Samuria
    .byte $5 ; 21 - The DL-6 Incident
    .byte $1 ; 22 - Investigation - Core
    .byte $6 ; 23 - Class Trial
    .byte $7 ; 24 - Victory
    .byte $2 ; 25 - Ending
    .byte $3 ; 26 - Turnabout Sisters Ballad

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
    .byte $3+MUS_BNK ; 11 - Jingle
    .byte $3+MUS_BNK ; 12 - Investigation
    .byte $0+MUS_BNK ; 13 - Maya Fey
    .byte $4+MUS_BNK ; 14 - Detention Center
    .byte $0+MUS_BNK ; 15 - Dick Gumshoe
    .byte $4+MUS_BNK ; 16 - Heartbroken Maya
    .byte $4+MUS_BNK ; 17 - Marvin Grossberg
    .byte $2+MUS_BNK ; 18 - Happy People
    .byte $5+MUS_BNK ; 19 - Light and Shadow of the Film Studio
    .byte $1+MUS_BNK ; 20 - Steel Samuria
    .byte $4+MUS_BNK ; 21 - The DL-6 Incident
    .byte $1+MUS_BNK ; 22 - Investigation - Core
    .byte $4+MUS_BNK ; 23 - Class Trial
    .byte $4+MUS_BNK ; 24 - Victory
    .byte $1+MUS_BNK ; 25 - Ending
    .byte $1+MUS_BNK ; 26 - Turnabout Sisters Ballad
