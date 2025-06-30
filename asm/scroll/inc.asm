.include "add.asm"
.include "load.asm"
.include "start.asm"
.include "step.asm"
.include "end.asm"
.include "draw.asm"
.include "nt.asm"

scroll_main:
    ; switch(scroll_state)
    ; case SCROLL_STATE_LOAD
    LDA scroll_state
    CMP #SCROLL_STATE_LOAD
    BNE :+++
        ; load correct image
        LDX scroll_img+0
        LDY scroll_img+1
        LDA scroll_n_img
        BEQ :+
            JSR scroll_load_2
            JMP :++
        :
            JSR scroll_load_1
        :
        INC scroll_n_img
        ; scroll_state = SCROLL_STATE_NONE
        LDA #SCROLL_STATE_NONE
        STA scroll_state
        ; break
        JMP @break
    :
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
