;################
; File: Main
;################

;--------------------------------
; Function: Main
;--------------------------------
; Main function called just after the reset vector
;
; Summary:
;--- Text
;   init()
;   loop:
;     wait_next_frame()
;     inputs()
;     effects()
;     image()
;     name()
;     lz()
;     dialog_box()
;     photo()
;---
;--------------------------------
MAIN:
    .include "init.asm"

MAIN_LOOP:
    ; wait for start of frame / acknowledge nmi
    JSR wait_next_frame

    ; update animation
    JSR update_anim

    ; loop back to start of main
    JMP MAIN_LOOP
