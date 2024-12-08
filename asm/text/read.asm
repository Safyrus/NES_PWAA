read:
    ; variables
    @n = txt_vars+0

    pushregs

    ; --------
    ; guard
    ; --------
    ; if text_wait_timer > 0
    LDA text_wait_timer
        ; return
        BNE @return

    ; --------
    ; init
    ; --------
    ; set busy flag
    ora_adr txt_flags, #TXT_FLAG_BUSY
    ; set text bank
    push mmc5_banks+0
    LDA #TEXT_BUF_BNK
    STA mmc5_banks+0
    STA MMC5_RAM_BNK
    ; n = text_speed_timer >> 5
    LDA text_speed_timer
    shift LSR, 5
    STA @n

    ; --------
    ; read
    ; --------
    ; while n > 0
    @while:
        LDA @n
        BEQ @while_end
        ; c = read_char()
        JSR read_char
        ; if c printable
        CMP #$20
        blt :+
            ; print(c)
            JSR print
            ; n--
            DEC @n
            ; continue
            JMP @while
        ; else
        :
            ; exec_char(c)
            TAX
            JSR exec_char
            ; continue
            JMP @while
    @while_end:

    ; update wait timer
    mov text_wait_timer, text_wait
    ; update speed timer
    LDA text_speed_timer
    AND #$1F ; number of char to display = 0
    add text_speed ; text_speed_timer += text_speed
    STA text_speed_timer

    ; flush text
    JSR flush

    ; clear busy flag
    and_adr txt_flags, #($FF-TXT_FLAG_BUSY)
    ; restore bank
    pull mmc5_banks+0
    STA MMC5_RAM_BNK

    ; return
    @return:
    pullregs
    RTS
