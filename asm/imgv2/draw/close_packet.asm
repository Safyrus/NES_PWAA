; A = real size
; packet_adr = tmp+2
close_packet:
    @size = close_packet_var
    @packet_adr = tmp+2

    STA @size
    pushregs
    LDX @size
    ; size = packet_adr[0]
    LDY #$00
    LDA (@packet_adr), Y
    AND #$3F
    STA @size
    ; if draw_packet_count <= 1
    LDA draw_packet_count
    CMP #$02
    bge @end
        ; dif = size - realsize
        TXA
        sub @size
        EOR #$FF
        add #$01
        ; size = dif*2
        ASL
        STA @size
        ; if dif != 0
        BEQ :++
            ; @packet_buf_write_adr -= size
            LDA packet_buf_write_adr+0
            sub @size
            STA packet_buf_write_adr+0
            BCS :+
                DEC packet_buf_write_adr+1
            :
        :
    @end:
    ; packet_adr[0] = realsize
    TXA
    STA (@packet_adr), Y
    ; draw_packet_count--
    JSR dec_draw_packet_count
    ; return
    pullregs
    RTS


; A = real size
; packet_adr = tmp+2
; clear Y
close_packet_nodefrag:
    PHA
    ; packet_adr[0] = realsize
    LDY #$00
    STA (tmp+2), Y
    ; draw_packet_count--
    JSR dec_draw_packet_count
    ; return
    PLA
    RTS

dec_draw_packet_count:
    ; draw_packet_count--
    LDA draw_packet_count
    BNE :+
        ; Error
        BRK
    :
    sub #$01
    STA draw_packet_count
    ; if draw_packet_count == 0 without no defrag flag
    AND #$7F
    BNE :+
        ; clear no defrag flag
        STA draw_packet_count
    :
    ; return
    RTS
