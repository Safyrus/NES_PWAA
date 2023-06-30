clear_collisions:
    ; set bank
    push mmc5_banks+0
    LDA #IMG_BUF_BNK
    STA mmc5_banks+0
    STA MMC5_RAM_BNK
    ; clear collisions
    LDA #$00
    TAX
    @loop:
        STA HITBOX_MAP+$000, X
        STA HITBOX_MAP+$100, X
        STA HITBOX_MAP+$200, X
    to_x_inc @loop, #0
    ; restore bank
    pull mmc5_banks+0
    STA MMC5_RAM_BNK
    ;
    RTS


; X, Y
set_collision:
    pushregs
    push tmp+0
    push tmp+1

    JSR get_collision_ptr
    LDY #$00
    LDA invest_tmp+0
    STA (tmp), Y

    pull tmp+1
    pull tmp+0
    pullregs
    RTS

; X, Y
get_collision_ptr:
    ; tmp+0 = X | (Y << 5)
    TYA
    shift ASL, 5
    STA tmp
    TXA
    ORA tmp
    STA tmp+0
    ; tmp+1 = Y >> 3 + HITBOX_MAP
    TYA
    shift LSR, 3
    add #>HITBOX_MAP
    STA tmp+1
    ;
    RTS


;
draw_collision:
    ; h += y
    LDA invest_tmp+2
    TAY
    add invest_tmp+4
    STA invest_tmp+4
    ; w += x
    LDA invest_tmp+1
    add invest_tmp+3
    STA invest_tmp+3
    ; for Y from y_pos to y+h:
    for_y @fory, invest_tmp+2
        ; for X from x_pos to x+w:
        for_x @forx, invest_tmp+1
            ; set_collision(X, Y, ptr_idx)
            JSR set_collision
        to_x_inc @forx, invest_tmp+3
    to_y_inc @fory, invest_tmp+4
    RTS

