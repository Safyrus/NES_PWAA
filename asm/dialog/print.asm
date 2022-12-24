; description:
;   print one character
; param:
; - A: char to print
; use:
; - A and X
; - print_ppu_buf, print_ext_buf, print_counter
; /!\ does not save registers
print_char:
    LDX print_counter
    STA print_ppu_buf, X
    LDA print_ext_val
    STA print_ext_buf, X
    INC print_counter
    RTS

; description:
;   print a line break
print_lb:
    ; flush any characters
    JSR print_flush

    PHA

    ; change ppu pointer to next line
    LDA print_ppu_ptr+0
    AND #%11100000
    CLC
    ADC #$42
    STA print_ppu_ptr+0
    BCC @add_ppu_end
        INC print_ppu_ptr+1
    @add_ppu_end:

    ; change ext ram pointer to next line
    LDA print_ext_ptr+0
    AND #%11100000
    CLC
    ADC #$42
    STA print_ext_ptr+0
    BCC @add_ext_end
        INC print_ext_ptr+1
    @add_ext_end:

    PLA
    RTS

; description:
;   flush any text from text buffer to screen
; use: tmp[0..1]
print_flush:
    pushregs

    ; if print_counter == 0
    LDA print_counter
        ; then exit (we din't have any character to flush)
        BEQ @end

    ; - - - - - - - -
    ; copy ext_buf to ext ram
    ; - - - - - - - -
    ; tmp = print_ext_ptr
    LDA print_ext_ptr+0
    STA tmp+0
    LDA print_ext_ptr+1
    STA tmp+1
    ; Y = counter
    LDY print_counter
    DEY
    ; wait to be in frame
    @wait_inframe:
        BIT scanline
        BVC @wait_inframe
    ; for y to 0 (included)
    @cp_ext:
        ; copy
        LDA print_ext_buf, Y
        STA (tmp), Y
        ; next
        DEY
        BPL @cp_ext

    ; - - - - - - - -
    ; make ppu packet
    ; - - - - - - - -
    ; init
    LDX background_index
    ; packet += print_counter
    LDA print_counter
    STA background, X
    INX
    ; packet += print_ppu_ptr
    LDA print_ppu_ptr+1
    STA background, X
    INX
    LDA print_ppu_ptr+0
    STA background, X
    INX

    ; - - - - - - - -
    ; copy ppu_buf to packet
    ; - - - - - - - -
    ; Y = 0
    LDY #$00
    ; while Y < print_counter
    @cp_ppu:
        ; copy
        LDA print_ppu_buf, Y
        STA background, X
        INX
        ; next
        INY
        CPY print_counter
        BCC @cp_ppu

    ; - - - - - - - -
    ; close ppu packet
    ; - - - - - - - -
    LDA #$00
    STA background, X
    STX background_index

    ; - - - - - - - -
    ; update pointers
    ; - - - - - - - -
    ; print_ext_buf += print_counter
    LDA print_counter
    add_A2ptr print_ext_ptr
    ; print_ppu_buf += print_counter
    LDA print_counter
    add_A2ptr print_ppu_ptr
    ; print_counter = 0
    LDA #$00
    STA print_counter

    @end:
    pullregs
    RTS
