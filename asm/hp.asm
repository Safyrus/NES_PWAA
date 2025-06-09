; A = number of hp
; X = index/type of hp
set_hp:
    ; hp[X] = A
    STA hps, X
    ; if A != hp_evt_n
    CMP hp_evt_n
        ; return
        BNE @ret
    ; if X != hp_evt_t
    CPX hp_evt_t
        ; return
        BNE @ret
    ; jump(hp_jmp)
    mov jmp_buf+0, hp_jmp+0
    mov jmp_buf+1, hp_jmp+1
    mov jmp_buf+2, hp_jmp+2
    JSR text_jump
    ; return
    @ret:
    RTS
