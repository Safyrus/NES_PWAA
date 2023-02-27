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


update_input:
    ; if buttons_1_timer > 0
    LDA buttons_1_timer
    BEQ @timer_reset
    ; then
        ; buttons_1_timer--
        DEC buttons_1_timer
        ; input = 0
        LDA #$00
        STA buttons_1
        ; end
        JMP @end
    ; else
    @timer_reset:
        ; read input
        JSR readjoy
        ; if input != 0
        LDA buttons_1
        BEQ @end
            ; buttons_1_timer = BTN_TIMER
            LDA #BTN_TIMER
            STA buttons_1_timer
    @end:
    RTS
