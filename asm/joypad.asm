; Subroutine from NesDev (https://www.nesdev.org/wiki/Controller_reading_code)
; At the same time that we strobe bit 0, we initialize the ring counter
; so we're hitting two birds with one stone here
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
loop:
    lda IO_JOY1
    lsr a	       ; bit 0 -> Carry
    rol buttons_1  ; Carry -> bit 0; bit 7 -> Carry
    bcc loop
    rts


; update_btn_timer:
;     @timer:
;     LDA buttons_1_timer   ; decrease buttons_1_timer if it is not 0
;     BEQ @timer_reset
;     SEC
;     SBC #$01
;     JMP @end

;     @timer_reset:
;     LDA buttons_1        ; set buttons_1_timer if any button was pressed
;     BEQ @end
;     LDA #BTN_TIMER

;     @end:
;     STA buttons_1_timer
;     RTS
