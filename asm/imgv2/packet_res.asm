; arg a = size
; adr = tmp+0
; return packet_buf_write_adr before calling function
; packet_buf_res(size, adr)
packet_buf_res:
    @adr = tmp+0
    PHA
    TYA
    PHA
    ; packet_buf_write_adr[0] = size | $40
    PHA
    LDY #$00
    ORA #$40
    STA (packet_buf_write_adr), Y
    ; packet_buf_write_adr[1] = adr_hi
    INY
    LDA @adr+1
    STA (packet_buf_write_adr), Y
    ; packet_buf_write_adr[2] = adr_lo
    INY
    LDA @adr+0
    STA (packet_buf_write_adr), Y
    ; packet_buf_write_adr += (3 + (size * 2))
    PLA
    ASL
    add #$03
    add_A2ptr packet_buf_write_adr
    ; packet_buf_write_adr %= PACKET_BUF_SIZE
    LDA packet_buf_write_adr+1
    AND #$03
    STA packet_buf_write_adr+1
    ; return
    PLA
    TAY
    PLA
    RTS
