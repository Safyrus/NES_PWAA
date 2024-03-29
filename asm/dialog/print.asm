; description:
;   print one character
; param:
; - A: char to print
; use:
; - A and X
; - print_ppu_buf, print_ext_buf, print_counter
; /!\ does not save the X register
print_char:
    PHA

    ; if char < $20 then return
    CMP #$20
    blt @end
    ; print_ppu_buf[X] = char + (font << 7)
    LDX print_counter
    STA print_ppu_buf, X
    LDA txt_font
    AND #$01
    CLC
    ROR
    ROR
    ADC print_ppu_buf, X
    STA print_ppu_buf, X
    ; print_ext_buf[X] = print_ext_val
    LDA print_ext_val
    STA print_ext_buf, X
    ; x++
    INC print_counter

    @end:
    PLA
    RTS

; description:
;   print a line break
print_lb:
    ; flush any characters
    JSR print_flush
    JMP print_lb_noflush

print_lb_noflush:
    PHA

    ; change ppu pointer to next line
    LDA print_ppu_ptr+0
    AND #%11100000
    add print_nl_offset
    STA print_ppu_ptr+0
    BCC @add_ppu_end
        INC print_ppu_ptr+1
    @add_ppu_end:

    ; change ext ram pointer to next line
    LDA print_ext_ptr+0
    AND #%11100000
    add print_nl_offset
    STA print_ext_ptr+0
    BCC @add_ext_end
        INC print_ext_ptr+1
    @add_ext_end:

    PLA
    RTS

print_flush_wait:
    ; if background buffer is too full
    LDA background_index
    add print_counter
    CMP #$40
    blt @start
        ; then wait for it to be empty
        JSR wait_next_frame
    @start:
    ;
    JMP print_flush

; description:
;   flush any text from text buffer to screen
; use: tmp[0..1]
print_flush:
    pushregs

    LDA tmp+0
    PHA
    LDA tmp+1
    PHA

    ; if text box hidden, then just update pointers
    BIT box_flags
    BMI print_flush_force_update_pointer

    JMP _print_flush


print_flush_force:
    pushregs

    LDA tmp+0
    PHA
    LDA tmp+1
    PHA
_print_flush:
    ; if print_counter == 0
    LDA print_counter
        ; then exit (we din't have any character to flush)
        bze @end

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
        blt @cp_ppu

    ; - - - - - - - -
    ; close ppu packet
    ; - - - - - - - -
    LDA #$00
    STA background, X
    STX background_index

    ; make bip sound
    JSR read_bip

    ; - - - - - - - -
    ; update pointers
    ; - - - - - - - -
    @update_ptrs:
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
    PLA
    STA tmp+1
    PLA
    STA tmp+0

    pullregs
    RTS

print_flush_force_update_pointer = @update_ptrs
