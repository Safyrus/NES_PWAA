; arg Y = size
; adr = tmp+0
; return
; - tmp+2 = packet adr
; - Y=2
packet_buf_res:
    @adr = tmp+0
    @pack_adr = tmp+2

    TXA
    PHA

    ; push values to save them
    ; from being overwriten by something else
    push @adr+0
    push @adr+1
    push @pack_adr+0
    push @pack_adr+1

    ; wait for free space
    @wait:
        ; if packet_buf_write_adr >= packet_buf_read_adr
        LDA packet_buf_write_adr+1
        CMP packet_buf_read_adr+1
        blt :+
            ; dif = packet_buf_write_adr - $400
            sub #$04
        :
        ; dif = abs(dif - packet_buf_read_adr)
        sub packet_buf_read_adr+1
        EOR #$FF
        add #$01
        ; wait if dif < $100
        CMP #$02
        blt @wait
    ; wait if at the very end of frame
    :
        LDA scanline
        CMP #SCANLINE_BOT_IMG
        BEQ :-
    ; if packet_buf_write_adr + (size*2+3) >= $400
    LDA packet_buf_write_adr+1
    CMP #$63
    BNE :+
    TYA
    ASL
    CLC
    ADC #$03
    ADC packet_buf_write_adr+0
    BCC :+
        ; packet_buf_write_adr = PACKET_BUFFER_ADR
        ; because we just want to write to packet with an offset
        ; and not moving the pointer will result in a overflow
        mov packet_buf_write_adr+0, #<PACKET_BUFFER_ADR
        mov packet_buf_write_adr+1, #>PACKET_BUFFER_ADR
    :
    ; draw_packet_count++
    LDA draw_packet_count
    add #$01
    ; if draw_packet_count >= 2
    CMP #$02
    blt :+
        ; disable defrag
        ORA #$80
    :
    STA draw_packet_count
    ; pack_adr = packet_buf_write_adr
    PLA
    STA @pack_adr+1
    PLA
    STA @pack_adr+0
    mov @pack_adr+1, packet_buf_write_adr+1
    mov @pack_adr+0, packet_buf_write_adr+0
    ; packet_buf_write_adr[0] = size | $40
    TYA
    TAX
    LDY #$00
    ORA #$40
    STA (packet_buf_write_adr), Y
    ; packet_buf_write_adr[1] = adr_hi
    INY
    PLA
    STA @adr+1
    STA (packet_buf_write_adr), Y
    ; packet_buf_write_adr[2] = adr_lo
    INY
    PLA
    STA @adr+0
    STA (packet_buf_write_adr), Y
    ; packet_buf_write_adr += (3 + (size * 2))
    TXA
    ASL
    add #$03
    add_A2ptr packet_buf_write_adr
    ; packet_buf_write_adr %= PACKET_BUF_SIZE
    LDA packet_buf_write_adr+1
    AND #>(PACKET_BUFFER_ADR+$3FF)
    STA packet_buf_write_adr+1
    ; return pack_adr
    PLA
    TAX
    RTS
