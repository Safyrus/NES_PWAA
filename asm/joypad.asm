;################
; File: Joypad
;################
; subrountines related to player inputs

;--------------------------------
; Subroutine: readjoy
;--------------------------------
;
; Subroutine from <NesDev:https://www.nesdev.org/wiki/Controller_reading_code>
;
; Read the player input from joypad 1
; 
; Parameter:
;   None
;
; Return:
;   buttons_1 - Joypad 1 inputs (ABTSUDLR)
;--------------------------------
readjoy:
    lda #$01
    ; While the strobe bit is set, buttons will be continuously reloaded.
    ; This means that reading from IO_JOY1 will only return the state of the
    ; first button: button A.
    sta IO_JOY1
    sta buttons_1
    lsr a        ; now A is 0
    ; By storing 0 into IO_JOY1, the strobe bit is cleared and the reloading stops.
    ; This allows all 8 buttons (newly reloaded) to be read from IO_JOY1.
    sta IO_JOY1
    @loop:
        lda IO_JOY1
        lsr a	       ; bit 0 -> Carry
        rol buttons_1  ; Carry -> bit 0; bit 7 -> Carry
        bcc @loop
    rts


;--------------------------------
; Subroutine: update_input
;--------------------------------
;
; Update the player input
; if the input timer has reached 0
; 
; Parameter:
;   None
;
; Return:
;   buttons_1 - Joypad 1 inputs (ABTSUDLR)
;--------------------------------
update_input:
    ; if buttons_1_timer > 0
    LDA buttons_1_timer
    bze @timer_reset
    ; then
        ; buttons_1_timer--
        DEC buttons_1_timer
        ; input = 0
        mov buttons_1, #$00
        ; end
        JMP @end
    ; else
    @timer_reset:
        ; read input
        JSR readjoy
        ; if input != 0
        LDA buttons_1
        bze @end
            ; buttons_1_timer = BTN_TIMER
            mov buttons_1_timer, #BTN_TIMER
    @end:
    RTS
