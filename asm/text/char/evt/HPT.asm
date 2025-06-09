EVT_HPT:
    ; switch(hp_state)
    LDA hp_state
    ; case HP_STATE_HIDE:
    CMP #HP_STATE_HIDE
    BEQ :+
    ; case HP_STATE_EXIT:
    CMP #HP_STATE_EXIT
    BNE :++
    :
        ; hp_state = HP_STATE_ENTER
        mov hp_state, #HP_STATE_ENTER
        ; return
        RTS
    :
    ; case HP_STATE_SHOW:
    CMP #HP_STATE_SHOW
    BEQ :+
    ; case HP_STATE_ENTER:
    CMP #HP_STATE_ENTER
    BNE :++
    :
        ; hp_state = HP_STATE_EXIT
        mov hp_state, #HP_STATE_EXIT
        ; return
        RTS
    :
    ; error
    BRK
