.include "add.asm"
.include "load.asm"
.include "start.asm"
.include "step.asm"
.include "end.asm"
.include "draw.asm"
.include "nt.asm"

scroll_main:
    ; switch(scroll_state)
    ; case SCROLL_STATE_LOAD1
    LDA scroll_state
    CMP #SCROLL_STATE_LOAD1
    BNE :+
        ; X = scroll_img
        LDX scroll_img+0
        ; Y = 0
        ; scroll_n_img = 1
        LDY #$01
        STY scroll_n_img
        DEY
        ; scroll_load_1(X, Y)
        JSR scroll_load_1
        ; scroll_state = SCROLL_STATE_NONE
        LDA #SCROLL_STATE_NONE
        STA scroll_state
        ; break
        JMP @break
    :
    ; case SCROLL_STATE_LOAD2
    CMP #SCROLL_STATE_LOAD2
    BNE :+
        ; scroll_n_img = 2
        mov scroll_n_img, #2
        ; X = scroll_img_1
        LDX scroll_img+1
        ; Y = 0
        LDY #$00
        ; scroll_load_1(X, Y)
        JSR scroll_load_1
        ; X = scroll_img_2
        LDX scroll_img+0
        ; Y = 0
        LDY #$00
        ; scroll_load_2(X, Y)
        JSR scroll_load_2
        ; scroll_state = SCROLL_STATE_NONE
        LDA #SCROLL_STATE_NONE
        STA scroll_state
        ; break
        JMP @break
    :
    ; ; case SCROLL_STATE_LOAD
    ; CMP #SCROLL_STATE_LOAD
    ; BNE :+++
    ;     ; load correct image
    ;     LDX scroll_img+0
    ;     LDY scroll_img+1
    ;     LDA scroll_n_img
    ;     BEQ :+
    ;         JSR scroll_load_2
    ;         JMP :++
    ;     :
    ;         JSR scroll_load_1
    ;     :
    ;     INC scroll_n_img
    ;     ; scroll_state = SCROLL_STATE_NONE
    ;     LDA #SCROLL_STATE_NONE
    ;     STA scroll_state
    ;     ; break
    ;     JMP @break
    ; :
    ; case SCROLL_STATE_START
    LDA scroll_state
    CMP #SCROLL_STATE_START
    BNE :+
        ; scroll_start()
        JSR scroll_start
    :
    ; case SCROLL_STATE_STEP
    LDA scroll_state
    CMP #SCROLL_STATE_STEP
    BNE :+
        ; scroll_step()
        JSR scroll_step
    :
    ; case SCROLL_STATE_END
    LDA scroll_state
    CMP #SCROLL_STATE_END
    BNE :+
        ; scroll_end()
        JSR scroll_end
        ; break
        ; JMP @break
    :
    @break:
    ; return
    RTS
