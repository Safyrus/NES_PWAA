flush:
    ; variables
    @adr = tmp+0
    @packet = tmp+2

    ; if don't need to flush
    LDX print_start
    CPX print_offset
        ; return
        BEQ @return

    ; save tmps
    push tmp+0
    push tmp+1
    push tmp+2
    push tmp+3

    ; save bank
    LDA mmc5_banks+0
    PHA
    ; set image bank
    LDA #IMG_BUF_BNK
    STA mmc5_banks+0
    STA MMC5_RAM_BNK

    ; ----------------
    ; send text as packet
    ; ----------------
    ; adr = $2260 + print_start
    mov @adr+1, #$82 ; + high priority
    LDA #$60
    add print_start
    STA @adr+0
    BCC :+
        INC @adr+1
    :
    ; print_offset - print_start
    LDA print_offset
    sub print_start
    ; test for bugs
    CMP #$20
    bge :+
    bne :++
    :
        BRK
    :
    PHA
    TAY
    ; reserve packet
    JSR packet_buf_res
    INY
    ; copy text
    @loop:
        ; low tile
        LDA DB_ADR_LO, X
        STA (@packet), Y
        INY
        ; high tile
        LDA DB_ADR_HI, X
        STA (@packet), Y
        INY
        ; continue
        INX
        CPX print_offset
        BNE @loop
    ; close packet
    PLA
    JSR close_packet_nodefrag
    ; print_start = print_offset
    mov print_start, print_offset

    ; restore bank
    PLA
    STA mmc5_banks+0
    STA MMC5_RAM_BNK

    ; restore tmps
    pull tmp+3
    pull tmp+2
    pull tmp+1
    pull tmp+0

    ; return
    @return:
    RTS
